local CC = require("CC")

local TrailAndroidGameListCtr = CC.class2("TrailAndroidGameListCtr")

function TrailAndroidGameListCtr:ctor(view, param)
	self:InitVar(view, param)
end

function TrailAndroidGameListCtr:InitVar(view,param)
    self.param = param

    self.view = view

    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

    self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")

    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")

    self.arenaList = self.gameDataMgr.GetArenaList()

    self.allGame = self.gameDataMgr.GetGameList()

    self.guideData = self.gameDataMgr.GetGuide()
end

function TrailAndroidGameListCtr:OnCreate()
    self:InitListData()
    self:RegisterEvent()
    self:LoadJackpots()
end

function TrailAndroidGameListCtr:InitListData()
    local List = {}
    List.airList = {}
    List.fishList = {}
    List.rcList = {}
    List.miniList = {}
    for i = 1, #self.allGame do
        local param = {}
        local id = self.allGame[i]
        local data = self.gameDataMgr.GetInfoByID(id)
        local vip = data.VipUnlock
        param.id = id
        param.name = "yxrk_"..id
        param.data = data
        local isHall = false
        if self.HallDefine.GameListIcon[param.name] then
            isHall = self.HallDefine.GameListIcon[param.name].isHall
        end
        if isHall and CC.LocalGameData.GetGameVersion(id) == 0 then
            CC.LocalGameData.SetGameVersion(id,1)
        end

        if self:JudgeGuideState(vip,isHall) then
            if id == 3002 or id == 3005 then
                table.insert(List.fishList,param)
            elseif data.IsRecommendGame == 1 then
                table.insert(List.rcList,param)
            elseif  (id == 4002 and (not self.switchDataMgr.GetSwitchStateByKey("TreasureGoods") or table.isEmpty(self.arenaList))) or id == 3006 then
                -- log("拉取竞技场信息失败，隐藏大厅竞技场,捕鱼竞技场不显示在游戏列表")
            else
                table.insert(List.miniList,param)
            end

            if CC.ChannelMgr.GetTrailStatus() then
                List.airList = {};
                List.fishList = {};
            end
        end
    end
    self.view:InitGameList(List)
end

function TrailAndroidGameListCtr:JudgeGuideState(vip,isHall)

    if not self.guideData.state or self.guideData.Flag > 0 or (self.guideData.state and vip < 1 and not isHall) then
        return true
    else
        return false
    end
end

function TrailAndroidGameListCtr:LoadJackpots()
    CC.Request("LoadJackpots",nil,function(err,data)
        CC.Player.Inst():SetJackpots(data.Items)
    end)
 
end

function TrailAndroidGameListCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.VipChanged,CC.Notifications.VipChanged)
	CC.HallNotificationCenter.inst():register(self,self.DownloadProcess,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():register(self,self.InitGameJackpots,CC.Notifications.InitGameJackpots)
	CC.HallNotificationCenter.inst():register(self,self.DownloadFail,CC.Notifications.DownloadFail)
    CC.HallNotificationCenter.inst():register(self,self.SetCanClick,CC.Notifications.GameClick)
    CC.HallNotificationCenter.inst():register(self,self.GameUnlockGift,CC.Notifications.OnGameUnlockGift)
    CC.HallNotificationCenter.inst():register(self,self.SetClickState,CC.Notifications.GameClickState)
end

function TrailAndroidGameListCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.VipChanged)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.InitGameJackpots)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadFail)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.GameClick)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnGameUnlockGift)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.GameClickState)
end

function TrailAndroidGameListCtr:GameUnlockGift(param)
    self.view:GameUnlockGift(param.GameId)
end

function TrailAndroidGameListCtr:VipChanged(level)
    self.view:VipChanged(level)
end

function TrailAndroidGameListCtr:DownloadProcess(data)
    self.view:DownloadProcess(data)
end

function TrailAndroidGameListCtr:DownloadFail(id)
    self.view:DownloadFail(id)
end

function TrailAndroidGameListCtr:InitGameJackpots(bState)
    self.view:InitGameJackpots(bState)
end

function TrailAndroidGameListCtr:SetClickState(param)
    local id = param.id
    local state = param.state
    self.view.gameList[id].isClick = state
end

function TrailAndroidGameListCtr:SetCanClick(flag)
    self.view:SetCanClick(flag)
end

function TrailAndroidGameListCtr:Destroy()
	self:UnRegisterEvent()
	self.view = nil;
end

return TrailAndroidGameListCtr