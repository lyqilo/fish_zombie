local CC = require("CC")
local FreeChipsIcon = require("View/FreeChipsCollectionView/FreeChipsIcon")
local this = CC.class2("SlotFreeChipsIcon",FreeChipsIcon)

function this:InitContent()

	-- self.transform = CC.uu.LoadHallPrefab("prefab", "SlotFreeChipsIcon", self.param.parent);

	-- self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer;

	self.redDot = self.transform:FindChild("RedDot");

	local icon = self.transform:FindChild("Icon");
	self:AddClick(icon, "OnOpenFreeChipsCollection");

	if self.param.sprite then
		local img = icon:GetComponent("Image");
		img.sprite = self.param.sprite;
		icon.width = self.param.width and self.param.width or img.sprite.rect.width;
		icon.height = self.param.height and self.param.height or img.sprite.rect.height;
	end

end

return this