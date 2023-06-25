
local CC = require("CC")

local MailView = CC.uu.ClassView("MailView")

function MailView:ctor(param)
	self.MailType = {
		System = 1,
		Friend = 2,
	}
	self:InitVar(param);
end

function MailView:OnCreate()
	self:InitTr()
	self:InitTextByLanguage();
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function MailView:InitVar(param)

	self.param = param;
	--系统邮件
	self.systemMails = {};
	--好友邮件
	self.friendMails = {};
	--邮件附件物品
	self.mailAttachments = {};
	self.language = self:GetLanguage();

end

function MailView:InitTr()
	self.btnGet = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnGet")
	self.btnCommit = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnCommit")
	self.BtnGetPoint = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnGetPoint")
	self.MailBtnItem = self:FindChild("MailBtnItem")
	self.SystemMailContent = self:FindChild("Frame/MailInfoPanel/LeftPanel/SystemMail/Viewport/Content")
	self.FriendMailContent = self:FindChild("Frame/MailInfoPanel/LeftPanel/FriendMail/Viewport/Content")
	self.MailAttachItem = self:FindChild("MailAttachItem")
	self.RightContent = self:FindChild("Frame/MailInfoPanel/RightPanel/ScrollAttachments/Viewport/Content")
	self.btnService = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnService")

	self:AddClick("Frame/BtnTab/BtnFriend", "OnClickChangeToFriend", "click_tabchange");

	self:AddClick("Frame/BtnTab/BtnSystem", "OnClickChangeToSystem", "click_tabchange");

	self:AddClick("Frame/MailInfoPanel/RightPanel/BtnGet/Select", "OnClickGetAttachments");

	self:AddClick("Frame/MailInfoPanel/RightPanel/BtnCommit/Select", "OnClickCommitAttachments");

	self:AddClick("Frame/MailInfoPanel/RightPanel/BtnGetPoint/Select", "OnClickPointAttachments");

	self:AddClick("Frame/MailInfoPanel/RightPanel/BtnGetAll/Select", "OnClickGetAllAttachments");

	self:AddClick("Frame/MailInfoPanel/RightPanel/BtnDeleteAll", "OnClickDeleteAll");

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:AddClick(self.btnService,function ()
		-- local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLocalServiceUrl();
		-- self.viewCtr:LinkClick(url)
		CC.ViewManager.OpenServiceView()
	end)
	--linkText 用来做超链接跳转
	self.linkTextNode = self:FindChild("Frame/MailInfoPanel/RightPanel/ScrollText/Viewport/Content/LinkText")
	self.linkText = self.linkTextNode:GetComponent("RichText")
	self.linkText.onLinkClick = function (url)
		self.viewCtr:LinkClick(url)
	end
end

function MailView:InitContent(param)

	if param.systemMails then
		self.systemMails = self:CreateMails(param.systemMails);
	end

	if param.friendMails then
		self.friendMails = self:CreateMails(param.friendMails);
	end

	local btnSystem = self:FindChild("Frame/BtnTab/BtnSystem");
	btnSystem:GetComponent("Toggle").isOn = true;
	self:OnClickChangeToSystem();

end

function MailView:InitTextByLanguage()

	local language = self:GetLanguage();

	local frame = self:FindChild("Frame");
	local tabFriend = frame:FindChild("BtnTab/BtnFriend/Text");
	tabFriend.text = language.tabFriend;
	local tabFriend = frame:FindChild("BtnTab/BtnFriendSelect/Text");
	tabFriend.text = language.tabFriend;
	local tabSystem = frame:FindChild("BtnTab/BtnSystem/Text");
	tabSystem.text = language.tabSystem;
	local tabFriend = frame:FindChild("BtnTab/BtnSystemSelect/Text");
	tabFriend.text = language.tabSystem;

	local btnGet = frame:FindChild("MailInfoPanel/RightPanel/BtnGet/Select/Text");
	btnGet.text = language.btnGet;
	local btnGet = frame:FindChild("MailInfoPanel/RightPanel/BtnGet/UnSelect/Text");
	btnGet.text = language.btnGet;
	local btnCommit = frame:FindChild("MailInfoPanel/RightPanel/BtnCommit/Select/Text");
	btnCommit.text = language.commitInfo;
	local btnCommit = frame:FindChild("MailInfoPanel/RightPanel/BtnCommit/UnSelect/Text");
	btnCommit.text = language.commitInfo;
	local btnPoint = frame:FindChild("MailInfoPanel/RightPanel/BtnGetPoint/Select/Text");
	btnPoint.text = language.checkPointCard;
	local btnPoint = frame:FindChild("MailInfoPanel/RightPanel/BtnGetPoint/UnSelect/Text");
	btnPoint.text = language.checkPointCard;
	local btnGetAll = frame:FindChild("MailInfoPanel/RightPanel/BtnGetAll/Select/Text");
	btnGetAll.text = language.btnGetAll;
	local btnGetAll = frame:FindChild("MailInfoPanel/RightPanel/BtnGetAll/UnSelect/Text");
	btnGetAll.text = language.btnGetAll;
	local btnDeleteAll = frame:FindChild("MailInfoPanel/RightPanel/BtnDeleteAll/Text");
	btnDeleteAll.text = language.btnDeleteAll;

	local noMailTips = frame:FindChild("NoMail/Text");
	noMailTips.text = language.noMailTips;
	self.btnService:FindChild("Text").text = language.btnService
