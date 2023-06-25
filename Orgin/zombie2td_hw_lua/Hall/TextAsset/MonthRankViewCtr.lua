
local CC = require("CC")

local MonthRankViewCtr = CC.class2("MonthRankViewCtr")

--[[// 游戏集合类型
enum GameSetType{
	GST_All = 0;
	GST_Slot = 1;
	GST_Poker = 2;
	GST_Catch = 3;          //捕获类
	GST_PokerDKT = 4;		// 多人棋牌
	GST_PokerPBHYX = 5;		// 单人棋牌
	CC.shared_enums_pb.GST_NotCatch = 6;		// 除捕获类外
}]]

function MonthRankViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function MonthRankViewCtr:InitVar(view,param)
    self.view = view
    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")


    if param and param.id then
        self.Type = self.HallDefine.MonthRank[param.id] and self.HallDefine.MonthRank[param.id].Type or CC.shared_enums_pb.GST_Catch
    else
        self.Type = CC.shared_enums_pb.GST_Catch
    end
    self.CurType = self.Type
end

function MonthRankViewCtr:OnCreate()
    self:RegisterEvent()
    self:SwitchType(self.Type)
end

function MonthRankViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnGetTopWins,CC.Notifications.NW_GetTopWins)
end

function MonthRankViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetTopWins)
end

function MonthRankViewCtr:OnGetTopWins(err,data)
    if err == 0 then
        self.view.RankDataMgr.SetMonthRankData(data)
        self:RefreshRank(data.Type)
    else
        self:RefreshRank(data.Type)
        log("拉取泼水节排行榜失败")
    end
end

function MonthRankViewCtr:SwitchType(Type)
    if self.view.RankDataMgr.GetMonthRankData(Type) then
        self:RefreshRank(Type)
    else
        CC.Request("GetTopWins",{Type = Type})
    end
    self.CurType = Type
end

function MonthRankViewCtr:RefreshRank(Type)
    self.RankData = self.view.RankDataMgr.GetMonthRankData(Type)
    self.view:RefreshRank(Type)
end

function MonthRankViewCtr:InitRankInfo(tran,dataIndex,cellIndex)
    --初始化所有数据，供UI界面刷新item
    local index = dataIndex + 1
    local rankInfo = self.RankData[index]
	self.view:RefreshItem(tran,rankInfo)
end

function MonthRankViewCtr:OpenRuleView()
    CC.ViewManager.Open("MonthRankRuleView")
end

function MonthRankViewCtr:Destroy()
    self:UnRegisterEvent()
    self.view = nil;
end

return MonthRankViewCtr