local CC = require("CC")

local ReliefManager = CC.class2("ReliefManager")

--[[
@param
curMoney
errCb
succCb
]]
function ReliefManager:ctor(param)
	self.param = param

	local succCb = self.param.succCb or function()
		end

	local errCb = self.param.errCb or function()
			CC.ViewManager.Open("StoreView")
		end

	self.succCb = function()
		succCb()
		self:Destroy()
	end

	self.errCb = function()
		errCb()
		self:Destroy()
	end

	--商店界面
	self.storeView = nil
	--商店内充值标记
	self.buyInStore = false
	self.buyNoviceReward = false
end

function ReliefManager:OnCreate()
	self:CheckReliefOrder()

	self:RegisterEvent()
end

function ReliefManager:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnPurchaseSuccess, CC.Notifications.OnPurchaseNotify)
	CC.HallNotificationCenter.inst():register(self, self.OnNoviceRewardSuccess, CC.Notifications.NoviceReward)
end

function ReliefManager:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPurchaseNotify)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NoviceReward)
end

function ReliefManager:CheckReliefOrder()
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") > 15 then
		--VIP大于15直接领取救济金
		self:CheckRelief()
	else
		--先检测VIP礼包是否购买过
		if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
			local callback = function()
				if CC.SelectGiftManager.CheckNoviceGiftCanBuy() and not self.buyNoviceReward then
					self:CheckRelief()
				else
					self.succCb()
				end
			end
			CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "NoviceGiftView", closeFunc = callback})
		else
			local data = {
				Items = {
					{
						ConfigId = CC.shared_enums_pb.EPC_ChouMa,
						Count = self.param.curMoney,
						Delta = 0
					}
				}
			}
			CC.Player.Inst():ChangeProp(data)

			--没有可购买的礼包就弹商店
			local callback = function()
				if not self.buyInStore then
					self:CheckRelief()
				else
					self.succCb()
				end
			end
			self.storeView = CC.ViewManager.Open("StoreView", {callback = callback})
		end
	end
end

--关闭商店或者礼包界面或者VIP大于15去检测救济金是否可领取
function ReliefManager:CheckRelief()
	local curMoney = self.param.curMoney
	CC.Request(
		"GetReliefInfo",
		nil,
		function(err, data)
			CC.Player.Inst():SetLeftTimes(data.LeftTimes)
			--可领取,并且当前筹码小于领取的限制，调用大厅弹框领取
			if data.LeftTimes > 0 and curMoney < data.Threshold then
				local param = {}
				param.Type = data.Type
				param.UnderAmount = data.Threshold
				param.Amount = data.Amount
				param.Type = data.Type
				param.LeftTimes = data.LeftTimes
				param.Callback = self.succCb
				CC.ViewManager.Open("BenefitsView", param)
			else
				self.errCb()
			end
		end,
		function(err, data)
			logError("拉取救济金失败:" .. err)
			self.errCb()
		end
	)
end

function ReliefManager:OnPurchaseSuccess()
	self.buyInStore = true

	if self.storeView then
		self.storeView:Destroy()
	end
end

function ReliefManager:OnNoviceRewardSuccess()
	self.buyNoviceReward = true
end

function ReliefManager:Destroy()
	self:UnRegisterEvent()

	if self.param.callback then
		self.param.callback()
	end
end

return ReliefManager
