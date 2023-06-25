
--[[
	封装一些通用的业务逻辑方法
]]

local CC = require("CC")

local HallUtil = {}

--检查是否是预约游戏
function HallUtil.CheckShow(id)
	local GameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	local SubscribeList = GameDataMgr.GetSubscribeList()	--已预约游戏
	local NeedSubscribeList = GameDataMgr.GetNeedSubscribeList()	--需要预约游戏
	local QueueList = GameDataMgr.GetQueueList()	--目前测试游戏
	local NeedSubscribe = false
	local Subscribe = false
	local QueueState = false
	--先检查游戏是否需要预约
	for i,v in ipairs(NeedSubscribeList) do
		if id == tonumber(v) then
			NeedSubscribe = true
		end
	end
	--如果都不需要预约，直接返回false，将卡图设置成可进入状态
	if not NeedSubscribe then return false end
	--如果当前游戏处于需要预约游戏状态,判断当前是否是测试阶段
	for i,v in ipairs(QueueList) do
		if id == tonumber(v) then
			QueueState = true
		end
	end
	--如果当前不是测试阶段，证明还在预约阶段，将卡图设置为不可点击状态
	if not QueueState then return true end
	--是排队阶段，则判断玩家是否已经预约该游戏
	for i,v in ipairs(SubscribeList) do
		if id == tonumber(v) then
			Subscribe = true
		end
	end
	--预约了显示正常卡图，没预约则不可点击
	if Subscribe then
		return false
	else
		return true
	end
end

--执行这个方法时，默认游戏为排队且已预约状态或正常进入游戏状态
function HallUtil.CheckSubscribe(id)
	local GameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	local SubscribeList = GameDataMgr.GetSubscribeList()	--已预约游戏
	local NeedSubscribeList = GameDataMgr.GetNeedSubscribeList()	--需要预约游戏
	local QueueList = GameDataMgr.GetQueueList()	--目前测试游戏
	local NeedSubscribe = false
	for i,v in ipairs(NeedSubscribeList) do
		if id == tonumber(v) then
			NeedSubscribe = true
		end
	end
	-- 不在需要预约列表里，直接让进入
	if not NeedSubscribe then
		return false
	else
		return true
	end
end

--检查游戏进入限制
function HallUtil.CheckEnterLimit(id)
	local define = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
	local vipLimit = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetVipUnlockByID(id)
	if define.UnlockCondition[id] then
		local info = define.UnlockCondition[id]
		local lock = info.Lock
		local prop = info.Prop
		if not lock or CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
			local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level") or 0
			local propNum = CC.Player.Inst():GetSelfInfoByKey(prop) or 0
			if vipLevel >= vipLimit or propNum > 0 then
				return true
			else
				return false
			end
		end
	end
	--正常VIP限制流程
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < vipLimit then
		return false
	end
	return true
end

--进入游戏
function HallUtil.EnterGame(id,gameData, callback)
	local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	local IsHallGroup = gameDataMgr.GetIsHallGroupByID(id)
	local okCB = function()
		CC.ResDownloadManager.CheckGame(id,function ()
			if CC.ViewManager.IsGameEntering() or not CC.ViewManager.IsHallScene() then return end
			if HallUtil.CheckSubscribe(id) then
				local data = {}
				data.GameID = id
				data.PlayerID = CC.Player.Inst():GetSelfInfoByKey("Id")
				CC.Request("ReqLimitStatus",data,function (err,data)
					if err == 0 then
						if data.Status == 2 and data.QueueStatus == 3 or data.Status == 3 then
							HallUtil.EnterGameWithoutCheckGame(id,gameData, callback)
						else
							local param = {}
							param.Status = data.Status
							param.QueueStatus = data.QueueStatus
							param.QueueIndex = data.QueueIndex
							param.QueueTotalNum = data.QueueTotalNum
							param.QueueEvaluateTime = data.QueueEvaluateTime
							CC.ViewManager.Open("QueueView",{GameId = id,QueueData = param})
						end
					end
				end,
				function (err)
					CC.ViewManager.Open("QueueView",{GameId = id})
				end)
			else
				HallUtil.EnterGameWithoutCheckGame(id,gameData, callback)
			end
		end)
	end
	local errorCB = function ()
		CC.HallNotificationCenter.inst():post(CC.Notifications.GameClickState,{id = id,state = false})
	end
	CC.HallUtil.CheckGroupConfig(id, okCB, errorCB)
