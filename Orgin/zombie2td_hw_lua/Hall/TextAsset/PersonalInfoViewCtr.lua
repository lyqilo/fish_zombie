local CC = require("CC")
local PersonalInfoViewCtr = CC.class2("PersonalInfoViewCtr")

--[[
@param
playerId
--]]
function PersonalInfoViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function PersonalInfoViewCtr:OnCreate()
	self:InitData();
	self:RegisterEvent();
	--获取玩家特许头像
	CC.Request("ReqGetPortraitList")
	--请求生日实名
	-- CC.Request("ReqGetBrithRealInfo",{PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")})
end

function PersonalInfoViewCtr:InitVar(view, param)
	self.param = param or {};
	self.param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
	--打开头像时有传当前筹码数量，以传的数值为准
	self.param.curChips = self.param and self.param.curChips or nil
	--UI对象
	self.view = view;
	--玩家信息数据
	self.playerData = nil;
	--是否已初始化个人信息页签
	self.initIntroduce = nil;
	--VIP等级配置
	self.levelCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Level");
	--道具配置
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");
	self.vipNewRight = CC.ConfigCenter.Inst():getConfigDataByKey("VIPNewRights")
	self.language = self.view:GetLanguage();
	--第三方账号绑定中
	self.accountBinding = false;
	--显示vip特权等级
	self.nextVIPEquitiesLevel = nil
	--权益相关 1:个人信息当前，2:权益当前，3:权益下级
	self.RightsIconType = {selfType = 1, curType = 2, nextType = 3}
	self.EquitiesField = {"UpGradeAward", "GiveLimit", "GiveTax", "PointExchange", "LotteryMarkup", "MinGive", "GiveTime", "Relief",  "CardCount"}
	self.copies = 0
	self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
	--特殊头像
	self.SpecialHeadIcon = {}
end

function PersonalInfoViewCtr:InitData()
	self.playerData = CC.Player.Inst():GetSelfInfo();
	local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0;
	local data = {}
	--任意绑定过facebook或者line账号的用户都不显示第三方绑定按钮
	local anyBinded = bit.band(bindingFlag, CC.shared_enums_pb.EF_Binded) == 0 and bit.band(bindingFlag, CC.shared_enums_pb.EF_LineBinded) == 0;
	data.showBtnFaceBook = CC.ViewManager.IsHallScene() and anyBinded;
	data.showBtnLine = CC.ViewManager.IsHallScene() and anyBinded;
	data.unClickNickInputField = not CC.ViewManager.IsHallScene() or not data.showBtnFaceBook;	--屏蔽昵称修改输入
	self.view:InitContent(data);
	self:ChangeToInfoPanel();
	CC.HallUtil.OnShowHallCamera(false);
end

function PersonalInfoViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RefreshSelfInfo,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self, self.OnChangeNick,CC.Notifications.ChangeNick)
	CC.HallNotificationCenter.inst():register(self, self.OnBindFaceBookRsp, CC.Notifications.NW_BindFacebook)
	CC.HallNotificationCenter.inst():register(self, self.OnBindLineRsp, CC.Notifications.NW_BindLine)
	CC.HallNotificationCenter.inst():register(self, self.VipPointChangeRsp, CC.Notifications.NW_VipPointChange)
	CC.HallNotificationCenter.inst():register(self, self.ShowRightGiftPanel, CC.Notifications.ShowRightGift)
	CC.HallNotificationCenter.inst():register(self, self.OnChangeBirth,CC.Notifications.ChangeBirth)
	CC.HallNotificationCenter.inst():register(self, self.OnChangeTelephone,CC.Notifications.ChangeTelephone)
	CC.HallNotificationCenter.inst():register(self, self.OnSetSafePassWordSucc,CC.Notifications.SetSafePassWordSucc)
	CC.HallNotificationCenter.inst():register(self, self.OnChangeSex,CC.Notifications.ChangeSex)
	CC.HallNotificationCenter.inst():register(self, self.OnGetPortraitListResp,CC.Notifications.NW_ReqGetPortraitList)
	CC.HallNotificationCenter.inst():register(self, self.OnGetBrithRealResp,CC.Notifications.NW_ReqGetBrithRealInfo)
	CC.HallNotificationCenter.inst():register(self, self.OnBirthUploadImage, CC.Notifications.OnBirthUploadImage)

end

function PersonalInfoViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function PersonalInfoViewCtr:OnBirthUploadImage(type)
	self.view:ShowBrithRealUI(type)
end

function PersonalInfoViewCtr:ChangeToInfoPanel()
	if not self.initIntroduce then
		self.initIntroduce = true;
		local data = self:GetIntroduceData();
		self.view:RefreshSelfInfoUI(data);
		self.view:RefreshVipPoint()
	end
end

function PersonalInfoViewCtr:Destroy()

	CC.HallUtil.OnShowHallCamera(true);
	--关闭界面保存昵称信息和个人签名
	local nick = self.view:GetNickInput();
	local sign = self.view:GetSignInput();
	local data = {};
	if nick ~= CC.Player.Inst():GetSelfInfoByKey("Nick") then
		nick = string.trim(nick, " ");
		if nick ~= "" then
		    if string.byte(nick) == 0 then
		        BuglyUtil.ReportException("ReqSavePlayer:", "string.byte(nick) = 0", "string.byte(nick) = 0");
		    end
			data.Nick = nick;
		end
	end

	if sign ~= CC.Player.Inst():GetSelfInfoByKey("PersonSign") then
		data.PersonSign = sign;
	end

	if not table.isEmpty(data) then
		CC.Request("ReqSavePlayer",data, function(err, result)
			local selfInfo = CC.Player.Inst():GetSelfInfo();
			if data.Nick then
				selfInfo.Data.Player.Nick = data.Nick;
				CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeNick);
			end
			if data.PersonSign then
				selfInfo.Data.Player.PersonSign = data.PersonSign;
			end
		end);
	end
	self:UnRegisterEvent();
