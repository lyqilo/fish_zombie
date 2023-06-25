local CC = require("CC")
local ItemBaseClass = require("View/RewardNoticeView/ItemBaseClass")
local baseClass = CC.class2("TreasureTipsItem",ItemBaseClass)

function baseClass:ctor(obj)
	self.type = 5
	self.callback = nil
	self.createTime = os.time()+math.random()
	self.bgRTr = self:SubGet("","RectTransform")
    self.btn = self:SubGet("btn","Image")
    self.BtnSkip = self:SubGet("BtnSkip","Image")
	self.iconSprite = self:SubGet("icon","Image")
	self.getText = self:SubGet("getText","Text")
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
	local des = data.des or string.format("ยินดีด้วย【%s】\nเข้าร่วม วันหยุดหรรษา ได้รับ", name)

	self.getText.text = des

	local ImageName = self.view.PropDataMgr.GetIcon( ConfigId, Count )
	if ImageName then
		self.view:SetImage(self.iconSprite, ImageName);
	else
		logError(ConfigId)
	end
	
	self.view:AddClick(self.BtnSkip,function()
		CC.ViewManager.Open(data.openView, {currentView = data.currentView})
	end)
end

return baseClass