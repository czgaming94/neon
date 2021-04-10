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
#### :addImage(userdata image, string name, boolean automatic)
> Add an image to the box element memory. These will be used with the :setImage() function.
```lua
local background = love.graphics.newImage("/images/background.png")
Neon:child("myBox"):addImage(background, "background", true)
-- The third param being true tells the box to automatically set the currently used image to this provided image.
```

#### :setBorderColor(table color)
> Set the border color of your element to a new color. Default is white.
#### :getBorderColor()
> Returns a table of the current element border color.
#### :setData(table data)
There are several options you can set in the `setData` function. Here is a list that will work on any element:
var type | var name | var default
:--|:--|:--
boolean | border | `false`
table | borderColor | `{1,1,1,1}`
table | color | `{1,1,1,1}`
boolean | clickable | `false`
boolean | moveable | `false`
boolean | noiseX | `false`
boolean | noiseY | `false`
number | noiseStrength | `0`
number | height / h | `0`
number | opacity | `1`
table | padding | `{0,0,0,0}`
number | paddingLeft | `0`
number | paddingRight | `0`
number | paddingTop | `0`
number | paddingBottom | `0`
boolean | useBorder | `false`
number | width / w | `0`
number | x | `0`
number | y | `0`
number | z | `0`

And here is a list that will also work for the box elements:
var type | var name | var default
:--|:--|:--
userdata | image | `nil`
boolean | keepBackground | `false`
string | imageBlend  | `premultiply`
boolean | round | `false`
number | roundRadius / radius | `0`
boolean | round | `false`
number | roundRadius / radius | `0`
number | rotation / rot | `0`
boolean | button | `false`
#### :setUseBorder(boolean useBorder)
> Set whether the element should have a border.
#### :getUseBorder()
> Get whether the element has a border.
## Object Manipulation
These functions are used for animating, enabling, and disabling elements.<br>
[Generic Element Methods](https://github.com/czgaming94/neon/blob/main/docs/Element.md)
#### :animateBorderToColor(table color, number speed)
> Animate the current element to a new border color, at the provided speed, or at 2s without a speed given.
#### :animateBorderToOpacity(number opacity, number speed)
> Animate the current element to a new opacity, at the provided speed, or at 2s without a speed given.