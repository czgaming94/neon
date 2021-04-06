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

local slider = {}

local guis = {}
slider.fonts = {}

function slider:new(n, id, p)
	local s = element()
	s.__index = slider
	s.name = n
	s.id = id
	s.type = "slider"
	if p then 
		if not guis[p.id] then guis[p.id] = p end
		if p.id then s.parent = p else s.parent = nil end
	end
	s.sliderColor = {1,1,1,1}
	s.sliderBorder = false
	s.sliderBorderColor = {1,1,1,1}
	s.round = false
	s.label = ""
	s.radius = 0
	s.images = {}
	s.image = nil
	s.sliderImage = nil
	s.inColor = {0.38,0.95,1,1}
	s.outColor = {0.76,0.98,1,0}
	s.percent = 0
	s.oldImage = nil
	s.imageBlend = "premultiply"
	s.iX = 0
	s.iY = 0
	s.r = {0,0,0,0}
	s.sX = 0
	s.sY = 0
	s.size = "auto"
	s.sliderHeld = false
	s.sliderHovered = false
	s.rot = 0
	s.animateImage = false
	s.imageToAnimateTo = nil
	s.imageAnimateTime = 0
	s.imageAnimateSpeed = s
	s.animateBorderColor = false
	s.borderColorToAnimateTo = {1,1,1,1}
	s.borderColorAnimateSpeed = 0
	s.borderColorAnimateTime = 0
	s.animateBorderOpacity = false
	s.opacityToAnimateBorderTo = 0
	s.opacityBorderAnimateTime = 0
	s.opacityBorderAnimateSpeed = 0
	
	return setmetatable(s, s)
end

function slider:animateBorderToColor(c, s, f)
	assert(c, "[" .. self.name .. "] FAILURE: slider:animateBorderToColor() :: Missing param[color]")
	assert(type(c) == "table", "[" .. self.name .. "] FAILURE: slider:animateBorderToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
	assert(#c > 2, "[" .. self.name .. "] FAILURE: slider:animateBorderToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
	s = s or 2
	assert(type(s) == "number", "[" .. self.name .. "] FAILURE: slider:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
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

function slider:animateBorderToOpacity(o, s, f)
	assert(o, "[" .. self.name .. "] FAILURE: slider:animateBorderToOpacity() :: Missing param[opacity]")
	assert(type(o) == "number", "[" .. self.name .. "] FAILURE: slider:animateBorderToOpacity() :: Incorrect param[opacity] - expecting number and got " .. type(o))
	s = s or 1
	assert(type(s) == "number", "[" .. self.name .. "] FAILURE: slider:animateBorderToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
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

function slider:addImage(i, n, a)
	assert(i, "[" .. self.name .. "] FAILURE: slider:addImage() :: Missing param[img]")
	assert(type(i) == "userdata", "[" .. self.name .. "] FAILURE: slider:addImage() :: Incorrect param[img] - expecting image userdata and got " .. type(i))
	assert(n, "[" .. self.name .. "] FAILURE slider:addImage() :: Missing param[name]")
	assert(type(n) == "string", "[" .. self.name .. "] FAILURE: slider:addImage() :: Incorrect param[img] - expecting string and got " .. type(n))
	self.images[n] = i
	if a and a == true then self:setImage(n) end
	return self
end

function slider:setImage(i)
	assert(i, "[" .. self.name .. "] FAILURE: slider:setImage() :: Missing param[img]")
	local t = type(i)
	assert(t == "string" or t == "userdata", "[" .. self.name .. "] FAILURE: slider:setImage() :: Incorrect param[img] - expecting string or image userdata and got " .. type(t))
	
	if t == "string" then
		if self.parent then
			self.image = self.images[i] or guis[self.parent].images[i]
		else
			self.image = self.images[i] or i
		end
	else self.image = i end
	return self
end

function slider:getImage()
	return self.image
end

function slider:unsetImage()
	self.image = nil
	return self
end

function slider:setImageOffset(o)
	assert(o, "[" .. self.name .. "] FAILURE: slider:setImageOffset() :: Missing param[offset]")
	assert(type(o) == "table", "[" .. self.name .. "] FAILURE: slider:setImageOffset() :: Incorrect param[offset] - expecting table and got " .. type(o))
	if o.x then
		self.iX, self.iY = o.x, o.y
	else
		self.iX, self.iY = unpack(o)
	end
	return self
end

function slider:getImageOffset()
	return {x = self.iX, y = self.iY}
end

function slider:setRounded(r)
	assert(r ~= nil, "[" .. self.name .. "] FAILURE: slider:setRounded() :: Missing param[round]")
	assert(type(r) == "boolean", "[" .. self.name .. "] FAILURE: slider:setRounded() :: Incorrect param[round] - expecting boolean and got " .. type(r))
	self.round = r
	return self
end

function slider:isRounded()
	return self.round
end

function slider:setSliderImage(i)
	assert(i, "[" .. self.name .. "] FAILURE: slider:setSliderImage() :: Missing param[image]")
	assert(type(i) == "userdata", "[" .. self.name .. "] FAILURE: slider:setSliderImage() :: Incorrect param[image] - expecting image userdata and got " .. type(i))
	self.sliderImage = i
	return self
end

function slider:getSliderImage()
	return self.sliderImage
end

function slider:getPercent()
	return self.percent
end

function slider:val()
	return self.percent
end

return setmetatable(slider, slider)