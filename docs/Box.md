# Box
The goal of the box element is for backgrounds, buttons, and HUD containers. This is the most commonly used type of element in a GUI.
## Object Creation
```lua
local GUI = require("gui")
local myBox = GUI:addBox("myBox")
myBox:addImage(lg.newImage("res/img/background.png"), "background", true)
myBox:setData({w = 800, h = 600, x = 0, y = 0, z = 0, clickable = false})
```
## Data Handling
These functions provide the ability to directly modify many variables of your elements. The way these work currently may change.<br>
The biggest change that may happen, is accepting additional parameter types. No old elements will be broken by updates.
##### :addImage(userdata image, string name, boolean automatic)
> Add an image to the box element memory. These will be used with the :setImage() function.
```lua
local background = love.graphics.newImage("/images/background.png")
Neon:child("myBox"):addImage(background, "background", true)
-- The third param being true tells the box to automatically set the currently used image to this provided image.
```

##### :setBorderColor(table color)
> Set the border color of your element to a new color. Default is white.
##### :getBorderColor()
> Returns a table of the current element border color.

##### :setData(table data)
There are several options you can set in the `setData` function. Here is a list:
var type | var name
---------|---------
table | borderColor
table | color
boolean | clickable
number | height / h
userdata | image
boolean | moveable
number | opacity
boolean | round
number | roundRadius / radius
boolean | useBorder
number | width / w
number | x
number | y
number | z
boolean | vertical
##### :setUseBorder(boolean useBorder)
> Set whether the element should have a border.
##### :getUseBorder()
> Get whether the element has a border.
## Object Manipulation
These functions are used for animating, enabling, and disabling elements.
##### :animateBorderToColor(table color, number speed)
> Animate the current element to a new border color, at the provided speed, or at 2s without a speed given.