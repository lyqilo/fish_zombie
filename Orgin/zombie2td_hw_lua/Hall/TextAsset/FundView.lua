local CC = require("CC")

local FundView = CC.uu.ClassView("FundView")

function FundView:ctor()

	self.content = nil
	self.FundItem = nil
	self.RecordTab = {}  --记录当前选择的基金
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.language = self:GetLanguage()
end

function FundView:OnCreate()

	self.activityDataMgr.SetActivityInfoByKey("FundView", {redDot = false})
	self.content = self:FindChild("Layer_UI/LeftGroup/Scroll View/Viewport/Content")
	self.FundItem = self.content:FindChild("FundItem")
	self.BtnDetal = self:FindChild("Layer_UI/BtnDetal")
	self.RightPanel = self:FindChild("Layer_UI/RightPanel")
	self.Amount = self.RightPanel:FindChild("Amount")
	self.Sum = self.RightPanel:FindChild("Sum")
	self.RightBG = self.RightPanel:FindChild("RightBG")
	self.RightBG_vip = self.RightBG:FindChild("vip")
	self.RightBG_AttackRemaning = self.RightBG:FindChild("AttackRemaning")
	self.RightBG_Capping = self.RightBG:FindChild("Capping")
	self.RightBG_LoginRemaning = self.RightBG:FindChild("LoginRemaning")
	self.RightBG_LoginCapping = self.RightBG:FindChild("LoginCapping")
	self.purchasedPanel = self.RightPanel:FindChild("purchasedPanel")
	self.purchasedPanel_vip = self.purchasedPanel:FindChild("vip")
	self.purchasedPanel_AttackRemaning = self.purchasedPanel:FindChild("AttackRemaning")
	self.purchasedPanel_Capping = self.purchasedPanel:FindChild("Capping")
	self.purchasedPanel_LoginMinMoney = self.purchasedPanel:FindChild("LoginMinMoney")
	self.purchasedPanel_LoginMaxMoney = self.purchasedPanel:FindChild("LoginMinMoney/label/LoginMaxMoney")
	self.purchasedPanel_BtnGet = self.purchasedPanel:FindChild("BtnGet")
	self.purchasedPanel_BtnUnGet = self.purchasedPanel:FindChild("BtnUnGet")
	self.purchasedPanel_Day = self.purchasedPanel:FindChild("Day")
	self.BtnBuy = self.RightPanel:FindChild("BtnBuy")
	self.BtnIsBuy = self.RightPanel:FindChild("BtnIsBuy")
	self.BtnGet = self.purchasedPanel:FindChild("BtnGet")
	self.BtnUnGet = self.purchasedPanel:FindChild("BtnUnGet")
	self.FundDetalPanel = self:FindChild("Layer_UI/FundDetalPanel")
	self.Detal_BtnClose = self.FundDetalPanel:FindChild("BtnClose")
	self.DetalText = self.FundDetalPanel:FindChild("DetalText")

	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()
	self:InitTextByLanguage()
end

function FundView:InitUI()
	self:InitItem()

	self:SelectBtnEvent()
	self:AddClickEvent()
end

--设置按钮置灰
function FundView:SetBtnMaterial(isbool)
	if isbool then
		self.BtnGet:SetActive(true)
		self.BtnUnGet:SetActive(false)
	else
		self.BtnGet:SetActive(false)
		self.BtnUnGet:SetActive(true)
	end
end

--点击事件
function FundView:AddClickEvent()
	self:AddClick("Layer_UI/BtnClose",function ()
		self:ActionOut()
	end)

	self:AddClick(self.BtnGet,function ()
		CC.ViewManager.ShowLoading()
		self.viewCtr:DailyGet(self.RecordTab)
	end)
	self:AddClick(self.BtnDetal,function ()
		self.FundDetalPanel:SetActive(true)
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnClickNoviceDes,false)
	end)
	self:AddClick(self.Detal_BtnClose,function ()
		self.FundDetalPanel:SetActive(false)
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnClickNoviceDes,true)
	end)
end

