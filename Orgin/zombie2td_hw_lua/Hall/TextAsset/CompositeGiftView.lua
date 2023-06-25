local CC = require("CC")
local CompositeGiftView = CC.uu.ClassView("CompositeGiftView")

function CompositeGiftView:ctor(param)
	self:InitVar(param);
end

function CompositeGiftView:InitVar(param)
    self.param = param;
    self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
end

function CompositeGiftView:OnCreate()
    self.walletView = CC.uu.CreateHallView("WalletView", {})
    self.walletView.transform:SetParent(self.transform, false)

	self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
    self.WareIdList = {"30195", "30196", "30197", "30198"}
    self.JpAwardIDAll = {507,508,510,511,513,514,516,515}
    self.GiftAwardIDAll = {504,507,508,510,511,513,514}
    self.giftList = {}
    self:InitUI()
    self:InitDesPanel()
    self:RefreshSelfInfo()
    self:LanguageSwitch()
end

function CompositeGiftView:InitUI()
    for i = 1, 4 do
        local index = i
        local wareId = self.WareIdList[index]
        self.giftList[index] = self:FindChild(string.format("GiftList/GiftItem%s", index))
        self:AddClick(self.giftList[index]:FindChild("btnbuy/bg"), function ()
            self:ReqBuyDailyGift(wareId)
        end)
        self.giftList[index]:FindChild("btnbuy/Price").text = self.wareCfg[wareId].Price
    end
    self.KeyCounterNum = self:FindChild("KeyCounter/Icon/Text")
end

function CompositeGiftView:InitDesPanel()
    local curJpAwardIndex = 1
    local curGiftAwardIndex = 1
    for i = 1,4 do
        local JpAward= self:FindChild("GiftList/GiftItem"..i.."/JpAward")
        for j = 1,JpAward.childCount do
            local index = curJpAwardIndex
            local tran = JpAward:FindChild("Prop"..j)
            self:AddClick(tran,function()
                self:OpenDesPanel(self.JpAwardIDAll[index],tran.position)
            end)
            curJpAwardIndex = curJpAwardIndex + 1
        end
        local GiftAward= self:FindChild("GiftList/GiftItem"..i.."/GiftAward")
        for j = 1,GiftAward.childCount do
            local index = curGiftAwardIndex
            local tran = GiftAward:FindChild("Prop"..j)
            self:AddClick(tran,function()
                self:OpenDesPanel(self.GiftAwardIDAll[index],tran.position)
            end)
            curGiftAwardIndex = curGiftAwardIndex + 1
        end
    end
    self.DesMask = self:FindChild("DescRoot/Mask")
    self.DesPanel = self:FindChild("DescRoot/Panel")
    self.DesPanel:FindChild("Item/Text").text = self.language.Value
    self.DesName = self.DesPanel:FindChild("Name")
    self.DesIcon = self.DesPanel:FindChild("Icon")
    self.Describle = self.DesPanel:FindChild("Describle")
    self.DesValue = self.DesPanel:FindChild("Value")
    self:AddClick(self.DesMask,"CloseDesPanel")
end

function CompositeGiftView:OpenDesPanel(propID,iconPos)
    self.DesPanel.position = iconPos + Vector3(7.5,5.5,0)
    self:SetImage(self.DesIcon,self.viewCtr.propCfg[propID].Icon)
    self.DesName.text = self.viewCtr.propLanguage[propID]
    self.Describle.text = self.viewCtr.propLanguage["des"..propID]
    self.DesValue.text = self.viewCtr.CompositeBaseCfg[propID].value[1]
    self.DesMask:SetActive(true)
    self.DesPanel:SetActive(true)

end

function CompositeGiftView:CloseDesPanel()
    self.DesMask:SetActive(false)
    self.DesPanel:SetActive(false)
end

function CompositeGiftView:RefreshSelfInfo()
    self.KeyCounterNum.text = CC.uu.ChipFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_CombineEgg_Key"))
end

function CompositeGiftView:LanguageSwitch()
    local keyNum = {"x1", "x6", "x18", "x40"}
    for i = 1, 4 do
        local index = i
        local wareId = self.WareIdList[index]
        self.giftList[index]:FindChild("btnbuy/Price").text = self.wareCfg[wareId].Price
        self.giftList[index]:FindChild("Title").text = self.language.TitleGift[index]
        self.giftList[index]:FindChild("KeyNum").text = keyNum[index]
        if index > 1 then
            self:FindChild(string.format("GiftList/Tip/Tip%s/Text", index)).text = self.language.Select
        end
    end
    self:FindChild("Bg/Time").text = self.language.Time
    self:FindChild("Bg/Explain").text = self.language.Explain
end

function CompositeGiftView:ReqBuyDailyGift(wareId)
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

function CompositeGiftView:ActionIn()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function CompositeGiftView:ActionOut()
    self:SetCanClick(false);
    --CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function CompositeGiftView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    if self.walletView then
		self.walletView:Destroy()
	end
end

return CompositeGiftView