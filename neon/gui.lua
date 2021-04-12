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



local lf, lg, lt, lm = love.filesystem, love.graphics, love.timer, love.mouse
local min, max, sqrt = math.min, math.max, math.sqrt

local gui = {}
local events = {}
local items = {}

local shaders = {
	fadeOut = lg.newShader(lf.read("/neon/shaders/fadeOut.shader")),
	fadeIn = lg.newShader(lf.read("/neon/shaders/fadeIn.shader")),
	slider = lg.newShader(lf.read("/neon/shaders/sliderRadialGradient.shader"))
}

local colors = {
	red = {1,0,0,1},
	green = {0,1,0,1},
	blue = {0,0,1,1},
	yellow = {1,1,0,1},
	purple = {1,0,1,1}
}

gui.handles = {
	box = require("neon.box"),
	checkbox = require("neon.checkbox"),
	dropdown = require("neon.dropdown"),
	text = require("neon.text"),
	textfield = require("neon.textfield"),
	radial = require("neon.radial"),
	slider = require("neon.slider")
}
gui.items = {}
gui.z = 0
gui.use255 = false
gui.id = 1
gui.enabled = true
gui.allowUpdate = true
gui.held = {}
gui.images = {}
gui.needToSort = false


function gui.color(c)
	assert(c, "FAILURE: gui:color() :: Missing param[name]")
	assert(type(c) == "string", "FAILURE: gui:color() :: Incorrect param[name] - expecting string and got " .. type(c))
	return gui:copy(colors[c])
end

function gui:new(item)
	if not self.enabled then return false end
	item = item or self
	local new = self:copy(item, "items")
	new.__index = gui
	setmetatable(new, new)
	new.id = #items + 1
	items[new.id] = new
	return new
end

function gui:copy(item, skip)
	if not self.enabled then return false end
    local c
    if type(item) == "table" then
        c = {}
        for orig_key, orig_value in pairs(item) do
			if skip and orig_key == skip then
				c[orig_key] = {}
			else
				c[orig_key] = self:copy(orig_value, skip)
			end
		end
    else
        c = item
    end
    return c
end

function gui:duplicate(i)	
	if not self.enabled then return false end
	assert(i, "FAILURE: gui:duplicate() :: Missing param[item]")
	assert(type(i) == "number" or type(i) == "string", "FAILURE: gui:duplicate() :: Incorrect param[item] - expecting boolean and got " .. type(i))
	if type(i) == "string" then
		return self:copy(self:child(i))
	else
		for _,v in ipairs(items) do
			for k,t in self:sort(v.items) do
				if t.id == i then
					return self:copy(v[k])
				end
			end
		end
	end
end

function gui:generate(item, copies, skip)
	if not self.enabled then return false end
	local copies = copies or {}
    local copy
    if type(item) == 'table' then
        if copies[item] then
            copy = copies[item]
        else
            copy = {}
            copies[item] = copy
            for orig_key, orig_value in next, item, nil do
				if skip and orig_key == skip then
					copy[skip] = {}
				else
					copy[self:generate(orig_key, copies, skip)] = self:generate(orig_value, copies, skip)
				end
            end
            setmetatable(copy, self:generate(getmetatable(item), copies, skip))
        end
    else
        copy = item
    end
    return copy
end

function gui:setUse255(u)
	if not self.enabled then return false end
	assert(u ~= nil, "FAILURE: gui:setUse255() :: Missing param[use255]")
	assert(type(u) == "boolean", "FAILURE: gui:setUse255() :: Incorrect param[use255] - expecting boolean and got " .. type(u))
	self.use255 = u
	return self
end