--当玩家非vip时需要前往商城充值
--当玩家没充过值并且非vip前往新手礼包
--以上条件都满足的话，为购买按钮
function FundView:SelectBtnEvent()
	local EPC_Level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	if EPC_Level >= self.RecordTab.vip then
		self.BtnBuy:FindChild("Text"):GetComponent("Text").text = self.language.Buy
		self:AddClick(self.BtnBuy,function ()
			self.viewCtr:BuyFund(self.RecordTab)
		end)
	elseif EPC_Level == 0 then --当玩家没充过值并且非vip,oppo包：一解锁没解跳转商城，已解锁跳首冲礼包；其他：跳新手礼包
		self.BtnBuy:FindChild("Text"):GetComponent("Text").text = self.language.VipUp
		local fun = function() end
		if CC.ChannelMgr.CheckOppoChannel() then
			if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
				fun = function() CC.ViewManager.Open("StoreView") end
			else
				fun = function() CC.ViewManager.Open("FirstBuyGiftView") end
			end

		else
			fun = function()
				self:Destroy()
				-- CC.ViewManager.Open("SelectActiveView")
				CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshJumpNovice)
			end
		end
		self:AddClick(self.BtnBuy,fun)
	elseif EPC_Level < self.RecordTab.vip then --当玩家非vip时需要前往商城充值
		self.BtnBuy:FindChild("Text"):GetComponent("Text").text = self.language.VipUp
		self:AddClick(self.BtnBuy,function ()
			CC.ViewManager.Open("StoreView")
			--self:Destroy()
		end)
	end
end

--初始化界面itemv
function FundView:InitItem()
	for i,v in ipairs(self.viewCtr.configData) do
		local item = CC.uu.UguiAddChild(self.content,self.FundItem,tostring(i))
		item:FindChild("UnSelect/Text"):GetComponent("Text").text = v.Money..self.language.danwei
		item:FindChild("Select/Text"):GetComponent("Text").text = v.Money..self.language.danwei
		local RedDot = item:FindChild("UnSelect/RedDot")

		if i == 1 then --默认第一个为选中
			item:GetComponent("Toggle").isOn = true
			self:ItemInfo(v)
		else
			self:ItemRedPoint(RedDot,v) --红点设置
		end
		UIEvent.AddToggleValueChange(item, function(flag)
			if flag then  --当点击监听到toggle的选中状态
				self:ItemInfo(v)
				RedDot:SetActive(false) 	--当点击过后红点设置为隐藏
				self:SelectBtnEvent()		--设置点击事件
			end
		end)
	end
end

--每一个item的红点显示（购买状态下才会显示）
function FundView:ItemRedPoint(tran,v)
	if self.viewCtr.FundDataMgr.GetFundItemStatus(v.ware_id).CanReward and
		not self.viewCtr.FundDataMgr.GetFundItemStatus(v.ware_id).CanBuy then	--已经购买但是可以领取
		tran:SetActive(true)
	elseif not self.viewCtr.FundDataMgr.GetFundItemStatus(v.ware_id).CanReward and
		not self.viewCtr.FundDataMgr.GetFundItemStatus(v.ware_id).CanBuy or
		self.viewCtr.FundDataMgr.GetFundItemStatus(v.ware_id).CanBuy then --已经购买并且已经领取  或者没有购买
		tran:SetActive(false)
	end
end

--领取的总筹码
function FundView:CountFund(num)
	self.Sum:GetComponent("Text").text = CC.uu.NumberFormat(num)
end

--设置右边界面赋值的赋值
function FundView:ItemInfo(data)
	self.RecordTab = data
	if self.viewCtr.FundDataMgr.GetFundItemStatus(data.ware_id).CanBuy then --是否可以购买
		self:BuyPnale(data)
	elseif self.viewCtr.FundDataMgr.GetFundItemStatus(data.ware_id).CanReward then  --是否领取状态
		self:Getpanel(data)
		self:SetBtnMaterial(true)  --按钮状态
	elseif not self.viewCtr.FundDataMgr.GetFundItemStatus(data.ware_id).CanReward and
			not self.viewCtr.FundDataMgr.GetFundItemStatus(data.ware_id).CanBuy then  --已经购买但是是不可以领取
		self:Getpanel(data)
		self:SetBtnMaterial(false) --按钮状态
	end
	self.Amount:GetComponent("Text").text = data.Money..self.language.danwei..self.language.Fund  --当前基金的金额
  	self:CountFund(self.viewCtr.FundDataMgr.GetTotal(data.ware_id))
  	self.purchasedPanel_Day:GetComponent("Text").text = self.viewCtr.FundDataMgr.GetPurchaseDays(data.ware_id) + 1
