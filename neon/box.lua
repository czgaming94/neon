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
local box = object()
box.__index = box

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
	b.shaders = {
		fadeOut = lg.newShader(love.filesystem.read("/neon/shaders/fadeOut.shader")),
		fadeIn = lg.newShader(love.filesystem.read("/neon/shaders/fadeIn.shader"))
	}
	b.x = b.pos.x
	b.y = b.pos.y
	b.z = b.pos.z
	b.border = false
	b.borderColor = {1,1,1,1}
	b.color = {1,1,1,1}
	b.defaults = {}
	b.hovered = false
	b.clicked = false
	b.clickable = true
	b.held = false
	b.moveable = false
	b.hollow = false
	b.faded = false
	b.fadedByFunc = false
	b.hidden = false
	b.round = false
	b.radius = 0
	b.events = {}
	b.images = {}
	b.image = nil
	b.oldImage = nil
	b.imageBlend = "premultiply"
	b.iX = 0
	b.iY = 0
	b.r = {0,0,0,0}
	b.rot = 0
	b.noiseX = false
	b.noiseY = false
	b.noiseStrength = 4
	b.keepBackground = false
	b.paddingLeft = 0
	b.paddingRight = 0
	b.paddingTop = 0
	b.paddingBottom = 0
	b.inAnimation = false
	b.runAnimations = false
	b.animateColor = false
	b.colorToAnimateTo = {1,1,1,1}
	b.colorAnimateSpeed = 0
	b.colorAnimateTime = 0
	b.animateBorderColor = false
	b.borderColorToAnimateTo = {1,1,1,1}
	b.borderColorAnimateSpeed = 0
	b.borderColorAnimateTime = 0
	b.animatePosition = false
	b.positionAnimateSpeed = 0
	b.positionToAnimateTo = {x = 0, y = 0}
	b.positionToAnimateFrom = {x = 0, y = 0}
	b.positionAnimateTime = 0
	b.bouncePositionAnimation = false
	b.positionAnimationPercent = 0
	b.positionAnimationPercentX = 0
	b.positionAnimationPercentY = 0
	b.animateOpacity = false
	b.opacityAnimateSpeed = 0
	b.opacityToAnimateTo = 0
	b.opacityAnimateTime = 0
	b.animateBorderOpacity = false
	b.opacityToAnimateBorderTo = 0
	b.opacityBorderAnimateTime = 0
	b.opacityBorderAnimateSpeed = 0
	b.animateImage = false
	b.imageToAnimateTo = nil
	b.imageAnimateTime = 0
	b.imageAnimateSpeed = s
	
	function b:addImage(i, n, a)
		assert(i, "[" .. self.name .. "] FAILURE: box:addImage() :: Missing param[img]")
		assert(type(i) == "userdata", "[" .. self.name .. "] FAILURE: box:addImage() :: Incorrect param[img] - expecting image userdata and got " .. type(i))
		assert(n, "[" .. self.name .. "] FAILURE box:addImage() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: box:addImage() :: Incorrect param[img] - expecting string and got " .. type(n))
		self.images[n] = i
		if a and a == true then self:setImage(n) end
		return self
	end
	
	function b:animateToColor(c, s, f)
		assert(c, "[" .. self.name .. "] FAILURE: box:animateToColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: box:animateToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c > 2, "[" .. self.name .. "] FAILURE: box:animateToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			self.colorToAnimateTo = c
			self.colorAnimateSpeed = s
			self.colorAnimateTime = 0
			self.inAnimation = true
			self.animateColor = true
			self.runAnimations = true
		end
		return self
	end
	
	function b:animateBorderToColor(c, s, f)
		assert(c, "[" .. self.name .. "] FAILURE: box:animateBorderToColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: box:animateBorderToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c > 2, "[" .. self.name .. "] FAILURE: box:animateBorderToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			self.borderColorToAnimateTo = c
			self.borderColorAnimateSpeed = s
			self.borderColorAnimateTime = 0
			self.inAnimation = true
			self.animateBorderColor = true
			self.runAnimations = true
		end
		return self
	end
	
	function b:animateToPosition(x, y, s, f, e)
		assert(x, "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Missing param[x]")
		assert(type(x) == "number" or type(x) == "string", "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Incorrect param[x] - expecting number or 'auto' and got " .. type(x))
		assert(y, "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Missing param[y]")
		assert(type(y) == "number" or type(x) == "string", "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Incorrect param[y] - expecting number or 'auto' and got " .. type(y))
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
		for k,v in pairs(self.pos) do self.positionToAnimateFrom[k] = v end
		if not self.fadedByFunc or f then
			if x == "auto" then
				x = self.pos.x
			end
			if y == "auto" then
				y = self.pos.y
			end
			self.positionToAnimateTo = {x = x, y = y}
			self.positionAnimateSpeed = s
			self.positionAnimateTime = 0
			self.inAnimation = true
			self.animatePosition = true
			self.runAnimations = true
			if e ~= nil then self.bouncePositionAnimation = e else self.bouncePositionAnimation = false end
		end
		return self
	end
	
	function b:animateToOpacity(o, s, f)
		assert(o, "[" .. self.name .. "] FAILURE: box:animateToOpacity() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: box:animateToOpacity() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		s = s or 1
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			self.opacityToAnimateTo = o
			self.opacityAnimateTime = 0
			self.opacityAnimateSpeed = s
			self.inAnimation = true
			self.animateOpacity = true
			self.runAnimations = true
		end
		return self
	end
	
	function b:animateBorderToOpacity(o, s, f)
		assert(o, "[" .. self.name .. "] FAILURE: box:animateBorderToOpacity() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: box:animateBorderToOpacity() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		s = s or 1
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateBorderToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			self.opacityToAnimateBorderTo = o
			self.opacityBorderAnimateTime = 0
			self.opacityBorderAnimateSpeed = s
			self.inAnimation = true
			self.animateBorderOpacity = true
			self.runAnimations = true
		end
		return self
	end
	
	function b:animateToImage(i, s, f)
		assert(i, "[" .. self.name .. "] FAILURE: box:animateToImage() :: Missing param[image]")
		assert(type(i) == "string" or type(i) == "userdata", "[" .. self.name .. "] FAILURE: box:animateToImage() :: Incorrect param[image] - expecting image userdata or string and got " .. type(i))
		s = s or 3
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: box:animateToImage() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			self.oldImage = self.image
			self.imageAnimateFilter = {0,0,0,1}
			if type(i) == "string" then
				self.imageToAnimateTo = self.images[i]
			else
				self.imageToAnimateTo = i
			end
			self.imageAnimateTime = 0
			self.imageAnimateSpeed = s
			self.inAnimation = true
			self.animateImage = true
			self.runAnimations = true
		end
		return self
	end
	
	function b:isAnimating()
		return self.inAnimation
	end
	
	function b:cancelAnimation(single)
		if not single then
			self.inAnimation = false
			self.animateColor = false
			self.animatePosition = false
			self.animateOpacity = false
			self.animateBorderColor = false
			self.animateBorderOpacity = false
			self.animateImage = false
		else
			self[single] = false
		end
	end
	
	function b:setBorderColor(bC)
		assert(bC, "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Missing param[color]")
		assert(type(bC) == "table", "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Incorrect param[color] - expecting table and got " .. type(bC))
		assert(#bC == 4, "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Incorrect param[color] - table length 4 expected and got " .. #bC)
		self.borderColor = bC
		return self
	end
	
	function b:getBorderColor()
		return self.borderColor
	end
	
	function b:setClickable(c)
		assert(c ~= nil, "[" .. self.name .. "] FAILURE: box:setClickable() :: Missing param[clickable]")
		assert(type(c) == "boolean", "[" .. self.name .. "] FAILURE: box:setClickable() :: Incorrect param[clickable] - expecting boolean and got " .. type(c))
		self.clickable = c
		return self
	end
	
	function b:isClickable()
		return self.clickable
	end
	
	function b:setColor(c)
		assert(c, "[" .. self.name .. "] FAILURE: box:setColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: box:setColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c > 2, "[" .. self.name .. "] FAILURE: box:setColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
		self.color = c
		return self
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
		self.rot = t.rot or self.rot
		if t.useBorder then self.border = t.useBorder end
		if t.clickable ~= nil then self.clickable = t.clickable end
		if t.moveable ~= nil then self.moveable = t.moveable end
		if t.hollow ~= nil then self.hollow = t.hollow end
		if t.keepBackground then self.keepBackground = t.keepBackground end
		if t.round then self.round = t.round end
		if t.radius then
			if type(t.radius) == "table" then
				self.r = t.radius
			else
				for k,v in ipairs(self.r) do self.r[k] = t.radius end
			end
		end
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
		self.image = self.images[t.image] or self.image
		self.color[4] = t.opacity or self.color[4]
		if t.padding then
			if t.padding.top then
				self.paddingTop, self.paddingRight, self.paddingBottom, self.paddingLeft = t.padding.top, t.padding.right, t.padding.bottom, t.padding.left
			else
				self.paddingTop, self.paddingRight, self.paddingBottom, self.paddingLeft = unpack(t.padding)
			end
		end
		if t.imageOffset then
			if t.imageOffset.x then
				self.iX, self.iY = t.imageOffset.x, t.imageOffset.y
			else
				self.iX, self.iY = unpack(t.imageOffset)
			end
		end
		self.defaults = t
		return self
	end
	
	function b:disable()
		self.hidden = true
		return self
	end
	
	function b:draw()
		lg.push()
		
		lg.setColor(1,1,1,1)
		local x,y
		if love.math.random(0,100) > 50 then
			x = not self.noiseX and (self.pos.x) or self.pos.x + ((love.math.noise(self.pos.x)) * self.noiseStrength)
			y = not self.noiseY and (self.pos.y) or self.pos.y + ((love.math.noise(self.pos.y)) * self.noiseStrength)
		else
			x = not self.noiseX and (self.pos.x) or self.pos.x - ((love.math.noise(self.pos.x)) * self.noiseStrength)
			y = not self.noiseY and (self.pos.y) or self.pos.y - ((love.math.noise(self.pos.y)) * self.noiseStrength)
		end
		if self.border then
			if self.parent and box.guis[self.parent] and box.guis[self.parent].use255 then
				lg.setColor(love.math.colorFromBytes(self.borderColor))
			else
				lg.setColor(self.borderColor)
			end
			if self.round then
				lg.setBlendMode("replace", "premultiplied")
				lg.setColor({self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4]})
				lg.rectangle("fill", x - 1, y - 1, (self.w - self.r[3]) + 2, (self.h - self.r[4]) + 2, self.r[1])
				lg.rectangle("fill", x - 1, y - 1, (self.w - self.r[1]) + 2, (self.h - self.r[4]) + 2, self.r[2])
				lg.rectangle("fill", (x + self.r[1]) - 1, (y + self.r[2]) - 1, (self.w - self.r[1]) + 2, (self.h - self.r[2]) + 2, self.r[3])
				lg.rectangle("fill", x - 1, (y + self.r[2]) - 1, (self.w - self.r[1]) + 2, (self.h - self.r[2]) + 2, self.r[4])
				lg.setBlendMode("alpha")
			else
				lg.rectangle("line", x - 1, y - 1, self.paddingLeft + self.w + self.paddingRight + 2, self.paddingTop + self.h + self.paddingBottom + 2)
			end
		end
		if self.parent and box.guis[self.parent] and box.guis[self.parent].use255 then
			lg.setColor(love.math.colorFromBytes(self.color))
		else
			lg.setColor(self.color)
		end
		if self.image then 
			assert(type(self.image) == "userdata", "[" .. self.name .. "] FAILURE: box:draw(" .. self.name .. ") :: Incorrect param[image] - expecting image userdata and got " .. type(self.image))
			if self.keepBackground then
				if self.round then
					lg.rectangle("fill", x, y, self.w, self.h, self.radius)
				else
					lg.rectangle("fill", x, y, self.w, self.h)
				end
			end
			if self.animateImage then
				lg.setBlendMode("alpha", "alphamultiply")
				self.shaders.fadeIn:send('time', max(0, min(1, self.imageAnimateTime / self.imageAnimateSpeed)))
				lg.setShader(self.shaders.fadeIn)
				lg.draw(self.imageToAnimateTo, x + self.iX, y + self.iY, self.rot)
				self.shaders.fadeOut:send('time', max(0, min(1, self.imageAnimateTime / self.imageAnimateSpeed)))
				lg.setShader(self.shaders.fadeOut)
				lg.draw(self.image, x + self.iX, y + self.iY, self.rot)
				lg.setShader()
				lg.setBlendMode("alpha")
			else
				lg.draw(self.image, x + self.iX, y + self.iY, self.rot)
			end
		else
			if self.round then
				lg.setBlendMode("replace", "premultiplied")
				lg.setColor({self.color[1], self.color[2], self.color[3], self.color[4]})
				lg.rectangle("fill", x, y, self.w - self.r[3], self.h - self.r[4], self.r[1])
				lg.rectangle("fill", x, y, self.w - self.r[1], self.h - self.r[4], self.r[2])
				lg.rectangle("fill", x + self.r[1], y + self.r[2], self.w - self.r[1], self.h - self.r[2], self.r[3])
				lg.rectangle("fill", x, y + self.r[2], self.w - self.r[1], self.h - self.r[2], self.r[4])
				lg.setBlendMode("alpha")
			else
				lg.rectangle("fill", x, y, self.w, self.h)
			end
		end
		lg.pop()
	end
	
	function b:enable()
		self.hidden = false
		return self
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
		return self
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
		return self
	end
	
	function b:setHeight(h)
		assert(h, "[" .. self.name .. "] FAILURE: box:setHeight() :: Missing param[height]")
		assert(type(h) == "number", "[" .. self.name .. "] FAILURE: box:setHeight() :: Incorrect param[height] - expecting number and got " .. type(h))
		self.h = h
		return self
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
		return self
	end
	
	function b:isHollow()
		return self.hollow
	end
	
	function b:setImage(i)
		assert(i, "[" .. self.name .. "] FAILURE: box:setImage() :: Missing param[img]")
		local t = type(i)
		assert(t == "string" or t == "userdata", "[" .. self.name .. "] FAILURE: box:setImage() :: Incorrect param[img] - expecting string or image userdata and got " .. type(t))
		
		if t == "string" then
			if self.parent then
				self.image = self.images[i] or box.guis[self.parent].images[i]
			else
				self.image = self.images[i] or i
			end
		else self.image = i end
		return self
	end
	
	function b:getImage()
		return self.image
	end
	
	function b:unsetImage()
		self.image = nil
		return self
	end
	
	function b:setImageOffset(o)
		assert(o, "[" .. self.name .. "] FAILURE: box:setImageOffset() :: Missing param[offset]")
		assert(type(o) == "table", "[" .. self.name .. "] FAILURE: box:setImageOffset() :: Incorrect param[offset] - expecting table and got " .. type(o))
		if o.x then
			self.iX, self.iY = o.x, o.y
		else
			self.iX, self.iY = unpack(o)
		end
		return self
	end
	
	function b:getImageOffset()
		return {x = self.iX, y = self.iY}
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
		return self
	end
	
	function b:setPaddingBottom(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingBottom() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingBottom() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.paddingBottom = p
		return self
	end
	
	function b:setPaddingLeft(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingLeft() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingLeft() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.paddingLeft = p
		return self
	end
	
	function b:setPaddingRight(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingRight() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingRight() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.paddingRight = p
		return self
	end
	
	function b:setPaddingTop(p)
		assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingTop() :: Missing param[padding]")
		assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingTop() :: Incorrect param[padding] - expecting number and got " .. type(p))
		self.paddingTop = p
		return self
	end
	
	function b:startAnimation()
		self.inAnimation = true
		return self
	end
	
	function b:stopAnimation()
		self.inAnimation = false
		return self
	end
	
	function b:setMoveable(m)
		assert(m ~= nil, "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Missing param[useBorder]")
		assert(type(m) == "boolean", "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Incorrect param[useBorder] - expecting boolean and got " .. type(m))
		self.moveable = m
		return self
	end
	
	function b:isMoveable()
		return self.moveable
	end
	
	function b:setName(n)
		assert(n, "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.name = n
		return self
	end
	
	function b:getName()
		return self.name
	end
	
	function b:setNoiseStrength(n)
		assert(n, "[" .. self.name .. "] FAILURE: box:setNoiseStrength() :: Missing param[strength]")
		assert(type(n) == "number", "[" .. self.name .. "] FAILURE: box:setNoiseStrength() :: Incorrect param[strength] - expecting number and got " .. type(n))
		self.noiseStrength = n
		return self
	end
	
	function b:getNoiseStrength()
		return self.noiseStrength
	end
	
	function b:setNoiseX(n)
		assert(n ~= nil, "[" .. self.name .. "] FAILURE: box:setNoiseX() :: Missing param[useNoise]")
		assert(type(n) == "boolean", "[" .. self.name .. "] FAILURE: box:setNoiseX() :: Incorrect param[useNoise] - expecting boolean and got " .. type(n))
		self.noiseX = n
		return self
	end
	
	function b:getNoiseX()
		return self.noiseX
	end	
	
	function b:setNoiseY(n)
		assert(n ~= nil, "[" .. self.name .. "] FAILURE: box:setNoiseY() :: Missing param[useNoise]")
		assert(type(n) == "boolean", "[" .. self.name .. "] FAILURE: box:setNoiseY() :: Incorrect param[useNoise] - expecting boolean and got " .. type(n))
		self.noiseY = n
		return self
	end
	
	function b:getNoiseY()
		return self.noiseY
	end

	
	function b:setOpacity(o)
		assert(o, "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		self.color[4] = o
		return self
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
		return self
	end
	
	function b:setRounded(r)
		assert(r ~= nil, "[" .. self.name .. "] FAILURE: box:setRounded() :: Missing param[round]")
		assert(type(r) == "boolean", "[" .. self.name .. "] FAILURE: box:setRounded() :: Incorrect param[round] - expecting boolean and got " .. type(r))
		self.round = r
		return self
	end
	
	function b:isRounded()
		return self.round
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
		return self
	end
	
	function b:getUseBorder()
		return self.border
	end
	
	function b:setWidth(w)
		assert(w, "[" .. self.name .. "] FAILURE: box:setWidth() :: Missing param[width]")
		assert(type(w) == "number", "[" .. self.name .. "] FAILURE: box:setWidth() :: Incorrect param[width] - expecting number and got " .. type(w))
		self.w = w
		return self
	end
	
	function b:getWidth()
		return self.w
	end
	
	function b:setX(x)
		assert(x, "[" .. self.name .. "] FAILURE: box:setX() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: box:setX() :: Incorrect param[x] - expecting number and got " .. type(x))
		self.pos.x = x
		return self
	end
	
	function b:getX()
		return self.pos.x
	end
	
	function b:setY(y)
		assert(y, "[" .. self.name .. "] FAILURE: box:setY() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: box:setY() :: Incorrect param[y] - expecting number and got " .. type(y))
		self.pos.y = y
		return self
	end
	
	function b:getY()
		return self.pos.y
	end
	
	function b:setZ(z)
		assert(z, "[" .. self.name .. "] FAILURE: box:setZ() :: Missing param[z]")
		assert(type(z) == "number", "[" .. self.name .. "] FAILURE: box:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
		self.pos.z = z
		return self
	end
	
	function b:getZ()
		return self.pos.z
	end
	
	function b.lerp(t1,t2,t)
		return (1 - t) * t1 + t * t2
	end
	
	function b.softLerp(e,e1,s,s1,c)
		return (1 - c) * ((s + s1) + ((e - e1) * c^2))
	end
	
	setmetatable(b, box)
	self.items[b.id] = b
	return b
end

return box