end

--不检查更新直接进入游戏
function HallUtil.EnterGameWithoutCheckGame(id,gameData,callback)
	local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	local IsHallGroup = gameDataMgr.GetIsHallGroupByID(id)
	if IsHallGroup == 1 then
		if callback then
			callback()
		end
		CC.ViewManager.Open("SelectionGameView",id)
		CC.HallNotificationCenter.inst():post(CC.Notifications.GameClickState,{id = id,state = false})
	else
		--游戏入口（根据ID做特殊处理）
		if id == 5008 then
			--虽然说是10W筹码入场，但实际上需要留底3000，不触发救济金
			if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < 103000 then
				local language = CC.LanguageManager.GetLanguage("L_Tip")
				CC.ViewManager.ShowMessageBox(language.enter_5008_tip,function ()
					CC.ViewManager.Open("StoreView")
				end,
				function ()
					-- 取消不做任何操作
				end)
				CC.HallNotificationCenter.inst():post(CC.Notifications.GameClickState,{id = id,state = false})
				return
			end
			
			-- CC.ViewManager.Open("FootballView",{Enter = true})
			return
		end
		local gameData = gameData or gameDataMgr.GetInfoByID(id)
		CC.ViewManager.EnterGame(gameData,id)
	end
end

--进入游戏条件不够
function HallUtil.UnlockCondition(id, callback)
	local language = CC.LanguageManager.GetLanguage("L_Tip")
	local define = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
	local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	if define.UnlockCondition[id] then
		local info = define.UnlockCondition[id]
		local view = info.View
		local lock = info.Lock
		if not lock or CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
			if callback then
				callback()
			end
			CC.ViewManager.Open(view)
			return
		end
	end
	local vipLimit = gameDataMgr.GetVipUnlockByID(id)
	CC.ViewManager.ShowMessageBox(string.format(language.enterGame_tip,vipLimit),
	function ()
		if callback then
			callback()
		end
		if vipLimit > 1 and vipLimit <= 3 then
			CC.SubGameInterface.OpenVipBestGiftView({needLevel = vipLimit})
		elseif CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
			CC.ViewManager.OpenEx("SelectGiftCollectionView")
		else
			CC.ViewManager.Open("StoreView")
		end
	end,
	function ()
		--取消不作任何处理
	end)
end

function HallUtil.CheckAndEnter(id,gameData,callback)
	if HallUtil.CheckEnterLimit(id) then
		HallUtil.EnterGame(id,gameData, callback)
	else
		HallUtil.UnlockCondition(id, callback)
		CC.HallNotificationCenter.inst():post(CC.Notifications.GameClickState,{id = id,state = false})
	end
end

function HallUtil.ReqGameGroupConfig(gameId, succCb, errCb)
	succCb = succCb or function() end
	errCb = errCb or function() end
    local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    local updateDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Update")
    local webUrlDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
    local gameProName = gameDataMgr.GetProNameByID(gameId)
    local url = webUrlDataMgr.GetGroupConfigUrl(gameProName)
	CC.HttpMgr.Get(url, function(www)
        local data = Json.decode(www.downloadHandler.text)
        gameDataMgr.SetGroupConfigByID(gameId, data.Group)
        local param = {
        	Id = data.Id,
        	version = data.version,
        	forceUpdate = data.forceUpdate
        }
        updateDataMgr.SetUpdateInfoByID(param)
        succCb(data)
	end, function()
		CC.uu.Log(url, "reqGameCfg failed");
		errCb()
	end)
end

