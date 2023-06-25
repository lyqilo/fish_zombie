
local CC = require("CC")

local TrailPersonalInfoView = CC.uu.ClassView("TrailPersonalInfoView")

function TrailPersonalInfoView:ctor(param)

	self:InitVar(param);
end

function TrailPersonalInfoView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function TrailPersonalInfoView:CreateViewCtr(...)
	local viewCtrClass = require("View/TrailView/"..self.viewName.."Ctr");
	return viewCtrClass.new(self, ...);
end

function TrailPersonalInfoView:InitVar(param)

	self.param = param;

	self.headIcon = nil;

	self.personalInfoDefine = CC.DefineCenter.Inst():getConfigDataByKey("PersonalInfoDefine");

	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
end

function TrailPersonalInfoView:InitContent(param)

	if param.infoType == self.personalInfoDefine.PersonalInfoMode.Self then
		local btnSelf = self:FindChild("Frame/BtnTab/Self");
		btnSelf:SetActive(true);

		local btnIntroduce = btnSelf:FindChild("BtnIntroduce");
		self:AddClick(btnIntroduce, "OnClickTabInfo");
		btnIntroduce:GetComponent("Toggle").isOn = true;

		local panel = self:FindChild("Frame/IntroducePanel/SelfInfo");
		panel:SetActive(true);
		

		local btnFaceBook = panel:FindChild("BottomPanel/BtnSizeFitter/BtnFaceBook");
		btnFaceBook:SetActive(param.showBtnFaceBook);
		if param.showBtnFaceBook then
			self:AddClick(btnFaceBook, "OnClickBindFaceBook");
		end

		local btnLine = panel:FindChild("BottomPanel/BtnSizeFitter/BtnLine");
		btnLine:SetActive(false);
		-- if param.showBtnLine then
		-- 	self:AddClick(btnLine, "OnClickBindLine");
		-- end

		local nickInput = panel:FindChild("TopPanel/LeftPanel/NickInputField");
		local nickPlaceholder = panel:FindChild("TopPanel/LeftPanel/NickInputField/Placeholder")
		UIEvent.AddInputFieldOnValueChange(nickInput, function(str)
				if str == "" then
					nickInput:GetComponent("InputField").text = self.viewCtr:GetNickName();
					CC.ViewManager.ShowTip(self.language.nickInputTip);
					return
				end
				nickInput:GetComponent("InputField").text = str;
			end);
		--屏蔽修改昵称和签名
		if param.unClickNickInputField then
			local nickInput = panel:FindChild("TopPanel/LeftPanel/NickInputField"):GetComponent("InputField");
			nickInput.enabled = false;
		end
		if param.unClickSignInputField then
			local signInput = panel:FindChild("TopPanel/RightPanel/Signature/SignInputField"):GetComponent("InputField");
			signInput.enabled = false;
		end

	else
		local BtnOther = self:FindChild("Frame/BtnTab/Other");
		BtnOther:SetActive(true);

		local panel = self:FindChild("Frame/IntroducePanel/OtherInfo");
		panel:SetActive(true);
		self:AddClick(panel:FindChild("BottomPanel/BtnDelete"), "OnClickDeleteFriend");
		self:AddClick(panel:FindChild("BottomPanel/BtnAddFriend/Select"), "OnClickAddFriend");


		local effectLeft = self:FindChild("Frame/EffectLeft");
		local pos = effectLeft.transform.localPosition;
		effectLeft.transform.localPosition = Vector3(-161, pos.y, pos.z);
		local effectRight = self:FindChild("Frame/EffectRight");
		local pos = effectRight.transform.localPosition;
		effectRight.transform.localPosition = Vector3(161, pos.y, pos.z);	
		local rightRibbon = self:FindChild("Frame/RightRibbon");
		local pos = rightRibbon.transform.localPosition;
		rightRibbon.transform.localPosition = Vector3(176, pos.y, pos.z);	
	end

	self:AddClick("Frame/BtnClose", "ActionOut");
	self:AddClick("Frame/ClickLayer", "ResetHeadIcon");

	self:InitTextByLanguage(param.infoType);
end

