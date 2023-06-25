local CC = require("CC")
local BirthdayView = CC.uu.ClassView("BirthdayView")

function BirthdayView:ctor(param)
	self.param = param or {}
	self.language = self:GetLanguage()
    self.giftInfo = {{wareId = "30233", status = true, cost = "86Thb", chip = "430K", rate = "54Thb", price = 269, source = CC.shared_transfer_source_pb.TS_Birthday_Pack_269},
                    {wareId = "30234", status = true, cost = "159Thb", chip = "800K", rate = "100Thb", price = 499, source = CC.shared_transfer_source_pb.TS_Birthday_Pack_499},
                    {wareId = "30235", status = true, cost = "510Thb", chip = "2.5M", rate = "320Thb", price = 1599, source = CC.shared_transfer_source_pb.TS_Birthday_Pack_1599},
                    {wareId = "30236", status = true, cost = "1800Thb", chip = "8.4M", rate = "1120Thb", price = 5599, source = CC.shared_transfer_source_pb.TS_Birthday_Pack_5599}}
end

function BirthdayView:OnCreate()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate(self.param)
	self:InitUI()
end

function BirthdayView:InitUI()
    for i = 1, 4 do
        local idx = i
        self:AddClick(self:FindChild(string.format("Grade%s/BuyBtn", idx)), function ()
            self:OnBuyGift(self.giftInfo[idx].wareId)
        end)
    end

    self:AddClick(self:FindChild("BtnClose"), function ()
		self:CloseView()
	end)
    self:LanguageSwitch()
	self:InitUIData()
    self.viewCtr:ReqTimesbuyGift()
end

--语言切换
function BirthdayView:LanguageSwitch()
	for i = 1, 4 do
		local idx = i
        self:FindChild(string.format("Grade%s/BuyBtn/Text", idx)).text = self.giftInfo[idx].price
		self:FindChild(string.format("Grade%s/Text", idx)).text = string.format(self.language.Text, self.giftInfo[idx].rate)
        self:FindChild(string.format("Grade%s/Text1", idx)).text = string.format(self.language.Text1, self.giftInfo[idx].chip, self.giftInfo[idx].cost)
        self:FindChild(string.format("Grade%s/GrayBtn/Text", idx)).text = self.language.GrayText
	end
	local giftEndTime = CC.Player.Inst():GetBirthdayGiftData().GiftEndAt or ""
	self:FindChild("Bg/Time").text = string.format(self.language.time, giftEndTime)
    self:FindChild("Des").text = self.language.des
end

function BirthdayView:InitUIData()
	CC.LocalGameData.SetLocalDataToKey("BirthdayGift", CC.Player.Inst():GetSelfInfoByKey("Id"))
	if self.param and self.param.isGiftCollection then
		self:FindChild("mask"):SetActive(false)
		self:FindChild("BtnClose"):SetActive(false)
	else
		self:FindChild("mask"):SetActive(true)
		self:FindChild("BtnClose"):SetActive(true)
    end
    self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform})
	self.walletView.transform:SetParent(self.transform, false)
end

function BirthdayView:OnBuyGift(giftWareId)
	local price = self.wareCfg[giftWareId].Price
	if CC.Player:Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		local data={}
        data.WareId = giftWareId
        data.ExchangeWareId = giftWareId
        CC.Request("ReqBuyWithId",data)
	else
		if self.walletView then
			self.walletView:SetBuyExchangeWareId(giftWareId)
			self.walletView:PayRecharge()
		end
	end
end

function BirthdayView:RefreshView()
    for i = 1, 4 do
        local idx = i
        self:FindChild(string.format("Grade%s/BuyBtn", idx)):SetActive(self.giftInfo[idx].status)
        self:FindChild(string.format("Grade%s/GrayBtn", idx)):SetActive(not self.giftInfo[idx].status)
    end
end

function BirthdayView:BirthdayStatus()
	for _, v in ipairs(self.giftInfo) do
		if v.status then
			--有礼包没有购买
			return
		end
	end
	--礼包都购买了
	CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("BirthdayView", {switchOn = false})
end

function BirthdayView:ActionIn()
	if self.param and self.param.isGiftCollection then
		self:SetCanClick(false)
		-- self.transform.size = Vector2(125, 0)
		-- self.transform.localPosition = Vector3(-125 / 2, 0, 0)
		self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
	end
end

function BirthdayView:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

--关闭界面
function BirthdayView:CloseView()
	self:ActionOut()
end

function BirthdayView:OnDestroy()
	--CC.Sound.StopEffect()
	-- if self.musicName then
	-- 	CC.Sound.PlayHallBackMusic(self.musicName);
	-- else
	-- 	CC.Sound.StopBackMusic();
	-- end
	self:BirthdayStatus()
	if self.walletView then
		self.walletView:Destroy()
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return BirthdayView;