end

function PersonalInfoViewCtr:RefreshSelfInfo()
	local data = {}
	data.curChips = CC.uu.ChipFormat(self:GetPropValueByKey("EPC_ChouMa"));
	data.curDiamond = CC.uu.DiamondFortmat(self:GetPropValueByKey("EPC_ZuanShi"));
	data.curIntegral = CC.uu.DiamondFortmat(self:GetPropValueByKey("EPC_New_GiftVoucher"));
	data.curLevel = self:GetPropValueByKey("EPC_Level");
	self.view:RefreshSelfInfoUI(data);
	self.view:RefreshVipPoint()
end

function PersonalInfoViewCtr:GetIntroduceData()
	if not self.playerData then return end
	--组装刷新界面需要使用的数据
	local playerData = self.playerData.Data.Player;
	local data = {};
	data.createHeadId = playerData.Id
	data.nick = playerData.Nick;
	data.id = playerData.Id;
	data.portrait = playerData.Portrait;
	data.personSign = playerData.PersonSign;
	data.sex = playerData.Sex
	data.birth = playerData.Birth
	data.telephone = playerData.Telephone
	if self.param.curChips then
		data.curChips = CC.uu.ChipFormat(self.param.curChips)
	else
		data.curChips = CC.uu.ChipFormat(self:GetPropValueByKey("EPC_ChouMa"));
	end
	data.curDiamond = CC.uu.DiamondFortmat(self:GetPropValueByKey("EPC_ZuanShi"));
	data.curIntegral = CC.uu.DiamondFortmat(self:GetPropValueByKey("EPC_New_GiftVoucher"));
	data.maxWin = CC.uu.ChipFormat(self:GetPropValueByKey("EPC_MaxSingleWin"));
	data.totalWin = CC.uu.ChipFormat(self:GetPropValueByKey("EPC_TotalWin"));
	data.curLevel = self:GetPropValueByKey("EPC_Level");
	data.curRightsInfo = self:GetNewRightsInfo(data.curLevel)
	data.nextLevel = self:GetNextLevel(data.curLevel)
	if data.nextLevel then
		data.nextLvlNeedExp,data.expProgress = self:GetNextLvlNeedExpAndProgress(data.curLevel, data.curLevel);
		self.nextVIPEquitiesLevel = data.nextLevel
		data.nextRightsInfo = self:GetNewRightsInfo(data.nextLevel)
		data.nextLvlRecharge = self:GetNextLvlNeedExpAndProgress(data.curLevel, self.nextVIPEquitiesLevel - 1)
	end
	return data;
