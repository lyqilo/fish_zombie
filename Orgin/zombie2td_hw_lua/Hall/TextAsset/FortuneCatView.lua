
local CC = require("CC")
local FortuneCatView = CC.uu.ClassView("FortuneCatView")

function FortuneCatView:ctor(param)

	self:InitVar(param);
end

function FortuneCatView:InitVar(param)
    self.param = param
    self.needSkin = 6
    self.WareId1 = "30037"
    self.WareId2 = "30038"
    self.WareId3 = "30036"
	self.language = self:GetLanguage()
    self.propfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.rewardCfg = {{id = 46,count = "x120"},{id = 2,count = "x150K"},{id = 10012,count = "x1"},
                      {id = 1109,count = "x1"},{id = 10011,count = "x1"},{{id = 1007,count = "x1"},{id = 1035,count = "x1"},{id = 1012,count = "x1"}},
                    }
end

function FortuneCatView:OnCreate()
    self:InitNode()
    self:InitView()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param);
    self.viewCtr:OnCreate();
end

function FortuneCatView:InitNode()
    self.RewardPanel = self:FindChild("View/RewardPanel")
    self.RewardSpin = self:FindChild("View/RewardPanel/RewardAnim"):GetComponent("SkeletonGraphic")
    self.NormalEffect = self.RewardPanel:FindChild("RewardAnim/EffectNode/Normal")
    self.BubbleAni = self:FindChild("View/UI/Bubble"):GetComponent("Animator")

    self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("View/MarqueeNode"),TextPos = 1.5})
    self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
end

function FortuneCatView:InitView()
    self:FindChild("View/UI/RightCat/Tip1").text = self.language.Tip1
    self:FindChild("View/UI/Tip2/Text").text = self.language.Tip2
    self:FindChild("View/UI/Tip3").text = self.language.Tip3
    self:FindChild("View/Btn/Lottery_Left/Text").text = self.language.Lottery1
    self:FindChild("View/Btn/Lottery_Left/Price").text = self.wareCfg[self.WareId1].Price
    self:FindChild("View/Btn/Lottery_Right/Text").text = self.language.Lottery2
    self:FindChild("View/Btn/Lottery_Right/Price").text = self.wareCfg[self.WareId2].Price
    self:FindChild("View/Btn/Buy/Pay/Text").text = self.language.BuySkin
    self:FindChild("View/Btn/Buy/Pay/Price").text = self.wareCfg[self.WareId3].Price
    self:FindChild("CompoundPanel/Hall/Btn_CatchFish_2/Text").text = self.language.CatchFish_2
    self:FindChild("CompoundPanel/Hall/Btn_CatchFish_4/Text").text = self.language.CatchFish_4
    self:FindChild("CompoundPanel/Hall/Btn_Airplane/Text").text = self.language.Airplane
    self:FindChild("CompoundPanel/Game/Btn_Use/Text").text = self.language.OK
    self:FindChild("View/Btn/Buy/Compound/Text").text = self.language.Compound
    self:FindChild("View/Btn/Buy/Compound/Gray/Text").text = self.language.CompoundSucceed

    for i,v in ipairs(self.rewardCfg) do
        if i == 6 then
            for j,tab in ipairs(v) do
                self:SetImage(self:FindChild("View/UI/Bubble/"..i.."/Image"..j),self.propfg[tab.id].Icon)
                self:FindChild("View/UI/Bubble/"..i.."/Text"..j).text = tab.count
            end
        else
            self:SetImage(self:FindChild("View/UI/Bubble/"..i.."/Image"),self.propfg[v.id].Icon)
            self:FindChild("View/UI/Bubble/"..i.."/Text").text = v.count
        end
    end

    self:RefreshDisplay()
end

