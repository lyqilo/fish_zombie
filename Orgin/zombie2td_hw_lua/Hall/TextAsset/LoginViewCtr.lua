local CC = require("CC")
local AsynCall = require("Common/AsynCall")
local LoginViewCtr = CC.class2("LoginViewCtr")

function LoginViewCtr:ctor(view, loginType)
	self:InitVar(view, loginType)
end

function LoginViewCtr:InitVar(view, loginType)
	self.loginType = loginType

	self.view = view

	--socket连接是否建立
	self.isOpenSocket = false

	self.webUrlData = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")

	self.noticeData = CC.DataMgrCenter.Inst():GetDataByKey("NoticeData")

	self.gameData = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
	-- self.noviceDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr")

	self.loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine")

	self.isAutoLogin = true

	self.isMaintenance = false

	self.deviceId = CC.Platform.GetDeviceId()

	self.language = self.view:GetLanguage()
	--协议回包计数,用来计算loading进度
	self.networkRspCount = 0
	--保存上一次的计数
	self.lastNetworkRspCount = 0
	--登录流程串联协议数
	self.totalRspCount = 5
	--时间偏移量
	self.deltaTime = 0
	--等待时间
	self.dalayTime = 0
	--当前进度百分比
	self.percent = 0
	--保存上一次百分比计数
	self.lastPercent = 0

	self.clickCount = {[1] = 0, [2] = 0}
end

function LoginViewCtr:OnCreate()
	--返回登录界面，关闭跑马灯，喇叭，侧边弹窗,所有拉回游戏保存ID置空
	CC.ViewManager.SetNeedToGoGameId(nil)
	CC.ViewManager.SetExitToGuideId(nil)
	CC.ViewManager.CloseTip()
	CC.ChatManager.SetSpeakBordState(false)
	CC.ChatManager.SetNoticeBordState(false)
	CC.ViewManager.SetRewardNoticeView(false, false, 0)
	CC.ViewManager.SetArenaNoticeView(false, false, 0)
	CC.ReportManager.SetDot("LOGINVIEW")
	self:SetBtnState(false)

	self:PreloadAssets()

	self:SetNotice()

	self:StartUpdate()

	self:RegisterEvent()

	self:ReqGameInfo()

	-- self:SetLocalGameVersion();

	if self.loginType == self.loginDefine.LoginType.Common then
		--请求大厅服ip、验证服ip
		CC.WebUrlManager.InitServerAddress()
	elseif self.loginType == self.loginDefine.LoginType.Logout then
		self:SetBtnState(true)
		self.view:ShowNotice(true)
	elseif self.loginType == self.loginDefine.LoginType.AutoFacebook then
		self:OnFacebookLogin()
	elseif self.loginType == self.loginDefine.LoginType.AutoLine then
		self:OnLineLogin()
	elseif self.loginType == self.loginDefine.LoginType.Reconnect then
		local doFunc = function()
			CC.WebUrlManager.InitServerAddress()
		end
		CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").SetOrgUrlPrefix(CC.UrlConfig.EntryUrl.Release)
		CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").SetIsUseBackup(false)
		CC.WebUrlManager.ReqEntryConfig(doFunc)
	elseif self.loginType == self.loginDefine.LoginType.Kickedout then
		local language = CC.LanguageManager.GetLanguage("L_MessageBox")
		local box = CC.ViewManager.ShowMessageBox(language.replaceAccountTip)
		box:SetOneButton()

		self:SetBtnState(true)
		self.view:ShowNotice(true)
	end

	CC.LocalGameData.SaveIMEICode(self.deviceId)
end

function LoginViewCtr:PreloadAssets()
	--预加载进入大厅会默认创建的界面以及常用界面
	local resDefine = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine")
	local preloadAssets = resDefine.PreloadAssets
	local tempPreloadAssets = {}
	for orgAbName, fileNames in pairs(preloadAssets) do
		for _, v in pairs(fileNames) do
			local abName = resDefine[orgAbName][v] or orgAbName
			if not tempPreloadAssets[abName] then
				tempPreloadAssets[abName] = {}
			end
			table.insert(tempPreloadAssets[abName], v)
		end
	end

	for abName, fileName in pairs(tempPreloadAssets) do
		ResMgr.LoadAssetsAsync(
			abName,
			fileName,
			function()
				-- CC.uu.Log(abName.."资源异步预加载完成..")
			end
		)
	end
end

