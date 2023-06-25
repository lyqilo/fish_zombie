
local CC = require("CC")

local MailViewCtr = CC.class2("MailViewCtr")

function MailViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function MailViewCtr:OnCreate()

	self:InitData();

	self:RegisterEvent();
end

function MailViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.SetMailData, CC.Notifications.NW_ReqMailLoadAll)

	CC.HallNotificationCenter.inst():register(self, self.OnAddMail, CC.Notifications.MailAdd)

	CC.HallNotificationCenter.inst():register(self, self.OnMailLoad, CC.Notifications.NW_ReqMailLoad)

	CC.HallNotificationCenter.inst():register(self, self.OnTakeAttachments, CC.Notifications.NW_ReqMailTakeAttachments)

	CC.HallNotificationCenter.inst():register(self, self.OnTakeAllAttachments, CC.Notifications.NW_ReqMailTakeAllSys)

	CC.HallNotificationCenter.inst():register(self, self.OnTakeAllAttachments, CC.Notifications.NW_ReqMailTakeAllPersonal)

	CC.HallNotificationCenter.inst():register(self, self.OnDeleteMails, CC.Notifications.NW_ReqMailDeleteAllSys)

	CC.HallNotificationCenter.inst():register(self, self.OnDeleteMails, CC.Notifications.NW_ReqMailDeleteAllPersonal)

	CC.HallNotificationCenter.inst():register(self, self.OnGetPointInfo, CC.Notifications.NW_GetPointInfo)
end

function MailViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqMailLoadAll)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.MailAdd)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqMailLoad)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqMailTakeAttachments)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqMailTakeAllSys)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqMailTakeAllPersonal)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqMailDeleteAllSys)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_ReqMailDeleteAllPersonal)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_GetPointInfo)
end

function MailViewCtr:SetMailData(err,data)
	if err == 0 then
		-- log("拉取邮件列表成功！")
		self.mailDataMgr.SetMailData(data);
		self:InitData();
	else
		logError("MailViewCtr: LoadMailData failed"..err);
	end
end

function MailViewCtr:OnAddMail()
	--在邮件界面收到邮件重新打开
    self.view:RunAction(self.view, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self.view:Destroy();
    		CC.ViewManager.Open("MailView");
    	end})
end

function MailViewCtr:Destroy()
	self:UnRegisterEvent();
end

function MailViewCtr:InitVar(view, param)

	self.param = param;

	self.view = view;
	--邮件数据
	self.mailData = {};
	--当前显示的邮件类型
	self.mailType = nil;
	--当前显示的邮件对象
	self.curMailInfo = nil;
	--记录每个页签选中的邮件信息
	self.recordMailInfo = {};

	self.propData = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.mailDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Mail");

	self.language = self.view:GetLanguage();
end

function MailViewCtr:InitData()

	if not self.mailDataMgr.GetReqState() then
		CC.Request("ReqMailLoadAll")
		--获取本地缓存的邮件数据
		self.mailData = self:GetUIData();

		self.view:InitContent(self.mailData);
		return
	end

	--获取推送过来的邮件id,如果有就请求邮件数据
	local mailIds = self.mailDataMgr.GetMailIds();

	if not table.isEmpty(mailIds) then

        CC.Request("ReqMailLoad",{Ids = mailIds})

	else

		--获取本地缓存的邮件数据
		self.mailData = self:GetUIData();

		self.view:InitContent(self.mailData);
	end

end

function MailViewCtr:GetUIData()
	local data = {};
	data.systemMails = self.mailDataMgr.GetSystemMailData();
	data.friendMails = self.mailDataMgr.GetFriendMailData();
	return data;
end

function MailViewCtr:OnMailLoad(err, data)
	if err == 0 then
		self.mailDataMgr.AddMail(data);
		self.mailData = self:GetUIData();
		self.view:InitContent(self.mailData);
		--刷新大厅邮件按钮角标提示
		CC.HallNotificationCenter.inst():post(CC.Notifications.MailOpen);
	else
		self.mailData = self:GetUIData();
		self.view:InitContent(self.mailData);
	end
end

function MailViewCtr:OnMailOpen(mailId)

	self.mailDataMgr.SetMailOpen(mailId);
	--通知服务器邮件已被打开
    CC.Request("ReqMailOpen",{MailId = mailId})

	CC.HallNotificationCenter.inst():post(CC.Notifications.MailOpen);
