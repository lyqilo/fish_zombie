local CC = require("CC")
local LoginQueueView = CC.uu.ClassView("LoginQueueView")

function LoginQueueView:ctor(param)
	self:InitVar(param);
end

function LoginQueueView:InitVar(param)
    self.param = param or {}
    self.language = self:GetLanguage()
end

function LoginQueueView:OnCreate()
    self:RegisterEvent()
    self:InitView()
    
    self:StartTimer("Rotate",2,function ()
        self:RunAction(self:FindChild("BG/Content/Image/Image"),{"rotateTo",360,1})
    end,-1)

    --定时请求（心跳保活）
    if self.param.reqSucc then
        self:StartTimer("heartbeat",10,function()
            CC.Request("ReqQueueHeartbeat")
        end,-1)
    end

    --倒计时
    local timeTex = self:FindChild("BG/Content/Time")
    self.time = self.param.result.QueueTime
    timeTex.text = string.format(self.language.timeTip,CC.uu.TicketFormat(self.time))
    self:StartTimer("timetime",1,function()
        if self.time > 0 then
            timeTex.text = string.format(self.language.timeTip,CC.uu.TicketFormat(self.time))
            self.time = self.time -1
            if self.time <= 0 and self.param.enterFun then
                if self.param.reqSucc then
                    CC.Request("ReqQueuePush")
                end
                self.param.enterFun()
                self:ActionOut()
            end
        end
    end,-1)
end

function LoginQueueView:InitView()
    self:FindChild("BG/Title/Text").text = self.language.title
    self:FindChild("BG/Tips").text = self.language.waitTip
    self:FindChild("BG/Btn/Text").text = self.language.exitTip
    self:FindChild("BG/Content/SystemTip").text = self.language.systemTip
    self:FindChild("BG/Content/Rank").text = string.format(self.language.rankTip,self:RankDeal())

    self:AddClick("BG/Btn","OnExit",nil,true)
    self:AddClick("Mask","OnExit")
end

function LoginQueueView:RankDeal(rank)
    local num = 99999
    local rank = rank or self.param.result.Rank
    if rank < 1e1 then
        num = "0000"..rank
    elseif rank < 1e2 then
        num = "000"..rank
    elseif rank < 1e3 then
        num = "00"..rank
    elseif rank < 1e4 then
        num = "0"..rank
    elseif rank < 1e5 then
        num = rank
    end
    return num
end

function LoginQueueView:OnExit()
    CC.ViewManager.ShowMessageBox(self.language.affirmExit,function()
        if self.param.reqSucc then
            CC.Request("ReqQueuePush")
        end
        if self.param.exitFun then
            self.param.exitFun()
        end
        self:ActionOut()
    end):ConvertBtnPos()
end

function LoginQueueView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnDisconnectDeal,CC.Notifications.OnDisconnect)
    CC.HallNotificationCenter.inst():register(self,self.OnQueueDataResp,CC.Notifications.NW_ReqQueueData)
    CC.HallNotificationCenter.inst():register(self,self.OnReqQueueHeartbeatResp,CC.Notifications.NW_ReqQueueHeartbeat)
end

function LoginQueueView:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function LoginQueueView:OnDisconnectDeal()
    if self.param.exitFun then
        self.param.exitFun()
    end
    self:ActionOut()
    CC.ViewManager.ShowTip(self.language.notNetWork)
end

function LoginQueueView:OnResume()
    if self.param.reqSucc then
        CC.Request("ReqQueueData")
    end
end

function LoginQueueView:OnQueueDataResp(err,data)
    if err == 0 then
        self.time = data.QueueTime
        self:FindChild("BG/Content/Rank").text = string.format(self.language.rankTip,self:RankDeal(data.Rank))
    end
end

function LoginQueueView:OnReqQueueHeartbeatResp(err,data)
    if err ~= 0 then
        if err == CC.shared_en_pb.InvalidAuthorization then
            --账号在别的设备登录，这时服务器还不会推送踢人，这里收到错误码就弹窗回到登录
            if self.param.exitFun then
                self.param.exitFun()
            end
            self:Destroy()
            CC.ViewManager.ShowMessageBox(CC.LanguageManager.GetLanguage("L_MessageBox").replaceAccountTip):SetOneButton()
        end
    end
end

function LoginQueueView:ActionIn()
	self:SetCanClick(false)
    self:FindChild("BG").transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self:FindChild("BG"), {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
    CC.Sound.PlayHallEffect("click_boardopen");
end

function LoginQueueView:ActionOut()
	self:SetCanClick(false);
    self:RunAction(self:FindChild("BG"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})
end

function LoginQueueView:OnDestroy()
	self:UnRegisterEvent()
end

return LoginQueueView    