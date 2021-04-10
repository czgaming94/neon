# NEON [Newbie, Experienced, or Neither]
This API's goal is to make laying out your application GUI simple and efficient. The secondary goal of this API 
is to be as easy to grasp as possible for even the mediocre Lua user, as well as users coming from other scripting languages.<br>
#### [If you aren't quite understanding how to start using the API, check out this quick starters guide!](https://github.com/czgaming94/neon/blob/main/docs/examples/StartGuide.md)

### GUI Handles
The GUI lib brings a few handles and callbacks that allow the user to have full control.
##### :new(item)
`var item`
> Create a new instance of the GUI. This is used for when you do not want every element in one GUI.
> An example of two GUIs would be a `mainMenu` and `pauseMenu`
```lua
local Neon = require("neon")
local Game = {}
Game.mainMenu = Neon:new()
```
> Can also be used to create a new instance of any table or variable.
##### :duplicate(item)
`var item`
> Creates a new instance of an already existing item.
```lua
local Neon = require("neon")
local myBox = Neon:add("box", "myBox"):setData({x = 20, y = 30, w = 10, h = 10})
local newBox = Neon:duplicate(myBox)
```
##### :setUse255(use255)
`boolean use255`
> Tell the GUI whether you are using a 255 color scheme. It will automatically divide your colors for you.
```lua
local Neon = require("neon")
Neon:setUse255(true) -- works like love.graphics.setColor(love.math.colorFromBytes(180, 120, 190, 255))
Neon:setUse255(false) -- works like love.graphics.setColor(.6, .4, .7, 1)
```
##### :animateToColor(object, color, speed)
`table object, table color, number speed`
> Animate an object through the GUI parent, to a specified color, at an optional speed. Speed defaults to `2`
```lua
local Neon = require("neon")
Neon:add("box", "myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:animateToColor(Neon:child("myBox"), {1,1,1,1}, 5)
```
##### :animateBorderToColor(object, color, speed)
`table object, table color, number speed`
> Animate an object through the GUI parent, to a specified border color, at an optional speed. Speed defaults to `2`
```lua
local Neon = require("neon")
Neon:add("box", "myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}, borderColor = {.5,1,1,1}})
Neon:animateBorderToColor(Neon:child("myBox"), {1,1,1,1}, 5)
```
##### :animateToPosition(object, position, speed)
`table object, table position, number speed`
> Animate an object through the GUI parent, to a specified position, at an optional speed. Speed defaults to `2`
```lua
local Neon = require("neon")
Neon:add("box", "myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:animateToPosition(Neon:child("myBox"), 20, 20, 5)
```
##### :animateBorderToOpacity(object, opacity, speed)
`table object, number opacity, number speed`
> Animate an object through the GUI parent, to a specified border color, at an optional speed. Speed defaults to `2`
```lua
local Neon = require("neon")
Neon:add("box", "myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}, borderColor = {.5,1,1,1}})
Neon:animateBorderToOpacity(Neon:child("myBox"), .2, 5)
```
##### :animateToOpacity(object, opacity, speed)
`table object, number opacity, number speed`
> Animate an object through the GUI parent, to a specified opacity, at an optional speed. Speed defaults to `1`
```lua
local Neon = require("neon")
Neon:add("box", "myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:animateToOpacity(Neon:child("myBox"), .2, 5)
```
##### :canUpdate(canUpdate)
`boolean canUpdate`
> Returns whether GUI can update if canUpdate is not supplied
> Set whether a GUI can update if canUpdate is supplied
```lua
local Neon = require("neon")
Neon:canUpdate(false)
function love.mousepressed()
	if not Neon:canUpdate() then
		Neon:canUpdate(true)
	end
end
```
##### :addColor(color, name)
`table color, string name`
> Add a color to the global GUI interface with the given name. Call with `Neon.color("name")`
```lua
local Neon = require("neon")
Neon:addColor({1,1,1,1}, opaqueWhite)
Neon:addColor({1,1,1,.5}, transparentWhite)
Neon:addColor({1,1,1,.25}, seeThroughWhite)
```
##### :add(type, name, button, func, target)
`string type, string name, boolean button, function func, var target`
> Add an element of the given type to the GUI interface with the given name. Call with `Neon:child("name")`
```lua
local Neon = require("neon")
Neon:add("box", "myBox")
-- or
local myBox = Neon:add("box", "myBox")
```
##### :addBox(name, button, func, target)
`string name, boolean button, function func, var target`
> Add a box element to the GUI interface.
> If button is set as true, define box as a button, with a default onClick function and target
```lua
local Neon = require("neon")
Neon:addBox("myBox")
or
Neon:addBox("myButton", true, function(self, target, event)
	print(self.type) -- will still be box
	print(self.button) -- true
end)
```
`string name`
##### :addText(name)
`string name`
> Add a text element to the GUI interface.
```lua
local Neon = require("neon")
Neon:addText("myText")
```
##### :addCheckbox(name)
`string name`
> Add a checkbox element to the GUI interface.
```lua
local Neon = require("neon")
Neon:addCheckbox("myCheckbox")
```
##### :addDropdown(name)
`string name`
> Add a dropdown element to the GUI interface.
```lua
local Neon = require("neon")
Neon:addDropdown("myDropdown")
```
##### :addSlider(name)
`string name`
> Add a slider element to the GUI interface.
```lua
local Neon = require("neon")
Neon:addSlider("mySlider")
```
##### :addRadial(name)
`string name`
> Add a radial element to the GUI interface.
```lua
local Neon = require("neon")
Neon:addRadial("myRadial")
```
##### :addTextfield(name)
`string name`
> Add a textfield element to the GUI interface.
```lua
local Neon = require("neon")
Neon:addTextfield("myTextfield")
```
##### :enable()
> Re-enable a GUI to display.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:disable()
function love.keypressed(key)
	if key == "e" then Neon:enable() end