end

--[[
@param
refreshContent:		是否刷右边邮件内容
mailTitle:			邮件标题
mailTime:			邮件创建时间
mailContent:		邮件文本内容
mailAttachments:	邮件附件内容
mailAttachTook：		领取按钮的显示状态
setBtnData:			按钮选中数据
	orgShow:		当前按钮无焦点，默认选中一个需要设置toggle组件isOn字段
	index:			邮件对象列表的数组索引
	mailType:		邮件类型(好友,系统)
showMailInfo:		是否显示邮件内容
deleteMails:		需要删除的邮件id
hasMaterialObject:	是否实物
--]]
function MailView:RefreshUI(param)
	if param.refreshContent then
		self:RefreshContent(param);
	end
	--设置按钮选中
	if param.setBtnData then
		self:OnSetBtnShow(param.setBtnData);
	end
	--显示邮件信息
	if param.showMailInfo ~= nil then
		self:OnShowMailInfo(param.showMailInfo);
	end
	--删除邮件
	if param.deleteMails then
		self:OnDeleteMails(param.deleteMails);
	end
	--打开邮件
	if param.openMailIds then
		self:OnOpenMails(param);
	end

	--设置一键领取的显示状态
	if param.allMailAttackTook ~= nil then
		self:OnSetAllAttachBtn(param.allMailAttackTook);
	end
end

function MailView:RefreshContent(param)
	local panel = self:FindChild("Frame/MailInfoPanel");
	--设置邮件标题
	if param.mailTitle then
		self:SetText(panel:FindChild("RightPanel/TopDes/Des"), param.mailTitle);
	end
	--设置邮件创建时间
	if param.mailTime then
		self:SetText(panel:FindChild("RightPanel/TopDes/Time"), param.mailTime);
	end
	--设置普通邮件文本内容
	if param.normalMailContent then
		if param.hasIdendityInfo then
			param.normalMailContent = param.normalMailContent..self.language.serviceTips
		end
		self:SetMailText(param.normalMailContent, true);
	end
	--设置超链接文本内容
	if param.linkMailContent then
		self:SetMailText(param.linkMailContent, false);
	end
	--设置附件内容和领取按钮
	if param.mailAttachments then
		self:CreateAttachments(param.mailAttachments);
	end
	--设置领取按钮的显示状态
	if param.mailAttachTook ~= nil then
		if param.hasMaterialObject then
			if param.hasIdendityInfo then
				self.btnCommit:SetActive(true)
				self.BtnGetPoint:SetActive(false)
				self.btnGet:SetActive(false)
				self:OnSetCommitAttachBtn(param.mailAttachTook)
				self.btnService:SetActive(true)
			else
				self.BtnGetPoint:SetActive(true)
				self.btnCommit:SetActive(false)
				self.btnGet:SetActive(false)
				self:OnSetPointAttachBtn(param.mailAttachTook)
				self.btnService:SetActive(false)
			end
		else
			self.btnGet:SetActive(true)
			self.btnCommit:SetActive(false)
			self.BtnGetPoint:SetActive(false)
			self:OnSetAttachBtn(param.mailAttachTook)
			self.btnService:SetActive(false)
		end
	else
		self.btnCommit:SetActive(false)
		self.btnGet:SetActive(false);
		self.btnService:SetActive(false)
	end
end

function MailView:SetMailText(str, isShowNormal)

	local normalText = self:FindChild("Frame/MailInfoPanel/RightPanel/ScrollText/Viewport/Content/Text");
	normalText:SetActive(isShowNormal);

	self.linkTextNode:SetActive(not isShowNormal);

	if isShowNormal then
		self:SetText(normalText, str);
	else
		self.linkText.text = str;
		LayoutRebuilder.ForceRebuildLayoutImmediate(self:FindChild("Frame/MailInfoPanel/RightPanel/ScrollText/Viewport/Content"));
	end
end

function MailView:OnSetBtnShow(param)

	local mailList = param.mailType == self.MailType.System and self.systemMails or self.friendMails;
	local mailItem = mailList[param.index];
	if param.orgShow then
		mailItem.btn:GetComponent("Toggle").isOn = true;
	end

	mailItem.onSelect();
end

function MailView:OnSetAttachBtn(flag)
	local btnSelect = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnGet/Select");
	btnSelect:SetActive(not flag);
	local btnUnSelect = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnGet/UnSelect");
	btnUnSelect:SetActive(flag);
end

function MailView:OnSetCommitAttachBtn(flag)
	local btnSelect = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnCommit/Select");
	btnSelect:SetActive(not flag);
	local btnUnSelect = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnCommit/UnSelect");
	btnUnSelect:SetActive(flag);
end

