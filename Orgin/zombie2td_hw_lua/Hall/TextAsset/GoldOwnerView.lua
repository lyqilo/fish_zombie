local CC = require("CC")
local GoldOwnerView = CC.uu.ClassView("GoldOwnerView")

function GoldOwnerView:ctor(param)
	self:InitVar(param)
end

function GoldOwnerView:InitVar(param)
	self.param = param
	self.IconList = {}
end

function GoldOwnerView:OnCreate()
	
	self:InitContent()
	self:InitTextByLanguage()
	
	if not self.param or not self.param.PlayerList or table.isEmpty(self.param.PlayerList) then
		self:FindChild("Empty"):SetActive(true)
		return
	end
	
	self:RefreshIconList()
end

function GoldOwnerView:InitContent()
	self.scrollbar = self:FindChild("Scroll View/Scrollbar Vertical"):GetComponent("Scrollbar")
	self.content = self:FindChild("Scroll View/Viewport/Content")
	self.itemPre = self:FindChild("Item")
	
	self.scrollbar.size = 0.09
	
	
	--self:AddClick("Mask","ActionOut")
	self:AddClick("Bg/CloseBtn","ActionOut")
end

function GoldOwnerView:InitTextByLanguage()
	self:FindChild("Bg/Title/Text").text = self.param.title or ""
end

function GoldOwnerView:RefreshIconList()
	for k,v in ipairs(self.param.PlayerList) do
		local item = CC.uu.UguiAddChild(self.content, self.itemPre, k)
		local IconData = {}
		IconData.playerId = v.PlayerId
		IconData.portrait = v.Portrait
		IconData.headFrame = v.Background
		IconData.unShowVip = true
		IconData.parent = item:FindChild("Head")
		local headIcon = CC.HeadManager.CreateHeadIcon(IconData)
		table.insert(self.IconList,headIcon)
		
		item:FindChild("Info/Name").text = v.Nick
		item:FindChild("Info/ID").text = "ID:"..v.PlayerId
	end
end

function GoldOwnerView:OnDestroy()
	
	for _,v in ipairs(self.IconList) do
		if v then
			v:Destroy(true)
			v = nil
		end
	end
	
end



return GoldOwnerView