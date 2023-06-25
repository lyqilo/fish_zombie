local CC = require("CC")

local FortunebagView = CC.uu.ClassView("FortunebagView")

function FortunebagView:ctor()

	self.FortunebagData = CC.DataMgrCenter.Inst():GetDataByKey("FortunebagData")
	self.EPC_Level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
end

function FortunebagView:OnCreate()
	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()
	self:InitUI()
	self:AddClickEvent()
end

function FortunebagView:InitUI()
	self.language = self:GetLanguage()
	self.FortunebagGroup = self:FindChild("Layer_UI/TopContent/FortunebagGroup")
	self.LoginGet = self:FindChild("Layer_UI/DownContent/LoginGet")
	self.VioAttackGet = self:FindChild("Layer_UI/DownContent/VioAttackGet")
	self.BtnVioAttackGet = self:FindChild("Layer_UI/DownContent/BtnVioAttackGet/BtnVioAttackGet")
	self.BtnVioAttackUnGet = self:FindChild("Layer_UI/DownContent/BtnVioAttackGet/BtnVioAttackUnGet")
	self.BtnLoginGet = self:FindChild("Layer_UI/DownContent/BtnLoginGet/BtnLoginGet")
	self.BtnLoginUnGet = self:FindChild("Layer_UI/DownContent/BtnLoginGet/BtnLoginUnGet")
	self.BtnVIPup = self:FindChild("Layer_UI/DownContent/BtnLoginGet/BtnVIPup")
	self.DetalObj = self:FindChild("Layer_UI/DetalObj")
	self.btnDetalClose = self.DetalObj:FindChild("BG")
	self.btnDetalGet = self.DetalObj:FindChild("BtnGet")
	self.btnDetalUnGet = self.DetalObj:FindChild("BtnUnGet")
	self.Amount =  self:FindChild("Layer_UI/TopContent/Amount")
	self.BtnShop =  self:FindChild("Layer_UI/DownContent/BtnShop")
	self:InitBag()
	self:InitLoginData()
	self:InitStore()
	self:SetAmountText()
	self:SetLoginGetBtnActive()
	self:SetVioAttackGetBtnActive()
	self:InitTextByLanguage()
end

--点击事件
function FortunebagView:AddClickEvent()
	self:AddClick("Layer_UI/BtnClose",function ()
		self:ActionOut()
	end)
	self:AddClick(self.btnDetalClose,function ()
		self.DetalObj:SetActive(false)
	end)
	self:AddClick(self.BtnShop,function ()
		CC.ViewManager.Open("StoreView")
		self:Destroy()
	end)
	self:LoginGetClick()--登陆领取按钮事件注册
	self:VioAttackGetClick() --设置充值领取奖励按钮注册
	--self:DetalClick() -- 福袋信息界面按钮点击事件设置
end

--累计活动币
function FortunebagView:SetAmountText()
	self.Amount.text = CC.Player.Inst():GetSelfInfoByKey("EPC_ActivityCurrency")
end

--初始化福袋
function FortunebagView:InitBag()
	for i,v in ipairs(self.viewCtr.Fortunebag_Data) do
		self.FortunebagGroup:FindChild(i.."/BG/Text").text = v.price
		local btn = self.FortunebagGroup:FindChild(i.."/BtnFortunebag")
		self:AddClick(btn,function ()
			self:DetalPanel(i)
		end)
		self.FortunebagGroup:FindChild(i):SetActive(true)
	end
end

--初始化登陆领取奖励
function FortunebagView:InitLoginData()
	for i,v in ipairs(self.viewCtr.login_Data) do
		if v.Min <= self.EPC_Level and  v.Max >= self.EPC_Level then
			self.LoginGet:FindChild(i.."/VipRange").text = "<color=#E31C1C>"..self.language[v.vipText].."</color>"
			self.LoginGet:FindChild(i.."/GetText").text = "<color=#E31C1C>"..v.ActiveMoney.."</color>"
		else
			self.LoginGet:FindChild(i.."/VipRange").text = "<color=#522509>"..self.language[v.vipText].."</color>"
			self.LoginGet:FindChild(i.."/GetText").text = "<color=#522509>"..v.ActiveMoney.."</color>"
		end
		self.LoginGet:FindChild(i):SetActive(true)
	end
end

--初始化累计储值
function FortunebagView:InitStore()
	local str = "0" --活动币
	for i,v in ipairs(self.viewCtr.Store_Data) do
		if i == 1 then
			str = self.FortunebagData.GetFortunebagTotalRecharge()
		elseif i == 2 then
			str = self.FortunebagData.GetFortunebagRechargeCanConvert()
		elseif i == 3 then
			str = self.FortunebagData.GetFortunebagRechargeHasConverted()
		end
		if self.FortunebagData.GetFortunebagRechargeCanConvert() > 0 and i == 2 then --可领取充值奖励不大于0的话 字体为红色
			self.VioAttackGet:FindChild(i.."/VipRange").text = "<color=#E31C1C>"..self.language[v.DetalText].."</color>"
			self.VioAttackGet:FindChild(i.."/GetText").text = "<color=#E31C1C>"..str.."</color>"
		else
			self.VioAttackGet:FindChild(i.."/VipRange").text = self.language[v.DetalText]		
			self.VioAttackGet:FindChild(i.."/GetText").text = str
		end
		self.VioAttackGet:FindChild(i):SetActive(true)
	end
