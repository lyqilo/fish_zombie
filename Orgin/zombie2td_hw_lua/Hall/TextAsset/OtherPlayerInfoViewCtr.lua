local CC = require("CC")
local OtherPlayerInfoViewCtr = CC.class2("OtherPlayerInfoViewCtr")

--[[
@param
playerId
--]]
function OtherPlayerInfoViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function OtherPlayerInfoViewCtr:OnCreate()
	self:InitData();
	self:RegisterEvent();
end

function OtherPlayerInfoViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnLoadPlayerWithPropTypeRsp, CC.Notifications.NW_ReqLoadPlayerWithPropType)
	CC.HallNotificationCenter.inst():register(self, self.OnDeleteFriendRsp, CC.Notifications.NW_ReqDelFriend)
	CC.HallNotificationCenter.inst():register(self, self.OnSilentRsp, CC.Notifications.NW_Silent)
end

function OtherPlayerInfoViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqLoadPlayerWithPropType)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqDelFriend)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_Silent)
end

function OtherPlayerInfoViewCtr:Destroy()
	self:UnRegisterEvent();
end

function OtherPlayerInfoViewCtr:InitVar(view, param)
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
	--个人信息字段定义
	self.personalInfoDefine = CC.DefineCenter.Inst():getConfigDataByKey("PersonalInfoDefine");

	self.friendDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Friend");

	self.silentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Silent");

	self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
end

function OtherPlayerInfoViewCtr:InitData()
    if self.param.playerId == CC.Player.Inst():GetSelfInfoByKey("Id") then
        self.view:ActionOut()
        return
    end
    --如果是好友或者陌生人则向服务器请求数据
    if self.friendDataMgr.IsFriend(self.param.playerId) then
        self.infoType = self.personalInfoDefine.PersonalInfoMode.Friend;
    else
        self.infoType = self.personalInfoDefine.PersonalInfoMode.Stranger;
    end
    self:ReuestOtherInfoData();
end

function OtherPlayerInfoViewCtr:ReuestOtherInfoData()
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

function OtherPlayerInfoViewCtr:OnLoadPlayerWithPropTypeRsp(err, result)
	if err == 0 then
		if self.param.playerId ~= result.Data.Player.Id then return end
		--返回数据后初始化界面
		self.playerData = result;
		local data = {};
		data.infoType = self.infoType;
		self.view:RefreshContent(data);
		self:ChangeToInfoPanel();
	else
		self.view:Destroy();
	end
end

function OtherPlayerInfoViewCtr:GetIntroduceData()
	--组装刷新界面需要使用的数据
	local playerData = self.playerData.Data.Player;
	local data = {};
	data.createHeadId = playerData.Id
	data.infoType = self.infoType;
	data.nick = playerData.Nick;
	data.id = playerData.Id;
	data.portrait = playerData.Portrait;
	data.personSign = playerData.PersonSign;
	data.sex = self:GetSexValue(playerData.Sex)
	data.Background = playerData.Background
	if self.param.curChips then
		data.curChips = CC.uu.ChipFormat(self.param.curChips)
	else
		data.curChips = CC.uu.ChipFormat(self:GetPropValueByKey("EPC_ChouMa"));
	end
	if self.param.maxWin then
		data.maxWin = CC.uu.ChipFormat(self.param.maxWin)
	else
		data.maxWin = CC.uu.ChipFormat(self:GetPropValueByKey("EPC_MaxSingleWin"));
	end
	if self.param.totalWin then
		data.totalWin = CC.uu.ChipFormat(self.param.totalWin)
	else
		data.totalWin =  CC.uu.ChipFormat(self:GetPropValueByKey("EPC_TotalWin"));
	end
	data.curLevel = self:GetPropValueByKey("EPC_Level");
	return data;
end

function OtherPlayerInfoViewCtr:GetSexValue(value)
	local sex = self.language.male
	if value == CC.shared_enums_pb.S_Female then
		sex = self.language.female
	end
	return sex
end

function OtherPlayerInfoViewCtr:GetPropValueByKey(key)
	local propId = CC.shared_enums_pb[key]
	if not propId then
		logError("OtherPlayerInfoViewCtr:shared_enums_pb has no enum value of "..tostring(key))
		return
	end
	local propsData = self.playerData.Data.Props;
	for _,v in ipairs(propsData) do
		if v.ConfigId == propId then
			return v.Count
		end
	end
	logError("OtherPlayerInfoViewCtr:has no this propId-"..tostring(propId))
end

function OtherPlayerInfoViewCtr:ChangeToInfoPanel()
	if not self.initIntroduce then
		self.initIntroduce = true;
		local data = self:GetIntroduceData();
		self.view:RefreshIntroduceOtherUI(data);
	end
end

function OtherPlayerInfoViewCtr:OnDeleteFriend()
	local playerId = self.playerData.Data.Player.Id;
	--先检查是否是好友
	if not self.friendDataMgr.IsFriend(playerId) then
		return
		log("不是好友，无法删除")
	end
	CC.Request("ReqDelFriend",{FriendId = playerId});
end

function OtherPlayerInfoViewCtr:OnDeleteFriendRsp(err, result)
	if err == 0 then
		CC.ViewManager.ShowTip(self.language.deleteSuccess)
		local data = {};
		data.infoType = self.personalInfoDefine.PersonalInfoMode.Stranger;
		self.view:RefreshIntroduceOtherUI(data);
	else
		CC.uu.Log("OtherPlayerInfoViewCtr: Request.ReqDelFriend failed");
	end
end

function OtherPlayerInfoViewCtr:OnGivingFriend()
	local param = {};
	param.playerId = self.playerData.Data.Player.Id;
	param.playerName = self.playerData.Data.Player.Nick;
	param.portrait = self.playerData.Data.Player.Portrait;
	param.vipLevel = self.playerData.Data.Player.Level;
	CC.ViewManager.Open("SendChipsView", param)
	CC.ViewManager.HideChatPanel();
end

function OtherPlayerInfoViewCtr:OnAddFriend()
	local playerId = self.playerData.Data.Player.Id;
	local lan = CC.LanguageManager.GetLanguage("L_FriendView")
	--先检查是否在申请列表里
	if not self.friendDataMgr.CheckSaveID(playerId) then
		CC.ViewManager.ShowTip(lan.tip1)
		return
	end
	--再检查是否已经是好友
	if self.friendDataMgr.IsFriend(playerId) then
		CC.ViewManager.ShowTip(lan.connectfriendReturn4)
		return
	end

	CC.Request("ReqAddFriend",{FriendId = playerId});

	local data = {};
	data.setAddFriendGray = true;
	self.view:RefreshIntroduceOtherUI(data);
end

function OtherPlayerInfoViewCtr:OnBanSpeak()
	local playerId = self.playerData.Data.Player.Id;
	CC.Request("Silent",{BeSilentPlayer = playerId});
end

function OtherPlayerInfoViewCtr:OnSilentRsp(err, result)
	if err == 0 then
		local lastSilent = self.silentDataMgr.CheckSilentById(result.playerId);
		if lastSilent then
			self.silentDataMgr.RemoveSilentById(result.playerId);
		else
			self.silentDataMgr.AddSilentById(result.playerId);
		end

		local data = {};
		data.banSpeak = lastSilent;
		self.view:RefreshIntroduceOtherUI(data);
	else
		CC.uu.Log("OtherPlayerInfoViewCtr: Request.Slient failed");
	end
end

return OtherPlayerInfoViewCtr;