function TrailPersonalInfoView:InitTextByLanguage(infoType)
	
	local language = self.language;

	local btnTab = self:FindChild("Frame/BtnTab");
	local introduce = self:FindChild("Frame/IntroducePanel");
	
	if infoType == self.personalInfoDefine.PersonalInfoMode.Self then
		--Self
		--页签
		local tabIntroduce = btnTab:FindChild("Self/BtnIntroduce/Text");
		tabIntroduce.text = language.tabIntroduce;
		local tabIntroduceSelect = btnTab:FindChild("Self/BtnIntroduceSelect/Text");
		tabIntroduceSelect.text = language.tabIntroduce;

		local signature = introduce:FindChild("SelfInfo/TopPanel/RightPanel/Signature/Text");
		signature.text = language.signature;
		-- local totalChips = introduce:FindChild("SelfInfo/TopPanel/RightPanel/Item1/TotalChips/Des");
		-- totalChips.text = language.totalChips;
		local maxWinChips = introduce:FindChild("SelfInfo/TopPanel/RightPanel/Item2/Des");
		maxWinChips.text = language.maxWinChips;
		local totalWin = introduce:FindChild("SelfInfo/TopPanel/RightPanel/Item3/Des");
		totalWin.text = language.totalWin;
		introduce:FindChild("SelfInfo/TopPanel/LeftPanel/CurId/Id").text = language.idTitle;
		introduce:FindChild("SelfInfo/BottomPanel/BtnSizeFitter/BtnFaceBook/Text").text = language.btnFB;
	else
		--Other
		--页签
		local tabIntroduce = btnTab:FindChild("Other/BtnIntroduce/Text");
		tabIntroduce.text = language.tabIntroduce;
		--个人信息
		local taskTitle = introduce:FindChild("OtherInfo/TopPanel/CurTitle/Title");
		taskTitle.text = language.taskTitle;
		local signature = introduce:FindChild("OtherInfo/TopPanel/Signature/Text");
		signature.text = language.signature;
		local totalChips = introduce:FindChild("OtherInfo/MiddlePanel/Item1/Des");
		totalChips.text = language.totalChips;
		local maxWinChips = introduce:FindChild("OtherInfo/MiddlePanel/Item2/Des");
		maxWinChips.text = language.maxWinChips;
		local totalWin = introduce:FindChild("OtherInfo/MiddlePanel/Item3/Des");
		totalWin.text = language.totalWin;
		local btnDelete = introduce:FindChild("OtherInfo/BottomPanel/BtnDelete/Text");
		btnDelete.text = language.btnDelete;
		local btnAddFriend = introduce:FindChild("OtherInfo/BottomPanel/BtnAddFriend/Select/Text");
		btnAddFriend.text = language.btnAddFriend;
		local btnAdded = introduce:FindChild("OtherInfo/BottomPanel/BtnAddFriend/UnSelect/Text");
		btnAdded.text = language.btnSend;
		introduce:FindChild("OtherInfo/TopPanel/CurId/Id").text = language.idTitle;
	end
end

function TrailPersonalInfoView:CreateHeadIcon(panel, playerData, isSelf)
	local data = {};
	local path = isSelf and "TopPanel/LeftPanel/HeadNode" or "TopPanel/HeadNode";
	data.parent = panel:FindChild(path);
	data.playerId = playerData.id;
	data.clickFunc = "ScaleEffect";
	if isSelf then
		local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0;
		local unBindFacebook = bit.band(bindingFlag, CC.shared_enums_pb.EF_Binded) == 0;
		local unBindLine = bit.band(bindingFlag, CC.shared_enums_pb.EF_LineBinded) == 0;
		--没绑定过facebook或者Line则可以选择更换头像
		if unBindFacebook and unBindLine then 
			data.clickFunc = function()
				self.viewCtr:OnOpenHeadChoose();
			end
		end
	else
		data.nick = playerData.nick
		data.portrait = playerData.portrait
		data.vipLevel = playerData.curLevel
		data.showChat = true;
		data.chatCallback = function()
			self:Destroy();
		end
	end
	self.headIcon = CC.HeadManager.CreateHeadIcon(data);
end

