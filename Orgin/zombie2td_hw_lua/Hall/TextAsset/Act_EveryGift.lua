
local CC = require("CC")
local Act_EveryGift = CC.uu.ClassView("Act_EveryGift")
--VIP活动
function Act_EveryGift:ctor(content,language,btnName)
	self.content = content
	self.language = language
	self.btnName = btnName
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
end

function Act_EveryGift:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:RegisterEvent()
	self:ReFreshDailyGift()
	self.activityDataMgr.SetActivityInfoByKey("Act_EveryGift", {redDot = false})
end


function Act_EveryGift:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReFreshDailyGiftEvent,CC.Notifications.OnDailyGiftReward)
end

function Act_EveryGift:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftReward)
end

function Act_EveryGift:ReFreshDailyGift()
	self:FindChild("BG/Btn"):SetActive(true)
	self:FindChild("BG/Btn/Text").text = self.language[self.btnName]
	self:AddClick("BG/Btn",function ()
		local wareId = CC.PaymentManager.GetActiveWareIdByKey("buyu");
		local wareCfg = self.wareCfg[wareId];
		local param = {}
		param.wareId = wareCfg.Id
		param.subChannel = wareCfg.SubChannel
		param.price = wareCfg.Price
		param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
		param.errCallback = function (err)
			if err == CC.shared_en_pb.WareAlreadyPurchased or err == CC.shared_en_pb.WareLocked then
				CC.ViewManager.ShowTip(self.language.tips_fishGift)
			end
		end
		CC.PaymentManager.RequestPay(param)
	end)
end

function Act_EveryGift:ReFreshDailyGiftEvent(param)
	self:ReFreshDailyGift()
end

function Act_EveryGift:OnDestroy()
	self:unRegisterEvent()
end

function Act_EveryGift:ActionOut()
	self:SetCanClick(false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function Act_EveryGift:ActionIn()
	self:SetCanClick(false);

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

return Act_EveryGift