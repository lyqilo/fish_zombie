
local CC = require("CC")
local SendChipsView = CC.uu.ClassView("SendChipsView")


function SendChipsView:ctor(param)
	if param then
		self.playerId = param.playerId
		self.playerName = param.playerName
		self.vipLevel = param.vipLevel
		self.portrait = param.portrait
		--目标的等级
		self.targetPLevel = param.vipLevel
	end
	self.language = self:GetLanguage()
	self.timeNow = 60
	self.TradeInfo = {}
	self.IconTab = {}
	self.Telephone = CC.Player.Inst():GetSelfInfoByKey("Telephone")
	--vip0-2 的赠送默认金额
	self.vipSendConfig = {150000,250000,400000}

	self.GiftDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("GiftData")
	self.superBaseRatio = {9100, 9300, 9500, 9800, 10000}
	self.TaxFree = false
	self.TaxFreeTip = false
	self.extraCost = 0
end

function SendChipsView:OnCreate()
	self:init()
	self:addClickEvent()
	self:InitWhiteAccount()
	self:RegisterEvent()
	self:RefreshSwitchState()
end

function SendChipsView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.RefreshSwitchState, CC.Notifications.HallFunctionUpdate)
end

function SendChipsView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SendChipsView:init()
	self:FindChild("FrameBg/GiftRankItem/ItemName"):GetComponent("Text").text = self.playerName

	self.FrameBg = self:FindChild("FrameBg")
	self.lwzs = self:FindChild("lwzs")
	self.BtnShuoming = self.FrameBg:FindChild("BtnShuoming")
	self.BtnOTP = self.FrameBg:FindChild("BtnOTP")
	self.BtnOTPFlag = self.FrameBg:FindChild("BtnOTP/Image")
	
	self.VerificationCode = self:FindChild("VerificationCode")
	self.BtnSure = self.VerificationCode:FindChild("BG/BtnSure")
	self.BtnExit = self.VerificationCode:FindChild("BG/BtnExit")
	self.Ver_BtnSure = self.VerificationCode:SubGet("BG/BtnSure","Button")

	self.input = self:FindChild("FrameBg/InputChips")
	self.quotaNode = self:FindChild("FrameBg/quotaNode")

	local headNode = self:FindChild("FrameBg/GiftRankItem/Node")
	Util.ClearChild(headNode,false)
	local param = {}
	param.parent = headNode
	param.playerId = self.playerId
	param.portrait = self.portrait
	param.vipLevel = self.targetPLevel
	self:SetHeadIcon(param,headNode)

	self.material = ResMgr.LoadAsset("material", "Gray")

	local function TradeCallBack()
		self:Quota()
		local str = string.format(self.language.sendChipsTipsTitle,self.TradeInfo.MinLimit)
		self:FindChild("FrameBg/LblTax").text = str
		self:FindChild("FrameBg/exText").text = self.language.sendChipExTips
		--self.otpBtnStatus = self.TradeInfo.NoVerify
		--self.BtnOTPFlag:SetActive(self.otpBtnStatus)
	end
	self:ReqTrade(TradeCallBack)
	self:setLanguageByText()
	--根据等级动态监听输入框字符串
	self:CanSetInputField()
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 3 then
		self:FindChild("FrameBg/BtnSet"):SetActive(true)
	end
	self.TaxFree = CC.Player.Inst():GetSelfInfoByKey("EPC_TaxFree_Item") > 0

	self.verifyState = CC.Player.Inst():GetSafeCodeData().SafeService[4].Status
	self.BtnOTPFlag:SetActive(self.verifyState)
end

function SendChipsView:CanSetInputField()
	if self:GetLevel() < 3 then
		local fixStr = self.vipSendConfig[self:GetLevel()+1]
		self:OnChipsChange(fixStr)
        UIEvent.AddInputFieldOnValueChange(self.input,function(str)
			self:OnChipsChange(fixStr)
		end)
		self:AddClick(self.input,function()
			local callback = function()
                if self:GetLevel() == 0 and CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
                    local param = {}
					param.SelectGiftTab = {"NoviceGiftView"}
					CC.ViewManager.Open("SelectGiftCollectionView",param)
					self:closeView()
                else
					CC.SubGameInterface.OpenVipBestGiftView({needLevel = 3})
					self:closeView()
                end
		end
            local tip = CC.ViewManager.ShowTip(self.language.ToUpVipLimit,3,callback)
            tip:SetOneButton()
			tip:SetButtonText(self.language.UpVip)
		end)
	else
        UIEvent.AddInputFieldOnValueChange(self.input,function(str)
			self:OnChipsChange(str)
		end)
	end