function TrailPersonalInfoView:ResetHeadIcon()
	if self.headIcon then
		self.headIcon:ResetHeadScale();
	end
end

function TrailPersonalInfoView:OnClickTabProcess()

	self.viewCtr:ChangeToProcessPanel();
end

function TrailPersonalInfoView:OnClickTabInfo()

	self.viewCtr:ChangeToInfoPanel();
end

function TrailPersonalInfoView:RefreshUI(param)
	CC.uu.Log(param,"refresh:")
	if param.refreshIntroduce then
		self:RefreshIntroduce(param);
	end
end

function TrailPersonalInfoView:RefreshIntroduce(param)

	local panel = self:FindChild("Frame/IntroducePanel");
	panel:SetActive(true);
	if param.infoType == self.personalInfoDefine.PersonalInfoMode.Self then
		self:RefreshIntroduceSelfUI(param);
	else
		self:RefreshIntroduceOtherUI(param);
	end
end

function TrailPersonalInfoView:RefreshIntroduceSelfUI(param)

	local panel = self:FindChild("Frame/IntroducePanel/SelfInfo");
	--创建头像
	if param.createHeadId then
		self:CreateHeadIcon(panel, param, true);
	end
	--设置玩家名字
	if param.nick then
		-- self:SetText(panel:FindChild("TopPanel/LeftPanel/NickInputField/Placeholder"), param.nick);
		local inputField = panel:FindChild("TopPanel/LeftPanel/NickInputField"):GetComponent("InputField");
		inputField.text = param.nick;
	end

	--设置玩家id
	if param.id then
		self:SetText(panel:FindChild("TopPanel/LeftPanel/CurId/Text"), param.id);
		if param.curLevel >= 20 then
			panel:FindChild("TopPanel/LeftPanel/VIPId"):SetActive(true);
			self:SetText(panel:FindChild("TopPanel/LeftPanel/VIPId/Text"), param.id);
			panel:FindChild("TopPanel/LeftPanel/CurId"):SetActive(false);
		end
	end

	--设置玩家签名
	if param.personSign then
		-- self:SetText(panel:FindChild("TopPanel/RightPanel/Signature/SignInputField/Placeholder"), param.personSign);
		local inputField = panel:FindChild("TopPanel/RightPanel/Signature/SignInputField"):GetComponent("InputField");
		inputField.text = param.personSign;
	end

	--设置玩家当前筹码
	if param.curChips then
		self:SetText(panel:FindChild("TopPanel/RightPanel/Item1/TotalChips/Number"), param.curChips);
	end
	if param.curDiamond then
		self:SetText(panel:FindChild("TopPanel/RightPanel/Item1/TotalDiamond/Number"), param.curDiamond);
	end
	--设置玩家最高赢取
	if param.maxWin then
		self:SetText(panel:FindChild("TopPanel/RightPanel/Item2/Number"), param.maxWin);
	end
	--设置玩家总赢取
	if param.totalWin then
		self:SetText(panel:FindChild("TopPanel/RightPanel/Item3/Number"), param.totalWin);
	end

	if param.hideBtnBindFacebook then
		local btnBindFacebook = panel:FindChild("BottomPanel/BtnSizeFitter/BtnFaceBook");
		btnBindFacebook:SetActive(false);
	end

	-- if param.hideBtnBindLine then
	-- 	local btnBindLine = panel:FindChild("BottomPanel/BtnSizeFitter/BtnLine");
	-- 	btnBindLine:SetActive(false);
	-- end

	if param.showShieldLayer then
		local shieldLayer = self:FindChild("ShieldLayer");
		shieldLayer:SetActive(true);
	end
end

