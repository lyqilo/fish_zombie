
--[[
    该文件内容将逐渐被class2.lua所取代
]]

--全局类申明
local _class = {}
local function class(name, super)
    logError("！！！警告！！！不建议使用该class创建类，请使用class2.lua\n" .. debug.traceback())
    if type(name) ~= "string" then
        super = name
        name = nil
    end
    local class_type = {}
    class_type.ctor = false
    class_type.super = super

    class_type.new = function(...)
        local obj = {}
        setmetatable(obj, {__index = _class[class_type]})
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

    local vtbl = {super = super, className = name}
    _class[class_type] = vtbl
 
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
                local ret = _class[super][k]
                vtbl[k] = ret
                return ret
            end
        })
    end

    if name then
        _G[name] = class_type
    end
    return class_type
end

--结构体
local function struct( data )
    data.new = function (self, object)
        object = object or {};
        setmetatable(object, self);
        self.__index = self;
        return object;
    end
    data.__call = data.new
    return data
end

--生成类的方法（来源于cocos，无法继承）
local setmetatableindex_ = nil
setmetatableindex_ = function(t, index)
    if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else
        local mt = getmetatable(t)
        if not mt then mt = {} end
        if not mt.__index then
            mt.__index = index
            setmetatable(t, mt)
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    end
end
local setmetatableindex = setmetatableindex_

local function classEx(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function",
                    classname));
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class",
                        classname));
                cls.__create = function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function() end
    end
    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        instance.isClassObject = true
        return instance
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end

    return cls
end

return {
    class = class,
    struct = struct,
    classEx = classEx
}