function LoginViewCtr:SetNotice()
	if not self.noticeData.GetContent() then
		local url = self.webUrlData.GetNoticeUrl()
		local www =
			CC.HttpMgr.Get(
			url,
			function(www)
				if CC.uu.IsNil(self.view.transform) then
					return
				end
				local table = Json.decode(www.downloadHandler.text)
				if table.status == 1 then
					self.noticeData.SetNotice(table)
					self.view:RefreshNotice(table)
					if table.IsUphold == "True" then
						self.isAutoLogin = false
						self.isMaintenance = true
						self.view:UnderMaintenance()
						CC.LocalGameData.SetNoticeVersion(table.Version)
						return
					elseif table.Version ~= CC.LocalGameData.GetNoticeVersion() or CC.LocalGameData.GetNoticeVersion() == nil then
						self.isAutoLogin = false
						self.view:ShowNotice(true)
						CC.LocalGameData.SetNoticeVersion(table.Version)
					else
						self.view:ShowNotice(false)
					end
				else
					local table = {}
					table.Title = self.language.noticeTitle
					table.Content = self.language.noticeContent
					self.view:RefreshNotice(table)
					self.view:ShowNotice(false)
				end
			end
		)
	else
		local table = {}
		table.Title = self.noticeData.GetTitle()
		table.Content = self.noticeData.GetContent()
		self.view:RefreshNotice(table)
	end
end

--获取游戏列表数据
function LoginViewCtr:ReqGameInfo()
	if self.gameData.IsInit() then
		return
	end
	local language = CC.LanguageManager.GetLanguage("L_Common")
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetGameInfoUrl()
	CC.uu.Log(url, "reqGameInfoUrl:")

	local doReq
	doReq = function()
		local www =
			CC.HttpMgr.Get(
			url,
			function(www)
				local data = Json.decode(www.downloadHandler.text)
				self.gameData.InitGameData(data)
				self:ReqGameGroupInfo()
				self:ReadyToEnter()
				CC.uu.Log("WebUrlManager.ReqGroupListInfo success")
			end,
			function()
				CC.uu.Log("WebUrlManager.ReqGroupListInfo failed")
				local tips =
					CC.ViewManager.ShowMessageBox(
					language.tip5,
					function()
						doReq()
					end
				)
				tips:SetOneButton()
			end
		)
	end
	doReq()
end

function LoginViewCtr:ReqGameGroupInfo()
	--先下载并缓存所有游戏版本号
	local gameList = self.gameData.GetGameList()
	for _, gameId in pairs(gameList) do
		CC.HallUtil.ReqGameGroupConfig(gameId)
	end
end

function LoginViewCtr:StartUpdate()
	UpdateBeat:Add(self.Update, self)
end

function LoginViewCtr:StopUpdate()
	UpdateBeat:Remove(self.Update, self)
end

function LoginViewCtr:Update()
	self.dalayTime = self.dalayTime + Time.deltaTime
	if self.dalayTime >= 1 then
		self.dalayTime = 0
	end

	if self.percent >= 100 then
		return
	end

	if self.lastNetworkRspCount ~= self.networkRspCount then
		--每一次收到协议都重新跑差值
		self.lastNetworkRspCount = self.networkRspCount
		self.lastPercent = self.percent
		self.deltaTime = 0
	end
	self.deltaTime = self.deltaTime + Time.deltaTime
	self.percent =
		math.ceil(Mathf.Lerp(self.lastPercent, self.networkRspCount / self.totalRspCount * 100, self.deltaTime * 2))
	self.view:RefreshUI({percent = self.percent})
end

function LoginViewCtr:RegisterEvent()
	--大厅服ip获取通知
	CC.HallNotificationCenter.inst():register(self, self.OnOpenSocket, CC.Notifications.ReqServerAddress)
	--Socket建立通知
	CC.HallNotificationCenter.inst():register(self, self.OnSocketConnect, CC.Notifications.OnConnectServer)
	--登录连接失败通知
	CC.HallNotificationCenter.inst():register(self, self.OnSocketStop, CC.Notifications.OnLoginDisconnect)
	--获取手机验证码
	CC.HallNotificationCenter.inst():register(self, self.GetTokenByPhoneRsp, CC.Notifications.NW_ReqGetTokenByPhone)
	--校驗
	CC.HallNotificationCenter.inst():register(self, self.VerifyPhoneTokenRsp, CC.Notifications.NW_ReqVerifyPhoneToken)
	--登录
	CC.HallNotificationCenter.inst():register(self, self.LoginByPhoneRsp, CC.Notifications.NW_ReqLoginByPhone)

	CC.HallNotificationCenter.inst():register(self, self.RefreshBtnService, CC.Notifications.HallFunctionUpdate)
