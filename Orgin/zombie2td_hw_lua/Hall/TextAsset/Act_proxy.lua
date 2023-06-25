
local CC = require("CC")
local Act_proxy = CC.uu.ClassView("Act_proxy")

function Act_proxy:ctor(content,language)
	self.content = content
	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
	self.language = language
end

function Act_proxy:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:InitProxy()
end

--高V系统
function Act_proxy:InitProxy()
	self:FindChild("BG/Btn/Text").text = self.language.btn_proxy
	self:FindChild("BG/Blind/Text").text = self.language.proxy_proxyed
	self.proxyBtn = self:FindChild("BG/Btn")
	self.inputField = self:FindChild("BG/InputField")
	self.Blind = self:FindChild("BG/Blind")
	self.linkText = self:FindChild("BG/Url"):GetComponent("RichText")
	self.linkText.onLinkClick = function (url)
		Client.OpenURL(url)
	end
	self:AddClick("BG/Btn","BindAgent")
	if CC.Player.Inst():GetSelfInfoByKey("EPC_AgentLevel") > 0 then
		self.proxyBtn:SetActive(false)
		self.Blind:SetActive(true)
		self.inputField:SetActive(false)
	else
		self.proxyBtn:SetActive(true)
		self.inputField:SetActive(true)
		self.Blind:SetActive(false)
	end
	if CC.Player.Inst():GetSelfInfoByKey("EPC_AgentLevel") == 2 or CC.Player.Inst():GetSelfInfoByKey("EPC_AgentLevel") == 3 then
		if not self.switchDataMgr.GetSwitchStateByKey("AgentUnlock") then
			self:FindChild("BG/Url"):SetActive(true)
		else
			self:AgentInfo()
		end
	else
		self:FindChild("BG/Url"):SetActive(false)
	end
end

function Act_proxy:AgentInfo()
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
					self.Blind:SetActive(true)
					self.inputField:SetActive(false)
				end
				if self.switchDataMgr.GetSwitchStateByKey("AgentUnlock") then
					if not data.result.data.IsNewServer then
						self:FindChild("BG/Url"):SetActive(true)
					end
				end
			end,
			function ()
				local tips = CC.ViewManager.ShowMessageBox(self.language.timeout_tip,
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

function Act_proxy:BindAgent()
	--android模拟器不能绑定高V
	if Client.IsEmulator() then
		CC.ViewManager.ShowTip(self.language.notice_proxy_fail);
		return false 
	end
	CC.ViewManager.ShowLoading()
	local agentCode = self:FindChild("BG/InputField"):GetComponent("InputField").text
	local url = self.WebUrlDataManager.GetAgentBindUrl(agentCode)
	log(url)
	local blindProxy = nil
	blindProxy = function ()
		CC.HttpMgr.Get(url,
		function (www)
			local data = Json.decode(www.downloadHandler.text)
			if data.result.value == "0" then
				CC.ViewManager.ShowTip(data.result.message)
				local data = {
						Items = {
							{
								ConfigId = CC.shared_enums_pb.EPC_AgentLevel,
								Count = 4,
							}}
				}
				CC.Player.Inst():ChangeProp(data);
				self:AgentInfo()
				CC.ViewManager.CloseLoading()
			else
				CC.ViewManager.ShowTip(data.result.message)
				CC.ViewManager.CloseLoading()
			end
		end,
		function ()
			CC.ViewManager.CloseLoading()
			local tips = CC.ViewManager.ShowMessageBox(self.language.timeout_tip,
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

function Act_proxy:OnDestroy()
end

return Act_proxy