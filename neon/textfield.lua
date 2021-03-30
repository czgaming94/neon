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

local textfield = {}

textfield.guis = {}
textfield.fonts = {}

function textfield:new(n, id, p)
	local t = {}
	setmetatable(t, object())
	t.name = n
	t.id = id
	t.type = "textfield"
	if p then 
		if not self.guis[p.id] then self.guis[p.id] = p end
		if p.id then t.parent = p.id else t.parent = nil end
	end
	t.textfield = ""
	t.keys = {
		"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","space",
		"1","2","3","4","5","6","7","8","9","0",",",".","/",";","'","[","]","`","-","=","\"","\\","!","@","#","$",
		"%","^","&","*","(",")","{","}",":","<",">","?","~","backspace","return","enter","up","down","left","right"
	}
	t.textColor = {1,1,1,1}
	t.placeholder = ""
	t.display = {""}
	t.currentLine = 1
	t.showCursor = true
	t.keyDown = false
	t.cursorTime = 0
	t.cursorOffset = 0
	t.maxLines = 0
	t.maxed = false
	t.font = love.graphics.getFont()
	t.fonts = {}
	t.active = false
	t.useable = true
	t.paddingLeft = 0
	t.r = {0,0,0,0}
	t.paddingRight = 0
	t.paddingTop = 0
	t.paddingBottom = 0
	t.animateBorderOpacity = true
	t.opacityToAnimateBorderTo = 0
	t.opacityBorderAnimateTime = 0
	t.opacityBorderAnimateSpeed = 0
	
	function t:addFont(f, n)
		assert(f, "[" .. self.name .. "] FAILURE: textfield:addFont() :: Missing param[font]")
		assert(type(f) == "userdata", "[" .. self.name .. "] FAILURE: textfield:addFont() :: Incorrect param[font] - expecting font userdata and got " .. type(f))
		assert(n, "[" .. self.name .. "] FAILURE: textfield:addFont() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: textfield:addFont() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.fonts[n] = f
		return self
	end
	
	function t:setFont(n)
		assert(n, "[" .. self.name .. "] FAILURE: textfield:setFont() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: textfield:setFont() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.font = self.fonts[n]
		return self
	end
	
	function t:setText(txt)
		assert(txt ~= nil, "[" .. self.name .. "] FAILURE: textfield:setText() :: Missing param[text]")
		assert(type(txt) == "string", "[" .. self.name .. "] FAILURE: textfield:setText() :: Incorrect param[text] - expecting string and got " .. type(txt))
		self.text = txt
		return self
	end
	
	function t:getText()
		return self.textfield
	end
	
	function t:setUseable(u)
		assert(u ~= nil, "[" .. self.name .. "] FAILURE: textfield:setX() :: Missing param[useable]")
		assert(type(u) == "boolean", "[" .. self.name .. "] FAILURE: textfield:setX() :: Incorrect param[useable] - expecting boolean and got " .. type(u))
		self.useable = u
		return self
	end
	
	function t:getUseable()
		return self.getUseable
	end
	
	function t:val()
		local result = ""
		for k,v in ipairs(self.options) do
			if #v == 1 and v == " " then
				v = "\n"
			end
			result = result .. v
		end
		return result
	end
	
	return t
end

return setmetatable(textfield, textfield)