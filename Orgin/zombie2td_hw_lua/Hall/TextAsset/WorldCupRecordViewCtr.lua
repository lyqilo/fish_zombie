local CC = require("CC")

local WorldCupRecordViewCtr = CC.class2("WorldCupRecordViewCtr")
local M = WorldCupRecordViewCtr

function M:ctor(view, param)
    self.GameTypeEnums = {
        [0] = CC.shared_enums_pb.WC_All,
        [1] = CC.shared_enums_pb.WC_GroupGame,
        [2] = CC.shared_enums_pb.WC_ChampionGame,
    }
    self.RecentDayEnums = {
        [0] = 0,
        [1] = 3,
        [2] = 7,
    }
	self:InitVar(view,param)
end

function M:InitVar(view, param)
	self.param = param
	self.view = view
    --投注记录 第一层GameType(下注类型0全部，1单场，2冠军) 第二层RecentDay(天数0全部，3(3天)，7(7天))
    --索引对应Eunms
    self.betRecordList = {
        [0] = {[0] = {}, [3] = {}, [7] = {}},
        [1] = {[0] = {}, [3] = {}, [7] = {}},
        [2] = {[0] = {}, [3] = {}, [7] = {}},
    }
    --中奖记录
    self.winRecordList = {
        [0] = {[0] = {}, [3] = {}, [7] = {}},
        [1] = {[0] = {}, [3] = {}, [7] = {}},
        [2] = {[0] = {}, [3] = {}, [7] = {}},
    }
    --总数量 -1表示没有初始化过
    self.totalCount = {
        --投注记录
        [1] = {
            [0] = {[0] = -1,[3] = -1,[7] = -1},
            [1] = {[0] = -1,[3] = -1,[7] = -1},
            [2] = {[0] = -1,[3] = -1,[7] = -1},
        },
        --中奖记录
        [2] = {
            [0] = {[0] = -1,[3] = -1,[7] = -1},
            [1] = {[0] = -1,[3] = -1,[7] = -1},
            [2] = {[0] = -1,[3] = -1,[7] = -1},
        },
    }
    --页数   1(投注记录)2(中奖记录)
    self.curPage = 1
    self.totalPage = 0

    --记录类型
    self.curGameTpye = self.GameTypeEnums[0]
    --查看天数 0(全部)
    self.betRecentDay = self.RecentDayEnums[0]
    self.winRecentDay = self.RecentDayEnums[0]
end

function M:OnCreate()
	self:RegisterEvent();

    self:ReqGetWorldCupBetRecord()
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqGetWorldCupBetRecordResp,CC.Notifications.NW_ReqGetWorldCupBetRecord)
    CC.HallNotificationCenter.inst():register(self,self.ReqGetWorldCupWinRecordResp,CC.Notifications.NW_ReqGetWorldCupWinRecord)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

--设置记录类型 有类型变化，当前页重置
function M:SetGameType(value)
    self.curPage = 1
    self.curGameTpye = self.GameTypeEnums[value] or 0
end

--设置投注记录显示的天数
function M:SetBetRecentDay(value)
    self.curPage = 1
    self.betRecentDay = self.RecentDayEnums[value] or 0
end

--设置投注记录显示的天数
function M:SetWinRecentDay(value)
    self.curPage = 1
    self.winRecentDay = self.RecentDayEnums[value] or 0
end

