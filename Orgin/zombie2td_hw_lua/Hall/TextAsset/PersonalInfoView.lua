local CC = require("CC")
local PersonalInfoView = CC.uu.ClassView("PersonalInfoView")

function PersonalInfoView:ctor(param)
	self:InitVar(param);
end

function PersonalInfoView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function PersonalInfoView:InitVar(param)
	self.param = param or {}
	self.headIcon = nil;

	self.language = self:GetLanguage();
	self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
	self.selfInfoPrefabs = {}
	self.curIconPrefabs = {}
	self.nextIconPrefabs = {}
	self.curPrefabs = {}
	self.nextPrefabs = {}
	self.scrollDirUp = true
	self.getChipCount = 0
	self.isUploading = false
end

function PersonalInfoView:InitContent(param)
	self.selfInfoToggle = self:FindChild("LeftPanel/LayoutGroup/SelfInfo");
	UIEvent.AddToggleValueChange(self.selfInfoToggle, function(selected)
		self:FindChild("InfoPanel"):SetActive(selected)
		if selected then
			self:OnClickSelfInfo()
		end
	end)
	self.VIPToggle = self:FindChild("LeftPanel/LayoutGroup/VIP");
	UIEvent.AddToggleValueChange(self.VIPToggle, function(selected)
		self:FindChild("VIPPanel"):SetActive(selected)
	end)
	self:AddClick(self:FindChild("LeftPanel/BtnCrystalStore"), function() CC.ViewManager.Open("CrystalStoreView") end)

	self.GiftPanel = self:FindChild("GiftPanel")
	self.GiftToggle = self:FindChild("LeftPanel/LayoutGroup/Gift");
	if Util.GetFromPlayerPrefs("RightGiftFinishBuy"..CC.Player.Inst():GetSelfInfoByKey("Id")) ~= "true" then
		self.rightsGiftView = CC.uu.CreateHallView("VipRightsGiftView",{parent = self.GiftPanel})
		UIEvent.AddToggleValueChange(self.GiftToggle, function(selected)
			self.GiftPanel:SetActive(selected)
			if selected then
				CC.LocalGameData.SetLocalDataToKey("VipRightsGift", CC.Player.Inst():GetSelfInfoByKey("Id"))
			end
		end)
	end
	local btnFaceBook = self:FindChild("LeftPanel/BtnFaceBook");
	self:AddClick(btnFaceBook, "OnClickBindFaceBook");
	btnFaceBook:SetActive(param.showBtnFaceBook); 
	local btnLine = self:FindChild("LeftPanel/BtnLine");
	self:AddClick(btnLine, "OnClickBindLine");
	btnLine:SetActive(param.showBtnLine);

	self:AddClick(self:FindChild("InfoPanel/Top/Nick/NickInputField/PenIcon"),"OnClickRename")
	self:AddClick(self:FindChild("InfoPanel/Top/Birthday/BtnChange"),"OnClickReBirthday")

	local safeBox = self:FindChild("InfoPanel/Top/SafeBox")
	safeBox:SetActive(true)
    self:AddClick(safeBox, "OnClickSafaBox");

	local btnBackpack = self:FindChild("InfoPanel/Top/BtnBackpack")
	self:AddClick(btnBackpack,"OnClickBackpack")
	if self.param and self.param.guideFun then
		self.param.guideFun(btnBackpack)
	end
	local nickInput = self:FindChild("InfoPanel/Top/Nick/NickInputField");
	if param.unClickNickInputField then
		nickInput:GetComponent("InputField").enabled = false
	end
	UIEvent.AddInputFieldOnValueChange(nickInput, function(str)
			if str == "" then
				nickInput:GetComponent("InputField").text = "Royal_pid";
				CC.ViewManager.ShowTip(self.language.nickInputTip);
				return
			end
		end);

	local signInput = self:FindChild("InfoPanel/Top/Signature/SignInputField");
	UIEvent.AddInputFieldOnEndEdit(signInput, function(value)
			CC.DebugDefine.CheckDebugKey(value);
		end)

	self:AddClick(self:FindChild("InfoPanel/Bottom/BtnDetermine"), "OnClickDetermine");
	self:AddClick(self:FindChild("InfoPanel/Bottom/BtnVIP"), "OnClickVIPRights")
	--添加礼券Tips
	--self:AddClick("InfoPanel/Top/TotalIntegral", "ShowIntegralTips")
	--Vip点
	self:AddClick("InfoPanel/Bottom/VipSpot/BtnExchange",function ()
		if not CC.ViewManager.IsSwitchOn("VIPPoint") then
			return;
		end
		self:ShowExchangePanel(true)
	end)
	self:AddClick("Exchange/bg/ExitBtn",function ()
		self:ShowExchangePanel(false)
		self:ResetExchange()
	end)
	self:AddClick("Exchange/bg/AddBtn",function ()
		self:RefreshExchange(true)
		self:CheckMonthCard(self.getChipCount)
	end)
	self:AddClick("Exchange/bg/LessBtn",function ()
		self:RefreshExchange(false)
		self:CheckMonthCard(self.getChipCount)
	end)
	self:AddClick("Exchange/bg/SubBtn","ExchangePoint")

	self:AddClick("TopPanel/BtnBack", "CloseView")
	self:AddClick("TopPanel/BtnClose", "CloseView")
	--解绑手机界面
	self:AddClick("InfoPanel/Top/Telephone", "OnClickTelephone")
	self:AddClick("InfoPanel/Top/Sex", "OnClickSex")

	--vip权益相关
	self.selfRightsParent = self:FindChild("InfoPanel/Bottom/Group")
	self.curVipParent = self:FindChild("VIPPanel/CurEquities/Group")
	self.nextVipParent = self:FindChild("VIPPanel/VIPEquities/Group")
	self.ScrollContent = self:FindChild("VIPPanel/Scroll/Viewport/Content")
	self.EquitiesItem = self:FindChild("EquitiesItem")
	self.IconItem = self:FindChild("IconItem")
	self:AddClick("VIPPanel/BtnRight","VIPEquitiesRight")
	self:AddClick("VIPPanel/BtnLeft","VIPEquitiesLeft")
	self:AddClick(self:FindChild("VIPPanel/VIPEquities/BtnRecharge"), function()
		self.viewCtr:OnOpenDetermineView()
	end)
	self.BtnBottom = self:FindChild("VIPPanel/VIPEquities/BtnBottom")
	self:AddClick(self.BtnBottom, function()
		self:SetEquitiesScroll(not self.scrollDirUp)
	end)
	self.scrollRect = self:FindChild("VIPPanel/Scroll")
	UIEvent.AddScrollRectOnValueChange(self.scrollRect,function (v)
		if v.y < 0.9 then
			self.scrollDirUp = false
			self.BtnBottom.localScale = Vector3(1, -1, 1)
		else
			self.scrollDirUp = true
			self.BtnBottom.localScale = Vector3(1, 1, 1)
		end
	end)

	self:AddClick("InfoPanel/Top/Birthday/Image2",function ()
		if self.isUploading then return end
		CC.ViewManager.Open("VerifiedView")
	end)
	self:InitEquitiesPrefabs()

	self:InitTextByLanguage()
	self:CheckeHallScene()

	self.viewCtr:CheckOtherView()
	self:SetSafeBoxTip()
