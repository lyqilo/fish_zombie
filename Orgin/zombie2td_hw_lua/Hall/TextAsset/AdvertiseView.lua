local CC = require("CC")
local AdvertiseView = CC.uu.ClassView("AdvertiseView")

function AdvertiseView:ctor()

end

function AdvertiseView:OnCreate()

	self.facebookBinding = false
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()

	self:RegisterEvent()
	self:AddClickEvent()
end

function AdvertiseView:InitContent(count)
	if count <= 1 then
		self:FindChild("UILayout/LastBtn"):SetActive(false)
		self:FindChild("UILayout/NextBtn"):SetActive(false)
		count = 1
	else
		self:FindChild("UILayout/LastBtn"):SetActive(true)
		self:FindChild("UILayout/NextBtn"):SetActive(true)
	end
	self.ScrollerController = self:FindChild("UILayout/BGImage/ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self.viewCtr:ItemData(tran,dataIndex,cellIndex)
	end)
	self.ScrollerController:InitScroller(count)
end

function AdvertiseView:CreateItem(tran,param)
	if param.texture then
		tran:FindChild("Image"):GetComponent("RawImage").texture = param.texture
		tran:FindChild("Image"):SetActive(true)
	else
		tran:FindChild("Image"):SetActive(true)
	end
	self:AddClick(tran:FindChild("Image"),function ()  self:InitClickEvent(param.info) end)
end

function AdvertiseView:InitClickEvent(param)
	--执行广告操作
	CC.HallUtil.ClickADEvent(param)
	--看看操作需不需要退出当前广告
	local key = tonumber(param.MessageUseType)
	local switch = {
		[0] = function ()
			--无任何操作
		end,
		[1] = function ()
			--无任何操作
		end,
		[4] = function()
			--无任何操作
		end,  
		[8] = function()  
			--无任何操作
		end
	}
	local fSwitch = switch[key]
	if fSwitch then
		fSwitch()
	else
		self:ActionOut()
	end
end

function AdvertiseView:RequestSevenGift(param)
	if param.WareId == CC.PaymentManager.GetActiveWareIdByKey("sevenday") then
		CC.Request("Take7DaysReward",nil,function (err,data)
			CC.uu.Log(data,"Take7DaysReward")
			if data.State == 1 then
				CC.Player.Inst():SetSevenDays(data)
				CC.Player.Inst():OpenSevenDaysView()
				self:ActionOut()
			end
		end,function (err,data)
			logError("ActiveView: 7DaysReward failed:"..err)
			self:ActionOut()
		end)
		
	end
end

function AdvertiseView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RequestSevenGift,CC.Notifications.OnPurchaseNotify)
end

function AdvertiseView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify)
end

function AdvertiseView:AddClickEvent()
	self:AddClick("UILayout/BGImage/CloseBtn","ActionOut")
end

function AdvertiseView:ActionOut()
	self:SetCanClick(false);
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    	self:Destroy();
    end})
end

function AdvertiseView:OnDestroy()
	self:unRegisterEvent()
end

return AdvertiseView