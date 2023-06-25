local CC = require("CC")

local SubscribeView = CC.uu.ClassView("SubscribeView")

--[[ 大状态名称
enum LimitStatus {
      Subscribe = 1; // 预约
      Test = 2; // 测试
      Online = 3; // 正式
}

// 所有预约状态名称
enum SubStatus {
      SubscribeNoStart = 1; // 预约未开始
      SubscribeIng = 2; // 可预约
      SubscribeEd = 3; // 已预约
      SubscribeRepeat = 4; // 重复预约
      SubscribeOver = 5; //预约满额
      SubscribeEnd = 6; //预约已結束

// 所有排队状态名称
enum QueueStatus {
      NoStart = 1; // 排队未开始
      NoSub = 2; // 未预约
      InGame = 3; // 进入游戏
      InQueue = 4; // 进入排队
}
}]]

local LimitStatus = {
    Subscribe = 1,
    Test = 2,
    Online = 3
}

local SubStatus = {
    SubscribeNoStart = 1,
    SubscribeIng = 2,
    SubscribeEd = 3,
    SubscribeRepeat = 4,
    SubscribeOver = 5,
    SubscribeEnd = 6,
}

local QueueStatus = {
    NoStart = 1,
    NoSub = 2,
    InGame = 3,
    InQueue = 4
}

function SubscribeView:ctor(param)
    self.param = param
    self.gameID = self.param.currentView
    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
end

function SubscribeView:OnCreate()
    self:InitTextByLanguage()
    self:InitUI()
    self:AddClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
end

function SubscribeView:InitTextByLanguage()
    self.language = self:GetLanguage()
    self:FindChild("BG/Title/Text").text = self.language.Title
    self:FindChild("BG/Content/Text").text = self.language.SubscribeVIP
    self:FindChild("BG/SubscribeBtn/Text").text = self.language.SubscribeBtn
    self:FindChild("BG/CompletedBtn/Text").text = self.language.SubscribeCompleted
    self:FindChild("BG/Warnning").text = self.language.SubscribeTips
end

function SubscribeView:InitUI()
    local preName = "yxrk_"..self.gameID
    local icon = self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].path
    self:SetImage(self:FindChild("BG/Content/Icon"),icon)
end

function SubscribeView:InitGameInfo(info)
    if info then
        self:FindChild("BG/Tips").text = string.format(self.language.Tips,info.Name)
    else
        self:FindChild("BG/Tips").text = string.format(self.language.Tips," ")
    end
end

function SubscribeView:AddClickEvent()
    self:AddClick("BG/SubscribeBtn",function () self.viewCtr:ReqSubscribe() end)
    self:AddClick("BG/CloseBtn",function () self:ActionOut() end)
    self:AddClick("Mask",function () self:ActionOut() end)
end

function SubscribeView:InitState(param)
    --Status 1  为预约模式
    if param.Status == LimitStatus.Subscribe then
        if param.SubscribeStatus == SubStatus.SubscribeNoStart then
            --预约未开始
            self:FindChild("BG/StateTips").text = self.language.SubscribeNoStart
            self:FindChild("BG/StateTips"):SetActive(true)
        elseif param.SubscribeStatus == SubStatus.SubscribeIng then
            --预约进行中
            self:FindChild("BG/SubscribeBtn"):SetActive(true)
        elseif param.SubscribeStatus == SubStatus.SubscribeEd then
            --已预约
            self:FindChild("BG/CompletedBtn"):SetActive(true)
        elseif param.SubscribeStatus == SubStatus.SubscribeRepeat then
        --重复预约
        elseif param.SubscribeStatus == SubStatus.SubscribeOver then
            --预约额满
            self:FindChild("BG/StateTips").text = self.language.SubscribeEnd
            self:FindChild("BG/StateTips"):SetActive(true)
        elseif param.SubscribeStatus == SubStatus.SubscribeEnd then
            --预约已结束
            self:FindChild("BG/StateTips").text = self.language.SubscribeEnd
            self:FindChild("BG/StateTips"):SetActive(true)
        end
    elseif param.Status == LimitStatus.Test and (param.SubscribeStatus == QueueStatus.InGame or param.SubscribeStatus == QueueStatus.InQueue) then
        --可以请求进入游戏了
        self:FindChild("BG/StateTips").text = self.language.QueueIng
        self:FindChild("BG/StateTips"):SetActive(true)
        self:RefreshBtn()
    else
        --预约已结束
        self:FindChild("BG/StateTips").text = self.language.SubscribeEnd
        self:FindChild("BG/StateTips"):SetActive(true)
    end
end

function SubscribeView:RefreshUI(status)
    if status == SubStatus.SubscribeEd or status == SubStatus.SubscribeRepeat then
        self:FindChild("BG/SubscribeBtn"):SetActive(false)
        self:FindChild("BG/CompletedBtn"):SetActive(true)
    elseif status == SubStatus.SubscribeOver or status == SubStatus.SubscribeEnd then
        self:FindChild("BG/SubscribeBtn"):SetActive(false)
        self:FindChild("BG/CompletedBtn"):SetActive(false)
        self:FindChild("BG/StateTips").text = self.language.SubscribeEnd
        self:FindChild("BG/StateTips"):SetActive(true)
    end
end

function SubscribeView:RefreshBtn()
    if not CC.HallUtil.CheckShow(self.gameID) then
        local btn = self:FindChild("BG/Go")
        local richText = btn:GetComponent("RichText")
        richText.text = self.language.GoToGame
        self:AddClick(btn,"EnterGame")
        btn:SetActive(true)
    end
end

function SubscribeView:EnterGame()
    CC.HallUtil.CheckAndEnter(self.gameID)
    self:ActionOut()
end

function SubscribeView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return SubscribeView