end
-- 刷新可领取活动币的文本
function FortunebagView:RefreshVioAttack()
	self.VioAttackGet:FindChild("2/VipRange").text = "<color=#522509>"..self.language[self.viewCtr.Store_Data[2].DetalText].."</color>"
	self.VioAttackGet:FindChild("2/GetText").text = "<color=#522509>"..self.FortunebagData.GetFortunebagRechargeCanConvert().."</color>"
	self.VioAttackGet:FindChild("3/GetText").text = "<color=#522509>"..self.FortunebagData.GetFortunebagRechargeHasConverted().."</color>"
end

--设置每日登陆领取按钮置灰
function FortunebagView:SetLoginGetBtnActive()
	if self.EPC_Level <= 0 then
		self.BtnLoginGet:SetActive(false)
		self.BtnLoginUnGet:SetActive(false)
		self.BtnVIPup:SetActive(true)
	else
		if not self.FortunebagData.GetFortunebagHasTaken() then		 --true:已领取  false:未领取
			self.BtnLoginGet:SetActive(true)
			self.BtnLoginUnGet:SetActive(false)
		else		 --已经领取
			self.BtnLoginGet:SetActive(false)	
			self.BtnLoginUnGet:SetActive(true)
		end
		self.BtnVIPup:SetActive(false)
	end	
end

--登陆领取按钮事件注册
function FortunebagView:LoginGetClick()
	if self.FortunebagData.GetFortunebagHasTaken() then	return end --true:已领取  false:未领取
	if self.EPC_Level == 0 then --vip == 0 购买新手礼包注册
		self:AddClick(self.BtnVIPup,function ()
			if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
				CC.ViewManager.Open("SelectGiftCollectionView")
			else
				CC.ViewManager.Open("StoreView")
			end
			self:Destroy()
		end)
	elseif self.EPC_Level > 0 then  --领取按钮注册
		self:AddClick(self.BtnLoginGet,function ()
			self.viewCtr:GetFestivalLoginReward()
		end)
	end
end

--设置充值领取奖励按钮显示
function FortunebagView:SetVioAttackGetBtnActive()
	if self.FortunebagData.GetFortunebagRechargeCanConvert() <= 0 then --没有可领取的活动币
		self.BtnVioAttackGet:SetActive(false)
		self.BtnVioAttackUnGet:SetActive(true)
	else
		self.BtnVioAttackGet:SetActive(true)
		self.BtnVioAttackUnGet:SetActive(false)
	end
end


--设置充值领取奖励按钮注册
function FortunebagView:VioAttackGetClick()
	if self.FortunebagData.GetFortunebagRechargeCanConvert() > 0 then --有可领取的活动币 注册按钮事件
		self:AddClick(self.BtnVioAttackGet,function ()
			self.viewCtr:GetFestivalRechargeReward()
		end)
	end
end

--福袋信息界面设置
function FortunebagView:DetalPanel(i)
	self.DetalObj:SetActive(true)
	local sum = CC.Player.Inst():GetSelfInfoByKey("EPC_ActivityCurrency")--累计活动币
	local currentNum = self.viewCtr.Fortunebag_Data[i].price -- 当前所点击的活动币

	self:SetImage(self.DetalObj:FindChild("DetalImg"), self.viewCtr.Fortunebag_Data[i].ImgName);
	
	self.DetalObj:FindChild("DetalImg").sizeDelta = Vector2(self.viewCtr.Fortunebag_Data[i].Vecx, self.viewCtr.Fortunebag_Data[i].Vecy)
	self.DetalObj:FindChild("num"):GetComponent("Text").text = self.viewCtr.Fortunebag_Data[i].Money

	if sum >= currentNum then --总活动币大于等于当前所兑换的福袋价格
		self.btnDetalGet:SetActive(true)
		self.btnDetalUnGet:SetActive(false)
	else
		self.btnDetalGet:SetActive(false)
		self.btnDetalUnGet:SetActive(true)
	end
	self:DetalClick(i) -- 福袋信息界面按钮点击事件设置
end

--福袋信息界面按钮点击事件设置
function FortunebagView:DetalClick(i)
	self:AddClick(self.btnDetalGet,function ()
		self.DetalObj:SetActive(false)
		self.viewCtr:TakeFestivalReward(i)
	end)
end

--翻译
function FortunebagView:InitTextByLanguage()
	self.BtnLoginGet:FindChild("Text"):GetComponent("Text").text = self.language.Get
	self.BtnLoginUnGet:FindChild("Text"):GetComponent("Text").text = self.language.Get
	self.BtnVIPup:FindChild("Text"):GetComponent("Text").text = self.language.VipUp
	self.BtnVioAttackGet:FindChild("Text"):GetComponent("Text").text = self.language.Get
	self.BtnVioAttackUnGet:FindChild("Text"):GetComponent("Text").text = self.language.Get
	self.btnDetalGet:FindChild("Text"):GetComponent("Text").text = self.language.Get
	self.btnDetalUnGet:FindChild("Text"):GetComponent("Text").text = self.language.Noenough
end

function FortunebagView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy()
	end
end

return FortunebagView