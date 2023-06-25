-- ************************************************************
-- @File: ViewDefine.lua
-- @Summary:ViewName枚举,用的是ViewCenter里面的View2FilePath的Key
-- @Version: 1.0
-- @Author: xxxxxx
-- @Date: 2023-04-26 16:24:53
-- ************************************************************
local CC = require("CC")
local ViewDefine = {}

local ViewMap = CC.ViewCenter.View2FilePath

local map = {}

setmetatable(
	ViewDefine,
	{
		__index = function(_, viewName)
			if ViewMap[viewName] then
				map[viewName] = viewName
				return map[viewName]
			else
				logError("ViewCenter.lua 中不存在 " .. (viewName or "nil") .. ", 请确认ViewName是否正确")
				return false
			end
		end
	}
)

return ViewDefine
