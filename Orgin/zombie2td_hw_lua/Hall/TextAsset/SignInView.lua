-- region SignInView.lua
-- Date: 2019.7.13
-- Desc: 签到，宝箱的UI控制，刷新
-- Author: chris
local CC = require("CC")
local SignInView = CC.uu.ClassView("SignInView")


--公告
function SignInView:ctor()
	self.language = self:GetLanguage()
	self.ItemNode = {}
	self.efftab = {}
	self.times = 0  --初始时间
	self.LastEffIndex = 0
end

function SignInView:OnCreate()

	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()
	self:Init()
	self:setLanguageByText()
	self:AddClickEvent()
	CC.LocalGameData.SetSignState(true);
	self:DispatchRedDotState(false);
end

function SignInView:Init()
	self.Layer_Mask = self:FindChild("Layer_Mask")
	self.BtnSignIn = self:FindChild("Layer_UI/SignInMain/BtnSignIn")
	self.BtnSignature = self:FindChild("Layer_UI/SignInMain/BtnSignature")
	self.ThreetySign = self:FindChild("Layer_UI/ThreetySign")
	self.SignInMain = self:FindChild("Layer_UI/SignInMain")
	self.SignClose = self.SignInMain:FindChild("BtnClose")
	self.ThreetySignClose = self.ThreetySign:FindChild("Close")
	self.DayGroup = self.ThreetySign:FindChild("DayGroup")
	self.BtnSignInGray = self:FindChild("Layer_UI/SignInMain/BtnSignInGray")
	self.BtnSign = self.ThreetySign:FindChild("BtnSign")
	self.BtnSignGray = self.ThreetySign:FindChild("BtnSignGray")
	self.DateText = self.ThreetySign:FindChild("DateText")
	self.BtnDetail = self.SignInMain:FindChild("BtnDetail")
	self.Btn = self.SignInMain:FindChild("Btn")
	self.winText = self.SignInMain:FindChild("Btn/Text")
	self.Str_parent = self.SignInMain:FindChild("RollPanel/Mask/Parent")
	self.ItemGroup = self.SignInMain:FindChild("ItemGroup")
	self.TipPanel = self:FindChild("Layer_UI/TipPanel")
	self.BtnYes = self.TipPanel:FindChild("BtnYes")
	self.BtnNO = self.TipPanel:FindChild("BtnNO")
	self.TipClose = self.TipPanel:FindChild("bg")
	self.TopTitle = self.SignInMain:FindChild("TopTitle")
	self.DetalObj = self:FindChild("Layer_UI/DetalObj")
	self.DetalObjContent = self.DetalObj:FindChild("Content")
	self.DetalObjClose = self.DetalObj:FindChild("BG")
	self.EffectBox = self.SignInMain:FindChild("EffectBox")
	self:GetTreasurechestNode()
	self.viewCtr:LatticeInit(self.DayGroup)
	self:GetBox()

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");

	CC.Request("ReqAskSign")
	CC.Request("ReqAskRoll")
	--请求宝箱状态
	CC.Request("ReqAskBox")
end

function SignInView:GetBox()
	for i= 1 , 4 do
		local eff = self.EffectBox:FindChild(i)
		table.insert(self.efftab,eff)
	end
end

--点击事件
function SignInView:AddClickEvent()
	self:AddClick(self.BtnSignIn,"SignInFunc")
	self:AddClick(self.BtnSignature,"SignatureFunc")
	self:AddClick(self.ThreetySignClose,"ThreetySignCloseFunc")
	-- self:AddClick(self.SignClose,"Close")
	self:AddClick(self.BtnSign,"OpenTipPanel")
	self:AddClick(self.BtnDetail,"OpenDetailView")
	self:AddClick(self.Btn,"OpenSignWinView")
	self:AddClick(self.BtnYes,"Supplementary_sign")
	self:AddClick(self.BtnNO,"CloseTipPanel")
	self:AddClick(self.TipClose,"CloseTipPanel")
	self:AddClick(self.DetalObjClose,"DetalObjCloseFunc")
	self:TreasurechestClick()
end

function SignInView:DetalObjCloseFunc()
	self.DetalObj:SetActive(false)
end


function SignInView:CanClick(flag)
	self:SetCanClick(flag)
	CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, flag)