end

function LoginViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function LoginViewCtr:SetLocalGameVersion()
	-- local InPackGameID = AppInfo.InPackGameID
	-- local localVersion = CC.LocalGameData.GetGameVersion(InPackGameID)
	-- if localVersion == 0 then
	-- 	CC.LocalGameData.SetGameVersion(InPackGameID,1)
	-- end
end

function LoginViewCtr:OnRequestVersionInfo()
	--获取强制更新版本号信息
	local reqFunc
	reqFunc = function()
		CC.Request(
			"GetAllResourceVersionInfo",
			nil,
			function(err, result)
				self.gameData.SetForceUpdateVersion(result.Items)
			end,
			function(err, result)
				-- reqFunc();
				CC.uu.Log("LoginViewCtr: OnRequestVersionInfo failed")
			end
		)
	end
	reqFunc()
end

function LoginViewCtr:OnOpenSocket()
	--连接socket
	CC.Network.Start()
end

function LoginViewCtr:OnSocketConnect()
	CC.uu.Log("LoginViewCtr: Socket Connet")
	self.isOpenSocket = true
	self:ReadyToEnter()
	-- self:OnRequestVersionInfo();
end

function LoginViewCtr:OnSocketStop()
	CC.ViewManager.ShowMessageBox(
		self.language.connectFail,
		function()
			local doFunc = function()
				CC.WebUrlManager.InitServerAddress()
			end
			CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").SetOrgUrlPrefix(CC.UrlConfig.EntryUrl.Release)
			CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").SetIsUseBackup(false)
			CC.WebUrlManager.ReqEntryConfig(doFunc)
		end,
		function()
			self:SafeQuit()
		end
	)
end

--退出游戏
function LoginViewCtr:SafeQuit()
	if Application.isEditor then
		self:SetBtnState(true)
	else
		Application.Quit()
	end
end

function LoginViewCtr:ReadyToEnter()
	if not self.isAutoLogin then
		if self.isMaintenance then
			self:SetBtnState(false)
		else
			self:SetBtnState(true)
		end
		return
	end

	if self.gameData.IsInit() and self.isOpenSocket then
		--默认走上次的登录方式，不显示按钮
		self.view:ShowNotice(false)
		local curLoginWay = CC.Player.Inst():GetCurLoginWay()
		CC.uu.Log("curLoginWay:" .. tostring(curLoginWay))
		if curLoginWay == self.loginDefine.LoginWay.Guest then
			--默认游客登录
			self:OnGuestLogin()
		elseif curLoginWay == self.loginDefine.LoginWay.Facebook then
			--默认FACEBOOK登录
			self:OnFacebookLogin()
		elseif curLoginWay == self.loginDefine.LoginWay.Line then
			--默认Line登录
			self:OnLineLogin()
		elseif curLoginWay == self.loginDefine.LoginWay.OPPO then
			self:OnOppoLogin()
		else
			--第一次登录没有默认登录方式，让玩家自己选择
			self:SetBtnState(true)
			self.view:ShowNotice(true)
		end
	end
end

function LoginViewCtr:OnGuestLogin()
	--游客登录
	self:SetBtnState(false)
	self.view:RefreshUI({showPercent = true, percent = 0})

	local data = {}
	data.User = self.deviceId
	data.Pwd = self.deviceId
	data.Imei = self.deviceId
	data.OS = self:GetOSEnum()
	CC.Request(
		"Login",
		data,
		function(err, result)
			CC.uu.Log("Request.Login success")
			CC.ReportManager.SetDot("GUESTLOGINSUCC")
			CC.Player.Inst():SetLoginInfo(result)
			--游客登录置空第三方登录token
			CC.Player.Inst():SetThirdPartyToken()
			self:ReqestQueue(result, nil, self.loginDefine.LoginWay.Guest, CC.shared_enums_pb.RT_Guest)
		end,
		function(err)
			CC.uu.Log("Request.Login fail")
			CC.ReportManager.SetDot("GUESTLOGINFAIL")
			--玩家被封号,ip限制
			if err == CC.shared_en_pb.PlayerIsClosed or err == CC.shared_en_pb.LimitIpAddress then
				self:SetBtnState(true)
			else
				--其他错误返回走注册流程
				self:Register()
			end
		end
	)
end

