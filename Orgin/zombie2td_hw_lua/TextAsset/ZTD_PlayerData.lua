local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local Player = GC.Player
--引导开关
local isOpenGuide = false
local playerInfo = nil
local ForceGuideData = nil
local PlayerData = {}

local roomArenaID = 0

function PlayerData.Init()
    playerInfo = {}
    playerInfo.PlayerId = GC.SubGameInterface.GetPlayerId()
    playerInfo.nickName = GC.SubGameInterface.GetNickName()
	playerInfo.money = GC.SubGameInterface.GetHallMoney()
	playerInfo.diamond = GC.SubGameInterface.GetHallDiamond()
    playerInfo.viplevel = GC.SubGameInterface.GetVipLevel()
	playerInfo.IsVip = false
	playerInfo.Effect = nil
	playerInfo.Background = nil
	playerInfo.headID = 1
	playerInfo.chipData = {}
end

function PlayerData.GetMoney()
    return playerInfo.money
end

function PlayerData.GetChipData()
    return playerInfo.chipData
end

function PlayerData.GetChipNumByID(PropsID)
	for k, v in ipairs(playerInfo.chipData) do
		if PropsID == v.PropsID then
			return v.TotalNum
		end
	end
end

function PlayerData.SetChipNumByID(PropsID, TotalNum)
	for k, v in ipairs(playerInfo.chipData) do
		if PropsID == v.PropsID then
			v.TotalNum = TotalNum
		end
	end
end

function PlayerData.SetChipData(chipData)
    playerInfo.chipData = chipData
end

function PlayerData.GetDiamond()
    return playerInfo.diamond
end

function PlayerData.SetDiamond(diamond)
    playerInfo.diamond = diamond
end

function PlayerData.GetPlayerId()
    return playerInfo.PlayerId
end 

function PlayerData.GetNickName()
    return playerInfo.nickName
end

function PlayerData.SetEntryEffect(EffectID)
	-- if EffectID == 3011 then
	-- 	playerInfo.Effect = GC.shared_enums_pb.EPC_Avatar_Effect_1
	-- elseif EffectID == 3012 then
	-- 	playerInfo.Effect = GC.shared_enums_pb.EPC_Avatar_Effect_2
	-- elseif EffectID == 3013 then
	-- 	playerInfo.Effect = GC.shared_enums_pb.EPC_Avatar_Effect_3
	-- elseif EffectID == 3014 then
	-- 	playerInfo.Effect = GC.shared_enums_pb.EPC_Avatar_Effect_4
	-- elseif EffectID == 3015 then
	-- 	playerInfo.Effect = GC.shared_enums_pb.EPC_Avatar_Effect_5
	-- end
	playerInfo.Effect = EffectID
end

function PlayerData.GetEntryEffect()
	return playerInfo.Effect
end

function PlayerData.SetBackground(Background)
	playerInfo.Background = Background
end

function PlayerData.GetBackground()
	return playerInfo.Background
end

function PlayerData.SetHeadID(headID)
    playerInfo.headID = headID
end

function PlayerData.SetHeadImage( playerObj )
    local icon = GC.SubGameInterface.GetHeadIconPathById(playerInfo.headID)
	GC.uu.SetImage(playerObj, icon);
end

--倍率
function PlayerData.SetMultiple(multiple)
	if not playerInfo.oldMultiple then
		playerInfo.oldMultiple = multiple;
	end	
	playerInfo.multiple = multiple
end

function PlayerData.GetMultiple()
	return playerInfo.multiple or 1;
end

-- 设置场ID
function PlayerData.SetRoomArenaID(id)
    roomArenaID = id
end

-- 获取场ID
function PlayerData.GetRoomArenaID()
    return roomArenaID
end

function PlayerData.SetVipLevel(viplevel)
	playerInfo.viplevel = viplevel
end

function PlayerData.GetVipLevel()
	return playerInfo.viplevel
end

function PlayerData.SetIsVip(IsVip)
	playerInfo.IsVip = IsVip
end

function PlayerData.GetIsVip()
	return playerInfo.IsVip
end

function PlayerData.RadioReq(succCb, errCb)
	local cfg = ZTD.ConstConfig[1];
	local multi = playerInfo.multiple or 1;
    ZTD.Request.CSKeepRatioReq(multi, succCb, errCb)
end

function PlayerData.UpdateRadioReq()
	if playerInfo.oldMultiple ~= playerInfo.multiple then
		playerInfo.oldMultiple = playerInfo.multiple;
		PlayerData.RadioReq();
	end
	
end

return PlayerData