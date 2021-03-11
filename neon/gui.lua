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



local box = require("gui.box")
local checkbox = require("gui.checkbox")
local dropdown = require("gui.dropdown")
local text = require("gui.text")
local textfield = require("gui.textfield")
local radial = require("gui.radial")
local slider = require("gui.slider")
local lg, lt = love.graphics, love.timer
local min, max = math.min, math.max

local gui = {}
local events = {}
local items = {}

local colors = {
	red = {1,0,0,1},
	green = {0,1,0,1},
	blue = {0,0,1,1},
	yellow = {1,1,0,1},
	purple = {1,0,1,1}
}

gui.items = {}
gui.z = 0
gui.use255 = false
gui.id = 1
gui.enabled = true
gui.held = {}
gui.images = {}


function gui.color(c)
	assert(c, "FAILURE: gui:color() :: Missing param[name]")
	assert(type(c) == "string", "FAILURE: gui:color() :: Incorrect param[name] - expecting string and got " .. type(c))
	return gui:copy(colors[c])
end

function gui:new(item)
	if not self.enabled then return false end
	item = item or self
	local new = self:generate(item)
	new.id = #items
	items[#items + 1] = new
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
		return self:child(i)
	else
		for _,v in ipairs(items) do
			for k,t in ipairs(v.items) do
				if t.id == i then
					return t
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
	o.colorAnimateTime = lt.getTime()
	o.inAnimation = true
	o.animateColor = true
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
	o.borderColorAnimateTime = lt.getTime()
	o.inAnimation = true
	o.animateBorderColor = true
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
	o.positionAnimateTime = lt.getTime()
	o.inAnimation = true
	o.animatePosition = true
end

function gui:animateToOpacity(obj, o, s)
	if not self.enabled then return false end
	assert(obj, "FAILURE: gui:animateToColor() :: Missing param[object]")
	assert(type(obj) == "table", "FAILURE: gui:animateToColor() :: Incorrect param[object] - expecting table and got " .. type(obj))
	assert(o, "FAILURE: gui:animateToOpacity() :: Missing param[o]")
	assert(type(o) == "number", "FAILURE: gui:animateToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
	s = s or 1
	assert(type(s) == "number", "FAILURE: gui:animateToOpacity() :: Incorrect param[s] - expecting number and got " .. type(s))
	obj.opacityToAnimateTo = o
	obj.opacityAnimateTime = lt.getTime()
	obj.opacityAnimateSpeed = s
	obj.inAnimation = true
	obj.animateOpacity = true
end

function gui:addColor(c, n)
	if not self.enabled then return false end
	assert(c, "FAILURE: gui:addColor() :: Missing param[color]")
	assert(type(c) == "table", "FAILURE: gui:addColor() :: Incorrect param[color] - expecting table and got " .. type(c))
	assert(#c > 2, "FAILURE : gui:addColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
	assert(n, "FAILURE: gui:addColor() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addColor() :: Incorrect param[name] - expecting string and got " .. type(n))
	colors[n] = c
end

function gui:addBox(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addBox() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addBox() :: Incorrect param[name] - expecting string and got " .. type(n))
	local id = #self.items + 1
	self.items[id] = box:new(n, self)
	return self.items[id]
end

function gui:addCheckbox(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addCheckbox() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addCheckbox() :: Incorrect param[name] - expecting string and got " .. type(n))
	local id = #self.items + 1
	self.items[id] = checkbox:new(n, self)
	return self.items[id]
end

function gui:addDropdown(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addDropdown() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addDropdown() :: Incorrect param[name] - expecting string and got " .. type(n))
	local id = #self.items + 1
	self.items[id] = dropdown:new(n, self)
	return self.items[id]
end

function gui:addImage(i, n)
	if not self.enabled then return false end
	assert(i, "FAILURE: gui:addImage() :: Missing param[img]")
	assert(type(i) == "userdata", "FAILURE: gui:addImage() :: Incorrect param[img] - expecting image userdata and got " .. type(i))
	assert(n, "FAILURE gui:addImage() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addImage() :: Incorrect param[img] - expecting string and got " .. type(n))
	self.images[n] = i
end

function gui:addTextfield(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addTextfield() :: Missing param[name]")
	assert(type(n) == "FAILURE: gui:addTextfield() :: Incorrect param[name] - expecting string and got " .. type(n))
	local id = #self.items + 1
	self.items[id] = textfield:new(n, self)
	return self.items[id]
end

function gui:addRadial(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addRadial() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addRadial() :: Incorrect param[name] - expecting string and got " .. type(n))
	local id = #self.items + 1
	self.items[id] = radial:new(n, self)
	return self.items[id]
end

function gui:addText(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:addText() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:addText() :: Incorrect param[name] - expecting string and got " .. type(n))
	local id = #self.items + 1
	self.items[id] = text:new(n, self)
	return self.items[id]
end

function gui:update(dt)
	if not self.enabled then return false end
	for _,v in ipairs(items) do 
		if v.enabled then
			for _,i in ipairs(v.items) do 
				if not i.hidden then 
					local x,y = love.mouse.getPosition()
					local hover = (x >= i.pos.x + i.paddingLeft and x <= i.pos.x + i.w + i.paddingRight) and (y >= i.pos.y + i.paddingTop and y <= i.pos.y + i.h + i.paddingBottom)
					if i.type == "text" then
						hover = (x >= i.pos.x and x <= i.pos.x + i.w) and (y >= i.pos.y and y <= i.pos.y + i.h)
					elseif i.type == "dropdown" then
						if i.border then
							hover = i.open and (x >= i.pos.x and x <= i.pos.x + i.dW + i.optionPaddingLeft + i.optionPaddingRight + 2 and y >= i.pos.y and y <= i.pos.y + i.h + i.dH) or (x >= i.pos.x and x <= i.pos.x + i.w and y >= i.pos.y and y <= i.pos.y + i.h)
						else
							hover = i.open and (x >= i.pos.x and x <= i.pos.x + i.dW + i.optionPaddingLeft + i.optionPaddingRight and y >= i.pos.y and y <= i.pos.y + i.h + i.dH) or (x >= i.pos.x and x <= i.pos.x + i.w and y >= i.pos.y and y <= i.pos.y + i.h)
						end
					end
					if hover then
						if i.hovered then
							if i.events.whileHovering then 
								for _,v in ipairs(i.events.whileHovering) do	
									v.f(i, v.t)
								end
							end
						end
						if not i.hovered then
							if i.events.onHoverEnter then 
								for _,v in ipairs(i.events.onHoverEnter) do	
									v.f(i, v.t)
								end
							end
							i.hovered = true 
						end
					else
						if i.hovered then 
							if i.events.onHoverExit then 
								for _,v in ipairs(i.events.onHoverExit) do	
									v.f(i, v.t)
								end
							end
							i.hovered = false 
						end
					end
					
					if i:isAnimating() then
						local allColorsMatch = true
						local allBorderColorsMatch = true
						local inProperPosition = true
						local atProperOpacity = true
						
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
						
						if i.animatePosition then
							local t = math.min((lt.getTime() - i.positionAnimateTime) * (i.positionAnimateSpeed / 2), 1.0)
							if i.pos.x ~= i.positionToAnimateTo.x or i.pos.y ~= i.positionToAnimateTo.y then
								i.pos.x = i.lerp(i.positionToAnimateFrom.x, i.positionToAnimateTo.x, t)
								i.pos.y = i.lerp(i.positionToAnimateFrom.y, i.positionToAnimateTo.y, t)
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
										if i.afterFadeIn then i:afterFadeIn() end
									elseif i.color[4] == 0 then
										if i.afterFadeOut then i:afterFadeOut() end
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
						
						if allColorsMatch and inProperPosition and atProperOpacity and allBorderColorsMatch then
							i.inAnimation = false
							i.animateColor = false
							i.animatePosition = false
							if i.animateOpacity and i.faded then i.hidden = true end
							i.animateOpacity = false
						end
					end
					i:update(dt)
				end
			end 
		end
	end
end

function gui:enable()
	self.enabled = true
end

function gui:disable()
	self.enabled = false
end

function gui:draw()
	if not self.enabled then return false end
	table.sort(items, function(a, b) return a.z < b.z end)
	for _,v in ipairs(items) do
		if v.enabled then
			table.sort(v.items, function(a, b) return a.pos.z < b.pos.z end)
			for _,i in ipairs(v.items) do 
				if not i.hidden then i:draw(dt) end
			end
		end
	end
end

function gui:child(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:child() :: Missing param[name]")
	assert(type(n) == "string", "FAILURE: gui:child() :: Incorrect param[name] - expecting string and got " .. type(n))
	for _,g in ipairs(items) do
		if g.enabled then
			for _,v in ipairs(g.items) do
				if v.name == n then return v end
			end
		end
	end
	return nil
end

function gui:getHeld()
	if not self.enabled then return false end
	return self.held
end

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
	assert(o, "FAILURE: gui:registerEvent() :: Missing param[type]")
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
end

function gui:mousemoved(x, y, dx, dy, istouch)
	if not self.enabled then return false end
	local event = {x=x, y=y, dx=dx, dy=dy, istouch=istouch}
	for _,v in ipairs(items) do 
		if v.enabled then
			for _,i in ipairs(v.items) do 
				if not i.hidden then 
					if i.mousemoved then i:mousemoved({x, y, dx, dy, istouch}) end
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
					end
				end
			end 
		end
	end
end

function gui:mousepressed(x, y, button, istouch, presses)
	if not self.enabled then return false end
	local event = {x=x, y=y, button=button, istouch=istouch, presses=presses}
	local objs = self:copy(items)
	table.sort(objs, function(a, b) return a.z > b.z end)
	local hitTarget = false
	for _,o in ipairs(objs) do
		if o.enabled then
			local obj = self:copy(o)
			table.sort(obj.items, function(a,b) return a.pos.z == b.pos.z and (a.id < b.id) or a.pos.z > b.pos.z end)
			for k,v in ipairs(obj.items) do
				local i = self:child(v.name)
				if not hitTarget and i.hovered and i.clickable and not i.hidden and not i.faded then
					if i.moveable then
						i.held = true
						local heldID = #self.held + 1
						self.held[heldID] = {id = heldID, obj = i}
					end
					if i.mousepressed then i:mousepressed(event) end
					if i.events.onClick then 
						for j,e in ipairs(i.events.onClick) do
							e.fn(i, e.target, event)
						end
					end
					if events.onClick then
						for _,e in ipairs(events.onClick) do
							if e.o == i.type then
								e.fn(i, e.target, event)
							end
						end
					end
					if not i.hollow then hitTarget = true end
				end
				if i.type == "dropdown" and i.open and not i.hovered then
					local optionHit = false
					for k,v in ipairs(i.options) do
						if v.hovered then optionHit = true end
					end
					if not optionHit then i.open = false end
				end
			end
			obj = nil
		end
	end
	objs = nil
end

function gui:mousereleased(x, y, button, istouch, presses)
	if not self.enabled then return false end
	for _,v in ipairs(items) do
		if v.enabled then
			for _,i in ipairs(v.items) do
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
			for _,i in ipairs(v.items) do 
				if not i.hidden then 
					if i.touchmoved then i:touchmoved({id, x, y, dx, dy, pressure}) end
				end
			end 
		end
	end
end

function gui:touchpressed(event)
	if not self.enabled then return false end
	local objs = self:copy(items)
	table.sort(objs, function(a, b) return a.z > b.z end)
	local hitTarget = false
	for _,o in ipairs(objs) do
		if o.enabled then
			local obj = self:copy(o)
			table.sort(obj.items, function(a,b) return a.pos.z == b.pos.z and (a.id < b.id) or a.pos.z > b.pos.z end)
			for k,v in ipairs(obj.items) do
				local i = self:child(v.name)
				if not hitTarget and i.hovered and i.clickable and not i.hidden and not i.faded then
					if i.touchpressed then i:touchpressed(event) end
					if i.events.onTouch then 
						for j,e in ipairs(i.events.onTouch) do
							e.fn(e.target, event)
						end
					end
					if events.onTouch then
						for j,e in ipairs(events.onTouch) do
							if e.o == i.type then
								e.fn(i, e.target, event)
							end
						end
					end
					if not i.hollow then hitTarget = true end
				end
			end
			obj = nil
		end
	end
	objs = nil
end

function gui:hardRemove(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:remove() :: Missing param[name]")
	if type(n) ~= "string" and type(n) ~= "number" then
		assert(type(n) == "string" or type(n) == "number", "FAILURE: gui:remove() :: Incorrect param[name] - expecting string or number and got " .. type(n))
	end
	
	for _,v in ipairs(items) do
		for _,e in ipairs(v.items) do
			if type(n) == "number" then
				if e.id == n then 
					e = nil 
					return
				end
			else
				if e.name == n then 
					e = nil
					return
				end
			end
		end
	end
end

function gui:remove(n)
	if not self.enabled then return false end
	assert(n, "FAILURE: gui:remove() :: Missing param[name]")
	if type(n) ~= "string" and type(n) ~= "number" then
		assert(type(n) == "string" or type(n) == "number", "FAILURE: gui:remove() :: Incorrect param[name] - expecting string or number and got " .. type(n))
	end
	
	if type(n) == "string" then
		for k,t in ipairs(self.items) do
			if t.name == n then 
				self.items[k] = nil
				return
			end
		end
	else
		self.items[n] = nil
	end
end

function gui:setZ(z)
	if not self.enabled then return false end
	assert(z, "FAILURE: gui:setZ() :: Missing param[z]")
	assert(type(z) == "number", "FAILURE: gui:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
	self.z = z
end

return gui