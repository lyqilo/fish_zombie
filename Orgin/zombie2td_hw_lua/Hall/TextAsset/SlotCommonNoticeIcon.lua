--Author:AQ
--Time:2020年12月15日 09:45:53 Tuesday
--Describe:

local CC = require "CC"
local uu = CC.uu
local ViewUIBase = require("Common/ViewUIBase")
local M = CC.class2("SlotCommonNoticeIcon",ViewUIBase)

function M:OnCreate(param)
	self:InitVar(param);
	self:InitContent();
	self.noticeView = uu.CreateHallView("SlotCommonNoticeView",{
		parent = param.viewParent,
		latternParam = param.latternParam,
		bulletMsgParam = param.bulletMsgParam,
	});
end

function M:InitVar(param)
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
end

function M:InitContent()
    self:AddClick(self.transform, "OnOpenSlotCommonNoticeView");
	
end

function M:OnOpenSlotCommonNoticeView()
	if self.noticeView then
		if not self.noticeView:ReadHistoryPublic() then
			CC.ViewManager.ShowMessageBox(self.language.LANGUAGE_59,function()end,function()end):SetOneButton();---“暂时没有公告消息”
			return;
		end
	end
end

function M:OnDestroy()
    if self.noticeView then
		self.noticeView:Destroy();
	end
end

return M