function LoginViewCtr:OnAppleLogin()
	--苹果登录走游客登录
	self:SetBtnState(false)
	self.view:RefreshUI({showPercent = true, percent = 0})

	local callback = function(result)
		CC.uu.Log(result, "appleLogin callback:")
		local data = Json.decode(result)
		if data.code == 0 then
			CC.ReportManager.SetDot("APPLELOGINSUCC")
			self:OnGuestLogin()
		else
			CC.uu.Log(data.msg, "AppleLogin failed msg:")
			CC.ReportManager.SetDot("APPLELOGINFAIL")
			self:SetBtnState(true)
		end
	end
	CC.ApplePayPlugin.Login(callback)
end

function LoginViewCtr:Register()
	local data = {}
	data.User = self.deviceId
	data.Pwd = self.deviceId
	data.Imei = self.deviceId
	data.OS = self:GetOSEnum()
	CC.Request(
		"Register",
		data,
		function(err, data)
			CC.uu.Log("Request.Register success")
			CC.ReportManager.SetDot("GUESTREGISUCC")
			--保存注册信息
			self:SaveRegister(self.loginDefine.LoginWay.Guest)
			--注册成功后重新登录
			self:OnGuestLogin()
		end,
		function(err)
			CC.uu.Log("Request.Register failed")
			CC.ReportManager.SetDot("GUESTREGIFAIL")
			if err ~= CC.shared_en_pb.LimitIpAddress then
				CC.ViewManager.ShowTip(self.language.guessLoginFailed)
			end
			--注册失败显示登录按钮
			self:SetBtnState(true)
		end
	)
end

function LoginViewCtr:GetThirdPartyLoginUserInfo()
	local userName = self.deviceId
	local passWord = self.deviceId
	if CC.ChannelMgr.CheckOppoChannel() then
		userName = CC.Player.Inst():GetThirdPartyUserId()
		passWord = ""
	end

	return userName, passWord
end

function LoginViewCtr:OnLineLogin()
	--Line登录
	self:SetBtnState(false)
	self.view:RefreshUI({showPercent = true, percent = 0})
	local successCallback = function(lineData)
		local data = {}
		data.LineId = lineData.user_id
		data.LineToken = lineData.access_token
		data.GuestUsr, data.GuestPwd = self:GetThirdPartyLoginUserInfo()
		data.Imei = self.deviceId
		data.OS = self:GetOSEnum()
		data.ThirdPartner = CC.ChannelMgr.GetSwitchByKey("nThirdPartner")
		CC.uu.Log(data, "LineLoginData:")
		CC.Request(
			"LineLogin",
			data,
			function(err, result)
				--line登录验证成功
				CC.ReportManager.SetDot("LINECHECKSUCC")
				CC.uu.Log("Request.LineLogin success")
				CC.Player.Inst():SetLoginInfo(result)
				CC.Player.Inst():SetThirdPartyToken(data.LineToken)
				self:SaveRegister(self.loginDefine.LoginWay.Line)
				self:ReqestQueue(result, data.LineToken, self.loginDefine.LoginWay.Line, CC.shared_enums_pb.RT_Line)
			end,
			function(err)
				--line登录验证失败
				CC.ReportManager.SetDot("LINECHECKFAIL")
				CC.uu.Log("Request.LineLogin failed")
				if err ~= CC.shared_en_pb.LimitIpAddress then
					CC.ViewManager.ShowTip(self.language.lineLoginCheckFailed)
				end
				self:SetBtnState(true)
			end
		)
	end

	local errCallBack = function()
		CC.uu.Log("LoginViewCtr: LineSDK Login err")
		CC.ViewManager.ShowTip(self.language.lineLoginFailed)
		self:SetBtnState(true)
		if self.switchDataMgr.GetPhoneLoginSwitch() then
			self.view:OpenPhoneLogin()
		end
	end

	--如果没有绑定过FACEBOOK,走FACEBOOK绑定流程
	CC.LinePlugin.Login(successCallback, errCallBack)
end

