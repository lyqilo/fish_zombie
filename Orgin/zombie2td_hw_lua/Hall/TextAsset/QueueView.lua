local CC = require("CC")

local QueueView = CC.uu.ClassView("QueueView")

--[[ 大状态名称
enum LimitStatus {
      Subscribe = 1; // 预约
      Test = 2; // 测试
      Online = 3; // 正式
}

// 所有排队状态名称
enum QueueStatus {
      NoStart = 1; // 排队未开始
      NoSub = 2; // 未预约
      InGame = 3; // 进入游戏
      InQueue = 4; // 进入排队
}

]]

local LimitStatus = {
    Subscribe = 1,
    Test = 2,
    Online = 3
}

local QueueStatus = {
    NoStart = 1,
    NoSub = 2,
    InGame = 3,
    InQueue = 4
}

function QueueView:ctor(param)
    self.param = param

    self.lastCountdown = nil
    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
end

function QueueView:OnCreate()
    self:InitTextByLanguage()
    self:AddClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
    self:InitUI()
end

function QueueView:InitTextByLanguage()
    self.language = self:GetLanguage()
    self:FindChild("BG/Title/Text").text = self.language.Title
    self:FindChild("BG/Tips").text = string.format(self.language.Tips,self.gameDataMgr.GetGameNameByID(self.param.GameId))
    self:FindChild("BG/Content/Label").text = self.language.QueueTips
    self:FindChild("BG/CannelBtn/Text").text = self.language.CanelBtn
    self:FindChild("BG/Warnning").text = self.language.OtherChoice

    self.NumText = self:FindChild("BG/Content/Num")
    self.TimeText = self:FindChild("BG/Content/Time")
end

function QueueView:AddClickEvent()
    self:AddClick("BG/CannelBtn","CancelQueue")
end

function QueueView:InitUI()
    if self.param.QueueData then
        self:InitState(self.param.QueueData)
    else
        self.viewCtr:ReqState()
    end
    self:StartTimer("Rotate",2,function ()
        self:RunAction(self:FindChild("BG/Content/Image/Image"),{"rotateTo",360,1})
    end,-1)
end

function QueueView:InitState(param)
    if param.Status == LimitStatus.Test then
        if param.QueueStatus == QueueStatus.NoStart then
            --排队未开始
        elseif param.QueueStatus == QueueStatus.NoSub then
            --未预约
        elseif param.QueueStatus == QueueStatus.InGame then
            --进入游戏
            self:EnterGame({GameID = self.param.GameId})
        elseif param.QueueStatus == QueueStatus.InQueue then
            --进入排队
            self.NumText.text = string.format(self.language.QueueNums,param.QueueIndex,param.QueueTotalNum)
            self:SetCountDown(param.QueueEvaluateTime)
        end
    end
end

function QueueView:SetCountDown(time)
    if self.lastCountdown ~= time then
        self.lastCountdown = time
        self.TimeText.text = string.format(self.language.QueueMinTime,self.lastCountdown)
    end
    
	self:StartTimer("QueueReq", 10, function()
		self.viewCtr:ReqState()
    end, -1)
end

function QueueView:EnterGame(data)
    if data.GameID == self.param.GameId then
        CC.HallUtil.EnterGameWithoutCheckGame(self.param.GameId)
        self:ActionOut()
    end
end

function QueueView:CancelQueue()
    self.viewCtr:ReqCannel()
    self:ActionOut()
end

function QueueView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
end

return QueueView