end

--购买界面
function FundView:BuyPnale(data)
	self.purchasedPanel:SetActive(false)
	self.RightBG:SetActive(true)
	self.BtnBuy:SetActive(true)
	self.BtnGet:SetActive(false)
	self.BtnIsBuy:SetActive(false)
	self.RightBG_vip:GetComponent("Text").text = data.vip
	self.RightBG_AttackRemaning:GetComponent("Text").text = CC.uu.NumberFormat(data.BuyRemaining)
	self.RightBG_Capping:GetComponent("Text").text = CC.uu.NumberFormat(data.BuyMaxCount)
	self.RightBG_LoginRemaning:GetComponent("Text").text = CC.uu.NumberFormat(data.LoginRemaining)
	self.RightBG_LoginCapping:GetComponent("Text").text = CC.uu.NumberFormat(data.LoginMaxCount)
end

--领取基金界面
function FundView:Getpanel(data)
	self.purchasedPanel:SetActive(true)
	self.RightBG:SetActive(false)
	self.BtnBuy:SetActive(false)
	self.BtnGet:SetActive(true)
	self.BtnIsBuy:SetActive(true)
	self.purchasedPanel_vip:GetComponent("Text").text = data.vip
	self.purchasedPanel_AttackRemaning:GetComponent("Text").text = CC.uu.NumberFormat(data.BuyRemaining)
	self.purchasedPanel_Capping:GetComponent("Text").text = CC.uu.NumberFormat(data.BuyMaxCount)
	self.purchasedPanel_LoginMinMoney:GetComponent("Text").text = CC.uu.NumberFormat(data.LoginRemaining)
	self.purchasedPanel_LoginMaxMoney:GetComponent("Text").text = CC.uu.NumberFormat(data.LoginMaxCount)
end

--翻译
function FundView:InitTextByLanguage()
	self:FindChild("Layer_BG/Top/TopText"):GetComponent("Text").text = self.language.SevenFund
	self.purchasedPanel_BtnGet:FindChild("Text"):GetComponent("Text").text = self.language.Get
	self.purchasedPanel_BtnUnGet:FindChild("Text"):GetComponent("Text").text = self.language.Get
	self.FundDetalPanel:FindChild("DetalText"):GetComponent("Text").text = self.language.Detal
	self.FundDetalPanel:FindChild("Layer_BG/Top/TopText"):GetComponent("Text").text = self.language.DetalTitle
	self.FundDetalPanel:FindChild("Groupimg/1_1"):GetComponent("Text").text = self.language.FundType
	self.FundDetalPanel:FindChild("Groupimg/1_2"):GetComponent("Text").text = self.language.acquired
	self.FundDetalPanel:FindChild("Groupimg/1_3"):GetComponent("Text").text = self.language.Daily_Get
	self.BtnBuy:FindChild("Text"):GetComponent("Text").text = self.language.Buy
	if self:IsPortraitView() then
		self.FundDetalPanel:FindChild("Groupimg/Portrait/1_1"):GetComponent("Text").text = self.language.FundType
	end
	for i,v in ipairs(self.viewCtr.configData) do
		local num = i + 1
		for j=1,3 do
			local findstr = "Groupimg/"..num.."_"..j
			local str
			if j == 1 then
				str = v.Money..self.language.danwei
				if self:IsPortraitView() then
					self.FundDetalPanel:FindChild("Groupimg/Portrait/"..num.."_"..j):GetComponent("Text").text = str
				end
			elseif  j == 2 then
				str = self.language.Remaining ..v.BuyRemaining.." "..self.language.Height ..v.BuyMaxCount
			elseif  j == 3 then
				str = self.language.Remaining ..v.LoginRemaining.." "..self.language.Height ..v.LoginMaxCount
			end
			self.FundDetalPanel:FindChild(findstr):GetComponent("Text").text = str
		end
	end
end

function FundView:OnDestroy()
	self:SetCanClick(false)
	if self.viewCtr then
		self.viewCtr:Destroy()
	end
end


function FundView:ActionOut()
	self:SetCanClick(false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function FundView:ActionIn()
	self:SetCanClick(false);

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

return FundView