function LoginViewCtr:OnFacebookLogin()
	--Fackbook登录
	self:SetBtnState(false)
	self.view:RefreshUI({showPercent = true, percent = 0})
	local successCallback = function(fbData)
		local data = {}
		data.FacebookId = fbData.user_id
		data.FacebookToken = fbData.access_token
		data.GuestUsr, data.GuestPwd = self:GetThirdPartyLoginUserInfo()
		data.Imei = self.deviceId
		data.OS = self:GetOSEnum()
		data.ThirdPartner = CC.ChannelMgr.GetSwitchByKey("nThirdPartner")
		CC.uu.Log(data, "FacebookLoginData:")
		CC.Request(
			"FacebookLogin",
			data,
			function(err, result)
				--facebook登录验证成功
				CC.ReportManager.SetDot("FBCHECKSUCC")
				CC.uu.Log("Request.FacebookLogin success")
				CC.Player.Inst():SetLoginInfo(result)
				CC.Player.Inst():SetThirdPartyToken(data.FacebookToken)
				self:SaveRegister(self.loginDefine.LoginWay.Facebook)
				self:ReqestQueue(result, data.FacebookToken, self.loginDefine.LoginWay.Facebook, CC.shared_enums_pb.RT_Facebook)
			end,
			function(err)
				--facebook登录验证失败
				CC.ReportManager.SetDot("FBCHECKFAIL")
				CC.uu.Log("Request.FacebookLogin failed")
				if err ~= CC.shared_en_pb.LimitIpAddress then
					CC.ViewManager.ShowTip(self.language.facebookLoginCheckFailed)
				end
				self:SetBtnState(true)
			end
		)
	end

	local errCallBack = function()
		CC.uu.Log("LoginViewCtr: FacebookSDK Login err")
		CC.ViewManager.ShowTip(self.language.facebookLoginFailed)
		self:SetBtnState(true)

		if
			(CC.Platform.isAndroid and (tonumber(AppInfo.androidVersionCode) < 28)) or
				(CC.ChannelMgr.CheckOfficialWebChannel() and (tonumber(AppInfo.androidVersionCode) <= 26))
		 then
			local param = {}
			param.str = self.language.updateMsg
			param.btnOkText = self.language.btnGo
			param.btnNoText = self.language.btnCancel
			param.okFunc = function()
				local marketUrl = "market://details?id=com.huoys.royalcasinoonline"
				Client.GotoAPPStore(marketUrl)
			end
			CC.ViewManager.MessageBoxExtend(param)
		end
		if self.switchDataMgr.GetPhoneLoginSwitch() then
			self.view:OpenPhoneLogin()
		end
	end

	--如果没有绑定过FACEBOOK,走FACEBOOK绑定流程
	CC.FacebookPlugin.LogIn(successCallback, errCallBack)
end

function LoginViewCtr:OnOppoLogin()
	--Oppo登录
	self:SetBtnState(false)
	self.view:RefreshUI({showPercent = true, percent = 0})
	local successCallback = function(oppoData)
		local data = {}
		data.OPPOSsoid = oppoData.ssoid
		data.OPPOToken = oppoData.token
		data.GuestUsr = self.deviceId
		data.GuestPwd = self.deviceId
		data.Imei = self.deviceId
		data.OS = self:GetOSEnum()
		data.ThirdPartner = CC.ChannelMgr.GetSwitchByKey("nThirdPartner")
		CC.uu.Log(data, "OppoLoginData:")
		CC.Request(
			"OppoLogin",
			data,
			function(err, result)
				--facebook登录验证成功
				CC.uu.Log("Request.OppoLogin success")
				CC.Player.Inst():SetLoginInfo(result)
				CC.Player.Inst():SetThirdPartyToken()
				CC.Player.Inst():SetThirdPartyUserId(oppoData.ssoid)
				self:SaveRegister(self.loginDefine.LoginWay.OPPO)
				self:ReqestQueue(result, data.OPPOToken, self.loginDefine.LoginWay.OPPO, CC.shared_enums_pb.RT_OPPO)
			end,
			function(err)
				--facebook登录验证失败
				CC.uu.Log("Request.OppoLogin failed")
				if err ~= CC.shared_en_pb.LimitIpAddress then
					CC.ViewManager.ShowTip(self.language.guessLoginFailed)
				end
				self:SetBtnState(true)
			end
		)
	end

	local errCallBack = function()
		CC.uu.Log("LoginViewCtr: OppoLogin Login err")
		CC.ViewManager.ShowTip(self.language.guessLoginFailed)
		self:SetBtnState(true)
	end

	--如果没有绑定过FACEBOOK,走FACEBOOK绑定流程
	CC.OppoPlugin.Login(successCallback, errCallBack)
end

function LoginViewCtr:LoginByPhoneRsp(err, result)
	if err == 0 then
		self:SetBtnState(false)
		self.view:RefreshUI({showPercent = true, percent = 0})
		self.view:ClearPhonePanel()
		CC.Player.Inst():SetLoginInfo(result)
		--游客登录置空第三方登录token
		CC.Player.Inst():SetThirdPartyToken()
		self:ReqestQueue(result, nil, self.loginDefine.LoginWay.Phone, CC.shared_enums_pb.RT_Phone)
	else
		CC.uu.Log("Login fail")
		self:SetBtnState(true)
	end