function TrailPersonalInfoView:RefreshIntroduceOtherUI(param)
	local panel = self:FindChild("Frame/IntroducePanel/OtherInfo");
	--创建头像
	if param.createHeadId then
		self:CreateHeadIcon(panel, param);
	end
	--设置玩家名字
	if param.nick then
		-- self:SetText(panel:FindChild("TopPanel/NickInputField/Placeholder"), param.nick);
		local inputField = panel:FindChild("TopPanel/NickInputField"):GetComponent("InputField");
		inputField.text = param.nick;
	end

	--设置玩家id
	if param.id then
		self:SetText(panel:FindChild("TopPanel/CurId/Text"), param.id);
		if param.curLevel >= 20 then
			panel:FindChild("TopPanel/VIPId"):SetActive(true);
			self:SetText(panel:FindChild("TopPanel/VIPId/Text"), param.id);
			panel:FindChild("TopPanel/CurId"):SetActive(false);
		end
	end

	--设置玩家头衔
	if param.titleDes then
		self:SetText(panel:FindChild("TopPanel/CurTitle/Text"), param.titleDes);
	end

	--设置玩家签名
	if param.personSign then
		-- self:SetText(panel:FindChild("TopPanel/Signature/SignInputField/Placeholder"), param.personSign);
		local inputField = panel:FindChild("TopPanel/Signature/SignInputField"):GetComponent("InputField");
		inputField.text = param.personSign;
	end

	--设置玩家当前筹码
	if param.curChips then
		self:SetText(panel:FindChild("MiddlePanel/Item1/Number"), param.curChips);
	end
	--设置玩家最高赢取
	if param.maxWin then
		self:SetText(panel:FindChild("MiddlePanel/Item2/Number"), param.maxWin);
	end
	--设置玩家总赢取
	if param.totalWin then
		self:SetText(panel:FindChild("MiddlePanel/Item3/Number"), param.totalWin);
	end

	--设置按钮状态
	if param.infoType then
		self:SetOtherInfoBtnShow(param.infoType);
	end

	--设置请求按钮显示
	if param.setAddFriendGray then
		local btnSelect = panel:FindChild("BottomPanel/BtnAddFriend/Select");
		btnSelect:SetActive(false);
		local btnUnSelect = panel:FindChild("BottomPanel/BtnAddFriend/UnSelect");
		btnUnSelect:SetActive(true);
	end
end

function TrailPersonalInfoView:SetOtherInfoBtnShow(infoType)

	local panel = self:FindChild("Frame/IntroducePanel/OtherInfo");
	local btnDelete = panel:FindChild("BottomPanel/BtnDelete");
	local btnAddFriend = panel:FindChild("BottomPanel/BtnAddFriend");

	if infoType == self.personalInfoDefine.PersonalInfoMode.Friend then
		btnDelete:SetActive(true);
		btnAddFriend:SetActive(false);
	elseif infoType == self.personalInfoDefine.PersonalInfoMode.Stranger then
		btnDelete:SetActive(false);
		btnAddFriend:SetActive(true);
	end
end

function TrailPersonalInfoView:OnClickBindFaceBook()

	self.viewCtr:OnBindFaceBook();
end

function TrailPersonalInfoView:OnClickBindLine()

	self.viewCtr:OnBindLine();
end

function TrailPersonalInfoView:OnClickDeleteFriend()

	self.viewCtr:OnDeleteFriend()
end

function TrailPersonalInfoView:OnClickAddFriend()

	self.viewCtr:OnAddFriend()
end

function TrailPersonalInfoView:OnDestroy()
	if self.headIcon then
		self.headIcon:Destroy();
		self.headIcon = nil;
	end

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

function TrailPersonalInfoView:GetSignInput()

	local panel = self:FindChild("Frame/IntroducePanel/SelfInfo");
	local inputField = panel:FindChild("TopPanel/RightPanel/Signature/SignInputField"):GetComponent("InputField");
	return inputField.text;
end

function TrailPersonalInfoView:GetNickInput()

	local panel = self:FindChild("Frame/IntroducePanel/SelfInfo");
	local inputField = panel:FindChild("TopPanel/LeftPanel/NickInputField"):GetComponent("InputField");
	return inputField.text;
end

function TrailPersonalInfoView:GetDecodeBirth(str)
	if str == "" then return "" end
	local mon = string.sub(str,1,string.find(str,'/')-1)
	local tempStr = string.sub(str,string.find(str,'/')+1,-1)
	local day = string.sub(tempStr, 1,string.find(tempStr,'/')-1)
	local year = string.sub(tempStr,string.find(str,'/')+1,-1)
	return day.."/"..mon.."/"..year
end

return TrailPersonalInfoView;