end

function SignInView:Supplementary_sign()
	local Chip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
	if Chip >= self.viewCtr.SignData.GetExpend() then  --判断筹码 是否大于等于 需要消耗的筹码
		local data = {}
        data.Month = tonumber(self.viewCtr.SignData.GetMonth())
        data.Day = tonumber(self.viewCtr.CurrentClickDate)
		CC.Request("ReqReplenish",data)
	else
		CC.ViewManager.ShowTip(self.language.NotEnoughMoney)
	end
end

function SignInView:Refresh_TipPanel()
	self.TipPanel:SetActive(true)
	local StrExpend = string.format(self.language.Tip,self.viewCtr.SignData.GetExpend())
	self.TipPanel:FindChild("Title"):GetComponent("Text").text = StrExpend
	self.TipPanel:FindChild("Content/Text"):GetComponent("Text").text = self.language.Tip2
end

function SignInView:CloseTipPanel()
	self.TipPanel:SetActive(false)
end

--拿到最后一个会执行的
function SignInView:GeLastEffIndex()
	for j=1,4 do
		--遍历拿到最后一个有UI上有加次数的宝箱
		--PS： 当前次日3/5，点击签到按钮 会从签到按钮飞一个特效到  次数显示上。然后次日宝箱签到次数+1结构为4/5
		if self.viewCtr.SignData.GetSignTimes(j) <= self.viewCtr.SignData.GetNeedTimes(j) and self.viewCtr.SignData.GetNeedTimes(j)~= 0 then
			if self.LastEffIndex <= j then
				self.LastEffIndex =  j
			end
		end
	end
	return self.LastEffIndex
end

--刷新宝箱
function SignInView:Refresh_Treasure()
	for i = 1,4 do
		local index = i - 1
		self:Refresh_Box(i)
		self:Refresh_TimeUI(i)

		if self.viewCtr.SignEffect == true then --是否执行签到后 “抛物线特效”飞到次数显示上的判断
			if i < 4 then
				self.times = self.times + 0.35
			end
			if self.viewCtr.SignData.GetSignTimes(i) <= self.viewCtr.SignData.GetNeedTimes(i) and self.viewCtr.SignData.GetNeedTimes(i)~= 0 then
				self.Effectco = self:DelayRun(self.times, function ()
					self.viewCtr:CurveMove(self.efftab[i],self.viewCtr.tab[i],self.times,function()
						self:RefreshSignTimes(i)
						self:DelayRun(0.8, function ()
							if i == self:GeLastEffIndex() then  --判断当前宝箱是不是最后一个需要执行抛物线特效的宝箱
								local param = {}
								param[1] = {}
								param[1].ConfigId = self.viewCtr.SignData.GetSignConfigId()
								param[1].Count = self.viewCtr.SignData.GetSignCount()
								CC.ViewManager.OpenRewardsView({items = param,title = "SignAward"})
								self.viewCtr.SignEffect = false
							end
					 	end)
					end)
			 	end)
			end
		else
			self:RefreshSignTimes(i)
		end
	end
	local curTimes = string.format(self.language.CurrentDay_Sign,tostring(self.viewCtr.SignData.GetSignTimes(4)))
	self.TopTitle:GetComponent("Text").text = curTimes
end

--刷新签到次数
function SignInView:RefreshSignTimes(i)
	local strAmount = self.viewCtr.SignData.GetSignTimes(i).."/"..self.viewCtr.SignData.GetNeedTimes(i)
	if self.viewCtr.SignData.GetSignTimes(i) >= self.viewCtr.SignData.GetNeedTimes(i) then --判断已签到次数是否大于 需要签到次数
		strAmount = self.viewCtr.SignData.GetNeedTimes(i).."/"..self.viewCtr.SignData.GetNeedTimes(i)
	end
	self.ItemNode[i].Amount:GetComponent("Text").text = strAmount
end

