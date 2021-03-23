local function new(t)
	t = t or {}
	t.__index = t
	t.init = t.init or t[1] or function() end
	return setmetatable(t, {__call = function(c, ...)
		local o = setmetatable({}, c)
		o:new(...)
		return o
	end})
end

return setmetatable({new = new}, {__call = function(_,...) return new(...) end})