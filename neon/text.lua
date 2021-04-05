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
local prefixes = {
	color = "c",
	delay = "d",
	font = "f",
	time = "t",
	offset = "o",
}

local text = {}

local guis = {}
text.fonts = {}

function text:new(n, id, p)
	local t = element()
	t.__index = text
	t.name = n
	t.id = id
	t.type = "text"
	if p then 
		if not guis[p.id] then guis[p.id] = p end
		if p.id then t.parent = p else t.parent = nil end
	end
	t.font = lg.getFont()
	t.fonts = {}
	t.fancy = false
	t.shadow = false
	t.align = "center"
	t.text = ""
	t.typewriter = false
	t.typewriterText = {}
	t.typewriterPrint = ""
	t.typewriterPos = 1
	t.typewriterSpeed = 0
	t.typewriterWaited = 0
	t.typewriterFinished = false
	t.typewriterPaused = false
	t.typewriterStopped = false
	t.typewriterRepeat = false
	t.typewriterRunCount = 0
	
	return setmetatable(t, t)
end

function text:addFont(f, n)
	assert(f, "[" .. self.name .. "] FAILURE: text:addFont() :: Missing param[font]")
	assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: text:addFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
	assert(n, "[" .. self.name .. "] FAILURE: text:addFont() :: Missing param[name]")
	assert(type(n) == "string", "[" .. self.name .. "] FAILURE: text:addFont() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.fonts[n] = f
	return self
end

function text:setFont(n)
	assert(n, "[" .. self.name .. "] FAILURE: text:setFont() :: Missing param[name]")
	assert(type(n) == "string", "[" .. self.name .. "] FAILURE: text:setFont() :: Incorrect param[name] - expecting string and got " .. type(n))
	self.font = self.fonts[n]
	return self
end

function text:getFont()
	return self.font
end

function text:setTypewriterSpeed(s)
	assert(s, "[" .. self.name .. "] FAILURE: text:setTypewriterSpeed() :: Missing param[speed]")
	assert(type(s) == "number", "[" .. self.name .. "] FAILURE: text:setTypewriterSpeed() :: Incorrect param[speed] - expecting number and got " .. type(s))
	self.typewriterSpeed = n
	return self
end

function text:getTypewriterSpeed()
	return self.typewriterSpeed
end

function text:typewriterCycle()
	self.typewriterWaited = 0
	self.typewriterPos = 1
	self.typewriterPrint = ""
	self.typewriterFinished = false
	self.typewriterStopped = false
	self.typewriterPaused = false
	return self
end

function text:setText(txt)
	assert(txt ~= nil, "[" .. self.name .. "] FAILURE: text:setText() :: Missing param[text]")
	assert(type(txt) == "string", "[" .. self.name .. "] FAILURE: text:setText() :: Incorrect param[text] - expecting string and got " .. type(txt))
	self.text = txt
	self.typewriterText, self.fancy = self:split(txt)
	return self
end

function text:getText()
	return self.text
end

function text:setAsTypewriter(aT)
	assert(aT ~= nil, "[" .. self.name .. "] FAILURE: text:setAsTypewriter() :: Missing param[useBorder]")
	assert(type(aT) == "boolean", "[" .. self.name .. "] FAILURE: text:setAsTypewriter() :: Incorrect param[useBorder] - expecting boolean and got " .. type(aT))
	self.typewriter = aT
	return self
end

function text:isTypewriter()
	return self.typewriter
end

function text:split()
	if not self.text then return {} end
	local s = self.text
	local d={}
	local f = false
	if s:match("{") and s:match("}") then
		f = true
		for b in s:gmatch(".-{") do
			local id = #d + 1
			d[id] = {}
			d[id].text = {}
			d[id].offset = {}
			d[id].color = "white"
			d[id].delay = 0
			d[id].delayWaited = 0
			d[id].needToWait = false
			d[id].font = "default"
			d[id].time = 0.5
			d[id].started = false
			d[id].finished = false
			d[id].textPos = 0
			d[id].timeWaited = 0
			d[id].x = 0
			d[id].oX = 0
			d[id].tX = 0
			d[id].y = 0
			d[id].oY = 0
			d[id].tY = 0
			d[id].toShow = ""
			d[id].fullText = ""
			if b:match("}") then
				for o in b:gmatch(".-}") do
					local k = o:gsub("}","")
					for m in k:gmatch("([^,]+)") do
						local prefix = m:sub(1,1)
						if prefix == prefixes.color then
							d[id].color = m:gsub("^" .. prefixes.color .. "=", "")
						end
						if prefix == prefixes.delay then
							d[id].delay = tonumber((m:gsub("^" .. prefixes.delay .. "=", "")))
							d[id].needToWait = true
						end
						if prefix == prefixes.font then
							d[id].font = m:gsub("^" .. prefixes.font .. "=", "")
						end
						if prefix == prefixes.time then
							d[id].time = tonumber((m:gsub("^" .. prefixes.time .. "=", "")))
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
								d[id].offset = offsets
							end
						end
					end
				end
				d[id].fullText = b:gsub("^.-}",""):gsub("{",""):gsub("^%s*(.-)%s*$","%1")
			else
				d[id].fullText = b:gsub("{", "")
			end
			for i in d[id].fullText:gmatch(".") do
				d[id].text[#d[id].text + 1] = i
			end
		end
	else
		for i in string.gmatch(s, ".") do
			d[#d+1] = i
		end
	end
	return d, f
end

return setmetatable(text, text)