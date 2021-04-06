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

local radial = {}
local guis = {}

radial.fonts = {}
radial.defaultFont = lg.getFont()

function radial:new(n, id, p)
	local r = element()
	r.__index = radial
	r.name = n
	r.id = id
	r.type = "radial"
	if p then 
		if not guis[p.id] then guis[p.id] = p end
		if p.id then r.parent = p.id else r.parent = nil end
	end
	r.uW = 0
	r.uH = 0
	r.size = 0
	r.label = ""
	r.selected = {}
	r.selectedBorder = {1,1,1,1}
	r.labelColor = {1,1,1,1}
	r.labelPosition = {
		x = 0,
		y = 0,
		z = 0
	}
	r.font = self.defaultFont
	r.labelFont = self.defaultFont
	r.borderColor = {1,1,1,1}
	r.optionFont = self.defaultFont
	r.optionsColor = {1,1,1,1}
	r.paddingLeft = 0
	r.paddingRight = 0
	r.paddingTop = 0
	r.paddingBottom = 0
	r.options = {}
	r.optionPaddingLeft = 0
	r.optionPaddingRight = 0
	r.optionPaddingTop = 0
	r.optionPaddingBottom = 0
	r.overlayColor = {1,1,1,1}
	r.shadowLabel = false
	r.vertical = false
	
	return setmetatable(r, r)
end

