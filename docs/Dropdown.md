# Checkbox
The checkbox is designed to be used for taking user input on choices. A top use for the checkbox is for Poll option selection.<br>
Checkboxes can accept multiple selections, or be limited to a single selection. 
## Object Creation
```lua
local GUI = require("gui")
GUI:addColor({1,0,0,.5}, "alphaRed")
GUI:addColor({.92,.97,.92,1}, "eggshell")
local colors = GUI.color
local myFont = lg.newFont("res/font/thicktext.otf", 32)
local myCheckbox = GUI:addCheckbox("myCheckbox")
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
```
## API Callbacks
This API brings several user defined callbacks which allow you to customize what happens when a user interacts with your elements.<br>
Any callback with an `event` paramter has a table provided to it with data accessible to the user. You can easily define these<br>
with 
```lua
myDropdown:registerEvent("onClick", function(self, target, event)
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
##### :onOptionClick(self, option, target, event) -- {text, width, height, x, y}, target, {x, y, button, istouch, presses}
> Triggered when a user clicks an option on a checkbox.
## Data Handling
These functions provide the ability to directly modify many variables of your elements. The way these work currently may change.<br>
The biggest change that may happen, is accepting additional parameter types. No old elements will be broken by updates.
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
var type | var name | var type | var name
---------|----------|----------|---------
table | borderColor | table | color
boolean | clickable | boolean | fixPadding / fix
number | height / h | userdata | image
boolean | keepOptions | string | label / text
table | labelColor | userdata | labelFont
table | labelPosition / labelPos | boolean | moveable
number | opacity | table | options
table | optionsColor | table | overlayColor
table | padding | boolean | round
number | roundRadius / radius | boolean | singleSelection / single
boolean | useBorder | number | width / w
number | x | number | y
number | z | string | default
boolean | closeOnUnfocus | | 
##### :fixPadding(boolean fix)
> Adjusts padding to be ignored on the top of first line, and ignore left padding on first element.
##### :getFixPadding()
> Get whether the element is fixing its padding.
##### :setFont(userdata font)
> Set the font of the element. Userdata font will be stored as an element font.
##### :getFont()
> Get the font of the element.
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
##### :setLabel(string label)
> Set the label of the current checkbox.
##### :getLabel()
> Get the label of the current checkbox.
##### :setLabelColor(table color)
> Set the label color of the current checkbox to a new color. Default is white.
##### :getLabelColor()
> Get the label color of the current checkbox.
##### :setLabelFont(userdata font)
> Set the label font of the current checkbox.
##### :getLabelFont()
> Get the label font of the current checkbox.
##### :setLabelPosition(table pos)
> Set the label position of the current checkbox.
##### :getLabelPosition()
> Get the label position of the current checkbox.
##### :setMoveable(boolean canMove)
> Set whether an element is moveable.
##### :getMoveable()
> Get whether the element is moveable.
##### :setOpacity(number opacity)
> Set the opacity of the current element
##### :getOpacity()
> Get the opacity of the current element
##### :addOption(string option)
> Add an option to the list of options availabe on your checkbox.
##### :removeOption(string option)
> Remove an option from the current checkbox.
##### :setOptionColor(table color)
> Set the option color of the current checkbox.
##### :getOptionColor()
> Get the option color of the current checkbox.
##### :setOptionPadding(table padding) [top, right, bottom, left]
> Set the padding for the current checkbox options.
##### :setOptionPaddingBottom(number padding)
> Set the bottom padding
##### :setOptionPaddingLeft(number padding)
> Set the left padding
##### :setOptionPaddingRight(number padding)
> Set the right padding
##### :setOptionPaddingTop(number padding)
> Set the top padding
##### :setOverlayColor(table color)
> Set the overlay color of the current checkbox.
##### :getOverlayColor()
> Get the overlay color of the current checkbox.
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
