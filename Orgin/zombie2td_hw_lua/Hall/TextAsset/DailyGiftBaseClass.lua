local CC = require("CC")
local DailyGiftBaseClass = CC.uu.ClassView("DailyGiftBaseClass")

function DailyGiftBaseClass:ctor(content, language, isHall)
    self.content = content
    self.language = language
    self.isHall = isHall
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    self.activity = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
    self.openExplainView = false
    self.wareIdList = {}
    self.giftSourceList = {}
    self.panelView = {}
    --移动中
    self.moving = false
    self.curShowPanel = 1
    self.lastShowPanel = self.curShowPanel
    self:InitDailyGiftData()
end

function DailyGiftBaseClass:OnCreate(viewName)
    self.transform = CC.uu.LoadHallPrefab("prefab", viewName, self.content.transform);
    self.transform:SetParent(self.content.transform, false)
    self.viewName = viewName

    for i = 1, 5 do
        local index = i
        self.panelView[index] = self:FindChild(string.format("Panel_%s", index))
        self:AddClick(self.panelView[index]:FindChild("BuyBtn"), "ReqBuyDailyGift")
        local wareId = self.wareIdList[index]
        if wareId then
            local price = self.wareCfg[wareId].Price
            self.panelView[index]:FindChild("BuyBtn/Text"):GetComponent("Text").text = price
        end
    end
    self:AddClick(self:FindChild("BtnRight"), function ()
        self:PanelSwitch(true)
    end)
    self:AddClick(self:FindChild("BtnLeft"), function ()
		self:PanelSwitch(false)
	end)
    self.walletView = CC.uu.CreateHallView("WalletView", {exchangeWareId = self.WareId})
    self.walletView.transform:SetParent(self.transform, false)
    self:InitLanguage()
    self:RegisterEvent()
    self:InitSpecialView()
    self:InitShowPanel()
end

function DailyGiftBaseClass:InitLanguage()
    --礼包界面中处理
end

function DailyGiftBaseClass:InitSpecialView()
    self:AddClick(self:FindChild("BtnRule"), function ()
        self.openExplainView = true
		self:FindChild("ExplainView"):SetActive(true)
		self:SetExplainViewBtn()
	end)
	self:AddClick(self:FindChild("ExplainView/Frame/BtnPay"), "ReqBuyDailyGift")
	self:AddClick(self:FindChild("ExplainView/Frame/BtnSkip"), function ()
		self:CheckGameState()
	end)
    self:AddClick(self:FindChild("ExplainView/Frame/BtnClose"), function ()
        self.openExplainView = false
		self:FindChild("ExplainView"):SetActive(false)
    end)
end

--初始化每日礼包数据,在继承类重写
function DailyGiftBaseClass:InitDailyGiftData()
    self.WareId = "22013"
    self.gameId = 3002
    self.giftSource = CC.shared_transfer_source_pb.TS_CatchFish_DailyTreasure
end

--礼包切换
function DailyGiftBaseClass:PanelSwitch(isRight)
    if self.moving then return end
	self.lastShowPanel = self.curShowPanel
	self.curShowPanel = isRight and self.curShowPanel + 1 or self.curShowPanel - 1
	if self.curShowPanel > 5 then
		self.curShowPanel = 1
	elseif self.curShowPanel < 1 then
		self.curShowPanel = 5
	end
    self.moving = true
    local pos = isRight and -1280 or 1280
    self:RunAction(self.panelView[self.lastShowPanel],  {"localMoveTo", pos, 0, 0.5, function ()
        self.panelView[self.lastShowPanel]:SetActive(false)
    end})
    self.panelView[self.curShowPanel]:SetActive(true)
    self.panelView[self.curShowPanel].transform.localPosition = Vector3(-pos, 0, 0)
    self:RunAction(self.panelView[self.curShowPanel],  {"localMoveTo", 0, 0, 0.5})
    self:DelayRun(0.6, function ()
        self.moving = false
    end)
    if self.wareIdList[self.curShowPanel] then
        self.WareId = self.wareIdList[self.curShowPanel]
    end
    self.walletView:ChangeExchangeWareId(self.WareId)
    self:SwitchChange()
    self:SetBtnState()
end

function DailyGiftBaseClass:SwitchChange()
end

function DailyGiftBaseClass:InitShowPanel()
    local level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    if level >= 20 then
        self.curShowPanel = 5
    elseif level >= 10 then
        self.curShowPanel = 4
    elseif level >= 3 then
        self.curShowPanel = 3
    elseif level >= 1 then
        self.curShowPanel = 2
    else
        self.curShowPanel = 1
    end
    if self.wareIdList[self.curShowPanel] then
        self.WareId = self.wareIdList[self.curShowPanel]
    end
    self.walletView:ChangeExchangeWareId(self.WareId)
    self.panelView[self.lastShowPanel]:SetActive(false)
    self.panelView[self.curShowPanel]:SetActive(true)
	self:SwitchChange()
    self:SetBtnState()
end

