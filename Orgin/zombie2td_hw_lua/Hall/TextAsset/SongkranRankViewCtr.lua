local CC = require("CC")

local SongkranRankViewCtr = CC.class2("SongkranRankViewCtr")

function SongkranRankViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function SongkranRankViewCtr:OnCreate()
end

function SongkranRankViewCtr:InitVar(view,param)
    self.view = view
    self.param = param
    self.succCount = 0

    self:RegisterEvent()
    self:ReqRankInfo()
end

function SongkranRankViewCtr:ReqRankInfo()
    if self.view.RankDataMgr.GetSongkranSuccCount() == 4 then
        self.view:InitRank()
    else
        for i = 0,3 do
            -- CC.Request.GetTopWins(i)
        end
    end
end

function SongkranRankViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnGetTopWins,CC.Notifications.NW_GetTopWins)
end

function SongkranRankViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetTopWins)
end

function SongkranRankViewCtr:OnGetTopWins(err,data)
    if err == 0 then
        self.view.RankDataMgr.SetSongkranRankData(data)
    else
        log("拉取泼水节排行榜失败")
    end
    self.succCount = self.succCount + 1
    if self.succCount == 4 then
        self.succCount = 0
        self.view:InitRank()
    end
end

function SongkranRankViewCtr:Destroy()
    self:unRegisterEvent()
end

return SongkranRankViewCtr