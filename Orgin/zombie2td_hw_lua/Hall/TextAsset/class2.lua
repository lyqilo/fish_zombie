
local class2 = function(_name, _super)
	local name = _name
	local super = _super
	if type(_name) ~= "string" then
		--the _name must be string value
		name = nil
		super = nil
	end
	local class_type = {}
	class_type.ctor = false
	class_type.super = super

	local vtbl = {super = super, className = name}
	class_type.vtbl = vtbl
 
	setmetatable(class_type, {
	__index = function( t, k )
		return vtbl[k]
	end,
	__newindex = function(t, k, v)
		vtbl[k] = v
	end
	})
 
	if super then
		setmetatable(vtbl, {__index =
			function(t,k)
				local ret = super.vtbl[k]
				vtbl[k] = ret
				return ret
			end
		})
	end
	
 	class_type.new = function(...)
		local obj = {}
		setmetatable(obj, {__index = vtbl})
		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.ctor then
					c.ctor(obj, ...)
				end
			end

			create(class_type, ...)
		end
        obj.isClassObject = true
		return obj
	end

	return class_type
end

return class2