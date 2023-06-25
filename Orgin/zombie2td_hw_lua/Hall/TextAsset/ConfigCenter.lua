
local CC = require("CC")

local ConfigCenter = CC.class2("ConfigCenter")

local CSVConfigFile = {
	"Task",				--头衔任务
	"Prop",				--道具配置
	"Level",			--vip等级
	"Ware",				--支付相关配置
	"VIPRights",		--vip权益相关配置
	"Sign",				--每日登录奖励
	"Rewards",
	"ActiveRankReward",
	"DailyTurntable",	--每日转盘配置
	"OnlineWelfare",	--在线福利配置
	"ChannelSwitch",	--渠道功能开关配置
	"Backpack",			--背包配置
	"NewbieTask",		--新手任务
	"VIPNewRights",		--vip新权益相关配置
	"VIPUnlock",		--vip权益功能解锁配置
	"PhysicalShop",		--实物商城
	"CompositeBase",		--合成系统物件配置
	"CompositeAssembly",		--合成系统组合配置
	"CompositeJPConfig",		--合成系统JP配置
	"AgentConfig",		--高v相关配置
	"PhysicalExchangeTips",--实物商城兑换说明
	"AnniversaryTurntable",		--周年庆幸运转盘
	"WorldCup",				--世界杯相关配置
}

local _configCenter = nil
function ConfigCenter.Inst()
	if not _configCenter then
		_configCenter = ConfigCenter.new()
	end
	return _configCenter
end

function ConfigCenter:ctor()
	self:init()
end

function ConfigCenter:init()
	--这里加载所有需要用到的配置列表
	self.configData = {}

	self.configData.ChatConfig = require "Model/Config/ChatConfig"

	self.configData.SwitchMap = require "Model/Config/SwitchMap"

	self.configData.BuglySceneMap = require "Model/Config/BuglySceneMap"

	self.configData.FundConfig = require "Model/Config/FundConfig"

	self.configData.ShakeConfig = require "Model/Config/ShakeConfig"

	self.configData.SDKConfig = require "Model/Config/SDKConfig"

	self.configData.HeadPortrait = require "Model/Config/HeadPortrait"

	self.configData.DailyLotteryConfig = require "Model/Config/DailyLotteryConfig"

	self.configData.WebConfig = require "Model/Config/WebConfig"

	self.configData.MarsTaskConfig = require "Model/Config/MarsTaskConfig"

	self.configData.NewPayGiftConfig = require "Model/Config/NewPayGiftConfig"

	self.configData.CapsuleConfig = require "Model/Config/CapsuleConfig"

	self.configData.BatteryRankConfig = require "Model/Config/BatteryRankConfig"
	self.configData.MonopolyConfig = require "Model/Config/MonopolyConfig"

	for _,name in ipairs(CSVConfigFile) do
		local file = require("Model/Config/CSVExport/"..name);
		self.configData[name] = self:FormatConfig(file);
	end

	--文字配置表
	self:organizeLanguageCfg()
end

function ConfigCenter:FormatConfig(table)
	local tb = {}
	--把配置表内的子表Id作为key赋到一张新表(方便通过Id直接取到表内数据,无需每次遍历)
	for _, v in pairs(table) do
		if v then
			local id = v.Id or v.ID;
			if id then
				tb[id] = v;
			end
		end
	end
	return tb;
end

function ConfigCenter:organizeLanguageCfg()
	--切换语言重新调用该方法
	local languageCfg = CC.LanguageManager.GetLanguage("L_Description");
	self.configData.languageCfg = {}
	for i = 1,#languageCfg do
		local key = languageCfg[i].Title
		local value = languageCfg[i].Desc
		self.configData.languageCfg[key] = value
	end
end

function ConfigCenter:getDescByKey(key)
	return self.configData.languageCfg[key] or ""
end

function ConfigCenter:getConfigDataByKey(key)
	return self.configData[key]
end

return ConfigCenter