--投注记录 每页100数据
function M:ReqGetWorldCupBetRecord()
    if self.recordBetInit and self.totalCount[1][self.curGameTpye][self.betRecentDay] >= 0 and
    (#self.betRecordList[self.curGameTpye][self.betRecentDay] >= self.curPage * 100 or #self.betRecordList[self.curGameTpye][self.betRecentDay] >= self.totalCount[1][self.curGameTpye][self.betRecentDay]) then
        --初始化过 当前类型和当前天数的记录总数>0有请求初始化过
        --当前类型和当前天数的投注记录数据，有当前页数的数据 或者 缓存的数据和总数一样
        --不请求，使用缓存数据
        self:RefreshBetScroller()
        return
    end
    local data = {}
    data.From = self.curPage <= 1 and 0 or (self.curPage - 1) * 100 + 1
    data.To = self.curPage * 100
    data.RecentDay = self.betRecentDay
    data.GameType = self.curGameTpye
    CC.Request("ReqGetWorldCupBetRecord", data)
end

function M:ReqGetWorldCupBetRecordResp(err, param)
    log(CC.uu.Dump(param, "ReqGetWorldCupBetRecord:"))
    if err == 0 then
        if param.TotalCount then
            self.totalCount[1][self.curGameTpye][self.betRecentDay] = param.TotalCount
        end
        if param.BetRecord then
            for _, v in ipairs(param.BetRecord) do
                table.insert(self.betRecordList[self.curGameTpye][self.betRecentDay], v)
            end
            if not self.recordBetInit then
                self.recordBetInit = true
                self.view.BetScrollerController:InitScroller(#self.betRecordList[self.curGameTpye][self.betRecentDay])
                self.view:RefreshPage()
            else
                self:RefreshBetScroller()
            end
        end
    end
end

--刷新投注记录显示数据
function M:RefreshBetScroller()
    local list = {}
    local form = self.curPage <= 1 and 0 or (self.curPage - 1) * 100 + 1
    local to = self.curPage * 100
    for i = form, to do
        if self.betRecordList[self.curGameTpye][self.betRecentDay][i] then
            table.insert(list, self.betRecordList[self.curGameTpye][self.betRecentDay][i])
        end
    end
    self.view.BetScrollerController:RefreshScroller(#list,1 - self.view.recordBetScroRect.verticalNormalizedPosition)
    self.view:RefreshPage()
end

--中奖记录
function M:ReqGetWorldCupWinRecord()
    if self.recordBetInit and self.totalCount[2][self.curGameTpye][self.winRecentDay] >= 0 and
    (#self.winRecordList[self.curGameTpye][self.winRecentDay] >= self.curPage * 100 or #self.winRecordList[self.curGameTpye][self.winRecentDay] >= self.totalCount[2][self.curGameTpye][self.winRecentDay]) then
        self:RefreshWinScroller()
        return
    end
    local data = {}
    data.From = self.curPage <= 1 and 0 or (self.curPage - 1) * 100 + 1
    data.To = self.curPage * 100
    data.RecentDay = self.winRecentDay
    data.GameType = self.curGameTpye
    CC.Request("ReqGetWorldCupWinRecord", data)
end

function M:ReqGetWorldCupWinRecordResp(err, param)
    log(CC.uu.Dump(param, "ReqGetWorldCupWinRecord:"))
    if err == 0 then
        if param.TotalCount then
            self.totalCount[2][self.curGameTpye][self.winRecentDay] = param.TotalCount
        end
        if param.TotalBonus then
            self.view:RefreshEarn(param.TotalBonus)
        end
        if param.BetRecord then
            for _, v in ipairs(param.BetRecord) do
                table.insert(self.winRecordList[self.curGameTpye][self.winRecentDay], v)
            end
            if not self.recordWinInit then
                self.recordWinInit = true
                self.view.WinScrollerController:InitScroller(#self.winRecordList[self.curGameTpye][self.winRecentDay])
                self.view:RefreshPage()
            else
                self:RefreshWinScroller()
            end
        end
    end
end

--刷新中奖记录显示数据
function M:RefreshWinScroller()
    local list = {}
    local form = self.curPage <= 1 and 0 or (self.curPage - 1) * 100 + 1
    local to = self.curPage * 100
    for i = form, to do
        if self.winRecordList[self.curGameTpye][self.winRecentDay][i] then
            table.insert(list, self.winRecordList[self.curGameTpye][self.winRecentDay][i])
        end
    end
    self.view.WinScrollerController:RefreshScroller(#list,1 - self.view.recordBetScroRect.verticalNormalizedPosition)
    self.view:RefreshPage()
end

function M:GetTotalPage(curRecord)
    if curRecord == 1 then
        return math.ceil(self.totalCount[1][self.curGameTpye][self.betRecentDay] / 100)
    elseif curRecord == 2 then
        return math.ceil(self.totalCount[2][self.curGameTpye][self.winRecentDay] / 100)
    end
    return 0
end

function M:Destroy()
	self:UnRegisterEvent()
end

return M