--刷新宝箱内容
function SignInView:Refresh_Box(i)
	if self.viewCtr.SignData.GetIsOpen(i) == true then --已经开启
		self.ItemNode[i].Treasurechest:SetActive(false)
		local p_type = self.viewCtr.SignData.GetEntityId(i)
		local p_index = self.viewCtr.SignData.GetEntityIdValue(i)
		self.ItemNode[i].JerShow:SetActive(true)
		self.ItemNode[i].Mask:SetActive(false)
		self:SetImage(self.ItemNode[i].JerShow, self.viewCtr.configData[p_type].Icon)
		self.ItemNode[i].JerShow:GetComponent("Image"):SetNativeSize()
		if self.viewCtr.SignData.GetEntityId(i) == 2 or self.viewCtr.SignData.GetEntityId(i) == 22 then
			self.ItemNode[i].Chip:SetActive(true)
			self.ItemNode[i].Chip:FindChild("Text").text = self.viewCtr.SignData.GetEntityIdValue(i)
		else
			self.ItemNode[i].Chip:SetActive(false)
		end
		self.ItemNode[i].isBuy:SetActive(true)
	elseif self.viewCtr.SignData.GetIsOpen(i) == false then --	--未开启
		self.ItemNode[i].Treasurechest:SetActive(true)
		self.ItemNode[i].isBuy:SetActive(false)
		self.ItemNode[i].IsOverdue:SetActive(false)
		self.ItemNode[i].Chip:SetActive(false)
		self.ItemNode[i].JerShow:SetActive(false)
		self.ItemNode[i].IsOverdue:SetActive(self.viewCtr.SignData.GetExpire(i))
	end
	if self.viewCtr.SignData.GetIsOpen(i) == true and self.viewCtr.SignData.GetSignState() == true then --已经签到并且已经已经开奖
		self.ItemNode[i].Treasurechest:SetActive(true)
		self.ItemNode[i].isBuy:SetActive(false)
		self.ItemNode[i].IsOverdue:SetActive(false)
		self.ItemNode[i].Chip:SetActive(false)
		self.ItemNode[i].JerShow:SetActive(false)
		self.ItemNode[i].IsOverdue:SetActive(self.viewCtr.SignData.GetExpire(i))
	end
end

--刷新时间ui
function SignInView:Refresh_TimeUI(i)
	if self.viewCtr.SignData.GetCanOpen(i) then --是否能够开启
		self.ItemNode[i].IsChoose:SetActive(true)
	else
		self.ItemNode[i].IsChoose:SetActive(false)
	end
 	--倒计时
	local function updateTimer(timers,tran)
		local str = ""
		local strText = tran:GetComponent("Text")
		if timers <= 0 then
			str = "0"..self.language.DayText.."00:00:00"
			strText.text = str
		else
			self:StartTimer("timer"..i, 1,
		    function()
		    	timers = timers - 1
				str = CC.uu.TicketFormatDay(timers)..self.language.DayText..CC.uu.TicketFormat3(timers)
				strText.text = str
				if timers <= 0 then
					self:StopTimer("timer"..i)
					CC.Request("ReqAskSign")
					CC.Request("ReqAskBox")
				end
		    end
		    ,-1)
		end
	end

	if self.viewCtr.SignData.GetNextAtivityTime(i) > 0 then  --下次活动倒计时 是否大于0 如果大于0会显示下次活动倒计时
		self.ItemNode[i].Title:SetActive(true)
		self.ItemNode[i].Date:SetActive(true)
		self.ItemNode[i].Title2:SetActive(false)
		self.ItemNode[i].Title:GetComponent("Text").text = self.language.NextActive
		updateTimer(self.viewCtr.SignData.GetNextAtivityTime(i),self.ItemNode[i].Date)
		return
	end

	if  self.viewCtr.SignData.GetExpire(i) then --过期
		self.ItemNode[i].Title:SetActive(false)
		self.ItemNode[i].Date:SetActive(false)
		self.ItemNode[i].Title2:SetActive(true)
		self.ItemNode[i].Title2:GetComponent("Text").text = self.language.overdue
	else --距开奖
		self.ItemNode[i].Title:SetActive(true)
		self.ItemNode[i].Date:SetActive(true)
		self.ItemNode[i].Title2:SetActive(false)
		self.ItemNode[i].Title:GetComponent("Text").text = self.language.Distance
		updateTimer(self.viewCtr.SignData.GetNextOpenTime(i),self.ItemNode[i].Date)
	end
end

