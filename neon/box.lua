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
local box = {}

box.items = {}
box.guis = {}

function box:new(n, p)
	local b = {}
	if not self.guis[p.id] then self.guis[p.id] = p end
	b.name = n
	b.id = #self.items + 1
	b.type = "box"
	if p and p.id then b.parent = p.id else b.parent = nil end
	b.w = 0
	b.h = 0
	b.pos = {
		x = 0,
		y = 0,
		z = 0
	}
	b.x = b.pos.x
	b.y = b.pos.y
	b.z = b.pos.z
	b.border = false
	b.borderColor = {1,1,1,1}
	b.color = {1,1,1,1}
	b.hovered = false
	b.clicked = false
	b.clickable = true
	b.held = false
	b.moveable = false
	b.hollow = false
	b.faded = false
	b.fadedByFunc = false
	b.hidden = false
	b.events = {}
	b.images = {}
	b.image = nil
	b.paddingLeft = 0
	b.paddingRight = 0
	b.paddingTop = 0
	b.paddingBottom = 0
	b.inAnimation = false
	b.animateColor = false
	b.colorToAnimateTo = {1,1,1,1}
	b.colorAnimateSpeed = 0
	b.colorAnimateTime = lt.getTime()
	b.animateBorderColor = false
	b.borderColorToAnimateTo = {1,1,1,1}
	b.borderColorAnimateSpeed = 0
	b.borderColorAnimateTime = lt.getTime()
	b.animatePosition = false
	b.positionAnimateSpeed = 0
	b.positionToAnimateTo = {x = 0, y = 0}
	b.positionToAnimateFrom = {x = 0, y = 0}
	b.positionAnimateTime = lt.getTime()
	b.animateOpacity = false
	b.opacityAnimateSpeed = 0
	b.opacityToAnimateTo = 0
	b.opacityAnimateTime = lt.getTime()
	
	function b:addImage(i, n, a)
		assert(i, "[" .. self.name .. "] FAILURE: box:addImage() :: Missing param[img]")
		assert(type(i) == "userdata", "[" .. self.name .. "] FAILURE: box:addImage() :: Incorrect param[img] - expecting image userdata and got " .. type(i))
		assert(n, "[" .. self.name .. "] FAILURE box:addImage() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: box:addImage() :: Incorrect param[img] - expecting string and got " .. type(n))
		self.images[n] = i
		if a and a == true then self:setImage(n) end
	end
	
	function b:animateToColor(c, s)
		assert(c, "[" .. self.name .. "] FAILURE: box:animateToColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: box:animateToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c > 2, "[" .. self.name .. "] FAILURE: box:animateToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc then
			self.colorToAnimateTo = c
			self.colorAnimateSpeed = s
			self.colorAnimateTime = lt.getTime()
			self.inAnimation = true
			self.animateColor = true
		end
	end
	
	function b:animateBorderToColor(c, s)
		assert(c, "[" .. self.name .. "] FAILURE: box:animateBorderToColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: box:animateBorderToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c > 2, "[" .. self.name .. "] FAILURE: box:animateBorderToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc then
			self.borderColorToAnimateTo = c
			self.borderColorAnimateSpeed = s
			self.borderColorAnimateTime = lt.getTime()
			self.inAnimation = true
			self.animateBorderColor = true
		end
	end
	
	function b:animateToPosition(x, y, s)
		assert(x, "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Incorrect param[x] - expecting number and got " .. type(x))
		assert(y, "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Incorrect param[y] - expecting number and got " .. type(y))
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
		for k,v in pairs(self.pos) do self.positionToAnimateFrom[k] = v end
		if not self.fadedByFunc then
			self.positionToAnimateTo = {x = x, y = y}
			self.positionAnimateSpeed = s
			self.positionAnimateTime = lt.getTime()
			self.inAnimation = true
			self.animatePosition = true
		end
	end
	
	function b:animateToOpacity(o, s)
		assert(o, "[" .. self.name .. "] FAILURE: box:animateToOpacity() :: Missing param[o]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: box:animateToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
		s = s or 1
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc then
			self.opacityToAnimateTo = o
			self.opacityAnimateTime = lt.getTime()
			self.opacityAnimateSpeed = s
			self.inAnimation = true
			self.animateOpacity = true
		end
	end
	
	function b:isAnimating()
		return self.inAnimation
	end
	
	function b:setBorderColor(bC)
		assert(bC, "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Missing param[color]")
		assert(type(bC) == "table", "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Incorrect param[color] - expecting table and got " .. type(bC))
		assert(#bC == 4, "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Incorrect param[color] - table length 4 expected and got " .. #bC)
		self.borderColor = bC
	end
	
	function b:getBorderColor()
		return self.borderColor
	end
	
	function b:setClickable(c)
		assert(c ~= nil, "[" .. self.name .. "] FAILURE: box:setClickable() :: Missing param[clickable]")
		assert(type(c) == "boolean", "[" .. self.name .. "] FAILURE: box:setClickable() :: Incorrect param[clickable] - expecting boolean and got " .. type(c))
		self.clickable = c
	end
	
	function b:isClickable()
		return self.clickable
	end
	
	function b:setColor(c)
		assert(c, "[" .. self.name .. "] FAILURE: box:setColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: box:setColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c > 2, "[" .. self.name .. "] FAILURE: box:setColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
		self.color = c
	end
	
	function b:getColor()
		return self.color
	end
	
	function b:setData(t)
		assert(t, "[" .. self.name .. "] FAILURE: box:setData() :: Missing param[data]")
		assert(type(t) == "table", "[" .. self.name .. "] FAILURE: box:setData() :: Incorrect param[data] - expecting table and got " .. type(t))
		assert(t.w or t.width, "[" .. self.name .. "] FAILURE: box:setData() :: Missing param[data['width']")
		assert(type(t.w) == "number" or type(t.width) == "number", "[" .. self.name .. "] FAILURE: box:setData() :: Incorrect param[data['width']] - expecting number and got " .. (type(t.w) or type(t.width)))
		assert(t.h or t.height, "[" .. self.name .. "] FAILURE: box:setData() :: Missing param[data['height']")
		assert(type(t.h) == "number" or type(t.height) == "number", "[" .. self.name .. "] FAILURE: box:setData() :: Incorrect param[data['height']] - expecting number and got " .. (type(t.h) or type(t.height)))
		assert(t.x, "[" .. self.name .. "] FAILURE: box:setData() :: Missing param[data['x']")
		assert(type(t.x) == "number", "[" .. self.name .. "] FAILURE: box:setData() :: Incorrect param[x] - expecting number and got " .. type(t.x))
		assert(t.y, "[" .. self.name .. "] FAILURE: box:setData() :: Missing param[data['y']")
		assert(type(t.y) == "number", "[" .. self.name .. "] FAILURE: box:setData() :: Incorrect param[y] - expecting number and got " .. type(t.y))
		self.w = t.w or t.width or self.w
		self.h = t.h or t.height or self.h
		self.pos.x = t.x or self.pos.x
		self.pos.y = t.y or self.pos.y
		self.pos.z = t.z or self.pos.z
		self.border = t.useBorder and t.useBorder or self.border
		self.borderColor = t.borderColor or self.borderColor
		self.color = t.color or self.color
		self.image = self.images[t.image] or self.image
		self.clickable = t.clickable and t.clickable or self.clickable
		self.color[4] = t.opacity or self.color[4]
		if t.padding then
			self.paddingTop, self.paddingRight, self.paddingBottom, self.paddingLeft = unpack(t.padding)
		end
		self.moveable = t.moveable and t.moveable or self.moveable
		return self
	end
	
	function b:disable()
		self.hidden = true
	end
	
	function b:draw()
		lg.push()
		
		lg.setColor(1,1,1,1)
		if self.border then
			if self.parent and box.guis[self.parent].use255 then
				lg.setColor(love.math.colorFromBytes(self.borderColor))
			else
				lg.setColor(self.borderColor)
			end
			lg.rectangle("line", self.pos.x - 1, self.pos.y - 1, self.paddingLeft + self.w + self.paddingRight + 2, self.paddingTop + self.h + self.paddingBottom + 2)
		end
		if self.parent and box.guis[self.parent].use255 then
			lg.setColor(love.math.colorFromBytes(self.color))
		else
			lg.setColor(self.color)
		end
		if self.image then 
			assert(type(self.image) == "userdata", "[" .. self.name .. "] FAILURE: box:draw(" .. self.name .. ") :: Incorrect param[image] - expecting image userdata and got " .. type(self.image))
			lg.draw(self.image, self.pos.x, self.pos.y)
		else
			lg.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
		end
		lg.pop()
	end
	
	function b:enable()
		self.hidden = false
	end
	
	function b:fadeIn()
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
	
	function b:fadeOut(p, h)
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
	
	function b:setHeight(h)
		assert(h, "[" .. self.name .. "] FAILURE: box:setHeight() :: Missing param[height]")
		assert(type(h) == "number", "[" .. self.name .. "] FAILURE: box:setHeight() :: Incorrect param[height] - expecting number and got " .. type(h))
		self.h = h
	end
	
	function b:getHeight(h)
		return self.h
	end
	
	function b:isHovered()
		return self.hovered
	end
	
	function b:setHollow(h)
		assert(h ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Missing param[hollow]")
		assert(type(h) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Incorrect param[hollow] - expecting boolean and got " .. type(h))
		self.hollow = h
	end
	
	function b:isHollow()
		return self.hollow
	end
	
	function b:setImage(i)
		assert(i, "[" .. self.name .. "] FAILURE: box:setImage() :: Missing param[img]")
		local t = type(i)
		assert(t == "string" or t == "userdata", "[" .. self.name .. "] FAILURE: box:setImage() :: Incorrect param[img] - expecting string or image userdata and got " .. t)
		
		if t == "string" then
			if self.parent then
				self.image = self.images[i] or box.guis[self.parent].images[i]
			else
				self.image = i or self.images[i]
			end
		else self.image = i end
	end
	
	function b:getImage()
		return self.image
	end
	
	function b:setPadding(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPadding() :: Missing param[padding]")
		assert(type(p) == "table", "[" .. self.name .. "] FAILURE: box:setPadding() :: Incorrect param[padding] - expecting table and got " .. type(p))
		assert(#p == 4, "[" .. self.name .. "] FAILURE: box:setPadding() :: Incorrect param[padding] - expecting table length 4 and got " .. #p)
		if p.top or p.paddingTop then
			self.paddingTop = p.paddingTop or p.top
			self.paddingRight = p.paddingRight or p.right or self.paddingRight
			self.paddingBottom = p.paddingBottom or p.bottom or self.paddingBottom
			self.paddingLeft = p.paddingLeft or p.left or self.paddingLeft
		else
			self.paddingTop, self.paddingRight, self.paddingBottom, self.paddingTop = unpack(p)
		end
	end
	
	function b:setPaddingBottom(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingBottom() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingBottom() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.paddingBottom = p
	end
	
	function b:setPaddingLeft(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingLeft() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingLeft() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.paddingLeft = p
	end
	
	function b:setPaddingRight(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingRight() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingRight() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.paddingRight = p
	end
	
	function b:setPaddingTop(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingTop() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingTop() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.paddingTop = p
	end
	
	function b:startAnimation()
		self.inAnimation = true
	end
	
	function b:stopAnimation()
		self.inAnimation = false
	end
	
	function b:setMoveable(m)
		assert(m ~= nil, "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Missing param[useBorder]")
		assert(type(m) == "boolean", "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Incorrect param[useBorder] - expecting boolean and got " .. type(m))
		self.moveable = m
	end
	
	function b:isMoveable()
		return self.moveable
	end
	
	function b:setOpacity(o)
		assert(o, "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		self.color[4] = o
	end
	
	function b:getOpacity()
		return self.color[4]
	end
	
	function b:getParent()
		return box.guis[self.parent]
	end
	
	function b:registerEvent(n, f, t, i)
		assert(n, "FAILURE: gui:registerEvent() :: Missing param[eventName]")
		assert(type(n) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
		assert(f, "FAILURE: gui:registerEvent() :: Missing param[functiom]")
		assert(type(f) == "function", "FAILURE: gui:registerEvent() :: Incorrect param[functiom] - expecting function and got " .. type(f))
		if not self.events[n] then self.events[n] = {} end
		local id = #self.events[n] + 1
		self.events[n][id] = {id = id, fn = f, target = t, name = i}
		return self
	end
	
	function b:removeEvent(n, i)
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
	
	function b:touchmoved(id, x, y, dx, dy, pressure)
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
	
	function b:update(dt)
	
	end
	
	function b:setUseBorder(uB)
		assert(uB ~= nil, "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Missing param[useBorder]")
		assert(type(uB) == "boolean", "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Incorrect param[useBorder] - expecting boolean and got " .. type(uB))
		self.border = uB
	end
	
	function b:getUseBorder()
		return self.border
	end
	
	function b:setWidth(w)
		assert(w, "[" .. self.name .. "] FAILURE: box:setWidth() :: Missing param[width]")
		assert(type(w) == "number", "[" .. self.name .. "] FAILURE: box:setWidth() :: Incorrect param[width] - expecting number and got " .. type(w))
		self.w = w
	end
	
	function b:getWidth()
		return self.w
	end
	
	function b:setX(x)
		assert(x, "[" .. self.name .. "] FAILURE: box:setX() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: box:setX() :: Incorrect param[x] - expecting number and got " .. type(x))
		self.pos.x = x
	end
	
	function b:getX()
		return self.pos.x
	end
	
	function b:setY(y)
		assert(y, "[" .. self.name .. "] FAILURE: box:setY() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: box:setY() :: Incorrect param[y] - expecting number and got " .. type(y))
		self.pos.y = y
	end
	
	function b:getY()
		return self.pos.y
	end
	
	function b:setZ(z)
		assert(z, "[" .. self.name .. "] FAILURE: box:setZ() :: Missing param[z]")
		assert(type(z) == "number", "[" .. self.name .. "] FAILURE: box:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
		self.pos.z = z
	end
	
	function b:getZ()
		return self.pos.z
	end
	
	function b.lerp(t1,t2,t)
		return (1 - t) * t1 + t * t2
	end
	
	self.items[b.id] = b
	return b
end

return box