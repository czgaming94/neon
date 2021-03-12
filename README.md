# NEON [Newbie, Experienced, or Neither]
This API's goal is to make laying out your application GUI simple and efficient. The secondary goal of this API 
is to be as easy to grasp as possible for beginners, as well as users coming from other scripting languages. <br>
This API is based off of a modified version of the [standard metatable table.deepcopy function.](http://lua-users.org/wiki/CopyTable)
```lua
function gui:generate(item, copies, skip)
	if not self.enabled then return false end
	local copies = copies or {}
    local copy
    if type(item) == 'table' then
        if copies[item] then
            copy = copies[item]
        else
            copy = {}
            copies[item] = copy
            for orig_key, orig_value in next, item, nil do
				if skip and orig_key == skip then
					copy[skip] = {}
				else
					copy[self:generate(orig_key, copies, skip)] = self:generate(orig_value, copies, skip)
				end
            end
            setmetatable(copy, self:generate(getmetatable(item), copies, skip))
        end
    else
        copy = item
    end
    return copy
end
```
#### [If you aren't quite understanding how to start using the API, check out this quick starters guide!](https://github.com/czgaming94/love2d-gui/blob/main/docs/examples/MainMenu.md)
There are several different commonly used GUI tools brought with this API, as well as a few special ones.
### [Boxes](https://github.com/czgaming94/love2d-gui/blob/main/docs/Box.md)
![Box Image](https://github.com/czgaming94/love2d-gui/blob/main/docs/examples/box.png)<br>
The goal of the box object is for backgrounds, buttons, and HUD containers. This is the most commonly used type of object in a GUI.
### [Text](https://github.com/czgaming94/love2d-gui/blob/main/docs/Text.md)
![Text Image](https://github.com/czgaming94/love2d-gui/blob/main/docs/examples/text.png)<br>
The text object has a few abilities. It can be treated as regular static text, or it can be treated as a typewriter, 
and given syntax coding to morph and affect how the text is displayed.
### [Checkboxes](https://github.com/czgaming94/love2d-gui/blob/main/docs/Checkbox.md)
![Checkbox Image](https://github.com/czgaming94/love2d-gui/blob/main/docs/examples/checkbox.png)<br>
The checkbox is designed to be used for taking user input on choices. A top use for the checkbox is for Poll option selection. 
Checkboxes can accept multiple selections, or be limited to a single selection.
### [Dropdowns](https://github.com/czgaming94/love2d-gui/blob/main/docs/Dropdown.md)
![Dropdown Image](https://github.com/czgaming94/love2d-gui/blob/main/docs/examples/dropdown.png)<br>
The dropdown is just as it sounds; A menu of options that drops down when clicked on. This is commonly used for toggling between user input options, form submissions, etc.
### [Radials](https://github.com/czgaming94/love2d-gui/blob/main/docs/Radial.md)
__Coming Soon__
### [Sliders](https://github.com/czgaming94/love2d-gui/blob/main/docs/Slider.md)
__Coming Soon__
### [Textfields](https://github.com/czgaming94/love2d-gui/blob/main/docs/Textfield.md)
__Coming Soon__
