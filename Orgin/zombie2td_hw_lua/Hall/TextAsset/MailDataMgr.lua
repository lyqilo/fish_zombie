
local CC = require("CC")

local MailDataMgr = {}

--存放已拉取数据的邮件
local mailData = {}
--存放已拉取数据的系统邮件
local systemMailData = {}
--存放已拉取数据的好友邮件
local friendMailData = {}

--存放服务器push过来还未拉取数据的邮件Id
local mailIds = {};

--邮件拉取状态
local initState = false

function MailDataMgr.SetMailData(data)
	initState = true
	mailData = {};
	systemMailData = {};
	friendMailData = {};
	mailIds = {};
	MailDataMgr.AddMail(data);
end

--插入邮件数据
function MailDataMgr.AddMail(data)
	for _,v in ipairs(data.Mails) do
		local tb = {};
		tb.Id = v.Id;
		tb.Open = v.Open;
		tb.FromPlayerId = v.FromPlayerId;
		tb.Title = v.Title;
		tb.Content = v.Content;
		tb.CreateTime = v.CreateTime;
		tb.CreateTimeStamp = v.CreateTimeStamp;
		tb.AttachmentsTook = v.AttachmentsTook;
		--ExtraData现在用于点卡卡密，直接拼接到Content里面用于显示
		if v.ExtraData ~= "" then
			tb.Content = v. Content.."\n"..v.ExtraData;
		end
		if v.GMailId ~= "" then
			tb.GMailId = v.GMailId;
		end
		tb.Attachments = {} 
		for _,c in ipairs(v.Attachments) do
			table.insert(tb.Attachments, c);
		end

		mailData[v.Id] = tb;

		mailIds[tb.GMailId or tb.Id] = nil;

		if tb.FromPlayerId == 0 then
			systemMailData[v.Id] = tb;
		else
			friendMailData[v.Id] = tb;
		end
	end
end

--删除邮件数据
function MailDataMgr.RemoveMail(data)

	for _,id in ipairs(data.MailIds) do
		if mailData[id] then
			mailData[id] = nil;
		end
		if systemMailData[id] then
			systemMailData[id] = nil;
		end
		if friendMailData[id] then
			friendMailData[id] = nil;
		end
	end
end

function MailDataMgr.GetMailById(id)

	return mailData[id];
end

--插入未拉取数据的邮件Id
function MailDataMgr.AddMailId(data, key)

	mailIds[data.MailId] = {};
	mailIds[data.MailId].Id = data.MailId;
	mailIds[data.MailId].Open = false;
end

--修改邮件已读
function MailDataMgr.SetMailOpen(id)

	if mailData[id] then
		mailData[id].Open = true;
	end
	if systemMailData[id] then
		systemMailData[id].Open = true;
	end
	if friendMailData[id] then
		friendMailData[id].Open = true;
	end
	if mailIds[id] then
		mailIds[id].Open = true;
	end
end

--修改邮件附件已领取
function MailDataMgr.SetMailAttackTook(id)

	if mailData[id] then
		mailData[id].AttachmentsTook = true;
	end
	if systemMailData[id] then
		systemMailData[id].AttachmentsTook = true;
	end
	if friendMailData[id] then
		friendMailData[id].AttachmentsTook = true;
	end
end

--点卡邮件领取之后修改本地缓存内容
function MailDataMgr.SetAndReturnMailExtraData(id,ExtraData)
	if mailData[id] then
		mailData[id].Content = mailData[id].Content..ExtraData;
	end
	return mailData[id].Content
end

function MailDataMgr.GetMailData()
	return mailData;
end

function MailDataMgr.GetMailIds()
	local mails = {};
	for _,v in pairs(mailIds) do
		table.insert(mails, v.Id);
	end
	return mails;
end

function MailDataMgr.GetMailCount()

	return table.length(mailData) + table.length(mailIds);
end

function MailDataMgr.GetUnOpenMailCount()
	local count = 0;
	for _ ,v in pairs(mailData) do
		if not v.Open then
			count = count + 1;
		end
	end

	for _, v in pairs(mailIds) do
		if not v.Open then
			count = count + 1;
		end
	end
	
	return count;
end

function MailDataMgr.CheckFriendMailTook()
	for _,v in pairs(friendMailData) do
		if not v.AttachmentsTook then
			return false;
		end
	end
	return true;
end

function MailDataMgr.CheckSystemMailTook()
	for _,v in pairs(systemMailData) do
		if not v.AttachmentsTook and not table.isEmpty(v.Attachments) then
			return false;
		end
	end
	return true;
end

function MailDataMgr.GetFriendMailData()
	return friendMailData;
end

function MailDataMgr.GetSystemMailData()
	return systemMailData;
end

function MailDataMgr.GetReqState()
	return initState
end

function MailDataMgr.ResetReqState()
	initState = false
end

return MailDataMgr
