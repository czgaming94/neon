# Box
The goal of the box element is for backgrounds, buttons, and HUD containers. This is the most commonly used type of element in a GUI.
## Object Creation
```lua
local GUI = require("gui")
local myBox = GUI:addBox("myBox")
myBox:addImage(lg.newImage("res/img/background.png"), "background", true)
myBox:setData({w = 800, h = 600, x = 0, y = 0, z = 0, clickable = false})
```
## API Callbacks
This API brings several user defined callbacks which allow you to customize what happens when a user interacts with your elements.<br>
Any callback with an `event` paramter has a table provided to it with data accessible to the user. You can easily define these<br>
with 
```lua
myBox:registerEvent("onClick", function(self, target, event)
  print(target.name, event.x, event.y) 
end, yourTargetelement)
```
##### :onClick(self, target, event) -- {x, y, button, istouch, presses}
> Triggered when a user clicks on the element.
##### :onTouch(self, target, event) -- {id, x, y, dx, dy, pressure}
> Triggered when a user taps on the element on mobile.
##### :onHoverEnter(self, target, event) -- {x, y}
> Triggered when a user initially hovers over an element.
##### :onHoverExit(self, target, event) -- {x, y}
> Triggered when a user initially stops hovering an element.
##### :beforeFadeIn(self, target)
> Triggered when an element is about to fade in.
##### :onFadeIn(self, target)
> Triggered when an element is fading in.
##### :afterFadeIn(self, target)
> Triggered after an element fades in.
##### :beforeFadeOut(self, target)
> Triggered when an element is about to fade out.
##### :onFadeOut(self, target)
> Triggered when an element is fading out.
##### :afterFadeOut(self, target)
> Triggered after an element fades out.
## Data Handling
These functions provide the ability to directly modify many variables of your elements. The way these work currently may change.<br>
The biggest change that may happen, is accepting additional parameter types. No old elements will be broken by updates.
##### :addImage(userdata image, string name, boolean automatic)
> Add an image to the box element memory. These will be used with the :setImage() function.
##### :isAnimating()
> Returns true/false depending on whether the element is in the process of any animation.
##### :setBorderColor(table color)
> Set the border color of your element to a new color. Default is white.
##### :getBorderColor()
> Returns a table of the current element border color.
##### :setClickable(boolean clickable)
> Set whether the element will register as a clickable element.
##### :isClickable()
> Returns whether the element is clickable.
##### :setColor(table color)
> Set the color of your element as a new color. Default is white.
##### :getColor()
> Returns a table of the current element color.
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
##### :setHeight(number height)
> Set the height of the current element
##### :getHeight()
> Get the height of the current element
##### :setHollow(boolean hollow)
> Sets whether an element is detected as hollow. When an element is hollow, it will allow the user to click through it,<br>
> while also triggering its own onClick() function.
##### :getHollow()
> Returns whether an element is hollow.
##### :isHovered()
> Returns whether an element is hovered.
##### :setMoveable(boolean canMove)
> Set whether an element is moveable.
##### :getMoveable()
> Get whether the element is moveable.
##### :setOpacity(number opacity)
> Set the opacity of the current element
##### :getOpacity()
> Get the opacity of the current element
##### :getParent()
> Returns the parent GUI element of the current element.
##### :setUseBorder(boolean useBorder)
> Set whether the element should have a border.
##### :getUseBorder()
> Get whether the element has a border.
##### :setWidth(number width)
> Set the width of the current element.
##### :getWidth()
> Get the width of the current element.
##### :setX(number x)
> Set the X position of the current element.
##### :getX()
> Get the X position of the current element.
##### :setY(number y)
> Set the Y position of the current element.
##### :getY()
> Get the Y position of the current element.
##### :setZ(number z)
> Set the Z position of the current element.
##### :getZ()
> Get the Z position of the current element.
## Object Manipulation
These functions are used for animating, enabling, and disabling elements.
##### :animateToColor(table color, number speed)
> Animate the current element to a new color, at the provided speed, or at 2s without a speed given.
##### :animateBorderToColor(table color, number speed)
> Animate the current element to a new border color, at the provided speed, or at 2s without a speed given.
##### :animateToPosition(number x, number y, number speed)
> Animate the current element to a new position, at the provided speed, or at 2s without a speed given.
##### :animateToOpacity(number opacity, number speed)
> Animate the current element to a new opacity, at the provided speed, or at 2s without a speed given.
##### :disable()
> Fully disable and hide the element.
##### :enable()
> Enable and show the element if it was hidden.
##### :fadeIn()
> Fade the element in from X opacity to full 1.0 opacity.
##### :fadeOut(boolean disableClick, boolean haltAnimations)
> Fade the element out to 0 opacity.
> <br>`disableClick` will prevent the API from performing click operations on the element while it is faded out.
> <br>`haltAnimations` will stop the element in its animation state and fade out to 0 opacity.
##### :startAnimation()
> Resumes any halted animations.
##### :stopAnimation()
> Halts any currently progressing animations.
