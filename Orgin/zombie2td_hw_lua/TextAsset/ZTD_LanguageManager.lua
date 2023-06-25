local GC = require("GC")
local ZTD = require("ZTD")

local M = {};

--当前语言类型
local _type = "Thai"

function M.GetType()

	if GC.DebugDefine.GetLanguageDebugState() then
		_type = "Chinese"
	else
		_type = "Thai"
	end

	return _type
end

function M.GetLanguage(fileName)
	
	if GC.DebugDefine.GetLanguageDebugState() then
		_type = "Chinese"
	else
		_type = "Thai"
	end

	return require("_ZTD_Model/Language/".._type.."/"..fileName);
end

return M