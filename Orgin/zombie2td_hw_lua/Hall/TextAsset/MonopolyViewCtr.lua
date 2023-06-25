local CC = require("CC")
local MonopolyViewCtr = CC.class2("MonopolyViewCtr")

function MonopolyViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function MonopolyViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
end

function MonopolyViewCtr:OnCreate()
    --展示奖励列表
    self.RewardsList = {}
    --真实获得奖励
    self.ChooseRewardProp = {}
    --地图是否升级
    self.IsUpgrade = false
    --是否中jp
    self.IsJPPool = false
    --是否可以玩
    self.CanPlay = true
    self.PlayAnim = false
	self:RegisterEvent()
    self:Req_UW_MonopolyGetUserInfo()
    self:ReqGfitList()
end

function MonopolyViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.MonopolyInfoResp,CC.Notifications.NW_Req_UW_MonopolyGetUserInfo)
    CC.HallNotificationCenter.inst():register(self,self.MonopolyPlayResp,CC.Notifications.NW_Req_UW_MonopolyPlay)
    CC.HallNotificationCenter.inst():register(self,self.GfitListResp,CC.Notifications.NW_Req_UW_MonopolyGiftBagList)
    CC.HallNotificationCenter.inst():register(self,self.MonopolyGiftChangeResp,CC.Notifications.NW_Req_UW_MonopolyGiftChange)
    CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
end

function MonopolyViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function MonopolyViewCtr:OnChangeSelfInfo(props)
	local isNeedRefresh = false
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_TenGift_Sign_97 then
			isNeedRefresh = true;
		end
	end
	if not isNeedRefresh then return end;
	self.view:SetWaterNum()
end

--基础信息
function MonopolyViewCtr:Req_UW_MonopolyGetUserInfo()
    self.IsUpgrade = false
    self.IsJPPool = false
	CC.Request("Req_UW_MonopolyGetUserInfo", {GameId = CC.shared_enums_pb.AE_Breakthrough_party})
end

function MonopolyViewCtr:MonopolyInfoResp(err, param)
    log(CC.uu.Dump(param, "Req_UW_MonopolyGetUserInfo:"))
    if err == 0 then
        self.view:SetViewInfo(param)
    end
end
--礼包列表
function MonopolyViewCtr:ReqGfitList()
    CC.Request("Req_UW_MonopolyGiftBagList", {GameId = CC.shared_enums_pb.AE_Breakthrough_party})
end

function MonopolyViewCtr:GfitListResp(err, param)
    log(CC.uu.Dump(param, "Req_UW_MonopolyGiftBagList:"))
    if err == 0 then
        if param.UWMonopolyGiftBags then
            local data = {}
            for k, v in ipairs(param.UWMonopolyGiftBags) do
                data[k] = v
            end
            self.view:InitGiftInfo(data)
        end
    end
end
--投骰
function MonopolyViewCtr:ReqPlayerSpin()
    if not self.CanPlay or self.PlayAnim then return end
    self.CanPlay = false
    CC.Request("Req_UW_MonopolyPlay", {GameId = CC.shared_enums_pb.AE_Breakthrough_party})
end

function MonopolyViewCtr:MonopolyPlayResp(err, param)
    log(CC.uu.Dump(param, "Req_UW_MonopolyPlay:"))
    if err == 0 then
        self.view:PlayDiceAnimator(param.DicePoints)
        self.ChooseRewardProp = {}
        if param.ChooseRewardProp and param.ChooseRewardProp.PropID ~= 0 then
            self.ChooseRewardProp[1] = {}
            self.ChooseRewardProp[1].ConfigId = param.ChooseRewardProp.PropID
            self.ChooseRewardProp[1].Count = param.ChooseRewardProp.PropNum
            self.ChooseRewardProp[1].Type = param.ChooseRewardProp.Type
        end
        self.RewardsList = {}
        if param.RewardsList then
            for k, v in ipairs(param.RewardsList) do
                self.RewardsList[k] = {}
                self.RewardsList[k].ConfigId = v.PropID
                self.RewardsList[k].Count = v.PropNum
                self.RewardsList[k].Type = v.Type
            end
        end
        if param.CurrentJPPool and param.CurrentJPPool > 0 then
            self.view:SetJackPotNum(param.CurrentJPPool)
        end
        self.IsUpgrade = param.IsUpgrade
        self.IsJPPool = param.GainJPPoolResult
        if param.IsUpgrade then
            if param.GainValue > 0 then
                --地图升级博取jp
                local tab = {ConfigId = 2, Count = param.GainValue}
                table.insert(self.ChooseRewardProp, tab)
            end
            if param.HasRealObject then
                local tab = {ConfigId = param.RealObjectId, Count = 1}
                table.insert(self.ChooseRewardProp, tab)
            end
        end
    end
    self.CanPlay = true
end

function MonopolyViewCtr:MonopolyGiftChangeResp(err, param)
    log(CC.uu.Dump(param, "Req_UW_MonopolyGiftChange:"))
    if err == 0 then
        if param.PlusProgressBarCount and param.PlusProgressBarCount > 0 then
            self.view:SetProgress(param.PlusProgressBarCount)
        end
        self.ChooseRewardProp = {}
        if param.CurrentJPPool and param.CurrentJPPool > 0 then
            self.view:SetJackPotNum(param.CurrentJPPool)
        end
        self.IsUpgrade = param.IsUpgrade
        self.IsJPPool = param.GainJPPoolResult
        if param.IsUpgrade then
            if param.GainValue > 0 then
                --地图升级博取jp
                local tab = {ConfigId = 2, Count = param.GainValue}
                table.insert(self.ChooseRewardProp, tab)
            end
            if param.HasRealObject then
                local tab = {ConfigId = param.RealObjectId, Count = 1}
                table.insert(self.ChooseRewardProp, tab)
            end
            self.view:UpgradePlayAnim()
        end
    end
end

--获得神秘奖励信息(是否选择的牌)
function MonopolyViewCtr:GetRewardInfo(isSelect)
    if isSelect then
        return self.ChooseRewardProp[1]
    else
        return self.RewardsList[1]
    end
end

function MonopolyViewCtr:Destroy()
	self:unRegisterEvent()
end

return MonopolyViewCtr