end
```
##### :disable()
> Fully disable the GUI from displaying any elements inside it.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
function love.keypressed(key)
	if key == "e" then Neon:enable() end
	if key == "d" then Neon:disable() end
	--[[
		Keep animation state during disable by using 
			Neon:disable(false) 
		instead of 
			Neon:disable()
	 --]]
end
```
##### :drawAll()
> Tell GUI system to draw all GUI parents.
```lua
local Neon = require("neon")
Neon2 = Neon:new()
Neon3 = Neon:new()
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon2:addBox("myBox2"):setData({x = 30, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon3:addBox("myBox3"):setData({x = 50, y = 10, w = 50, h = 50, color = {1,.5,1,1}})

function love.draw()
	Neon:drawAll()
end
```
##### :child(name, ignore)
`string name, boolean ignore`
> Get a child element from a GUI parent if it's active.
> Will get child even if parent isn't active, if ignore is true.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
local box = Neon:child("myBox")
```
##### :children(type, ignore)
`string type, boolean ignore`
> Get all children from an element if the GUI parent is active.
> Will get all children even if parent isn't active, if ignore is true.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:addBox("myBox2"):setData({x = 30, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:addBox("myBox3"):setData({x = 50, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
local boxes = Neon:childred("box")
```
##### :getHeld()
> Returns a table of items that are held by the mouse. Only works with `moveable = true` on the object.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}, moveable = true})
function love.mousepressed(x,y,button)
	if button == 1 then
		for k,v in ipairs(Neon:getHeld()) do
			print(v.name)
		end
	end
