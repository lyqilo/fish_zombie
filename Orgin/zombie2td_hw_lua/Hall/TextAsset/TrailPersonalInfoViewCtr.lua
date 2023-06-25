
local CC = require("CC")

local TrailPersonalInfoViewCtr = CC.class2("TrailPersonalInfoViewCtr")

--[[
@param
playerId
--]]
function TrailPersonalInfoViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function TrailPersonalInfoViewCtr:OnCreate()
	self:InitData();

	self:RegisterEvent();
end

function TrailPersonalInfoViewCtr:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self, self.OnLoadPlayerWithPropTypeRsp, CC.Notifications.NW_ReqLoadPlayerWithPropType)

	CC.HallNotificationCenter.inst():register(self, self.OnBindFaceBookRsp, CC.Notifications.NW_BindFacebook)

	CC.HallNotificationCenter.inst():register(self, self.OnBindLineRsp, CC.Notifications.NW_BindLine)

	CC.HallNotificationCenter.inst():register(self, self.OnDeleteFriendRsp, CC.Notifications.NW_ReqDelFriend)

end

function TrailPersonalInfoViewCtr:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqLoadPlayerWithPropType)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_BindFacebook)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_BindLine)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqDelFriend)

end

function TrailPersonalInfoViewCtr:Destroy()
	--关闭界面保存昵称信息和个人签名
	if self.infoType == self.personalInfoDefine.PersonalInfoMode.Self then
		local nick = self.view:GetNickInput();
		local sign = self.view:GetSignInput();

		local data = {};
		if nick ~= CC.Player.Inst():GetSelfInfoByKey("Nick") then
			nick = string.trim(nick, " ");
			if nick ~= "" then
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
	end

	self:UnRegisterEvent();
end

function TrailPersonalInfoViewCtr:InitVar(view, param)

	self.param = param or {};

	self.param.playerId = self.param and self.param.playerId or CC.Player.Inst():GetSelfInfoByKey("Id");

	--打开头像时有传当前筹码数量，以传的数值为准
	self.param.curChips = self.param and self.param.curChips or nil
	--UI对象
	self.view = view;
	--个人信息类型(自己，好友，陌生人)
	self.infoType = nil;
	--玩家信息数据
	self.playerData = nil;
	--是否已初始化个人信息页签
	self.initIntroduce = nil;
	--是否已初始化头衔任务页签
	self.initProcess = nil;
	--VIP等级配置
	self.levelCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Level");
	--道具配置
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");
	--头衔任务配置
	self.taskCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Task");
	--个人信息字段定义
	self.personalInfoDefine = CC.DefineCenter.Inst():getConfigDataByKey("PersonalInfoDefine");

	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend");

	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView")
	--第三方账号绑定中
	self.accountBinding = false;
end

function TrailPersonalInfoViewCtr:InitData()
	if self.param.playerId == CC.Player.Inst():GetSelfInfoByKey("Id") then
		--如果是自己，获取本地数据直接刷新界面
		self.infoType = self.personalInfoDefine.PersonalInfoMode.Self;
		self.playerData = CC.Player.Inst():GetSelfInfo();
		local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0;
		local data = {}
		data.infoType = self.infoType;
		--任意绑定过facebook或者line账号的用户都不显示第三方绑定按钮
		local anyBinded = bit.band(bindingFlag, CC.shared_enums_pb.EF_Binded) == 0 and bit.band(bindingFlag, CC.shared_enums_pb.EF_LineBinded) == 0;
		data.showBtnFaceBook = CC.ViewManager.IsHallScene() and anyBinded;
		data.showBtnLine = CC.ViewManager.IsHallScene() and anyBinded;
		data.unClickNickInputField = not CC.ViewManager.IsHallScene() or not data.showBtnFaceBook;	--屏蔽昵称修改输入
		data.unClickSignInputField = not CC.ViewManager.IsHallScene();	--屏蔽签名修改输入
		self.view:InitContent(data);
		self:ChangeToInfoPanel();
	else
		--如果是好友或者陌生人则向服务器请求数据
		if self.friendDataMgr.IsFriend(self.param.playerId) then
			self.infoType = self.personalInfoDefine.PersonalInfoMode.Friend;
		else
			self.infoType = self.personalInfoDefine.PersonalInfoMode.Stranger;
		end
		self:ReuestOtherInfoData();
	end