function MailView:OnSetPointAttachBtn(flag)
	local btnSelect = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnGetPoint/Select");
	btnSelect:SetActive(not flag);
	local btnUnSelect = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnGetPoint/UnSelect");
	btnUnSelect:SetActive(flag);
end

function MailView:OnSetAllAttachBtn(flag)
	local btnSelect = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnGetAll/Select");
	btnSelect:SetActive(not flag);
	local btnUnSelect = self:FindChild("Frame/MailInfoPanel/RightPanel/BtnGetAll/UnSelect");
	btnUnSelect:SetActive(flag);
end

function MailView:OnOpenMails(param)
	local mailList = param.mailType == self.MailType.System and self.systemMails or self.friendMails;

	for _,v in ipairs(mailList) do
		if param.openMailIds[v.data.Id] then
			v.redDot:SetActive(false);
		end
	end
end

function MailView:OnDeleteMails(mailIds)
	for _,id in ipairs(mailIds) do
		--删除系统邮件
		for i,mail in ipairs(self.systemMails) do
			if mail.data.Id == id then
				CC.uu.destroyObject(mail.btn);
				table.remove(self.systemMails, i);
				break;
			end
		end

		--删除好友邮件
		for i,mail in ipairs(self.friendMails) do
			if mail.data.Id == id then
				CC.uu.destroyObject(mail.btn);
				table.remove(self.friendMails, i);
				break;
			end
		end
	end
	--重置数组下标索引
	for i,mail in ipairs(self.systemMails) do
		mail.index = i;
	end
	for i,mail in ipairs(self.friendMails) do
		mail.index = i;
	end
end

function MailView:CreateMails(mails)
	local mailList ={};
	for _,v in pairs(mails) do
		table.insert(mailList, v);
	end
	--按照策划进行排序
	self.viewCtr:OnSortMail(mailList);

	local data = {};
	for index, v in ipairs(mailList) do
		local mail = self:CreateMailItem(index, v);
		table.insert(data, mail);
	end

	return data;
end

function MailView:CreateMailItem(index, param)
	--创建邮件对象
	local item = {};
	item.data = param;
	item.index = index;
	item.mailType = param.FromPlayerId == 0 and self.MailType.System or self.MailType.Friend;
	local mailContent = item.mailType == self.MailType.System and self.SystemMailContent or self.FriendMailContent;
	item.btn = CC.uu.newObject(self.MailBtnItem, mailContent);
	item.btn:SetActive(true);

	local text;
	if item.mailType == self.MailType.System then
		text = self:GetLanguage().systemMail;
	elseif item.mailType == self.MailType.Friend then
		text = self:GetLanguage().friendMail;
	end
	local btnText = item.btn:FindChild("UnSelect/Text");
	btnText.text = text;
	local btnText = item.btn:FindChild("Select/Text");
	btnText.text = text;

	--没有打开过就显示红点
	item.redDot = item.btn:FindChild("UnSelect/RedDot");
	item.redDot:SetActive(not param.Open);

	item.onSelect = function()
		if not param.Open then
			--设置成打开状态
			self.viewCtr:OnMailOpen(param.Id);

			item.redDot:SetActive(false);
		end

		self.viewCtr:OnClickMailBtn(item);
	end

	item.btn.onClick = function()
		item.onSelect();
	end

	return item;
end

function MailView:CreateAttachments(attachments)
	--每次切换邮件都会重新创建附件物品
	for _,v in ipairs(self.mailAttachments) do
		CC.uu.destroyObject(v);
	end
	self.mailAttachments = {};

	for _,v in ipairs(attachments) do
		local attachment = self:CreateAttachItem(v);
		table.insert(self.mailAttachments, attachment);
	end
end

function MailView:CreateAttachItem(param)
	--创建增送物品
	local item = CC.uu.newObject(self.MailAttachItem, self.RightContent);
	--设置icon
	self:SetImage(item:FindChild("Image"), param.icon);
	--数量
	local count = item:FindChild("DesFrame/Text"):GetComponent("Text");
	count.text = CC.uu.ChipFormat(param.count);
	item:SetActive(true);

	return item;
end

function MailView:OnClickChangeToFriend()

	self.viewCtr:OnChangeToFriend();
end

function MailView:OnClickChangeToSystem()

	self.viewCtr:OnChangeToSystem();
end

function MailView:OnClickGetAttachments()

	self.viewCtr:OnGetAttachments();
end

function MailView:OnClickCommitAttachments()

	self.viewCtr:OnCommitAttachments();
end

function MailView:OnClickPointAttachments()
	self.viewCtr:OnPointAttachments();
end

function MailView:OnClickGetAllAttachments()

	self.viewCtr:OnGetAllAttachments();
end

function MailView:OnClickDeleteAll()

	self.viewCtr:OnDeleteAll();
end

function MailView:OnShowMailInfo(isShow)
	local noMail = self:FindChild("Frame/NoMail");
	local mailInfo = self:FindChild("Frame/MailInfoPanel");
	noMail:SetActive(not isShow);
	mailInfo:SetActive(isShow);
end

function MailView:OnDestroy()
	if self.param then
		self.param()
	end
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end

	self.linkText = nil;
end

return MailView;