function DailyGiftBaseClass:SetBtnState()
    if not self.activity.GetGiftStatus(self.WareId) then
        self.panelView[self.curShowPanel]:FindChild("BuyBtn"):SetActive(false)
        self.panelView[self.curShowPanel]:FindChild("GrayBtn"):SetActive(true)

        local serverDate = CC.TimeMgr.GetTimeInfo()
        local countdown = 86400
        if serverDate then
            countdown = 86400 - serverDate.hour*3600 - serverDate.min*60 - serverDate.sec
        end
        self.panelView[self.curShowPanel]:FindChild("GrayBtn/Text").text = CC.uu.TicketFormat(countdown)
        self:StopTimer("GiftCountdown")
        self:StartTimer("GiftCountdown",1,function ()
            countdown = countdown - 1
            if countdown < 0 then
                self:StopTimer("GiftCountdown")
                self.panelView[self.curShowPanel]:FindChild("BuyBtn"):SetActive(true)
                self.panelView[self.curShowPanel]:FindChild("GrayBtn"):SetActive(false)
            else
                self.panelView[self.curShowPanel]:FindChild("GrayBtn/Text").text = CC.uu.TicketFormat(countdown)
            end
        end,-1)
    else
        self:StopTimer("GiftCountdown")
        self.panelView[self.curShowPanel]:FindChild("BuyBtn"):SetActive(true)
        self.panelView[self.curShowPanel]:FindChild("GrayBtn"):SetActive(false)
    end
end

function DailyGiftBaseClass:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.DailyGiftReward,CC.Notifications.OnDailyGiftGameReward)
end

function DailyGiftBaseClass:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
end

function DailyGiftBaseClass:ReqBuyDailyGift()
    if self.moving then return end
    if not self.activity.GetGiftStatus(self.WareId) then
        CC.ViewManager.ShowTip(self.language.tips_gift)
        return
    end
    local price = self.wareCfg[self.WareId].Price
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
        CC.Request("ReqBuyWithId",{WareId=self.WareId,ExchangeWareId=self.WareId})
    else
        if self.openExplainView and not CC.LocalGameData.GetLocalStateToKey("CommodityType") then
            CC.ViewManager.ShowTip(self.language.tips_commodityType)
        end
        if self.walletView then
            self.walletView:PayRecharge()
        end
    end
end

function DailyGiftBaseClass:DailyGiftReward(param)
    log(CC.uu.Dump(param,"DailyGiftReward",10))
    local isCurGift = false
    for _, v in ipairs(self.giftSourceList) do
        if param.Source == v then
            isCurGift = true
            break
        end
    end
    if not isCurGift then return end
    local data = {};
    for k,v in ipairs(param.Rewards) do
        data[k] = {}
        data[k].ConfigId = v.ConfigId
        data[k].Count = v.Count
    end
    local Cb = nil
	-- if self.isHall and CC.LocalGameData.GetLocalDataToKey("DailyGift", self.WareId) then
    --     Cb = function ()
    --         self.openExplainView = true
    --         local ExplainView = self.transform:FindChild("ExplainView")
    --         if ExplainView then
    --             ExplainView:SetActive(true)
    --         end
	-- 	end
    -- end
	CC.LocalGameData.SetLocalDataToKey("DailyGift", self.WareId)
	CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
    self.activity.SetGiftStatus(self.WareId, false)
    self:SetBtnState()
    self:SetExplainViewBtn()
end

function DailyGiftBaseClass:SetExplainViewBtn()
    local giftState = self.activity.GetGiftStatus(self.WareId)
	self.transform:FindChild("ExplainView/Frame/BtnPay"):SetActive(giftState)
	self.transform:FindChild("ExplainView/Frame/BtnSkip"):SetActive(self.isHall and not giftState)
end

function DailyGiftBaseClass:CheckGameState()
    local IsHallGroup = self.gameDataMgr.GetIsHallGroupByID(self.gameId)
    CC.HallUtil.EnterGame(self.gameId, nil, function()
        CC.ViewManager.CloseAllOpenView()
    end)
end

function DailyGiftBaseClass:EnterGame(id)
    CC.ViewManager.CloseAllOpenView()
    CC.HallUtil.CheckAndEnter(id)
end

function DailyGiftBaseClass:OnDestroy()
    self:StopTimer("GiftCountdown")
    self:unRegisterEvent()
    if self.walletView then
		self.walletView:Destroy()
	end
end

function DailyGiftBaseClass:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function DailyGiftBaseClass:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function DailyGiftBaseClass:ActionIn()
    self:SetCanClick(false)
    -- self.transform.size = Vector2(125, 0)
	-- self.transform.localPosition = Vector3(-125 / 2, 0, 0)
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0},
        {"fadeToAll", 255, 0.5, function() self:SetCanClick(true) end}
    })
end

function DailyGiftBaseClass:ActionOut()
    self:SetCanClick(false)
    self:RunAction(self.transform, {
        {"fadeToAll", 0, 0.5, function() self:Destroy() end},
    })
end

return DailyGiftBaseClass