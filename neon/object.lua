local function obj(t)
	t = t or {}
	t.__index = t
	t.init = t.init or t[1] or function() end
	return setmetatable(t, {__call = function(c, ...)
		local o = setmetatable({}, c)
		o:obj(...)
		return o
	end})
end

return setmetatable({obj = obj}, {__call = function(_,...) return obj(...) end})