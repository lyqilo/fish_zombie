
---------------------------------
-- region RealStoreExplainView.lua    -
-- Date: 2019.8.27        -
-- Desc: 每日转盘说明界面  -
-- Author: Chaoe        -
---------------------------------

local CC = require("CC")

local RealStoreExplainView = CC.uu.ClassView("RealStoreExplainView")

function RealStoreExplainView:ctor(param,callback)
	self.param = param
	self.callback = callback
end

function RealStoreExplainView:OnCreate()

	self:InitContent();
end

function RealStoreExplainView:InitContent()

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:InitTextByLanguage();
end

function RealStoreExplainView:InitTextByLanguage()

	local language = CC.LanguageManager.GetLanguage("L_TreasureView");

	local title = self:FindChild("Frame/Tittle/Text");
	title.text = language.explainTitle;

	local content = self:FindChild("Frame/ScrollText/Viewport/Content/Text");
	local parent = self:FindChild("Frame/ScrollText/Viewport/Content")
	if self.param.shopType == 0 then
		-- CC.uu.ExplainContentSplit(parent,content,language.treasure_ExplainContent)
		content.text = language.treasure_ExplainContent;
	elseif self.param.shopType == CC.proto.client_shop_pb.LiQuanShop then
		-- CC.uu.ExplainContentSplit(parent,content,language.explainContent)
		content.text = language.explainContent;
	elseif self.param.shopType == CC.proto.client_shop_pb.RedEnvelopeShop then
		content.text = language.redPacketExplain;
		parent:FindChild("RedEnvelopeLimit"):SetActive(true)
	end
end

function RealStoreExplainView:OnDestroy()
	if self.callback then
		self.callback()
	end
end

return RealStoreExplainView;