--注册开宝箱的点击事件
function SignInView:TreasurechestClick()
	for i = 1,4 do
		self:AddClick(self.ItemNode[i].Treasurechest,function ()
			if self.viewCtr.SignData.GetCanOpen(i) then  --是否能够开启
				if i ==1 then
					CC.Request("ReqOpenBoxDay")
				elseif i == 2 then
					CC.Request("ReqOpenBoxWeek")
				elseif i == 3 then
					CC.Request("ReqOpenBoxHalfMonth")
				elseif i ==4 then
					CC.Request("ReqOpenBoxMonth")
				end
			else  --不能开启的话打开  宝箱详细的奖励内容
				local tab = {}
				if i ==1 then
					tab = self.viewCtr.SignDefine.DayilyBox
				elseif i == 2 then
					tab = self.viewCtr.SignDefine.SevenDayBox
				elseif i == 3 then
					tab = self.viewCtr.SignDefine.FivteeenDayBox
				elseif i ==4 then
					tab = self.viewCtr.SignDefine.ThreetyDayBox
				end
				self.DetalObj:SetActive(true)
				self.viewCtr:RefreshDetailObjAward(tab)

				-- local temp = {}
				-- temp.IdendityInfo = true --是否需要填写身份证
				-- temp.PersonInfo = true --是否需要填写个人信息
				-- temp.Desc = "50点卡" --描述
				-- temp.Icon = "dhk_50"	--图片名称
				-- temp.callback = nil --回调
				-- temp.Type = 9
				-- temp.ActiveName = "30日签到" --活动名称
				-- CC.ViewManager.Open("InformationView",temp)
			end
		end)
	end
end


function SignInView:OpenBoxCallBack(i)
	self:CanClick(false)
	self.ItemNode[i].Mask:SetActive(true)
	self.ItemNode[i].Treasurechest:SetActive(false)
	local param = {}
	param.EntityId = self.viewCtr.SignData.GetBoxType(i)
	param.Value = self.viewCtr.SignData.GetBoxValue(i)
	param.callBack = function()
		self:CanClick(true)
	end
	self.viewCtr:RanDomNum(self.ItemNode[i].Mask,self.ItemNode[i].isBuy,self.ItemNode[i].Chip,self.ItemNode[i].KuaiSuZhuanDon,param)
end

--拿到宝箱节点,写入table
function SignInView:GetTreasurechestNode()
	for i = 1,4 do
		local index = i - 1
		local Treasurechest =  self.ItemGroup:FindChild("Item"..index.."/Treasurechest")
		local Date =  self.ItemGroup:FindChild("Item"..index.."/Date")
		local Amount = self.ItemGroup:FindChild("Item"..index.."/Amount")
		local JerShow = self.ItemGroup:FindChild("Item"..index.."/JerShow")
		local Chip = self.ItemGroup:FindChild("Item"..index.."/Chip")
		local isBuy = self.ItemGroup:FindChild("Item"..index.."/IsBuy")
		local Mask =  self.ItemGroup:FindChild("Item"..index.."/Mask")
		local Title =  self.ItemGroup:FindChild("Item"..index.."/Title")
		local IsChoose = self.ItemGroup:FindChild("Item"..index.."/IsChoose")
		local Title2 = self.ItemGroup:FindChild("Item"..index.."/Title2")
		local KuaiSuZhuanDon = self.ItemGroup:FindChild("Item"..index.."/KuaiSuZhuanDon")
		local IsOverdue = self.ItemGroup:FindChild("Item"..index.."/IsOverdue")
		self.ItemNode[i] = {}
		self.ItemNode[i].Treasurechest = Treasurechest
		self.ItemNode[i].Date = Date
		self.ItemNode[i].Amount = Amount
		self.ItemNode[i].JerShow = JerShow
		self.ItemNode[i].Chip = Chip
		self.ItemNode[i].isBuy = isBuy
		self.ItemNode[i].Mask = Mask
		self.ItemNode[i].Title = Title
		self.ItemNode[i].IsChoose = IsChoose
		self.ItemNode[i].Title2 = Title2
		self.ItemNode[i].KuaiSuZhuanDon = KuaiSuZhuanDon
		self.ItemNode[i].IsOverdue = IsOverdue
	end
end

--打开中奖名单
function SignInView:OpenSignWinView()
	CC.Request("ReqAskRank")
end

