local CC = require("CC")

local DefineCenter = CC.class2("DefineCenter")

local _defineCenter = nil
function DefineCenter.Inst()
	if not _defineCenter then
		_defineCenter = DefineCenter.new()
	end
	return _defineCenter
end

function DefineCenter:ctor()
	self:init()
end

function DefineCenter:init()
	--这里加载所有需要用到的配置列表
	self.defineData = {}

	self.defineData.RankDefine = require "Model/Define/RankDefine"

	self.defineData.SignDefine = require "Model/Define/SignDefine"

	self.defineData.StoreDefine = require "Model/Define/StoreDefine"

	self.defineData.PersonalInfoDefine = require "Model/Define/PersonalInfoDefine"

	self.defineData.LoginDefine = require "Model/Define/LoginDefine"

	self.defineData.HallDefine = require "Model/Define/HallDefine"

	self.defineData.ResourceDefine = require "Model/Define/ResourceDefine"
end

function DefineCenter:getConfigData()
	return self.defineData
end

function DefineCenter:getConfigDataByKey(key)
	return self.defineData[key]
end

return DefineCenter