--游戏进入前下载场次及版本配置
function HallUtil.CheckGroupConfig(gameId, succCb, errCb)
	local succCb = succCb or function() end
	local errCb = errCb or function() end
    local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    local gameGroupConfig = gameDataMgr.GetGroupConfigByID(gameId)
    if gameGroupConfig then
    	succCb(gameGroupConfig)
    	return
    end

    local doReq
    doReq = function()
    	local errorCb = function()
            local language = CC.LanguageManager.GetLanguage("L_Common")
            CC.ViewManager.ShowMessageBox(
                language.tip5,
                function()
                    doReq()
                end,
                errCb
            )
    	end
    	HallUtil.ReqGameGroupConfig(gameId, succCb, errorCb)
	end
	doReq()
end

--隐藏tag的object
function HallUtil.HideByTagName(tagName, status)
	local tags = GameObject.FindGameObjectsWithTag(tagName)
    for i = 0, tags.Length-1 do
        tags[i].transform:SetActive(status)
    end
end

function HallUtil.JudgeHaveLineApp()
	local appkey = CC.Platform.isAndroid and "jp.naver.line.android" or "lineauth2";
	if not Client.JudgeHaveApp(appkey) then
        local language = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView");
        CC.ViewManager.ShowTip(language.lineTip);
        return false;
    end
	return true;
end

function HallUtil.JudgeHaveFacebookApp()
	local appkey = CC.Platform.isAndroid and "com.facebook.katana" or "fb";
	if not Client.JudgeHaveApp(appkey) then
        local language = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView");
        CC.ViewManager.ShowTip(language.facebookTip);
        return false;
    end
	return true;
end

--判断用户是否广告安装来源
function HallUtil.IsFromADSource()
	local mediaSource = CC.Player.Inst():GetSelfInfoByKey("MediaSource");
	return mediaSource ~= "" and mediaSource ~= "organic";
end

function HallUtil.CheckDeepPlayer()
	return CC.Player.Inst():GetSendOrRecievedState();
end

--[[
@param:
webTitle: 链接标题
webText:  链接描述内容
file: 	  传入texture2D
urlData:  链接参数,table类型
succCb(url): 成功回调 带回分享链接
errCb:    失败回调
]]
function HallUtil.CreateShareLink(param)
	local createLink = function(imgUrl)
		Util.hasLog = true;
		local t = {
			webTitle = param.webTitle,
			webText = param.webText,
			textureUrl = imgUrl,
			callback = function(url)
				CC.uu.Log(url, "shareLink:");
				Util.hasLog = false;
				if not url then
					param.errCb();
					return;
				end
				param.succCb(url, imgUrl);
			end,
			urlData = param.urlData or {}
		}
		t.urlData.isDeepPlayer = CC.HallUtil.CheckDeepPlayer();
		CC.FirebasePlugin.CreateCommonShareLink(t);
	end

	param.file = param.file or "";
	--file不是texture则直接创建链接
	if type(param.file) == "string" then
		CC.uu.Log(param.file,"share texture url:");
		createLink(param.file);
		return;
	end
	--file为texture则先上传图片再创建链接
	local data = {};
	data.file = param.file;
	data.succCb = function(imgUrl)
		createLink(imgUrl);
	end
	data.errCb = param.errCb;
	HallUtil.UpLoadImg(data);
end

--[[
@param:
file: 传入texture2D
succCb(url): 成功回调 带回图片地址
errCb: 失败回调
]]
function HallUtil.UpLoadImg(param)
	local succCb = param.succCb or function() end
	local errCb = param.errCb or function() end
	local fileBytes = UnityEngine.ImageConversion.EncodeToJPG(param.file, 16);
	local wwwForm = UnityEngine.WWWForm.New();
	wwwForm:AddBinaryData("file", fileBytes, "jpg");
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetUpLoadImgUrl();
	CC.HttpMgr.PostForm(url,wwwForm,function(www)
        local result = Json.decode(www.downloadHandler.text)
        CC.uu.Log(result,"UpLoadImgResp:")
        if result.status == 1 then
            local data = result.data;
            succCb(data.ImgUrl);
            return
        end
        errCb();
	end, function(error)
		CC.uu.Log(error,"UpLoadImgResp error:");
		errCb();
	end)