function radial:animateBorderToColor(t, s, f)
	assert(t, "[" .. self.name .. "] FAILURE: radial:animateBorderToColor() :: Missing param[color]")
	assert(type(t) == "table", "[" .. self.name .. "] FAILURE: radial:animateBorderToColor() :: Incorrect param[color] - expecting table and got " .. type(t))
	assert(#t > 2, "[" .. self.name .. "] FAILURE: radial:animateBorderToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #t)
	s = s or 2
	assert(type(s) == "number", "[" .. self.name .. "] FAILURE: radial:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
	if not self.fadedByFunc or f then
		self.borderColorToAnimateTo = t
		self.borderColorAnimateSpeed = s
		self.borderColorAnimateTime = 0
		self.inAnimation = true
		self.animateBorderColor = true
	end
	return self
end

function radial:animateBorderToOpacity(o, s, f)
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

function radial:setBorderColor(bC)
	assert(bC, "[" .. self.name .. "] FAILURE: radial:setBorderColor() :: Missing param[color]")
	assert(type(bC) == "table", "[" .. self.name .. "] FAILURE: radial:setBorderColor() :: Incorrect param[color] - expecting table and got " .. type(bC))
	assert(#bC == 4, "[" .. self.name .. "] FAILURE: radial:setBorderColor() :: Incorrect param[color] - table length 4 expected and got " .. #bC)
	self.borderColor = bC
	return self
end

function radial:getBorderColor()
	return self.borderColor
end

function radial:setFont(f)
	assert(f, "[" .. self.name .. "] FAILURE: radial:setFont() :: Missing param[font]")
	assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: radial:setFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
	self.font = f
	return self
end

function radial:getFont()
	return self.font
end

function radial:setForceOption(f)
	assert(f ~= nil, "[" .. self.name .. "] FAILURE: radial:setForceOption() :: Missing param[hollow]")
	assert(type(f) == "boolean", "[" .. self.name .. "] FAILURE: radial:setForceOption() :: Incorrect param[hollow] - expecting boolean and got " .. type(f))
	self.forceOption = f
	return self
end

function radial:getForceOption()
	return self.forceOption
end

function radial:setLabel(l)
	assert(l, "[" .. self.name .. "] FAILURE: radial:setLabel() :: Missing param[label]")
	assert(type(l) == "string", "[" .. self.name .. "] FAILURE: radial:setLabel() :: Incorrect param[label] - expecting string and got " .. type(l))
	self.label = l
	return self
end

function radial:getLabel()
	return self.label
end

function radial:setLabelColor(t)
	assert(t, "[" .. self.name .. "] FAILURE: radial:setLabelColor() :: Missing param[color]")
	assert(type(t) == "table", "[" .. self.name .. "] FAILURE: radial:setLabelColor() :: Incorrect param[color] - expecting table and got " .. type(t))
	assert(#t == 4, "[" .. self.name .. "] FAILURE: radial:setLabelColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
	self.labelColor = t
	return self
end

function radial:getLabelColor()
	return self.labelColor
end

function radial:setLabelFont(f)
	assert(f, "[" .. self.name .. "] FAILURE: radial:setLabelFont() :: Missing param[font]")
	assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: radial:setLabelFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
	self.labelFont = f
	return self
end

function radial:getLabelFont()
	return self.labelFont
end

function radial:setLabelPosition(t)
	assert(t, "[" .. self.name .. "] FAILURE: radial:setLabelPosition() :: Missing param[position]")
	assert(type(t) == "table", "[" .. self.name .. "] FAILURE: radial:setLabelPosition() :: Incorrect param[position] - expecting table and got " .. type(t))
	assert(#t == 3, "[" .. self.name .. "] FAILURE: radial:setLabelPosition() :: Incorrect param[position] - table length 4 expected and got " .. #t)
	if t.x then
		self.labelPosition = t
	else
		self.labelPosition.x, self.labelPosition.y, self.labelPosition.z = unpack(t)
	end
	return self
end

function radial:getLabelPosition()
	return self.labelPosition
end

function radial:addOption(o)
	assert(o, "[" .. self.name .. "] FAILURE: radial:addOption() :: Missing param[option]")
	assert(type(o) == "string", "[" .. self.name .. "] FAILURE: radial:addOption() :: Incorrect param[option] - expecting string and got " .. type(o))
	local x,y
	
	if self.vertical then
		x,y = self.paddingLeft + self.pos.x + self.paddingRight, self.paddingTop + self.pos.y + self.font:getHeight(o) + self.paddingBottom
	else
		x,y = self.paddingLeft + self.options[#self.options].x + self.font:getWidth(o) + self.paddingRight, self.paddingTop + self.pos.y + self.paddingBottom
	end
	self.options[#self.options + 1] = {text = o, x = x, y = y}
	return self
end

function radial:removeOption(o)
	assert(o, "[" .. self.name .. "] FAILURE: radial:addOption() :: Missing param[option]")
	assert(type(o) == "string", "[" .. self.name .. "] FAILURE: radial:addOption() :: Incorrect param[option] - expecting string and got " .. type(o))
	for k,v in ipairs(self.options) do
		if v.text == o then self.options[k] = nil end
	end
	return self
end

function radial:setOptionColor(t)
	assert(t, "[" .. self.name .. "] FAILURE: radial:setOverlayColor() :: Missing param[color]")
	assert(type(t) == "table", "[" .. self.name .. "] FAILURE: radial:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
	assert(#t == 4, "[" .. self.name .. "] FAILURE: radial:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
	self.optionsColor = t
	return self
end

function radial:getOptionColor()
	return self.optionsColor
end

function radial:setOptionPadding(p)
	assert(p, "[" .. self.name .. "] FAILURE: radial:setOptionPadding() :: Missing param[padding]")
	assert(type(p) == "table", "[" .. self.name .. "] FAILURE: radial:setOptionPadding() :: Incorrect param[padding] - expecting table and got " .. type(p))
	assert(#p == 4, "[" .. self.name .. "] FAILURE: radial:setOptionPadding() :: Incorrect param[padding] - expecting table length 4 and got " .. #p)
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

function radial:setOptionPaddingBottom(p)
	assert(p, "[" .. self.name .. "] FAILURE: radial:setOptionPaddingBottom() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: radial:setOptionPaddingBottom() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.OptionaddingBottom = p
	return self
end

function radial:setOptionPaddingLeft(p)
	assert(p, "[" .. self.name .. "] FAILURE: radial:setOptionPaddingLeft() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: radial:setOptionPaddingLeft() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.OptionaddingLeft = p
	return self
end

function radial:setOptionPaddingRight(p)
	assert(p, "[" .. self.name .. "] FAILURE: radial:setOptionPaddingRight() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: radial:setOptionPaddingRight() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.OptionaddingRight = p
	return self
end

function radial:setOptionPaddingTop(p)
	assert(p, "[" .. self.name .. "] FAILURE: radial:setOptionPaddingTop() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: radial:setOptionPaddingTop() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.OptionaddingTop = p
	return self
end

function radial:setOverlayColor(t)
	assert(t, "[" .. self.name .. "] FAILURE: radial:setOverlayColor() :: Missing param[color]")
	assert(type(t) == "table", "[" .. self.name .. "] FAILURE: radial:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
	assert(#t == 4, "[" .. self.name .. "] FAILURE: radial:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
	self.overlayColor = t
	return self
end

function radial:getOverlayColor()
	return self.overlayColor
end

return setmetatable(radial, radial)