end

function PersonalInfoView:InitTextByLanguage()
	--个人信息
	self:FindChild("LeftPanel/LayoutGroup/SelfInfo/Text").text = self.language.selfInfo
	self:FindChild("LeftPanel/LayoutGroup/SelfInfo/Select/Text").text = self.language.selfInfo
	self:FindChild("InfoPanel/Top/BaseInfo/Text").text = self.language.baseInfo
	--self:FindChild("InfoPanel/Top/Nick/Des").text = self.language.nickName
	--self:FindChild("InfoPanel/Top/BtnPerfectInfo/Text").text = self.language.completeInfo;
	--self:FindChild("InfoPanel/Top/Sex/Des").text = self.language.sex
	--self:FindChild("InfoPanel/Top/Birthday/Des").text = self.language.birth
	--self:FindChild("InfoPanel/Top/TotalIntegral/Tips/Text").text = self.language.integralTips
	self:FindChild("InfoPanel/Top/MaxWinChip/Des").text = self.language.maxWinChips
	self:FindChild("InfoPanel/Top/TotalWinChip/Des").text = self.language.totalWin
	self:FindChild("InfoPanel/Top/Signature/Text").text = self.language.signature
	self:FindChild("InfoPanel/Top/CurId/Id").text = self.language.idTitle
	self:FindChild("InfoPanel/Bottom/CurVip/CurLevel/Text").text = self.language.curVipLevel
	self:FindChild("InfoPanel/Bottom/Experience/VIP0").text = self.language.anyPay
	self:FindChild("InfoPanel/Bottom/Experience/Recharge/Title").text = self.language.rechargeTips
	self:FindChild("InfoPanel/Bottom/VipSpot/VIPSpot/Text").text = self.language.vipPoint
	self:FindChild("InfoPanel/Bottom/VipSpot/BtnExchange/Text").text = self.language.exchange
	self:FindChild("InfoPanel/Top/SafeBox/Image/Text").text = self.language.box
	self:FindChild("InfoPanel/Top/SafeBox/New/Text").text = "NEW"
	--Vip权益
	self:FindChild("LeftPanel/LayoutGroup/VIP/Text").text = self.language.VipInfo
	self:FindChild("LeftPanel/LayoutGroup/VIP/Select/Text").text = self.language.VipInfo
	self:FindChild("VIPPanel/CurEquities/CurLevel/Des").text = self.language.curVip
	--特权礼包
	self:FindChild("LeftPanel/LayoutGroup/Gift/Text").text = self.language.GiftInfo
	self:FindChild("LeftPanel/LayoutGroup/Gift/Select/Text").text = self.language.GiftInfo
	--vip点兑换
	self:FindChild("Exchange/bg/Title/Text").text = self.language.exchangeCenter
	self:FindChild("Exchange/bg/SPLabel").text = self.language.vipPoint
	self:FindChild("Exchange/bg/SubBtn/Text").text = self.language.exchange
	self:FindChild("Exchange/bg/Tip").text = self.language.tip_vipSpot
	self:FindChild("InfoPanel/Top/Birthday/Image2/Image/Text").text = self.language.realName
