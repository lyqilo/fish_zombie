local CC = require("CC")

--游戏语言管理
local LanguageManager = {}

--当前语言类型（暂且默认Chinese）Thai
local _type = "Thai"

function LanguageManager.GetType()

	if CC.DebugDefine.GetLanguageDebugState() then
		_type = "Chinese"
	else
		_type = "Thai"
	end

	return _type
end

function LanguageManager.GetLanguage(fileName)
	
	if CC.DebugDefine.GetLanguageDebugState() then
		_type = "Chinese"
	else
		_type = "Thai"
	end

	return require("Model/Language/".._type.."/"..fileName);
end

return LanguageManager