local CC = require("CC")
local OtherPlayerInfoView = CC.uu.ClassView("OtherPlayerInfoView")

function OtherPlayerInfoView:ctor(param)
	self:InitVar(param);
end

function OtherPlayerInfoView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitContent();
	self:InitTextByLanguage();
end

function OtherPlayerInfoView:InitVar(param)
	self.param = param;
	self.headIcon = nil;
	self.personalInfoDefine = CC.DefineCenter.Inst():getConfigDataByKey("PersonalInfoDefine");

	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
end

function OtherPlayerInfoView:InitContent()
	self:AddClick("Frame/BtnClose", "ActionOut");
	self:FindChild("Frame/TopPanel/CurVip"):SetActive(not CC.ChannelMgr.GetTrailStatus());
end

function OtherPlayerInfoView:RefreshContent(param)
	self:AddClick(self:FindChild("Frame/BottomPanel/BtnDelete"), "OnClickDeleteFriend");
	self:AddClick(self:FindChild("Frame/BottomPanel/BtnGiving"), "OnClickGivingFriend");
	self:AddClick(self:FindChild("Frame/BottomPanel/BtnAddFriend/Select"), "OnClickAddFriend");
	--暂时屏蔽禁言功能
	-- local showOn = true;
	-- self:AddClick(self:FindChild("BottomPanel/BtnBanSpeak"), function()
	-- 		showOn = not showOn;
	-- 		self:OnClickBanSpeak(showOn);
	-- 	end);
	--游戏内不显示赠送按钮
	local btnGiving = self:FindChild("Frame/BottomPanel/BtnGiving");
	if not CC.ChannelMgr.GetTrailStatus() then
		btnGiving:SetActive(CC.ViewManager.IsHallScene());
	else
		btnGiving:SetActive(false);
	end
	self:SetOtherInfoBtnShow(param.infoType);

	-- self:AddClick("Frame/BtnClose", "ActionOut");
	self:AddClick("Frame/ClickLayer", "ResetHeadIcon");

end

function OtherPlayerInfoView:InitTextByLanguage()
	--页签
	self:FindChild("Frame/Title/Text").text = self.language.tabIntroduce;
		--个人信息
	self:FindChild("Frame/TopPanel/CurId/Id").text = self.language.idTitle;
	self:FindChild("Frame/TopPanel/Signature/Text").text = self.language.signature;
	self:FindChild("Frame/TopPanel/Sex/Title").text = self.language.sex;
	self:FindChild("Frame/MiddlePanel/Item1/Des").text = self.language.totalChips;
	self:FindChild("Frame/MiddlePanel/Item2/Des").text = self.language.maxWinChips;
	self:FindChild("Frame/MiddlePanel/Item3/Des").text = self.language.totalWin;
	self:FindChild("Frame/BottomPanel/BtnDelete/Text").text = self.language.btnDelete;
	self:FindChild("Frame/BottomPanel/BtnGiving/Text").text = self.language.btnGiving;
	self:FindChild("Frame/BottomPanel/BtnAddFriend/Select/Text").text = self.language.btnAddFriend;
	self:FindChild("Frame/BottomPanel/BtnAddFriend/UnSelect/Text").text = self.language.btnSend;
end

function OtherPlayerInfoView:CreateHeadIcon(playerData)
	local data = {};
	data.parent = self:FindChild("Frame/TopPanel/HeadNode")
	data.playerId = playerData.id;
	data.clickFunc = "ScaleEffect";
	data.showFrameEffect = true;
	data.nick = playerData.nick
	data.portrait = playerData.portrait
	data.vipLevel = playerData.curLevel
	data.headFrame = playerData.Background
	data.showChat = true;
	data.chatCallback = function()
		self:Destroy();
	end
	self.headIcon = CC.HeadManager.CreateHeadIcon(data);
end

function OtherPlayerInfoView:ResetHeadIcon()
	if self.headIcon then
		self.headIcon:ResetHeadScale();
	end
end