end

function MailViewCtr:OnTakeAttachments(err, result)

	if err == 0 then
		local curMailId = self.curMailInfo and self.curMailInfo.data.Id;
		self.mailDataMgr.SetMailAttackTook(curMailId);
		local data = {};
		data.refreshContent = true;
		data.mailAttachTook = true;
		data.allMailAttackTook = self:OnCheckAllMailTook();
		self.view:RefreshUI(data);

		local ConfigId = nil
		for k, v in pairs(self.curMailInfo.data.Attachments) do
			if v.ConfigId then
				ConfigId = v.ConfigId
			end
		end
		if self.propData[ConfigId].Physical and self.propData[ConfigId].IdendityInfo then
			log("提交信息")
		else
			CC.ViewManager.OpenRewardsView({items = self.curMailInfo.data.Attachments})
		end
	else
		CC.uu.Log("MailViewCtr: takeAttachments failed");
	end
end

function MailViewCtr:OnGetPointInfo(err,param)
	if err == 0 then
		local curMailId = self.curMailInfo and self.curMailInfo.data.Id;
		local serail = ""
		local password = ""
		for _, v in ipairs(param.Cards) do
			if v.CardSeri then
				serail = self.language.pointCardNum..(v.CardSeri)
			end
			if v.CardPwd then
				password = self.language.pointCardPin..(v.CardPwd)
			end
		end
		local str = "\n\n"..serail..password
		self.mailDataMgr.SetMailAttackTook(curMailId);
		local content = self.mailDataMgr.SetAndReturnMailExtraData(curMailId,str)
		local data = {};
		data.refreshContent = true;
		data.mailAttachTook = true;
		data.hasDelivery = false;
		if string.find(content, "</url>") then
			data.linkMailContent = content;
		else
			data.normalMailContent = content;
		end
		data.allMailAttackTook = self:OnCheckAllMailTook();
		self.view:RefreshUI(data);
	else
		logError("获取点卡失败")
	end
end

function MailViewCtr:OnTakeAllAttachments(err, result)

	if err == 0 then
		if #result.TookIds == 0 then
			CC.ViewManager.ShowTip(self.language.noMailCanTake);
			return;
		end

		for _,id in ipairs(result.TookIds) do
			self.mailDataMgr.SetMailAttackTook(id);
			self.mailDataMgr.SetMailOpen(id);
		end
		--组装刷新邮件界面的数据
		local data = {};
		data.mailType = self.mailType;
		data.openMailIds = {};
		for _,id in ipairs(result.TookIds) do
			data.openMailIds[id] = id;
		end
		local curMailId = self.curMailInfo and self.curMailInfo.data.Id;
		for _,id in ipairs(result.TookIds) do
			if curMailId and curMailId == id then
				data.refreshContent = true;
				data.mailAttachTook = true;
			end
		end
		data.allMailAttackTook = self:OnCheckAllMailTook();

		self.view:RefreshUI(data);

		CC.HallNotificationCenter.inst():post(CC.Notifications.MailOpen);

		--组装通用奖励显示的数据
		local data = {};
		local mailData = self.mailDataMgr.GetMailData();
		for _, id in ipairs(result.TookIds) do
			for _,v in ipairs(mailData[id].Attachments) do
				if not data[v.ConfigId] then
					data[v.ConfigId] = {};
					data[v.ConfigId].ConfigId = v.ConfigId;
					data[v.ConfigId].Delta = v.Count;
				else
					data[v.ConfigId].Delta = data[v.ConfigId].Delta + v.Count;
				end
			end
		end

		local propData = {};
		for _,v in pairs(data) do
			table.insert(propData, v);
		end
		if not CC.ViewManager.OpenRewardsView({items = propData}) then
			CC.ViewManager.ShowTip(self.language.noMailCanTake);
		end
	else
		CC.uu.Log("MailViewCtr: takeAllAttachments failed");
	end

end

