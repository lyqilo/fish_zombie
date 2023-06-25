
local CC = require("CC")
local WorldCupTipsView = CC.uu.ClassView("WorldCupTipsView")
--[[
@param
Index:显示第几个弹窗 1、礼包弹窗  2、投注弹窗  3、投注确认信息

页面所需参数：
----------------------------------
1、
IsEnough：筹码是否足够
IsPurchase：是否有购买
2、
Odds：赔率
SpriteName：传入图片名显示图片
CountryID： 传入国家ID
Amount：投注金额
3、
TicketNum：投注券号
-----------------------------------
CloseCb:关闭按钮回调
CanelBtnCb：取消按钮回调
SureBtnCb：确定按钮回调
]]

function WorldCupTipsView:ctor(param)
	self:InitVar(param);
end

function WorldCupTipsView:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function WorldCupTipsView:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:RegisterEvent()
	self:InitContent()
	self:InitTextByLanguage()
	self:AddClickEvent()
end

function WorldCupTipsView:InitVar(param)

	self.param = param or {};
	self.index = self.param.Index

end

function WorldCupTipsView:InitContent()
	-- CC.uu.Log(self.param,"WorldCupTipsView:")
	self.OnePanel = self:FindChild("Frame/Bg/1")
	self.TwoPanel = self:FindChild("Frame/Bg/2")
	self.ThreePanel = self:FindChild("Frame/Bg/3")
	if self.index > 0 then
		self:FindChild("Frame/Bg/"..self.index):SetActive(true)
		if self.index == 2 then
			self:FindChild("Frame/Bg/BtnPanel/CanelBtn"):SetActive(true)
		end
	else
		self:ActionOut()
	end

	if self.param.SpriteName then
		local spriteName = self.param.SpriteName
		if not string.match(spriteName,".png") then
			spriteName = spriteName..".png"
		end
		local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName];
		local imageCmp = self.TwoPanel:FindChild("Dk/CountryImage"):GetComponent("Image")
		imageCmp.sprite = CC.uu.LoadImgSprite(spriteName,abName);
		imageCmp:SetNativeSize()
	end
	if self.param.Odds then
		self.TwoPanel:FindChild("Dk/CountryImage/num").text = self.param.Odds
		self.TwoPanel:FindChild("Dk/CountryText").text = self.language.countryName[self.param.CountryID]
		self.TwoPanel:FindChild("Dk/DesText").text = string.format(self.language.Tips[2].Des2,self.param.Odds*self.param.Amount)
	end
	if self.param.TicketNum then
		local number = #tostring(self.param.TicketNum)
		for i = 1, number, 1 do
			self.ThreePanel:FindChild("Dk/NumPanel/Num"..i.."/Text").text = string.sub(self.param.TicketNum,i,i)
		end
	end
	self.OnePanel:FindChild("A/0"):SetActive(not self.param.IsEnough)
	self.OnePanel:FindChild("A/1"):SetActive(self.param.IsEnough)
	self.OnePanel:FindChild("B/0"):SetActive(not self.param.IsPurchase)
	self.OnePanel:FindChild("B/1"):SetActive(self.param.IsPurchase)

end

function WorldCupTipsView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ActionOut,CC.Notifications.WorldCupTipsViewNotify)
end

function WorldCupTipsView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.WorldCupTipsViewNotify)
end

function WorldCupTipsView:AddClickEvent()
	self:AddClick("Frame/CloseBtn",function ()
		if self.param.CloseCb then
			self.param.CloseCb()
		end
		self:ActionOut()
	end)
	self:AddClick("Frame/Bg/BtnPanel/CanelBtn",function ()
		if self.param.CanelBtnCb then
			self.param.CanelBtnCb()
		end
		self:ActionOut()
	end)
	self:AddClick("Frame/Bg/BtnPanel/SureBtn",function ()
		if self.param.SureBtnCb then
			self.param.SureBtnCb()
		end
		self:ActionOut()
	end)
end

function WorldCupTipsView:InitTextByLanguage()
	self.OnePanel:FindChild("A/Text").text = self.language.Tips[1].Des1
	self.OnePanel:FindChild("B/Text").text = self.language.Tips[1].Des2
	self.ThreePanel:FindChild("Dk/Des").text = self.language.Tips[3].Des2
	self:FindChild("Frame/Bg/BtnPanel/CanelBtn/Text").text = self.language.Tips.BtnCanelText
	self:FindChild("Frame/Bg/BtnPanel/SureBtn/Text").text = self.language.Tips.BtnSureText
	if self.index == 1 then
		self:FindChild("Frame/Bg/Title"):SetActive(false)
	else
		self:FindChild("Frame/Bg/Title").text = self.language.Tips[self.index].Des1
	end
end

function WorldCupTipsView:OnDestroy()
	self:UnRegisterEvent()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return WorldCupTipsView