end

function PersonalInfoView:ShowBrithRealUI(index)
	self:FindChild("InfoPanel/Top/Birthday/Image2"):SetActive(false)
	self:FindChild("InfoPanel/Top/Birthday/Number/Loading"):SetActive(false)
	self:FindChild("InfoPanel/Top/Birthday/Number/Done"):SetActive(false)
	local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	if vip < 5 then
		return
	end
	if index == 0 then
		self:FindChild("InfoPanel/Top/Birthday/Image2"):SetActive(true)
	elseif index == 1 then
		self.isUploading = true
		self:FindChild("InfoPanel/Top/Birthday/Number/Loading"):SetActive(true)
	elseif index == 2 then

		self:FindChild("InfoPanel/Top/Birthday/Image2"):SetActive(true)
	elseif index == 3 then
		self:FindChild("InfoPanel/Top/Birthday/Number/Done"):SetActive(true)
	end
	
end

--检查是否在大厅
function PersonalInfoView:CheckeHallScene()
	--屏蔽修改昵称、签名、背包
	local isHall = CC.ViewManager.IsHallScene()
	if not isHall then
		local signInput = self:FindChild("InfoPanel/Top/Signature/SignInputField"):GetComponent("InputField");
		signInput.enabled = false;
	end

	if self.param.Upgrade == 1 and not self:IsPortraitView() then
		self.VIPToggle:GetComponent("Toggle").isOn = true;
		self.selfInfoToggle:SetActive(isHall)
		if not isHall then self.GiftToggle:SetActive(false) end
	elseif self.param.Upgrade == 2 and not self:IsPortraitView() then
		self:DelayRun(0.5,function()
			if self.GiftToggle.activeSelf then
				self.selfInfoToggle:SetActive(false)
				self.VIPToggle:SetActive(false)
				self.GiftToggle:GetComponent("Toggle").isOn = true
			else
				self.VIPToggle:SetActive(true)
				self.VIPToggle:GetComponent("Toggle").isOn = true
			end
		end)
	else
		self.selfInfoToggle:GetComponent("Toggle").isOn = true;
		self.VIPToggle:SetActive(isHall)
	end

	--self:FindChild("TopPanel/Image"):SetActive(isHall)
	self:FindChild("TopPanel/logo"):SetActive(isHall)
	self:FindChild("TopPanel/BtnBack"):SetActive(isHall)
	self:FindChild("TopPanel/BtnClose"):SetActive(not isHall)
	self:FindChild("InfoPanel/Top/BtnBackpack"):SetActive(isHall)
	self:FindChild("InfoPanel/Bottom/BtnVIP"):SetActive(isHall)
end

function PersonalInfoView:CreateHeadIcon(playerData)
	local data = {};
	data.parent = self:FindChild("InfoPanel/Top/HeadNode");
	data.playerId = playerData.id;
	data.clickFunc = "ScaleEffect";
	data.showFrameEffect = true;
	data.clickFunc = function()
		self.viewCtr:OnOpenHeadChoose();
	end
	self.headIcon = CC.HeadManager.CreateHeadIcon(data);
end

function PersonalInfoView:OnClickSelfInfo()
--个人信息
	self.viewCtr:ChangeToInfoPanel();
end