function MailViewCtr:OnDeleteMails(err, result)
	if err == 0 then
		-- if #result.DeletedIds == 0 then
		-- 	return;
		-- end
		self.mailDataMgr.RemoveMail({MailIds = result.DeletedIds})

		--清除本地记录的指定类型的邮件信息
		local sysRecordMail = self.recordMailInfo[self.view.MailType.System];
		local friRecordMail = self.recordMailInfo[self.view.MailType.Friend];
		for _,id in ipairs(result.DeletedIds) do
			if sysRecordMail and sysRecordMail.data.Id == id then
				self.recordMailInfo[self.view.MailType.System] = nil;
			end
			if friRecordMail and friRecordMail.data.Id == id then
				self.recordMailInfo[self.view.MailType.Friend] = nil;
			end
			if self.curMailInfo and self.curMailInfo.data.Id == id then
				self.curMailInfo = nil;
			end
		end
		local data = {}
		data.deleteMails = result.DeletedIds;
		--需要先删除UI缓存的邮件对象并重新设置数组下标索引
		self.view:RefreshUI(data);


		local data = {};
		--检测当前页签内邮件是否被完全删除，被完全删除需要隐藏邮件信息
		if (table.isEmpty(self.mailData.systemMails) and self.mailType == self.view.MailType.System)
			or (table.isEmpty(self.mailData.friendMails) and self.mailType == self.view.MailType.Friend) then
			data.showMailInfo = false;
			self.view:RefreshUI(data);
		else
			--检测当前显示的邮件信息是否被删除，被删除则重新选中另外的邮件
			if not self.curMailInfo then
				data.setBtnData = self:GetMailBtnData();
			end
			self.view:RefreshUI(data);

			local mails
			if self.mailType == self.view.MailType.System then
				mails = self.mailDataMgr.GetSystemMailData()
			else
				mails = self.mailDataMgr.GetFriendMailData()
			end
			for id,mail in pairs(mails or {}) do
				local Attachments = mail.Attachments or {}
				for _,v in ipairs(Attachments) do
					if self.propData[v.ConfigId].Physical then
						local box = CC.ViewManager.ShowMessageBox(self.language.deleteTips)
						box:SetOneButton()
						return
					end
				end
			end
		end
	else
		CC.uu.Log("MailViewCtr: deleteAllMail failed");
	end
end

function MailViewCtr:OnClickMailBtn(item)
	local mailInfo = item.data;
	if not mailInfo then
		logError("MailViewCtr: has no mailInfo");
		return;
	end

	if self.curMailInfo == item then
		return
	end

	local data = {};
	data.refreshContent = true;
	data.mailTitle = mailInfo.Title;
	data.mailTime = mailInfo.CreateTime;
	if string.find(mailInfo.Content, "</url>") then
		data.linkMailContent = mailInfo.Content;
	else
		data.normalMailContent = mailInfo.Content;
	end
	data.mailAttachments,data.hasMaterialObject,data.hasIdendityInfo = self:GetAttachmentsData(mailInfo.Attachments);
	if #data.mailAttachments > 0 then
		data.mailAttachTook = mailInfo.AttachmentsTook;
	end
	data.allMailAttackTook = self:OnCheckAllMailTook();

	--当前显示的邮件对象
	self.curMailInfo = item;
	--记录指定类型的邮件对象
	self.recordMailInfo[item.mailType] = item;

	self.view:RefreshUI(data);
end

function MailViewCtr:GetAttachmentsData(attachments)
	local data = {};
	local hasMaterialObject = false
	local hasIdendityInfo = false
	for _,v in ipairs(attachments) do
		local iconData = self.propData[v.ConfigId] and self.propData[v.ConfigId].Icon
		if iconData and iconData ~= "" then
			local t = {};
			t.count = v.Count;
			t.icon = iconData
			table.insert(data, t)
			if hasMaterialObject == false and self.propData[v.ConfigId].Physical then
				hasMaterialObject = true
			end
			if hasIdendityInfo == false and self.propData[v.ConfigId].IdendityInfo then
				hasIdendityInfo = true
			end
		else
			log("MailViewCtr:has no match icon, propId:"..tostring(v.ConfigId))
		end
	end

	return data,hasMaterialObject,hasIdendityInfo;
end

function MailViewCtr:OnChangeToFriend()
	self.mailType = self.view.MailType.Friend;

	local data = {};
	data.showMailInfo = not table.isEmpty(self.mailData.friendMails);
	if data.showMailInfo then
		--没有记录的邮件信息就默认选择第一封邮件显示
		data.setBtnData = self:GetMailBtnData();
	end

	self.view:RefreshUI(data);
end

function MailViewCtr:OnChangeToSystem()
	self.mailType = self.view.MailType.System;

	local data = {};
	data.showMailInfo = not table.isEmpty(self.mailData.systemMails);
	if data.showMailInfo then
		--没有记录的邮件信息就默认选择第一封邮件显示
		data.setBtnData = self:GetMailBtnData();
	end

	self.view:RefreshUI(data);
