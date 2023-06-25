local CC = require("CC")

local this = CC.uu.ClassView("BeforeSendTipsView")

function this:ctor(param)
	self.param = param or {}
end

function this:OnCreate()
	self:InitUI()
	self:InitTextByLanguage()
end

function this:InitUI()
	self.mask = self:FindChild("mask")
	self:AddClick(self.mask,function ()
		self:Destroy()
	end)
	self.beforeSendTipsView_vipDone = self:FindChild("vipTips/done")
	self.beforeSendTipsView_vipBtn = self:FindChild("vipTips/btn")
	self.beforeSendTipsView_phoneDone = self:FindChild("phoneTips/done")
	self.beforeSendTipsView_phoneBtn = self:FindChild("phoneTips/btn")

	self:AddClick(self.beforeSendTipsView_vipBtn,slot(self.OnTipsViewVipBtnClick,self))
	self:AddClick(self.beforeSendTipsView_phoneBtn,slot(self.OnTipsViewPhoneBtnClick,self))

	local IsVip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") > 2 -- self:IsVip()
	local HasBindPhone = self.param.HasBindPhone -- self:HasBindPhone()
	self.beforeSendTipsView_vipDone:SetActive(IsVip)
	self.beforeSendTipsView_vipBtn:SetActive(not IsVip)
	self.beforeSendTipsView_phoneDone:SetActive(HasBindPhone)
	self.beforeSendTipsView_phoneBtn:SetActive(not HasBindPhone)
	self:FindChild("vipTips"):SetActive(false)
end

function this:InitTextByLanguage()
	local language = CC.LanguageManager.GetLanguage("L_SendChipsTipsView");
	self:FindChild("phoneTips/Text").text = language.tobePhone
	self:FindChild("phoneTips/btn/Text").text = language.gotoPhone
	self:FindChild("vipTips/Text").text = language.tobeVip
	self:FindChild("vipTips/btn/Text").text = language.gotoVip
end

function this:OnTipsViewVipBtnClick()
	self:Destroy()

	if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
		local param = {}
		param.SelectGiftTab = {"NoviceGiftView"}
		CC.ViewManager.Open("SelectGiftCollectionView",param)
	else
		CC.ViewManager.Open("StoreView")
	end
end

function this:OnTipsViewPhoneBtnClick()
	self:Destroy()

	CC.ViewManager.Open("BindTelView")
end

return this