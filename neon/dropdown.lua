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
local dropdown = object()
dropdown.__index = dropdown

dropdown.items = {}
dropdown.guis = {}

function dropdown:new(n, p)
	local d = {}
	if not self.guis[p.id] then self.guis[p.id] = p end
	d.name = n
	d.id = #self.items + 1
	d.type = "dropdown"
	if p and p.id then d.parent = p.id else d.parent = nil end
	d.w = 0
	d.dW = 0
	d.uW = 0
	d.h = 0
	d.dH = 0
	d.uH = 0
	d.pos = {
		x = 0,
		y = 0,
		z = 0
	}
	d.x = d.pos.x
	d.y = d.pos.y
	d.z = d.pos.z
	d.label = ""
	d.labelColor = {1,1,1,1}
	d.labelPosition = {
		x = 0,
		y = 0,
		z = 0
	}
	d.border = false
	d.borderColor = {1,1,1,1}
	d.defaults = {}
	d.color = {1,1,1,1}
	d.overlayColor = {1,1,1,.5}
	d.optionsColor = {1,1,1,1}
	d.paddingLeft = 0
	d.paddingRight = 0
	d.paddingTop = 0
	d.paddingBottom = 0
	d.roundRadius = 0
	d.font = lg.getFont()
	d.optionFont = lg.getFont()
	d.hovered = false
	d.clicked = false
	d.clickable = true
	d.hollow = false
	d.open = false
	d.closeOnUnfocus = false
	d.faded = false
	d.fadedByFunc = false
	d.hidden = false
	d.vertical = false
	d.round = false
	d.hollow = false
	d.single = false
	d.fixPadding = false
	d.moveable = false
	d.held = false
	d.events = {}
	d.options = {}
	d.optionPaddingLeft = 0
	d.optionPaddingRight = 0
	d.optionPaddingTop = 0
	d.optionPaddingBottom = 0
	d.selected = 0
	d.font = lg.getFont()
	d.inAnimation = false
	d.animateColor = false
	d.colorToAnimateTo = {1,1,1,1}
	d.colorAnimateSpeed = 0
	d.colorAnimateTime = 0
	d.animatePosition = false
	d.positionAnimateSpeed = 0
	d.positionToAnimateTo = {x = 0, y = 0}
	d.positionToAnimateFrom = {x = 0, y = 0}
	d.bouncePositionAnimation = false
	d.positionAnimationPercent = 0
	d.positionAnimationPercentX = 0
	d.positionAnimationPercentY = 0
	d.positionAnimateTime = 0
	d.animateOpacity = false
	d.opacityAnimateSpeed = 0
	d.opacityToAnimateTo = 0
	d.opacityAnimateTime = 0
	d.animateBorderOpacity = true
	d.opacityToAnimateBorderTo = 0
	d.opacityBorderAnimateTime = 0
	d.opacityBorderAnimateSpeed = 0
	
	function d:animateToColor(t, s, f)
		assert(t, "[" .. self.name .. "] FAILURE: dropdown:animateToColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: dropdown:animateToColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: dropdown:animateToColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: dropdown:animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			self.colorToAnimateTo = t
			self.colorAnimateSpeed = s
			self.colorAnimateTime = 0
			self.inAnimation = true
			self.animateColor = true
		end
		return self
	end
	
	function d:animateBorderToColor(t, s, f)
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
	
	function d:animateToPosition(x, y, s, f)
		assert(x, "[" .. self.name .. "] FAILURE: dropdown:animateToPosition() :: Missing param[x]")
		assert(type(x) == "number" or type(x) == "string", "[" .. self.name .. "] FAILURE: dropdown:animateToPosition() :: Incorrect param[x] - expecting number or 'auto' and got " .. type(x))
		assert(y, "[" .. self.name .. "] FAILURE: dropdown:animateToPosition() :: Missing param[y]")
		assert(type(y) == "number" or type(x) == "string", "[" .. self.name .. "] FAILURE: dropdown:animateToPosition() :: Incorrect param[y] - expecting number or 'auto' and got " .. type(y))
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: dropdown:animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
		for k,v in pairs(self.pos) do self.positionToAnimateFrom[k] = v end
		if not self.fadedByFunc or f then
			if x == "auto" then
				x = self.pos.x
			end
			if y == "auto" then
				y = self.pos.y
			end
			self.positionToAnimateTo = {x = x, y = y}
			self.positionAnimateDrag = s
			self.positionAnimateTime = 0
			self.inAnimation = true
			self.animatePosition = true
		end
		return self
	end
	
	function d:animateToOpacity(o, s, f)
		assert(o, "[" .. self.name .. "] FAILURE: dropdown:animateToOpacity() :: Missing param[o]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: dropdown:animateToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
		s = s or 1
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: dropdown:animateToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			self.opacityToAnimateTo = o
			self.opacityAnimateTime = 0
			self.opacityAnimateSpeed = s
			self.inAnimation = true
			self.animateOpacity = true
		end
		return self
	end
	
	function d:animateBorderToOpacity(o, s, f)
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
	
	function d:isAnimating()
		return self.inAnimation
	end
	
	function d:startAnimation()
		self.inAnimation = true
		return self
	end
	
	function d:stopAnimation()
		self.inAnimation = false
		return self
	end
	
	function d:setBorderColor(bC)
		assert(bC, "[" .. self.name .. "] FAILURE: dropdown:setBorderColor() :: Missing param[color]")
		assert(type(bC) == "table", "[" .. self.name .. "] FAILURE: dropdown:setBorderColor() :: Incorrect param[color] - expecting table and got " .. type(bC))
		assert(#bC == 4, "[" .. self.name .. "] FAILURE: dropdown:setBorderColor() :: Incorrect param[color] - table length 4 expected and got " .. #bC)
		self.borderColor = bC
		return self
	end
	
	function d:getBorderColor()
		return self.borderColor
	end
	
	function d:setClickable(t)
		assert(t ~= nil, "[" .. self.name .. "] FAILURE: dropdown:setClickable() :: Missing param[clickable]")
		assert(type(t) == "boolean", "[" .. self.name .. "] FAILURE: dropdown:setClickable() :: Incorrect param[clickable] - expecting boolean and got " .. type(t))
		self.clickable = t
		return self
	end
	
	function d:isClickable()
		return self.clickable
	end
	
	function d:setColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: dropdown:setColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: dropdown:setColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: dropdown:setColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.color = t
		return self
	end
	
	function d:getColor()
		return self.color
	end
	
	function d:setData(t)
		assert(t, "[" .. self.name .. "] FAILURE: dropdown:setData() :: Missing param[data]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: dropdown:setData() :: Incorrect param[data] - expecting table and got " .. type(t))
		assert(t.label or t.text, "[" .. self.name .. "] FAILURE: dropdown:setData() :: Missing param[data['text']]")
		assert(type(t.label) or type(t.text) == "string", "[" .. self.name .. "] FAILURE: dropdown:setData() :: Incorrect param[data['text']] - expecting string and got " .. type(t.label or t.text))
		assert(t.x, "[" .. self.name .. "] FAILURE: dropdown:setData() :: Missing param[data['x']]")
		assert(type(t.x) == "number", "[" .. self.name .. "] FAILURE: dropdown:setData() :: Incorrect param[data['x']] - expecting number and got " .. type(t.x))
		assert(t.y, "[" .. self.name .. "] FAILURE: dropdown:setData() :: Missing param[data['y']]")
		assert(type(t.y) == "number", "[" .. self.name .. "] FAILURE: dropdown:setData() :: Incorrect param[data['y']] - expecting number and got " .. type(t.y))
		self.uW = t.w or t.width or self.uW
		self.uH = t.h or t.height or self.uH
		self.w, self.h = self.uW, self.uH
		self.label = t.label or t.text or self.label
		self.labelColor = t.labelColor or self.labelColor
		self.labelFont = t.labelFont or self.labelFont
		if t.labelPosition or t.labelPos then
			local i = t.labelPosition or t.labelPos
			if i.x then
				self.labelPosition = i
			else
				self.labelPosition.x, self.labelPosition.y, self.labelPosition.z = unpack(i)
			end
		end
		if t.padding then
			if t.padding.top or t.padding.paddingTop then
				self.paddingTop = t.padding.paddingTop or t.padding.top
				self.paddingRight = t.padding.paddingRight or t.padding.right or self.paddingRight
				self.paddingBottom = t.padding.paddingBottom or t.padding.bottom or self.paddingBottom
				self.paddingLeft = t.padding.paddingLeft or t.padding.left or self.paddingLeft
			else
				self.paddingTop, self.paddingRight, self.paddingBottom, self.paddingLeft = unpack(t.padding)
			end
		end
		if t.optionPadding then
			if t.optionPadding.top or t.optionPadding.optionPaddingTop then
				self.optionPaddingTop = t.optionPadding.optionPaddingTop or t.optionPadding.top
				self.optionPaddingRight = t.optionPadding.optionPaddingRight or t.optionPadding.right or self.optionPaddingRight
				self.optionPaddingBottom = t.optionPadding.optionPaddingBottom or t.optionPadding.bottom or self.optionPaddingBottom
				self.optionPaddingLeft = t.optionPadding.optionPaddingLeft or t.optionPadding.left or self.optionPaddingLeft
			else
				self.optionPaddingTop, self.optionPaddingRight, self.optionPaddingBottom, self.optionPaddingLeft = unpack(t.optionPadding)
			end
		end
		self.fixPadding = (t.fixPadding and t.fixPadding) or (t.fix and t.fix) or self.fixPadding
		self.pos.x = t.x or self.pos.x
		self.pos.y = t.y or self.pos.y
		self.pos.z = t.z or self.pos.z
		if t.useBorder ~= nil then self.border = t.useBorder end
		if t.clickable ~= nil then self.clickable = t.clickable end
		if t.moveable ~= nil then self.moveable = t.moveable end
		if t.hollow ~= nil then self.hollow = t.hollow end
		if t.round ~= nil then self.round = t.round end
		if t.closeOnUnfocus ~= nil then self.closeOnUnfocus = t.closeOnUnfocus end
		if t.color then
			for k,v in ipairs(t.color) do
				self.color[k] = v
			end
		end
		if t.borderColor then
			for k,v in ipairs(t.borderColor) do
				self.borderColor[k] = v
			end
		end
		if t.optionsColor then
			for k,v in ipairs(t.optionsColor) do
				self.optionsColor[k] = v
			end
		end
		self.font = t.font or self.font
		self.optionFont = t.optionFont or self.optionFont
		self.roundRadius = (t.roundRadius and t.roundRadius) or (t.radius and t.radius) or self.roundRadius
		if t.options then
			if not t.keepOptions then
				self.options = {}
			end
			local w, h = self.uW, 0
			for k,v in ipairs(t.options) do
				if k == 1 then
					self.options[k] = {
						text = v, 
						x = self.optionPaddingLeft + self.pos.x, 
						y = self.optionPaddingTop + self.pos.y + self.uH + self.optionPaddingBottom,
						w = self.optionPaddingLeft + self.optionFont:getWidth(v) + self.optionPaddingRight,
						h = self.optionPaddingTop + self.uH + self.optionFont:getHeight(v) + self.optionPaddingBottom
					}
					if self.fixPadding then
						self.options[k].y = self.pos.y + self.uH + self.optionPaddingBottom
					end
					if self.border then self.options[k].y = self.options[k].y + 7 end
				else
					self.options[k] = {
						text = v, 
						x = self.optionPaddingLeft + self.pos.x,
						y = self.options[k - 1].y + self.options[k - 1].h,
						w = self.optionPaddingLeft + self.optionFont:getWidth(v) + self.optionPaddingRight,
						h = self.optionPaddingTop + self.uH + self.optionFont:getHeight(v) + self.optionPaddingBottom
					}
				end
				if self.border then 
					self.options[k].x = self.options[k].x - 5	
				end
				h = h + self.options[k].h
				w = max(w, self.options[k].w)
			end
			for k,v in ipairs(self.options) do v.w = w end
			self.dW = w
			self.dH = h
		end
		if t.default then
			for k,v in ipairs(self.options) do 
				if v.text == t.default then
					self.selected = k 
				end 
			end 
		end
		self.defaults = t
		return self
	end
	
	function d:disable()
		self.hidden = true
		return self
	end
	
	function d:draw()
		lg.push()
		lg.setColor(self.color)
		lg.setFont(self.font)
		
		lg.rectangle("fill", self.pos.x, self.pos.y, self.uW, self.uH)
		if self.open then
			lg.setColor(0,0,0,.2)
			lg.rectangle("fill", self.pos.x, self.pos.y, self.uW, self.uH)
			lg.setColor(self.color)
		end
		if self.border then
			lg.setColor(self.borderColor)
			lg.rectangle("line", self.pos.x - 1, self.pos.y - 1, self.uW + 2, self.uH + 2)
		end
		lg.setColor(self.optionsColor)
		lg.setFont(self.optionFont)
		if self.selected then lg.print(self.options[self.selected].text, self.pos.x + self.paddingLeft, self.pos.y + self.paddingTop) end
		if self.open then
			if self.border then
				if self.fixPadding then
					lg.setColor(self.borderColor)
					lg.rectangle("line", self.pos.x, self.pos.y + self.uH + 2, self.optionPaddingLeft + self.dW + self.optionPaddingRight + 2, self.dH + 2)
					lg.setColor(self.color)
					lg.rectangle("fill", self.pos.x + 1, self.pos.y + self.uH + 3, self.optionPaddingLeft + self.dW + self.optionPaddingRight, self.dH)
				else
					lg.setColor(self.borderColor)
					lg.rectangle("line", self.pos.x, self.pos.y + self.uH + 2, self.optionPaddingLeft + self.dW + self.optionPaddingRight + 2, self.optionPaddingTop + self.dH + self.paddingBottom + 2)
					lg.setColor(self.color)
					lg.rectangle("fill", self.pos.x + 1, self.pos.y + self.uH + 3, self.optionPaddingLeft + self.dW + self.optionPaddingRight, self.optionPaddingTop + self.dH + self.paddingBottom)
				end
			else
				lg.setColor(self.color)
				if self.fixPadding then
					lg.rectangle("fill", self.pos.x, self.pos.y + self.uH, self.optionPaddingLeft + self.dW + self.optionPaddingRight, self.dH)
				else
					lg.rectangle("fill", self.pos.x, self.pos.y + self.uH, self.optionPaddingLeft + self.dW + self.optionPaddingRight, self.optionPaddingTop + self.dH + self.paddingBottom)
				end
			end
			for k,v in ipairs(self.options) do
				if v.hovered then
					lg.setColor(0,0,0,.2)
					if self.border then
						lg.rectangle("fill",v.x - (self.optionPaddingLeft / 2) + 1,v.y - self.optionPaddingTop - self.optionPaddingBottom,v.w + self.optionPaddingLeft + self.optionPaddingRight,v.h)
					else
						lg.rectangle("fill",v.x - self.optionPaddingLeft / 2,v.y,v.w + self.optionPaddingLeft + self.optionPaddingRight,v.h)
					end
				end
				lg.setColor(self.optionsColor)
				lg.setFont(self.optionFont)
				lg.print(v.text, v.x, v.y + self.optionPaddingTop)
				if k ~= #self.options then
					lg.setColor(0,0,0,.2)
					lg.line(v.x - self.optionPaddingLeft / 2, v.y + ((v.h - self.optionPaddingTop) - self.optionPaddingBottom), v.x + v.w + self.optionPaddingLeft, v.y + ((v.h - self.optionPaddingTop) - self.optionPaddingBottom))
				end
			end
		end
		
		lg.setColor(self.labelColor)
		lg.setFont(self.labelFont)
		lg.print(self.label, self.labelPosition.x, self.labelPosition.y)
		lg.pop()
	end
	
	function d:enable()
		self.hidden = false
		return self
	end
	
	function d:fadeIn()
		if self.events.beforeFadeIn then 
			for _,r in ipairs(self.events.beforeFadeIn) do
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
			for _,r in ipairs(self.events.onFadeIn) do
				e.fn(self, e.target)
			end
		end
		return self
	end
	
	function d:fadeOut(p, h)
		if self.events.beforeFadeOut then
			for _,r in ipairs(self.events.beforeFadeOut) do
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
			for _,r in ipairs(self.events.onFadeOut) do
				e.fn(self, e.target)
			end
		end
		return self
	end
	
	function d:setFont(f)
		assert(f, "[" .. self.name .. "] FAILURE: dropdown:setFont() :: Missing param[font]")
		assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: dropdown:setFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		self.font = f
		return self
	end
	
	function d:getFont()
		return self.font
	end
	
	function d:setHeight(h)
		assert(h, "[" .. self.name .. "] FAILURE: dropdown:setHeight() :: Missing param[height]")
		assert(type(h) == "number", "[" .. self.name .. "] FAILURE: dropdown:setHeight() :: Incorrect param[height] - expecting number and got " .. type(h))
		self.h = h
		return self
	end
	
	function d:getHeight(h)
		return self.h
	end
	
	function d:setHollow(h)
		assert(h ~= nil, "[" .. self.name .. "] FAILURE: dropdown:setHollow() :: Missing param[hollow]")
		assert(type(h) == "boolean", "[" .. self.name .. "] FAILURE: dropdown:setHollow() :: Incorrect param[hollow] - expecting boolean and got " .. type(h))
		self.hollow = h
		return self
	end
	
	function d:isHollow()
		return self.hollow
	end
	
	function d:isHovered()
		return self.hovered
	end
	
	function d:mousepressed(event)
		local x, y, button = event.x, event.y, event.button
		if button == 1 then
			if self.hovered then 
				if self.open then
					local hitTarget = false
					for k,v in ipairs(self.options) do
						if v.hovered then
							self.selected = k
							hitTarget = true
							if self.events.onOptionClick then 
								for _,e in ipairs(self.events.onOptionClick) do
									e.fn(self, self.options[k], e.t, event)
								end
							end
						end
					end
					if not hitTarget then
						self.open = false
					end
				else
					self.open = true
				end
			else
				self.open = false
			end
		end
	end
	
	function d:setOpacity(o)
		assert(o, "[" .. self.name .. "] FAILURE: dropdown:setUseBorder() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: dropdown:setUseBorder() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		self.color[4] = o
		return self
	end
	
	function d:getOpacity()
		return self.color[4]
	end
	
	function d:addOption(o)
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
	
	function d:removeOption(o)
		assert(o, "[" .. self.name .. "] FAILURE: dropdown:addOption() :: Missing param[option]")
		assert(type(o) == "string", "[" .. self.name .. "] FAILURE: dropdown:addOption() :: Incorrect param[option] - expecting string and got " .. type(o))
		for k,v in ipairs(self.options) do
			if v.text == o then self.options[k] = nil end
		end
		return self
	end
	
	function d:setOptionColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.optionsColor = t
		return self
	end
	
	function d:getOptionColor()
		return self.optionsColor
	end
	
	function d:setOptionPadding(p)
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
	
	function d:setOptionPaddingBottom(p)
		assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingBottom() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingBottom() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingBottom = p
		return self
	end
	
	function d:setOptionPaddingLeft(p)
		assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingLeft() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingLeft() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingLeft = p
		return self
	end
	
	function d:setOptionPaddingRight(p)
		assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingRight() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingRight() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingRight = p
		return self
	end
	
	function d:setOptionPaddingTop(p)
		assert(p, "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingTop() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: dropdown:setOptionPaddingTop() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.OptionaddingTop = p
		return self
	end
	
	function d:setOverlayColor(t)
		assert(t, "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Missing param[color]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Incorrect param[color] - expecting table and got " .. type(t))
		assert(#t == 4, "[" .. self.name .. "] FAILURE: dropdown:setOverlayColor() :: Incorrect param[color] - table length 4 expected and got " .. #t)
		self.overlayColor = t
		return self
	end
	
	function d:getOverlayColor()
		return self.overlayColor
	end
	
	function d:getParent()
		return dropdown.guis[self.parent]
	end
	
	function d:registerEvent(n, f, t, i)
		assert(n, "FAILURE: gui:registerEvent() :: Missing param[eventName]")
		assert(type(n) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
		assert(f, "FAILURE: gui:registerEvent() :: Missing param[functiom]")
		assert(type(f) == "function", "FAILURE: gui:registerEvent() :: Incorrect param[functiom] - expecting function and got " .. type(f))
		if not self.events[n] then self.events[n] = {} end
		local id = #self.events[n] + 1
		self.events[n][id] = {id = id, fn = f, target = t, name = i}
		return self
	end
	
	function d:removeEvent(n, i)
		assert(n, "FAILURE: gui:removeGlobalEvent() :: Missing param[eventName]")
		assert(type(n) == "string", "FAILURE: gui:removeGlobalEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
		assert(i, "FAILURE: gui:registerEvent() :: Missing param[name]")
		assert(type(i) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[name] - expecting string and got " .. type(i))
		for k,e in ipairs(self.events[n]) do
			if e.name == i then
				table.remove(events[n], k)
			end
		end
		return self
	end
	
	function d:touchmoved(id, x, y, dx, dy, pressure)
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
	
	function d:update(dt)
		if self.open then
			local x,y = love.mouse.getPosition()
			for k,v in ipairs(self.options) do
				if x >= v.x - self.optionPaddingLeft / 2 and x <= v.x + v.w + self.optionPaddingLeft and y >= v.y - self.optionPaddingTop - self.optionPaddingBottom and y <= v.y + v.h - self.optionPaddingTop - self.optionPaddingBottom then
					if not v.hovered then v.hovered = true end
				else
					if v.hovered then v.hovered = false end
				end
			end
		end
	end
	
	function d:setWidth(w)
		assert(w, "[" .. self.name .. "] FAILURE: dropdown:setWidth() :: Missing param[width]")
		assert(type(w) == "number", "[" .. self.name .. "] FAILURE: dropdown:setWidth() :: Incorrect param[width] - expecting number and got " .. type(w))
		self.w = w
		return self
	end
	
	function d:getWidth()
		return self.w
	end
	
	function d:setX(x)
		assert(x, "[" .. self.name .. "] FAILURE: dropdown:setX() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: dropdown:setX() :: Incorrect param[x] - expecting number and got " .. type(x))
		self.pos.x = x
		return self
	end
	
	function d:getX()
		return self.pos.x
	end
	
	function d:setY(y)
		assert(y, "[" .. self.name .. "] FAILURE: dropdown:setY() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: dropdown:setY() :: Incorrect param[y] - expecting number and got " .. type(y))
		self.pos.y = y
		return self
	end
	
	function d:getY()
		return self.pos.y
	end
	
	function d:setZ(z)
		assert(z, "[" .. self.name .. "] FAILURE: dropdown:setZ() :: Missing param[z]")
		assert(type(z) == "number", "[" .. self.name .. "] FAILURE: dropdown:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
		self.pos.z = z
		return self
	end
	
	function d:getZ()
		return self.pos.z
	end
	
	function d.lerp(e,s,c)
		return (1 - c) * e + c * s
	end
	
	setmetatable(d, dropdown)
	return d
end

return dropdown