function PersonalInfoView:RefreshSelfInfoUI(param)
	CC.uu.Log(param,"refresh:")
	if not param then return end
	--创建头像
	if param.createHeadId then
		self:CreateHeadIcon(param);
	end
	--设置玩家名字
	if param.nick then
		self:FindChild("InfoPanel/Top/Nick/NickInputField"):GetComponent("InputField").text = param.nick;
	end
	--设置玩家id
	if param.id then
		self:SetText(self:FindChild("InfoPanel/Top/CurId/Text"), param.id);
		self:SetText(self:FindChild("InfoPanel/Top/VIPId/Text"), param.id);
	end
	-- 设置性别
	if param.sex then
		--self:SetText(self:FindChild("InfoPanel/Top/Sex/Number"), param.sex);
		self:FindChild("InfoPanel/Top/Sex/Male"):SetActive(param.sex == CC.shared_enums_pb.S_Male)
		self:FindChild("InfoPanel/Top/Sex/Female"):SetActive(param.sex == CC.shared_enums_pb.S_Female)
	end
	--设置出生日期
	if param.birth then
		self:SetText(self:FindChild("InfoPanel/Top/Birthday/Number"), self:GetDecodeBirth(param.birth));
		if param.birth ~= "" then
			self:FindChild("InfoPanel/Top/Birthday/BtnChange"):SetActive(CC.Player.Inst():GetBirthdayGiftData().UpdateBirthStatus)
		else
			self:FindChild("InfoPanel/Top/Birthday/BtnChange"):SetActive(true)
		end
	end
	if param.telephone then
		self:SetText(self:FindChild("InfoPanel/Top/Telephone/Text"), CC.uu.phoneNumberToSecret(param.telephone,3,8));
	end
	--设置玩家当前筹码
	if param.curChips then
		self:SetText(self:FindChild("TopPanel/TotalChips/Number"), param.curChips);
	end
	--当前钻石
	if param.curDiamond then
		self:SetText(self:FindChild("TopPanel/TotalDiamond/Number"), param.curDiamond);
	end
	--当前礼票
	if param.curIntegral then
		self:SetText(self:FindChild("TopPanel/TotalIntegral/Number"), param.curIntegral);
	end
	--设置玩家最高赢取
	if param.maxWin then
		self:SetText(self:FindChild("InfoPanel/Top/MaxWinChip/Number"), param.maxWin);
	end
	--设置玩家总赢取
	if param.totalWin then
		self:SetText(self:FindChild("InfoPanel/Top/TotalWinChip/Number"), param.totalWin);
	end
	--设置玩家签名
	if param.personSign then
		local inputField = self:FindChild("InfoPanel/Top/Signature/SignInputField"):GetComponent("InputField");
		inputField.text = param.personSign;
	end

	--设置当前vip等级
	if param.curLevel then
		self:SetText(self:FindChild("InfoPanel/Bottom/CurVip/VipIcon/Text"), param.curLevel);
		local vipIcon = self:FindChild("InfoPanel/Bottom/CurVip/VipIcon");
		vipIcon:SetImage(string.format("vip%d", math.floor(param.curLevel/10)+1 > 3 and 3 or math.floor(param.curLevel/10)+1));
		--是否充值过
		local isPurchase = true
		if param.curLevel <= 0 and CC.Player.Inst():GetSelfInfoByKey("EPC_TotalRecharge") <= 0 then
			isPurchase = false
		end
		self:FindChild("InfoPanel/Bottom/Experience/VIP0"):SetActive(not isPurchase)
		self:FindChild("InfoPanel/Bottom/Experience/Recharge"):SetActive(isPurchase)
		self:FindChild("InfoPanel/Bottom/Experience/Progress"):SetActive(isPurchase)
		if param.curLevel == 0 then
			self:FindChild("InfoPanel/Bottom/BtnDetermine/Text").text = self.language.btnUnlock
		else
			self:FindChild("InfoPanel/Bottom/BtnDetermine/Text").text = self.language.btnLevel
		end
		if param.curLevel >= 20 then
			self:FindChild("InfoPanel/Top/VIPId"):SetActive(true);
			self:FindChild("InfoPanel/Top/CurId/Text"):SetActive(false);
			if param.curLevel >= 30 then
				self:FindChild("VIPPanel/VIPEquities"):SetActive(false)
				self:FindChild("VIPPanel/maskScroll"):SetActive(true)
				self:FindChild("VIPPanel/BtnRight"):SetActive(false)
				self:FindChild("VIPPanel/BtnLeft"):SetActive(false)
				for i = 1, #self.nextPrefabs do
					self.nextPrefabs[i]:FindChild("Cur"):SetActive(false)
					self.nextPrefabs[i]:FindChild("Next"):SetActive(false)
				end
				self:FindChild("InfoPanel/Bottom/BtnVIP"):SetActive(false)
				self:FindChild("InfoPanel/Bottom/Experience"):SetActive(false)
				self:FindChild("InfoPanel/Bottom/BtnDetermine"):SetActive(false)
			end
		end
		self:SetText(self:FindChild("VIPPanel/CurEquities/CurLevel/Level"), param.curLevel);
	end
	--设置下一级vip等级
	if param.nextLevel then
		self:FindChild("InfoPanel/Bottom/BtnVIP/Text").text = string.format(self.language.vipRights, param.nextLevel)
	end
	--设置下一级升级所需经验值
	if param.nextLvlNeedExp then
		self:SetText(self:FindChild("InfoPanel/Bottom/Experience/Recharge/Text"), string.format("%s฿",param.nextLvlNeedExp));
	end
	--设置经验进度
	if param.expProgress then
		local progress = self:FindChild("InfoPanel/Bottom/Experience/Progress/CurProgress"):GetComponent("Image");
		progress.fillAmount = param.expProgress;
	end

	-- if param.hideBtnBindPhone then
	-- 	self:FindChild("InfoPanel/Top/BtnPerfectInfo"):SetActive(false);
	-- 	self:FindChild("InfoPanel/Top/SafeBox"):SetActive(true);
	-- end
	if param.hideBtnBindFacebook then
		self:FindChild("LeftPanel/BtnFaceBook"):SetActive(false);
	end
	if param.hideBtnBindLine then
		self:FindChild("LeftPanel/BtnLine"):SetActive(false);
	end
	if param.curRightsInfo then
		self:ReFreshVipRightsIcon(param.curRightsInfo, self.viewCtr.RightsIconType.selfType)
		self:ReFreshVipRightsIcon(param.curRightsInfo, self.viewCtr.RightsIconType.curType)
		self:ReFreshEquities(param.curRightsInfo, true)
	end
	if param.nextRightsInfo then
		self:ReFreshVipRightsIcon(param.nextRightsInfo, self.viewCtr.RightsIconType.nextType)
		self:ReFreshEquities(param.nextRightsInfo, false)
		self:FindChild("VIPPanel/VIPEquities/Level/Text").text = string.format("VIP%s", param.nextRightsInfo.VipLv)
	end
	if param.nextLvlRecharge then
		self:FindChild("VIPPanel/VIPEquities/BtnRecharge/Text").text = param.nextLvlRecharge .. "฿"
	end
