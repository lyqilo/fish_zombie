local CC = require("CC")
local MarsTaskUnlockView = CC.uu.ClassView("MarsTaskUnlockView")
local M = MarsTaskUnlockView

--火星任务解锁礼包
--[[
@param
stage:阶段
level:等级
rewards={[1]={PropID=2,PropNum=10000},[2]={PropID=2,PropNum=10000}}
price=49
succCb
errCb
]]
function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param
	self.language = CC.LanguageManager.GetLanguage("L_MarsTaskView")
	self.marsTaskCfg = CC.ConfigCenter.Inst():getConfigDataByKey("MarsTaskConfig")
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnBuyUnLockGiftRsp,CC.Notifications.NW_Req_UW_MarsBuyUnLockGirt)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function M:OnCreate()
	self:RegisterEvent()
    self:InitContent()
	self:InitTextByLanguage()
end

function M:InitContent()
	self:FindChild("Frame/BtnBuy/Text").text = self.param.price
	self:FindChild("Frame/Reward1/Desc/Text").text = self.param.rewards[1].PropNum
	self:SetImage(self:FindChild("Frame/Reward2/Icon"),string.format(self.marsTaskCfg[self.param.stage].targetImg,self.param.level))
	self:FindChild("Frame/Reward2/Icon"):GetComponent("Image"):SetNativeSize()
	
	local buff = self.marsTaskCfg.buff[self.param.level]
	local isShow = buff and (not table.isEmpty(buff))
	self:FindChild("Frame/BtnBuy/Buff"):SetActive(isShow)
	self:FindChild("Frame/BuffTips"):SetActive(isShow)
	
	self:AddClick("Mask","ActionOut")
	self:AddClick("Frame/BtnBuy","OnClickBtnBuy")
end

function M:InitTextByLanguage()
	self:FindChild("Frame/Reward2/Desc/Text").text = self.language.targetName[self.param.stage][self.param.level]
	self:FindChild("Frame/BuffTips").text = self.language.buffTips
end

function M:OnClickBtnBuy()
	if CC.Player:Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.param.price then
		self:SetCanClick(false)
		CC.Request("Req_UW_MarsBuyUnLockGirt")
	else
		CC.ViewManager.ShowTip(self.language.diamondNotEnough)
	end
end

function M:OnBuyUnLockGiftRsp(err,data)
	self:SetCanClick(true)
	if err ~= 0 then
		logError("Req_UW_BuyUnLockGirt err:"..err)
		if self.param.errCb then self.param.errCb() end
		return
	end

end

function M:OnPropChange(props,source)

	if source == CC.shared_transfer_source_pb.TS_Splash_Unlock_1 or
		source == CC.shared_transfer_source_pb.TS_Splash_Unlock_2 or
		source == CC.shared_transfer_source_pb.TS_Splash_Unlock_3 or
		source == CC.shared_transfer_source_pb.TS_Splash_Unlock_4 or
		source == CC.shared_transfer_source_pb.TS_Splash_Unlock_5 then
		
		local cb = function()
			if self.param.succCb then self.param.succCb() end
			self:ActionOut()
		end
		CC.ViewManager.OpenMarsTaskRewardsView({items = props, callback = cb});
	end
end

function M:ShowEffect()
	self:FindChild("beijing"):SetActive(true)
	self:FindChild("Frame/pmd"):SetActive(true)
	self:FindChild("Frame/Reward1/Icon/chouma"):SetActive(true)
end

function M:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {"spawn",
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.2},
			{"scaleTo",1,0,0},
			{"scaleTo",1,1,0.2, function() self:SetCanClick(true) end},
			{"delay",0.3,function () self:ShowEffect() end}
		});
end

function M:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {"spawn",
			{"fadeToAll", 0, 0.2},
			{"scaleTo",1,0,0.2, function() self:Destroy() end}
		});
end

function M:OnDestroy()
	self:UnRegisterEvent()
end

return MarsTaskUnlockView