end
function HallUtil.ClickADEvent(param)
	local language = CC.LanguageManager.GetLanguage("L_PopupView");
	if param.MessageUseType == "1" then
	    --购买商品,  对应web后台的里的 跳转指向
		local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")[param.ExtensionID];
		local data = {}
		data.wareId = wareCfg.Id
		data.subChannel = wareCfg.SubChannel
		data.price = wareCfg.Price
		data.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
		if param.ExtensionID == CC.PaymentManager.GetActiveWareIdByKey("buyu") then
			data.errCallback = function (err)
				if err == CC.shared_en_pb.WareAlreadyPurchased then
					CC.ViewManager.ShowTip(language.WareAlreadyPurchased)
				end
			end
		end
		CC.PaymentManager.RequestPay(data)
	elseif param.MessageUseType == "2" then
		--跳转游戏
		local id = tonumber(param.ExtensionID)
		if HallUtil.CheckEnterLimit(id) then
			HallUtil.EnterGame(id)
		else
			HallUtil.UnlockCondition(id)
		end
	elseif param.MessageUseType == "3" then
	    --跳转客户端功能
		if param.ExtensionID == "MarsTaskView" then
			--火星任务活动
			CC.HallNotificationCenter.inst():post(CC.Notifications.JumpToMarsTask)
			return
		end
		
		if param.ExtensionID == "AgentNewView" and CC.DataMgrCenter.Inst():GetDataByKey("Agent").GetForbiddenAgentSatus() then
			local hallLanguage = CC.LanguageManager.GetLanguage("L_HallView")
			CC.ViewManager.ShowTip(hallLanguage.tipAgent)
			return
		end
		CC.ViewManager.Open(param.ExtensionID)
	elseif param.MessageUseType == "4" then
		--绑定facebook
		HallUtil.BlindFacebook()
	elseif param.MessageUseType == "5" then
	    --打开网页外链
		Client.OpenURL(param.ExtensionID)
	elseif param.MessageUseType == "6" then
		--打开乐透功能
		if CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLotAddress() then
			CC.ViewManager.Open("LotteryView",{serverIp = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLotAddress()})
		else
			CC.Request("ReqAllocServer",{GameId = 4001,GroupId = 1},function (err,data)
				CC.ViewManager.Open("LotteryView",{serverIp = data.Address})
			end,
			function (err,data)
				logError("EnterLot Fail")
			end)
		end
	elseif param.MessageUseType == "7" then
		--打开合集
		if param.ExtensionID and param.ExtensionID == "SelectGiftCollectionView" and not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
			return
		end
		if param.ExtensionID and param.ExtensionID == "FreeChipsCollectionView" and not CC.ChannelMgr.GetSwitchByKey("bHasFreeChips") then
			return
		end
		if param.ExtensionID and param.ExtensionID == "RankCollectionView" and not CC.ChannelMgr.GetSwitchByKey("bShowTotalRank") then
			return
		end

		CC.ViewManager.Open(param.ExtensionID, {currentView = param.CurrentView})
	elseif param.MessageUseType == "8" then
		--跳转FB主页
		local pageId = CC.ConfigCenter.Inst():getConfigDataByKey("SDKConfig")[AppInfo.ChannelID].facebook.pageId;
		Client.OpenFacebook(pageId);
	elseif param.MessageUseType == "9" then
		--领取奖励
		local data = {};
		data.ID = 19
		data.Amount = 1
		data.GameId = CC.ViewManager.GetCurGameId() or 1
		data.GroupId = CC.ViewManager.GetCurGroupId() or 0
		CC.Request("ReqExchange",data);
	else
	--无处理
	end
end

