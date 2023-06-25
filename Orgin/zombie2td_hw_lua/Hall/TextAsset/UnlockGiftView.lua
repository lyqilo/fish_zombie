local CC = require("CC")
local UnlockGiftView = CC.uu.ClassView("UnlockGiftView")

--泼水节解锁礼包
--[[
@param
level
rewards={[1]={PropID=2,PropNum=10000},[2]={PropID=2,PropNum=10000}}
price=49
succCb
errCb
]]
function UnlockGiftView:ctor(param)
	self:InitVar(param)
end

function UnlockGiftView:InitVar(param)
	self.param = param
	self.language = CC.LanguageManager.GetLanguage("L_HolidayTaskView")
end

function UnlockGiftView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnBuyUnLockGiftRsp,CC.Notifications.NW_Req_UW_BuyUnLockGirt)
end

function UnlockGiftView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function UnlockGiftView:OnCreate()
	self:RegisterEvent()
    self:InitContent()
	self:InitTextByLanguage()
end

function UnlockGiftView:InitContent()
	self:FindChild("Frame/BtnBuy/Text").text = self.param.price
	--for i=1,2 do
		self:FindChild("Frame/Reward1/Desc/Text").text = self.param.rewards[1].PropNum
	--end
	for i=1,7 do
		self:FindChild("Frame/Reward2/Icon"..i):SetActive(i == self.param.level)
	end
	
	self:AddClick("Mask","ActionOut")
	self:AddClick("Close","ActionOut")
	self:AddClick("Frame/BtnBuy","OnClickBtnBuy")
end

function UnlockGiftView:InitTextByLanguage()
	
end

function UnlockGiftView:OnClickBtnBuy()
	if CC.Player:Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.param.price then
		CC.Request("Req_UW_BuyUnLockGirt")
	else
		CC.ViewManager.ShowTip(self.language.diamondNotEnough)
	end
end

function UnlockGiftView:OnBuyUnLockGiftRsp(err,data)
	if err ~= 0 then
		logError("Req_UW_BuyUnLockGirt err:"..err)
		if self.param.errCb then self.param.errCb() end
		return
	end
	if self.param.succCb then self.param.succCb() end
	self:ActionOut()
end

function UnlockGiftView:OnDestroy()
	self:UnRegisterEvent()
end

return UnlockGiftView