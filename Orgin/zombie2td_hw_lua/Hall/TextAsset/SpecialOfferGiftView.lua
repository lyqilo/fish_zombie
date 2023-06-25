local CC = require("CC")
local SpecialOfferGiftView = CC.uu.ClassView("SpecialOfferGiftView")

function SpecialOfferGiftView:ctor(param)
	self:InitVar(param)
end

function SpecialOfferGiftView:InitVar(param)
	self.param = param
    self.language = self:GetLanguage()
end

function SpecialOfferGiftView:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)

    self:InitContent()
	self:InitTextByLanguage()
	
	self.viewCtr:OnCreate()
end

function SpecialOfferGiftView:InitContent()
	self:SetCanClick(false)
	self.content = self:FindChild("Frame/Content")
	
	self.content:FindChild("OnceGift/Button/Text").text = self.viewCtr.giftInfo[3].price
	self:AddClick("Frame/Close","ActionOut")
	self:AddClick("Frame/Content/OnceGift/Button",function ()
		self:OnClickOnceGiftBuyBtn()
	end)
	for i=1,2 do
		self.content:FindChild("DailyGift/Item"..i.."/Button/Text").text = self.viewCtr.giftInfo[i].price
		self:AddClick("Frame/Content/DailyGift/Item"..i.."/Button",function ()
			self:OnClickDailyGiftBuyBtn(i)
		end)
	end
	self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform})
end

function SpecialOfferGiftView:InitTextByLanguage()
	self.content:FindChild("OnceGift/Desc/Text1").text = self.language.desc1
	self.content:FindChild("OnceGift/Desc/Text2").text = "1000THB"
	self.content:FindChild("OnceGift/Desc/Text3").text = self.language.desc2
	self.content:FindChild("OnceGift/Desc/Text4").text = "500THB"
	self.content:FindChild("OnceGift/Rewards/prop1/Text").text = CC.uu.ChipFormat(self.viewCtr.giftInfo[3].rewards[1].num,true)
	self.content:FindChild("OnceGift/Rewards/prop2/Text").text = self.language.prop2
	self.content:FindChild("OnceGift/Rewards/prop3/Text").text = self.language.prop3
	for i=1,2 do
		self.content:FindChild("DailyGift/Item"..i.."/Title").text = self.language.dailyGift..i
		self.content:FindChild("DailyGift/Item"..i.."/prop1/Text").text = CC.uu.ChipFormat(self.viewCtr.giftInfo[i].rewards[1].num,true)
		self.content:FindChild("DailyGift/Item"..i.."/prop2/Text").text = self.viewCtr.giftInfo[i].rewards[2].num
		self.content:FindChild("DailyGift/Bubble"..i.."/Image/Text").text = self.language["expBubble"..i]
	end
	
end

function SpecialOfferGiftView:RefreshView()
	
	local showCountDown = false
	self.content:FindChild("OnceGift"):SetActive(self.viewCtr.giftInfo[3].status)
	for i=1,2 do
		local status = self.viewCtr.giftInfo[i].status
		showCountDown = showCountDown or (not status)
		self.content:FindChild("DailyGift/Item"..i.."/Button"):SetActive(status)
		self.content:FindChild("DailyGift/Item"..i.."/CountDown"):SetActive(not status)
	end
	
	if showCountDown then
		local timeInfo = os.date("*t", os.time())
		local countdown = 86400 - timeInfo.hour*3600 - timeInfo.min*60 - timeInfo.sec
		self:SetCountDown(countdown)
		self:StartTimer("CountDown",1,function ()
				countdown = countdown - 1
				if countdown < 0 then
					self:StopTimer("CountDown")
					self:DelayRun(2,function ()
						self.viewCtr:ReqGiftStatus()
					end)
				else
					self:SetCountDown(countdown)
				end
		end,-1)
	end
end

function SpecialOfferGiftView:SetCountDown(second)
	local countdown = second > 0 and second or 0
	self.content:FindChild("DailyGift/Item1/CountDown/Text").text = CC.uu.TicketFormat(countdown)
	self.content:FindChild("DailyGift/Item2/CountDown/Text").text = CC.uu.TicketFormat(countdown)
end

function SpecialOfferGiftView:OnClickOnceGiftBuyBtn()
	self.viewCtr:OnPay(self.viewCtr.giftInfo[3].wareId)
end

function SpecialOfferGiftView:OnClickDailyGiftBuyBtn(type)
	self.viewCtr:OnPay(self.viewCtr.giftInfo[type].wareId)
end

function SpecialOfferGiftView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					--self:SetCanClick(true);
				end}
		});
end

function SpecialOfferGiftView:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function SpecialOfferGiftView:OnDestroy()
	
	self:StopTimer("CountDown")
	if self.walletView then
		self.walletView:Destroy()
		self.walletView = nil
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return SpecialOfferGiftView