# NEON [Newbie, Experienced, or Neither]
This API's goal is to make laying out your application GUI simple and efficient. The secondary goal of this API 
is to be as easy to grasp as possible for beginners, as well as users coming from other scripting languages. <br>
This API is based off of a modified version of the [standard metatable table.deepcopy function.](http://lua-users.org/wiki/CopyTable).<br>
> The deepcopy function creates a special instance of a table, allowing the user to create multiple instance
> without overwriting the original.
### GUI Handles
The GUI lib brings a few handles and callbacks that allow the user to have full control.
##### :new()
> Create a new instance of the GUI. This is used for when you do not want every element in one GUI.
> An example of two GUIs would be a `mainMenu` and `pauseMenu`
##### :duplicate(item)
> Creates a new instance of an already existing item.
##### :setUse255(use255)
> Tell the GUI whether you are using a 255 color scheme. It will automatically divide your colors for you.
##### :animateToColor(object, color, speed)
> Animate an object through the GUI parent, to a specified color, at an optional speed. Speed defaults to `2`
##### :animateToBorderColor(object, color, speed)
> Animate an object through the GUI parent, to a specified border color, at an optional speed. Speed defaults to `2`
##### :animateToPosition(object, position, speed)
> Animate an object through the GUI parent, to a specified position, at an optional speed. Speed defaults to `2`
##### :animateToOpacity(object, color, speed)
> Animate an object through the GUI parent, to a specified opacity, at an optional speed. Speed defaults to `1`
##### :addColor(color, name)
> Add a color to the global GUI interface with the given name. Call with `Neon.color("name")`
##### :add(type, name)
> Add an element to the GUI interface with the given name. Call with `Neon:child("name")`
##### :addBox(name)
> Add a box element to the GUI interface.
##### :addText(name)
> Add a text element to the GUI interface.
##### :addCheckbox(name)
> Add a checkbox element to the GUI interface.
##### :addDropdown(name)
> Add a dropdown element to the GUI interface.
##### :addSlider(name)
> __Coming Soon__
##### :addRadials(name)
> __Coming Soon__
##### :addTextfield(name)
> Add a textfield element to the GUI interface.
##### :enable()
> Re-enable a GUI to display.
##### :disable()
> Fully disable the GUI from displaying any elements inside it.
##### :getHeld()
> Returns a table of items that are held by the mouse. Only works with `moveable = true` on the object.
##### :enableAll()
> Turn on all GUI's and re-enable all elements.
##### :disableAllElements(only)
> Fully disable every element, if only is true then it will only disable in the specific GUI.
##### :registerEvent(eventType, object, func, target, eventName)
> Specify an callback to trigger on a specific event, on a specific target.<br>
> `eventType` will be such as `"onClick"` or `"onHoverEnter"`.<br>
> `object` is the element that the callback will happen on.<br>
> `func` is the function defined by the user that will happen when the callback is triggered.<br>
> `target` is the arg sent to the callback as `target` to be used as the user wants.<br>
> `eventName` allows the user to name a specific event, such as an `"onClick"` having a `"quitGame"` tag.
##### :removeEvent(eventType, object, eventName)
> Remove an event from an object.
##### :registerGlobalEvent(eventType, objectType, func, target, eventName)
> Specify an callback to trigger on a specific event, on a specific target.
> `eventType` will be such as `"onClick"` or `"onHoverEnter"`.
> `objectType` is the type of element that the callback will happen on, such as "box".
> `func` is the function defined by the user that will happen when the callback is triggered.
> `target` is the arg sent to the callback as `target` to be used as the user wants.
> `eventName` allows the user to name a specific event, such as an `"onClick"` having a `"quitGame"` tag.
##### :removeGlobalEvent(eventType, object, eventName)
> Remove an event from the global callback system.
### Elements
There are several different commonly used GUI tools brought with this API, as well as a few special ones.
[Boxes](https://github.com/czgaming94/neon/blob/main/docs/Box.md) | [Text](https://github.com/czgaming94/neon/blob/main/docs/Text.md) | [Checkboxes](https://github.com/czgaming94/neon/blob/main/docs/Checkbox.md) | [Dropdowns](https://github.com/czgaming94/neon/blob/main/docs/Dropdown.md) | [Radials](https://github.com/czgaming94/neon/blob/main/docs/Radial.md) | [Sliders](https://github.com/czgaming94/neon/blob/main/docs/Slider.md) | [Textfields](https://github.com/czgaming94/neon/blob/main/docs/Textfield.md)
------|------|------------|-----------|---------|---------|-----------
The goal of the box object is for backgrounds, buttons, and HUD containers. This is the most commonly used type of object in a GUI. | The text object has a few abilities. It can be treated as regular static text, or it can be treated as a typewriter, and given syntax coding to morph and affect how the text is displayed. | The checkbox is designed to be used for taking user input on choices. A top use for the checkbox is for Poll option selection. Checkboxes can accept multiple selections, or be limited to a single selection. | The dropdown is just as it sounds; A menu of options that drops down when clicked on. This is commonly used for toggling between user input options, form submissions, etc. | __Coming Soon__ | __Coming Soon__ | Textfields are as they sound. A field that text can be put. Either you the dev, can put the text that will be there in, or, you can allow the user to type into it. To disable user typing, add `useable = false` to the `setData` function, or use `:useable(false)` on the textfield object.
#### [If you aren't quite understanding how to start using the API, check out this quick starters guide!](https://github.com/czgaming94/neon/blob/main/docs/examples/StartGuide.md)