function OtherPlayerInfoView:RefreshIntroduceOtherUI(param)
	CC.uu.Log(param,"refresh:")
	--创建头像
	if param.createHeadId then
		self:CreateHeadIcon(param);
	end
	--设置玩家名字
	if param.nick then
		self:FindChild("Frame/TopPanel/NickInputField"):GetComponent("InputField").text = param.nick;
	end
	--设置玩家id
	if param.id then
		self:SetText(self:FindChild("Frame/TopPanel/CurId/Text"), param.id);
		if param.curLevel >= 20 then
			self:FindChild("Frame/TopPanel/VIPId"):SetActive(true);
			self:SetText(self:FindChild("Frame/TopPanel/VIPId/Text"), param.id);
			self:FindChild("Frame/TopPanel/CurId"):SetActive(false);
		end
	end
	--设置玩家签名
	if param.personSign then
		self:FindChild("Frame/TopPanel/Signature/SignInputField"):GetComponent("InputField").text = param.personSign
	end
	--设置玩家当前筹码
	if param.curChips then
		self:SetText(self:FindChild("Frame/MiddlePanel/Item1/Number"), param.curChips);
	end
	--设置玩家最高赢取
	if param.maxWin then
		self:SetText(self:FindChild("Frame/MiddlePanel/Item2/Number"), param.maxWin);
	end
	--设置玩家总赢取
	if param.totalWin then
		self:SetText(self:FindChild("Frame/MiddlePanel/Item3/Number"), param.totalWin);
	end
	--设置当前vip等级
	if param.curLevel then
		self:SetText(self:FindChild("Frame/TopPanel/CurVip/VipIcon/Text"), param.curLevel);
	end
	-- 设置性别
	if param.sex then
		self:SetText(self:FindChild("Frame/TopPanel/Sex/Text"), param.sex);
	end

	--设置按钮状态
	if param.infoType then
		self:SetOtherInfoBtnShow(param.infoType);
	end
	--设置禁言状态
	if param.banSpeak ~= nil then
		local on = self:FindChild("Frame/BottomPanel/BtnBanSpeak/On");
		on:SetActive(param.banSpeak);
		local off = self:FindChild("Frame/BottomPanel/BtnBanSpeak/Off");
		off:SetActive(not param.banSpeak);
	end

	--设置请求按钮显示
	if param.setAddFriendGray then
		local btnSelect = self:FindChild("Frame/BottomPanel/BtnAddFriend/Select");
		btnSelect:SetActive(false);
		local btnUnSelect = self:FindChild("Frame/BottomPanel/BtnAddFriend/UnSelect");
		btnUnSelect:SetActive(true);
	end
end

function OtherPlayerInfoView:SetOtherInfoBtnShow(infoType)
	local btnDelete = self:FindChild("Frame/BottomPanel/BtnDelete");
	local btnAddFriend = self:FindChild("Frame/BottomPanel/BtnAddFriend");
	if infoType == self.personalInfoDefine.PersonalInfoMode.Friend then
		btnDelete:SetActive(true);
		btnAddFriend:SetActive(false);
	elseif infoType == self.personalInfoDefine.PersonalInfoMode.Stranger then
		btnDelete:SetActive(false);
		btnAddFriend:SetActive(true);
	end
end

function OtherPlayerInfoView:OnClickDeleteFriend()
--删除好友
	self.viewCtr:OnDeleteFriend()
end

function OtherPlayerInfoView:OnClickGivingFriend()
--赠送
	if self:HasBindPhone() then
		self.viewCtr:OnGivingFriend()
	else
		self:ShowBeforeSendTips()
	end
	self:Destroy()
end

function OtherPlayerInfoView:ShowBeforeSendTips()
	CC.ViewManager.Open("BeforeSendTipsView",{HasBindPhone = CC.HallUtil.CheckTelBinded()})
end

function OtherPlayerInfoView:HasBindPhone()
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify") then
		return true
	else
		return CC.HallUtil.CheckTelBinded()
	end
end

function OtherPlayerInfoView:OnClickAddFriend()
--添加好友
	self.viewCtr:OnAddFriend()
end

function OtherPlayerInfoView:OnClickBanSpeak()
--禁言
	self.viewCtr:OnBanSpeak()
end

function OtherPlayerInfoView:OnDestroy()
	if self.headIcon then
		self.headIcon:Destroy();
		self.headIcon = nil;
	end

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return OtherPlayerInfoView;