function gui:animateToColor(o, c, s)
	if not self.enabled then return false end
	assert(o, "FAILURE: gui:animateToColor() :: Missing param[object]")
	assert(type(o) == "table", "FAILURE: gui:animateToColor() :: Incorrect param[object] - expecting table and got " .. type(o))
	assert(c, "FAILURE: gui:animateToColor() :: Missing param[color]")
	assert(type(c) == "table", "FAILURE: gui:animateToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
	assert(#c > 2, "FAILURE: gui:animateToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
	s = s or 2
	assert(type(s) == "number", "FAILURE: gui:animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
	o.colorToAnimateTo = c
	o.colorAnimateSpeed = s
	o.colorAnimateTime = 0
	o.inAnimation = true
	o.animateColor = true
	return o
end

function gui:animateBorderToColor(o, c, s)
	if not self.enabled then return false end
	assert(o, "FAILURE: gui:animateToColor() :: Missing param[object]")
	assert(type(o) == "table", "FAILURE: gui:animateToColor() :: Incorrect param[object] - expecting table and got " .. type(o))
	assert(c, "FAILURE: gui:animateBorderToColor() :: Missing param[color]")
	assert(type(c) == "table", "FAILURE: gui:animateBorderToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
	assert(#c > 2, "FAILURE: gui:animateBorderToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
	s = s or 2
	assert(type(s) == "number", "FAILURE: gui:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
	o.borderColorToAnimateTo = c
	o.borderColorAnimateSpeed = s
	o.borderColorAnimateTime = 0
	o.inAnimation = true
	o.animateBorderColor = true
	return o
end
	
function gui:animateToPosition(o, x, y, s)
	if not self.enabled then return false end
	assert(o, "FAILURE: gui:animateToPosition() :: Missing param[object]")
	assert(type(o) == "table", "FAILURE: gui:animateToPosition() :: Incorrect param[object] - expecting table and got " .. type(o))
	assert(x, "FAILURE: gui:animateToPosition() :: Missing param[x]")
	assert(type(x) == "number", "FAILURE: gui:animateToPosition() :: Incorrect param[x] - expecting number and got " .. type(x))
	assert(y, "FAILURE: gui:animateToPosition() :: Missing param[y]")
	assert(type(y) == "number", "FAILURE: gui:animateToPosition() :: Incorrect param[y] - expecting number and got " .. type(y))
	s = s or 2
	assert(type(s) == "number", "FAILURE: gui:animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
	for k,v in pairs(o.pos) do o.positionToAnimateFrom[k] = v end
	o.positionToAnimateTo = {x = x, y = y}
	o.positionAnimateSpeed = s
	o.positionAnimateTime = 0
	o.inAnimation = true
	o.animatePosition = true
	return o
end

function gui:animateBorderToOpacity(obj, o, s)
	if not self.enabled then return false end
	assert(obj, "FAILURE: gui:animateBorderToOpacity() :: Missing param[object]")
	assert(type(obj) == "table", "FAILURE: gui:animateBorderToOpacity() :: Incorrect param[object] - expecting table and got " .. type(obj))
	assert(o, "FAILURE: gui:animateBorderToOpacity() :: Missing param[o]")
	assert(type(o) == "number", "FAILURE: gui:animateBorderToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
	s = s or 2
	assert(type(s) == "number", "FAILURE: gui:animateBorderToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
	o.opacityToAnimateBorderTo = c
	o.opacityBorderAnimateSpeed = s
	o.opacityBorderAnimateTime = 0
	o.inAnimation = true
	o.animateBorderOpacity = true
	return o
end

function gui:animateToOpacity(obj, o, s)
	if not self.enabled then return false end
	assert(obj, "FAILURE: gui:animateToOpacity() :: Missing param[object]")
	assert(type(obj) == "table", "FAILURE: gui:animateToOpacity() :: Incorrect param[object] - expecting table and got " .. type(obj))
	assert(o, "FAILURE: gui:animateToOpacity() :: Missing param[o]")
	assert(type(o) == "number", "FAILURE: gui:animateToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
	s = s or 1
	assert(type(s) == "number", "FAILURE: gui:animateToOpacity() :: Incorrect param[s] - expecting number and got " .. type(s))
	obj.opacityToAnimateTo = o
	obj.opacityAnimateTime = 0
	obj.opacityAnimateSpeed = s
	obj.inAnimation = true
	obj.animateOpacity = true
	return obj
end

function gui:canUpdate(a)
	if a ~= nil then
		assert(type(a) == "boolean", "FAILURE: gui:canUpdate() :: Incorrect param[update] - expecting boolean and got " .. type(a))
		self.allowUpdate = a
		return self
	else
		return self.allowUpdate
	end
end

function gui:addColor(c, n)
	if not self.enabled then return false end
	assert(c, "FAILURE: gui:addColor() :: Missing param[color]")
	assert(type(c) == "table", "FAILURE: gui:addColor() :: Incorrect param[color] - expecting table and got " .. type(c))
	assert(#c > 2, "FAILURE : gui:addColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
	assert(n, "FAILURE: gui:addColor() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addColor() :: Incorrect param[name] - expecting string and got " .. type(n))
	colors[n] = c
	return self
end

function gui:add(t, n, b, f, tar)
	assert(t, "FAILURE: gui:addBox() :: Missing param[type]")
	assert(type(t) == "string", "FAILURE: gui:addBox() :: Incorrect param[type] - expecting string and got " .. type(t))
	assert(n, "FAILURE: gui:addBox() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addBox() :: Incorrect param[name] - expecting string and got " .. type(n))
	local button = false
	if t == "button" then
		t = "box"
		button = true
	end
	self.items[n] = self.handles[t]:new(n, #self.items + 1, self)
	if button then
		assert(f, "FAILURE: gui:addBox() :: Missing param[function]")
		assert(type(f) == "function", "FAILURE: gui:addBox() :: Incorrect param[function] - expecting function and got " .. type(f))
		self.items[n]:registerEvent("onClick", f, tar).button = true
	end
	self.needToSort = true
	return self.items[n]
end

function gui:addBox(n, b, f, t)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addBox() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addBox() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.items[n] = self.handles.box:new(n, #self.items + 1, self)
	self.needToSort = true
	if b then
		assert(f, "FAILURE: gui:addBox() :: Missing param[function]")
		assert(type(f) == "string", "FAILURE: gui:addBox() :: Incorrect param[function] - expecting string and got " .. type(f))
		self.items[n]:registerEvent("onClick", f, t)
	end
	return self.items[n]
end

function gui:addCheckbox(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addCheckbox() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addCheckbox() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.items[n] = self.handles.checkbox:new(n, #self.items + 1, self)
	self.needToSort = true
	return self.items[n]
end

function gui:addDropdown(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addDropdown() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addDropdown() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.items[n] = self.handles.dropdown:new(n, #self.items + 1, self)
	self.needToSort = true
	return self.items[n]
end

function gui:addTextfield(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addTextfield() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addTextfield() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.items[n] = self.handles.textfield:new(n, #self.items + 1, self)
	self.needToSort = true
	return self.items[n]
end

function gui:addSlider(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addSlider() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addSlider() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.items[n] = self.handles.slider:new(n, #self.items + 1, self)
	self.needToSort = true
	return self.items[n]
end

function gui:addRadial(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addRadial() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addRadial() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.items[n] = self.handles.radial:new(n, #self.items + 1, self)
	self.needToSort = true
	return self.items[n]
end

function gui:addText(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addText() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addText() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.items[n] = self.handles.text:new(n, #self.items + 1, self)
	self.needToSort = true
	return self.items[n]
end

function gui:update(dt)
	if not self.enabled then return false end
	for _,v in ipairs(items) do 
		if v.enabled and v.allowUpdate then
			for _,e in self:sort(v.items) do 
				local i = self:child(e.name)
				if not i.hidden then 
					local x,y = lm.getPosition()
					local hover = (x >= i.pos.x + i.paddingLeft and x <= i.pos.x + i.w + i.paddingRight) and (y >= i.pos.y + i.paddingTop and y <= i.pos.y + i.h + i.paddingBottom)
					local event = {x=x,y=y}
					if i:is("text") then
						hover = (x >= i.pos.x and x <= i.pos.x + i.w) and (y >= i.pos.y and y <= i.pos.y + i.h)
					elseif i:is("dropdown") then
						if i.border then
							hover = i.open and (x >= i.pos.x and x <= i.pos.x + i.dW + i.optionPaddingLeft + i.optionPaddingRight + 2 and y >= i.pos.y and y <= i.pos.y + i.h + i.dH) or (x >= i.pos.x and x <= i.pos.x + i.w and y >= i.pos.y and y <= i.pos.y + i.h)
						else
							hover = i.open and (x >= i.pos.x and x <= i.pos.x + i.dW + i.optionPaddingLeft + i.optionPaddingRight and y >= i.pos.y and y <= i.pos.y + i.h + i.dH) or (x >= i.pos.x and x <= i.pos.x + i.w and y >= i.pos.y and y <= i.pos.y + i.h)
						end
					elseif i:is("radial") then
						hover = (x >= i.pos.x - i.size and x <= i.pos.x + i.w) and (y >= i.pos.y - i.size and y <= i.pos.y + i.h)
					end
					-- HOVER UPDATE
					if hover then
						if i.hovered then
							if i.events.whileHovering then 
								for _,v in ipairs(i.events.whileHovering) do	
									v.fn(i, v.target, event)
								end
							end
						end
						if not i.hovered then
							if i.events.onHoverEnter then 
								for _,v in ipairs(i.events.onHoverEnter) do	
									v.fn(i, v.target, event)
								end
							end
							if events.onHoverEnter then
								for _,v in ipairs(events.onHoverEnter) do
									if i:is(v.o) then
										v.fn(i, v.target, event)
									end
								end
							end
							i.hovered = true 
						end
					else
						if i.hovered then 
							if i.events.onHoverExit then 
								for _,v in ipairs(i.events.onHoverExit) do	
									v.fn(i, v.target, event)
								end
							end
							if events.onHoverExit then
								for _,v in ipairs(events.onHoverExit) do
									if i:is(v.o) then
										v.fn(i, v.target, event)
									end
								end
							end
							i.hovered = false 
						end
					end
					-- ANIMATION UPDATE
					if i:isAnimating() then
						local allColorsMatch = true
						local allBorderColorsMatch = true
						local inProperPosition = true
						local atProperOpacity = true
						local atProperBorderOpacity = true
						local imagesMatch = true
						
						if i.runAnimations then
							local animEvent = {color = i.animateColor, borderColor = i.animateBorderColor, opacity = i.animateOpacity, borderOpacity = i.animateBorderOpacity, position = i.animatePosition, image = i.animateImage}
							if i.events.onAnimationStart then
								for _,v in ipairs(i.events.onAnimationStart) do
									v.fn(i, v.target, animEvent)
								end
							end
							if events.onAnimationStart then
								for _,v in ipairs(events.onAnimationStart) do
									if i:is(v.o) then
										v.fn(i, v.target, animEvent)
									end
								end
							end
							i.runAnimations = false
						end
						
						if i.animateColor then
							for k,v in ipairs(i.colorToAnimateTo) do
								if i.color[k] ~= v then
									if v > i.color[k] then
										i.color[k] = min(v, i.color[k] + (i.colorAnimateSpeed * dt))
									else
										i.color[k] = max(v, i.color[k] - (i.colorAnimateSpeed * dt))
									end
									allColorsMatch = false
								end
							end
						end
						
						if i.animateImage then
							if i.imageAnimateTime <= i.imageAnimateSpeed then
								i.imageAnimateTime = i.imageAnimateTime + dt
								imagesMatch = false
							else
								i.image = i.imageToAnimateTo
							end
						end
						
						if i.animatePosition then
							i.positionAnimateTime = i.positionAnimateTime + dt
							local t = min(i.positionAnimateTime * (i.positionAnimateSpeed / 10), 1.0)
							if i.pos.x ~= i.positionToAnimateTo.x or i.pos.y ~= i.positionToAnimateTo.y then
								i.pos.x = i.lerp(i.positionToAnimateFrom.x, i.positionToAnimateTo.x, t)
								i.pos.y = i.lerp(i.positionToAnimateFrom.y, i.positionToAnimateTo.y, t)
								if i.type == "text" and i.fancy then
									for _,v in ipairs(i.typewriterText) do
										v.x = i.lerp(v.oX, v.tX, t)
										v.y = i.lerp(v.oY, v.tY, t)
									end
								end
								inProperPosition = false
							end
						end
						
						if i.animateOpacity then
							if i.color[4] ~= i.opacityToAnimateTo then
								if i.color[4] < i.opacityToAnimateTo then
									i.color[4] = min(i.opacityToAnimateTo, i.color[4] + (i.opacityAnimateSpeed * dt))
								else
									i.color[4] = max(i.opacityToAnimateTo, i.color[4] - (i.opacityAnimateSpeed * dt))
								end
								atProperOpacity = false
							else
								if i.fadedByFunc then
									if i.color[4] == 1 then
										if i.events.afterFadeIn then 
											for _,v in ipairs(i.events.afterFadeIn) do
												v.fn(i, v.target)
											end
										end
										if events.afterFadeIn then
											for _,v in ipairs(events.afterFadeIn) do
												if i:is(v.o) then
													v.fn(i, v.target)
												end
											end
										end
									elseif i.color[4] == 0 then
										if i.events.afterFadeOut then 
											for _,v in ipairs(i.events.afterFadeOut) do
												v.fn(i, v.target)
											end
										end
										if events.afterFadeOut then
											for _,v in ipairs(events.afterFadeOut) do
												if i:is(v.o) then
													v.fn(i, v.target)
												end
											end
										end
									end
									i.fadedByFunc = false
								end
							end
						end
						
						if i.animateBorderColor then
							for k,v in ipairs(i.borderColorToAnimateTo) do
								if i.borderColor[k] ~= v then
									if v > i.borderColor[k] then
										i.borderColor[k] = min(v, i.borderColor[k] + (i.borderColorAnimateSpeed * dt))
									else
										i.borderColor[k] = max(v, i.borderColor[k] - (i.borderColorAnimateSpeed * dt))
									end
									allBorderColorsMatch = false
								end
							end
						end
						
						if i.animateBorderOpacity then
							if i.borderColor[4] ~= i.opacityToAnimateBorderTo then
								if i.borderColor[4] < i.opacityToAnimateBorderTo then
									i.borderColor[4] = min(i.opacityToAnimateBorderTo, i.borderColor[4] + (i.opacityBorderAnimateSpeed * dt))
								else
									i.borderColor[4] = max(i.opacityToAnimateBorderTo, i.borderColor[4] - (i.opacityBorderAnimateSpeed * dt))
								end
								atProperBorderOpacity = false
							else
								if i.fadedByFunc then
									if i.borderColor[4] == 1 then
										if i.events.afterFadeIn then 
											for _,v in ipairs(i.events.afterFadeIn) do
												v.fn(i, v.target)
											end
										end
										if events.afterFadeIn then
											for _,v in ipairs(events.afterFadeIn) do
												if i:is(v.o) then
													v.fn(i, v.target)
												end
											end
										end
									elseif i.borderColor[4] == 0 then
										if i.events.afterFadeOut then 
											for _,v in ipairs(i.events.afterFadeOut) do
												v.fn(i, v.target)
											end
										end
										if events.afterFadeOut then
											for _,v in ipairs(events.afterFadeOut) do
												if i:is(v.o) then
													v.fn(i, v.target)
												end
											end
										end
									end
									i.fadedByFunc = false
								end
							end
						end
						
						if i.inAnimation and allColorsMatch and inProperPosition and atProperOpacity and allBorderColorsMatch and atProperBorderOpacity and imagesMatch then
							i.inAnimation = false
							i.animateColor = false
							i.animatePosition = false
							if i.animateOpacity and i.faded then i.hidden = true end
							i.animateOpacity = false
							i.animateBorderColor = false
							i.animateBorderOpacity = false
							i.animateImage = false
							if i.events.onAnimationComplete then
								for _,v in ipairs(i.events.onAnimationComplete) do
									v.fn(i, v.target)
								end
							end
							if events.onAnimationComplete then
								for _,v in ipairs(events.onAnimationComplete) do
									if i:is(v.o) then
										v.fn(i, v.target)
									end
								end
							end
						end
					end
					-- BOX UPDATE
					if i:is("box") then
					
					end
					-- CHECKBOX UPDATE
					if i:is("checkbox") then
						for k,v in ipairs(i.options) do
							if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
								if not v.hovered then 
									v.hovered = true 
									if i.events.onOptionHover then
										for _,e in ipairs(i.events.onOptionHover) do
											e.fn(i, v)
										end
									end
									if events.onOptionHover then
										for _,e in ipairs(events.onOptionHover) do
											if i.type == e.o then
												e.fn(i, v)
											end
										end
									end
								end
							else
								if v.hovered then 
									v.hovered = false 
									if i.events.onOptionHoverExit then
										for _,e in ipairs(i.events.onOptionHoverExit) do
											e.fn(i, v)
										end
									end
									if events.onOptionHoverExit then
										for _,e in ipairs(events.onOptionHoverExit) do
											if i.type == e.o then
												e.fn(i, v)
											end
										end
									end
								end
							end
						end
					end					
					-- DROPDOWN UPDATE
					if i:is("dropdown") then
						if i.open then
							local x,y = lm.getPosition()
							for k,v in ipairs(i.options) do
								if x >= v.x - i.optionPaddingLeft / 2 and x <= v.x + v.w + i.optionPaddingLeft and y >= v.y - i.optionPaddingTop - i.optionPaddingBottom and y <= v.y + v.h - i.optionPaddingTop - i.optionPaddingBottom then
									if not v.hovered then v.hovered = true end
								else
									if v.hovered then v.hovered = false end
								end
							end
						end
					end
					-- RADIAL UPDATE
					if i:is("radial") then
						for _,v in ipairs(i.options) do
							if x >= v.x - i.size and x <= v.x + i.size and y >= v.y - i.size and y <= v.y + i.size then
								if not v.hovered then 
									v.hovered = true 
									if i.events.onOptionHover then
										for _,e in ipairs(i.events.onOptionHover) do
											e.fn(i, v)
										end
									end
									if events.onOptionHover then
										for _,e in ipairs(events.onOptionHover) do
											if i.type == e.o then
												e.fn(i, v)
											end
										end
									end
								end
							else
								if v.hovered then 
									v.hovered = false 
									if i.events.onOptionHoverExit then
										for _,e in ipairs(i.events.onOptionHoverExit) do
											e.fn(i, v)
										end
									end
									if events.onOptionHoverExit then
										for _,e in ipairs(events.onOptionHoverExit) do
											if i.type == e.o then
												e.fn(i, v)
											end
										end
									end
								end
							end
						end
					end
					-- SLIDER UPDATE
					if i:is("slider") then
						if (x >= i.sX - i.h and x <= i.sX + i.h) and (y >= i.sY and y <= i.sY + i.h) or i.sliderHeld then
							if not i.sliderHovered then i.sliderHovered = true end
							if lm.isDown(1) then
								if not i.sliderHeld then 
									i.sliderHeld = true 
									if i.events.onGrab then 
										for _,v in ipairs(i.events.onGrab) do
											v.fn(i, v.target, i.percent)
										end
									end
									if events.onGrab then 
										for _,v in ipairs(events.onGrab) do
											if i:is(v.o) then
												v.fn(i, v.target, i.percent)
											end
										end
									end
								end
								if x >= i.pos.x and x <= i.pos.x + i.w then
									i.sX = x
								else
									i.sX = min(max(i.pos.x, x), (i.pos.x + i.w) - 3)
								end
								i.percent = (i.sX - i.pos.x) / (i.w - 3)
								if i.events.onChange then 
									for _,v in ipairs(i.events.onChange) do
										v.fn(i, v.target, i.percent)
									end
								end
								if events.onChange then 
									for _,v in ipairs(events.onChange) do
										if i:is(v.o) then
											v.fn(i, v.target, i.percent)
										end
									end
								end
							else
								if i.sliderHeld then 
									i.sliderHeld = false 
								end
								if i.events.onRelease then 
									for _,v in ipairs(i.events.onRelease) do
										v.fn(i, v.target, i.percent)
									end
								end
								if events.onRelease then 
									for _,v in ipairs(events.onRelease) do
										if i:is(v.o) then
											v.fn(i, v.target, i.percent)
										end
									end
								end
							end
						else
							if not i.sliderHeld and i.sliderHovered then i.sliderHovered = false end
						end
					end
					-- TEXT UPDATE
					if i:is("text") then
						if i.typewriter then
							i.typewriterWaited = i.typewriterWaited + dt
							if i.fancy then
								for k,v in ipairs(i.typewriterText) do
									if not v.finished then
										if v.text then
											if v.delay > 0 and v.delayWaited < v.delay then
												v.delayWaited = v.delayWaited + dt
												if v.delayWaited >= v.delay then
													v.needToWait = false
												end
											end
											if not v.needToWait then
												v.timeWaited = v.timeWaited + dt
												if not v.started then
													v.started = true
												end
												while v.timeWaited >= v.time and v.textPos <= #v.text do
													v.timeWaited = v.timeWaited - v.time
													v.textPos = v.textPos + 1
													if not v.toShow then v.toShow = "" end
													if not v.text[v.textPos] then v.text[v.textPos] = 0 end
													v.toShow = v.toShow .. v.text[v.textPos]
												end
												if v.textPos >= #v.text then
													v.finished = true
												end
											end
										end
										if not v.finished then break end
										if k == #i.typewriterText then
											if i.events.onTypewriterFinish then
												for _,e in ipairs(i.events.onTypewriterFinish) do
													e.fn(i, e.target)
												end
											end
											if i.typewriterRepeat then
												for _,e in ipairs(i.typewriterText) do
													v.timeWaited = 0
													v.toShow = ""
													v.finished = false
													v.textPos = 1
													if v.delayWaited ~= 0 then
														v.needToWait = true
													end
												end
											end
										end
									end
								end
							else
								while i.typewriterWaited >= i.typewriterSpeed and i.typewriterPos <= #i.typewriterText do
									i.typewriterWaited = i.typewriterWaited - i.typewriterSpeed
									i.typewriterPrint = i.typewriterPrint .. i.typewriterText[i.typewriterPos]
									i.typewriterPos = i.typewriterPos + 1
								end
								if i.typewriterPos >= #i.typewriterText and not i.typewriterFinished then
									if not i.typewriterRepeat then i.typewriterFinished = true else i:typewriterCycle() end
									i.typewriterRunCount = i.typewriterRunCount + 1
								end
							end
						end
					end
					-- TEXTFIELD UPDATE
					if i:is("textfield") then
						if i.active then
							i.cursorTime = i.cursorTime + dt
							if i.cursorTime >= 1 then
								i.cursorTime = i.cursorTime - 1
								i.showCursor = not i.showCursor
							end
						end
					end
					if i.update then i:update(dt) end
				end
			end
		end
	end
end

function gui:enable()
	self.enabled = true
	return self
end

function gui:disable(kill, keep)
	if kill ~= nil then kill = kill else kill = true end
	if keep ~= nil then keep = keep else keep = false end
	if kill then
		for _,i in self:sort(self.items) do
			i.hovered = false
			i.active = false
			i.clicked = false
			i.held = false
			i.fadedByFunc = false
			i.inAnimation = false
			i.animateColor = false
			i.animatePosition = false
			i.animateOpacity = false
			i.animateBorderColor = false
			i.animateBorderOpacity = false
			if not keep then
				i:setData(i.defaults)
			end
		end
	end
	self.enabled = false
	return self
end

function gui:drawAll()
	if not self.enabled then return false end
	table.sort(items, function(a,b)
		if not a or not b then return false end
		if a.z == b.z then
			if a.id == b.id then
				return false
			else
				return a.id > b.id
			end
		else
			return a.z < b.z
		end
	end)
	for _,v in ipairs(items) do
		v:draw()
	end
end

function gui:draw()
	if not self.enabled then return false end
	toDraw = self:sort(self.items, function(a,b)
		if not a or not b then return false end
		if a.pos.z == b.pos.z then
			if a.id == b.id then
				if a.pos.x == b.pos.x then
					if a.pos.y == b.pos.y then
						return false
					else
						return a.pos.y > b.pos.y
					end
				else
					return a.pos.x < b.pos.x
				end
			else
				return a.id > b.id
			end
		else
			return a.pos.z < b.pos.z
		end
	end)
	for _,i in toDraw do
		lg.push("all")
		if not i.hidden then
			lg.setColor(1,1,1,1)
			-- BOX DRAW
			if i:is("box") then
				lg.setColor(1,1,1,1)
				local x,y
				if love.math.random(0,100) > 50 then
					x = not i.noiseX and (i.pos.x) or i.pos.x + ((love.math.noise(i.pos.x)) * i.noiseStrength)
					y = not i.noiseY and (i.pos.y) or i.pos.y + ((love.math.noise(i.pos.y)) * i.noiseStrength)
				else
					x = not i.noiseX and (i.pos.x) or i.pos.x - ((love.math.noise(i.pos.x)) * i.noiseStrength)
					y = not i.noiseY and (i.pos.y) or i.pos.y - ((love.math.noise(i.pos.y)) * i.noiseStrength)
				end
				if i.border then
					if i.parent and items[i.parent] and items[i.parent].use255 then
						lg.setColor(love.math.colorFromBytes(i.borderColor))
					else
						lg.setColor(i.borderColor)
					end
					if i.round then
						lg.setBlendMode("replace", "premultiplied")
						lg.setColor({i.borderColor[1], i.borderColor[2], i.borderColor[3], i.borderColor[4]})
						lg.rectangle("fill", x - 1, y - 1, (i.w - i.r[3]) + 2, (i.h - i.r[4]) + 2, i.r[1])
						lg.rectangle("fill", x - 1, y - 1, (i.w - i.r[1]) + 2, (i.h - i.r[4]) + 2, i.r[2])
						lg.rectangle("fill", (x + i.r[1]) - 1, (y + i.r[2]) - 1, (i.w - i.r[1]) + 2, (i.h - i.r[2]) + 2, i.r[3])
						lg.rectangle("fill", x - 1, (y + i.r[2]) - 1, (i.w - i.r[1]) + 2, (i.h - i.r[2]) + 2, i.r[4])
						lg.setBlendMode("alpha")
					else
						lg.rectangle("line", x - 1, y - 1, i.paddingLeft + i.w + i.paddingRight + 2, i.paddingTop + i.h + i.paddingBottom + 2)
					end
				end
				if i.parent and items[i.parent] and items[i.parent].use255 then
					lg.setColor(love.math.colorFromBytes(i.color))
				else
					lg.setColor(i.color)
				end
				if i.image then 
					assert(type(i.image) == "userdata", "[" .. i.name .. "] FAILURE: box:draw(" .. i.name .. ") :: Incorrect param[image] - expecting image userdata and got " .. type(i.image))
					if i.keepBackground then
						if i.round then
							lg.rectangle("fill", x, y, i.w, i.h, i.radius)
						else
							lg.rectangle("fill", x, y, i.w, i.h)
						end
					end
					if i.animateImage then
						lg.setBlendMode("alpha", "alphamultiply")
						shaders.fadeIn:send('time', max(0, min(1, i.imageAnimateTime / i.imageAnimateSpeed)))
						lg.setShader(shaders.fadeIn)
						lg.draw(i.imageToAnimateTo, x + i.iX, y + i.iY, i.rot)
						shaders.fadeOut:send('time', max(0, min(1, i.imageAnimateTime / i.imageAnimateSpeed)))
						lg.setShader(shaders.fadeOut)
						lg.draw(i.image, x + i.iX, y + i.iY, i.rot)
						lg.setShader()
						lg.setBlendMode("alpha")
					else
						lg.draw(i.image, x + i.iX, y + i.iY, i.rot)
					end
				else
					if i.round then
						lg.setBlendMode("replace", "premultiplied")
						lg.setColor({i.color[1], i.color[2], i.color[3], i.color[4]})
						lg.rectangle("fill", x, y, i.w - i.r[3], i.h - i.r[4], i.r[1])
						lg.rectangle("fill", x, y, i.w - i.r[1], i.h - i.r[4], i.r[2])
						lg.rectangle("fill", x + i.r[1], y + i.r[2], i.w - i.r[1], i.h - i.r[2], i.r[3])
						lg.rectangle("fill", x, y + i.r[2], i.w - i.r[1], i.h - i.r[2], i.r[4])
						lg.setBlendMode("alpha")
					else
						lg.rectangle("fill", x, y, i.w, i.h)
					end
				end
			end
			-- CHECKBOX DRAW
			if i:is("checkbox") then
				lg.setColor(i.color)
				lg.setFont(i.font)
				for k,v in ipairs(i.options) do
					if v.text then
						lg.push()
						if i.border then
							if i.parent and items[i.parent] and items[i.parent].use255 then
								lg.setColor(love.math.colorFromBytes(i.borderColor))
								if v.selected then
									lg.setColor(love.math.colorFromBytes(i.selectedBorder))
								end
							else
								lg.setColor(i.borderColor)
								if v.selected then
									lg.setColor(i.selectedBorder)
								end
							end
							if i.round then
								lg.rectangle("line", v.x - 1, v.y - 1, v.w + 2, v.h + 2, i.roundRadius, i.roundRadius)
							else	
								lg.rectangle("line", v.x - 1, v.y - 1, v.w + 2, v.h + 2)
							end
						end
						if i.parent and items[i.parent] and items[i.parent].use255 then
							lg.setColor(love.math.colorFromBytes(i.color))
						else
							lg.setColor(i.color)
						end
						if i.round then
							lg.rectangle("fill", v.x, v.y, v.w, v.h, i.roundRadius, i.roundRadius)
						else
							lg.rectangle("fill", v.x, v.y, v.w, v.h)
						end
						
						if v.selected then
							lg.setColor(i.overlayColor)
							if i.round then
								lg.rectangle("fill", v.x, v.y, v.w, v.h, i.roundRadius, i.roundRadius)
							else
								lg.rectangle("fill", v.x, v.y, v.w, v.h)
							end
							lg.setColor(i.color)
						end
						lg.setColor(i.optionsColor)
						if i.border then
							lg.printf(v.text, v.x + 1, (i.paddingTop / 2) + v.y + (i.paddingBottom / 2) - 2, v.w, "center")
						else
							lg.printf(v.text, v.x, (i.paddingTop / 2) + v.y + (i.paddingBottom / 2), v.w, "center")
						end
						lg.pop()
					end
				end
				lg.setColor(i.labelColor)
				lg.setFont(i.labelFont)
				if i.shadowLabel then
					lg.setColor(0,0,0,.2)
					lg.print(i.label, i.labelPosition.x + 1, i.labelPosition.y + 1)
					lg.setColor(i.labelColor)
				end
				lg.print(i.label, i.labelPosition.x, i.labelPosition.y)
			end
			-- DROPDOWN DRAW
			if i:is("dropdown") then
				lg.setColor(i.color)
				lg.setFont(i.font)

				lg.rectangle("fill", i.pos.x, i.pos.y, i.uW, i.uH)
				if i.open then
					lg.setColor(0,0,0,.2)
					lg.rectangle("fill", i.pos.x, i.pos.y, i.uW, i.uH)
					lg.setColor(i.color)
				end
				if i.border then
					lg.setColor(i.borderColor)
					lg.rectangle("line", i.pos.x - 1, i.pos.y - 1, i.uW + 2, i.uH + 2)
				end
				lg.setColor(i.optionsColor)
				lg.setFont(i.optionFont)
				if i.selected ~= 0 then lg.print(i.options[i.selected].text, i.pos.x + i.paddingLeft, i.pos.y + i.paddingTop) end
				if i.open then
					if i.border then
						if i.fixPadding then
							lg.setColor(i.borderColor)
							lg.rectangle("line", i.pos.x, i.pos.y + i.uH + 2, i.optionPaddingLeft + i.dW + i.optionPaddingRight + 2, i.dH + 2)
							lg.setColor(i.color)
							lg.rectangle("fill", i.pos.x + 1, i.pos.y + i.uH + 3, i.optionPaddingLeft + i.dW + i.optionPaddingRight, i.dH)
						else
							lg.setColor(i.borderColor)
							lg.rectangle("line", i.pos.x, i.pos.y + i.uH + 2, i.optionPaddingLeft + i.dW + i.optionPaddingRight + 2, i.optionPaddingTop + i.dH + i.paddingBottom + 2)
							lg.setColor(i.color)
							lg.rectangle("fill", i.pos.x + 1, i.pos.y + i.uH + 3, i.optionPaddingLeft + i.dW + i.optionPaddingRight, i.optionPaddingTop + i.dH + i.paddingBottom)
						end
					else
						lg.setColor(i.color)
						if i.fixPadding then
							lg.rectangle("fill", i.pos.x, i.pos.y + i.uH, i.optionPaddingLeft + i.dW + i.optionPaddingRight, i.dH)
						else
							lg.rectangle("fill", i.pos.x, i.pos.y + i.uH, i.optionPaddingLeft + i.dW + i.optionPaddingRight, i.optionPaddingTop + i.dH + i.paddingBottom)
						end
					end
					for k,v in ipairs(i.options) do
						if v.hovered then
							lg.setColor(0,0,0,.2)
							if i.border then
								lg.rectangle("fill",v.x - (i.optionPaddingLeft / 2) + 1,v.y - i.optionPaddingTop - i.optionPaddingBottom,v.w + i.optionPaddingLeft + i.optionPaddingRight,v.h)
							else
								lg.rectangle("fill",v.x - i.optionPaddingLeft / 2,v.y,v.w + i.optionPaddingLeft + i.optionPaddingRight,v.h)
							end
						end
						lg.setColor(i.optionsColor)
						lg.setFont(i.optionFont)
						lg.print(v.text, v.x, v.y + i.optionPaddingTop)
						if k ~= #i.options then
							lg.setColor(0,0,0,.2)
							lg.line(v.x - i.optionPaddingLeft / 2, v.y + ((v.h - i.optionPaddingTop) - i.optionPaddingBottom), v.x + v.w + i.optionPaddingLeft, v.y + ((v.h - i.optionPaddingTop) - i.optionPaddingBottom))
						end
					end
				end

				lg.setColor(i.labelColor)
				lg.setFont(i.labelFont)
				lg.print(i.label, i.labelPosition.x, i.labelPosition.y)
			end
			-- SLIDER DRAW
			if i:is("slider") then
				if i.border then
					lg.setColor(i.borderColor)
					lg.rectangle("line", i.x - 1, i.y - 1, i.w + 2, i.h + 2, i.radius, i.radius)
				end
				
				lg.setColor(i.color)
				if i.image then
					lg.draw(i.image, i.x, i.y)
				else
					lg.rectangle("fill", i.x, i.y, i.w, i.h, i.radius, i.radius)
				end
				lg.setColor(i.sliderColor)
				if i.sliderImage then
					if i.border then
						lg.draw(i.sliderImage, i.sX, floor((i.y + i.h * 0.66) + 0.5))
					else
						lg.draw(i.sliderImage, i.sX, (i.y + i.h * 0.66))
					end
				else
					local size = i.size == "auto" and i.h * 0.66 or i.size 
					lg.circle("fill", i.sX, i.sY + i.h * 0.5, size)
					shaders.slider:send('inColor', i.inColor)
					shaders.slider:send('outColor', i.outColor)
					shaders.slider:send('centerX', i.sX + (i.h / 2))
					shaders.slider:send('centerY', i.sY + (i.h / 2))
					lg.setShader(shaders.slider)
					lg.circle("fill", i.sX, i.sY + i.h * 0.5, size)
					lg.setShader()
					if i.sliderBorder then
						lg.setColor(i.sliderBorderColor)
						lg.setLineWidth(2)
						lg.circle("line", i.sX, (i.sY + i.h * 0.5), size)
						lg.setLineWidth(1)
						lg.setColor(i.sliderColor)
					end
				end
				lg.setColor(1,1,1,1)
			end
			-- RADIAL DRAW
			if i:is("radial") then
				lg.setColor(i.color)
				lg.setFont(i.font)
				for k,v in ipairs(i.options) do
					if v.text then
						lg.push()
						if i.border then
							if i.parent and items[i.parent] and items[i.parent].use255 then
								lg.setColor(love.math.colorFromBytes(i.borderColor))
								if v.selected then
									lg.setColor(love.math.colorFromBytes(i.selectedBorder))
								end
							else
								lg.setColor(i.borderColor)
								if v.selected then
									lg.setColor(i.selectedBorder)
								end
							end
							lg.circle("line", v.x, v.y, i.size + 1)
						end
						if i.parent and items[i.parent] and items[i.parent].use255 then
							lg.setColor(love.math.colorFromBytes(i.color))
						else
							lg.setColor(i.color)
						end
						lg.circle("fill", v.x, v.y, i.size)
						
						if v.selected then
							lg.setColor(i.overlayColor)
							lg.circle("fill", v.x, v.y, i.size)
						end
						lg.setColor(i.optionsColor)
						lg.print(v.text, v.x + i.size + 5, v.y - (i.font:getHeight() / 2))
						lg.pop()
					end
				end
				lg.setColor(i.labelColor)
				lg.setFont(i.labelFont)
				if i.shadowLabel then
					lg.setColor(0,0,0,.2)
					lg.print(i.label, i.labelPosition.x + 1, i.labelPosition.y + 1)
					lg.setColor(i.labelColor)
				end
				lg.print(i.label, i.labelPosition.x, i.labelPosition.y)
			end
			-- TEXT DRAW
			if i:is("text") then
				lg.setColor(i.color)
				lg.setFont(i.font)
				if i.typewriter then
					if i.fancy then
						for k,v in ipairs(i.typewriterText) do
							if v.text then
								lg.push()
								lg.setColor(i.color)
								if v.color ~= "white" then
									if i.parent then
										lg.setColor(self.color(v.color))
									else
										if type(v.color) == "string" then
											lg.setColor(colors[v.color])
										else
											lg.setColor(v.color)
										end
									end
								end
								if v.font ~= "default" then
									lg.setFont(i.fonts[v.font])
								end
								if v.offset[1] then
									if i.shadow then
										lg.print({{0,0,0,.4}, v.toShow}, v.x + v.offset[1] + 1, v.y + v.offset[2] + 1)
									end
									lg.print(v.toShow, v.x + v.offset[1], v.y + v.offset[2])
								else
									if i.shadow then
										lg.print({{0,0,0,.4}, v.toShow}, v.x + 1, v.y + 1)
									end
									lg.print(v.toShow, v.x, v.y)
								end
								lg.setColor(1,1,1,1)
								lg.pop()
								if not v.finished then break end
							end
						end
					else
						if i.shadow then
							lg.print({{0,0,0,.4}, i.typewriterPrint}, i.pos.x + 1, i.pos.y + 1)
						end
						lg.print({i.color, i.typewriterPrint}, i.pos.x, i.pos.y)
					end
				else
					if i.fancy then
						for k,v in ipairs(i.typewriterText) do
							if v.fullText then
								lg.push()
								lg.setColor(i.color)
								if v.color ~= "white" then
									if i.parent then
										lg.setColor(self.color(v.color))
									else
										if type(v.color) == "string" then
											lg.setColor(colors[v.color])
										else
											lg.setColor(v.color)
										end
									end
								end
								if v.font ~= "default" then
									lg.setFont(i.fonts[v.font])
								end
								if v.offset[1] then
									if i.shadow then
										lg.print({{0,0,0,.4}, v.fullText}, v.x + v.offset[1] + 1, v.y + v.offset[2] + 1)
									end
									lg.print(v.fullText, v.x + v.offset[1], v.y + v.offset[2])
								else
									if i.shadow then
										lg.print({{0,0,0,.4}, v.fullText}, v.x + 1, v.y + 1)
									end
									lg.print(v.fullText, v.x, v.y)
								end
								lg.setColor(1,1,1,1)
								lg.pop()
							end
						end
					else
						if i.w ~= 0 then
							if i.shadow then
								lg.printf({{0,0,0,.4}, i.text}, i.pos.x + 1, i.pos.y + 1, i.w, i.align)
							end
							lg.printf({i.color, i.text}, i.pos.x, i.pos.y, i.w, i.align)
						else
							if i.shadow then
								lg.print({{0,0,0,.4}, i.text}, i.pos.x + 1, i.pos.y + 1)
							end
							lg.print({i.color, i.text}, i.pos.x, i.pos.y)
						end
					end
				end
				lg.setColor(1,1,1,1)
			end
			-- TEXTFIELD DRAW
			if i:is("textfield") then
				lg.setFont(i.font)
				lg.setColor(i.color)
				lg.rectangle("fill", i.pos.x, i.pos.y, i.w, i.h)
				if i.border then
					lg.setColor(i.borderColor)
					lg.rectangle("fill", i.pos.x - 1, i.pos.y - 1, i.w + 2, i.h + 2)
				end
				lg.setColor(i.textColor)
				for k,v in ipairs(i.display) do
					if k == 1 then
						lg.print(v, i.pos.x + 5 + i.paddingLeft, i.pos.y + 5 + i.paddingTop)
					else
						lg.print(v, i.pos.x + 5 + i.paddingLeft, i.pos.y + (5 + (i.font:getHeight() * (k - 1))))
					end
				end
				if i.active and i.showCursor then
					lg.setColor(.05,.05,.05,1)
					if i.cursorOffset == #i.display[i.currentLine] then
						lg.line(i.pos.x + i.font:getWidth(i.display[i.currentLine]) + 7,i.pos.y + (i.font:getHeight() * (i.currentLine - 1)) + 5, i.pos.x + i.font:getWidth(i.display[i.currentLine]) + 7, i.pos.y + (i.font:getHeight() * i.currentLine) + 5)
					else
						if i.maxed then
							lg.line(i.pos.x + (i.font:getWidth(i.display[i.currentLine - 1]) + 5) - i.font:getWidth(string.sub(i.display[i.currentLine - 1], 1, #i.display[i.currentLine - 1] - i.cursorOffset)),
									i.pos.y + (i.font:getHeight() * (i.currentLine - 2)) + 5,
									i.pos.x + (i.font:getWidth(i.display[i.currentLine - 1]) + 5) - i.font:getWidth(string.sub(i.display[i.currentLine - 1], 1, #i.display[i.currentLine - 1] - i.cursorOffset)),
									i.pos.y + (i.font:getHeight() * i.currentLine - 3) + 5)				
						else
							lg.line(i.pos.x + (i.font:getWidth(i.display[i.currentLine]) + 5) - i.font:getWidth(string.sub(i.display[i.currentLine], 1, #i.display[i.currentLine] - i.cursorOffset)),
									i.pos.y + (i.font:getHeight() * (i.currentLine - 1)) + 5,
									i.pos.x + (i.font:getWidth(i.display[i.currentLine]) + 5) - i.font:getWidth(string.sub(i.display[i.currentLine], 1, #i.display[i.currentLine] - i.cursorOffset)),
									i.pos.y + (i.font:getHeight() * i.currentLine) + 5)
						end
					end
				end
				lg.setColor(1,1,1,1)
			end
			-- ELEMENT SELF DRAW
			if i.draw then i:draw() end
		end
		lg.pop("all")
	end
end

function gui:child(n, i)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:child() :: Missing param[name]")
	assert(type(n) == "string" or type(n) == "number", "FAILURE: gui:child() :: Incorrect param[name] - expecting string and got " .. type(n))
	if type(n) == "string" then
		if self.items[n] then return self.items[n] end
		if not i then
			for _,v in ipairs(items) do
				if v.items[n] and type(v.items[n]) == "table" then 
					return v.items[n]
				end
			end
		end
	else
		for k,v in ipairs(items) do
			for i,e in self:sort(v.items) do
				if e.id == n then return v.items[e.name] end
			end
		end
	end
	return nil
end

function gui:children(t, i)
	if not self.enabled then return false end
	local children = {}
	if t then
		for _,g in ipairs(items) do
			if g.enabled or i then
				for _,v in self:sort(g.items) do
					if v.type == t then
						children[v.name] = v
					end
				end
			end
		end
	else
		return self.items
	end
	return children
end

function gui:getHeld()
	if not self.enabled then return false end
	return self.held
end

function gui:enableAll()
	for _,v in ipairs(items) do
		if not v.enabled then v.enabled = true end
		for _,i in self:sort(v.items) do
			if self:child(i.name).hidden then self:child(i.name).hidden = false end
		end
	end
	return self
end

function gui:enableAllElements(only)
	if only then
		for _,v in self:sort(self.items) do
			if v.hidden then v.hidden = false end
		end
	else
		for _,v in ipairs(items) do
			for _,i in self:sort(v.items) do
				if not self:child(i.name).hidden then self:child(i.name).hidden = false end
			end
		end
	end
	return self
end

function gui:disableAllElements(only)
	if only then
		for _,v in ipairs(self.items) do
			if v.hidden then v.hidden = true end
		end
	else
		for _,v in ipairs(items) do
			for _,i in self:sort(v.items) do
				if not self:child(i.name).hidden then self:child(i.name).hidden = true end
			end
		end
	end
	return self
end

-- string name, table object, func function, table target, string identifier
function gui:registerEvent(n, o, f, t, i)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:registerEvent() :: Missing param[eventName]")
	assert(type(n) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
	assert(o, "FAILURE: gui:registerEvent() :: Missing param[object]")
	assert(type(o) == "table", "FAILURE: gui:registerEvent() :: Incorrect param[object] - expecting GUI element table and got " .. type(o))
	assert(f, "FAILURE: gui:registerEvent() :: Missing param[functiom]")
	assert(type(f) == "function", "FAILURE: gui:registerEvent() :: Incorrect param[functiom] - expecting function and got " .. type(f))
	return o:registerEvent(n, f, t, i)
end

function gui:removeEvent(n, o, i)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:removeEvent() :: Missing param[eventName]")
	assert(type(n) == "string", "FAILURE: gui:removeEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
	assert(o, "FAILURE: gui:removeEvent() :: Missing param[object]")
	assert(type(o) == "table", "FAILURE: gui:removeEvent() :: Incorrect param[object] - expecting GUI element table and got " .. type(o))
	assert(i, "FAILURE: gui:removeEvent() :: Missing param[name]")
	assert(type(i) == "string", "FAILURE: gui:removeEvent() :: Incorrect param[name] - expecting string and got " .. type(i))
	return o:removeEvent(n, o, i)
end

function gui:registerGlobalEvent(n, o, f, t, i)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:registerEvent() :: Missing param[eventName]")
	assert(type(n) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
	assert(o, "FAILURE: gui:registerEvent() :: Missing param[eventType]")
	assert(type(o) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[type] - expecting string and got " .. type(o))
	assert(f, "FAILURE: gui:registerEvent() :: Missing param[name]")
	assert(type(f) == "function", "FAILURE: gui:registerEvent() :: Incorrect param[name] - expecting function and got " .. type(f))
	if not events[n] then events[n] = {} end
	local id = #events[n] + 1
	events[n][id] = {id = id, o = o, fn = f, target = t, name = i}
	return self
end

function gui:removeGlobalEvent(n, o, i)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:removeGlobalEvent() :: Missing param[eventName]")
	assert(type(n) == "string", "FAILURE: gui:removeGlobalEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
	assert(o, "FAILURE: gui:registerEvent() :: Missing param[type]")
	assert(type(o) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[type] - expecting string and got " .. type(o))
	assert(i, "FAILURE: gui:removeGlobalEvent() :: Missing param[name]")
	assert(type(i) == "string", "FAILURE: gui:removeGlobalEvent() :: Incorrect param[name] - expecting string and got " .. type(i))
	for k,e in ipairs(events[n]) do
		if e.name == i and e.o == o then
			table.remove(events[n], k)
		end
	end
	return self
end

function gui:keypressed(key, scan, isRepeat)
	if not self.enabled then return false end
	local event = {key=key, scancode=scan, isRepeat=isRepeat}
	for _,v in ipairs(items) do
		if v.enabled then
			for _,e in self:sort(v.items) do
				local i = self:child(e.name)
				if i.keypressed then i:keypressed(event) end
				-- BOX KEYPRESS
				if i:is("box") then
				
				end
				-- CHECKBOX KEYPRESS
				if i:is("checkbox") then
				
				end
				-- DROPDOWN KEYPRESS
				if i:is("dropdown") then
				
				end
				-- SLIDER KEYPRESS
				if i:is("slider") then
				
				end
				-- RADIAL KEYPRESS
				if i:is("radial") then
				
				end
				-- TEXT KEYPRESS
				if i:is("text") then
				
				end
				-- TEXTFIELD KEYPRESS
				if i:is("textfield") then
					if not i.useable then return false end
					if keyIsDown then return false end
					keyIsDown = true
					if i.active then
						local allowKey = false
						for _,v in ipairs(i.keys) do
							if v == event.key then allowKey = true end
						end
						if allowKey then
							if event.key == "backspace" then
								if i.currentLine == 1 then
									if i.display[i.currentLine] ~= "" then
										i.display[i.currentLine] = i.display[i.currentLine]:sub(1,-2)
										i.cursorOffset = i.cursorOffset - 1
									end
								else
									i.display[i.currentLine] = i.display[i.currentLine]:sub(1,-2)
									if i.display[i.currentLine] == "" or i.cursorOffset == 0 then
										i.currentLine = i.currentLine - 1
										i.cursorOffset = #i.display[i.currentLine]
									else
										i.cursorOffset = i.cursorOffset - 1
									end
								end
							elseif event.key == "return" or event.key == "enter" then
								i.currentLine = i.currentLine + 1
								if not i.display[i.currentLine] then i.display[i.currentLine] = "" end
							elseif event.key == "up" then
								if i.currentLine ~= 1 then
									i.currentLine = i.currentLine - 1
								end
							elseif event.key == "down" then
								if i.display[i.currentLine + 1] then 
									i.currentLine = i.currentLine + 1
								end
							elseif event.key == "left" then
								if i.cursorOffset >= 1 then
									i.cursorOffset = i.cursorOffset - 1
								else
									if i.currentLine ~= 1 then
										i.currentLine = i.currentLine - 1
										i.cursorOffset = #i.display[i.currentLine]
									end
								end
							elseif event.key == "right" then
								if i.cursorOffset < #i.display[i.currentLine] then
									i.cursorOffset = i.cursorOffset + 1
								else
									if i.display[i.currentLine + 1] then
										i.currentLine = i.currentLine + 1
										i.cursorOffset = 0
									end
								end
							else
								if i.maxed then return false end
								if event.key == "space" then event.key = " " end
								local foundHome = false
								local line = i.currentLine
								local tooWide = i.font:getWidth(i.display[line] .. event.key) > (i.w - (i.paddingLeft + 7)) - (i.paddingRight + 7)
								
								if tooWide then
									i.display[line] = string.sub(i.display[line], 1, i.cursorOffset) .. event.key .. string.sub(i.display[line], i.cursorOffset + 1, #i.display[line])
									while not foundHome do
										local pop = string.sub(i.display[line], #i.display[line], #i.display[line])
										if i.font:getWidth(i.display[line]) >= (i.w - (i.paddingLeft + 7)) - (i.paddingRight + 7) then
											if not i.display[line] then i.display[line] = "" end
											for k,v in ipairs(i.display) do 
												while i.font:getWidth(i.display[k]) >= (i.w - (i.paddingLeft + 7)) - (i.paddingRight + 7) do
													if not i.display[k + 1] then i.display[k + 1] = "" end
													i.display[k + 1] = pop .. i.display[k + 1]
													i.display[k] = string.sub(i.display[k], 1, #i.display[k] - 1)
												end
											end
										else
											foundHome = true
										end
									end
									if i.cursorOffset == #i.display[i.currentLine] then
										i.currentLine = i.currentLine + 1
										if i.maxLines < i.currentLine then
											i.maxed = true
											i.display[i.currentLine] = string.sub(i.display[i.currentLine], 0, #i.display[i.currentLine] - 1)
										else
											i.cursorOffset = 1
										end
									else
										if i.maxLines < #i.display then
											i.maxed = true
											i.display[#i.display] = string.sub(i.display[#i.display], 0, #i.display[#i.display] - 1)
										end
									end
								else
									i.cursorOffset = i.cursorOffset + 1
									i.display[line] = string.sub(i.display[line], 1, i.cursorOffset) .. event.key .. string.sub(i.display[line], i.cursorOffset + 1, #i.display[line])
								end
							end
						end
					end
					keyIsDown = false
				end
			end
		end
	end
end

function gui:keyreleased(key, scan)
	if not self.enabled then return false end
	local event = {key=key, scancode=scan}
	for _,v in ipairs(items) do
		if v.enabled then
			for _,i in self:sort(v.items) do
				if i.keyreleased then i:keyreleased(event) end
			end
		end
	end
end

function gui:mousemoved(x, y, dx, dy, istouch)
	if not self.enabled then return false end
	local event = {x=x, y=y, dx=dx, dy=dy, istouch=istouch}
	for _,v in ipairs(items) do 
		if v.enabled then
			for _,i in self:sort(v.items) do 
				if not i.hidden then 
					if i.mousemoved then i:mousemoved(event) end
					if i.held then
						if i.type == "text" and i.typewriter then
							for k,t in ipairs(i.typewriterText) do
								t.x = t.x + 1 * dx
								t.y = t.y + 1 * dy
							end
						end
						i.pos.x = i.pos.x + 1 * dx
						i.pos.y = i.pos.y + 1 * dy
						i.x, i.y = i.pos.x, i.pos.y
						if i.events.onMove then
							for _,e in ipairs(i.events.onMove) do
								e.fn(i, e.target, event)
							end
						end
						if events.onMove then
							for _,e in ipairs(events.onMove) do
								if i.is(e.o) then
									e.fn(i, e.target, event)
								end
							end
						end
					end
				end
			end 
		end
	end
end

function gui:mousepressed(x, y, button, istouch, presses)
	if not self.enabled then return false end
	local event = {x=x, y=y, button=button, istouch=istouch, presses=presses}
	table.sort(items, function(a,b) 
		if not a or not b then return false end
		if a.z == b.z then
			if a.id == b.id then
				return false
			else
				return a.id < b.id
			end
		else
			return a.z > b.z
		end
	end)
	local hitTarget = false
	for _,o in ipairs(items) do
		if o.enabled then
			local elements = self:sort(o.items, function(a,b) 
				if not a or not b then return false end
				if a.pos.z ~= b.pos.z then 
					return a.pos.z > b.pos.z 
				end
				if a.id ~= b.id then
					return a.id < b.id
				end
				if a.pos.x ~= b.pos.x then
					return a.pos.x > b.pos.x
				end
				if a.pos.y ~= b.pos.y then
					return a.pos.y < b.pos.y
				end
				return false
			end)
			for _,v in elements do
				local i = self:child(v.name)
				print(1, v.name)
				if self:child(v.name) and not hitTarget and i.hovered and i.clickable and not i.hidden and not i.faded then
					if i.moveable then
						i.held = true
						local heldID = #self.held + 1
						self.held[heldID] = {id = heldID, obj = i}
					end
					if i.mousepressed then i:mousepressed(event) end
					-- BOX CLICK
					if i:is("box") then
					
					end
					-- CHECKBOX CLICK
					if i:is("checkbox") then
						if button == 1 then
							local oneIsSelected = false
							for k,v in ipairs(i.options) do
								if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
									if i.single then
										for _,o in ipairs(i.options) do
											o.selected = false
										end
									end
									v.selected = not v.selected
									if i.forceOption then
										local haveSelected = false
										for _,o in ipairs(i.options) do
											if o.selected then 
												haveSelected = true 
											end
										end
										if not haveSelected then
											v.selected = true
										end
									end
									if i.events.onOptionClick then 
										for _,e in ipairs(i.events.onOptionClick) do
											e.fn(i, i.options[k], e.t, event)
										end
									end
								end
							end
						end
					end
					-- DROPDOWN CLICK
					if i:is("dropdown") then
						if button == 1 then
							if i.open then
								local hitTarget = false
								for k,v in ipairs(i.options) do
									if v.hovered then
										v.selected = k
										hitTarget = true
										if i.events.onOptionClick then 
											for _,e in ipairs(i.events.onOptionClick) do
												e.fn(i, i.options[k], e.t, event)
											end
										end
									end
								end
								if not hitTarget then
									i.open = false
								end
							else
								i.open = true
							end
						end
					end
					-- SLIDER CLICK
					if i:is("slider") then
					
					end
					-- RADIAL CLICK
					if i:is("radial") then
						if button == 1 then
							for k,v in ipairs(i.options) do
								v.selected = false
								if v.hovered then
									v.selected = true
									if i.events.onOptionClick then 
										for _,e in ipairs(i.events.onOptionClick) do
											e.fn(i, i.options[k], e.t, event)
										end
									end
								end
							end
						end
					end
					-- TEXT CLICK
					if i:is("text") then
					
					end
					-- TEXTFIELD CLICK
					if i:is("textfield") then
						if button == 1 then
							if not i.active then
								i.active = true
							end
						end
					end
					
					if button == 1 then
						if i.events.onClick then 
							for j,e in ipairs(i.events.onClick) do
								e.fn(i, e.target, event)
							end
						end
						if events.onClick then
							for _,e in ipairs(events.onClick) do
								if i:is(e.o) then
									e.fn(i, e.target, event)
								end
							end
						end
					else
						if i.events.onRightClick then 
							for j,e in ipairs(i.events.onRightClick) do
								e.fn(i, e.target, event)
							end
						end
						if events.onRightClick then
							for _,e in ipairs(events.onRightClick) do
								if i:is(e.o) then
									e.fn(i, e.target, event)
								end
							end
						end
					end
					if not i.hollow then hitTarget = true end
				end
				if i.type == "dropdown" and i.open and not i.hovered then
					local optionHit = false
					for _,v in ipairs(i.options) do
						if i.hovered then optionHit = true end
					end
					if not optionHit then i.open = false end
				end
				if i.type == "textfield" and i.active and not i.hovered then
					i.active = false
				end
			end
		end
	end
	table.sort(items, function(a,b) 
		if not a or not b then return false end
		if a.z == b.z then
			if a.id == b.id then
				return false
			else
				return a.id < b.id
			end
		else
			return a.z > b.z
		end
	end)
end

function gui:mousereleased(x, y, button, istouch, presses)
	if not self.enabled then return false end
	for _,v in ipairs(items) do
		if v.enabled then
			for _,i in self:sort(v.items) do
				if i.held then 
					i.held = false
					for k,h in ipairs(self.held) do
						if h.obj == i then
							self.held[h.id] = nil
						end
					end
				end
			end
		end
	end
end

function gui:touchmoved(id, x, y, dx, dy, pressure)
	if not self.enabled then return false end
	for _,v in ipairs(items) do 
		if v.enabled then
			for _,i in self:sort(v.items) do 
				if not i.hidden then 
					if i.touchmoved then i:touchmoved({id, x, y, dx, dy, pressure}) end
				end
			end 
		end
	end
end

function gui:touchpressed(id, x, y, dx, dy, pressure)
	if not self.enabled then return false end
	local event = {id=id, x=x, y=y, dx=dx, dy=dy, pressure=pressure}
	table.sort(items, function(a,b) 
		if not a or not b then return false end
		if a.z == b.z then
			if a.id == b.id then
				return false
			else
				return a.id < b.id
			end
		else
			return a.z > b.z
		end
	end)
	local hitTarget = false
	for _,o in ipairs(items) do
		if o.enabled then
			local elements = self:sort(o.items, function(a,b) 
				if not a or not b then return false end
				if a.pos.z == b.pos.z then
					if a.id == b.id then
						if a.pos.x == b.pos.x then
							if a.pos.y == b.pos.y then
								return false
							else
								return a.pos.y < b.pos.y
							end
						else
							return a.pos.x > b.pos.x
						end
					else
						return a.id < b.id
					end
				else
					return a.pos.z > b.pos.z
				end
			end)
			for _,i in elements do
				local v = self:child(i.name)
				if not hitTarget and v.hovered and v.clickable and not v.hidden and not v.faded then
					if v.moveable then
						v.held = true
						local heldID = #self.held + 1
						self.held[heldID] = {id = heldID, obj = i}
					end
					if v.touchpressed then i:touchpressed(event) end
					
					if v.type == "box" then
					
					end
					if v.type == "checkbox" then
						if id == 1 then
							local oneIsSelected = false
							for k,v in ipairs(v.options) do
								if x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
									if v.single then
										for _,o in ipairs(v.options) do
											o.selected = false
										end
									end
									v.selected = not v.selected
									if v.forceOption then
										local haveSelected = false
										for _,o in ipairs(v.options) do
											if o.selected then 
												haveSelected = true 
											end
										end
										if not haveSelected then
											v.selected = true
										end
									end
									if v.events.onOptionTouch then 
										for _,e in ipairs(v.events.onOptionTouch) do
											e.fn(v, v.options[k], e.t, event)
										end
									end
								end
							end
						end
					end
					if v.type == "dropdown" then
						if id == 1 then
							if v.open then
								local hitTarget = false
								for k,v in ipairs(v.options) do
									if v.hovered then
										v.selected = k
										hitTarget = true
										if v.events.onOptionTouch then 
											for _,e in ipairs(v.events.onOptionTouch) do
												e.fn(v, v.options[k], e.t, event)
											end
										end
									end
								end
								if not hitTarget then
									v.open = false
								end
							else
								v.open = true
							end
						end
					end
					if v.type == "text" then
					
					end
					if v.type == "textfield" then
						if id == 1 then
							if not v.active then
								v.active = true
							end
						end
					end
					
					if id == 1 then
						if v.events.onTouch then 
							for j,e in ipairs(v.events.onTouch) do
								e.fn(v, e.target, event)
							end
						end
						if events.onTouch then
							for _,e in ipairs(events.onTouch) do
								if e.o == v.type then
									e.fn(v, e.target, event)
								end
							end
						end
					else
						if id == 2 then
							if v.events.onDoubleTouch then 
								for j,e in ipairs(v.events.onDoubleTouch) do
									e.fn(v, e.target, event)
								end
							end
							if events.onDoubleTouch then
								for _,e in ipairs(events.onDoubleTouch) do
									if e.o == v.type then
										e.fn(v, e.target, event)
									end
								end
							end
						else
							if v.events.onMultiTouch then 
								for j,e in ipairs(v.events.onMultiTouch) do
									e.fn(v, e.target, event)
								end
							end
							if events.onMultiTouch then
								for _,e in ipairs(events.onMultiTouch) do
									if e.o == v.type then
										e.fn(v, e.target, event)
									end
								end
							end
						end
					end
					if not v.hollow then hitTarget = true end
				end
				if v.type == "dropdown" and v.open and not v.hovered then
					local optionHit = false
					for _,v in ipairs(v.options) do
						if v.hovered then optionHit = true end
					end
					if not optionHit then v.open = false end
				end
				if v.type == "textfield" and v.active and not v.hovered then
					v.active = false
				end
			end
		end
	end
	table.sort(items, function(a,b) 
		if not a or not b then return false end
		if a.z == b.z then
			if a.id == b.id then
				return false
			else
				return a.id < b.id
			end
		else
			return a.z > b.z
		end
	end)
end

function gui:hardRemove(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:hardRemove() :: Missing param[name]")
	assert(type(n) == "string" or type(n) == "number", "FAILURE: gui:hardRemove() :: Incorrect param[name] - expecting string or number and got " .. type(n))
	
	for _,v in ipairs(items) do
		for k,e in self:sort(v.items) do
			if type(n) == "number" then
				if e.id == n then
					e = nil 
					return self
				end
			else
				if e.name == n then 
					e = nil
					return self
				end
			end
		end
	end
	self.needToSort = true
	return self
end

function gui:remove(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:remove() :: Missing param[name]")
	if type(n) ~= "string" and type(n) ~= "number" then
		assert(type(n) == "string" or type(n) == "number", "FAILURE: gui:remove() :: Incorrect param[name] - expecting string or number and got " .. type(n))
	end

	if type(n) == "string" then
		self.items[n] = nil
	else
		for k,t in self:sort(self.items) do
			if t.id == n then 
				t = nil
				return self
			end
		end
	end
	self.needToSort = true
	return self
end

function gui:setZ(z)
	if not self.enabled then return false end
	assert(z, "FAILURE: gui:setZ() :: Missing param[z]")
	assert(type(z) == "number", "FAILURE: gui:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
	self.z = z
	self.needToSort = true
	return self
end

function gui:getZ()
	return self.z
end

function gui:dist(x1,y1,x2,y2)
	sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function gui:sort(t, f)
	local a = {}
	local v = {}
	
	for k,e in pairs(t) do 
		table.insert(a, k) 
		table.insert(v, e)
	end
	if f then
		table.sort(v, f)
	end
	local i = 0 
	local iter = function ()
		i = i + 1
		
		if a[i] == nil then 
			return nil
		else 
			return a[i], v[i]
		end
	end
	return iter
end

return gui