function FortuneCatView:InitClickEvent()
    self:AddClick(self:FindChild("View/Btn/ExplainBtn") , function() self:OpenExplainView() end,nil,true)
    self:AddClick(self:FindChild("View/Btn/Lottery_Left") , function() self:ReqBuy(self.WareId1) end,nil,true)
    self:AddClick(self:FindChild("View/Btn/Lottery_Right") , function() self:ReqBuy(self.WareId2) end,nil,true)
    self:AddClick(self:FindChild("View/Btn/Buy/Pay") , function() self:ReqBuy(self.WareId3) end,nil,true)
    self:AddClick(self:FindChild("View/Btn/Buy/Compound") , function() self:ReqExchange() end,nil,true)
    self:AddClick(self:FindChild("View/Btn/Buy/Compound/Gray") , function() CC.ViewManager.ShowTip(self.language.CompoundSucceed) end)
    self:AddClick(self:FindChild("CompoundPanel/Hall/Btn_CatchFish_2") , function() self:EnterGame(3002) end,nil,true)
    self:AddClick(self:FindChild("CompoundPanel/Hall/Btn_CatchFish_4") , function() self:EnterGame(3005) end,nil,true)
    self:AddClick(self:FindChild("CompoundPanel/Hall/Btn_Airplane") , function() self:EnterGame(3007) end,nil,true)
    self:AddClick(self:FindChild("CompoundPanel/Game/Btn_Use") , function() self:HideCompoundPanel() end,nil,true)
    self:AddClick(self:FindChild("CompoundPanel/ClosePanel") , function() self:HideCompoundPanel() end,nil,true)
end

function FortuneCatView:OpenExplainView()
	local data = {
		title = self.language.explainTitle,
		content = self.language.explainContent,
	}
	CC.ViewManager.Open("CommonExplainView", data)
end

function FortuneCatView:ShowActTime(actTime)
	self:FindChild("View/UI/ActTime").text = string.format(self.language.ActTime,actTime)
end

function FortuneCatView:ReqBuy(WareId)
    if self.isReqBuy then 
        log("请求购买中……")
        return 
    end

    if WareId == self.WareId3 then
        if CC.Player.Inst():GetSelfInfoByKey("EPC_Cat_Ticket_1109") >= self.needSkin or CC.Player.Inst():GetSelfInfoByKey("EPC_Cat_Battery_1110") >= 1 then
            return
        end
    end
   
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.wareCfg[WareId].Price then
        self.isReqBuy = true
        CC.Request("ReqBuyWithId",{WareId = WareId, ExchangeWareId = WareId},function() self.isReqBuy = false end,function() self.isReqBuy = false end)
    else
        if self.walletView then
            self.walletView:SetBuyExchangeWareId(WareId)
            self.walletView:PayRecharge()
        end
    end
end

function FortuneCatView:ReqExchange()
    if CC.Player.Inst():GetSelfInfoByKey("EPC_Cat_Battery_1110") > 0 then return end

    local param = {}
    param.ID = 7
    param.Amount = 1
    param.GameId = CC.ViewManager.GetCurGameId() or 1
	param.GroupId = CC.ViewManager.GetCurGroupId() or 0
    CC.Request("ReqExchange",param) 
end

function FortuneCatView:EnterGame(GameId)
    CC.HallUtil.CheckAndEnter(GameId, nil, function()
        CC.ViewManager.CloseAllOpenView()
    end)
end

function FortuneCatView:StartLottery(Rewards)
    if self.lotterying then return end
    self.lotterying = true

    CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, false)
    self:SetCanClick(false)
    self.BubbleAni:Play("Bubble_Close")
    local NiuDanSpin = self:FindChild("View/UI/NiuDanAnim"):GetComponent("SkeletonGraphic")
    self:DelayRun(0.7,function()
        CC.Sound.StopBackMusic()
        CC.Sound.PlayHallEffect("gs_niudan")
        if NiuDanSpin.AnimationState then
            NiuDanSpin.AnimationState:ClearTracks()
            NiuDanSpin.AnimationState:SetAnimation(0, "stand2", false)
        end
        local LotteryFun = nil
        LotteryFun = function ()
            CC.Sound.PlayHallEffect("gs_reward")
            self:PlayRewardAnim(Rewards)
            NiuDanSpin.AnimationState:ClearTracks()
            NiuDanSpin.AnimationState:SetAnimation(0, "stand1", true)
            NiuDanSpin.AnimationState.Complete =  NiuDanSpin.AnimationState.Complete - LotteryFun
        end
        NiuDanSpin.AnimationState.Complete =  NiuDanSpin.AnimationState.Complete + LotteryFun
    end)
