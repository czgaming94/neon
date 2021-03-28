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
local object = require("neon.object")

local checkbox = {}

checkbox.guis = {}

function checkbox:new(n, id, p)
	local c = object()
	c.__index = c
	c.name = n
	c.id = id
	c.type = "checkbox"
	if p then 
		if not self.guis[p.id] then self.guis[p.id] = p end
		if p.id then c.parent = p.id else c.parent = nil end
	end
	c.uW = 0
	c.uH = 0
	c.label = ""
	c.labelColor = {1,1,1,1}
	c.labelPosition = {
		x = 0,
		y = 0,
		z = 0
	}
	c.border = false
	c.borderColor = {1,1,1,1}
	c.overlayColor = {1,1,1,.5}
	c.optionsColor = {1,1,1,1}
	c.paddingLeft = 0
	c.paddingRight = 0
	c.paddingTop = 0
	c.paddingBottom = 0
	c.r = {0,0,0,0}
	c.font = lg.getFont()
	c.labelFont = lg.getFont()
	c.vertical = false
	c.round = false
	c.shadowLabel = false
	c.single = false
	c.fixPadding = false
	c.forceOption = false
	c.options = {}
	c.optionPaddingLeft = 0
	c.optionPaddingRight = 0
	c.optionPaddingTop = 0
	c.optionPaddingBottom = 0
	c.selected = {}
	c.selectedBorder = {1,1,1,1}
	c.animateBorderOpacity = true
	c.opacityToAnimateBorderTo = 0
	c.opacityBorderAnimateTime = 0
	c.opacityBorderAnimateSpeed = 0
	
	function c:animateBorderToColor(t, s, f)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:animateBorderToColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:animateBorderToColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t > 2, "[" .. self.name .. "] FAILURE: checkbox:animateBorderToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #t)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: checkbox:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			self.borderColorToAnimateTo = t
			self.borderColorAnimateSpeed = s
			self.borderColorAnimateTime = 0
			self.inAnimation = true
			self.animateBorderColor = true
		end
		return self
	end
	
	function c:animateBorderToOpacity(o, s, f)
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
	
	function c:setBorderColor(bC)
		assert(bC, "[" .. self.name .. "] FAILURE: checkbox:setBorderColor() :: Missing param[color]")
		assert(type(bC) == "table", "[" .. self.name .. "] FAILURE: checkbox:setBorderColor() :: Incorrect param[color] - expecting table and got " .. type(bC))
		assert(#bC == 4, "[" .. self.name .. "] FAILURE: checkbox:setBorderColor() :: Incorrect param[color] - table length 4 expected and got " .. #bC)
		self.borderColor = bC
		return self
	end
	
	function c:getBorderColor()
		return self.borderColor
	end
	
	function c:fixPadding(f)
		assert(f ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Missing param[hollow]")
		assert(type(f) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Incorrect param[hollow] - expecting boolean and got " .. type(f))
		self.fixPadding = f
		return self
	end
	
	function c:getFixPadding()
		return self.fixPadding
	end
	
	function c:setFont(f)
		assert(f, "[" .. self.name .. "] FAILURE: checkbox:setFont() :: Missing param[font]")
		assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: checkbox:setFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		self.font = f
		return self
	end
	
	function c:getFont()
		return self.font
	end
	
	function c:setForceOption(f)
		assert(f ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setForceOption() :: Missing param[hollow]")
		assert(type(f) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setForceOption() :: Incorrect param[hollow] - expecting boolean and got " .. type(f))
		self.forceOption = f
		return self
	end
	
	function c:getForceOption()
		return self.forceOption
	end
	
	function c:setLabel(l)
		assert(l, "[" .. self.name .. "] FAILURE: checkbox:setLabel() :: Missing param[label]")
		assert(type(l) == "string", "[" .. self.name .. "] FAILURE: checkbox:setLabel() :: Incorrect param[label] - expecting string and got " .. type(l))
		self.label = l
		return self
	end
	
	function c:getLabel()
		return self.label
	end
	
	function c:setLabelColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:setLabelColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:setLabelColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: checkbox:setLabelColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.labelColor = t
		return self
	end
	
	function c:getLabelColor()
		return self.labelColor
	end
	
	function c:setLabelFont(f)
		assert(f, "[" .. self.name .. "] FAILURE: checkbox:setLabelFont() :: Missing param[font]")
		assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: checkbox:setLabelFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		self.labelFont = f
		return self
	end
	
	function c:getLabelFont()
		return self.labelFont
	end
	
	function c:setLabelPosition(t)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:setLabelPosition() :: Missing param[position]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:setLabelPosition() :: Incorrect param[position] - expecting table and got " .. type(t))
		assert(#t == 3, "[" .. self.name .. "] FAILURE: checkbox:setLabelPosition() :: Incorrect param[position] - table length 4 expected and got " .. #t)
		if t.x then
			self.labelPosition = t
		else
			self.labelPosition.x, self.labelPosition.y, self.labelPosition.z = unpack(t)
		end
		return self
	end
	
	function c:getLabelPosition()
		return self.labelPosition
	end
	
	function c:addOption(o)
		assert(o, "[" .. self.name .. "] FAILURE: checkbox:addOption() :: Missing param[option]")
		assert(type(o) == "string", "[" .. self.name .. "] FAILURE: checkbox:addOption() :: Incorrect param[option] - expecting string and got " .. type(o))
		local x,y
		
		if self.vertical then
			x,y = self.paddingLeft + self.pos.x + self.paddingRight, self.paddingTop + self.pos.y + self.font:getHeight(o) + self.paddingBottom
		else
			x,y = self.paddingLeft + self.options[#self.options].x + self.font:getWidth(o) + self.paddingRight, self.paddingTop + self.pos.y + self.paddingBottom
		end
		self.options[#self.options + 1] = {text = o, x = x, y = y}
		return self
	end
	
	function c:removeOption(o)
		assert(o, "[" .. self.name .. "] FAILURE: checkbox:addOption() :: Missing param[option]")
		assert(type(o) == "string", "[" .. self.name .. "] FAILURE: checkbox:addOption() :: Incorrect param[option] - expecting string and got " .. type(o))
		for k,v in ipairs(self.options) do
			if v.text == o then self.options[k] = nil end
		end
		return self
	end
	
	function c:setOptionColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.optionsColor = t
		return self
	end
	
	function c:getOptionColor()
		return self.optionsColor
	end
	
	function c:setOptionPadding(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPadding() :: Missing param[padding]")
		assert(type(p) == "table", "[" .. self.name .. "] FAILURE: checkbox:setOptionPadding() :: Incorrect param[padding] - expecting table and got " .. type(p))
		assert(#p == 4, "[" .. self.name .. "] FAILURE: checkbox:setOptionPadding() :: Incorrect param[padding] - expecting table length 4 and got " .. #p)
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
	
	function c:setOptionPaddingBottom(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingBottom() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingBottom() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingBottom = p
		return self
	end
	
	function c:setOptionPaddingLeft(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingLeft() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingLeft() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingLeft = p
		return self
	end
	
	function c:setOptionPaddingRight(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingRight() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingRight() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingRight = p
		return self
	end
	
	function c:setOptionPaddingTop(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingTop() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingTop() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingTop = p
		return self
	end
	
	function c:setOverlayColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.overlayColor = t
		return self
	end
	
	function c:getOverlayColor()
		return self.overlayColor
	end
	
	return c
end

return setmetatable(checkbox, checkbox)