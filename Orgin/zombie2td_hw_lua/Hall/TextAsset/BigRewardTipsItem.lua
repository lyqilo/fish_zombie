local CC = require("CC")
local ItemBaseClass = require("View/RewardNoticeView/ItemBaseClass")
local baseClass = CC.class2("BigRewardTipsItem",ItemBaseClass)

function baseClass:ctor(obj)
	self.type = 6
	self.callback = nil
	self.createTime = os.time()+math.random()
	self.bgRTr = self:SubGet("","RectTransform")
    self.btn = self:SubGet("btn","Image")
	self.headNode = self:FindChild("Content/HeadNode")
	self.titleText = self:SubGet("Title","Text")
	self.descText = self:FindChild("Content/Desc","Text")
    self.BtnSkip = self:SubGet("BtnSkip","Image")
    self:SetClick()
end

function baseClass:GetOffset(offset)
	return 80 + offset
end

function baseClass:UpdateView( data )
	if not data then
		return
	end
	local title = data.title or ""
	local des = data.des or ""
	self.titleText.text = title
	self.descText.text = des
	
	if data.Player then
		local IconData = {}
		IconData.parent = self.headNode
		IconData.playerId = data.Player.PlayerId
		IconData.portrait = data.Player.Portrait
		self.HeadIcon = CC.HeadManager.CreateHeadIcon(IconData);
	end

	
	if data.openView then
		self.view:AddClick(self.BtnSkip,function()
			CC.ViewManager.Open(data.openView,data.openParam)
		end)
	end
end

function baseClass:OnHide()
	if self.HeadIcon then
		self.HeadIcon:Destroy(true)
		self.HeadIcon = nil
	end
end

return baseClass