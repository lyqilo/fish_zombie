local CC = require("CC")
local ItemBaseClass = require("View/RewardNoticeView/ItemBaseClass")
local baseClass = CC.class2("AwardTipsItem",ItemBaseClass)

function baseClass:ctor(obj)
	self.type = 2
	self.callback = nil
	self.createTime = os.time()+math.random()
	self.bgRTr = self:SubGet("","RectTransform")
	self.btn = self:SubGet("btn","Image")
	self.iconSprite = self:SubGet("icon/Image","Image")
	self.getText = self:SubGet("getText","Text")
	self.goodText = self:SubGet("goodText","Text")
	self.goText = self:SubGet("goText","Text")
	self:SetClick()
end

function baseClass:GetOffset(offset)
	return 39 + offset
end

function baseClass:UpdateView( data )
	if data.Props == nil then
		logError("!!!!!!!!!!!!!!!! 未传奖励信息")
		return
	end
	local ConfigId = data.Props.ConfigId or 1
	local Count = data.Props.Count or 0
	local name = data.name or ""

	local desc = self.view.PropDataMgr.GetLanguageDesc(ConfigId,Count)

	if data.type == 2 then
		self.getText.text = self.view.language.tipsget
		self.goodText.text = desc
		self.goText.text = self.view.language.tipstoemail
	end

	local ImageName = self.view.PropDataMgr.GetIcon( ConfigId, Count )
	if ImageName then
		self.view:SetImage(self.iconSprite, ImageName);
	else
		logError(ConfigId)
	end
end

return baseClass