function HallUtil.BlindFacebook()
	if HallUtil.CheckLineBinded() or HallUtil.CheckFacebookBinded() then return end

	CC.ViewManager.ShowLoading(true)
	local language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
	local successCallback = function (fbData)
		local data = {};
        data.FacebookId = fbData.user_id;
	    data.FacebookToken = fbData.access_token;
		CC.Request("BindFacebook",data,function (err,data)
			--facebook绑定成功
			CC.ViewManager.CloseLoading()

			local loginData = CC.Player.Inst():GetLoginInfo();
			loginData.BindingFlag = bit.bor(loginData.BindingFlag, CC.shared_enums_pb.EF_Binded);

			local param = {}
			param.items = {{ConfigId = 2, Count = 5000}}
			param.title = "BindFacebook"
			param.callback = function ()
				CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.AutoFacebook);
			end
			CC.ViewManager.OpenRewardsView(param)
		end,function (err)
			--facebook绑定失败
			CC.ViewManager.CloseLoading();

			if err == CC.shared_en_pb.FacebookAlreadyBinded then
				CC.ViewManager.ShowTip(language.facebookLoginTips1);
			else 
				CC.ViewManager.ShowTip(language.facebookLoginTips4);
			end
			CC.FacebookPlugin.Logout();
		end)
	end

	local errCallBack = function()
		CC.ViewManager.CloseLoading();
		CC.ViewManager.ShowTip(language.facebookLoginTips2);
	end
	--如果没有绑定过FACEBOOK,走FACEBOOK绑定流程
	CC.FacebookPlugin.LogIn(successCallback, errCallBack);
end

function HallUtil.BindLine()
	if HallUtil.CheckLineBinded() or HallUtil.CheckFacebookBinded() then return end

	CC.ViewManager.ShowLoading(true)
	local language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
	local successCallback = function (lineData)
		local data = {};
		data.LineId = lineData.user_id;
		data.LineToken = lineData.access_token;
		CC.Request("BindLine",data,function(err,data)
			--line绑定成功
			CC.ViewManager.CloseLoading();

			local loginData = CC.Player.Inst():GetLoginInfo();
			loginData.BindingFlag = bit.bor(loginData.BindingFlag, CC.shared_enums_pb.EF_LineBinded);

			local param = {}
			param.items = {{ConfigId = 2, Count = 5000}}
			param.title = "BindLine"
			param.callback = function ()
				CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.AutoLine);
			end
			CC.ViewManager.OpenRewardsView(param)
		end,function(err)
			--line绑定失败
			CC.ViewManager.CloseLoading();

			if err == CC.shared_en_pb.LineAlreadyBinded then
				CC.ViewManager.ShowTip(language.lineLoginTips1);
			else
				CC.ViewManager.ShowTip(language.lineLoginTips4);
			end
			CC.LinePlugin.Logout();
		end)
	end

	local errCallBack = function()
		CC.ViewManager.CloseLoading();
		CC.ViewManager.ShowTip(language.lineLoginTips2);
	end

	--如果没有绑定过Line,走Line绑定流程
	CC.LinePlugin.Login(successCallback, errCallBack);
end

--检查玩家是否游客
function HallUtil.CheckGuest()
	local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0
	local BindPhone = bit.band(bindingFlag, CC.shared_enums_pb.EF_TelBinded) == 0
	local anyBinded = bit.band(bindingFlag, CC.shared_enums_pb.EF_Binded) == 0 and bit.band(bindingFlag, CC.shared_enums_pb.EF_LineBinded) == 0
	return anyBinded and BindPhone
end

function HallUtil.GetDeviceInfo()
	local deviceInfoStr = Client.GetDeviceInfo();
	if deviceInfoStr == "" then
		return {}
	end
	deviceInfoStr = string.gsub(deviceInfoStr, "%$", "\"");
	local info
	local ret = CC.uu.SafeCallFunc(function ()
		info = Json.decode(deviceInfoStr)
	end)
	return ret and info or {};
end

