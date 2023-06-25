local CC = require("CC")

local AdvertiseViewCtr = CC.class2("AdvertiseViewCtr")

function AdvertiseViewCtr:ctor(view)
	self:InitVar(view);
end

function AdvertiseViewCtr:InitVar(view)
	self.view = view;
end

function AdvertiseViewCtr:OnCreate()
	self.advertiseList = CC.MessageManager.GetAdvertiseList()
	self.count = #self.advertiseList
	self.view:InitContent(self.count)
end

function AdvertiseViewCtr:ItemData(tran,dataIndex,cellIndex)
	if self.count == 0 then
		local param = {}
		param.texture = nil	--ResourceManager.LoadAsset("image", "message_texture.png")  后续更改可以都只改预制体 AdvertiseView
		param.info = {
    					IsShow = "0",
    					ShowTimeOut = "-1",
    					MessageType = "3",
    					MessageUseType = "3",
    					ExtensionID = "SetUpServiceView"
					}
		self.view:CreateItem(tran,param)
	else
		local index = dataIndex + 1
		local param = {}
		local id = self.advertiseList[index]
		tran.name = tostring(index)
		if CC.MessageManager.GetIconWithID(id) then
			param.texture = CC.MessageManager.GetIconWithID(id)
			param.info = CC.MessageManager.GetADInfoWithID(id)
			self.view:CreateItem(tran,param)
		else
			param.id = id
			param.callback = function ()
				local data = {}
				data.texture = CC.MessageManager.GetIconWithID(id)
				data.info = CC.MessageManager.GetADInfoWithID(id)
				self.view:CreateItem(tran,data)
			end
			CC.MessageManager.ReadLocalAsset(param)
		end
	end
end

return AdvertiseViewCtr