end

function PersonalInfoView:RefreshVipPoint()
	self.vipSpot = math.floor(CC.Player.Inst():GetSelfInfoByKey("EPC_VIPPoint")/20000)
	self:FindChild("InfoPanel/Bottom/VipSpot/VIPSpot").text = CC.uu.numberToStrWithComma(self.vipSpot)
	if self.vipSpot > 10000 then
		self.num = 1
	else
		self.num = 0
	end
	self:RefreshExchange(false)
	local level = self.viewCtr:GetPropValueByKey("EPC_Level")
	self:FindChild("Exchange/bg/SPLabel/VIPSpot").text = CC.uu.numberToStrWithComma(self.vipSpot)
	self:FindChild("Exchange/bg/VIPLevel").text = string.format(self.language.VIPSpotRatio_exchange,self.viewCtr.vipNewRight[level+1].PointExchange.Count)
end

function PersonalInfoView:RefreshExchange(isAdd)
	local level = self.viewCtr:GetPropValueByKey("EPC_Level")
	self:FindChild("Exchange/bg/VipBG/Text").text = level
	if isAdd then
		self.num = self.num + 1
	else
		self.num = self.num - 1
	end
	if self.num * 10000 > self.vipSpot then self.num = self.num -1 end
	if self.num > 50 then
		self.num = 50
		CC.ViewManager.ShowTip(self.language.tip_vipSpotMax)
	end
	if self.num < 0 then
		self.num = 0
	end
	if self.num == 0 then
		self:FindChild("Exchange/bg/SubBtn"):GetComponent("Button"):SetBtnEnable(false)
	else
		self:FindChild("Exchange/bg/SubBtn"):GetComponent("Button"):SetBtnEnable(true)
	end
	self:FindChild("Exchange/bg/TextBG/Text").text = self.num
	self:FindChild("Exchange/bg/BG/Spot").text = CC.uu.numberToStrWithComma(self.num * 10000)
	self.getChipCount = self.num * 15000 * self.viewCtr.vipNewRight[level+1].PointExchange.Count
	self:FindChild("Exchange/bg/BG/Chip").text = CC.uu.numberToStrWithComma(self.getChipCount)
