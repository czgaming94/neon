local lg, lt = love.graphics, love.timer
local floor, random, min, max = math.floor, love.math.random, math.min, math.max
local guis = {}
local function obj(t, p)
	if p and p.id and not guis[p.id] then guis[p.id] = p end
	t = t or {}
	t.__index = t
	t.new = t.new or t.init or t[1] or function() end
	t.w = 0
	t.h = 0
	t.shaders = {
		fadeOut = lg.newShader(love.filesystem.read("/neon/shaders/fadeOut.shader")),
		fadeIn = lg.newShader(love.filesystem.read("/neon/shaders/fadeIn.shader"))
	}
	t.pos = {
		x = 0,
		y = 0,
		z = 1
	}
	t.x = t.pos.x
	t.y = t.pos.y
	t.z = t.pos.z
	t.type = "emptyElement"
	t.border = false
	t.borderColor = {1,1,1,1}
	t.color = {1,1,1,1}
	t.defaults = {}
	t.hovered = false
	t.clicked = false
	t.clickable = true
	t.held = false
	t.moveable = false
	t.hollow = false
	t.faded = false
	t.fadedByFunc = false
	t.hidden = false
	t.events = {}
	t.noiseX = false
	t.noiseY = false
	t.noiseStrength = 4
	t.inAnimation = false
	t.runAnimations = false
	t.animateColor = false
	t.colorToAnimateTo = {1,1,1,1}
	t.colorAnimateSpeed = 0
	t.colorAnimateTime = 0
	t.animatePosition = false
	t.positionAnimateSpeed = 0
	t.positionToAnimateTo = {x = 0, y = 0}
	t.positionToAnimateFrom = {x = 0, y = 0}
	t.positionAnimateTime = 0
	t.bouncePositionAnimation = false
	t.positionAnimationPercent = 0
	t.positionAnimationPercentX = 0
	t.positionAnimationPercentY = 0
	t.animateOpacity = false
	t.opacityAnimateSpeed = 0
	t.opacityToAnimateTo = 0
	t.opacityAnimateTime = 0
	
	function t:animateToColor(c, s, f)
		assert(c, "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c > 2, "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToColor() :: Incorrect param[speed] - expecting number and got " .. type(s))
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
	function t:animateToPosition(x, y, s, f, e)
		assert(x, "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToPosition() :: Missing param[x]")
		assert(type(x) == "number" or type(x) == "string", "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToPosition() :: Incorrect param[x] - expecting number or 'auto' and got " .. type(x))
		assert(y, "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToPosition() :: Missing param[y]")
		assert(type(y) == "number" or type(x) == "string", "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToPosition() :: Incorrect param[y] - expecting number or 'auto' and got " .. type(y))
		s = s or 2
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToPosition() :: Incorrect param[speed] - expecting number and got " .. type(s))
		if not self.fadedByFunc or f then
			if x == "auto" then
				x = self.pos.x
			end
			if y == "auto" then
				y = self.pos.y
			end
			if self.type == "text" then
				for _,v in ipairs(self.typewriterText) do
					local xDif, yDif
					if self.pos.x - v.x ~= 0 then
						xDif = x - (self.pos.x - v.x)
					else
						xDif = self.pos.x
					end
					if self.pos.y - v.y ~= 0 then
						yDif = y - (self.pos.y - v.y)
					else
						yDif = self.pos.y
					end
					v.oX = v.x
					v.tX = xDif
					v.oY = v.y
					v.tY = yDif
				end
			end
			for k,v in pairs(self.pos) do self.positionToAnimateFrom[k] = v end
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

	function t:animateToOpacity(o, s, f)
		assert(o, "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToOpacity() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToOpacity() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		s = s or 1
		assert(type(s) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":animateToOpacity() :: Incorrect param[speed] - expecting number and got " .. type(s))
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

	function t:isAnimating()
		return self.inAnimation
	end

	function t:cancelAnimation(single)
		if not single then
			self.inAnimation = false
			self.animateColor = false
			self.animatePosition = false
			self.animateOpacity = false
			if self.animateBorderColor ~= nil then self.animateBorderColor = false end
			if self.animateBorderOpacity ~= nil then self.animateBorderOpacity = false end
			if self.animateImage ~= nil then self.animateImage = false end
		else
			self[single] = false
		end
	end

	function t:setClickable(c)
		assert(c ~= nil, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setClickable() :: Missing param[clickable]")
		assert(type(c) == "boolean", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setClickable() :: Incorrect param[clickable] - expecting boolean and got " .. type(c))
		self.clickable = c
		return self
	end

	function t:isClickable()
		return self.clickable
	end

	function t:setColor(c)
		assert(c, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setColor() :: Missing param[color]")
		assert(type(c) == "table", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setColor() :: Incorrect param[color] - expecting table and got " .. type(c))
		assert(#c > 2, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setColor() :: Incorrect param[color] - expecting table length 3 or 4 and got " .. #c)
		self.color = c
		return self
	end

	function t:getColor()
		return self.color
	end

	function t:setData(d)
		assert(d, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setData() :: Missing param[data]")
		assert(type(d) == "table", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setData() :: Incorrect param[data] - expecting table and got " .. type(d))
		assert(d.x, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setData() :: Missing param[data['x']")
		assert(type(d.x) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setData() :: Incorrect param[x] - expecting number and got " .. type(d.x))
		assert(d.y, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setData() :: Missing param[data['y']")
		assert(type(d.y) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setData() :: Incorrect param[y] - expecting number and got " .. type(d.y))
		self.pos.x = d.x
		self.pos.y = d.y
		if d.w then 
			self.w = d.w 
			if self.uW then
				self.uW = d.w
			end
		end
		if d.width then 
			self.w = d.width
			if self.uW then
				self.uW = d.width
			end
		end
		if d.h then 
			self.h = d.h 
			if self.uH then
				self.uH = d.h
			end
		end
		if d.height then 
			self.h = d.height
			if self.uH then
				self.uH = d.height
			end
		end
		if d.label then self.label = d.label end
		if d.text then
			self.text = d.text
			if self.label then
				self.label = d.text
			end
			if self.typewriterText then
				self.typewriterText, self.fancy = self:split()
			end
			if self.placeholder then
				self.placeholder = d.text
			end
		end
		if d.t then
			self.text = d.t
			if self.label then
				self.label = d.t
			end
			if self.typewriterText then
				self.typewriterText = self:split(self.text)
			end
			if self.placeholder then
				self.placeholder = d.t
			end
		end
		if d.placeholder then
			self.placeholder = d.placeholder
		end
		if d.fonts then
			for k,v in pairs(d.fonts) do
				self.fonts[k] = v
			end
		end
		if d.z then self.pos.z = d.z end
		if d.rot then self.rot = d.rot end
		if d.image then self.image = self.images[d.image] or d.image end
		if d.font then self.font = d.font end
		if self.type == "text" and self.text then
			if not d.w and not d.width then
				self.w = self.font:getWidth(self.text)
			end
			if not d.h and not d.height then
				self.h = self.font:getHeight()
			end
		end
		if d.labelFont then self.labelFont = d.labelFont end
		if d.optionFont then self.optionFont = d.optionFont end
		if d.s then self.speed = d.s end
		if d.speed then self.speed = d.speed end
		if d.align then self.align = d.align end
		
		if d.useBorder ~= nil then self.border = d.useBorder end
		if d.clickable ~= nil then self.clickable = d.clickable end
		if d.moveable ~= nil then self.moveable = d.moveable end
		if d.hollow ~= nil then self.hollow = d.hollow end
		if d.keepBackground ~= nil then self.keepBackground = d.keepBackground end
		if d.round ~= nil then self.round = d.round end
		if d.single ~= nil then self.single = d.single end
		if d.singleSelection ~= nil then self.single = d.singleSelection end
		if d.fixPadding ~= nil then self.fixPadding = d.fixPadding end
		if d.fix ~= nil then self.fixPadding = d.fix end
		if d.force ~= nil then self.forceOption = d.force end
		if d.forceOption ~= nil then self.forceOption = d.forceOption end
		if d.labelShadow ~= nil then self.shadowLabel = d.labelShadow end
		if d.tw ~= nil then self.typewriter = d.tw end
		if d.typewriter ~= nil then self.typewriter = d.typewriter end
		if d.tRepeat ~= nil then self.typewriterRepeat = d.tRepeat end
		if d.shadow ~= nil then self.shadow = d.shadow end
		if d.closeOnUnfocus ~= nil then self.closeOnUnfocus = d.closeOnUnfocus end
		
		if d.radius then
			if type(d.radius) == "table" then
				self.r = d.radius
			else
				for k,v in ipairs(self.r) do self.r[k] = d.radius end
			end
		end
		if d.color then
			for k,v in ipairs(d.color) do
				self.color[k] = v
			end
		end
		if d.borderColor then
			for k,v in ipairs(d.borderColor) do
				self.borderColor[k] = v
			end
		end
		if d.optionsColor then
			for k,v in ipairs(d.optionsColor) do
				self.optionsColor[k] = v
			end
		end
		if d.overlayColor then
			for k,v in ipairs(d.overlayColor) do
				self.overlayColor[k] = v
			end
		end
		if d.labelColor then
			for k,v in ipairs(d.labelColor) do
				self.labelColor[k] = v
			end
		end
		if d.selectedColor then
			for k,v in ipairs(d.selectedColor) do
				self.selectedColor[k] = v
			end
		end
		if d.textColor then
			for k,v in ipairs(d.textColor) do
				self.textColor[k] = v
			end
		end
		if d.opacity then 
			self.color[4] = d.opacity 
			if self.borderColor then
				self.borderColor[4] = d.opacity
			end
		end
		if d.labelPosition or d.labelPos then
			local i = d.labelPosition or d.labelPos
			if i.x then
				self.labelPosition = i
			else
				self.labelPosition.x, self.labelPosition.y, self.labelPosition.z = unpack(i)
			end
		end
		if d.padding then
			if d.padding.top then
				self.paddingTop, self.paddingRight, self.paddingBottom, self.paddingLeft = d.padding.top, d.padding.right, d.padding.bottom, d.padding.left
			else
				self.paddingTop, self.paddingRight, self.paddingBottom, self.paddingLeft = unpack(d.padding)
			end
		end
		if d.imageOffset then
			if d.imageOffsed.x then
				self.iX, self.iY = d.imageOffsed.x, d.imageOffsed.y
			else
				self.iX, self.iY = unpack(d.imageOffset)
			end
		end
		if d.options then
			if not d.keepOptions then
				self.options = {}
			end
			local w, h = 0, 0
			if self.type == "checkbox" then
				for k,v in ipairs(d.options) do
					if k == 1 then
						self.options[k] = {
							text = v, 
							x = self.pos.x, 
							y = self.pos.y,
							w = self.paddingLeft + self.uW + self.font:getWidth(v) + self.paddingRight,
							h = self.paddingTop + self.uH + self.paddingBottom
						}
						if self.fixPadding then
							self.options[k].x = self.pos.x
						end
					else
						self.options[k] = {
							text = v, 
							x = self.options[k - 1].x + self.font:getWidth(self.options[k - 1].text) + 4 + (self.paddingLeft * 2) + self.uW + self.paddingRight, 
							y = self.paddingTop + self.pos.y + self.paddingBottom,
							w = self.paddingLeft + self.uW + self.font:getWidth(v) + self.paddingRight,
							h = self.paddingTop + self.uH + self.paddingBottom
						}
						if d.verticalOptions then
							self.vertical = true
							self.options[k].x = self.pos.x + self.paddingRight
							self.options[k].y = self.options[k - 1].y + self.font:getHeight(v)
						else
							self.options[k].y = self.pos.y
						end
					end
					w = (self.paddingLeft * 2) + w + (self.uW + self.font:getWidth(v)) + self.paddingRight
					h = self.paddingTop + h + (self.uH + self.font:getHeight(v)) + 2 + self.paddingBottom
					if self.border then
						w = w + 2
						h = h + 2
					end
				end
				if self.vertical then 
					if self.border then
						self.w = self.paddingLeft + self.uW + 2 + self.paddingRight
					else
						self.w = self.paddingLeft + self.uW + self.paddingRight
					end
					self.h = h
				else 
					self.w = w
					if self.border then
						self.h = self.paddingTop + self.uH + 2 + self.paddingBottom
					else
						self.h = self.paddingTop + self.uH + self.paddingBottom
					end
				end
			else
				for k,v in ipairs(d.options) do
					if k == 1 then
						self.options[k] = {
							text = v, 
							x = self.optionPaddingLeft + self.pos.x, 
							y = self.optionPaddingTop + self.pos.y + self.uH + self.optionPaddingBottom,
							w = self.optionPaddingLeft + self.optionFont:getWidth(v) + self.optionPaddingRight,
							h = self.optionPaddingTop + self.uH + self.optionFont:getHeight(v) + self.optionPaddingBottom
						}
						if self.fixPadding then
							self.options[k].y = self.pos.y + self.uH + self.optionPaddingBottom
						end
						if self.border then self.options[k].y = self.options[k].y + 7 end
					else
						self.options[k] = {
							text = v, 
							x = self.optionPaddingLeft + self.pos.x,
							y = self.options[k - 1].y + self.options[k - 1].h,
							w = self.optionPaddingLeft + self.optionFont:getWidth(v) + self.optionPaddingRight,
							h = self.optionPaddingTop + self.uH + self.optionFont:getHeight(v) + self.optionPaddingBottom
						}
					end
					if self.border then 
						self.options[k].x = self.options[k].x - 5	
					end
					h = h + self.options[k].h
					w = max(w, self.options[k].w)
				end
				for k,v in ipairs(self.options) do v.w = w end
				self.dW = w
				self.dH = h
			end
		end
		if d.default then
			if self.type == "checkbox" then
				for k,v in ipairs(self.options) do 
					if d.default == "all" then
						v.selected = true
					else
						if v.text == d.default then
							v.selected = true
						end
					end
				end 
			else
				for k,v in ipairs(self.options) do 
					if v.text == t.default then
						self.selected = k 
					end 
				end 
			end
		end
		if self.typewriter or self.fancy then
			local font = self.font
			local lastFont = self.font
			if not d.text then
				self.typewriterText, self.fancy = self:split()
			end
			for k,v in ipairs(self.typewriterText) do
				lastFont = font
				if v.font ~= "default" then
					font = self.fonts[v.font]
				else
					font = self.font
				end
				
				if not v.y or v.y == 0 then
					v.y = self.pos.y
					v.oY = v.y
				end
				
				if not v.x or v.x == 0 then
					if k == 1 then
						v.x = self.pos.x
					else
						v.x = self.typewriterText[k - 1].x + lastFont:getWidth(self.typewriterText[k - 1].fullText)
						if v.x > self.pos.x + (self.w - font:getWidth(v.fullText)) then
							v.x = self.pos.x
							v.y = self.typewriterText[k - 1].y + lastFont:getHeight(self.typewriterText[k - 1].fullText) 
							self.h = self.h + font:getHeight(v.fullText)
							v.oY = v.y
						end
					end
					v.oX = v.x
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
		if self.type == "textfield" then
			self.maxLines = floor((self.h - (10 + self.paddingTop + self.paddingBottom)) / self.font:getHeight())
		end
		
		self.defaults = d
		return self
	end
	
	function t:getData()
		local d = {}
		for k,v in pairs(self) do
			if type(v) ~= "function" then
				d[k] = v
			end
		end
		return d
	end
	
	function t:getDefault()
		local d = {}
		for k,v in pairs(self.defaults) do
			d[k] = v
		end
		return d
	end

	function t:disable()
		self.hidden = true
		return self
	end

	function t:enable()
		self.hidden = false
		return self
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
		return self
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
		return self
	end

	function t:setHeight(h)
		assert(h, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setHeight() :: Missing param[height]")
		assert(type(h) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setHeight() :: Incorrect param[height] - expecting number and got " .. type(h))
		self.h = h
		return self
	end

	function t:getHeight(h)
		return self.h
	end

	function t:isHovered()
		return self.hovered
	end

	function t:setHollow(h)
		assert(h ~= nil, "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Missing param[hollow]")
		assert(type(h) == "boolean", "[" .. self.name .. "] FAILURE: checkbox:setHollow() :: Incorrect param[hollow] - expecting boolean and got " .. type(h))
		self.hollow = h
		return self
	end

	function t:isHollow()
		return self.hollow
	end

	function t:startAnimation()
		self.inAnimation = true
		return self
	end

	function t:stopAnimation()
		self.inAnimation = false
		return self
	end

	function t:setMoveable(m)
		assert(m ~= nil, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setUseBorder() :: Missing param[useBorder]")
		assert(type(m) == "boolean", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setUseBorder() :: Incorrect param[useBorder] - expecting boolean and got " .. type(m))
		self.moveable = m
		return self
	end

	function t:isMoveable()
		return self.moveable
	end

	function t:setName(n)
		assert(n, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setUseBorder() :: Missing param[name]")
		assert(type(n) == "string", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setUseBorder() :: Incorrect param[name] - expecting string and got " .. type(n))
		self.name = n
		return self
	end

	function t:getName()
		return self.name
	end

	function t:setNoiseStrength(n)
		assert(n, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setNoiseStrength() :: Missing param[strength]")
		assert(type(n) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setNoiseStrength() :: Incorrect param[strength] - expecting number and got " .. type(n))
		self.noiseStrength = n
		return self
	end

	function t:getNoiseStrength()
		return self.noiseStrength
	end

	function t:setNoiseX(n)
		assert(n ~= nil, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setNoiseX() :: Missing param[useNoise]")
		assert(type(n) == "boolean", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setNoiseX() :: Incorrect param[useNoise] - expecting boolean and got " .. type(n))
		self.noiseX = n
		return self
	end

	function t:getNoiseX()
		return self.noiseX
	end	

	function t:setNoiseY(n)
		assert(n ~= nil, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setNoiseY() :: Missing param[useNoise]")
		assert(type(n) == "boolean", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setNoiseY() :: Incorrect param[useNoise] - expecting boolean and got " .. type(n))
		self.noiseY = n
		return self
	end

	function t:getNoiseY()
		return self.noiseY
	end

	function t:setOpacity(o)
		assert(o, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setUseBorder() :: Missing param[opacity]")
		assert(type(o) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setUseBorder() :: Incorrect param[opacity] - expecting number and got " .. type(o))
		self.color[4] = o
		return self
	end

	function t:getOpacity()
		return self.color[4]
	end

	function t:registerEvent(n, f, trg, i)
		assert(n, "FAILURE: gui:registerEvent() :: Missing param[eventName]")
		assert(type(n) == "string", "FAILURE: gui:registerEvent() :: Incorrect param[eventName] - expecting string and got " .. type(n))
		assert(f, "FAILURE: gui:registerEvent() :: Missing param[functiom]")
		assert(type(f) == "function", "FAILURE: gui:registerEvent() :: Incorrect param[functiom] - expecting function and got " .. type(f))
		if not self.events[n] then self.events[n] = {} end
		local id = #self.events[n] + 1
		self.events[n][id] = {id = id, fn = f, target = trg, name = i}
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
		return self
	end

	function t:setWidth(w)
		assert(w, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setWidth() :: Missing param[width]")
		assert(type(w) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setWidth() :: Incorrect param[width] - expecting number and got " .. type(w))
		self.w = w
		return self
	end

	function t:getWidth()
		return self.w
	end

	function t:setX(x)
		assert(x, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setX() :: Missing param[x]")
		assert(type(x) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setX() :: Incorrect param[x] - expecting number and got " .. type(x))
		self.pos.x = x
		return self
	end

	function t:getX()
		return self.pos.x
	end

	function t:setY(y)
		assert(y, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setY() :: Missing param[y]")
		assert(type(y) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setY() :: Incorrect param[y] - expecting number and got " .. type(y))
		self.pos.y = y
		return self
	end

	function t:getY()
		return self.pos.y
	end

	function t:setZ(z)
		assert(z, "[" .. self.name .. "] FAILURE: " .. self.type .. ":setZ() :: Missing param[z]")
		assert(type(z) == "number", "[" .. self.name .. "] FAILURE: " .. self.type .. ":setZ() :: Incorrect param[z] - expecting number and got " .. type(z))
		self.pos.z = z
		guis[self.parent].needToSort = true
		return self
	end

	function t:getZ()
		return self.pos.z
	end

	-- begin, end, scale
	function t.lerp(b,e,s)
		return (1 - s) * b + s * e
	end
	
	return setmetatable(t, {__call = function(o, ...)
		local e = setmetatable({}, o)
		e:obj(...)
		return e
	end})
end

return setmetatable({obj = obj}, {__call = function(_,...) return obj(...) end})