
local CC = require("CC")

local TotalWaterRankViewCtr = CC.class2("TotalWaterRankViewCtr")

function TotalWaterRankViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function TotalWaterRankViewCtr:InitVar(view,param)
    self.view = view
    self.CurRankData = {}
    self.CaptureRankData = {}
    self.SynthesizeRankData = {}
    self.RewardConfig = {{rank = "1",rew1 = {id = 20118,count = 1},rew2 = {id = 20118,count = 1}},
                         {rank = "2",rew1 = {id = 20109,count = 1},rew2 = {id = 20109,count = 1}},
                         {rank = "3",rew1 = {id = 20116,count = 1},rew2 = {id = 20116,count = 1}},
                         {rank = "4",rew1 = {id = 2,count = "20M"},rew2 = {id = 2,count = "20M"}},
                         {rank = "5",rew1 = {id = 2,count = "15M"},rew2 = {id = 2,count = "15M"}},
                         {rank = "6-10",rew1 = {id = 2,count = "10M"},rew2 = {id = 2,count = "10M"}},
                         {rank = "11-20",rew1 = {id = 2,count = "5M"},rew2 = {id = 2,count = "5M"}},
                         {rank = "21-30",rew1 = {id = 2,count = "3M"},rew2 = {id = 2,count = "3M"}},
                         {rank = "31-60",rew1 = {id = 2,count = "2M"},rew2 = {id = 2,count = "2M"}},
                         {rank = "61-100",rew1 = {id = 2,count = "1M"},rew2 = {id = 2,count = "1M"}},
                        }
    self.Type = {Capture = 1,Synthesize = 2}
end

function TotalWaterRankViewCtr:OnCreate()
    self:RegisterEvent()
end

function TotalWaterRankViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnActivityRankDataResq,CC.Notifications.NW_ActivityRankData)
end

function TotalWaterRankViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function TotalWaterRankViewCtr:SwitchTab(tab)
    self.waterTab = tab
   
    local data = tab == self.Type.Capture and self.CaptureRankData or self.SynthesizeRankData
    if table.isEmpty(data) then
        CC.Request("ActivityRankData", {GameType = tab})
    else
        self:RefreshRank(tab)
    end
end

function TotalWaterRankViewCtr:OnActivityRankDataResq(err,data)
    log(string.format("err: %s      data: %s",err,tostring(data)))
    if err == 0 then
        if data.GameType == self.Type.Capture then
            self.CaptureRankData = data.GameRank
            self.CaptureRank = data.PlayerRankID
            self.CaptureScore = data.PlayerRankScore
        else
            self.SynthesizeRankData = data.GameRank
            self.SynthesizeRank = data.PlayerRankID
            self.SynthesizeScore = data.PlayerRankScore
        end
        
        self:RefreshRank(data.GameType)
    end
end

function TotalWaterRankViewCtr:RefreshRank(tab)
    if self.waterTab ~= tab then return end
    
    self.CurRankData = tab == self.Type.Capture and self.CaptureRankData or self.SynthesizeRankData
    self.view:RefreshRankInfo(tab)
end

function TotalWaterRankViewCtr:Destroy()
    self:UnRegisterEvent()
    self.view = nil;
end

return TotalWaterRankViewCtr