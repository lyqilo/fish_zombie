---------------------------------
-- region ArenaViewCtr.lua	-
-- Date: 2019.7.18				-
-- Desc: 实物商城				-
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local ArenaViewCtr = CC.class2("ArenaViewCtr")

function ArenaViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function ArenaViewCtr:InitVar(view,param)
	self.view = view
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
end

function ArenaViewCtr:OnCreate()
	self.arenaList = self.gameDataMgr.GetArenaList()
	self.arenaADList = CC.MessageManager.GetArenaADList()
	if self.arenaList then
		self.view:InitCards(self.arenaList)
	end
	if self.arenaADList then
		self.view:InitAD(#self.arenaADList)
	end
end

function ArenaViewCtr:CardItem(tran,dataIndex,cellIndex)
	local index = dataIndex + 1
	local param = {}
	param.GameID = self.arenaList[index]
	param.Info = self.gameDataMgr.GetArenaInfoByID(param.GameID)
	self.view:CreateCardItem(tran,param)
end

function ArenaViewCtr:ADItem(tran,dataIndex,cellIndex)
	if #self.arenaADList == 0 then
		local param = {}
		param.texture = nil	--ResourceManager.LoadAsset("image", "message_texture.png")  后续更改可以都只改预制体 AdvertiseView
		param.info = {
    					IsShow = "0",
    					ShowTimeOut = "-1",
    					MessageType = "4",
    					MessageUseType = "0",
    					ExtensionID = ""
					}
		self.view:CreateADItem(tran,param)
	else
		local index = dataIndex + 1
		local param = {}
		local id = self.arenaADList[index]
		tran.name = tostring(index)
		if CC.MessageManager.GetIconWithID(id) then
			param.texture = CC.MessageManager.GetIconWithID(id)
			param.info = CC.MessageManager.GetADInfoWithID(id)
			self.view:CreateADItem(tran,param)
		else
			param.id = id
            param.isHall = true
			param.callback = function ()
				local data = {}
				data.texture = CC.MessageManager.GetIconWithID(id)
				data.info = CC.MessageManager.GetADInfoWithID(id)
				self.view:CreateADItem(tran,data)
			end
			CC.MessageManager.ReadLocalAsset(param)
		end
	end
end

function ArenaViewCtr:Destroy()
	self.view = nil;
end

return ArenaViewCtr