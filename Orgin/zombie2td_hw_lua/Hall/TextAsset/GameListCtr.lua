local CC = require("CC")
local GameListCtr = CC.class2("GameListCtr")
local GameType = {
    AllGame = 0,
    FishGame = 1,
    SlotsGame = 2,
    PokerGame = 3
}

function GameListCtr:ctor(view, param)
    self:InitVar(view, param)
    --游戏父节点是否显示
    self.showFish = false
    self.showRecommend = false
    self.showCommon = false
    --广告是否循环
    self.HallADLoop = true
end

function GameListCtr:InitVar(view, param)
    self.param = param

    self.view = view

    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

    self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")

    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")

    self.arenaList = self.gameDataMgr.GetArenaList()

    self.allGame = self.gameDataMgr.GetGameList()
    self.fishGame = self.gameDataMgr.GetFishGameList()
    self.slotsGame = self.gameDataMgr.GetSlotsGameList()
    self.pokerGame = self.gameDataMgr.GetPokerGameList()

    self.guideData = self.gameDataMgr.GetGuide()

    self.ADData = CC.MessageManager.GetHallADList()
end

function GameListCtr:OnCreate()
    -- self:InitListData()
    self:InitHallAD()
    self:RegisterEvent()
    -- if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetPingSwitch() then
    self:LoadJackpots()
    -- end
end

function GameListCtr:InitHallAD()
    self.adCount = #self.ADData
    self.view:InitContent(self.adCount)
end

function GameListCtr:SetGameList(gameType)
    local list = nil
    if gameType == GameType.AllGame then
        list = self.allGame
    elseif gameType == GameType.FishGame then
        list = self.fishGame
    elseif gameType == GameType.SlotsGame then
        list = self.slotsGame
    elseif gameType == GameType.PokerGame then
        list = self.pokerGame
    end
    if list then
        self:InitListData(list)
    end
end