end

function LoginViewCtr:RefreshBtnService()
	self.view:RefreshUI({refreshBtnService = true})
end

function LoginViewCtr:ReqestQueue(data, partnerToken, loginType, registerType)
	CC.TimeMgr.SetSvrTimeStamp(data.ServerTimeStamp)
	local doFun1 = function()
		self:LoginWithProcess(data, partnerToken, loginType, registerType)
	end
	if CC.ChannelMgr.GetTrailStatus() then
		doFun1()
		return
	end
	local doFun2 = function()
		self:SetBtnState(true)
		if not self.view.noticeIsShow and not self.view:FindChild("NoticeBtn").activeSelf then
			self.view:FindChild("NoticeBtn"):SetActive(true)
		end
	end
	local queueData = self.switchDataMgr.GetLoginQueueSwitch()
	if queueData.switch and CC.DebugDefine.GetEnvState() ~= CC.DebugDefine.EnvState.StableDev then
		CC.Request(
			"ReqQueueData",
			nil,
			function(err, result)
				log(string.format("Request.ReqQueueData success   result: %s", tostring(result)))
				if result.QueueTime > 0 then
					CC.ViewManager.Open("LoginQueueView", {result = result, reqSucc = true, enterFun = doFun1, exitFun = doFun2})
				else
					doFun1()
				end
			end,
			function(err, result)
				logError(string.format("Request.ReqQueueData failed(%s)   result: %s", err, tostring(result)))
				result = {
					QueueTime = math.random(queueData.timeMin, queueData.timeMax),
					Rank = math.random(queueData.rankNumMin, queueData.rankNumMax)
				} --请求失败客户端默认排队数据
				CC.ViewManager.Open("LoginQueueView", {result = result, reqSucc = false, enterFun = doFun1, exitFun = doFun2})
			end
		)
	else
		doFun1()
	end
end

function LoginViewCtr:LoginWithProcess(data, partnerToken, loginType, registerType)
	--登录后时间
	self.time = os.clock()
	AsynCall.run(
		function()
			--验证token获取玩家基本信息
			local loginData = self:LoginWithToken(data, partnerToken, loginType, registerType)
			if not loginData then
				return
			end
			--请求玩家道具信息
			if not self:LoadPlayerWithPropType(loginData) then
				return
			end
			--请求注册publisher(接收服务器推送)
			if not self:RegToPublisher(loginData) then
				return
			end
			--并行请求(非必要的状态都放到这里请求)
			self:ParallelRequest()
			--获取玩家引导状态
			if not self:GetNewPlayerFlag() then
				return
			end
			--获取玩家游戏状态
			if not self:ReqLoadPlayerGameInfo(loginData) then
				return
			end
			--进入大厅
			self:EnterGame()
		end
	)
end

function LoginViewCtr:AysnRequest(param, succCb, errCb)
	local succCb = succCb or function()
		end
	local errCb = errCb or function()
		end
	local reqName = "Request." .. param.name
	local code, data = AsynCall.call(CC.Request, "RequestAsyn", param)
	if code == 0 then
		CC.uu.Log(reqName .. " success")
		succCb(code, data)
		self.networkRspCount = self.networkRspCount + 1
		return data
	end
	CC.uu.Log(reqName .. " failed")
	errCb(code, data)
	return false
end

function LoginViewCtr:LoginWithToken(data, partnerToken, loginType, registerType)
	local req = {}
	req.name = "LoginWithToken"
	req.data = {}
	req.data.PlayerId = data.PlayerId
	req.data.Token = data.Token
	req.data.PartnerToken = partnerToken
	req.data.Imei = self.deviceId
	req.data.OS = self:GetOSEnum()
	req.data.AccountType = registerType
	local succCb = function()
		CC.Player.Inst():SetData(self.deviceId, self.deviceId)
		CC.Player.Inst():SetCurLoginWay(loginType)
	end
	local errCb = function()
		self:SetBtnState(true)
		CC.ViewManager.ShowTip(self.language.tokenCheckFailed)
	end
	return self:AysnRequest(req, succCb, errCb)
end