end

function PersonalInfoView:CheckMonthCard(count)
	local card1 = CC.Player.Inst():GetSelfInfoByKey("EPC_Super") or 0 --小月卡
	local card2 = CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") or 0 --大月卡
	self:FindChild("Exchange/bg/MonthCard"):SetActive(card1 > 0 or card2 > 0)

	if card1 > 0 or card2 > 0 then
		self:FindChild("Exchange/bg/BG").y = 92
		self:FindChild("Exchange/bg/MonthCard/Card1"):SetActive(card1 > 0)
		self:FindChild("Exchange/bg/MonthCard/Card2"):SetActive(card2 > 0)
		self:FindChild("Exchange/bg/MonthCard/Card12"):SetActive(card1 > 0 and card2 > 0)
		local ratio = 0 
		if card1 > 0 then ratio = ratio + 0.1 end
		if card2 > 0 then ratio = ratio + 0.1 end
		local percent = ratio == 0 and "0" or (ratio == 0.1 and "10%" or "20%")
		self:FindChild("Exchange/bg/MonthCard/Text").text = string.format("%s <color=#28F553FF>+%s</color>",CC.uu.numberToStrWithComma(count),percent)
	else
		self:FindChild("Exchange/bg/BG").y = 60
	end
end

function PersonalInfoView:ResetExchange()
	self.num = 0
	self.getChipCount = 0
	self:FindChild("Exchange/bg/TextBG/Text").text = 0
	self:FindChild("Exchange/bg/BG/Spot").text = 0
	self:FindChild("Exchange/bg/BG/Chip").text = 0
	self:CheckMonthCard(0)
end

function PersonalInfoView:ShowExchangePanel(isShow)
	if isShow then
		--每次打开兑换界面，如果玩家有月卡重新拉取下月卡看是否到期失效
		if CC.Player.Inst():GetSelfInfoByKey("EPC_Super") > 0 or CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") > 0 then
			local data = {
				propIds = {CC.shared_enums_pb.EPC_Super,CC.shared_enums_pb.EPC_Supreme},
				succCb = function()
					self:CheckMonthCard(self.getChipCount)
				end
			}
			CC.HallUtil.ReqPlayerPropByIds(data)
		end

		self:SetCanClick(false)
		self:FindChild("Exchange/bg").transform.localScale = Vector3(0.5,0.5,1)
		self:FindChild("Exchange"):SetActive(true)
		self:RunAction(self:FindChild("Exchange/bg"), {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
				self:SetCanClick(true);
			end})
	else
		self:SetCanClick(false);
		self:RunAction(self:FindChild("Exchange/bg"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
			self:FindChild("Exchange"):SetActive(false)
			self:SetCanClick(true)
			end})
	end
end

function PersonalInfoView:OnClickDetermine()
--去解锁vip
	self.viewCtr:OnOpenDetermineView()
end

--改名
function PersonalInfoView:OnClickRename()
	self.viewCtr:OnClickRename()
end

--改生日
function PersonalInfoView:OnClickReBirthday()
	if self.isUploading then return end
	self.viewCtr:OnClickReBirthday()
end

--改性别
function PersonalInfoView:OnClickSex()
	self.viewCtr:OnClickSex()
end

--电话
function PersonalInfoView:OnClickTelephone()
	self.viewCtr:OnClickTelephone()
end

function PersonalInfoView:OnClickVIPRights()
--vip特权
	self.VIPToggle:GetComponent("Toggle").isOn = true;
end

function PersonalInfoView:OnClickBindFaceBook()
	self.viewCtr:OnBindFaceBook();
end

function PersonalInfoView:OnClickBindLine()
	self.viewCtr:OnBindLine();
end

function PersonalInfoView:OnClickPerfectInfo()
--完善信息
	self.viewCtr:OnBindPhone();
end

function PersonalInfoView:OnClickSafaBox()
	self.viewCtr:OnSafaBox();
end

function PersonalInfoView:ExchangePoint()
	self.viewCtr:VipPointChange()
	self:FindChild("Exchange"):SetActive(false)
	self:ResetExchange()
end

function PersonalInfoView:OnClickBackpack()
--背包
	self.viewCtr:OnBackpack()
end

--function PersonalInfoView:ShowIntegralTips()
	--self:FindChild("InfoPanel/Top/TotalIntegral/Tips"):SetActive(true)
	--self:StartTimer("ShowTips",3,function ()
		--self:FindChild("InfoPanel/Top/TotalIntegral/Tips"):SetActive(false)
	--end)