end

function TrailPersonalInfoViewCtr:ReuestOtherInfoData()

	local param = {
		playerId = self.param.playerId,
		propTypes = {
			CC.shared_enums_pb.EPT_Wealth,
			CC.shared_enums_pb.EPT_Title,
			CC.shared_enums_pb.EPT_Statistic,
		}
	}
	CC.Request("ReqLoadPlayerWithPropType",param)
end

function TrailPersonalInfoViewCtr:OnLoadPlayerWithPropTypeRsp(err, result)

	--重连触发重新加载玩家道具信息,玩家为自己时不处理
	if self.infoType == self.personalInfoDefine.PersonalInfoMode.Self then
		return;
	end

	if err == 0 then
		--返回数据后初始化界面
		self.playerData = result;
		local data = {};
		data.infoType = self.infoType;
		self.view:InitContent(data);
		self:ChangeToInfoPanel();
	else
		self.view:Destroy();
	end
end

function TrailPersonalInfoViewCtr:GetProcessData(param)
	--组装刷新界面需要使用的数据
	local data = {};
	data.refreshProcess = true;
	data.infoType = self.infoType;
	data.curTitleDes = self:GetTitleDes("current");
	data.nextTitleDes = self:GetTitleDes("next");
	data.progress,data.total = self:GetTaskProgress(param);
	data.taskData = self:GetTaskDes(param);
	return data;
end

function TrailPersonalInfoViewCtr:GetIntroduceData()
	--组装刷新界面需要使用的数据
	local playerData = self.playerData.Data.Player;
	local data = {};
	data.refreshIntroduce = true;
	data.createHeadId = playerData.Id
	data.infoType = self.infoType;
	data.nick = playerData.Nick;
	data.id = playerData.Id;
	data.portrait = playerData.Portrait;
	data.personSign = playerData.PersonSign;
	data.sex = self:GetSexValue(playerData.Sex)
	data.bitrh = playerData.Birth
	data.titleDes = self:GetTitleDes("current");
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
	if self.infoType == self.personalInfoDefine.PersonalInfoMode.Self then
		data.nextLevel = self:GetNextLevel(data.curLevel);
		data.nextLvlNeedExp,data.expProgress = self:GetNextLvlNeedExpAndProgress(data.curLevel);
	end
	return data;
end

function TrailPersonalInfoViewCtr:GetSexValue(value)
	local sex = self.language.male
	if value == CC.shared_enums_pb.S_Female then
		sex = self.language.female
	end
	return sex
end

function TrailPersonalInfoViewCtr:GetTaskProgress(taskData)
	if not taskData then
		return;
	end

	local taskCfg = self.taskCfg[taskData.ConfigId];

	local progress = 0;
	for _,v in ipairs(taskData.Items) do
		for _, c in ipairs(taskCfg.Conditions) do
			if c.ConfigId == v.ConfigId then
				progress = progress + math.floor(v.Progress/c.Count);
				break;
			end
		end
	end

	return progress,#taskCfg.Conditions;
end

function TrailPersonalInfoViewCtr:GetTaskDes(taskData)
	if not taskData then
		return;
	end

	local taskCfg = self.taskCfg[taskData.ConfigId];

	local data = {};
	for _,v in ipairs(taskData.Items) do
		local tb = {};
		local key = string.format("task_%s_%s_Desc", taskData.ConfigId, v.ConfigId);
		tb.des = CC.ConfigCenter.Inst():getDescByKey(key);

		for _, c in ipairs(taskCfg.Conditions) do
			if c.ConfigId == v.ConfigId then
				tb.showTick = math.floor(v.Progress/c.Count) >= 1 and true;
				break;
			end
		end
		table.insert(data, tb);
	end

	return data;
end