function LoginViewCtr:LoadPlayerWithPropType(loginData)
	--先获取玩家个人信息数据
	local req = {}
	req.name = "ReqLoadPlayerWithPropType"
	req.data = {
		playerId = loginData.Id,
		propTypes = {
			CC.shared_enums_pb.EPT_Wealth,
			CC.shared_enums_pb.EPT_Title,
			CC.shared_enums_pb.EPT_Lot,
			CC.shared_enums_pb.EPT_Statistic,
			CC.shared_enums_pb.EPT_MidMonth_Treasure
		}
	}
	local succCb = function(err, data)
		CC.Player.Inst():SetSelfInfo(data)
	end
	local errCb = function()
		self:SetBtnState(true)
		CC.ViewManager.ShowTip(self.language.loadPlayerDataFailed)
	end
	return self:AysnRequest(req, succCb, errCb)
end

function LoginViewCtr:RegToPublisher(logindata)
	local req = {}
	req.name = "RegToPublisher"
	req.data = {}
	req.data.Id = logindata.Id
	req.data.Token = logindata.Nick
	local succCb = function()
		CC.Network.SetPublisherState(true)
	end
	local errCb = function()
		self:SetBtnState(true)
		CC.ViewManager.ShowTip(self.language.regToPublisherFailed)
	end
	return self:AysnRequest(req, succCb, errCb)
end

function LoginViewCtr:GetNewPlayerFlag()
	local createTime = CC.uu.date4time(CC.Player.Inst():GetSelfInfoByKey("CreateTime"))
	local openTime = 1623117600
	--2021-06-08
	if CC.ChannelMgr.GetSwitchByKey("bHasGuide") and not CC.DebugDefine.GetGuideDebugState() then
		if createTime - openTime > 0 then
			local req = {}
			req.name = "ReqGetNewPlayerFlag"
			local succCb = function(err, data)
				CC.uu.Log(data, "GUIDE:", 3)
				self.gameData.SetGuide(data.Flag)
				self.gameData.SetTotalFlag(data.TotalFlag)
				self.gameData.SetPlayerType(data.PlayerType)
			end
			local errCb = function()
				self:SetBtnState(true)
			end
			return self:AysnRequest(req, succCb, errCb)
		end
	end
	self.networkRspCount = self.networkRspCount + 1
	return true
end

function LoginViewCtr:ReqLoadPlayerGameInfo(logindata)
	local req = {}
	req.name = "ReqLoadPlayerGameInfo"
	req.data = {
		PlayerId = logindata.Id
	}
	local succCb = function(err, data)
		CC.Player.Inst():SetReConnectInfo(data)
		CC.Player.Inst():SetLoginState(true)
	end
	local errCb = function()
		self:SetBtnState(true)
		CC.ViewManager.ShowTip(self.language.loadReConnectDataFailed)
	end
	return self:AysnRequest(req, succCb, errCb)
end

function LoginViewCtr:ParallelRequest()
	--检查玩家生日
	self:CheckBirthday()
	--检查新手签到状态
	self:GetNoviceSignInState()
	--检查任务状态
	self:GetPlayerTaskState()
	--检测玩家是否为高V
	self:CheckMeIfAgent()
	--获取玩家赠送信息
	self:CheckTradeInfo()
	--检测整包更新奖励
	self:CheckAppUpdateReward()
end

function LoginViewCtr:GetNoviceSignInState()
	CC.Request(
		"ReqNewPlayerSignStatus",
		nil,
		function(err, data)
			CC.uu.Log("ReqNewPlayerSignStatus success")
			--成功回调，设置新手签到状态
			CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr").SetNoviceDataByKey("NoviceSignInView", data.Open)
		end,
		function(err)
			CC.uu.Log(string.format("ReqNewPlayerSignStatus failed(%s)", err))
		end
	)
end

function LoginViewCtr:GetPlayerTaskState()
	CC.Request(
		"ReqTaskListInfo",
		nil,
		function(err, data)
			CC.uu.Log("ReqTaskListInfo success")
			CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr").SetNoviceDataByKey(
				"NewbieTaskView",
				not (data.IsNewTaskAllAward and data.IsBoxTaskAllAward)
			)
		end,
		function(err)
			CC.uu.Log(string.format("ReqTaskListInfo failed(%s)", err))
		end
	)
end

function LoginViewCtr:CheckMeIfAgent()
	if self.switchDataMgr.GetSwitchStateByKey("AgentUnlock") then
		CC.Request(
			"ReqAgentData",
			nil,
			function(err, data)
				-- CC.uu.Log(data,"ReqAgentData:",3)
				CC.uu.Log(data, "ReqAgentData success")
				CC.DataMgrCenter.Inst():GetDataByKey("Agent").SetAgentSatus(data)
			end,
			function(err)
				CC.uu.Log(string.format("ReqAgentData failed(%s)", err))
			end
		)
	end
