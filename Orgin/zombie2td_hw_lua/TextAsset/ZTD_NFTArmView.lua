local GC = require("GC")
local ZTD = require("ZTD")
--NFT卡装备界面
local NFTArmView = ZTD.ClassView("ZTD_NFTArmView")

--最高品质
local maxGrade = 5

function NFTArmView:OnCreate()
	if #self._args > 0 then
		self.cb = self._args[1]
	end
	self.armList = ZTD.NFTData.GetArmedList()
	for pos,id in pairs(self.armList) do
		if id ~= "" then
			local data = ZTD.NFTData.GetCard(id)
			local card = ZTD.NFTCard:new(data, self:FindChild("Card"..pos))
			card:SetCameraSize(8)
		end
	end
    self:InitBtn()

end


function NFTArmView:InitBtn()
	for i=1, 3 do
		self:AddClick("Card"..i, function()
			self.armPos = i
			self:Destroy()
		end)
	end
	
    self:AddClick("Mask", function()
        self:Destroy()
    end)
end



function NFTArmView:OnDestroy()
	if self.armPos and self.cb then
		self.cb(self.armPos)
	end
end




return NFTArmView