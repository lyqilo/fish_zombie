local CC = require("CC")
local CommonHolidayGiftView = CC.uu.ClassView("CommonHolidayGiftView")
local M = CommonHolidayGiftView

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
	self.wareIdList = {"30312","30313"}
	self.wareId = "30335"
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.wareInfo = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")[self.wareId]
	self.rewardInfo = CC.ConfigCenter.Inst():getConfigDataByKey("Rewards")[10002344]
end

function M:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
	self:InitRewardItem()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
end

function M:InitContent()
	self.buyBtn = self:FindChild("Content/BtnBuy")
	self.buyBtn:FindChild("Text").text = self.wareInfo.Price

	-- self.buyBtn2 = self:FindChild("Content/BtnBuy2")
	-- self.buyBtn2:FindChild("Text").text = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")[self.wareIdList[2]].Price

	self:AddClick(self.buyBtn,"OnClickBtnBuy")
	-- self:AddClick(self.buyBtn2,"OnClickBtnBuy2")

	self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform})
end

function M:InitTextByLanguage()
	-- self:FindChild("Content/Rewards/Item3/Icon/Text").text = "Exp VIPx2"
	-- self:FindChild("Content/Rewards/Item3/Text").text = "ประสบการณ์"
	-- self:FindChild("Content/Rewards/Item1/Text").text = "ประสบการณ์"
	-- self:FindChild("Bg/Time").text = "เวลากิจกรรม: 09/12 ~ 15/12"
end

function M:InitRewardItem()
	for i,v in ipairs(self.rewardInfo.Items) do
		local item = self:FindChild("Content/Rewards/Item"..i)
		local data = self:GetRewardData(v.ConfigId,v.Count)
		self:SetImage(item:FindChild("Icon"),data.icon)
		item:FindChild("Icon"):GetComponent("Image"):SetNativeSize()
		item:FindChild("Text").text = data.text
	end
end

function M:GetRewardData(propId,num)
	local propInfo = self.propCfg[propId]
	local t = {}
	t.icon = propInfo.Icon
	if propId == CC.shared_enums_pb.EPC_ChouMa then
		t.text = CC.uu.ChipFormat(num).."\n"..self.propLanguage[propId]
	else
		t.text = self.propLanguage[propId].."x"..num
	end
	return t
end

function M:SetBuyBtnState(isShow)
	self.buyBtn:SetActive(isShow)
end

function M:OnClickBtnBuy()
	local price = self.wareInfo.Price
	if CC.Player:Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		local data={}
		data.WareId = self.wareId
		data.ExchangeWareId = self.wareId
		CC.Request("ReqBuyWithId",data)
	else
		if self.walletView then
			self.walletView:SetBuyExchangeWareId(self.wareId)
			self.walletView:PayRecharge()
		end
	end
end

function M:OnClickBtnBuy2()
	local price = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")[self.wareIdList[2]].Price
	if CC.Player:Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		local data={}
		data.WareId = self.wareIdList[2]
		data.ExchangeWareId = self.wareIdList[2]
		CC.Request("ReqBuyWithId",data)
	else
		if self.walletView then
			self.walletView:SetBuyExchangeWareId(self.wareIdList[2])
			self.walletView:PayRecharge()
		end
	end
end

function M:RefreshUI(wareId,enabled)
	local time = CC.TimeMgr.GetTimeInfo()
	local longTime = (23 - time.hour)*60*60 + (59 - time.min)*60 + (60 - time.sec)
	local i = wareId == self.wareIdList[1] and 1 or 2

	self:DelayRun(1,function ()
		self:FindChild("Content/BtnBuy"..i):SetActive(enabled)
		self:FindChild("Content/BtnUnBuy"..i):SetActive(not enabled)
	end)

	if not enabled then
		self:StartTimer("timer"..i,1,function ()
			longTime = longTime - 1
			if longTime < 0 then
				self:StopTimer("timer"..i)
			else
				self:SetCountDown(longTime,wareId)
			end
		end,-1)
	end
end

function M:SetCountDown(time,wareId)
	local i = wareId == self.wareIdList[1] and 1 or 2
	if time <= 0 then
		self:FindChild("Content/BtnBuy"..i):SetActive(true)
		self:FindChild("Content/BtnUnBuy"..i):SetActive(false)
	else
		self:FindChild("Content/BtnUnBuy"..i.."/Text").text = CC.uu.TicketFormat(time)
	end
end

function M:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function M:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function M:OnDestroy()
	
	if self.walletView then
		self.walletView:Destroy()
		self.walletView = nil
	end
	
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return CommonHolidayGiftView