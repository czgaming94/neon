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
local textfield = {}

textfield.items = {}
textfield.guis = {}
textfield.fonts = {}

function textfield:new(n, p)
	local t = {}
	if p and p.id and not self.guis[p.id] then self.guis[p.id] = p end
	t.name = n
	t.id = #self.items + 1
	t.type = "textfield"
	if p and p.id then t.parent = p.id else t.parent = nil end
	t.textfield = ""
	t.w = 0
	t.h = 0
	t.pos = {
		x = 0,
		y = 0,
		z = 0
	}
	t.x = t.pos.x
	t.y = t.pos.y
	t.z = t.pos.z
	t.keys = {
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
		"1","2","3","4","5","6","7","8","9","0",",",".","/",";","'","[","]","`","-","=","\"","\\",
		"!","@","#","$","%","^","&","*","(",")","{","}",":","<",">","?","~","backspace","return","enter"
	}
	t.timerEvent = nil
	t.color = {1,1,1,1}
	t.textColor = {1,1,1,1}
	t.placeholder = ""
	t.display = {""}
	t.currentLine = 1
	t.showCursor = true
	t.cursorTime = 0
	t.font = love.graphics.getFont()
	t.fonts = {}
	t.hovered = false
	t.clicked = false
	t.hidden = false
	t.hollow = false
	t.clickable = true
	t.active = false
	t.faded = false
	t.fadedByFunc = false
	t.moveable = false
	t.held = false
	t.events = {}
	t.paddingLeft = 0
	t.paddingRight = 0
	t.paddingTop = 0
	t.paddingBottom = 0
	t.inAnimation = false
	t.animateColor = false
	t.colorToAnimateTo = {1,1,1,1}
	t.colorAnimateSpeed = 0
	t.colorAnimateTime = lt.getTime()
	t.animatePosition = false
	t.positionAnimateSpeed = 0
	t.positionToAnimateTo = {x = 0, y = 0}
	t.positionToAnimateFrom = {x = 0, y = 0}
	t.positionAnimateTime = lt.getTime()
	t.animateOpacity = false
	t.opacityAnimateSpeed = 0
	t.opacityToAnimateTo = 0
	t.opacityAnimateTime = lt.getTime()
	
	function t:animateToColor(c, s)
		assert(c, "[" .. self.name .. "] FAILURE: textfield:animateToColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: textfield:animateToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c == 4, "[" .. self.name .. "] FAILURE: textfield:animateToColor() :: Incorrect param[color] - table length 4 expected and got " .. #c)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: textfield:animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.colorToAnimateTo = c
		self.colorAnimateSpeed = s
		self.colorAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animateColor = true
	end
	
	function t:animateToPosition(x, y, s)
		assert(x, "[" .. self.name .. "] FAILURE: textfield:animateToPosition() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: textfield:animateToPosition() :: Incorrect param[x] - expecting number and got " .. type(x))
		assert(y, "[" .. self.name .. "] FAILURE: textfield:animateToPosition() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: textfield:animateToPosition() :: Incorrect param[y] - expecting number and got " .. type(y))
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: textfield:animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
		for k,v in pairs(self.pos) do self.positionToAnimateFrom[k] = v end
		self.positionToAnimateTo = {x = x, y = y}
		self.positionAnimateDrag = s
		self.positionAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animatePosition = true
	end
	
	function t:animateToOpacity(o, s)
		assert(o, "[" .. self.name .. "] FAILURE: textfield:animateToOpacity() :: Missing param[o]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: textfield:animateToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
		s = s or 1
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: textfield:animateToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.opacityToAnimateTo = o
		self.opacityAnimateTime = lt.getTime()
		self.opacityAnimateSpeed = s
		self.inAnimation = true
		self.animateOpacity = true
	end
	
	function t:isAnimating()
		return self.inAnimation
	end
	
	function t:setClickable(c)
		assert(c ~= nil, "[" .. self.name .. "] FAILURE: textfield:setClickable() :: Missing param[clickable]")
		assert(type(c) == "boolean", "[" .. self.name .. "] FAILURE: textfield:setClickable() :: Incorrect param[clickable] - expecting boolean and got " .. type(c))
		self.clickable = c
	end
	
	function t:isClickable()
		return self.clickable
	end
	
	function t:setColor(c)
		assert(c, "[" .. self.name .. "] FAILURE: textfield:setColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: textfield:setColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c == 4, "[" .. self.name .. "] FAILURE: textfield:setColor() :: Incorrect param[color] - table length 4 expected and got " .. #c)
		self.color = c
	end
	
	function t:getColor()
		return self.color
	end
	
	function t:setData(d)
		assert(d, "[" .. self.name .. "] FAILURE: textfield:setData() :: Missing param[data]")
		assert(type(d) == "table", "[" .. self.name .. "] FAILURE: textfield:setData() :: Incorrect param[data] - expecting table and got " .. type(d))
		assert(d.x, "[" .. self.name .. "] FAILURE: textfield:setData() :: Missing param[data['x']")
		assert(type(d.x) == "number", "[" .. self.name .. "] FAILURE: textfield:setData() :: Incorrect param[x] - expecting number and got " .. type(d.x))
		assert(d.y, "[" .. self.name .. "] FAILURE: textfield:setData() :: Missing param[data['y']")
		assert(type(d.y) == "number", "[" .. self.name .. "] FAILURE: textfield:setData() :: Incorrect param[y] - expecting number and got " .. type(d.y))
		assert(d.w or d.width, "[" .. self.name .. "] FAILURE: textfield:setData() :: Missing param[width]")
		assert(type(d.w) == "number" or type(d.width) == "number", "[" .. self.name .. "] FAILURE: textfield:setData() :: Incorrect param[width] - expecting number and got " .. type(d.w or d.width))
		assert(d.h or d.height, "[" .. self.name .. "] FAILURE: textfield:setData() :: Missing param[height]")
		assert(type(d.x) == "number" or type(d.height) == "number", "[" .. self.name .. "] FAILURE: textfield:setData() :: Incorrect param[height] - expecting number and got " .. type(d.h or d.height))
		self.placeholder = d.placeholder or d.t or d.text or self.placeholder
		self.pos.x = d.x or self.pos.x
		self.pos.y = d.y or self.pos.y
		self.pos.z = d.z or self.pos.z
		self.color = d.color or self.color
		self.textColor = d.textColor or self.textColor
		self.font = d.font or self.font
		self.w = d.w or d.width or self.font:getWidth(self.textfield)
		self.h = d.h or d.height or self.font:getHeight(self.textfield)
		self.font = d.font or self.font
		self.clickable = d.clickable and d.clickable or self.clickable
		self.moveable = d.moveable and d.moveable or self.moveable
		self.hollow = d.hollow and d.hollow or self.hollow
		return self
	end
	
	function t:disable()
		self.hidden = true
		return self
	end
	
	function t:draw()
		lg.push()		
		lg.setFont(self.font)
		lg.setColor(self.color)
		lg.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
		if self.border then
			lg.setColor(self.borderColor)
			lg.rectangle("fill", self.pos.x - 1, self.pos.y - 1, self.w + 2, self.h + 2)
		end
		lg.setColor(self.textColor)
		for k,v in ipairs(self.display) do
			if k == 1 then
				lg.print(v, self.pos.x + 5 + self.paddingLeft, self.pos.y + 5 + self.paddingTop)
			else
				lg.print(v, self.pos.x + 5 + self.paddingLeft, self.pos.y + (5 + (self.font:getHeight() * (k - 1))))
			end
		end
		if self.active and self.showCursor then
			lg.setColor(.05,.05,.05,1)
			lg.line(self.pos.x + self.font:getWidth(self.display[self.currentLine]) + 7,self.pos.y + (self.font:getHeight() * (self.currentLine - 1)) + 5, self.pos.x + self.font:getWidth(self.display[self.currentLine]) + 7, self.pos.y + (self.font:getHeight() * self.currentLine) + 5)
		end
		
		lg.setColor(1,1,1,1)
		lg.pop()
	end
	
	function t:enable()
		self.hidden = false
	end
	
	function t:fadeIn()
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
	
	function t:fadeOut(p, h)
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
	
	function t:addFont(f, n)
		assert(f, "[" .. self.name .. "] FAILURE: textfield:addFont() :: Missing param[font]")
		assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: textfield:addFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		assert(n, "[" .. self.name .. "] FAILURE: textfield:addFont() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: textfield:addFont() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.fonts[n] = f
	end
	
	function t:setFont(n)
		assert(n, "[" .. self.name .. "] FAILURE: textfield:setFont() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: textfield:setFont() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.font = self.fonts[n]
	end
	
	function t:setHollow(h)
		assert(h ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Missing param[hollow]")
		assert(type(h) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Incorrect param[hollow] - expecting boolean and got " .. type(h))
		self.hollow = h
	end
	
	function t:isHollow()
		return self.hollow
	end
	
	function t:isHovered()
		return self.hovered
	end
	
	function t:keypressed(event)
		if self.active then
			local allowKey = false
			for _,v in ipairs(self.keys) do
				if v == event.key then allowKey = true end
			end
			if allowKey then
				if event.key == "backspace" then
					if self.currentLine == 1 then
						if self.display[self.currentLine] ~= "" then
							self.display[self.currentLine] = self.display[self.currentLine]:sub(1,-2)
						end
					else
						if self.display[self.currentLine] == "" then
							self.currentLine = self.currentLine - 1
						end
						self.display[self.currentLine] = self.display[self.currentLine]:sub(1,-2)
					end
				elseif event.key == "return" or event.key == "enter" then
					self.currentLine = self.currentLine + 1
					if not self.display[self.currentLine] then self.display[self.currentLine] = "" end
				else
					if self.font:getWidth(self.display[self.currentLine]) > (self.w - (self.paddingLeft + 7)) - (self.paddingRight + 7) then
						self.currentLine = self.currentLine + 1
						if not self.display[self.currentLine] then self.display[self.currentLine] = "" end
						self.display[self.currentLine] = self.display[self.currentLine] .. event.key
					else
						self.display[self.currentLine] = self.display[self.currentLine] .. event.key
					end
				end
			end
		end
	end
	
	function t:mousepressed(event)
		local x, y, button = event.x, event.y, event.button
		if button == 1 then
			if self.hovered then 
				if not self.active then
					self.active = true
				end
			end
		end
	end
	
	function t:startAnimation()
		self.inAnimation = true
	end
	
	function t:stopAnimation()
		self.inAnimation = false
	end
	
	function t:update(dt)		
		if self.active then
			self.cursorTime = self.cursorTime + dt
			if self.cursorTime >= 1 then
				self.cursorTime = self.cursorTime - 1
				self.showCursor = not self.showCursor
			end
		end
	end
	
	function t:setOpacity(o)
		assert(o, "[" .. self.name .. "] FAILURE: textfield:setUseBorder() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: textfield:setUseBorder() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		self.color[4] = o
	end
	
	function t:getOpacity()
		return self.color[4]
	end
	
	function t:getParent()
		return textfield.guis[self.parent]
	end
	
	function t:registerEvent(n, f, t, i)
		assert(n, "FAILURE: gui:registerEvent() :: Missing param[eventName]")
		assert(type(n) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
		assert(f, "FAILURE: gui:registerEvent() :: Missing param[functiom]")
		assert(type(f) == "function", "FAILURE: gui:registerEvent() :: Incorrect param[functiom] - expecting function and got " .. type(f))
		if not self.events[n] then self.events[n] = {} end
		local id = #self.events[n] + 1
		self.events[n][id] = {id = id, fn = f, target = t, name = i}
		return self
	end
	
	function t:removeEvent(n, i)
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
	
	function t:touchmoved(id, x, y, dx, dy, pressure)
		if (x >= self.pos.x + self.paddingLeft and x <= self.pos.x + self.w + self.paddingRight) and 
		(y >= self.pos.y + self.paddingTop and y <= self.pos.y + self.h + self.paddingBottom) then
			if not self.hovered then
				if self.onHoverEnter then self:onHoverEnter() end
				self.hovered = true 
			end
			if self.whileHovering then self:whileHovering() end
		else
			if self.hovered then 
				if self.onHoverExit then self:onHoverExit() end
				self.hovered = false 
			end
		end
	end

	function t:setText(txt)
		assert(txt ~= nil, "[" .. self.name .. "] FAILURE: textfield:setText() :: Missing param[text]")
		assert(type(txt) == "string", "[" .. self.name .. "] FAILURE: textfield:setText() :: Incorrect param[text] - expecting string and got " .. type(txt))
		self.text = txt
	end
	
	function t:getText()
		return self.textfield
	end
	
	function t:setX(x)
		assert(x, "[" .. self.name .. "] FAILURE: textfield:setX() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: textfield:setX() :: Incorrect param[x] - expecting number and got " .. type(x))
		self.pos.x = x
	end
	
	function t:getX()
		return self.pos.x
	end
	
	function t:setY(y)
		assert(y, "[" .. self.name .. "] FAILURE: textfield:setY() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: textfield:setY() :: Incorrect param[y] - expecting number and got " .. type(y))
		self.pos.y = y
	end
	
	function t:getY()
		return self.pos.y
	end
	
	function t:setZ(z)
		assert(z, "[" .. self.name .. "] FAILURE: textfield:setZ() :: Missing param[z]")
		assert(type(z) == "number", "[" .. self.name .. "] FAILURE: textfield:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
		self.pos.z = z
	end
	
	function t:getZ()
		return self.pos.z
	end
	
	function t.lerp(e,s,c)
		return (1 - c) * e + c * s
	end
	
	return t
end

return textfield