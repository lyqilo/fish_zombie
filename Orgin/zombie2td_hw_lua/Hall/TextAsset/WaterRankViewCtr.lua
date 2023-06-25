local CC = require("CC")
local WaterRankViewCtr = CC.class2("WaterRankViewCtr")

function WaterRankViewCtr:ctor(view,param)
	self:InitVar(view,param)
end

function WaterRankViewCtr:InitVar(view,param)
	self.view = view
	self.param = param or {}
	self.rankData = {}
	self.boxData = {}
end

function WaterRankViewCtr:OnCreate()
	self:RegisterEvent()
	self:OnReqRankInfo()
end

function WaterRankViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqWaterRankDataRsp,CC.Notifications.NW_ReqWaterRankData)
    CC.HallNotificationCenter.inst():register(self,self.ReqOpenPrizeRsq,CC.Notifications.NW_ReqOpenPrize)
end

function WaterRankViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function WaterRankViewCtr:OnReqRankInfo()
	CC.Request("ReqWaterRankData", {GameType = self.view.gameType})
end

function WaterRankViewCtr:ReqWaterRankDataRsp(err,result)
	if err ~= 0 then
		logError("ReqWaterRankData err:"..err)
		self:OnShowErrorTips(err)
		return
	end
    log(CC.uu.Dump(result, "ReqWaterRankData"))
	self.rankData = result
	self.view:RefreshRankList(result)
    self.boxData = result.PlayerTreasure
    self.view:RefreshKeyGiftProgress(result.PlayerTreasure)
end

function WaterRankViewCtr:ReqOpenPrize(index)
	local data = {}
	data.treasureID = tonumber(index)
    data.GameType = self.view.gameType
    log(CC.uu.Dump(data))
	CC.Request("ReqOpenPrize",data)
end

function WaterRankViewCtr:ReqOpenPrizeRsq(err, data)
    log(CC.uu.Dump(data, "ReqOpenPrize"))
    if err == 0 then
        local param = {}
        param.items = {{ConfigId = data.PropID, Count = data.PropNum}}
        local cb = function ()
            self:OnReqRankInfo()
        end
        param.callback = cb
        CC.ViewManager.OpenRewardsView(param)
    else
        self:OnShowErrorTips(err)
    end
end

function WaterRankViewCtr:OnShowErrorTips(err)
	if err == -1 then
		local tips = CC.LanguageManager.GetLanguage("L_Common").tip9
		CC.ViewManager.ShowTip(tips)
	end
end

function WaterRankViewCtr:OnDestroy()
	self:UnRegisterEvent()
end

return WaterRankViewCtr