end

function LoginViewCtr:CheckBirthday()
	CC.Request(
		"ReqBirthdayData",
		{PlayerID = CC.Player.Inst():GetLoginInfo().PlayerId},
		function(err, data)
			CC.uu.Log("ReqBirthdayData success")
			CC.Player.Inst():SetBirthdayGiftData(data)
		end,
		function(err)
			CC.uu.Log(string.format("ReqBirthdayData failed(%s)", err))
		end
	)
end

function LoginViewCtr:CheckTradeInfo()
	CC.Request(
		"ReqTradeInfo",
		nil,
		function(err, data)
			CC.uu.Log("ReqTradeInfo success")
			local status = data.HasSended or data.HasRecieved
			CC.Player.Inst():SetSendOrRecievedState(status)
		end,
		function(err)
			CC.uu.Log(string.format("ReqTradeInfo failed(%s)", err))
		end
	)
end

function LoginViewCtr:CheckAppUpdateReward()
	local rewardVersion = CC.LocalGameData.GetAppUpdateRewardVersion()
	if rewardVersion == AppInfo.version then
		return
	end
	CC.Request(
		"ReqNewVersionReward",
		{RewardType = 1, Version = AppInfo.version},
		function()
			CC.LocalGameData.SetAppUpdateRewardVersion(AppInfo.version)
		end
	)
end

function LoginViewCtr:EnterGame()
	local time = math.floor((os.clock() - self.time) * 1000)
	CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").SetPlayerPing(time)
	CC.uu.DelayRun(
		0.5,
		function()
			CC.ViewManager.Replace("HallView")
		end
	)
end

function LoginViewCtr:SaveRegister(registerType)
	--保存注册信息到APPSFLYER
	local tips
	if registerType == self.loginDefine.LoginWay.Guest then
		tips = "guest"
	elseif registerType == self.loginDefine.LoginWay.Facebook then
		tips = "facebook"
	elseif registerType == self.loginDefine.LoginWay.Line then
		tips = "line"
	elseif registerType == self.loginDefine.LoginWay.OPPO then
		tips = "oppo"
	end
	local isRegister = Util.GetFromPlayerPrefs("isRegister")
	if isRegister ~= "true" then
		CC.AppsFlyerPlugin.TrackRregister(tips)
		CC.FacebookPlugin.TrackRregister(tips)
		CC.FirebasePlugin.TrackRregister(tips)
		Util.SaveToPlayerPrefs("isRegister", "true")
		Util.SaveToPlayerPrefs("isNewPlayer", "true")
	end
end

function LoginViewCtr:SetBtnState(flag)
	self.percent = 0

	self.networkRspCount = 0

	self.view:RefreshUI({showBtns = flag, showPercent = false})
end

function LoginViewCtr:OnOpenService()
	-- local url = self.webUrlData.GetLocalServiceUrl();
	-- local url = self.webUrlData.GetWebServiceUrl();
	-- Client.OpenURL(url);
	CC.ViewManager.Open("WebServiceView")
end

function LoginViewCtr:OnAddNodeCount(nodeIndex)
	if CC.DebugDefine.GetDebugMode() then
		return
	end
	local count = self.clickCount[nodeIndex]
	if count >= 10 then
		return
	end
	self.clickCount[nodeIndex] = count + 1

	if self.clickCount[1] + self.clickCount[2] >= 20 then
		CC.DebugDefine.SetDebugMode(true)
	end
end

function LoginViewCtr:GetOSEnum()
	return CC.Platform.GetOSEnum()
end

function LoginViewCtr:GetTokenByPhoneRsp(err)
	if err == 0 then
		CC.ViewManager.ShowTip(self.language.PhoneGetCodeSucc)
		self.view:StartPhoneTimer()
	else
		CC.ViewManager.ShowTip(self.language.PhoneGetCodeFail)
	end
end

function LoginViewCtr:VerifyPhoneTokenRsp(err, data)
	if err == 0 and #(data.PlayerId) ~= 0 then
		self.view:InitIDBtn(data)
	else
		CC.ViewManager.ShowTip(self.language.VerCodeFail)
	end
end

function LoginViewCtr:Destroy()
	self:UnRegisterEvent()

	self:StopUpdate()
end

return LoginViewCtr
