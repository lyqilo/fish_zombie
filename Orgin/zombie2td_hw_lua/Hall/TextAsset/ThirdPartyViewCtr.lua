local CC = require("CC")
local ThirdPartyViewCtr = CC.class2("ThirdPartyViewCtr")

function ThirdPartyViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function ThirdPartyViewCtr:InitVar(view,param)
    self.param = param
    self.view = view
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    self.allGame = self.gameDataMgr.GetThirdGameList() or {}
    self.viewDestroy = false
end

function ThirdPartyViewCtr:OnCreate()
    if table.isEmpty(self.allGame) then
        self:ReqThirdGameInfo()
    else
        self:InitListData()
    end
    self:RegisterEvent()
end

--获取游戏列表数据
function ThirdPartyViewCtr:ReqThirdGameInfo()
    local language = CC.LanguageManager.GetLanguage("L_Common");
    local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetThirdGameInfoUrl()
    CC.uu.Log(url, "ThirdPartyConfig:");

    local doReq;
    doReq = function()
        local www = CC.HttpMgr.Get(url,
        function(www)
            local data = Json.decode(www.downloadHandler.text)
            log(CC.uu.Dump(data, "data++++++"))
            self.gameDataMgr.SetThirdGameList(data)
            if self.viewDestroy then return end
            self.allGame = self.gameDataMgr.GetThirdGameList()
            self:InitListData()
            -- self:ReqGameGroupInfo()
            CC.uu.Log("WebUrlManager.ThirdPartyConfig success")
        end,
        function()
            CC.uu.Log("WebUrlManager.ThirdPartyConfig failed")
            local tips = CC.ViewManager.ShowMessageBox(language.tip5,
            function () doReq() end)
            tips:SetOneButton();
        end)
    end
    doReq();
end

function ThirdPartyViewCtr:InitListData()
    local list = {}
    for _,v in pairs(self.allGame) do
        local id = v.GameID
        table.insert(list, id)
    end
    table.sort(list, function(a,b) return a < b end )
    self.view:InitGameList(list)
end

function ThirdPartyViewCtr:GetInfoByID(id)
    return self.allGame[id]
end

function ThirdPartyViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.DownloadProcess,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():register(self,self.DownloadFail,CC.Notifications.DownloadFail)
    CC.HallNotificationCenter.inst():register(self,self.SetCanClick,CC.Notifications.GameClick)
    CC.HallNotificationCenter.inst():register(self,self.GameUnlockGift,CC.Notifications.OnGameUnlockGift)
    CC.HallNotificationCenter.inst():register(self,self.SetClickState,CC.Notifications.GameClickState)
end

function ThirdPartyViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadFail)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.GameClick)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnGameUnlockGift)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.GameClickState)
end

function ThirdPartyViewCtr:GameUnlockGift(param)
    self.view:GameUnlockGift(param.GameId)
end

function ThirdPartyViewCtr:DownloadProcess(data)
    self.view:DownloadProcess(data)
end

function ThirdPartyViewCtr:DownloadFail(id)
    self.view:DownloadFail(id)
end

function ThirdPartyViewCtr:SetClickState(param)
    local id = param.id
    local state = param.state
    --设置点击状态时，可能还在执行携程创建游戏入口，会导致列表中还没有相应游戏，跳过设置状态不影响后续功能
    if self.view.gameList[id] then
        self.view.gameList[id].isClick = state
    end
end

function ThirdPartyViewCtr:SetCanClick(flag)
    self.view:SetCanClick(flag)
end

function ThirdPartyViewCtr:Destroy()
	self:UnRegisterEvent()
    self.viewDestroy = true
	self.view = nil;
end

return ThirdPartyViewCtr