function TrailPersonalInfoViewCtr:GetTitleId(param)
	local propsData = self.playerData.Data.Props;
	local titleId;
	for _,v in ipairs(propsData) do
		if v.ConfigId >= 7000 and v.ConfigId < 8000 then
			titleId = v.ConfigId;
		end
	end

	if param == "current" then
		return titleId;
	elseif param == "next" then
		local nextTitleId = titleId+1;
		if self.propCfg[nextTitleId] then
			return nextTitleId;
		end
	end

	logError("TrailPersonalInfoViewCtr:has no titleId");
end

function TrailPersonalInfoViewCtr:GetTitleDes(param)
	--获取头衔id(7000-8000)
	local titleId = self:GetTitleId(param);

	if not titleId then
		return "";
	end

	local nameKey = "prop_" .. titleId .. "_Description";
	return CC.ConfigCenter.Inst():getDescByKey(nameKey);
end

function TrailPersonalInfoViewCtr:GetExperience(level)
	local level = tonumber(level);
	if self.levelCfg[level] then
		return self.levelCfg[level].Experience;
	end
	logError("TrailPersonalInfoViewCtr:has no config of level"..tostring(level));
end

function TrailPersonalInfoViewCtr:GetNextLevel(curLevel)
	local levelCfg = self.levelCfg[curLevel+1];
	if levelCfg then
		return curLevel+1;
	end
	logError("TrailPersonalInfoViewCtr:level "..(curLevel+1).." is out of limmit");
	return false;
end

function TrailPersonalInfoViewCtr:GetNextLvlNeedExpAndProgress(curLevel)
	local nextLvlNeedExp = self:GetExperience(curLevel);
	local totalCurExp = self:GetPropValueByKey("EPC_Experience");
	local totalNextExp = 0;
	for i=0, curLevel do
	    totalNextExp = totalNextExp + self:GetExperience(i);
	    if i <= curLevel - 1 then
	      totalCurExp = totalCurExp + self:GetExperience(i);
	    end
	end

	local progress = totalCurExp/totalNextExp;
	return CC.uu.ChipFormat(math.floor((totalNextExp-totalCurExp)/1000000)), progress;
end

function TrailPersonalInfoViewCtr:GetNickName()

	local playerData = self.playerData.Data.Player;
	if playerData.Nick == "" then
		return "Name"
	end
	return playerData.Nick;
end

function TrailPersonalInfoViewCtr:GetPropValueByKey(key)
	local propId = CC.shared_enums_pb[key]
	if not propId then
		logError("TrailPersonalInfoViewCtr:shared_enums_pb has no enum value of "..tostring(key))
		return
	end
	local propsData = self.playerData.Data.Props;
	for _,v in ipairs(propsData) do
		if v.ConfigId == propId then
			return v.Count
		end
	end
	logError("TrailPersonalInfoViewCtr:has no this propId-"..tostring(propId))
end

function TrailPersonalInfoViewCtr:ChangeToInfoPanel()

	if not self.initIntroduce then
		self.initIntroduce = true;
		local data = self:GetIntroduceData();
		self.view:RefreshUI(data);
	end
end

function TrailPersonalInfoViewCtr:OnOpenStoreView()
	CC.ViewManager.OpenAndReplace("StoreView");
end

function TrailPersonalInfoViewCtr:OnOpenVIPRightView()
	local gaussBlur = GameObject.Find("HallCamera/GaussCamera"):GetComponent("GaussBlur");
	local level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");
	CC.ViewManager.OpenAndReplace("VipView", level, function(state) gaussBlur.enabled = state end);
end

function TrailPersonalInfoViewCtr:OnBindFaceBook()

	if self.accountBinding then
		return;
	end
	self.accountBinding = true;
	local successCallback = function(fbData)

	        local data = {};
            data.FacebookId =   fbData.user_id;
	        data.FacebookToken = fbData.access_token;
            CC.Request("BindFacebook",data)
	    end

    local errCallBack = function()
    		CC.ViewManager.ShowTip(self.language.facebookLoginTips2);
    		self.accountBinding = false;
		end

	--如果没有绑定过FACEBOOK,走FACEBOOK绑定流程
	CC.FacebookPlugin.LogIn(successCallback, errCallBack);
end