end

function PersonalInfoViewCtr:GetSexValue(value)
	local sex = self.language.male
	if value == CC.shared_enums_pb.S_Female then
		sex = self.language.female
	end
	return sex
end

function PersonalInfoViewCtr:GetNextLevel(curLevel)
	local levelCfg = self.levelCfg[curLevel+1];
	if levelCfg then
		return curLevel+1;
	end
	return false;
end

function PersonalInfoViewCtr:GetNextLvlNeedExpAndProgress(curLevel, nextLevel)
	local totalCurExp = self:GetPropValueByKey("EPC_Experience");
	local totalNextExp = 0;
	for i = 0, nextLevel do
		totalNextExp = totalNextExp + self:GetExperience(i);
		if i <= curLevel - 1 then
			totalCurExp = totalCurExp + self:GetExperience(i);
		end
	end

	local progress = totalCurExp/totalNextExp;
	return CC.uu.ChipFormat(math.floor((totalNextExp-totalCurExp)/1000000)), progress;
end

function PersonalInfoViewCtr:GetExperience(level)
	local level = tonumber(level);
	if self.levelCfg[level] then
		return self.levelCfg[level].Experience;
	end
	logError("PersonalInfoViewCtr:has no config of level"..tostring(level));
end

function PersonalInfoViewCtr:GetNickName()
	local playerData = self.playerData.Data.Player;
	if playerData.Nick == "" then
		return "Name"
	end
	return playerData.Nick;
end

function PersonalInfoViewCtr:GetPropValueByKey(key)
	local propId = CC.shared_enums_pb[key]
	if not propId then
		logError("PersonalInfoViewCtr:shared_enums_pb has no enum value of "..tostring(key))
		return
	end
	local propsData = self.playerData.Data.Props;
	for _,v in ipairs(propsData) do
		if v.ConfigId == propId then
			return v.Count
		end
	end
	logError("PersonalInfoViewCtr:has no this propId-"..tostring(propId))
end

function PersonalInfoViewCtr:OnOpenDetermineView()
	local level = self:GetPropValueByKey("EPC_Level")
	if level < 3 then
		if level < 1 and CC.Player.Inst():GetFirstGiftState() then
			--首冲礼包
			CC.ViewManager.Open("FirstBuyGiftView")
		elseif CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
			--新手礼包
			CC.ViewManager.OpenAndReplace("SelectGiftCollectionView", {SelectGiftTab = {"NoviceGiftView"}})
		else
			--vip3直升卡
			CC.ViewManager.Open("VipThreeCardView")
		end
	else
		CC.ViewManager.OpenAndReplace("StoreView")
	end
end

function PersonalInfoViewCtr:OnClickRename(param)
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Mod_Name_Card") > 0 then
		local param = {}
		param.consumeProp = CC.shared_enums_pb.EPC_Mod_Name_Card
		CC.ViewManager.Open("RenameView",param)
	elseif CC.Player.Inst():GetSelfInfoByKey("EPC_ModifyNicknameCard") > 0 then
		local param = {}
		param.consumeProp = CC.shared_enums_pb.EPC_ModifyNicknameCard
		CC.ViewManager.Open("RenameView",param)
	else
		CC.ViewManager.ShowTip(self.view.language.needRenameCard)
		self.view:OpenStorePropShop()
	end
end

function PersonalInfoViewCtr:OnClickReBirthday()
	CC.ViewManager.Open("ReBirthdayView")
end

function PersonalInfoViewCtr:OnClickSex()
	CC.ViewManager.Open("SetSexView")
end

function PersonalInfoViewCtr:OnClickTelephone()
	local playerData = self.playerData.Data.Player
	local telephone = playerData.Telephone or ""
	if telephone == "" then
		if not self.switchDataMgr.GetSwitchStateByKey("OTPVerify") then
			CC.ViewManager.ShowTip(self.view.language.otpClose)
		else
			CC.ViewManager.Open("BindTelView")
		end
	else
		--在子游戏不进行下列操作
		if not CC.ViewManager.IsHallScene() then
			return
		end
		if CC.Player.Inst():GetSelfInfoByKey("EPC_UnbindTelCard") > 0 then
			--解绑手机
			CC.HallUtil.UnBindTelephone()
		else
			CC.ViewManager.ShowTip(self.view.language.needUnbindTelCard)
			self.view:OpenStorePropShop()
		end
	end