--end

function PersonalInfoView:VIPEquitiesRight()
--vip特权下一级
	self.viewCtr:OnChangeVIPEquities(true)
end

function PersonalInfoView:VIPEquitiesLeft()
--vip特权上一级
	self.viewCtr:OnChangeVIPEquities(false)
end

function PersonalInfoView:ReFreshVipRightsIcon(info, rightsType)
--设置权益图标
	local list = info.RightsIcon
	local level = info.VipLv
	local prefabsTab = nil
	local parent = nil
	if rightsType == self.viewCtr.RightsIconType.selfType then
		prefabsTab = self.selfInfoPrefabs
		parent = self.selfRightsParent
	elseif rightsType == self.viewCtr.RightsIconType.curType then
		prefabsTab = self.curIconPrefabs
		parent = self.curVipParent
	elseif rightsType == self.viewCtr.RightsIconType.nextType then
		prefabsTab = self.nextIconPrefabs
		parent = self.nextVipParent
	end
	if not prefabsTab then return end
	for _,v in pairs(prefabsTab) do
		v.transform:SetActive(false)
	end
	for i = 1, #list do
		local item = nil
		if prefabsTab[i] == nil then
			item = CC.uu.newObject(self.IconItem)
			item.transform.name = tostring(i)
			prefabsTab[i] = item.transform
		else
			item = prefabsTab[i]
		end
		if item then
			item:SetActive(true)
			item.transform:SetParent(parent, false)
			self:SetIconItemInfo(item, list[i], rightsType, level)
		end
	end
end

function PersonalInfoView:SetIconItemInfo(item, data, itemType, level)
	self:SetImage(item.transform:FindChild("Icon"), self.HallDefine.VIPNewRights[data.Icon].Icon);
	local count = data.Count
	if data.Icon == 10015 then
		--赠送税收
		count = count .. "%"
	elseif count <= 0 then
		count = ""
	elseif count >= 99999999999 then
		count = self.language.unlimited
	elseif count > 10000 then
		count = CC.uu.ChipFormat(data.Count)
	end
	item.transform:FindChild("Num"):GetComponent("Text").text = count
	item.transform:FindChild("Name"):GetComponent("Text").text = self.language.rightsIcon[data.Icon].name
	local newState = data.New
	local maxState = data.Max
	local upState = data.Up
	if itemType ~= self.viewCtr.RightsIconType.curType then
		item.transform:FindChild("New"):SetActive(newState)
		item.transform:FindChild("Max"):SetActive(maxState)
		item.transform:FindChild("Up"):SetActive(upState)
		if not CC.ViewManager.IsHallScene() then return end
		self:AddClick(item, function()
			-- if itemType == self.viewCtr.RightsIconType.selfType then
			-- 	item.transform:FindChild("New"):SetActive(false)
			-- 	item.transform:FindChild("Up"):SetActive(false)
			-- 	--本地缓存todo
			-- end
			if data.Icon == 10003 then
				CC.ViewManager.Open("UnLockVipView", {viewType = 2, showLevel = level});
			elseif data.Icon == 10005 then
				CC.ViewManager.Open("UnLockVipView", {viewType = 1, showLevel = level});
			end
		end)
	end
end

function PersonalInfoView:InitEquitiesPrefabs()
--初始化更多权益说明
	for i = 1, 9 do
		if self.curPrefabs[i] == nil then
			self.curPrefabs[i] = self:CreateEquitiesItem()
		end
		if self.nextPrefabs[i] == nil then
			self.nextPrefabs[i] = self:CreateEquitiesItem()
		end
	end
end

function PersonalInfoView:CreateEquitiesItem()
	local Item = nil
	Item = CC.uu.newObject(self.EquitiesItem)
	Item:SetActive(true)
	Item:FindChild("Cur"):SetActive(false)
	Item:FindChild("Next"):SetActive(false)
	Item.transform:SetParent(self.ScrollContent, false)
	return Item.transform
end

function PersonalInfoView:ReFreshEquities(info, showCur)
--设置权益相关说明
	info = self.viewCtr:SortEquities(info)
	for i = 1, 9 do
		local data = info[i]
		if data then
			local item = showCur and self.curPrefabs[i] or self.nextPrefabs[i]
			if item then
				item:SetActive(true)
				self:SetEquitiesInfo(item, data, showCur)
			end
		end
	end
	self:SetEquitiesScroll(true)
end

