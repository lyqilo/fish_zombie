local CC = require("CC")

local SelectionGameViewCtr = CC.class2("SelectionGameViewCtr")

function SelectionGameViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function SelectionGameViewCtr:InitVar(view,param)
	self.view = view
	self.param = param
	self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")		--游戏数据管理
	self.language = self.view.language
	--这里必须先缓存大厅界面拉取的强更版本信息(收到强更推送这个数据会被修改)
	self.forceUpdateVersion = self.gameDataMgr.GetForceUpdateVersion();
	self.gameGroupConfig = self.gameDataMgr.GetGroupConfigByID(self.param)
end

function SelectionGameViewCtr:OnCreate()
	self:InitDate()
end

function SelectionGameViewCtr:InitDate()
	local param = {}
	param.gameID = self.param
	param.cardName = "select_"..self.param
	param.lockSession = {}
	for k, v in ipairs(self.gameGroupConfig) do
		table.insert(param.lockSession, self:CheckLockCondition(v))
	end
	--排序
    local function _sort(a,b)
        local r
        local aID = a.GroupID
		local bID = b.GroupID
		r = aID < bID
        return r
    end
    table.sort(param.lockSession,_sort)
	self.view:ReFreshUI(param)
end

function SelectionGameViewCtr:CheckLockCondition(data)
	local param = {}
	local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")			--玩家VIP等级
	local lockCondition = Json.decode(data.UnlockCondition)
	param.GroupID = data.GroupID
	param.Bool = vip >= lockCondition.VipLocked
	param.VipLocked = lockCondition.VipLocked
	param.MinConfigId = lockCondition.Min[1].ConfigId
	param.MinCount = lockCondition.Min[1].Count
	param.Power = lockCondition.Power
	return param
end

function SelectionGameViewCtr:ReqAllocServer(gameID, groupID,isQuick)
	self.view:SetCanClick(false)

	if CC.DebugDefine.GetGameAddress() then
		self:EnterGame(CC.DebugDefine.GetGameAddress(),gameID,groupID,isQuick)
	else
        local data = {}
        data.GameId = gameID
        data.GroupId = groupID
        CC.Request("ReqAllocServer",data,function (err,data)
			self:EnterGame(data.Address,gameID,groupID,isQuick)
		end,
		function (err,data)
			self.view:SetCanClick(true)
		end)
	end
end

function SelectionGameViewCtr:GetForceUpdateVersionByGameId(gameId)
	return self.forceUpdateVersion[gameId] and tonumber(self.forceUpdateVersion[gameId])
end

function SelectionGameViewCtr:EnterGame(ip,gameID,groupID,isQuick)
	if CC.ViewManager.IsGameEntering() or not CC.ViewManager.IsHallScene() then return end
	local param = {}
	param.serverIp = ip
	param.RoomId = groupID
	param.GameId = gameID
	param.isQuick = isQuick
	param.gameData =  self.gameDataMgr.GetInfoByID(gameID)
	CC.uu.Log(param, " EnterGameParam:")
	CC.ViewManager.EnterGame(param,gameID)
end

function SelectionGameViewCtr:Destroy()
end

return SelectionGameViewCtr