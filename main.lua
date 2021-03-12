local lg = love.graphics

-- Create GUI instances
-- Doing this allows you to change settings between the two GUI's
-- This also separates the elements into two groups, and their z - index will be calculated differently.
local Neon = require("neon")
local Neon2 = Neon:new()

local myBox = Neon:add("box", "myBox")
Neon:addBox("myBox2")
local myCheckbox = Neon:addCheckbox("myCheckbox")
local myDropdown = Neon:addDropdown("myDropdown")
local myTextfield = Neon:addTextfield("myTextfield")
local myBox3 = Neon2:addBox("myBox3")
local myBox4 = Neon2:addBox("myBox4")

local myText = Neon2:addText("continue")

local myFont = lg.newFont("res/font/thicktext.otf", 24)

local colors = Neon.color

function love.load()
	-- Add color to global GUI
	Neon:addColor({1,1,1,1}, "white")
	Neon:addColor({0,0,0,1}, "black")
	Neon:addColor({0,0,0,0}, "empty")
	Neon:addColor({1,0,0,.5}, "alphaRed")
	Neon:addColor({.92,.97,.92,1}, "eggshell")
	
	-- Add images to your box, easily.
	-- image (userdata)
	-- name (string)
	-- automatic (boolean)
	myBox:addImage(lg.newImage("res/img/background.png"), "background")
	
	-- [PARAMS]
	-- borderColor  (table)
	-- clickable    (boolean)
	-- color        (table)
	-- h | height   (number)
	-- image        (string)
	-- moveable		(boolean)
	-- opacity      (number)
	-- padding      (numbers)(top, right, bottom, left)
	-- useBorder    (boolean)
	-- w | width    (number)
	-- x            (number)
	-- y            (number)
	-- z            (number)
	myBox:setData({ w = 800, h = 600, x = 0, y = 0, z = 0, image = "background"})
	-- This function can do the same as these 13. Order does not matter. Assosciative table required.

	--[[
		myBox:setBorderColor({1,0,1,1})
		myBox:setClickable(false)
		myBox:setColor({0,0,1,1})
		myBox:setHeight(50)
		myBox:setImage(love.graphics.newImage("path/to/image.png"))
		myBox:setMoveable(true)
		myBox:setOpacity(0.5)
		myBox:setPadding(0,5,0,5)
		myBox:setUseBorder(true)
		myBox:setWidth(50)
		myBox:setX(5)
		myBox:setY(10)
		myBox:setZ(2)
	--]]
	
	-- You can disable whether or not a box is read as a clickable object.
	-- Clicks will pass through this object.
	myBox:setClickable(false)
	
	Neon:child("myBox2"):setData({
		w = 50, h = lg.getHeight(), x = 1, y = 0, 
		color = colors("green"), 
		useBorder = true, borderColor = colors("black")
	})
	myBox3:setData({
		w = 225, h = 65, x = 105, y = 485, z = 2,
		color = colors("alphaRed"), 
		moveable = true,
		useBorder = false
	})
	myText:setData({
		width = 115, height = 40,
		x = 110, y = 490, z = 2, 
		color = colors("yellow"), 
		text = "{c=blue}Hello{/} {c=red,d=1,f=myFont,o=(5.-20),t=0.01}World!{/}",
		typewriter = true, speed = 0.5,
		fonts = {myFont = myFont},
		hollow = true, moveable = true
	})
	myCheckbox:setData({
		w = 10, h = 10, x = 250, y = 150, z = 1, 
		label = "Favorite Color?", labelColor = colors("black"), labelFont = myFont, labelPos = {290, 105, 1},
		padding = {10,10,10,10}, fixPadding = true, 
		options = {"Red", "Blue", "Green", "Yellow"}, optionColor = colors("blue"), singleSelection = true, default = "Green",
		color = colors("eggshell"), 
		useBorder = true, borderColor = colors("red"),
		round = true, radius = 3,
		overlayColor = colors("alphaRed")
	})
	myDropdown:setData({
		w = 150, h = 25, x = 400, y = 300, z = 2,
		label = "Window Size", labelColor = colors("red"), labelFont = myFont, labelPos = {400, 250, 2},
		padding = {5,5,5,5}, fixPadding = true,
		options = {"800x600","1024x640","1280x720","1960x1080"}, optionColor = colors("black"), default = "800x600", optionPadding = {5,5,5,10},
		color = colors("eggshell"),
		useBorder = true, borderColor = colors("yellow"),
		round = true, radius = 6,
		closeOnUnfocus = true
	})
	myTextfield:setData({
		w = 150, h = 125, x = 100, y = 50, z = 2,
		textColor = colors("green"),
		padding = {5,5,5,5}, fixPadding = true,
		color = colors("eggshell"),
		useBorder = true, borderColor = colors("yellow"),
		round = true, radius = 6,
		moveable = true
	})
	myBox4:setData({
		w = 50, h = 250, x = 105, y = 200, 
		color = colors("purple"), 
		useBorder = true, borderColor = colors("black")
	})
	
	
	-- You can change the Z index of an entire GUI container, or just a single object
	Neon2:setZ(1)
	
	-- You can define onClick callbacks for your GUI elements
	Neon:registerGlobalEvent("onClick", "box", function(self, obj, target, evt) 
		print(self.name) 
		Neon:removeGlobalEvent("onClick", "box", "boxOnClick") 
	end, nil, "boxOnClick")
	Neon:child("myBox2"):registerEvent("onClick", function(self, a) a:fadeOut(true, true) end, myBox3)
	myBox3:registerEvent("onFadeOut", function(self) print("Faded") end)
	myBox3:registerEvent("onMove", function(self) print("x", self.x, "y", self.y) end)
	Neon:registerEvent("onClick", Neon:child("myBox2"), function(self) Neon:child("myBox2"):animateBorderToColor(colors("red")) end)
	Neon:registerEvent("onClick", Neon:child("myBox2"), function(self) Neon:child("myBox2"):animateToColor(colors("black")) end)
	
	
	-- You can define onOptionClick callbacks for your checkbox elements
	myCheckbox:registerEvent("onOptionClick", function(self, option, target, evt) Neon:child("myBox2"):setColor(colors(option.text:lower())) end)
end

-- Use a single source for love callbacks
function love.update(dt)
	Neon:update(dt)
end

function love.draw()
	Neon:draw()
end

function love.keypressed(key,scancode,isrepeat)
	Neon:keypressed(key,scancode,isrepeat)
end

function love.keyreleased(key, scancode)
	Neon:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
	Neon:mousepressed(x, y, button, istouch, presses)
	if button == 2 then
		for k,v in ipairs(Neon:getHeld()) do
			v.obj:disable()
		end
	end
end

function love.mousereleased(x, y, button, istouch, presses)
	Neon:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
	Neon:mousemoved(x, y, dx, dy, istouch)
end

-- For mobile
function love.touchpressed(id, x, y, dx, dy, pressure)
	Neon:touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	Neon:touchmoved(id, x, y, dx, dy, pressure)
end