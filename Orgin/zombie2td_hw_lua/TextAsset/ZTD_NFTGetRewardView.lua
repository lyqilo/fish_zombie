local GC = require("GC")
local ZTD = require("ZTD")
--NFT领奖
local NFTGetRewardView = ZTD.ClassView("ZTD_NFTGetRewardView")

local typeImageList = {
	gold = "tubiao-jingbi11",
	frt = "qkl_frtb_icon",
	box_gold = "XD_icon1",
	box_silver = "XD_icon2",
	box_copper = "XD_icon3",
}

--1 每日奖励 2赛季奖励 3宝箱奖励
function NFTGetRewardView:OnCreate()
	local data = self._args[1]
	local lan = ZTD.LanguageManager.GetLanguage("L_ZTD_NFTView")
	self:SetText("root/TextTip", lan.touchTip)
	self.obj = self:FindChild("root/Scroll View/Viewport/Content/Item1")
	for i=1,2 do
		self:FindChild("root/ImageTitle"..i):SetActive(data._type == i)
	end
	self:FindChild("root/imageBg"):SetActive(data._type ~= 3)

	if data._type == 3 then
		self:FindChild("root/Scroll View").localPosition = Vector3(0,0,0)
		self.data = data.prize
	else
		self.data = {}
		for key, val in pairs(data.prize) do
			table.insert(self.data, {name = key, val = val})
		end
	end

	for _, v in pairs(self.data) do
		local obj = GameObject.Instantiate(self.obj)
		obj:SetActive(true)
		obj.transform.parent = self.obj.parent
		obj.localScale = Vector3(1, 1, 1)
		obj:FindChild("Image"):GetComponent("Image").sprite = ResMgr.LoadAssetSprite("uiPrefab", typeImageList[v.name])

		local num
		if v.name == "gold" then
			num = GC.uu.numberToStrWithComma(v.val)
		elseif v.name == "frt" then
			num = ZTD.Extend.FormatSpecNum(v.val/1000000, 6)
		else
			num = v.val
		end
		obj:FindChild("Text"):GetComponent("Text").text = num
	end
	
	self:AddClick("Mask", function()
        self:Destroy()
    end)

end

function NFTGetRewardView:OnDestroy()
	
end




return NFTGetRewardView