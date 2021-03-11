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
local text = {}

local prefixes = {
	color = "c",
	delay = "d",
	font = "f",
	time = "t",
	offset = "o",
}


text.items = {}
text.guis = {}
text.fonts = {}

function text:new(n, p)
	local t = {}
	if p and p.id and not self.guis[p.id] then self.guis[p.id] = p end
	t.name = n
	t.id = #self.items + 1
	t.type = "text"
	if p and p.id then t.parent = p.id else t.parent = nil end
	t.text = ""
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
	t.timerEvent = nil
	t.color = {1,1,1,1}
	t.font = love.graphics.getFont()
	t.fonts = {}
	t.hovered = false
	t.clicked = false
	t.hidden = false
	t.hollow = false
	t.clickable = true
	t.faded = false
	t.fadedByFunc = false
	t.fancy = false
	t.moveable = false
	t.held = false
	t.events = {}
	t.paddingLeft = 0
	t.paddingRight = 0
	t.paddingTop = 0
	t.paddingBottom = 0
	t.typewriter = false
	t.typewriterPrint = ""
	t.typewriterText = self:split(t.text)
	t.typewriterPos = 1
	t.typewriterSpeed = 0
	t.typewriterWaited = 0
	t.typewriterFinished = false
	t.typewriterPaused = false
	t.typewriterStopped = false
	t.typewriterRepeat = false
	t.typewriterRunCount = 0
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
		assert(c, "[" .. self.name .. "] FAILURE: text:animateToColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: text:animateToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c == 4, "[" .. self.name .. "] FAILURE: text:animateToColor() :: Incorrect param[color] - table length 4 expected and got " .. #c)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: text:animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.colorToAnimateTo = c
		self.colorAnimateSpeed = s
		self.colorAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animateColor = true
	end
	
	function t:animateToPosition(x, y, s)
		assert(x, "[" .. self.name .. "] FAILURE: text:animateToPosition() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: text:animateToPosition() :: Incorrect param[x] - expecting number and got " .. type(x))
		assert(y, "[" .. self.name .. "] FAILURE: text:animateToPosition() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: text:animateToPosition() :: Incorrect param[y] - expecting number and got " .. type(y))
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: text:animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
		for k,v in pairs(self.pos) do self.positionToAnimateFrom[k] = v end
		self.positionToAnimateTo = {x = x, y = y}
		self.positionAnimateDrag = s
		self.positionAnimateTime = lt.getTime()
		self.inAnimation = true
		self.animatePosition = true
	end
	
	function t:animateToOpacity(o, s)
		assert(o, "[" .. self.name .. "] FAILURE: text:animateToOpacity() :: Missing param[o]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: text:animateToOpacity() :: Incorrect param[o] - expecting number and got " .. type(o))
		s = s or 1
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: text:animateToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
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
		assert(c ~= nil, "[" .. self.name .. "] FAILURE: text:setClickable() :: Missing param[clickable]")
		assert(type(c) == "boolean", "[" .. self.name .. "] FAILURE: text:setClickable() :: Incorrect param[clickable] - expecting boolean and got " .. type(c))
		self.clickable = c
	end
	
	function t:isClickable()
		return self.clickable
	end
	
	function t:setColor(c)
		assert(c, "[" .. self.name .. "] FAILURE: text:setColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: text:setColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c == 4, "[" .. self.name .. "] FAILURE: text:setColor() :: Incorrect param[color] - table length 4 expected and got " .. #c)
		self.color = c
	end
	
	function t:getColor()
		return self.color
	end
	
	function t:setData(d)
		assert(d, "[" .. self.name .. "] FAILURE: text:setData() :: Missing param[data]")
		assert(type(d) == "table", "[" .. self.name .. "] FAILURE: text:setData() :: Incorrect param[data] - expecting table and got " .. type(d))
		assert(d.t or d.text, "[" .. self.name .. "] FAILURE: text:setData() :: Missing param[data['text']")
		assert(type(d.text) == "string", "[" .. self.name .. "] FAILURE: text:setData() :: Incorrect param[text] - expecting string and got " .. type(d.text))
		assert(d.x, "[" .. self.name .. "] FAILURE: text:setData() :: Missing param[data['x']")
		assert(type(d.x) == "number", "[" .. self.name .. "] FAILURE: text:setData() :: Incorrect param[x] - expecting number and got " .. type(d.x))
		assert(d.y, "[" .. self.name .. "] FAILURE: text:setData() :: Missing param[data['y']")
		assert(type(d.y) == "number", "[" .. self.name .. "] FAILURE: text:setData() :: Incorrect param[y] - expecting number and got " .. type(d.y))
		self.text = d.t or d.text or self.text
		self.typewriterText, self.fancy = text:split(self.text)
		self.typewriter = d.tw and d.tw or d.typewriter and d.typewriter or self.typewriter
		self.typewriterRepeat = d.r and d.r or d.tRepeat and d.tRepeat or self.typewriterRepeat
		self.pos.x = d.x or self.pos.x
		self.pos.y = d.y or self.pos.y
		self.typewriterSpeed = d.s or d.speed or self.typewriterSpeed
		self.pos.z = d.z or self.pos.z
		self.color = d.color or self.color
		self.font = d.font or self.font
		self.w = d.w or d.width or self.font:getWidth(self.text)
		self.h = d.h or d.height or self.font:getHeight(self.text)
		if d.fonts then
			for k,v in pairs(d.fonts) do
				self.fonts[k] = v
			end
		end
		if self.typewriter then
			local font = self.font
			local lastFont = self.font
			for k,v in ipairs(self.typewriterText) do
				lastFont = font
				if v.font ~= "default" then
					font = self.fonts[v.font]
				else
					font = self.font
				end
				
				if not v.y then
					v.y = self.pos.y
				end
				
				if not v.x then
					if k == 1 then
						v.x = self.pos.x
					else
						v.x = self.typewriterText[k - 1].x + lastFont:getWidth(self.typewriterText[k - 1].fullText)
						if v.x > self.pos.x + (self.w - font:getWidth(v.fullText)) then
							v.x = self.pos.x
							v.y = self.typewriterText[k - 1].y + lastFont:getHeight(self.typewriterText[k - 1].fullText) 
							self.h = self.h + font:getHeight(v.fullText)
						end
					end
				end
				
				if v.x == self.pos.x then
					self.w = math.max(self.w, font:getWidth(v.fullText))
				else
					self.w = self.w + font:getWidth(v.fullText)
				end
				
				if v.y == self.pos.y then
					self.h = math.max(self.h, font:getHeight(v.fullText))
				else
					self.h = self.h + font:getHeight(v.fullText)
				end
			end
		end
		self.clickable = d.clickable and d.clickable or self.clickable
		self.moveable = d.moveable and d.moveable or self.moveable
		self.hollow = d.hollow and d.hollow or self.hollow
		return self
	end
	
	function t:disable()
		self.hidden = true
	end
	
	function t:draw()
		lg.push()		
		lg.setFont(self.font)
		if self.typewriter then
			if self.fancy then
				for k,v in ipairs(self.typewriterText) do
					if v.text then
						lg.push()
						lg.setColor(self.color)
						if v.color ~= "white" then
							if self.parent then
								lg.setColor(text.guis[self.parent].color(v.color))
							else
								lg.setColor(v.color)
							end
						end
						if v.font ~= "default" then
							lg.setFont(self.fonts[v.font])
						end
						if v.offset[1] then
							lg.print(v.toShow, v.x + v.offset[1], v.y + v.offset[2])
						else
							lg.print(v.toShow, v.x, v.y)
						end
						lg.setColor(1,1,1,1)
						lg.pop()
						if not v.finished then break end
					end
				end
			else
				lg.print({self.color, self.typewriterPrint}, self.pos.x, self.pos.y)
			end
		else
			lg.print({self.color, self.text}, self.pos.x, self.pos.y)
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
		assert(f, "[" .. self.name .. "] FAILURE: text:addFont() :: Missing param[font]")
		assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: text:addFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		assert(n, "[" .. self.name .. "] FAILURE: text:addFont() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: text:addFont() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.fonts[n] = f
	end
	
	function t:setFont(n)
		assert(n, "[" .. self.name .. "] FAILURE: text:setFont() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: text:setFont() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.font = self.fonts[n]
	end
	
	function t:isHovered()
		return self.hovered
	end
	
	function t:setHollow(h)
		assert(h ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Missing param[hollow]")
		assert(type(h) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Incorrect param[hollow] - expecting boolean and got " .. type(h))
		self.hollow = h
	end
	
	function t:isHollow()
		return self.hollow
	end
	
	function t:setTypewriterSpeed(s)
		assert(s, "[" .. self.name .. "] FAILURE: text:setTypewriterSpeed() :: Missing param[speed]")
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: text:setTypewriterSpeed() :: Incorrect param[speed] - expecting number and got " .. type(s))
		self.typewriterSpeed = n
	end
	
	function t:getTypewriterSpeed()
		return self.typewriterSpeed
	end
	
	function t:startAnimation()
		self.inAnimation = true
	end
	
	function t:stopAnimation()
		self.inAnimation = false
	end
	
	function t:update(dt)		
		if self.typewriter then
			self.typewriterWaited = self.typewriterWaited + dt
			if self.fancy then
				for k,v in ipairs(self.typewriterText) do
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
									v.toShow = v.toShow .. v.text[v.textPos]
								end
								if v.textPos >= #v.text then
									v.finished = true
								end
							end
						end
						if not v.finished then break end
						if k == #self.typewriterText then
							if self.events.onTypewriterFinish then
								for _,e in ipairs(self.events.onTypewriterFinish) do
									e.fn(self, e.target)
								end
							end
							if self.typewriterRepeat then
								for _,e in ipairs(self.typewriterText) do
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
				while self.typewriterWaited >= self.typewriterSpeed and self.typewriterPos <= #self.typewriterText do
					self.typewriterWaited = self.typewriterWaited - self.typewriterSpeed
					self.typewriterPrint = self.typewriterPrint .. self.typewriterText[self.typewriterPos]
					self.typewriterPos = self.typewriterPos + 1
				end
				if self.typewriterPos >= #self.typewriterText and not self.typewriterFinished then
					if not self.typewriterRepeat then self.typewriterFinished = true else self:typewriterCycle() end
					self.typewriterRunCount = self.typewriterRunCount + 1
				end
			end
		end
	end
	
	function t:setOpacity(o)
		assert(o, "[" .. self.name .. "] FAILURE: text:setUseBorder() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: text:setUseBorder() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		self.color[4] = o
	end
	
	function t:getOpacity()
		return self.color[4]
	end
	
	function t:getParent()
		return text.guis[self.parent]
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
	
	function t:typewriterCycle()
		self.typewriterWaited = 0
		self.typewriterPos = 1
		self.typewriterPrint = ""
		self.typewriterFinished = false
		self.typewriterStopped = false
		self.typewriterPaused = false
	end
	
	function t:setText(txt)
		assert(txt ~= nil, "[" .. self.name .. "] FAILURE: text:setText() :: Missing param[text]")
		assert(type(txt) == "string", "[" .. self.name .. "] FAILURE: text:setText() :: Incorrect param[text] - expecting boolean and got " .. type(txt))
		self.text = text
		self.typewriterText, self.fancy = text:split(txt)
	end
	
	function t:getText()
		return self.text
	end
	
	function t:setAsTypewriter(aT)
		assert(aT ~= nil, "[" .. self.name .. "] FAILURE: text:setAsTypewriter() :: Missing param[useBorder]")
		assert(type(aT) == "boolean", "[" .. self.name .. "] FAILURE: text:setAsTypewriter() :: Incorrect param[useBorder] - expecting boolean and got " .. type(aT))
		self.typewriter = aT
	end
	
	function t:isTypewriter()
		return self.typewriter
	end
	
	function t:setX(x)
		assert(x, "[" .. self.name .. "] FAILURE: text:setX() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: text:setX() :: Incorrect param[x] - expecting number and got " .. type(x))
		self.pos.x = x
	end
	
	function t:getX()
		return self.pos.x
	end
	
	function t:setY(y)
		assert(y, "[" .. self.name .. "] FAILURE: text:setY() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: text:setY() :: Incorrect param[y] - expecting number and got " .. type(y))
		self.pos.y = y
	end
	
	function t:getY()
		return self.pos.y
	end
	
	function t:setZ(z)
		assert(z, "[" .. self.name .. "] FAILURE: text:setZ() :: Missing param[z]")
		assert(type(z) == "number", "[" .. self.name .. "] FAILURE: text:setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
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

function text:split(s)
	local t={}
	local f = false
	if s:match("{") and s:match("}") then
		f = true
		for b in s:gmatch(".-{") do
			local id = #t + 1
			t[id] = {}
			t[id].text = {}
			t[id].offset = {}
			t[id].color = "white"
			t[id].delay = 0
			t[id].delayWaited = 0
			t[id].needToWait = false
			t[id].font = "default"
			t[id].time = 0.5
			t[id].started = false
			t[id].finished = false
			t[id].textPos = 0
			t[id].timeWaited = 0
			t[id].toShow = ""
			if b:match("}") then
				for o in b:gmatch(".-}") do
					local d = o:gsub("}","")
					for m in d:gmatch("([^,]+)") do
						local prefix = m:sub(1,1)
						if prefix == prefixes.color then
							t[id].color = m:gsub("^" .. prefixes.color .. "=", "")
						end
						if prefix == prefixes.delay then
							t[id].delay = tonumber((m:gsub("^" .. prefixes.delay .. "=", "")))
							t[id].needToWait = true
						end
						if prefix == prefixes.font then
							t[id].font = m:gsub("^" .. prefixes.font .. "=", "")
						end
						if prefix == prefixes.time then
							t[id].time = tonumber((m:gsub("^" .. prefixes.time .. "=", "")))
						end
						if prefix == prefixes.offset then
							local offsets = {}
							local o = m:gsub("^" .. prefixes.offset .. "=","")
							if o:match("%(") and o:match("%)") then
								o = o:gsub("%(",""):gsub("%)","")
								for i in o:gmatch("-?[^%.]+") do
									if i ~= "%." then
										offsets[#offsets + 1] = tonumber(i) 
									end
								end
								t[id].offset = offsets
								print(offsets[1], offsets[2])
							end
						end
					end
				end
				t[id].fullText = b:gsub("^.-}",""):gsub("{",""):gsub("^%s*(.-)%s*$","%1")
			else
				t[id].fullText = b:gsub("{", "")
			end
			for i in t[id].fullText:gmatch(".") do
				t[id].text[#t[id].text + 1] = i
			end
		end
	else
		for i in string.gmatch(s, ".") do
			t[#t+1] = i
		end
	end
	return t, f
end

return text