function GameListCtr:InitListData(GameList)
    local List = {}
    List.airList = {}
    List.fishList = {}
    List.rcList = {}
    List.miniList = {}
    self.showFish = false
    self.showRecommend = false
    self.showCommon = false
    for i = 1, #GameList do
        local param = {}
        local id = GameList[i]
        local data = self.gameDataMgr.GetInfoByID(id)
        local vip = data.VipUnlock
        param.id = id
        param.name = "yxrk_" .. id
        param.data = data
        local isHall = false
        if self.HallDefine.GameListIcon[param.name] then
            isHall = self.HallDefine.GameListIcon[param.name].isHall
        end
        if isHall and CC.LocalGameData.GetGameVersion(id) == 0 then
            CC.LocalGameData.SetGameVersion(id, 1)
        end

        if self:JudgeGuideState(vip, isHall) then
            if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= data.VipShow then
                if id == 3002 or id == 3005 then
                    table.insert(List.fishList, param)
                    self.showFish = true
                elseif id == 3007 then
                    table.insert(List.airList, param)
                    self.showFish = true
                elseif data.IsRecommendGame == 1 then
                    table.insert(List.rcList, param)
                    self.showRecommend = true
                elseif
                    (id == 4002 and
                        (not self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel") or table.isEmpty(self.arenaList))) or
                        id == 3006
                 then
                    -- log("拉取竞技场信息失败，隐藏大厅竞技场,捕鱼竞技场不显示在游戏列表")
                elseif id == 2004 then
                    if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") > 0 then
                        table.insert(List.miniList, param)
                        self.showCommon = true
                    end
                else
                    table.insert(List.miniList, param)
                    self.showCommon = true
                end
            end

            if CC.ChannelMgr.GetTrailStatus() then
                List.airList = {}
                List.fishList = {}
                self.showFish = false
            end
        end
    end
    --IOS屏蔽足球
    if CC.Platform.isIOS then
        local remove = nil
        for k, v in pairs(List.miniList) do
            if v.id == 5008 then
                remove = k
                break
            end
        end
        if remove then
            table.remove(List.miniList, remove)
        end
    end
    self.view:InitGameList(List)
end

function GameListCtr:JudgeGuideState(vip, isHall)
    if not self.guideData.state or self.guideData.Flag > 0 or (self.guideData.state and vip < 1 and not isHall) then
        return true
    else
        return false
    end
end

function GameListCtr:LoadJackpots()
    CC.Request(
        "LoadJackpots",
        nil,
        function(err, data)
            CC.Player.Inst():SetJackpots(data.Items)
        end
    )
end

function GameListCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self, self.VipChanged, CC.Notifications.VipChanged)
    CC.HallNotificationCenter.inst():register(self, self.DownloadProcess, CC.Notifications.DownloadGame)
    CC.HallNotificationCenter.inst():register(self, self.InitGameJackpots, CC.Notifications.InitGameJackpots)
    CC.HallNotificationCenter.inst():register(self, self.DownloadFail, CC.Notifications.DownloadFail)
    CC.HallNotificationCenter.inst():register(self, self.SetCanClick, CC.Notifications.GameClick)
    CC.HallNotificationCenter.inst():register(self, self.GameUnlockGift, CC.Notifications.OnGameUnlockGift)
    CC.HallNotificationCenter.inst():register(self, self.SetClickState, CC.Notifications.GameClickState)
    CC.HallNotificationCenter.inst():register(self, self.RefreshSubscribeList, CC.Notifications.OnRefreshSubscribeList)
    -- CC.HallNotificationCenter.inst():register(self,self.OnExchangeRsp,CC.Notifications.NW_ReqExchange)
    CC.HallNotificationCenter.inst():register(self, self.UpdataGameList, CC.Notifications.RefreshGameList)
end

function GameListCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function GameListCtr:RefreshSubscribeList()
    self.view:RefreshSubscribeList()
end

function GameListCtr:OnExchangeRsp(err, result)
    log("err = " .. err .. "  " .. CC.uu.Dump(result, "ReqExchange", 10))
    if err == 0 then
        for _, v in ipairs(result.Items) do
            --2021周年庆免费头像框
            if v.ConfigId == CC.shared_enums_pb.EPC_Anni_Avator_Box then
                self.ADData = CC.MessageManager.GetHallADList()
                self:InitHallAD()
                CC.ViewManager.Open("CelebrationFrameView")
            end
        end
    end
end

function GameListCtr:GameUnlockGift(param)
    self.view:GameUnlockGift(param.GameId)
end

function GameListCtr:VipChanged(level)
    self.view:VipChanged(level)
end

function GameListCtr:DownloadProcess(data)
    self.view:DownloadProcess(data)
end

function GameListCtr:DownloadFail(id)
    self.view:DownloadFail(id)
end

function GameListCtr:InitGameJackpots(bState)
    self.view:InitGameJackpots(bState)
end

function GameListCtr:SetClickState(param)
    local id = param.id
    local state = param.state
    --设置点击状态时，可能还在执行携程创建游戏入口，会导致列表中还没有相应游戏，跳过设置状态不影响后续功能
    if self.view.gameList[id] then
        self.view.gameList[id].isClick = state
    end
end

function GameListCtr:SetCanClick(flag)
    self.view:SetCanClick(flag)
end

--资讯新增

function GameListCtr:ItemData(tran, dataIndex, cellIndex)
    if self.adCount == 0 then
        local param = {}
        param.texture = nil
        param.info = {
            MessageUseType = "0"
        }
        self.view:CreateItem(tran, param)
    else
        local index = dataIndex + 1
        local param = {}
        local id = self.ADData[index]
        tran.name = tostring(index)
        if CC.MessageManager.GetIconWithID(id) then
            param.texture = CC.MessageManager.GetIconWithID(id)
            param.info = CC.MessageManager.GetADInfoWithID(id)
            self.view:CreateItem(tran, param)
        else
            param.id = id
            param.isHall = true
            param.callback = function()
                local data = {}
                data.texture = CC.MessageManager.GetIconWithID(id)
                data.info = CC.MessageManager.GetADInfoWithID(id)
                self.view:CreateItem(tran, data)
            end
            CC.MessageManager.ReadLocalAsset(param)
        end
    end
end

function GameListCtr:UpdataGameList(gameType)
    self.view:SetGameType(gameType)
end

function GameListCtr:Destroy()
    self:UnRegisterEvent()
    self.view = nil
end

return GameListCtr
