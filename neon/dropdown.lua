--[[
	Copyright (c) 2021- David Ashton | CognizanceGaming
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	Except as contained in this notice, the name(s) of the above copyright holders
	shall not be used in advertising or otherwise to promote the sale, use or
	other dealings in this Software without prior written authorization.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
--]]



local lg, lt = love.graphics, love.timer
local min, max = math.min, math.max
local element = require("neon.element")

local dropdown = {}
dropdown.defaultFont = lg.getFont()

local guis = {}
dropdown.fonts = {}

function dropdown:new(n, id, p)
	local d = element()
	d.__index = dropdown
	d.name = n
	d.id = id
	d.type = "dropdown"
	if p then 
		if not guis[p.id] then guis[p.id] = p end
		if p.id then d.parent = p else d.parent = nil end
	end
	d.dW = 0
	d.uW = 0
	d.dH = 0
	d.uH = 0
	d.label = ""
	d.labelColor = {1,1,1,1}
	d.labelPosition = {
		x = 0,
		y = 0,
		z = 0
	}
	d.overlayColor = {1,1,1,.5}
	d.optionsColor = {1,1,1,1}
	d.r = {0,0,0,0}
	d.font = self.defaultFont
	d.optionFont = self.defaultFont
	d.open = false
	d.closeOnUnfocus = false
	d.vertical = false
	d.round = false
	d.single = false
	d.fixPadding = false
	d.options = {}
	d.optionPaddingLeft = 0
	d.optionPaddingRight = 0
	d.optionPaddingTop = 0
	d.optionPaddingBottom = 0
	d.selected = 0
	d.animateBorderColor = false
	d.borderColorToAnimateTo = {1,1,1,1}
	d.borderColorAnimateSpeed = 0
	d.borderColorAnimateTime = 0
	d.animateBorderOpacity = true
	d.opacityToAnimateBorderTo = 0
	d.opacityBorderAnimateTime = 0
	d.opacityBorderAnimateSpeed = 0
	
	return setmetatable(d, d)
end

function dropdown:animateBorderToColor(t, s, f)
	assert(t, "[" .. self.name .. "] FAILURE: dropdown:animateBorderToColor() :: Missing param[color]")
	assert(type(t) == "table", "[" .. self.name .. "] FAILURE: dropdown:animateBorderToColor() :: Incorrect param[color] - expecting table and got " .. type(t))
	assert(#t > 2, "[" .. self.name .. "] FAILURE: dropdown:animateBorderToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #t)
	s = s or 2
	assert(type(s) == "number", "[" .. self.name .. "] FAILURE: dropdown:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
	if not self.fadedByFunc or f then
		self.borderColorToAnimateTo = t
		self.borderColorAnimateSpeed = s
		self.borderColorAnimateTime = 0
		self.inAnimation = true
		self.animateBorderColor = true
	end
	return self
end

function dropdown:animateBorderToOpacity(o, s, f)
	assert(o, "[" .. self.name .. "] FAILURE: box:animateBorderToOpacity() :: Missing param[o]")
	assert(type(o) == "number", "[" .. self.name .. "] FAILURE: box:animateBorderToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
	s = s or 1
	assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateBorderToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
	if not self.fadedByFunc or f then
		self.opacityToAnimateBorderTo = o
		self.opacityBorderAnimateTime = 0
		self.opacityBorderAnimateSpeed = s
		self.inAnimation = true
		self.animateBorderOpacity = true
	end
	return self
end

function dropdown:setBorderColor(bC)
	assert(bC, "[" .. self.name .. "] FAILURE: dropdown:setBorderColor() :: Missing param[color]")
	assert(type(bC) == "table", "[" .. self.name .. "] FAILURE: dropdown:setBorderColor() :: Incorrect param[color] - expecting table and got " .. type(bC))
	assert(#bC == 4, "[" .. self.name .. "] FAILURE: dropdown:setBorderColor() :: Incorrect param[color] - table length 4 expected and got " .. #bC)
	self.borderColor = bC
	return self
end

function dropdown:getBorderColor()
	return self.borderColor
end

function dropdown:setFont(f)
	assert(f, "[" .. self.name .. "] FAILURE: dropdown:setFont() :: Missing param[font]")
	assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: dropdown:setFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
	self.font = f
	return self
end

function dropdown:getFont()
	return self.font
end

function dropdown:addOption(o)
	assert(o, "[" .. self.name .. "] FAILURE: dropdown:addOption() :: Missing param[option]")
	assert(type(o) == "string", "[" .. self.name .. "] FAILURE: dropdown:addOption() :: Incorrect param[option] - expecting string and got " .. type(o))
	local x,y
	
	if self.vertical then
		x,y = self.paddingLeft + self.pos.x + self.paddingRight, self.paddingTop + self.pos.y + self.font:getHeight(o) + self.paddingBottom
	else
		x,y = self.paddingLeft + self.options[#self.options].x + self.font:getWidth(o) + self.paddingRight, self.paddingTop + self.pos.y + self.paddingBottom
	end
	self.options[#self.options + 1] = {text = o, x = x, y = y}
	return self
end

function dropdown:removeOption(o)
	assert(o, "[" .. self.name .. "] FAILURE: dropdown:addOption() :: Missing param[option]")
	assert(type(o) == "string", "[" .. self.name .. "] FAILURE: dropdown:addOption() :: Incorrect param[option] - expecting string and got " .. type(o))
	for k,v in ipairs(self.options) do
		if v.text == o then self.options[k] = nil end
	end
	return self
end

function dropdown:setOptionColor(t)
	assert(t, "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Missing param[color]")
	assert(type(t) == "table", "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
	assert(#t == 4, "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
	self.optionsColor = t
	return self
end

function dropdown:getOptionColor()
	return self.optionsColor
end

function dropdown:setOptionPadding(p)
	assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPadding() :: Missing param[padding]")
	assert(type(p) == "table", "[" .. self.name .. "] FAILURE: dropdown:setOptionPadding() :: Incorrect param[padding] - expecting table and got " .. type(p))
	assert(#p == 4, "[" .. self.name .. "] FAILURE: dropdown:setOptionPadding() :: Incorrect param[padding] - expecting table length 4 and got " .. #p)
	if p.t or p.top or p.paddingTop then
		self.optionPaddingTop = p.t or p.top or p.paddingTop 
		self.optionPaddingRight = p.r or p.right or p.paddingRight or self.optionPaddingRight
		self.optionPaddingBottom = p.b or p.bottom or p.paddingBottom or self.optionPaddingBottom
		self.optionPaddingLeft = p.l or p.left or p.paddingLeft or self.optionPaddingLeft
	else
		self.optionPaddingTop, self.optionPaddingRight, self.optionPaddingBottom, self.optionPaddingTop = unpack(p)
	end
	return self
end

function dropdown:setOptionPaddingBottom(p)
	assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingBottom() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingBottom() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.OptionaddingBottom = p
	return self
end

function dropdown:setOptionPaddingLeft(p)
	assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingLeft() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingLeft() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.OptionaddingLeft = p
	return self
end

function dropdown:setOptionPaddingRight(p)
	assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingRight() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingRight() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.OptionaddingRight = p
	return self
end

function dropdown:setOptionPaddingTop(p)
	assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingTop() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingTop() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.OptionaddingTop = p
	return self
end

function dropdown:setOverlayColor(t)
	assert(t, "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Missing param[color]")
	assert(type(t) == "table", "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
	assert(#t == 4, "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
	self.overlayColor = t
	return self
end

function dropdown:getOverlayColor()
	return self.overlayColor
end

return setmetatable(dropdown,dropdown)