end

function PersonalInfoViewCtr:OnBindFaceBook()
	CC.HallUtil.BlindFacebook()
end

function PersonalInfoViewCtr:OnBindFaceBookRsp(err, result)
	if err == 0 then
		--facebook绑定成功
		local param = {};
		param.hideBtnBindFacebook = true;
		param.hideBtnBindLine = true;
		param.showShieldLayer = true;
		self.view:RefreshSelfInfoUI(param);
	end
end

function PersonalInfoViewCtr:OnBindLine()
	CC.HallUtil.BindLine()
end

function PersonalInfoViewCtr:OnBindLineRsp(err, data)
	if err == 0 then
		--line绑定成功
		local param = {};
		param.hideBtnBindFacebook = true;
		param.hideBtnBindLine = true;
		param.showShieldLayer = true;
		self.view:RefreshSelfInfoUI(param);
	end
end

function PersonalInfoViewCtr:OnBindPhone()
	local data = {};
	data.callback = function(info)
		local param = {};
		param.hideBtnBindPhone = true;
		param.birth = info.Birth
		param.sex = info.Sex
		self.view:RefreshSelfInfoUI(param);
	end
	--CC.ViewManager.Open("PersonalBindPhoneView", data);
end

function PersonalInfoViewCtr:OnBackpack()
	CC.ViewManager.OpenAndReplace("BackpackView");
end

function PersonalInfoViewCtr:OnOpenHeadChoose()
	if not CC.ViewManager.IsHallScene() then
		return;
	end
	-- local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0;
	-- local unBindFacebook = bit.band(bindingFlag, CC.shared_enums_pb.EF_Binded) == 0;
	-- local unBindLine = bit.band(bindingFlag, CC.shared_enums_pb.EF_LineBinded) == 0;

	local data = {};
	-- data.showHeadIcon = unBindFacebook and unBindLine;
	if not table.isEmpty(self.SpecialHeadIcon) then
		data.specialHeadList = self.SpecialHeadIcon
	end
	CC.ViewManager.Open("PersonalHeadChooseView", data);
	-- self.view:Destroy();
end

function PersonalInfoViewCtr:OnChangeNick()
	local playerData = self.playerData.Data.Player;
	local data = {};
	data.nick = playerData.Nick;
	self.view:RefreshSelfInfoUI(data);
end

function PersonalInfoViewCtr:OnChangeBirth()
	local playerData = self.playerData.Data.Player;
	local data = {};
	data.birth = playerData.Birth;
	self.view:RefreshSelfInfoUI(data);
end

function PersonalInfoViewCtr:OnChangeTelephone()
	local playerData = self.playerData.Data.Player;
	local data = {};
	data.telephone = playerData.Telephone;
	self.view:RefreshSelfInfoUI(data);
end

function PersonalInfoViewCtr:OnChangeSex()
	local playerData = self.playerData.Data.Player;
	local data = {};
	data.sex = playerData.Sex;
	self.view:RefreshSelfInfoUI(data);
end

function PersonalInfoViewCtr:VipPointChange()
	self.copies = self.view.num or 0
	if self.copies <= 0 then return end
	CC.Request("VipPointChange",{Copies = self.copies})
end

function PersonalInfoViewCtr:VipPointChangeRsp(err, data)
	log(CC.uu.Dump(data, "VipPointChangeRsp"))
	if err == 0 then
		local level = self:GetPropValueByKey("EPC_Level")
		local card1 = CC.Player.Inst():GetSelfInfoByKey("EPC_Super") or 0 --小月卡
		local card2 = CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") or 0 --大月卡
		local ratio = 0
		if card1 > 0 then ratio = ratio + 0.1 end
		if card2 > 0 then ratio = ratio + 0.1 end
		local count = self.copies * 15000 * self.vipNewRight[level+1].PointExchange.Count
		count = count + count *ratio
		local param = {}
		param[1] =
		{
			ConfigId = 2,
			Count = count
		}
		CC.ViewManager.OpenRewardsView({items = param})
		self.copies = 0
	end