end

function SendChipsView:RefreshSwitchState()
	--self.BtnOTP:SetActive(CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTP"))
end

function SendChipsView:ReqTrade(callback)
	--获取限制条件（锁定，今天赠送额度，最小赠送额度）
	CC.Request("ReqTradeInfo",nil,function(err,data)
		if err == 0 then
			log(CC.uu.Dump(data,"data = "))
			self.TradeInfo.BindingFlag = data.BindingFlag
			self.TradeInfo.Locked = data.Locked
			self.TradeInfo.Reserved = data.Reserved
			self.TradeInfo.AlreadySentToday = data.AlreadySentToday
			self.TradeInfo.AlreadySentVip = data.AlreadySentVip
			self.TradeInfo.MinLimit = data.MinLimit
			self.TradeInfo.MaxLimit = data.MaxLimit
			self.TradeInfo.NoVerify = data.NoVerify
			self.TradeInfo.NoVerifyTime = data.NoVerifyTime
			self.TradeInfo.RestNoVerifyTime = data.RestNoVerifyTime
			--self.TradeInfo.RestNoVerifyTime = 300
			self.TradeInfo.SmsToken = data.SmsToken
			self.TradeInfo.IOSTotalLimit = data.IOSTotalLimit
			self.TradeInfo.IOSLeftLimit = data.IOSLeftLimit
			self.TradeInfo.arrLockList = data.arrLockList
			self.TradeInfo.SetOneTimeTradeLimit = (data.SetOneTimeTradeLimit and data.SetOneTimeTradeLimit > 0) and data.SetOneTimeTradeLimit or nil
			self.TradeInfo.SetDailyTradeLimit = (data.SetDailyTradeLimit and data.SetDailyTradeLimit > 0) and data.SetDailyTradeLimit or nil
			self:SetWaitUnlockChipNum(data.arrLockList)
			self:SetFreeTaxProp(data.TaxFreeTime)
			callback()
		end
	end,
	function(err,data)
		self:Destroy()
	end)

end

function SendChipsView:SetWaitUnlockChipNum(data)
	local num = 0
	for _,v in ipairs(data) do
		if v.LeftTime > 0 or v.LeftUnlockMoney > 0 then
			num = num + v.LockMoney
		end
	end
	local canSendNum = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") - num
	self.quotaNode:FindChild("canSend/Num").text = canSendNum > 0 and canSendNum or 0
	self.quotaNode:FindChild("waitUnlock/Num").text = num
end

function SendChipsView:SetFreeTaxProp(countDown)
	if countDown <= 0 then
		self.TaxFree = false
	else
		local day = math.floor(countDown / 86400)
		local hours = math.ceil((countDown - day * 86400) / 3600)
		self:FindChild("FrameBg/FreeTak/Text").text = string.format(self.language.freeTakTime, day, hours)
	end
	self:FindChild("FrameBg/FreeTak"):SetActive(self.TaxFree)
end

--额度
function SendChipsView:Quota()
	self.vipLevel = self:GetLevel()
	self.curVipData = self:GetVipDatas()
	local showDetail = ""
	if self.vipLevel >= 14 then  --vip大于14级
		showDetail = self.language.NoLimit
		if self.TradeInfo.SetDailyTradeLimit then
			local num = tonumber(self.TradeInfo.SetDailyTradeLimit) - tonumber(self.TradeInfo.AlreadySentToday)
			num = num > 0 and num or 0
			local value = CC.uu.ChipFormat(num,true)
			showDetail = string.format(self.language.NoVipMax,value)
		end
	elseif self.vipLevel >= 0 and self.vipLevel < 14 then		--vip大于0小于14级显示额度
		if self.vipLevel >= 0 and self.vipLevel < 3 then
			local value = CC.uu.ChipFormat(tonumber(self.curVipData.MaxGiveCount) - tonumber(self.TradeInfo.AlreadySentVip),true)
			showDetail = string.format(self.language.NoVipMax,value)
		else
			local DailyTradeLimit = self.TradeInfo.SetDailyTradeLimit and self.TradeInfo.SetDailyTradeLimit or self.curVipData.MaxGiveCount
			local num = tonumber(DailyTradeLimit) - tonumber(self.TradeInfo.AlreadySentToday)
			num = num > 0 and num or 0
			local value = CC.uu.ChipFormat(num,true)
			showDetail = string.format(self.language.NoVipMax,value)
		end
	elseif self.vipLevel < 0 then --vip小于0
		showDetail = string.format(self.language.NoVipMax,0)
	end

	self:FindChild("FrameBg/QuotaText").text = showDetail
end

--vip等级
function SendChipsView:GetLevel()
	return CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
end

--获取筹码
function SendChipsView:GetChouMa()
	return CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
end

--获取自己的VIP数据
function SendChipsView:GetVipDatas()
	local vipDatas = CC.ConfigCenter.Inst():getConfigDataByKey("VIPRights")
	local curVipData = nil
	for k,v in pairs(vipDatas) do
		if v.Viplv == self.vipLevel then
			curVipData = v
			return curVipData
		end
	end
end

--获取留底 + 税 或者 锁定+税 的金额
function SendChipsView:GetGiveLockBool(num)
	local surplus = self:GetChouMa() - num
	local ret = 0
	local va = 0

	if surplus < self:OnGetExtraCost(num) then --手续费不足
		ret = self:OnGetExtraCost(num)
		va = 3
	else --留底 + 锁定
		ret = self.TradeInfo.Reserved + self.TradeInfo.Locked + self:OnGetExtraCost(num)
		va = 1
	end
	if surplus < ret and va == 1 then
		return 1 --保底
	elseif surplus < ret and va == 3 then
		return 3 --手续费不足
	end
	return 4
end

--计算缴纳的 税
function SendChipsView:OnGetExtraCost(num)
	local extraCost = 0
	local vipLevel = self:GetLevel()
	local curVipData =self:GetVipDatas()

	if num == nil then
		return
	end
	extraCost = math.ceil(num * curVipData.GivingTax)
	return extraCost
end

function SendChipsView:LanguageSwitch()
end

--设置头像
function  SendChipsView:SetHeadIcon(param,headNode)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	table.insert(self.IconTab,self.HeadIcon)
end

function SendChipsView:OnChipsChange(str)
	local numberLength = string.len(str)
	if numberLength > 12 then
		--最高12位
		str = string.sub(str,1,12)
	end
	self:FindChild("FrameBg/InputChips").text  = str
	self:FindChild("FrameBg/inputChipsShowText").text = CC.uu.ChipFormat(str,true)
end

--设置语言
function SendChipsView:setLanguageByText()
	self:FindChild("FrameBg/BtnSend/text").text = self.language.sendChipsConfirmTitle
	self:FindChild("FrameBg/GiftRankItem/ItemText"):GetComponent("Text").text = self.language.GiveAwayTo
	self:FindChild("FrameBg/InputChips/Placeholder"):GetComponent("Text").text = self.language.InputChips
	self.VerificationCode:FindChild("BG/BtnSure/Text"):GetComponent("Text").text = self.language.sendChipsConfirmTitle
	self.BtnShuoming:FindChild("SendShuomingText"):GetComponent("Text").text= self.language.Explaintitle
	self.BtnOTP:SubGet("BtnOTPText","Text").text= self.language.exemptPassWord
	self.VerificationCode:FindChild("BG/Image/TipText").text = self.language.tipText
	
	self:FindChild("FrameBg/BtnChat/Des/Text"):GetComponent("Text").text = self.language.btnChat
	self:FindChild("FrameBg/Super/Tip/Text"):GetComponent("Text").text = self.language.superTip
	self.quotaNode:FindChild("canSend").text = self.language.canSend
	self.quotaNode:FindChild("waitUnlock").text = self.language.waitUnlock
	self:FindChild("FrameBg/FreeTak/Tip/Text").text = self.language.freeTaxTip
end

--点击事件
function SendChipsView:addClickEvent()
	self:SetCanClick(false)
	CC.uu.DelayRun(0.8,function() self:SetCanClick(true) end)
	self:AddClick("closeBtn","closeView")
	self:AddClick("Bg","closeView")
	self:AddClick("FrameBg/BtnSend","sendChips")
	self:AddClick(self.BtnExit,function() self:ShowVerificationCode(false) end)
	self:AddClick(self.BtnShuoming,"OpenExplain")
	self:AddClick(self.BtnOTP,slot(self.OnOTPBtnClick,self))
	self:AddClick("FrameBg/BtnTips",slot(self.OpenTips,self))
	self:AddClick(self:FindChild("FrameBg/BtnChat"),function()
		local data = {}
		data.PlayerId = self.playerId
		data.Portrait = self.portrait
		data.HeadFrame = self.headFrame
		data.Nick = self.playerName
		data.Level = self.targetPLevel
		CC.ViewManager.ShowChatPanel(data)
	end)
	self:AddClick(self:FindChild("FrameBg/FreeTak"),function()
		self.TaxFreeTip = not self.TaxFreeTip
		self:FindChild("FrameBg/FreeTak/Tip"):SetActive(self.TaxFreeTip)
	end)

	self:AddClick(self:FindChild("FrameBg/BtnSet"),function()
		CC.ViewManager.Open("SendSetView")
		self:Destroy()
	end)
end

--超v白名单
function SendChipsView:InitWhiteAccount()
	self.targetWhiteAccount = self.GiftDataMgr:GetSuperWhiteAccount(self.playerId)
	local selfId = CC.Player.Inst():GetSelfInfoByKey("Id")
	self.oneselfWhiteAccount = self.GiftDataMgr:GetSuperWhiteAccount(selfId)
	if self.targetWhiteAccount or self.oneselfWhiteAccount then
		self:FindChild("FrameBg/BtnChat"):SetActive(true)
	end
	if self.oneselfWhiteAccount then
		self:FindChild("FrameBg/Super"):SetActive(true)
		self:FindChild("FrameBg/Super/Tip"):SetActive(true)
		self:FindChild("FrameBg/InputChips"):SetActive(false)
		self:FindChild("FrameBg/inputChipsShowText"):SetActive(false)
		self.quotaNode:SetActive(false)
		local baseRatio = self.superBaseRatio[1]
		if self.targetPLevel > 9 and self.targetPLevel < 15 then
			baseRatio = self.superBaseRatio[2]
		elseif self.targetPLevel >= 15 then
			baseRatio = self.superBaseRatio[3]
		end
		if selfId == 99999 or selfId == 999999 then
			if self.playerId == 11111 or self.playerId == 77777 or self.playerId == 55555 or self.playerId == 88888 then
				baseRatio = self.superBaseRatio[4]
				if self.playerId == 11111 then
					baseRatio = 9600
				end
			elseif self.playerId == 99999 or self.playerId == 999999 then
				baseRatio = self.superBaseRatio[5]
			end
		end
		self:FindChild("FrameBg/Super/Base/Text").text = baseRatio
		self.InputThbText = self:SubGet("FrameBg/Super/InputThb","InputField")
		self.totalChips = self:FindChild("FrameBg/Super/TotalChip/Text")
		self.Text_real = self:FindChild("FrameBg/Super/TotalChip/Text_real")
		UIEvent.AddInputFieldOnValueChange(self:FindChild("FrameBg/Super/InputThb"), function(str)
			self.InputThbText.text = str
			local thbNum = tonumber(self.InputThbText.text)
			if thbNum and thbNum > 0 then
				self.totalChips.text = CC.uu.ChipFormat(thbNum * baseRatio,true)
				self.Text_real.text = thbNum * baseRatio
			end
			if thbNum then
				self:FindChild("FrameBg/Super/Tip"):SetActive(false)
			else
				self.totalChips.text = ""
				self.Text_real.text = ""
				self:FindChild("FrameBg/Super/Tip"):SetActive(true)
			end
		end)
	end
end

function SendChipsView:OpenExplain()
	CC.ViewManager.Open("SendChipsExplainView")
end

function SendChipsView:OnOTPBtnClick()
	
	if not CC.HallUtil.CheckSafePassWord() then
		return
	end

	local ver = self.verifyState and 1 or 0
	local tex = self.verifyState and self.language.cancelExVer or self.language.openExVer
	CC.ViewManager.Open("VerSafePassWordView",{isVerify = ver,serviceType = 4,confirmStr = tex,verifySuccFun = function(err,data)
		--验证安全码错误
		if err ~= 0 then return end

		self.verifyState = not self.verifyState
		CC.Player.Inst():GetSafeCodeData().SafeService[4].Status = self.verifyState
		self.BtnOTPFlag:SetActive(self.verifyState)
	end})
end

function SendChipsView:OpenTips()
	local param = {}
	param.reserved = self.TradeInfo.Reserved -- + self.TradeInfo.Locked
	param.limit = self.TradeInfo.MaxLimit
	self.vipLevel = self:GetLevel()
	if self.vipLevel < 3 then
		param.left = self.TradeInfo.MaxLimit - self.TradeInfo.AlreadySentVip
	else
		param.left = self.TradeInfo.MaxLimit - self.TradeInfo.AlreadySentToday
	end
	param.payments = self.TradeInfo.arrLockList
	param.payNum = #param.payments
	CC.ViewManager.Open("SendChipsTipsView",param)
end

--关闭界面
function SendChipsView:closeView()
	self.Ver_BtnSure:SetBtnEnable(true)
	self:Destroy()
end

function SendChipsView:OnDestroy()
	for i,v in ipairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
	end

	self:UnRegisterEvent();
end

function SendChipsView:TextDetail(titletext,contenttext)
	self.VerificationCode:FindChild("BG/Image/titleText"):GetComponent("Text").text = titletext
	self.VerificationCode:FindChild("BG/Image/ContentText"):GetComponent("Text").text = contenttext
end

function SendChipsView:Passer()
	local function callback()
		self:ShowVerificationCode(true)
	end
	self:ReqTrade(callback)
end

--点击确定按钮，判断各种限制条件
function SendChipsView:sendChips()
	local id = self.playerId
	id = tonumber(id)
	local num = self:FindChild("FrameBg/InputChips").text
	if self.oneselfWhiteAccount then
		num = self.Text_real.text
	end
	--是否拥有足够的筹码
	local function moneyNotEnough(num)
		local curNum = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
		if curNum < tonumber(num) then
			return true
		else
			return false
		end
	end
	--最小赠送额度
	local function lowThanLimit(num)
		local limitNum = tonumber(self.TradeInfo.MinLimit)
		if limitNum > tonumber(num) then
			return true
		else
			return false
		end
	end
	--输入的筹码不能为空，筹码不足，赠送筹码小于90万
	if num == nil or num == "" then
		CC.ViewManager.ShowTip(self.language.numCannotEmpty,3)
		return
	elseif moneyNotEnough(num) then
		CC.ViewManager.ShowTip(self.language.sendTip1,3)
		return
	elseif lowThanLimit(num) then
		local str = string.format(self.language.sendTip2,self.TradeInfo.MinLimit)
		CC.ViewManager.ShowTip(str,3)
		return
	end
	--是否绑定 facebook
	-- if bit.band(self.TradeInfo.BindingFlag, CC.shared_enums_pb.EF_Binded) == 0 and bit.band(self.TradeInfo.BindingFlag, CC.shared_enums_pb.EF_LineBinded) == 0 then
	-- 	CC.ViewManager.ShowTip(self.language.FaceBand,3)
	-- 	return
	-- end
	--是否绑定 tel
	if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify") then
		if not CC.HallUtil.CheckTelBinded() then
			CC.ViewManager.ShowTip(self.language.TelBand,3)
			return
		end
	end
	
	if not self.targetWhiteAccount and self:GetLevel() == 0 and CC.Player.Inst():GetSelfInfoByKey("EPC_TotalRecharge") <= 0 then
		CC.ViewManager.ShowTip(self.language.needPay)
		return
	end

	--vip小于3并且 对象的等级小于28
    if not self.targetWhiteAccount and self:GetLevel() < 3 and self.targetPLevel < 28 then
		CC.ViewManager.ShowTip(self.language.otherVipNot)
		return
    end

	local DailyTradeLimit = self.TradeInfo.SetDailyTradeLimit
	--vip小于3并且今日赠送额度大于等于今天最大赠送额度
	if self:GetLevel() < 3 then
		local tempNum = tonumber(self.TradeInfo.AlreadySentVip)
		local Limit = DailyTradeLimit and DailyTradeLimit or tonumber(self:GetVipDatas().MaxGiveCount)
		if tempNum >= Limit then
			--local str = string.format(self.language.QuotaLimit,Limit - tempNum,Limit)
			CC.ViewManager.ShowTip(self.language.QuotaLimit)
			return
		end
	end

	if self:GetLevel() >= 3 and self:GetLevel() < 14 then
		local tempNum = tonumber(self.TradeInfo.AlreadySentToday)
		local Limit = DailyTradeLimit and DailyTradeLimit or tonumber(self:GetVipDatas().MaxGiveCount)
		if tempNum >= Limit then
			--local str = string.format(self.language.QuotaLimit,Limit - tempNum,Limit)
			CC.ViewManager.ShowTip(self.language.QuotaLimit)
			return
		end
	end
	if  self:GetLevel() >=14 and DailyTradeLimit then
		local tempNum = tonumber(self.TradeInfo.AlreadySentToday)
		if tempNum >= DailyTradeLimit then
			--local str = string.format(self.language.QuotaLimit,DailyTradeLimit - tempNum,DailyTradeLimit)
			CC.ViewManager.ShowTip(self.language.QuotaLimit)
			return
		end
	end
	--vip小于3并且 今日赠送额度 + （此刻）赠送大于今天最大赠送额度
	if self:GetLevel() < 3 then
		local tempNum = (tonumber(self.TradeInfo.AlreadySentVip) + tonumber(num))
		local Limit = DailyTradeLimit and DailyTradeLimit or tonumber(self:GetVipDatas().MaxGiveCount)
		if tempNum > Limit then
			CC.ViewManager.ShowTip(self.language.QuotaInput)
			return
		end
	end

	if self:GetLevel() >= 3 and self:GetLevel() < 14 then
		local tempNum = (tonumber(self.TradeInfo.AlreadySentToday) + tonumber(num))
		local Limit = DailyTradeLimit and DailyTradeLimit or tonumber(self:GetVipDatas().MaxGiveCount)
		if tempNum > Limit then
			CC.ViewManager.ShowTip(self.language.QuotaInput)
			return
		end
	end

	if self:GetLevel() >= 14 and DailyTradeLimit then
		local tempNum = (tonumber(self.TradeInfo.AlreadySentToday) + tonumber(num))
		if tempNum > DailyTradeLimit then
			CC.ViewManager.ShowTip(self.language.QuotaInput)
			return
		end
	end

	--超过单笔赠送上限
	if self.TradeInfo.SetOneTimeTradeLimit and tonumber(num) > self.TradeInfo.SetOneTimeTradeLimit then
		CC.ViewManager.ShowTip(self.language.Tip1)
		return
	end

	-- if self.TradeInfo.IOSLeftLimit > 0 and self.TradeInfo.IOSLeftLimit ~= nil then
	-- 	 local IOSTotal = CC.uu.NumberFormat(self.TradeInfo.IOSTotalLimit)
	-- 	 local IOSLeft = CC.uu.NumberFormat(self.TradeInfo.IOSLeftLimit)

	-- 	 local str = IOSLeft.."/"..IOSTotal
	-- 	 local strfomat = string.format(self.language.Flowing_water,str)
	-- 	 CC.ViewManager.ShowTip(strfomat)
	-- 	return
	-- end

	--保底，锁定
	if self:GetGiveLockBool(num) == 1 then--保底 + 锁定
		CC.ViewManager.ShowTip(self.language.KeepTheBottom)
		return
	elseif self:GetGiveLockBool(num) == 3 then --手续费不足
		CC.ViewManager.ShowTip(self.language.Insufficient_service)
		return
	end
	
	if not CC.HallUtil.CheckSafePassWord() then
		return
	end

	local nextFun = function(err,result)
		--验证安全码错误
		if err ~= 0 then return end

		num = tonumber(num)
		self.extraCost = self:OnGetExtraCost(num)
		local showDetail = string.format(self.language.comfirmSendChips,CC.uu.DiamondFortmat(self.extraCost))
		local t_text = string.format(self.language.GiveDdata,self.playerId,CC.uu.DiamondFortmat(num))
		if not self.TaxFree then
			--没有免税道具
			t_text = t_text..","..showDetail
		end
		--赠送收益手续费相关
		local ComFirmOK = nil
		local feeData = {}
		feeData.Target = id
		feeData.Amount = tonumber(num)
		CC.Request("ReqGetAgentRevenue",feeData,function(err,data)
			if err == 0 then
				local spreadFeeNum = data.Revenue
				if spreadFeeNum > 0 then
					self.VerificationCode:FindChild("BG/Image/ContentText").sizeDelta = Vector2(610, 52.4)
					local spreadFeeText = string.format(self.language.spreadFee,CC.uu.DiamondFortmat(spreadFeeNum))
					ComFirmOK =spreadFeeText..self.language.ComFirmOK

				else
					ComFirmOK = self.language.ComFirmOK
				end
				self:CheckMonthCard()  --月卡
				--self:Passer()  --30天免短信验证
				self:DelayRun(0.1,function() self:ShowVerificationCode(true) end)
				self:TextDetail(t_text,ComFirmOK)
				self:AddClick(self.BtnSure,function() self:sendChipsRequset(id,num,result.Token) end)
			end
		end,function(err)
			logError(err)
		end)
	end

	if not self.verifyState then
		CC.ViewManager.Open("VerSafePassWordView",{isVerify = 1,serviceType = 4,verifySuccFun = nextFun})
	else
		nextFun(0,{Token = ""})
	end
end

function SendChipsView:CheckMonthCard()
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") > 0 then
		local data = {
			propIds = {CC.shared_enums_pb.EPC_Supreme},
			succCb = function() self:ShowMonthCard() end
		}
		CC.HallUtil.ReqPlayerPropByIds(data)
	end
end

--月卡减免手续费
function SendChipsView:ShowMonthCard()
	local card = CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") or 0
	self.VerificationCode:FindChild("BG/MonthCard"):SetActive(card > 0)
	if card > 0 then
		self.VerificationCode:FindChild("BG/MonthCard/Text1").text = self.language.serviveCharge
		self.VerificationCode:FindChild("BG/MonthCard/Text2").text = string.format(self.language.original,CC.uu.DiamondFortmat(self.extraCost)) --原手续费
		self.extraCost = math.floor((self.extraCost - self.extraCost*0.1) + 0.5)
		self.VerificationCode:FindChild("BG/MonthCard/Text3").text = string.format(self.language.now,CC.uu.DiamondFortmat(self.extraCost)) --拥有月卡之后手续费
	end
end

function SendChipsView:ShowVerificationCode(isShow)
	if isShow then
		self:SetCanClick(false)
		self.VerificationCode:FindChild("BG").transform.localScale = Vector3(0.5,0.5,1)
		self.VerificationCode:SetActive(true)
		self:RunAction(self.VerificationCode:FindChild("BG"), {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
				self:SetCanClick(true);
			end})
	else
		self:SetCanClick(false);
		self:RunAction(self.VerificationCode:FindChild("BG"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
			self.VerificationCode:SetActive(false)
			self:SetCanClick(true)
			end})
	end
end

--点击赠送
function SendChipsView:sendChipsRequset(id,num,token)
	if id == nil then
		CC.ViewManager.ShowTip(self.language.idCannotEmpty,3)
	else
		self.Ver_BtnSure:SetBtnEnable(false)
		local param = {}
		param.Target = tonumber(id)
		param.Amount = tonumber(num)
		param.MailTitle = tostring(self.language.MailTitle)
		local MailContent = string.format(self.language.MailContent,tonumber(CC.Player.Inst():GetSelfInfoByKey("Id")))
		param.MailContent = tostring(MailContent)
		param.SmsToken = ""
		param.SafeToken = token

		CC.Request("ReqTrade",param,function(err,data)
			if err == 0 then
				local te_data = {
					To = self.playerId,
					AnotherPlayer = {Nick = self.playerName,Portrait = self.portrait,Level = self.targetPLevel},
					VipLevelTo = self.targetPLevel,
				    Amount = tonumber(num),
					AgentRevenue = self.extraCost,
					Time = CC.uu.TimeOut5(CC.HallUtil.GetCurServerTime(true)) 
				 }
				CC.HallNotificationCenter.inst():post(CC.Notifications.ReqTradeSuccess,te_data)
				self.extraCost = 0

				CC.ViewManager.ShowTip(self.language.sendSuccess,3)
				self.Ver_BtnSure:SetBtnEnable(true)
				self:Destroy()
				CC.FirebasePlugin.TrackSendChips();
			end
		end,function(err)
			self.Ver_BtnSure:SetBtnEnable(true)
			if err == CC.shared_en_pb.TradeSendChipsLimit then
				--弹出防诈骗窗口
				CC.ViewManager.Open("SendAntifraudView",self.playerId)
				self:Destroy()
			end
		end)
	end
end

function SendChipsView:ActionIn()

end

return SendChipsView