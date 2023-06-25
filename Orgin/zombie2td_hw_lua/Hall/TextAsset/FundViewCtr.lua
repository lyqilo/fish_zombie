
local CC = require("CC")

local FundViewCtr = CC.class2("FriendViewCtr")

function FundViewCtr:ctor(view, param)

	local config = CC.ConfigCenter.Inst():getConfigDataByKey("FundConfig");

	self.configData = CC.Platform.isIOS and config.IOS or (CC.ChannelMgr.CheckOppoChannel() and config.OPPO or config.Android)

	self:InitVar(view, param);
end

function FundViewCtr:OnCreate()
	self:InitData()
	self:RegisterEvent()
end

function FundViewCtr:Destroy()
	self:unRegisterEvent()
end

function FundViewCtr:InitVar(view, param)

	self.param = param;
	--UI对象
	self.view = view;
	
	 --计费点配置
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")

	--基金配置
	self.FundDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("FundData")

	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
end

function FundViewCtr:InitData()

	for i,v in ipairs(self.configData) do
		v.ware_id = CC.PaymentManager.GetActiveWareIdByKey("fund",v.Id);
	end

	self:CheckFundPurchaseStatus();
end

function FundViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnFundReward,CC.Notifications.OnFundReward)
	CC.HallNotificationCenter.inst():register(self,self.OnFundDailyReward,CC.Notifications.OnFundDailyReward)
	CC.HallNotificationCenter.inst():register(self,self.ReqGetSevenFundInfoResp,CC.Notifications.NW_ReqGetSevenFundInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqGetSevenFundRewardResp,CC.Notifications.NW_ReqGetSevenFundReward)
end

function FundViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnFundReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnFundDailyReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetSevenFundInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetSevenFundReward)
end

--每日基金领取
function FundViewCtr:OnFundDailyReward(data)
	CC.uu.Log(data,"FundViewCtr Reward:")
	self.view:SetBtnMaterial(false)
	local param = {}
	for i,v in ipairs(data.Items) do
		param[i] = {}
		param[i].ConfigId = data.Items[i].ConfigId
		param[i].Count = data.Items[i].Delta
  		self.FundDataMgr.SetTotal(self.view.RecordTab.ware_id,data.Items[i].Delta)  --统计总收益  		
	end
	self.view:CountFund(self.FundDataMgr.GetTotal(self.view.RecordTab.ware_id))
	self.FundDataMgr.SetDailyStatus(self.view.RecordTab.ware_id,false)
	CC.ViewManager.OpenRewardsView({items = param,title = "FundDaliyAward"})
	CC.ViewManager.CloseLoading()
end

--购买成功
function FundViewCtr:OnFundReward(data)
	CC.uu.Log(data,"OnFundReward:")
	self.view:FindChild("Layer_UI/RightPanel/BtnBuy"):SetActive(false)
  	-- CC.ViewManager.OpenOtherEx("ViolentAttackView",data.Items) --打开储值暴击
  	self.FundDataMgr.SetTotal(self.view.RecordTab.ware_id,data.Items[1].Delta)  --统计总收益
  	self.view:CountFund(self.FundDataMgr.GetTotal(self.view.RecordTab.ware_id))
  	self.FundDataMgr.SetpurchaseStatus(self.view.RecordTab.ware_id,false) --修改是否购买状态
  	self.FundDataMgr.SetDailyStatus(self.view.RecordTab.ware_id,true)--修改是否领取状态
  	self.FundDataMgr.SetPurchaseDays(self.view.RecordTab.ware_id)
  	self.view:ItemInfo(self.view.RecordTab) --重新刷新右边的界面
 	CC.ViewManager.CloseLoading()
end

--购买基金
function FundViewCtr:BuyFund(tab)
	local wareCfg = self.wareCfg[tab.ware_id]
	local param = {}
	param.wareId = wareCfg.Id
	param.subChannel = wareCfg.SubChannel
	param.price = wareCfg.Price
	param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.errCallback = function ()
		CC.ViewManager.CloseLoading()
	end
	CC.PaymentManager.RequestPay(param)

	CC.ViewManager.ShowLoading()
	self.view:DelayRun(20,function ()
		CC.ViewManager.CloseLoading()
	end)
end

--领取的协议
function FundViewCtr:DailyGet(tab)
	CC.Request("ReqGetSevenFundReward",{WareId=tab.ware_id})
end

function FundViewCtr:ReqGetSevenFundRewardResp(err,data)
	if err == 0 then
		log("获取每日奖励成功!")
	else
		log("ReqGetSevenFundRewardResp Err:"..err)
	end
end


--获取基金购买状态
function FundViewCtr:CheckFundPurchaseStatus()
	local data = self.FundDataMgr.GetFundStatus()
	if not table.isEmpty(data) then
		self.view:InitUI();
		return
	end
	CC.Request("ReqGetSevenFundInfo")
end

function FundViewCtr:ReqGetSevenFundInfoResp(err,data)
	if err == 0 then
		CC.uu.Log(data.Infos,"FundData:",3)
		self.FundDataMgr.SetFundStatus(data.Infos)
		self.view:InitUI();
	else
		log("ReqGetSevenFundInfo Err:"..err)
	end
end

return FundViewCtr