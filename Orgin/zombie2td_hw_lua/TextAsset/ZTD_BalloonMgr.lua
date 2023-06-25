local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

-- 管理所有气球怪母体奖牌
local BalloonMgr = {}
BalloonMgr.Medals = {}

function BalloonMgr.CreateMedal(MedalID, coinPos, monsterType, ratio, f_id, n_id)
    local medal = ZTD.BalloonUi:new()
    medal:Init(MedalID, coinPos, monsterType, ratio, f_id, n_id)
    BalloonMgr.Medals[MedalID] = medal
    return medal
end

function BalloonMgr.FinshMedal(masterId)
	local medal = BalloonMgr.Medals[masterId]
    if medal then
		medal.isMasterFinish = true
		medal:RefreshGold()
	end
end

function BalloonMgr.ReleaseAll()
    for _, medal in pairs(BalloonMgr.Medals) do
        medal:Release()
    end	
    BalloonMgr.Medals = {}
end

return BalloonMgr