end
```
##### :enableAll()
> Turn on all GUI's and re-enable all elements.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}}):disable()
Neon:addBox("myBox"):setData({x = 10, y = 60, w = 50, h = 50, color = {1,.5,1,1}}):disable()
Neon:addBox("myBox"):setData({x = 10, y = 110, w = 50, h = 50, color = {1,.5,1,1}}):disable()
Neon:addBox("myBox"):setData({x = 10, y = 160, w = 50, h = 50, color = {1,.5,1,1}}):disable()
function love.keypressed(key)
	if key == "e" then Neon:enableAll() end
end
```
##### :enableAllElements(only)
`boolean only`
> Fully enable every element, if only is true then it will only enable in the specific GUI.
```lua
local Neon = require("neon")
local Neon2 = Neon:new()
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}}):disable()
Neon:addBox("myBox"):setData({x = 10, y = 60, w = 50, h = 50, color = {1,.5,1,1}}):disable()
Neon2:addBox("myBox"):setData({x = 10, y = 110, w = 50, h = 50, color = {1,.5,1,1}}):disable()
Neon2:addBox("myBox"):setData({x = 10, y = 160, w = 50, h = 50, color = {1,.5,1,1}}):disable()
function love.keypressed(key)
	if key == "d" then Neon:enableAllElements() end
	-- or, to only disable the elements within the specific GUI
	if key == "d" then Neon2:enableAllElements(true) end
end
```
##### :disableAllElements(only)
`boolean only`
> Fully disable every element, if only is true then it will only disable in the specific GUI.
```lua
local Neon = require("neon")
local Neon2 = Neon:new()
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:addBox("myBox"):setData({x = 10, y = 60, w = 50, h = 50, color = {1,.5,1,1}})
Neon2:addBox("myBox"):setData({x = 10, y = 110, w = 50, h = 50, color = {1,.5,1,1}})
Neon2:addBox("myBox"):setData({x = 10, y = 160, w = 50, h = 50, color = {1,.5,1,1}})
function love.keypressed(key)
	if key == "d" then Neon:disableAllElements() end
	-- or, to only disable the elements within the specific GUI
	if key == "d" then Neon2:disableAllElements(true) end
end
```
##### :registerEvent(eventType, object, func, target, eventName)
`string eventType, table object, function func, var target, string eventName`
> Specify an callback to trigger on a specific event, on a specific target.<br>
> `eventType` will be such as `"onClick"` or `"onHoverEnter"`.<br>
> `object` is the element that the callback will happen on.<br>
> `func` is the function defined by the user that will happen when the callback is triggered.<br>
> `target` is the arg sent to the callback as `target` to be used as the user wants.<br>
> `eventName` allows the user to name a specific event, such as an `"onClick"` having a `"quitGame"` tag.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
local x = 50
Neon:registerEvent("onClick", Neon:child("myBox"), function(self)
	print(self.name, target)
end, x, "myBoxClickEvent") 
```
##### :removeEvent(eventType, object, eventName)
`string eventType, table object, string eventName`
> Remove an event from an object.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
local x = 50
Neon:registerEvent("onClick", Neon:child("myBox"), function(self)
	print(self.name, target)
	Neon:removeEvent("onClick", self, "myBoxClickEvent")
end, x, "myBoxClickEvent") 
```
##### :registerGlobalEvent(eventType, objectType, func, target, eventName)
`string eventType, string objectType, function func, var target, string eventName`
> Specify an callback to trigger on a specific event, on a specific target objectType.<br>
> Any element that is defined by the same objectType, will trigger the callback when the event happens.<br>
> This is especially useful for creating multiple boxes, buttons, or texts that should all do the same thing when<br>
> the user interacts with them.<br>
> `eventType` will be such as `"onClick"` or `"onHoverEnter"`.<br>
> `objectType` is the type of element that the callback will happen on, such as `"box"`.<br>
> `func` is the function defined by the user that will happen when the callback is triggered.<br>
> `target` is the arg sent to the callback as `target` to be used as the user wants.<br>
> `eventName` allows the user to name a specific event, such as an `"onClick"` having a `"quitGame"` tag.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:addBox("myBox2"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:addBox("myBox3"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
local x = 50
Neon:registerGlobalEvent("onClick", "box", function(self)
	print(self.name, target)
end, x, "boxClickEvent") 
```
`string eventType, string objectType, string eventName`
##### :removeGlobalEvent(eventType, objectType, eventName)
> Remove an event from the global callback system.
```lua
local Neon = require("neon")
Neon:addBox("myBox"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:addBox("myBox2"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
Neon:addBox("myBox3"):setData({x = 10, y = 10, w = 50, h = 50, color = {1,.5,1,1}})
local x = 50
Neon:registerGlobalEvent("onClick", "box", function(self)
	print(self.name, target)
	Neon:removeGlobalEvent("onClick", "box", "boxClickEvent")
end, x, "boxClickEvent") 
```
##### :setZ(z)
`number z`
> Set the parent Z index of the GUI. GUI's are sorted by their Z before draw.
```lua
local Neon = require("neon"):setZ(1)
local Neon2 = Neon:new():setZ(2)
local Neon3 = Neon:new():setZ(3)
```
###### :getZ()
> Get the Z index of the GUI parent.
```lua
local Neon = require("neon"):setZ(1):getZ() -- 1
```
### Element Use
There are several different commonly used GUI tools brought with this API, as well as a few special ones.<br>
Click the header for the element type to read the API for that specific element. <br>
[Element Methods](https://github.com/czgaming94/neon/blob/main/docs/Element.md) | [Element Callbacks](https://github.com/czgaming94/neon/blob/main/docs/Element.md#api-callbacks)
:--|:--
Each element shares most methods, but each one has individual methods that are specific to only it. Read about the shared methods [here](https://github.com/czgaming94/neon/blob/main/docs/Element.md). | Each element shares most callbacks, but each one has individual callbacks that are specific to only it. Read about the shared callbacks [here](https://github.com/czgaming94/neon/blob/main/docs/Element.md#api-callbacks).
### Element Types
[Boxes](https://github.com/czgaming94/neon/blob/main/docs/Box.md) | [Text](https://github.com/czgaming94/neon/blob/main/docs/Text.md) 
:--|:--
The goal of the box object is for backgrounds, buttons, and HUD containers. This is the most commonly used type of object in a GUI. | The text object has a few abilities. It can be treated as regular static text, or it can be treated as a typewriter, and given syntax coding to morph and affect how the text is displayed. 
[Checkboxes](https://github.com/czgaming94/neon/blob/main/docs/Checkbox.md) | [Dropdowns](https://github.com/czgaming94/neon/blob/main/docs/Dropdown.md) 
The checkbox is designed to be used for taking user input on choices. A top use for the checkbox is for Poll option selection. Checkboxes can accept multiple selections, or be limited to a single selection. | The dropdown is just as it sounds; A menu of options that drops down when clicked on. This is commonly used for toggling between user input options, form submissions, etc.
[Radials](https://github.com/czgaming94/neon/blob/main/docs/Radial.md) | [Sliders](https://github.com/czgaming94/neon/blob/main/docs/Slider.md) 
Radials are a circular "checkbox" design. These never have more than one option selected at a time. These are often used for toggles. |  Sliders are most often used for setting volumes, but they can be used for many things, including scaling and color changes.

[Textfields](https://github.com/czgaming94/neon/blob/main/docs/Textfield.md)
:--
Textfields are as they sound. A field that text can be put. Either you the dev, can put the text that will be there in, or, you can allow the user to type into it. To disable user typing, add `useable = false` to the `setData` function, or use `:useable(false)` on the textfield object.
