
local CC = require("CC")

local DataMgrCenter = CC.class2("DataMgrCenter")

local dataMgrCenter = nil
function DataMgrCenter.Inst()
	if not dataMgrCenter then
		dataMgrCenter = DataMgrCenter.new()
	end
	return dataMgrCenter
end

function DataMgrCenter:ctor()

	self.dataMgrList = {}

end

local DefineMap = {
	PropDataMgr = "PropDataMgr",

	Mail = "MailDataMgr",

	WebUrl = "WebUrlDataMgr",

	Game = "GameDataMgr",

	Agent = "AgentDataMgr",

	Activity = "ActivityDataMgr",

	ArenaData = "ArenaDataMgr",

	Update = "UpdateDataMgr",

	Friend = "FriendDataMgr",

	ActiveRankData = "ActiveRankDataManager",

	RankData = "RankDataManager",

	GiftData = "GiftDataMgr",

	Silent = "SilentDataMgr",

	HeadIcon = "HeadIconDataMgr",

	FundData = "FundDataManager",

	FortunebagData = "FortunebagDataManager",

	SplashingData = "SplashingDataManager",

	NoticeData = "NoticeDataMgr",

	ShakeData = "ShakeDataManager",

	SignData = "SignDataManager",

	RealStoreData = "RealStoreDataMgr",

	AchievementGift = "AchievementGiftDataMgr",

	InformationData = "InformationDataMgr",

	OnlineWelfareDataMgr = "OnlineWelfareDataMgr",

	SwitchDataMgr = "SwitchDataMgr",

	BlessData = "BlessDataMgr",

	DailyLotteryDataMgr = "DailyLotteryDataMgr",

	SignActivityDataMgr = "SignActivityDataMgr",

	NoviceDataMgr = "NoviceDataMgr",

	WorldCupData = "WorldCupDataMgr",
}

function DataMgrCenter:GetDataByKey(key)
	if self.dataMgrList[key] == nil then
		self.dataMgrList[key] = require("Model/Data/"..DefineMap[key])
	end
	return self.dataMgrList[key];
end

return DataMgrCenter