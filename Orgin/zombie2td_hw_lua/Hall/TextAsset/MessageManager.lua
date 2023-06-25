local CC = require("CC")
local DTproto = CC.proto
local LotteryProto = require "Model/LotteryNetwork/game_message_pb"
local MessageConfig = require "Model/LotteryNetwork/MessageConfig"
local MessageManager = CC.class2("MessageManager")

--静态方法
local _inst = nil

local _getProConfig
local _safeCheck
function MessageManager.Inst()
	if not _inst then
		_inst = MessageManager.new()
	end
	return _inst
end
function MessageManager.Release()
    _inst = nil
end


function MessageManager:ctor()
    self:init()
end

function MessageManager:init()
	_safeCheck()
end

--根据名称号获取协议配置
--name[string or int]
function MessageManager:GetRequestProConfig(name)
	return MessageConfig.request[name]
end

--根据协议号获取协议配置
--name[string or int]
function MessageManager:GetOnpushProConfig(ops)
	return MessageConfig.onPush[ops]
end


function MessageManager:GetpushProConfig(name)
	
end

--字段安全检测
function _safeCheck()
	log("_safeCheck")
	for proType,pros in pairs(MessageConfig) do
		for name,pro in pairs(pros) do
			if proType == "request" then
				name = pro.name
				local msg = LotteryProto[name] or DTproto.client_pb[name]
				if msg == nil then
					logError("--------------协议不存在：" .. name)
				end
			end
			if proType == "onPush" then
				local msg = LotteryProto[pro.Name] or DTproto.client_pb[pro.Name]
				if msg == nil then
					logError("--------------协议不存在：" .. pro.Name)
				end
				if pro.CallBack == nil then
					logError(string.format( "MessageConfig.%s.[%d].CallBack is null",proType,name))
				end
			end
		end
	end
end



return {
	Inst = MessageManager.Inst,
	Release = MessageManager.Release,
}