end

function PersonalInfoViewCtr:OnChangeVIPEquities(isRight)
	local curLevel = self:GetPropValueByKey("EPC_Level")
	if self.nextVIPEquitiesLevel then
		if isRight then
			self.nextVIPEquitiesLevel = self:GetNextLevel(self.nextVIPEquitiesLevel)
		else
			self.nextVIPEquitiesLevel = self.nextVIPEquitiesLevel - 1
			if self.nextVIPEquitiesLevel <= curLevel then
				self.nextVIPEquitiesLevel = #self.levelCfg
			end
		end
	end
	if not self.nextVIPEquitiesLevel then
		self.nextVIPEquitiesLevel = self:GetNextLevel(curLevel)
	end
	local data = {}
	data.nextRightsInfo = self:GetNewRightsInfo(self.nextVIPEquitiesLevel)
	data.nextLvlRecharge = self:GetNextLvlNeedExpAndProgress(curLevel, self.nextVIPEquitiesLevel - 1)
	self.view:RefreshSelfInfoUI(data)
end

--vip权益配置信息
function PersonalInfoViewCtr:GetNewRightsInfo(level)
	local viplevel = tonumber(level);
	if self.vipNewRight[viplevel + 1] then
		return self.vipNewRight[viplevel + 1]
	end
	return false
end

--权益说明排序
function PersonalInfoViewCtr:SortEquities(info)
	local list = {}
	local unlockList = {}
	local notList = {}
	for	i = 1, 9 do
		local data = info[self.EquitiesField[i]]
		data.name = self.EquitiesField[i]
		if data.name == "GiveLimit" and info.VipLv <= 2 then
			data.name = "GiveLimitLow"
		end
		if data.UnLock then
			table.insert(unlockList, data)
		else
			table.insert(notList, data)
		end
	end
	for i = 1, #unlockList do
		table.insert(list, unlockList[i])
	end
	for i = 1, #notList do
		table.insert(list, notList[i])
	end
	return list
end

function PersonalInfoViewCtr:ShowRightGiftPanel(isShow)
	self.view:ShowRightGiftPanel(isShow)
end

function PersonalInfoViewCtr:CheckOtherView()
	if not CC.ViewManager.IsHallScene() then return end
	if CC.DataMgrCenter.Inst():GetDataByKey("Game").GetGuide().state then return end

	--保险箱引导界面
	if not CC.Player.Inst():GetSafeCodeData().GuideStatus and self.view.selfInfoToggle.activeSelf then
		CC.ViewManager.Open("SafeBoxGuideView")
	    return
	end

	--安全提示界面
	if not CC.LocalGameData.GetDailyStateByKey("SafetyFactor") then
		if CC.HallUtil.CheckSafetyFactor() then
			CC.LocalGameData.SetDailyStateByKey("SafetyFactor", true)
		end
	end
end

function PersonalInfoViewCtr:OnSafaBox()
	--游戏内点击保险箱无反应 
	if not CC.ViewManager.IsHallScene() then
		return
	end

	if self.switchDataMgr.GetSwitchStateByKey("OTPVerify") then
		if not CC.HallUtil.CheckTelBinded() then
			CC.ViewManager.Open("BindTelView")
			return
		end
	end

	if CC.HallUtil.CheckSafePassWord() then
		CC.ViewManager.Open("SafeBoxView")
	end
end

function PersonalInfoViewCtr:OnSetSafePassWordSucc(password)
	self.view:SetSafeBoxTip()
end

function PersonalInfoViewCtr:OnGetPortraitListResp(err, data)
	log(CC.uu.Dump(data, "OnGetPortraitListResp:"))
	if err == 0 then
		for _,v in ipairs(data.PortraitId) do
			table.insert(self.SpecialHeadIcon, v)
		end
	end
end

function PersonalInfoViewCtr:OnGetBrithRealResp(err, data)
	CC.uu.Log(data,"OnGetBrithRealResp:")
	if err == 0 then
		self.view:ShowBrithRealUI(data.BirthAuth)
	end
end

return PersonalInfoViewCtr;