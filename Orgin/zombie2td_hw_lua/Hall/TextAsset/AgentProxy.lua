local CC = require("CC")
local AgentProxy = CC.uu.ClassView("AgentProxy")

function AgentProxy:ctor(param)
	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");
	self.param = param or {}
end

function AgentProxy:OnCreate()
	self.proxyBtn = self:FindChild("Btn")
	self.inputField = self:FindChild("InputField")
	self.Blind = self:FindChild("Blind")
	self:AddClick("Btn","BindAgent")
	self:AddClick("BtnClose","ActionOut")
	if self.agentDataMgr.GetAgentSatus() then
		self.proxyBtn:SetActive(false)
		self.inputField:SetActive(false)
		self.Blind:SetActive(true)
	else
		self.proxyBtn:SetActive(true)
		self.inputField:SetActive(true)
		self.Blind:SetActive(false)
	end
	self:InitTextLanguage()
	CC.Sound.StopEffect()
    CC.Sound.PlayHallEffect("agentBinding.ogg")
end

function AgentProxy:InitTextLanguage()
	self:FindChild("title/Text").text = self.language.proxyTitle
	self:FindChild("DesText").text = self.language.proxyDesText
	self:FindChild("PmcDes").text = self.language.proxyTitle
	self:FindChild("Blind/Text").text = self.language.proxyBlindText
	self:FindChild("Btn/Text").text = self.language.proxyBtnText
	self:FindChild("TipText").text = self.language.proxyTipText
end

function AgentProxy:AgentInfo()
	local url = self.WebUrlDataManager.GetAgentInfoUrl()
	log(url)
	local checkProxyInfo = nil
	checkProxyInfo = function ()
		CC.HttpMgr.Get(url,
			function (www)
				local data = Json.decode(www.downloadHandler.text)
				if data.result.value == "1" then
					self.proxyBtn:SetActive(true)
					self.inputField:SetActive(true)
					self.Blind:SetActive(false)
				else
					self.proxyBtn:SetActive(false)
                    self.inputField:SetActive(false)
					self.Blind:SetActive(true)
					if CC.HallUtil.CheckGuest() then
						local box = CC.ViewManager.ShowMessageBox(self.language.guestBlindTip)
						box:SetOneButton()
					end
				end
			end,
			function ()
				CC.ViewManager.ShowMessageBox(self.language.timeout_tip,
					function ()
						checkProxyInfo()
					end,
					function ()
					end
				)
			end
		)
	end
	checkProxyInfo()
end

function AgentProxy:BindAgent()
	--android模拟器不能绑定高V
	if Client.IsEmulator() then
		CC.ViewManager.ShowTip(self.language.notice_proxy_fail);
		return false
	end
	CC.ViewManager.ShowLoading()
	local agentCode = self.inputField:GetComponent("InputField").text
	local url = self.WebUrlDataManager.GetAgentBindUrl(agentCode)
	log(url)
	local blindProxy = nil
	blindProxy = function ()
		CC.HttpMgr.Get(url,
		function (www)
			local data = Json.decode(www.downloadHandler.text)
			if data.result.value == "0" then
				CC.ViewManager.ShowTip(data.result.message)
				local info = {
						Items = {
							{
								ConfigId = CC.shared_enums_pb.EPC_AgentLevel,
								Count = 4,
							}}
				}
				CC.Player.Inst():ChangeProp(info);
				self:AgentInfo()
				CC.ViewManager.CloseLoading()
			else
				CC.ViewManager.ShowTip(data.result.message)
				CC.ViewManager.CloseLoading()
			end
		end,
		function ()
			CC.ViewManager.CloseLoading()
			CC.ViewManager.ShowMessageBox(self.language.timeout_tip,
				function ()
					blindProxy()
				end,
				function ()
				end
			)
		end
	)
	end
	blindProxy()
end

function AgentProxy:OnDestroy()
	CC.Sound.StopEffect()
	if self.param.callback then
		self.param.callback()
	end
end

return AgentProxy