
local CC = require("CC")
local WebServiceView = CC.uu.ClassView("WebServiceView")

function WebServiceView:ctor()
	self.webUrl = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebServiceUrl();
end

function WebServiceView:OnCreate()
	CC.uu.Log("open WebServiceView...")
	self:InitView()
	self:InitTextByLanguage();
	-- self:RegisterEvent();
end

function WebServiceView:InitView()
	--初始化界面
	self.webview = self:SubAdd("Frame/WebView", WebViewObject)
    self.webview:Init(nil,nil,nil,nil,nil, nil, true)

	self.webview:LoadURL(self.webUrl)
	self.webview:SetVisibility(true)
	--根据分辨率设置显示尺寸
	local scale = math.min(Screen.width/1280, Screen.height/720)
	local offset = math.ceil(scale * 100)
	self.webview:SetMargins(0, offset, 0, 0, false);
	-- local scale = math.min(Screen.width/1280, Screen.height/720)
	-- local offset = math.ceil(scale * 100)
	-- self.webview:SetMargins(offset, 0, offset, 0, false);

	-- CC.SubGameInterface.SetFloatBtnGroupState({"1"})
	-- CC.SubGameInterface.CreateFloatBtnGroup(1);
	self:AddClick("Frame/BtnExit", "OnClickExit", nil, true)

	self:DelayRun(2, function() self:FindChild("Frame"):SetActive(true)  end)
end

function WebServiceView:InitTextByLanguage()

end

function WebServiceView:OnClickExit()
	self:SetCanClick(false);
	CC.uu.Log("WebServiceView OnClickExit......")
	-- CC.SubGameInterface.CreateFloatBtnGroup(0);
	self.webview:SetVisibility(false);
	self:DelayRun(0.5, function()
		CC.HallUtil.RotateCamera()
		self:Destroy()
	end)

end

-- function WebServiceView:RegisterEvent()

-- 	CC.HallNotificationCenter.inst():register(self,self.OnClickExit, CC.Notifications.OnClickFloatActionButton);
-- end

-- function WebServiceView:UnRegisterEvent()

-- 	CC.HallNotificationCenter.inst():unregisterAll(self);
-- end

function WebServiceView:ActionIn()

end

function WebServiceView:ActionOut()

end

function WebServiceView:OnDestroy()

	self.webview.enabled = false
	self.webview = nil
	-- self:UnRegisterEvent();
end

return WebServiceView