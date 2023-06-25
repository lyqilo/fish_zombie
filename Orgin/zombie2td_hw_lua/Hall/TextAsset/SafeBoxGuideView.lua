local CC = require("CC")
local SafeBoxGuideView = CC.uu.ClassView("SafeBoxGuideView")

function SafeBoxGuideView:ctor(param)
	self:InitVar(param);
end

function SafeBoxGuideView:InitVar(param)
    self.param = param or {}
    self.passWord = CC.Player.Inst():GetSafeCodeData().SafeStatus == 1
    --请求设置完成引导
    CC.Request("ReqCofferGuide",nil,function() end,function(err,data) 
        --请求超时再请求一次
        if err == CC.NetworkHelper.DelayErrCode then
            CC.Request("ReqCofferGuide") 
        end
    end)
    CC.Player.Inst():GetSafeCodeData().GuideStatus = true
end

function SafeBoxGuideView:OnCreate()
    local lan = CC.LanguageManager.GetLanguage("L_SafeBoxView")
    self:FindChild("Bg/2/Bottom/Text").text = lan.guideStr1
    self:FindChild("Bg/2/Bottom/Continue/Text").text = lan.continue
    self:FindChild("Bg/3/Bottom/Text").text = self.passWord and lan.guideStr2 or string.format("%s\n%s",lan.guideStr2,lan.guideStr3)
    self:FindChild("Bg/3/Bottom/Continue/Text").text = self.passWord and lan.continue or lan.toSet

    self:AddClick(self:FindChild("Bg/1"),function() 
        self:FindChild("Bg/1"):SetActive(false) 
        self:FindChild("Bg/2"):SetActive(true) 
    end)
    self:AddClick(self:FindChild("Bg/2/Bottom/Continue"),function() 
        self:FindChild("Bg/2"):SetActive(false)
        self:FindChild("Bg/3"):SetActive(true)
    end)
    self:AddClick(self:FindChild("Bg/3"),function() 
        self:Destroy()
        if not self.passWord then
            CC.ViewManager.Open("SetSafePassWordView")
        end
    end)
end

function SafeBoxGuideView:ActionIn()
end

function SafeBoxGuideView:ActionOut()
end

return SafeBoxGuideView    