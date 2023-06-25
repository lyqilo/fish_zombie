local CC = require("CC")
local baseClass = CC.class2("MiniGameCtr")

function baseClass:ctor()
	self:RegisterEvent()

	self.miniStatus = {}
	self.timeStamp = nil
	self.serverIpList = {}

	self.hasGame = false
	self.lastPos = Vector3.zero
	self.loadMiniGameStatus = false
	self:ReqLoadMiniStatus()
end

function baseClass:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
	-- CC.HallNotificationCenter.inst():register(self, self.OnPushMiniNotification, CC.Notifications.OnPushMiniNotification)
end

function baseClass:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
	-- CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnPushMiniNotification)
end

function baseClass:OnChangeSelfInfo(props)
	for _, v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_MiniChouMa then
			local chips = CC.Player.Inst():GetSelfInfoByKey("EPC_MiniChouMa") or 0
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniHallChipsChange, chips)
		end
	end
end

--大厅和小厅筹码转换
function baseClass:HallAndMiniConvert(num, toMini)
	if num == nil or type(num) ~= "number" then
		logError("baseClass:HallAndMiniConvert error")
		return
	end
	local curCM
	if toMini then
		curCM = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") or 0
	else
		curCM = CC.Player.Inst():GetSelfInfoByKey("EPC_MiniChouMa") or 0
	end
	if num > curCM then
		num = curCM
	end
	if num <= 0 then return end

	if toMini then
		CC.Request("ReqExchangeChmToMini",{Amount = num})
	else
		CC.Request("ReqExchangeMiniToChm",{Amount = num})
	end
end

function baseClass:ReqLoadMiniStatus()
	if self.loadMiniGameStatus then
		-- log("loading status, don't need to again")
		return
	end
	self.loadMiniGameStatus = true
	CC.Request("ReqLoadMiniStatus",nil,function(err, data)
			self.loadMiniGameStatus = false
			-- log(CC.uu.Dump(data, "ReqLoadMiniStatus data =", 10))
			if err ~= 0 or data == nil then
				self:delayLoad()
			else
				self:updateStatus(data)
			end
		end
	)
end

function baseClass:delayLoad()
	CC.uu.DelayRun(5,
		function()
			log("delay load mini game state trigger----------")
			self:ReqLoadMiniStatus()
		end
	)
end

function baseClass:updateStatus(data)
	local timeStamp = data.TimeStamp
	for _, v in ipairs(data.Items or {}) do
		local gameId = v.GameID
		local param
		if
			v.Json and
				CC.uu.SafeCallFunc(
					function()
						param = Json.decode(v.Json)
					end
				)
		then
			if param and param.timeStamp and timeStamp and param.timeStamp ~= timeStamp then
				param.countdown = param.countdown - (timeStamp - param.timeStamp)
			end
			self.miniStatus[gameId] = param
			self.hasGame = true
		end
	end

	self.timeStamp = os.time()
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniStatusUpdate, self.miniStatus)
end

function baseClass:OnPushMiniNotification(res)
	-- log("on push mini game data -------------------------")
	-- local gameId = res.GameID
	-- local timeStamp = res.TimeStamp
	-- local data
	-- local s = {}
	-- if
	-- 	res.Json and
	-- 		CC.uu.SafeCallFunc(
	-- 			function()
	-- 				data = Json.decode(res.Json)
	-- 			end
	-- 		)
	--  then
	-- 	-- if data and data.timeStamp and timeStamp and data.timeStamp ~= timeStamp then
	-- 	-- 	data.countdown = data.countdown - (timeStamp - data.timeStamp)
	-- 	-- end
	-- 	self.miniStatus[gameId] = data
	-- 	self.hasGame = true
	-- 	s[gameId] = data
	-- end
	-- self.timeStamp = os.time()
	-- CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniStatusUpdate, s)
end

function baseClass:OpenMiniGame(gameID, callback)
	if self.serverIpList[gameID] then
		if callback then
			callback(self.serverIpList[gameID])
		end
	else
		local data = {}
		data.GameId=gameID
		data.GroupId=1
        CC.Request("ReqAllocServer",data,function(err, data)
				self.serverIpList[gameID] = data.Address
				if callback then
					callback(data.Address)
				end
			end
		)

	end
end

function baseClass:CheckCanPlay()
	return self.hasGame
end

function baseClass:GetStatus()
	return self.miniStatus, self.timeStamp
end

function baseClass:SetLastPos(pos)
	self.lastPos = pos
end

function baseClass:GetLastPos()
	return self.lastPos
end

function baseClass:Destroy(...)
	self:unRegisterEvent()
end

return baseClass