function TrailPersonalInfoViewCtr:OnBindFaceBookRsp(err, result)
	if err == 0 then
		--facebook绑定成功
		local loginData = CC.Player.Inst():GetLoginInfo();
		loginData.BindingFlag = bit.bor(loginData.BindingFlag, CC.shared_enums_pb.EF_Binded);
		local param = {};
		param.infoType =self.infoType;
		param.refreshIntroduce = true;
		param.hideBtnBindFacebook = true;
		param.hideBtnBindLine = true;
		param.showShieldLayer = true;
		self.view:RefreshUI(param);

		CC.ViewManager.OpenRewardsView({items = {{ConfigId = 2, Count = 5000}},title = "BindFacebook",callback = function()
			CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.AutoFacebook);
		end})
	else
		--facebook绑定失败
		if err == CC.shared_en_pb.FacebookAlreadyBinded then
			CC.ViewManager.ShowTip(self.language.facebookLoginTips1);
		else
			CC.ViewManager.ShowTip(self.language.facebookLoginTips4);
		end
		self.accountBinding = false;
		CC.FacebookPlugin.Logout();
	end
end

function TrailPersonalInfoViewCtr:OnBindLine()
	if self.accountBinding then
		return;
	end
	self.accountBinding = true;
	local successCallback = function(lineData)
	        local data = {};
		    data.LineId = lineData.user_id;
		    data.LineToken = lineData.access_token;
            CC.Request("BindLine",data);

	    end

    local errCallBack = function()
    		CC.ViewManager.ShowTip(self.language.lineLoginTips2);
    		self.accountBinding = false;
		end

	--如果没有绑定过Line,走Line绑定流程
	CC.LinePlugin.Login(successCallback, errCallBack);
end

function TrailPersonalInfoViewCtr:OnBindLineRsp(err, data)
	if err == 0 then
		--facebook绑定成功
		local loginData = CC.Player.Inst():GetLoginInfo();
		loginData.BindingFlag = bit.bor(loginData.BindingFlag, CC.shared_enums_pb.EF_LineBinded);
		local param = {};
		param.infoType =self.infoType;
		param.refreshIntroduce = true;
		param.hideBtnBindFacebook = true;
		param.hideBtnBindLine = true;
		param.showShieldLayer = true;
		self.view:RefreshUI(param);
		CC.ViewManager.OpenRewardsView({items = {{ConfigId = 2, Count = 5000}},title = "BindLine",callback = function()
			CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.AutoLine);
		end})
	else
		--line绑定失败
		if err == CC.shared_en_pb.LineAlreadyBinded then
			CC.ViewManager.ShowTip(self.language.lineLoginTips1);
		else
			CC.ViewManager.ShowTip(self.language.lineLoginTips4);
		end
		self.accountBinding = false;
		CC.LinePlugin.Logout();
	end
end

function TrailPersonalInfoViewCtr:OnDeleteFriend()

	local playerId = self.playerData.Data.Player.Id;
	CC.Request("ReqDelFriend",{FriendId = playerId});
end

function TrailPersonalInfoViewCtr:OnDeleteFriendRsp(err, result)

	if err == 0 then
		CC.ViewManager.ShowTip(self.language.deleteSuccess)

		local data = {};
		data.refreshIntroduce = true;
		data.infoType = self.personalInfoDefine.PersonalInfoMode.Stranger;
		self.view:RefreshUI(data);
	else
		CC.uu.Log("TrailPersonalInfoViewCtr: Request.ReqDelFriend failed");
	end
end

function TrailPersonalInfoViewCtr:OnAddFriend()

	local playerId = self.playerData.Data.Player.Id;
	CC.Request("ReqAddFriend",{FriendId = playerId});

	local data = {};
	data.refreshIntroduce = true;
	data.setAddFriendGray = true;
	self.view:RefreshUI(data);
end

function TrailPersonalInfoViewCtr:OnOpenHeadChoose()

	if not CC.ViewManager.IsHallScene() then
		return;
	end

	local data = {};
	data.portrait = self.playerData.Data.Player.Portrait;
	data.callback = function()
		CC.ViewManager.Open("PersonalInfoView");
	end
	CC.ViewManager.Open("PersonalHeadChooseView", data);
	self.view:Destroy();
end

return TrailPersonalInfoViewCtr;