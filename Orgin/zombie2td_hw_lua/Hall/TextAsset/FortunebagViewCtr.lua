
local CC = require("CC")

local FortunebagViewCtr = CC.class2("FortunebagViewCtr")

--@param
--playerId
function FortunebagViewCtr:ctor(view, param)
	self.login_Data = {
		{
			Id = 1,
			vipText = "vipText1",
			ActiveMoney = "9",
			Min = 1,
			Max = 3
		},
		{
			Id = 2,
			vipText = "vipText2",
			ActiveMoney = "19",
			Min = 4,
			Max = 8
		},
		{
			Id = 3,
			vipText = "vipText3",
			ActiveMoney = "39",
			Min = 9,
			Max = 11
		},
		{
			Id = 4,
			vipText = "vipText4",
			ActiveMoney = "69",
			Min = 12,
			Max = 14
		},
		{
			Id = 5,
			vipText = "vipText5",
			ActiveMoney = "149",
			Min = 15,
			Max = 17
		},
		{
			Id = 6,
			vipText = "vipText6",
			ActiveMoney = "299",
			Min = 18,
			Max = 100
		}
	}

	self.Store_Data = {
		{
			Id = 1,
			DetalText = "currentSum"
		},
		{
			Id = 2,
			DetalText = "CanExchange"
		},
		{
			Id = 3,
			DetalText = "Convertibility"
		}
	}

	self.Fortunebag_Data = {
		{
			Id = 1,
			Money = 90000,
			price = 99,
			RewardId = 1,
			ImgName = "cjlb_orange",
			Vecx = 101,
			Vecy = 124

		},
		{
			Id = 2,
			Money = 690000,
			price = 999,
			RewardId = 2,
			ImgName = "cjlb_pink",
			Vecx = 127,
			Vecy = 153
		},
		{
			Id = 3,
			Money = 1290000,
			price = 1999,
			RewardId = 3,
			ImgName = "cjlb_red",
			Vecx = 139,
			Vecy = 166
		}
	}


	self:InitVar(view, param);
end

function FortunebagViewCtr:OnCreate()
	self:RegisterEvent()
end

function FortunebagViewCtr:Destroy()
	self:unRegisterEvent()
end

function FortunebagViewCtr:InitVar(view, param)

	self.param = param;
	--UI对象
	self.view = view;
	
	self.FortunebagData = CC.DataMgrCenter.Inst():GetDataByKey("FortunebagData")
end

function FortunebagViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.RefreshChips, CC.Notifications.changeSelfInfo)
end

function FortunebagViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
end


function FortunebagViewCtr:RefreshChips()
		self.view:SetAmountText()--更新累计活动币的总数	
end

--打开福袋
function FortunebagViewCtr:TakeFestivalReward(i)
	local PlayerId =  CC.Player.Inst():GetSelfInfoByKey("Id")
	local param = {}
	param.PlayerId = PlayerId	
	param.RewardId = self.Fortunebag_Data[i].RewardId
	-- logError("self.Fortunebag_Data[i].RewardId = "..self.Fortunebag_Data[i].RewardId )
	--春节活动信息
	CC.Request("TakeFestivalReward",param,function(err,data)
		-- logError(CC.uu.Dump(data,"TakeFestivalReward =",10))
		CC.ViewManager.OpenRewardsView({items = data.Prop,title = "Fortunebag"})
	end)
end

--春节登陆奖励
function FortunebagViewCtr:GetFestivalLoginReward()
	local PlayerId =  CC.Player.Inst():GetSelfInfoByKey("Id")
	--春节活动信息
	CC.Request("GetFestivalLoginReward",{PlayerId=PlayerId},function(err,data)
    	-- logError(CC.uu.Dump(data,"GetFestivalLoginReward =",10))
		self.FortunebagData.SetFortunebagHasTaken(true)--设置为已经领取
		self.view:SetLoginGetBtnActive() --设置登陆领取界面的按钮状态
		CC.ViewManager.OpenRewardsView({items = data.Prop,title = "FestivalLoginReward"})
	end)
	
end

--春节充值奖励
function FortunebagViewCtr:GetFestivalRechargeReward()
	local PlayerId =  CC.Player.Inst():GetSelfInfoByKey("Id")
	--春节活动信息
	CC.Request("GetFestivalRechargeReward",{PlayerId=PlayerId},function(err,data)
    	-- logError(CC.uu.Dump(data,"GetFestivalRechargeReward =",10))
		self.FortunebagData.SetFortunebagRechargeCanConvert()--设置可领取界面为0
		self.FortunebagData.SetFortunebagRechargeHasConverted(data.Prop[1].Count) --已经领取的活动币写入本地变量
    	self.view:SetVioAttackGetBtnActive() -- 刷新充值领取的按钮
		self.view:RefreshVioAttack() -- 刷新可领取活动币的文本
		CC.ViewManager.OpenRewardsView({items = data.Prop,title = "FestivalRechargeReward"})
	end)
	
end

return FortunebagViewCtr