--打开规则界面
function SignInView:OpenDetailView()
	CC.ViewManager.Open("SignExplainView")
end

--补签按钮
function SignInView:OpenTipPanel()
	local Chip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
	if Chip < self.viewCtr.SignData.GetExpend() then --补签 筹码数量 是否大于 需要消耗的筹码数量
		CC.ViewManager.ShowTip(self.language.NotEnoughMoney)
		return
	end

	if self.viewCtr.SignData.GetRemainingTimes() > 0 then --剩余签到次数
		self:Refresh_TipPanel()
	else
		CC.ViewManager.ShowTip(self.language.NotEnoughTimes)
	end
end

--刷新按钮状态，刷新日期
function SignInView:RefreshSupplementary(param)
	self.DateText:GetComponent("Text").text = param.Date.."-"..param.Month.."-"..param.Yeath
	self:SupplyBtnActive(param.b,param.Expend)
end
--刷新按钮转态
function SignInView:SupplyBtnActive(b,Expend)
	self.BtnSign:SetActive(b)
	self.BtnSignGray:SetActive(not b)
	self.BtnSign:FindChild("Text"):GetComponent("Text").text = CC.uu.ChipFormat(Expend)
	self.BtnSignGray:FindChild("Text"):GetComponent("Text").text = CC.uu.ChipFormat(Expend)
end

function SignInView:ThreetySignCloseFunc()
	self.ThreetySign:SetActive(false)
	self.viewCtr.ItemIndex = 0

	self.viewCtr.NextMonItemIndex = 0

	self.viewCtr.PrevMonItemIndex = 0
end

function SignInView:SignInFunc()
	 CC.Request("ReqSign")
end

function SignInView:SignatureFunc()
	CC.Request("ReqAskReplenish")
end

--关闭
function SignInView:Close()
	for i,v in ipairs(self.viewCtr.SignData.GetAskBox()) do
		if v.CanOpen then
			self:DispatchRedDotState(true);
			-- CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshRedPointState, {key = "SignBtn",state = true})
			--self:ActionOut()
			return
		end
	end

	self:DispatchRedDotState(false);
	-- CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshRedPointState, {key = "SignBtn",state = false})

	-- self:ActionOut()
end

function SignInView:DispatchRedDotState(state)

	self.activityDataMgr.SetActivityInfoByKey("SignInView", {redDot = state});

end

--摇色子
function SignInView:BtnShake()
end

--设置语言
function SignInView:setLanguageByText()
	self.BtnSignIn:FindChild("Text"):GetComponent("Text").text = self.language.Sign
	self.BtnSignature:FindChild("Text"):GetComponent("Text").text = self.language.SupplySign
	-- self.BtnSignatureGray:FindChild("Text"):GetComponent("Text").text = self.language.SupplySign
	self.BtnSignInGray:FindChild("Text"):GetComponent("Text").text = self.language.Sign
	self.winText:GetComponent("Text").text = self.language.WinText
end

function SignInView:OnDestroy()
	self:Close()
	self:CancelAllDelayRun()
	self:StopAllTimer()
	self:StopAllAction()

    CC.HallNotificationCenter.inst():post(CC.Notifications.OnpushShakeClose)
	-- self:StopUpdate()
	self.viewCtr:OnDestroy()
end

function SignInView:SetActiveEff()
	self.EffectBox:SetActive(false)
	self.SignInMain:FindChild("CaiDeng"):SetActive(false)
	self.BtnSignIn:FindChild("ljdl_an_shaoguan"):SetActive(false)
	self.BtnSignature:FindChild("ljdl_an_shaoguan"):SetActive(false)

	for i = 1,4 do
		self.ItemNode[i].IsChoose:SetActive(false)
		self.ItemNode[i].KuaiSuZhuanDon:SetActive(false)
	end
end

function SignInView:ActionIn()

	self:SetCanClick(false);

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function SignInView:ActionOut()

	self:SetCanClick(false)

	self:SetActiveEff()

	self:OnDestroy()


	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function SignInView:ActionShow()

	self:DelayRun(0.5, function() self:SetCanClick(true); end)

	self.transform:SetActive(true);
end

function SignInView:ActionHide()

	self:SetCanClick(false);

	self.transform:SetActive(false);
end

return SignInView