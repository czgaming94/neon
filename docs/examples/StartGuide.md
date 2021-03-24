# Quick Start Guide
The first step to using the GUI is including it into your file.
```lua
local Neon = require("neon")
```
Next, let's create a box, there are a few ways to do this:
```lua
local box = Neon:addBox("myBox")
-- or
Neon:add("box", "myBox")
```
Here, we have created a box object in both cases, with the name of `myBox`<br>
> In this example, we will be using the `box` local variable to modify the element.

The next step, we will set some data for the box, so that it can display itself.
```lua
box:setData({
	width = 150, height = 50,
	x = 50, y = 25, z = 1,
	color = {0,1,1,1},
	useBorder = true, borderColor = {1,1,0,1}
})
```
As you can see, we set the definition of this elements width, height, x,y,z, color, and whether the element should use a border,<br>
and what color the border is. Next, let's create a callback for when you click on the box.
```lua
box:registerEvent("onClick", function(self, target, event)
    print(self.name, event.x, event.y)
end, nil, "boxClick")
```
Let's break this down. `box:registerEvent("onClick",` defines the event to happen only when you click.
```lua
function(self, target, event)
	print(self.name, event.x, event.y)
end
```
This section tells the event what to do when it is fired.<Br>
`self` is the object the event is fired on.<br>
`target` is the object defined afer the event in the `registerEvent` block, here we have it defined as nil.<br>
`event` is the data that came from LOVE. onClick would deliver an associative table of `{x, y, button, istouch, presses}`<br>
<br>
Now let's take a look at what our code should look like.
```lua
local Neon = require("neon")
	
local box = Neon:addBox("myBox")
	
box:setData({
	width = 150, height = 50,
	x = 50, y = 25, z = 1,
	color = {0,1,1,1},
	useBorder = true, borderColor = {1,1,0,1}
})
	
box:registerEvent("onClick", function(self, target, event)
    print(self.name, event.x, event.y)
end, nil, "boxClick")
	
	
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
```
