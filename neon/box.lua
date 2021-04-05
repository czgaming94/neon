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

local box = {}

local guis = {}

function box:new(n, id, p)
	local b = element()
	b.__index = box
	b.name = n
	b.id = id
	b.type = "box"
	if p then 
		if not guis[p.id] then guis[p.id] = p end
		if p.id then b.parent = p else b.parent = nil end
	end
	b.round = false
	b.radius = 0
	b.images = {}
	b.image = nil
	b.oldImage = nil
	b.imageBlend = "premultiply"
	b.iX = 0
	b.iY = 0
	b.r = {0,0,0,0}
	b.rot = 0
	b.button = false
	b.keepBackground = false
	b.animateBorderColor = false
	b.borderColorToAnimateTo = {1,1,1,1}
	b.borderColorAnimateSpeed = 0
	b.borderColorAnimateTime = 0
	b.animateBorderOpacity = false
	b.opacityToAnimateBorderTo = 0
	b.opacityBorderAnimateTime = 0
	b.opacityBorderAnimateSpeed = 0
	b.animateImage = false
	b.imageToAnimateTo = nil
	b.imageAnimateTime = 0
	b.imageAnimateSpeed = s
	
	return setmetatable(b, b)
end

function box:addImage(i, n, a)
	assert(i, "[" .. self.name .. "] FAILURE: box:addImage() :: Missing param[img]")
	assert(type(i) == "userdata", "[" .. self.name .. "] FAILURE: box:addImage() :: Incorrect param[img] - expecting image userdata and got " .. type(i))
	assert(n, "[" .. self.name .. "] FAILURE box:addImage() :: Missing param[name]")
	assert(type(n) == "string", "[" .. self.name .. "] FAILURE: box:addImage() :: Incorrect param[img] - expecting string and got " .. type(n))
	self.images[n] = i
	if a and a == true then self:setImage(n) end
	return self
end

function box:animateBorderToColor(c, s, f)
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

function box:animateBorderToOpacity(o, s, f)
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

function box:animateToImage(i, s, f)
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

function box:setBorderColor(bC)
	assert(bC, "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Missing param[color]")
	assert(type(bC) == "table", "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Incorrect param[color] - expecting table and got " .. type(bC))
	assert(#bC == 4, "[" .. self.name .. "] FAILURE: box:setBorderColor() :: Incorrect param[color] - table length 4 expected and got " .. #bC)
	self.borderColor = bC
	return self
end

function box:getBorderColor()
	return self.borderColor
end

function box:setImage(i)
	assert(i, "[" .. self.name .. "] FAILURE: box:setImage() :: Missing param[img]")
	local t = type(i)
	assert(t == "string" or t == "userdata", "[" .. self.name .. "] FAILURE: box:setImage() :: Incorrect param[img] - expecting string or image userdata and got " .. type(t))
	
	if t == "string" then
		if self.parent then
			self.image = self.images[i] or guis[self.parent].images[i]
		else
			self.image = self.images[i] or i
		end
	else self.image = i end
	return self
end

function box:getImage()
	return self.image
end

function box:unsetImage()
	self.image = nil
	return self
end

function box:setImageOffset(o)
	assert(o, "[" .. self.name .. "] FAILURE: box:setImageOffset() :: Missing param[offset]")
	assert(type(o) == "table", "[" .. self.name .. "] FAILURE: box:setImageOffset() :: Incorrect param[offset] - expecting table and got " .. type(o))
	if o.x then
		self.iX, self.iY = o.x, o.y
	else
		self.iX, self.iY = unpack(o)
	end
	return self
end

function box:getImageOffset()
	return {x = self.iX, y = self.iY}
end

function box:setPadding(p)
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

function box:setPaddingBottom(p)
	assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingBottom() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingBottom() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.paddingBottom = p
	return self
end

function box:setPaddingLeft(p)
	assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingLeft() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingLeft() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.paddingLeft = p
	return self
end

function box:setPaddingRight(p)
	assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingRight() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingRight() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.paddingRight = p
	return self
end

function box:setPaddingTop(p)
	assert(p, "[" .. self.name .. "] FAILURE: box:setPaddingTop() :: Missing param[padding]")
	assert(type(p) == "number", "[" .. self.name .. "] FAILURE: box:setPaddingTop() :: Incorrect param[padding] - expecting number and got " .. type(p))
	self.paddingTop = p
	return self
end

function box:setRounded(r)
	assert(r ~= nil, "[" .. self.name .. "] FAILURE: box:setRounded() :: Missing param[round]")
	assert(type(r) == "boolean", "[" .. self.name .. "] FAILURE: box:setRounded() :: Incorrect param[round] - expecting boolean and got " .. type(r))
	self.round = r
	return self
end

function box:isRounded()
	return self.round
end

function box:setUseBorder(uB)
	assert(uB ~= nil, "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Missing param[useBorder]")
	assert(type(uB) == "boolean", "[" .. self.name .. "] FAILURE: box:setUseBorder() :: Incorrect param[useBorder] - expecting boolean and got " .. type(uB))
	self.border = uB
	return self
end

function box:getUseBorder()
	return self.border
end

return setmetatable(box, box)