--[[
@param
playerId: 玩家id
propIds: 道具id列表
succCb
errCb
]]
function HallUtil.ReqPlayerPropByIds(param)
	local param = param or {}
	local playerId = param.playerId or CC.Player.Inst():GetSelfInfoByKey("Id");
	if not playerId then return end
	local data = {
		playerId = playerId,
		propIds = {
			CC.shared_enums_pb.EPC_ChouMa,		--筹码
		}
	}
	if param.propIds then
		data.propIds = param.propIds
	end
	local succCb = function(err, data)
		CC.Player.Inst():ChangeProp(data);
		if param.succCb then
			param.succCb()
		end
	end
	local errCb = function(err, data)
		CC.uu.Log("HallUtil.ReqPlayerCommonProps failed");
		if param.errCb then
			param.errCb()
		end
	end
	CC.Request("ReqGetSpecialProps", data, succCb, errCb)
end

function HallUtil.CheckTelBinded()
	local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0;
	local binded = bit.band(bindingFlag, CC.shared_enums_pb.EF_TelBinded) ~= 0;
	return binded;
end

function HallUtil.CheckFacebookBinded()
	local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0;
	local binded = bit.band(bindingFlag, CC.shared_enums_pb.EF_Binded) ~= 0;
	return binded;
end

function HallUtil.CheckLineBinded()
	local bindingFlag = CC.Player.Inst():GetLoginInfo().BindingFlag or 0;
	local binded = bit.band(bindingFlag, CC.shared_enums_pb.EF_LineBinded) ~= 0;
	return binded;
end

function HallUtil.CheckSafetyFactor(data)
	
	if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify") then
		return false
	end

	if HallUtil.CheckTelBinded() and (HallUtil.CheckFacebookBinded() or HallUtil.CheckLineBinded()) then
		return false;
	end
	
	CC.ViewManager.ShowLoading(true);
	CC.uu.DelayRun(0, function()
		CC.ViewManager.CloseLoading();
		CC.ViewManager.Open("SafetyCompleteView",data);
	end)
	return true;
end

--解绑手机
function HallUtil.UnBindTelephone(isReplace)
	--先设置安全码
	if not HallUtil.CheckSafePassWord() then
		return
	end

	local telephone = CC.Player.Inst():GetSelfInfo().Data.Player.Telephone
	local lan = CC.LanguageManager.GetLanguage("L_PersonalInfoView")
	
	CC.ViewManager.ShowMessageBox(lan.unbindTel,function()
		local callback = function(err,data)
			--验证安全码错误
		    if err ~= 0 then return end
			
			--请求解绑
			CC.Request("ReqUnbindTelBySMS",{Tel = telephone,SafeToken = data.Token},function()
				local selfInfo = CC.Player.Inst():GetSelfInfo();
				selfInfo.Data.Player.Telephone = ""
				local loginData = CC.Player.Inst():GetLoginInfo();
				loginData.BindingFlag = bit.bxor(loginData.BindingFlag, CC.shared_enums_pb.EF_TelBinded)
				CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeTelephone);
				CC.ViewManager.ShowTip(lan.unbindTelSucc)

				if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify") then
					--解绑成功重新绑定手机
					CC.ViewManager.Open("BindTelView")
				end
			end,function()
				CC.ViewManager.ShowTip(lan.unbindTelFail)
			end)
		end
		
		--先验证安全码
		if not CC.Player.Inst():GetSafeCodeData().SafeService[6].Status then
			CC.ViewManager.Open("VerSafePassWordView",{serviceType = 6,confirmStr = lan.confirmUnbind,verifySuccFun = callback})
		else
			callback(0,{Token = ""})
		end
	end)
end

--检查是否有设置安全码，没有就设置
function HallUtil.CheckSafePassWord()
	if CC.Player.Inst():GetSafeCodeData().SafeStatus == 0 then
		local lan = CC.LanguageManager.GetLanguage("L_VerSafePassWordView")
		local box = CC.ViewManager.ShowMessageBox(lan.setPassWordTip,function()
			CC.ViewManager.Open("SetSafePassWordView")
		end)
		box:SetOneButton()
		box:SetOkText(lan.set)
		return false
	else
		return true
	end