end

function FortuneCatView:PlayRewardAnim(Rewards)
    self.RewardPanel:SetActive(true)
    self.RewardSpin:SetActive(true)
    if self.RewardSpin.AnimationState then
        self.RewardSpin.AnimationState:ClearTracks()
        self.RewardSpin.AnimationState:SetAnimation(0, "stand4", false)
	end
	self.NormalEffect:SetActive(true)
	local RewardFun = nil
    RewardFun = function ()
        self:ShowReward(Rewards)
        self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete - RewardFun
	end
    self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete + RewardFun
end

function FortuneCatView:ShowReward(Rewards)
	if self.RewardSpin.AnimationState then
        self.RewardSpin.AnimationState:ClearTracks()
        self.RewardSpin.AnimationState:SetAnimation(0, "stand", false)
    end
    self:DelayRun(0.016,function ()
        CC.Sound.PlayHallBackMusic("BGM_SelectGiftCollection")
		self.RewardSpin:SetActive(false)
		self.NormalEffect:SetActive(false)
        self.RewardPanel:SetActive(false)
        self.BubbleAni:Play("Bubble_Idle")
        CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, true)
        self:SetCanClick(true)
        self.lotterying = false
        CC.ViewManager.OpenRewardsView({items = Rewards,callback = function() self:RefreshDisplay() end})
    end)
end

function FortuneCatView:RefreshDisplay()
    if CC.uu.IsNil(self.transform) then return end

    local SkinNum = CC.Player.Inst():GetSelfInfoByKey("EPC_Cat_Ticket_1109")
    local Battery = CC.Player.Inst():GetSelfInfoByKey("EPC_Cat_Battery_1110")
    self:FindChild("View/UI/RightCat/Num").text = string.format("%s/%s",SkinNum,self.needSkin)
   
    local active = SkinNum < self.needSkin and Battery <= 0
    self:FindChild("View/Btn/Buy/Pay"):SetActive(active)
    self:FindChild("View/Btn/Buy/Compound"):SetActive(not active)

    self:FindChild("View/Btn/Buy/Compound/Gray"):SetActive(Battery > 0)
end

function FortuneCatView:ShowCompoundPanel()
    CC.Sound.StopBackMusic()
    CC.Sound.PlayHallEffect("gs_battery")
    local isHall = CC.ViewManager.IsHallScene()
    self:FindChild("CompoundPanel"):SetActive(true)
    self:FindChild("CompoundPanel/Hall"):SetActive(isHall)
    self:FindChild("CompoundPanel/ClosePanel"):SetActive(isHall)
    self:FindChild("CompoundPanel/Game"):SetActive(not isHall)
end

function FortuneCatView:HideCompoundPanel()
    CC.Sound.PlayHallBackMusic("BGM_SelectGiftCollection")
    CC.Sound.StopEffect()
    self:FindChild("CompoundPanel"):SetActive(false)
    self:RefreshDisplay()
end

function FortuneCatView:ActionIn()
    self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
end

function FortuneCatView:ActionOut()
    self:Destroy()
end

function FortuneCatView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil;
    end
    if self.walletView then
        self.walletView:Destroy()
        self.walletView = nil
    end
    if self.Marquee then
        self.Marquee:Destroy()
        self.Marquee = nil
    end
    CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, true)
end

return FortuneCatView