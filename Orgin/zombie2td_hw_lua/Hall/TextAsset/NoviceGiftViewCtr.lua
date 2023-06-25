
local CC = require("CC")

local NoviceGiftViewCtr = CC.class2("SelectActiveViewCtr")

function NoviceGiftViewCtr:ctor(view)

	self.configData = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").VIPGiftCfg;
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
	self:InitVar(view)
end

function NoviceGiftViewCtr:OnCreate()
	self:RegisterEvent()
end


function NoviceGiftViewCtr:RegisterEvent()
	-- CC.HallNotificationCenter.inst():register(self,self.RefreshNovice,CC.Notifications.NoviceReward)
end

function NoviceGiftViewCtr:unRegisterEvent()
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NoviceReward)
end

--购买成功 隐藏新手礼包
function NoviceGiftViewCtr:RefreshNovice(data)
end

function NoviceGiftViewCtr:Destroy()
	self:unRegisterEvent()
end

function NoviceGiftViewCtr:InitVar(view)
	--UI对象
	self.view = view
end

--购买礼包
function NoviceGiftViewCtr:OnPay()
	if not CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
		CC.ViewManager.OpenAndReplace("StoreView");
		return;
	end
	local wareId = CC.PaymentManager.GetActiveWareIdByKey("vip")
	local wareCfg = self.wareCfg[wareId]
	local param = {}
	param.wareId = wareCfg.Id
	param.subChannel = wareCfg.SubChannel
	param.price = wareCfg.Price
	param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.errCallback = function ()
		self.view.BtnBuy:SetActive(false)		
		self.view.BtnBuyGray:SetActive(true)
	end
	CC.PaymentManager.RequestPay(param)
end


function NoviceGiftViewCtr:InitData()
end

return NoviceGiftViewCtr