function PersonalInfoView:SetEquitiesInfo(item, data, showCur)
	local count = data.Count
	if count >= 99999999999 then
		count = self.language.unlimited
	elseif count > 10000 then
		CC.uu.ChipFormat(data.Count)
	end
	if showCur then
		item:FindChild("Cur"):SetActive(true)
		item:FindChild("Cur/BrightBg"):SetActive(data.UnLock)
		item:FindChild("Cur/BrightText"):SetActive(data.UnLock)
		item:FindChild("Cur/GrayBg"):SetActive(not data.UnLock)
		item:FindChild("Cur/GrayText"):SetActive(not data.UnLock)
		if data.UnLock then
			local colorStr = "<color=#E0A21E>" .. count .. "</color>"
			item:FindChild("Cur/BrightText"):GetComponent("Text").text = string.format(self.language[data.name], colorStr)
		else
			item:FindChild("Cur/GrayText"):GetComponent("Text").text = string.format(self.language[data.name], count)
		end
	else
		item:FindChild("Next"):SetActive(true)
		item:FindChild("Next/BrightBg"):SetActive(data.UnLock)
		item:FindChild("Next/BrightText"):SetActive(data.UnLock)
		item:FindChild("Next/GrayBg"):SetActive(not data.UnLock)
		item:FindChild("Next/GrayText"):SetActive(not data.UnLock)
		if data.UnLock then
			local colorStr = "<color=#FFFDD7>" .. count .. "</color>"
			item:FindChild("Next/BrightText"):GetComponent("Text").text = string.format(self.language[data.name], colorStr)
		else
			item:FindChild("Next/GrayText"):GetComponent("Text").text = string.format(self.language[data.name], count)
		end
		item:FindChild("Next/New"):SetActive(data.New)
		item:FindChild("Next/Max"):SetActive(data.Max)
		item:FindChild("Next/Up"):SetActive(data.Up)
	end
end

function PersonalInfoView:SetEquitiesScroll(isUp)
--权益滑动
	local value = isUp and 1 or 0
	local scaleY = isUp and 1 or -1
	self.scrollDirUp = isUp
	self.BtnBottom.localScale = Vector3(1, scaleY, 1)
	self.scrollRect:GetComponent("ScrollRect").verticalNormalizedPosition = value
end

function PersonalInfoView:ActionIn()
end

function PersonalInfoView:CloseView()
	if CC.LocalGameData.GetLocalDataToKey("VipRightsGift", CC.Player.Inst():GetSelfInfoByKey("Id")) and self.GiftToggle.activeSelf and not self:IsPortraitView() then
		self.GiftToggle:GetComponent("Toggle").isOn  = true
	else
		self:Destroy()
	end
end

function PersonalInfoView:OnDestroy()
	if self.rightsGiftView then
		self.rightsGiftView:Destroy()
	end
	if self.headIcon then
		self.headIcon:Destroy();
		self.headIcon = nil;
	end

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

function PersonalInfoView:GetSignInput()
	local inputField = self:FindChild("InfoPanel/Top/Signature/SignInputField"):GetComponent("InputField");
	return inputField.text;
end

function PersonalInfoView:GetNickInput()
	local inputField = self:FindChild("InfoPanel/Top/Nick/NickInputField"):GetComponent("InputField");
	return inputField.text;
end

function PersonalInfoView:GetDecodeBirth(str)
	if str == "" then return "" end
	local mon = string.sub(str,1,string.find(str,'/')-1)
	local tempStr = string.sub(str,string.find(str,'/')+1,-1)
	local day = string.sub(tempStr, 1,string.find(tempStr,'/')-1)
	local year = string.sub(tempStr,string.find(str,'/')+1,-1)
	return day.."/"..mon.."/"..year
end

function PersonalInfoView:ShowRightGiftPanel(isShow)
	if self.GiftToggle:GetComponent("Toggle").isOn then
		if not isShow then
			self.GiftPanel:SetActive(false)
			self.GiftToggle:SetActive(false)
			if CC.ViewManager.IsHallScene() then
				self.selfInfoToggle:GetComponent("Toggle").isOn = true
			else
				self:CloseView()
			end
		end
	else
		self.GiftToggle:SetActive(isShow)
	end
end

function PersonalInfoView:OpenStorePropShop()
	local storeDefine = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine")
	local param = {}
	param.channelTab = storeDefine.CommodityType.PropShop
	CC.ViewManager.OpenAndReplace("StoreView",param)
end

function PersonalInfoView:SetSafeBoxTip()
	self:FindChild("InfoPanel/Top/SafeBox/New"):SetActive(CC.Player.Inst():GetSafeCodeData().SafeStatus == 0)
end

return PersonalInfoView;