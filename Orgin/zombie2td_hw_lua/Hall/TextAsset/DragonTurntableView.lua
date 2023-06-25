local CC = require("CC")
local DragonTurntableView = CC.uu.ClassView("DragonTurntableView")

function DragonTurntableView:ctor(param)
	self:InitVar(param);
end

function DragonTurntableView:InitVar(param)
    self.param = param;
    self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    --倒计时
    self.countDown = 0
end

function DragonTurntableView:OnCreate()
    self.walletView = CC.uu.CreateHallView("WalletView", {})
    self.walletView.transform:SetParent(self.transform, false)

	self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
    self:LanguageSwitch()
    self:InitUI()
end

function DragonTurntableView:LanguageSwitch()
    self:FindChild("Bg/Title").text = self.language.Title
    self:FindChild("Bg/Explain").text = self.language.Explain
    self:FindChild("Bg/Explain1").text = self.language.Explain1
    self:FindChild("Bg/Explain2").text = self.language.Explain2
    for i=1,3 do
        local item = self:FindChild("GiftList/GiftItem"..i)
        item:FindChild("Bg/Text").text = self.language.GiftList[i].BgText
        item:FindChild("Introduce/Top/Text").text = self.language.GiftList[i].TopText
        item:FindChild("Introduce/Top/Text1").text = self.language.GiftList[i].TopText1
        item:FindChild("Introduce/Bottom/Text").text = self.language.GiftList[i].BottomText
        item:FindChild("Introduce/Bottom/Text1").text = self.language.GiftList[i].BottomText1
        item:FindChild("Introduce/Bottom/Tex2").text = self.language.GiftList[i].BottomText2

        local wareId = self.viewCtr.WareIdList[i].WareId
        local price = self.wareCfg[wareId].Price
        item:FindChild("BottomBtn/BuyBtn/Price").text = price
    end
end

function DragonTurntableView:InitUI()
    for i = 1, 3 do
        local index = i
        self:AddClick(self:FindChild(string.format("GiftList/GiftItem%s/BottomBtn/BuyBtn", index)), function ()
            if self.viewCtr.WareIdList[index].Status then
                self:ReqBuyDailyGift(self.viewCtr.WareIdList[index].WareId)
            end
        end)
    end

    self:StartTimer( "RefreshCountDown",1,function()
        self:RefreshCountDown()
    end,-1)
end

function DragonTurntableView:ReqBuyDailyGift(wareId)
    local price = self.wareCfg[wareId].Price
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
        CC.Request("ReqBuyWithId",{WareId = wareId, ExchangeWareId = wareId});
    else
        if self.walletView then
            self.walletView:SetBuyExchangeWareId(wareId)
            self.walletView:PayRecharge()
        end
    end
end

function DragonTurntableView:RefreshCountDown()
    if self.countDown <= 0 then return end
    self.countDown = self.countDown - 1
    for i, v in ipairs(self.viewCtr.WareIdList) do
        self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/CountDown/Text").text = CC.uu.TicketFormat(self.countDown)
    end
    if self.countDown <= 0 then
        self.viewCtr:LoadGiftStatus()
    end
end

function DragonTurntableView:RefreshUI()
    for i, data in ipairs(self.viewCtr.WareIdList) do
        self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/CountDown"):SetActive(not data.Status)
        self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/BuyBtn"):SetActive(data.Status)
        self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/CountDown/Text").text = CC.uu.TicketFormat(self.countDown)
    end
end

function DragonTurntableView:ActionIn()
    self:SetCanClick(false);
    self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function DragonTurntableView:ActionOut()
    self:SetCanClick(false);
    CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function DragonTurntableView:OnDestroy()
    self:StopTimer("RefreshCountDown")
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    if self.walletView then
		self.walletView:Destroy()
	end
end

return DragonTurntableView