end

function MailViewCtr:GetMailBtnData()
	local data = {};
	local recordMailItem = self.recordMailInfo[self.mailType];
	if not recordMailItem then
		data.orgShow = true;
		data.index = 1;
	else
		data.index = recordMailItem.index;
	end
	data.mailType = self.mailType;

	return data;
end

function MailViewCtr:OnCommitAttachments()
	for i=1,1 do
		if not self.curMailInfo then
			break
		end
		if not self.curMailInfo.data then
			break
		end
		if not self.curMailInfo.data.Attachments or type(self.curMailInfo.data.Attachments)~="table" then
			break
		end

		local prop
		for i,v in ipairs(self.curMailInfo.data.Attachments) do
			if self.propData[v.ConfigId].Physical then
				prop = v
				break
			end
		end
		if not prop then
			break
		end

		local propData = self.propData[prop.ConfigId]

		--获得物品信息
		local param = {}
		param.Canclose = false
		param.IdendityInfo = propData.IdendityInfo
		param.PersonInfo = propData.PersonInfo
		param.Desc = propData.Description
		if self.curMailInfo and self.curMailInfo.data and self.curMailInfo.data.Id then
			param.EmailId = self.curMailInfo.data.Id
		end
		param.Type = propData.Type
		param.Icon = propData.Icon
		param.ActiveName = "邮箱实物领取"
		param.commitCallback = function ()
			--请求领取邮件附件
			local curMailId = self.curMailInfo.data.Id;
            CC.Request("ReqMailTakeAttachments",{MailId = curMailId})

		end
		CC.ViewManager.OpenOtherEx("InformationView",param)
		return
	end
end

function MailViewCtr:OnGetAttachments()
	if not self.curMailInfo then
		return;
	end
	--请求领取邮件附件
	local curMailId = self.curMailInfo and self.curMailInfo.data.Id;
	CC.Request("ReqMailTakeAttachments",{MailId = curMailId})
end

function MailViewCtr:OnPointAttachments()
	if not self.curMailInfo then
		return;
	end
	--请求查看点卡
	local curMailId = self.curMailInfo and self.curMailInfo.data.Id;
	CC.Request("GetPointInfo",{MailId = curMailId})
end

function MailViewCtr:OnGetAllAttachments()
	local mails
	if self.mailType == self.view.MailType.System then
		mails = self.mailDataMgr.GetSystemMailData()
	else
		mails = self.mailDataMgr.GetFriendMailData()
	end
	for id,mail in pairs(mails or {}) do
		local Attachments = mail.Attachments or {}
		for _,v in ipairs(Attachments) do
			if self.propData[v.ConfigId].Physical and mail.AttachmentsTook == false then
				CC.ViewManager.ShowTip(self.language.cannotAllTips)
				return
			end
		end
	end

	if self.mailType == self.view.MailType.System then

        CC.Request("ReqMailTakeAllSys")

	elseif self.mailType == self.view.MailType.Friend then

         CC.Request("ReqMailTakeAllPersonal")
	end
end

function MailViewCtr:OnDeleteAll()
	--请求删除邮件(包括已读无附件的邮件、已读已领取附件的邮件)
	if self.mailType == self.view.MailType.System then

        CC.Request("ReqMailDeleteAllSys")

	elseif self.mailType == self.view.MailType.Friend then


        CC.Request("ReqMailDeleteAllPersonal")
	end
end

function MailViewCtr:OnSortMail(tb)
	--排序规则: 未读有附件>未读无附件>已读有附件>已读无附件
	local sortFunc = function(a,b)
		if not a.Open and b.Open then
			return true;
		elseif a.Open and not b.Open then
			return false;
		end
		return a.CreateTimeStamp > b.CreateTimeStamp;
	end

	table.sort(tb, sortFunc);
end

function MailViewCtr:OnCheckAllMailTook()
	if self.mailType == self.view.MailType.Friend then
		return self.mailDataMgr.CheckFriendMailTook();
	elseif self.mailType == self.view.MailType.System then
		return self.mailDataMgr.CheckSystemMailTook();
	end
	return false;
end

function MailViewCtr:LinkClick(url)
	logError("LinkUrl:"..url)
	Client.OpenURL(url)
end

return MailViewCtr;