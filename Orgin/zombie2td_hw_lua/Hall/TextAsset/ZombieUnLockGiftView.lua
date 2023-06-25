local CC = require("CC")
local ZombieUnLockGiftView = CC.uu.ClassView("ZombieUnLockGiftView")

function ZombieUnLockGiftView:ctor(param)

	self:InitVar(param);
end

function ZombieUnLockGiftView:InitVar(param)
    self.param = param;
    self.WareId = "30016"
    self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
end

function ZombieUnLockGiftView:OnCreate()
    self:RegisterEvent()
    self:InitUI()
    self:InitClickEvent()
end

function ZombieUnLockGiftView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self. ZombieUnLockReward,CC.Notifications.OnDailyGiftGameReward)
end

function ZombieUnLockGiftView:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
end

function ZombieUnLockGiftView:InitUI()
    self:FindChild("View/UI/Tip/Tip3/Text1").text = self.language.Btn4_1Tip
    self:FindChild("View/UI/Tip/Tip3/Text2").text = self.language.Btn4_2Tip
    self:FindChild("View/UI/Tip/Tip3/Text3").text = self.language.Btn4_3Tip
    self:FindChild("View/Btn/Buy/Price").text = self.wareCfg[self.WareId].Price
    self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform, exchangeWareId = self.WareId})
end

function ZombieUnLockGiftView:InitClickEvent(  )
    self:AddClick(self:FindChild("View/Btn/Close"),function() self:ActionOut() end)
    self:AddClick(self:FindChild("View/Btn/Buy"),function() self:OnClickBuyBtn() end)
    self:AddClick(self:FindChild("View/UI/Tip/TipMask"),function() self:HideTip() end)
    for i=1,4 do
        self:AddClick(self:FindChild("View/Btn/Btn"..i),function()  self:ShowTip("Btn"..i) end)
    end
end

function ZombieUnLockGiftView:ShowTip(Btn)
    if Btn == "Btn4" then
        self:FindChild("View/UI/Tip/Tip1"):SetActive(true)
    else
        self:FindChild("View/UI/Tip/Tip2"):SetActive(true)
        self:FindChild("View/UI/Tip/Tip2/Text").text = self.language[Btn.."Tip"]
    end
    self:FindChild("View/UI/Tip/TipMask"):SetActive(true)
    self.CurrentBtn = Btn
end

function ZombieUnLockGiftView:HideTip()
    if self.CurrentBtn == nil then return end
    if self.CurrentBtn == "Btn4" then
        self:FindChild("View/UI/Tip/Tip1"):SetActive(false)
    else
        self:FindChild("View/UI/Tip/Tip2"):SetActive(false)
    end
    self:FindChild("View/UI/Tip/TipMask"):SetActive(false)
end

function ZombieUnLockGiftView:OnClickBuyBtn()
    local price = self.wareCfg[self.WareId].Price
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
        CC.Request("ReqBuyWithId",{WareId=self.WareId,ExchangeWareId=self.WareId})
    else
        if self.walletView then
            self.walletView:PayRecharge()
        end
    end
end

function ZombieUnLockGiftView:ZombieUnLockReward(param)
	log(CC.uu.Dump(param,"ZombieUnLockReward",10))
    if param.Source == CC.shared_transfer_source_pb.TS_TD_Unlock then
        local data = {}
		for k,v in ipairs(param.Rewards) do
            if v.ConfigId ~= CC.shared_enums_pb.EPC_TD_Unlock_9003 then
                local tab = {ConfigId = v.ConfigId ,Count = v.Count}
                table.insert(data, tab)
			end
		end
		local Cb = function()
			self:ActionOut()
		end
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnGameUnlockGift, {GameId = 3009})
    end
end

function ZombieUnLockGiftView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function ZombieUnLockGiftView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function ZombieUnLockGiftView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    if  self.walletView then
        self.walletView:Destroy()
    end
    self:unRegisterEvent()
end

return ZombieUnLockGiftView