end

--检查是否能买万圣节登录有礼礼包
function HallUtil.IsHalloweenLoginGiftCanBuy()
	--2023年2月5号之后不允许购买
	local limitY = 2023
	local limitM = 6
	local limitD = 5
	local date = CC.TimeMgr.GetTimeInfo()
	if date then
		if (date.year >= limitY and date.month >= limitM and date.day >= limitD) 
			or (date.year >= limitY and date.month > limitM) or date.year > limitY then
			return false
		else
			return true
		end
	end
	return false
end

--是否显示登录有礼礼包
function HallUtil.ShowHalloweenLoginGift()
	local epcWaterSign = CC.Player.Inst():GetSelfInfoByKey("EPC_TenGift_Sign_88")
	local isShow = HallUtil.IsHalloweenLoginGiftCanBuy() or (epcWaterSign and epcWaterSign > 0)
	return isShow
end

--获取当前服务器时间
function HallUtil.GetCurServerTime(timestamp)
	local time = CC.TimeMgr.GetTimeInfo()
	if not time then 
		logError("+++++Error getting server time. Use local time+++++")
		time = os.date("*t", os.time()) 
	end
	CC.uu.Log(time,"GetCurServerTime")
	if timestamp then
		local tiStamp = os.time({year = time.year,month = time.month,day = time.day,hour = time.hour,min = time.min,sec = time.sec})
	    return tiStamp
	else
		return time
	end
end

local hallCamera;
function HallUtil.OnShowHallCamera(flag)
	if not CC.ViewManager.IsHallScene() then
		return;
	end
	if not hallCamera then
		hallCamera = GameObject.Find("HallCamera/GaussCamera"):GetComponent("Camera");
	end
	if hallCamera then
		hallCamera:SetActive(flag);
	end
end

--检测指定渠道实名验证
--[[
配置：
BankEnum:shared_enums的RealAuthBankEnum
AmountLimit:支付金额(thb) >= AmountLimit 的需要验证
]]
function HallUtil.GetRealAuthStates(wareData,succCb)
	local config = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetRealAuthCfg()
	local param = config[wareData.commodityType]
	local amount = wareData.price/100
	if param and amount >= param.AmountLimit then
		local data = {}
		data.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
		data.IsGetAll = true --true查询所有银行
		--data.BankId = param.BankEnum --查询指定银行
		CC.Request("ReqGetRealAuthInfo",data,
			function (err,result)
				CC.uu.Log(result,"OnGetRealAuthInfoRsp",1)
				local status = nil
				local list = {}
				for _,v in ipairs(result.RealAuthInfos) do
					list[v.BankId] = v.RealAuth
					if v.BankId == param.BankEnum then
						status = v.RealAuth
					end
				end

				local openViewFunc = function()
					CC.ViewManager.Open("IdentityVerificationView",{BankChannelID = param.BankEnum, StatesList = list})
				end

				if status == CC.shared_enums_pb.RAE_AuthSuc then
					succCb() --通过验证，返回支付
				elseif status == CC.shared_enums_pb.RAE_AuthCheck then
					local tips = CC.LanguageManager.GetLanguage("L_IdentityVerificationView").reviewTips
					CC.ViewManager.ShowConfirmBox(tips)
				elseif status == CC.shared_enums_pb.RAE_AuthFail then
					local tips = CC.LanguageManager.GetLanguage("L_IdentityVerificationView").failedTips
					CC.ViewManager.ShowConfirmBox(tips,openViewFunc)
				else
					openViewFunc()
				end
			end,
			function (err,result)
				
			end)
	else
		succCb() --不需要验证的渠道，返回支付
	end
end

function HallUtil.RotateCamera()
	CC.uu.LoadHallPrefab("prefab","hallSupportRotate",GameObject.Find("HallCamera/GUICamera").transform)
	CC.uu.DelayRun(1.0,function()
		CC.uu.destroyObject(GameObject.Find("HallCamera/GUICamera/hallSupportRotate"))
	end)
end

return HallUtil