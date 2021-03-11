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
local checkbox = {}

checkbox.items = {}
checkbox.guis = {}


function checkbox:new(n, p)
	local c = {}
	if not self.guis[p.id] then self.guis[p.id] = p end
	c.name = n
	c.id = #self.items + 1
	c.type = "checkbox"
	if p and p.id then c.parent = p.id else c.parent = nil end
	c.w = 0
	c.uW = 0
	c.h = 0
	c.uH = 0
	c.pos = {
		x = 0,
		y = 0,
		z = 0
	}
	c.x = c.pos.x
	c.y = c.pos.y
	c.z = c.pos.z
	c.label = ""
	c.labelColor = {1,1,1,1}
	c.labelPosition = {
		x = 0,
		y = 0,
		z = 0
	}
	c.border = false
	c.borderColor = {1,1,1,1}
	c.color = {1,1,1,1}
	c.overlayColor = {1,1,1,.5}
	c.optionsColor = {1,1,1,1}
	c.paddingLeft = 0
	c.paddingRight = 0
	c.paddingTop = 0
	c.paddingBottom = 0
	c.roundRadius = 0
	c.font = lg.getFont()
	c.labelFont = lg.getFont()
	c.hovered = false
	c.clicked = false
	c.clickable = true
	c.faded = false
	c.fadedByFunc = false
	c.hidden = false
	c.vertical = false
	c.round = false
	c.hollow = false
	c.single = false
	c.fixPadding = false
	c.moveable = false
	c.held = false
	c.events = {}
	c.options = {}
	c.optionPaddingLeft = 0
	c.optionPaddingRight = 0
	c.optionPaddingTop = 0
	c.optionPaddingBottom = 0
	c.selected = {}
	c.font = lg.getFont()
	c.inAnimation = false
	c.animateColor = false
	c.colorToAnimateTo = {1,1,1,1}
	c.colorAnimateSpeed = 0
	c.colorAnimateTime = lt.getTime()
	c.animatePosition = false
	c.positionAnimateSpeed = 0
	c.positionToAnimateTo = {x = 0, y = 0}
	c.positionToAnimateFrom = {x = 0, y = 0}
	c.positionAnimateTime = lt.getTime()
	c.animateOpacity = false
	c.opacityAnimateSpeed = 0
	c.opacityToAnimateTo = 0
	c.opacityAnimateTime = lt.getTime()
	
	function c:animateToColor(t, s)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:animateToColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:animateToColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: checkbox:animateToColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: checkbox:animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.colorToAnimateTo = t
		self.colorAnimateSpeed = s
		self.colorAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animateColor = true
	end
	
	function c:animateBorderToColor(t, s)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:animateBorderToColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:animateBorderToColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t > 2, "[" .. self.name .. "] FAILURE: checkbox:animateBorderToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #t)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: checkbox:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.borderColorToAnimateTo = t
		self.borderColorAnimateSpeed = s
		self.borderColorAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animateBorderColor = true
	end
	
	function c:animateToPosition(x, y, s)
		assert(x, "[" .. self.name .. "] FAILURE: checkbox:animateToPosition() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: checkbox:animateToPosition() :: Incorrect param[x] - expecting number and got " .. type(x))
		assert(y, "[" .. self.name .. "] FAILURE: checkbox:animateToPosition() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: checkbox:animateToPosition() :: Incorrect param[y] - expecting number and got " .. type(y))
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: checkbox:animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
		for k,v in pairs(self.pos) do self.positionToAnimateFrom[k] = v end
		self.positionToAnimateTo = {x = x, y = y}
		self.positionAnimateDrag = s
		self.positionAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animatePosition = true
	end
	
	function c:animateToOpacity(o, s)
		assert(o, "[" .. self.name .. "] FAILURE: checkbox:animateToOpacity() :: Missing param[o]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: checkbox:animateToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
		s = s or 1
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: checkbox:animateToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.opacityToAnimateTo = o
		self.opacityAnimateTime = lt.getTime()
		self.opacityAnimateSpeed = s
		self.inAnimation = true
		self.animateOpacity = true
	end
	
	function c:isAnimating()
		return self.inAnimation
	end
	
	function c:startAnimation()
		self.inAnimation = true
	end
	
	function c:stopAnimation()
		self.inAnimation = false
	end
	
	function c:setBorderColor(bC)
		assert(bC, "[" .. self.name .. "] FAILURE: checkbox:setBorderColor() :: Missing param[color]")
		assert(type(bC) == "table", "[" .. self.name .. "] FAILURE: checkbox:setBorderColor() :: Incorrect param[color] - expecting table and got " .. type(bC))
		assert(#bC == 4, "[" .. self.name .. "] FAILURE: checkbox:setBorderColor() :: Incorrect param[color] - table length 4 expected and got " .. #bC)
		self.borderColor = bC
	end
	
	function c:getBorderColor()
		return self.borderColor
	end
	
	function c:setClickable(t)
		assert(t ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setClickable() :: Missing param[clickable]")
		assert(type(t) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setClickable() :: Incorrect param[clickable] - expecting boolean and got " .. type(t))
		self.clickable = t
	end
	
	function c:isClickable()
		return self.clickable
	end
	
	function c:setColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:setColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:setColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: checkbox:setColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.color = t
	end
	
	function c:getColor()
		return self.color
	end
	
	function c:setData(d)
		assert(d, "[" .. self.name .. "] FAILURE: checkbox:setData() :: Missing param[data]")
		assert(type(d) == "table", "[" .. self.name .. "] FAILURE: checkbox:setData() :: Incorrect param[data] - expecting table and got " .. type(d))
		assert(d.label or d.text, "[" .. self.name .. "] FAILURE: checkbox:setData() :: Missing param[data['text']]")
		assert(type(d.label) or type(d.text) == "string", "[" .. self.name .. "] FAILURE: checkbox:setData() :: Incorrect param[data['text']] - expecting string and got " .. type(d.label or d.text))
		assert(d.x, "[" .. self.name .. "] FAILURE: checkbox:setData() :: Missing param[data['x']]")
		assert(type(d.x) == "number", "[" .. self.name .. "] FAILURE: checkbox:setData() :: Incorrect param[data['x']] - expecting number and got " .. type(d.x))
		assert(d.y, "[" .. self.name .. "] FAILURE: checkbox:setData() :: Missing param[data['y']]")
		assert(type(d.y) == "number", "[" .. self.name .. "] FAILURE: checkbox:setData() :: Incorrect param[data['y']] - expecting number and got " .. type(d.y))
		self.uW = d.w or d.width or self.uW
		self.uH = d.h or d.height or self.uH
		self.label = d.label or d.text or self.label
		self.labelColor = d.labelColor or self.labelColor
		if d.labelPosition or d.labelPos then
			local i = d.labelPosition or d.labelPos
			if i.x then
				self.labelPosition = i
			else
				self.labelPosition.x, self.labelPosition.y, self.labelPosition.z = unpack(i)
			end
		end
		if d.padding then
			if d.padding.top or d.padding.paddingTop then
				self.paddingTop = d.padding.paddingTop or d.padding.top
				self.paddingRight = d.padding.paddingRight or d.padding.right or self.paddingRight
				self.paddingBottom = d.padding.paddingBottom or d.padding.bottom or self.paddingBottom
				self.paddingLeft = d.padding.paddingLeft or d.padding.left or self.paddingLeft
			else
				self.paddingTop, self.paddingRight, self.paddingBottom, self.paddingLeft = unpack(d.padding)
			end
		end
		self.pos.x = d.x or self.pos.x
		self.pos.y = d.y or self.pos.y
		self.pos.z = d.z or self.pos.z
		self.color = d.color or self.color
		self.border = d.useBorder and d.useBorder or self.border
		self.borderColor = d.borderColor or self.borderColor
		self.optionsColor = d.optionColor or self.optionsColor
		self.overlayColor = d.overlayColor or self.overlayColor
		self.font = d.font or self.font
		self.labelFont = d.labelFont or self.labelFont
		self.clickable = d.clickable and d.clickable or self.clickable
		self.round = d.round and d.round or self.round
		self.roundRadius = (d.roundRadius and d.roundRadius) or (d.radius and d.radius) or self.roundRadius
		self.single = (d.singleSelection and d.singleSelection) or (d.single and d.single) or self.single
		self.fixPadding = (d.fixPadding and d.fixPadding) or (d.fix and d.fix) or self.fixPadding
		if d.options then
			if not d.keepOptions then
				self.options = {}
			end
			local w, h = 0, 0
			for k,v in ipairs(d.options) do
				if k == 1 then
					self.options[k] = {
						text = v, 
						x = self.pos.x, 
						y = self.pos.y,
						w = self.paddingLeft + self.uW + self.font:getWidth(v) + self.paddingRight,
						h = self.paddingTop + self.uH + self.paddingBottom
					}
					if self.fixPadding then
						self.options[k].x = self.pos.x
					end
				else
					self.options[k] = {
						text = v, 
						x = self.options[k - 1].x + self.font:getWidth(self.options[k - 1].text) + 4 + (self.paddingLeft * 2) + self.uW + self.paddingRight, 
						y = self.paddingTop + self.pos.y + self.paddingBottom,
						w = self.paddingLeft + self.uW + self.font:getWidth(v) + self.paddingRight,
						h = self.paddingTop + self.uH + self.paddingBottom
					}
					if d.verticalOptions then
						self.vertical = true
						self.options[k].x = self.pos.x + self.paddingRight
						self.options[k].y = self.options[k - 1].y + self.font:getHeight(v)
					else
						self.options[k].y = self.pos.y
					end
				end
				w = (self.paddingLeft * 2) + w + (self.uW + self.font:getWidth(v)) + self.paddingRight
				h = self.paddingTop + h + (self.uH + self.font:getHeight(v)) + 2 + self.paddingBottom
				if self.border then
					w = w + 2
					h = h + 2
				end
			end
			if self.vertical then 
				if self.border then
					self.w = self.paddingLeft + self.uW + 2 + self.paddingRight
				else
					self.w = self.paddingLeft + self.uW + self.paddingRight
				end
				self.h = h
			else 
				self.w = w
				if self.border then
					self.h = self.paddingTop + self.uH + 2 + self.paddingBottom
				else
					self.h = self.paddingTop + self.uH + self.paddingBottom
				end
			end
		end
		
		if d.default then
			for k,v in ipairs(self.options) do 
				if v.text == d.default then
					self.selected[k] = v
				end 
			end 
		end
		return self
	end
	
	function c:disable()
		self.hidden = true
	end
	
	function c:draw()
		lg.push()
		lg.setColor(1,1,1,1)
		lg.setFont(self.font)
		for k,v in ipairs(self.options) do
			if v.text then
				lg.push()
				if self.border then
					if self.parent and checkbox.guis[self.parent].use255 then
						lg.setColor(love.math.colorFromBytes(self.borderColor))
					else
						lg.setColor(self.borderColor)
					end
					if self.round then
						lg.rectangle("line", v.x - 1, v.y - 1, v.w + 2, v.h + 2, self.roundRadius, self.roundRadius)
					else	
						lg.rectangle("line", v.x - 1, v.y - 1, v.w + 2, v.h + 2)
					end
				end
				if self.parent and checkbox.guis[self.parent].use255 then
					lg.setColor(love.math.colorFromBytes(self.color))
				else
					lg.setColor(self.color)
				end
				if self.round then
					lg.rectangle("fill", v.x, v.y, v.w, v.h, self.roundRadius, self.roundRadius)
				else
					lg.rectangle("fill", v.x, v.y, v.w, v.h)
				end
				
				if self.selected[k] then
					lg.setColor(self.overlayColor)
					if self.round then
						lg.rectangle("fill", v.x, v.y, v.w, v.h, self.roundRadius, self.roundRadius)
					else
						lg.rectangle("fill", v.x, v.y, v.w, v.h)
					end
					lg.setColor(self.color)
				end
				lg.setColor(self.optionsColor)
				if self.border then
					lg.printf(v.text, v.x + 1, (self.paddingTop / 2) + v.y + (self.paddingBottom / 2) - 2, v.w, "center")
				else
					lg.printf(v.text, v.x, (self.paddingTop / 2) + v.y + (self.paddingBottom / 2), v.w, "center")
				end
				lg.pop()
			end
		end
		lg.setColor(self.labelColor)
		lg.setFont(self.labelFont)
		lg.print(self.label, self.labelPosition.x, self.labelPosition.y)
		lg.pop()
	end
	
	function c:enable()
		self.hidden = false
	end
	
	function c:fadeIn()
		if self.events.beforeFadeIn then 
			for _,e in ipairs(self.events.beforeFadeIn) do
				e.fn(self, e.target)
			end
		end
		self.hidden = false
		self:animateToOpacity(1)
		if self.faded then
			self.animateColor = true
			self.animatePosition = true
			self.animateBorderColor = true
		end
		self.faded = false
		self.fadedByFunc = true
		if self.events.onFadeIn then
			for _,e in ipairs(self.events.onFadeIn) do
				e.fn(self, e.target)
			end
		end
	end
	
	function c:fadeOut(p, h)
		if self.events.beforeFadeOut then
			for _,e in ipairs(self.events.beforeFadeOut) do
				e.fn(self, e.target)
			end
		end
		self:animateToOpacity(0)
		if p then 
			self.faded = true
			if h then
				self.animateColor = false
				self.animatePosition = false
				self.animateBorderColor = false
			end
		end
		self.fadedByFunc = true
		if self.events.onFadeOut then
			for _,e in ipairs(self.events.onFadeOut) do
				e.fn(self, e.target)
			end
		end
	end
	
	function c:fixPadding(f)
		assert(f ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Missing param[hollow]")
		assert(type(f) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Incorrect param[hollow] - expecting boolean and got " .. type(f))
		self.fixPadding = f
	end
	
	function c:getFixPadding()
		return self.fixPadding
	end
	
	function c:setFont(f)
		assert(f, "[" .. self.name .. "] FAILURE: checkbox:setFont() :: Missing param[font]")
		assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: checkbox:setFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		self.font = f
	end
	
	function c:getFont()
		return self.font
	end
	
	function c:setHeight(h)
		assert(h, "[" .. self.name .. "] FAILURE: checkbox:setHeight() :: Missing param[height]")
		assert(type(h) == "number", "[" .. self.name .. "] FAILURE: checkbox:setHeight() :: Incorrect param[height] - expecting number and got " .. type(h))
		self.h = h
	end
	
	function c:getHeight(h)
		return self.h
	end
	
	function c:setHollow(h)
		assert(h ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Missing param[hollow]")
		assert(type(h) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Incorrect param[hollow] - expecting boolean and got " .. type(h))
		self.hollow = h
	end
	
	function c:isHollow()
		return self.hollow
	end
	
	function c:isHovered()
		return self.hovered
	end
	
	function c:setLabel(l)
		assert(l, "[" .. self.name .. "] FAILURE: checkbox:setLabel() :: Missing param[label]")
		assert(type(l) == "string", "[" .. self.name .. "] FAILURE: checkbox:setLabel() :: Incorrect param[label] - expecting string and got " .. type(l))
		self.label = l
	end
	
	function c:getLabel()
		return self.label
	end
	
	function c:setLabelColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:setLabelColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:setLabelColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: checkbox:setLabelColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.labelColor = t
	end
	
	function c:getLabelColor()
		return self.labelColor
	end
	
	function c:setLabelFont(f)
		assert(f, "[" .. self.name .. "] FAILURE: checkbox:setLabelFont() :: Missing param[font]")
		assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: checkbox:setLabelFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		self.labelFont = f
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
	end
	
	function c:getLabelPosition()
		return self.labelPosition
	end
	
	function c:mousepressed(event)
		local x, y, button = event.x, event.y, event.button
		if button == 1 then
			for k,v in ipairs(self.options) do
				if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
					if self.selected[k] then
						self.selected[k] = nil
					else
						if self.single then
							self.selected = {}
							self.selected[k] = v
							print(k)
						else
							self.selected[k] = v
						end
					end
					if self.events.onOptionClick then 
						for _,e in ipairs(self.events.onOptionClick) do
							e.fn(self, self.options[k], e.t, {x=x, y=y, button=button, istouch=istouch, presses=presses})
						end
					end
				end
			end
		end
	end

	function c:setOpacity(o)
		assert(o, "[" .. self.name .. "] FAILURE: checkbox:setUseBorder() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: checkbox:setUseBorder() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		self.color[4] = o
	end
	
	function c:getOpacity()
		return self.color[4]
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
	end
	
	function c:removeOption(o)
		assert(o, "[" .. self.name .. "] FAILURE: checkbox:addOption() :: Missing param[option]")
		assert(type(o) == "string", "[" .. self.name .. "] FAILURE: checkbox:addOption() :: Incorrect param[option] - expecting string and got " .. type(o))
		for k,v in ipairs(self.options) do
			if v.text == o then self.options[k] = nil end
		end
	end
	
	function c:setOptionColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.optionsColor = t
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
	end
	
	function c:setOptionPaddingBottom(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingBottom() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingBottom() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingBottom = p
	end
	
	function c:setOptionPaddingLeft(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingLeft() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingLeft() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingLeft = p
	end
	
	function c:setOptionPaddingRight(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingRight() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingRight() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingRight = p
	end
	
	function c:setOptionPaddingTop(p)
		assert(p, "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingTop() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: checkbox:setOptionPaddingTop() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingTop = p
	end
	
	function c:setOverlayColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: checkbox:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.overlayColor = t
	end
	
	function c:getOverlayColor()
		return self.overlayColor
	end
	
	function c:getParent()
		return checkbox.guis[self.parent]
	end
	
	function c:registerEvent(n, f, t, i)
		assert(n, "FAILURE: gui:registerEvent() :: Missing param[eventName]")
		assert(type(n) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
		assert(f, "FAILURE: gui:registerEvent() :: Missing param[functiom]")
		assert(type(f) == "function", "FAILURE: gui:registerEvent() :: Incorrect param[functiom] - expecting function and got " .. type(f))
		if not self.events[n] then self.events[n] = {} end
		local id = #self.events[n] + 1
		self.events[n][id] = {id = id, fn = f, target = t, name = i}
		return self
	end
	
	function c:removeEvent(n, i)
		assert(n, "FAILURE: gui:removeGlobalEvent() :: Missing param[eventName]")
		assert(type(n) == "string", "FAILURE: gui:removeGlobalEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
		assert(i, "FAILURE: gui:registerEvent() :: Missing param[name]")
		assert(type(i) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[name] - expecting string and got " .. type(i))
		for k,e in ipairs(self.events[n]) do
			if e.name == i then
				table.remove(events[n], k)
			end
		end
	end
	
	function c:touchmoved(id, x, y, dx, dy, pressure)
		if (x >= self.pos.x and x <= self.pos.x + self.uW) and (y >= self.pos.y and y <= self.pos.y + self.uH) then
			if not self.hovered then
				if self.onHoverEnter then self:onHoverEnter() end
				self.hovered = true 
			end
			if self.uWhileHovering then self:whileHovering() end
		else
			if self.hovered then 
				if self.onHoverExit then self:onHoverExit() end
				self.hovered = false 
			end
		end
	end
	
	function c:update(dt)
	
	end
	
	function c:setWidth(w)
		assert(w, "[" .. self.name .. "] FAILURE: checkbox:setWidth() :: Missing param[width]")
		assert(type(w) == "number", "[" .. self.name .. "] FAILURE: checkbox:setWidth() :: Incorrect param[width] - expecting number and got " .. type(w))
		self.w = w
	end
	
	function c:getWidth()
		return self.w
	end
	
	function c:setX(x)
		assert(x, "[" .. self.name .. "] FAILURE: checkbox:setX() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: checkbox:setX() :: Incorrect param[x] - expecting number and got " .. type(x))
		self.pos.x = x
	end
	
	function c:getX()
		return self.pos.x
	end
	
	function c:setY(y)
		assert(y, "[" .. self.name .. "] FAILURE: checkbox:setY() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: checkbox:setY() :: Incorrect param[y] - expecting number and got " .. type(y))
		self.pos.y = y
	end
	
	function c:getY()
		return self.pos.y
	end
	
	function c:setZ(z)
		assert(z, "[" .. self.name .. "] FAILURE: checkbox:setZ() :: Missing param[z]")
		assert(type(z) == "number", "[" .. self.name .. "] FAILURE: checkbox:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
		self.pos.z = z
	end
	
	function c:getZ()
		return self.pos.z
	end
	
	function c.lerp(e,s,c)
		return (1 - c) * e + c * s
	end
	
	return c
end

return checkbox