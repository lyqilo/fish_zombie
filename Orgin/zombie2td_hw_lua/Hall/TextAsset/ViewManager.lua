
local CC = require("CC")

local ViewManager = {}

--大厅启动场景名字
local _hallRootName = "root"
--大厅主场景名字
local _hallMainName = "main"

--大厅任意一个时刻只有一个基层view，其他view都以弹窗的形式存在
local replaceView = nil
--在view上层打开的open，以弹窗形式存在，可以有多个，比如个人信息框
local openViewList = {}
--从屏幕上方弹出来的提示，任意一时刻，最多只存在一个
local iTip = nil
--从屏幕上方弹出来的邀请提示，任意一时刻，最多只存在一个
local iInviteTip = nil
--全屏转菊花的等待页面，任意一时刻，最多只存在一个
local iWaitTip = nil
--主动转菊花
local iLoadingTip = nil
--提示用弹窗，比如网络断线提示这种，任意一时刻，最多只存在一个
local iMsgbox = nil
--安卓返回弹窗
local iBackMsgbox = nil
--喇叭
local iSpeakBoard = nil
--跑马灯
local iNoticeBoard = nil
--任务
local iTaskProgress = nil
--聊天面板
local iChatPanel = nil
--判断是不是在游戏内
local _isInHall = true

--奖励队列
local _OtherViewEx = nil

--消息弹窗队列
local _MessageBoxEx = nil

local _gameId = nil

--记录游戏场信息
local _groupId = nil

-- 需要打开选场界面的游戏id
local _needToGoGameId = nil

--引导退出游戏id
local _ExitToGuideId = nil

local _isGameEntering = false

--大厅掉线标志
local _hallDisconnectTags = {
	Normal  = 0,
	Reconnecting = 1,
	Disconnected = 2
}

--大厅掉线标记
local _hallDisconnectTag = _hallDisconnectTags.Normal

local function OpenView(isReplace,viewName, ...)

	if ViewManager.IsViewOpen(viewName) then
		return
	end
	--判断界面能否开启
	if not ViewManager.IsSwitchOn(viewName) then
		return
	end

	if isReplace then
		ViewManager.CloseAllOpenView()
	end

	local view = CC.uu.SafeDoFunc(CC.uu.CreateHallView, viewName, ...)
	if view then
		--监听页面被销毁，清除他在viewlist中的保存
		view.OnDestroyFinish = function(view)
			for i,v in ipairs(openViewList) do
				if v == view then
					table.remove(openViewList,i)
					break
				end
			end

			local currentView = ViewManager.GetCurrentView();
			--聚焦当前界面回调
			if currentView and currentView.OnFocusIn then
				currentView:OnFocusIn();
			end
		end

		local currentView = ViewManager.GetCurrentView();
		--当前界面失去焦点回调
		if currentView and currentView.OnFocusOut then
			currentView:OnFocusOut();
		end

		table.insert(openViewList,view)

		if view.ActionIn then
			view:ActionIn();
		end
	end
	return view
end

local function ReplaceView(viewName, ...)
	ViewManager.CloseAllView()

	local view = CC.uu.SafeDoFunc(CC.uu.CreateHallView, viewName, ...)
	if view then
		--监听页面被销毁，清除他在viewlist中的保存
		view.OnDestroyFinish = function(view)
			replaceView = nil
		end
		replaceView = view
	end
	return view
end

function ViewManager.IsSwitchOn(viewName)
	--这里检测后台开关配置
	local switchOn = true;
	local switchMap = CC.ConfigCenter.Inst():getConfigDataByKey("SwitchMap");
	if switchMap[viewName] then
		switchOn = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey(switchMap[viewName].key);
	end
	if not switchOn and not switchMap[viewName].hideTip then
		local language = CC.LanguageManager.GetLanguage("L_Common");
		ViewManager.ShowTip(language.tip1);
	end
	return switchOn;
end

function ViewManager.Start()
	CC.HallNotificationCenter.inst():register(ViewManager,function()
		_hallDisconnectTag = true
	end,CC.Notifications.OnReLoginDisconnectToLogin)

	CC.HallNotificationCenter.inst():register(ViewManager,function()
		ViewManager.OnMenuBack()
	end,CC.Notifications.OnMenuBack)
end

function ViewManager.OnMenuBack()
	if _isInHall then

		local view = CC.ViewManager.GetCurrentView();
		if view and view.viewName == "WebServiceView" then return end;
		local function confirm()
			Application.Quit()
		end
		local function cancel()

		end

		local language = CC.LanguageManager.GetLanguage("L_MessageBox");
		CC.ViewManager.OpenBackMsgBox(language.contentExitGame,confirm,cancel);
	end
end

--正常流程进入大厅
function ViewManager.CommonEnterMainScene()
    local CC = require("CC")
    ViewManager.CloseAllView(true)
	Time.timeScale = 1;
    local callback = function ()
		local resDefine = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine")
		local cameraBundle = resDefine.Prefab["HallCamera"] or "prefab"
		local gNodeBundle = resDefine.Prefab["GNode"] or "prefab"
    	--大厅UI相机，不销毁节点
    	UnityEngine.Object.DontDestroyOnLoad(ResMgr.LoadPrefab(cameraBundle,"HallCamera",nil,nil,nil).gameObject)
    	--挂载切换游戏场景是不销毁的大厅节点，并设置Canvas的相机
    	local dontDestroyNode = ResMgr.LoadPrefab(gNodeBundle,"GNode",nil,"DontDestroyGNode",nil)
    	dontDestroyNode:Find("GaussCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GaussCamera"):GetComponent("Camera")
		dontDestroyNode:Find("GaussCanvas"):GetComponent("Canvas").sortingOrder = 1
    	dontDestroyNode:Find("GCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")
		dontDestroyNode:Find("GCanvas"):GetComponent("Canvas").sortingOrder = 2
		dontDestroyNode:Find("GPortraitCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")
		dontDestroyNode:Find("GPortraitCanvas"):GetComponent("Canvas").sortingOrder = 1
    	UnityEngine.Object.DontDestroyOnLoad(dontDestroyNode.gameObject)
    	--挂载随游戏场景切换而自动销毁的大厅节点，并设置Canvas的相机
    	local gNode = ResMgr.LoadPrefab(gNodeBundle,"GNode",nil,nil,nil)
    	gNode:Find("GaussCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GaussCamera"):GetComponent("Camera")
    	gNode:Find("GCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")
    	gNode:Find("GPortraitCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")

    	ViewManager.Replace("LoginView",CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.Common);

    	ViewManager.SetCurGameId(1);	--大厅id为1
    	ViewManager.SetCurGroupId(0);	--默为0
		CC.DebugDefine.SaveDebugKey();
    end
    CC.uu.changeScene(CC.ViewManager.GetHallMainSceneName(), true, function()
		callback()
    end )
end

--游戏游戏回到大厅检测是否断线
function ViewManager.CheckGameDisconnect()

	if _hallDisconnectTag  ==  _hallDisconnectTags.Disconnected then
		_hallDisconnectTag = false
		ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.Reconnect, true);
	elseif _hallDisconnectTag  ==  _hallDisconnectTags.Reconnecting then
		ViewManager.Replace("HallView")
		-- ViewManager.ShowConnecting()
	else
		ViewManager.Replace("HallView")
	end
end

--给独立选场提供断线踢回登录界面
function ViewManager.BackToLoginByDisconnect()
	if _hallDisconnectTag  ==  _hallDisconnectTags.Disconnected then
		_hallDisconnectTag = _hallDisconnectTags.Normal
		ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.Reconnect, true);
	end
end

--给独立选场的游戏检测大厅是否断开链接
function ViewManager.CheckHallDisconnect()
	if _hallDisconnectTag  ==  _hallDisconnectTags.Disconnected then
		return true;
	end
	return false;
end

--游戏返回大厅
function ViewManager.GameEnterMainScene(callFunc)
    ViewManager.CloseAllView(true)

    local callback = function()
    	--挂载随游戏场景切换而自动销毁的大厅节点，并设置Canvas的相机
		local resDefine = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine")
		local gNodeBundle = resDefine.Prefab["GNode"] or "prefab"
    	local gNode = ResMgr.LoadPrefab(gNodeBundle,"GNode",nil,nil,nil)
    	gNode:Find("GaussCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GaussCamera"):GetComponent("Camera")
    	gNode:Find("GCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")
		gNode:Find("GPortraitCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")
		
    	_isInHall = true
		vModuleLuaPathClear()
		ViewManager.HallLoad()
        ViewManager.CheckGameDisconnect()
        ResourceManager.UnloadGameAssetBundles()
        if callFunc then
        	callFunc();
        end
    end
    CC.uu.changeScene(ViewManager.GetHallMainSceneName(), true, callback)
end

--大厅进入游戏
function ViewManager.EnterGame(data,gameId)
	_isGameEntering = true
	ViewManager.ShowConnecting()
	Time.timeScale = 1;
	CC.HallNotificationCenter.inst():post(CC.Notifications.GameClick,false)
	local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
	local resourceName = gameDataMgr.GetResNameByID(gameId)
	local projectName = gameDataMgr.GetProNameByID(gameId) -- 目录名称，兼容三方游戏
	log("EnterGame: resourceName " .. resourceName .. "  projectName:" .. projectName)
	LuaFramework.GameManager.LoadGameModule(resourceName,projectName,function(msg)
		if msg == "ok" then
			log("-------准备进入游戏：msg:" .. msg.."projectName:"..projectName)
			ViewManager.CloseAllView(true)
			local MJGame = require "MJGame"
			CC.uu.changeScene(resourceName, true, function()
				CC.LocalGameData.SetDailyStateByKey("TodayEnterGame", true)
				ViewManager.CloseConnecting()
				ViewManager.CloseTip()
				--挂载随游戏场景切换而自动销毁的大厅节点，并设置Canvas的相机
				local resDefine = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine")
				local gNodeBundle = resDefine.Prefab["GNode"] or "prefab"
				local gNode = ResMgr.LoadPrefab(gNodeBundle,"GNode",nil,nil,nil)
				gNode:Find("GaussCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GaussCamera"):GetComponent("Camera")
				gNode:Find("GCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")
				gNode:Find("GPortraitCanvas"):GetComponent("Canvas").worldCamera = GameObject.Find("HallCamera/GUICamera"):GetComponent("Camera")
				--进入游戏解除模糊效果
				GameObject.Find("HallCamera/GaussCamera"):GetComponent("GaussBlur").enabled = false
				ViewManager.HallRelease();
				BuglyUtil.SetGameProjectName(resourceName)
				ViewManager.SetCurGameId(gameId);
				if not gameDataMgr.GetThirdGameNameByID(gameId) then
					--不是第三方游戏
					CC.LocalGameData.SetRecentGame(gameId)
				end
				ResourceManager.ReleaseHallAssets();
				CC.FirebasePlugin.TrackEnterGame(gameId);
				-- CC.ReportQManager.Upload()
				_isInHall = false
				_isGameEntering = false
				MJGame.Start(data)
			end)
		else
			logError("游戏加载失败")
			ViewManager.CloseConnecting()
			CC.HallNotificationCenter.inst():post(CC.Notifications.GameClick,true)
		end
	end)
end

function ViewManager.SubGameToGame(gameId,callback)
	local okCB = function()
	    CC.ResDownloadManager.CheckGame(gameId, function()
	            local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game");
	            local gameData = table.copy(gameDataMgr.GetInfoByID(gameId))
	            -- 提供 确认进入方法，为了 方便子游戏做二次确认 ，而不是直接调用
	            local enterFunc = function (enterData)
	                vModuleLuaPathClear()
	                ResourceManager.UnloadGameAssetBundles()
	                CC.ViewManager.EnterGame(enterData,gameId)
	            end
	            callback(enterFunc,gameData)
	        end)
	end
    CC.HallUtil.CheckGroupConfig(gameId, okCB)
end

function ViewManager.SetBuglySceneId(sceneKey)
	if not CC.Platform.isAndroid and not CC.Platform.isIOS then
		return;
	end
	local platform = CC.Platform.isIOS and 2 or 1;
	local buglySceneMap = CC.ConfigCenter.Inst():getConfigDataByKey("BuglySceneMap");
	if not buglySceneMap[sceneKey] then
		local id = buglySceneMap["Unknown"][platform];
		BuglyUtil.SetScene(id);
		return;
	end
	local id = buglySceneMap[sceneKey][platform];
	BuglyUtil.SetScene(id);
end

function ViewManager.SetCurGameId(gameId)
	_gameId = gameId or 0
end

function ViewManager.GetCurGameId()
	return _gameId
end

function ViewManager.SetCurGroupId(groupId)
	_groupId = groupId or 0
end

function ViewManager.GetCurGroupId()
	return _groupId
end

--返回登录
function ViewManager.BackToLogin(loginType, unReq2Publisher)
	local callback = function()
		CC.DataMgrCenter.Inst():GetDataByKey("Game").CleanGuide();
		ViewManager.HallRelease(true);
		ViewManager.Replace("LoginView",loginType);
	end
	--重连不需要请求断开publisher
	if unReq2Publisher then
		callback();
	else
		CC.Request("ReqUnreg2Publisher",nil,function()
			callback();
		end)
	end
end

function ViewManager.HallLoad()

	BuglyUtil.SetGameProjectName("HallCenter")

	ViewManager.SetCurGameId(1);	--大厅id为1

	ViewManager.SetCurGroupId(0);	--默为0

	CC.FirebasePlugin.ClearDynamicLink();
	CC.FacebookPlugin.ClearDynamicLink();
	CC.HttpMgr.DisposeWithoutCache();
end

function ViewManager.HallRelease(isBackToLogin)

	if isBackToLogin then
		CC.Player.Inst():ReleasePortraitTexture();
		CC.DataMgrCenter.Inst():GetDataByKey("Mail").ResetReqState()
		CC.DataMgrCenter.Inst():GetDataByKey("Friend").ResetInitState()
		CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetReqGiftState(false)
		CC.ChatManager.ResetPrivateState()
		CC.ChatManager.ResetChatCacheMsgTable()
		ViewManager.HideChatPanel();
		CC.HttpMgr.DisposeAll();
	end
	--进入游戏后，讲引导保存游戏ID置空
	ViewManager.SetExitToGuideId(nil)

	--释放广告图缓存
	CC.MessageManager.ClearCache()

	CC.Sound.StopBackMusic();

	--清理动态链接缓存
	CC.FirebasePlugin.ClearDynamicLink();
	CC.FacebookPlugin.ClearDynamicLink();
end

function ViewManager.TagGameDisconnecting()
	_hallDisconnectTag = _hallDisconnectTags.Reconnecting
end

function ViewManager.TagGameDisconnected()
	_hallDisconnectTag = _hallDisconnectTags.Disconnected
end

--打开大厅弹窗类界面，viewName为界面名字，通过该名字查找界面类
-- ... 为界面类ctor方法的参数
function ViewManager.Open(viewName, ...)
	-- local time = os.clock()
	local view = OpenView(false,viewName, ...)
	-- CC.uu.Log(os.clock()-time, tostring(viewName).."初始化耗时:", 3)
	return view
end

--打开大厅弹窗类界面，viewName为界面名字，通过该名字查找界面类（出现重叠的界面调用这个函数）
-- ... 为界面类ctor方法的参数
function ViewManager.OpenEx(viewName, ...)
	return CC.OverlappingManager.GetInstance():Open(viewName, ...)
end

function ViewManager.OpenOtherEx(viewName, ...)
	if not _OtherViewEx then
		_OtherViewEx = CC.OverlappingManager.new()
	end
	return _OtherViewEx:Open(viewName, ...)
end

function ViewManager.OpenMessageBoxEx(str,okFunc,noFunc)
	if not _MessageBoxEx then
		_MessageBoxEx = CC.OverlappingManager.new()
	end
	return _MessageBoxEx:Open("MessageBox", str, okFunc, noFunc)
end

--作用同ViewManager.Open，不过会关闭所有其他弹窗类界面
function ViewManager.OpenAndReplace(...)
	return OpenView(true,...)
end

--大厅任意一个时刻只有一个基层view，其他view都以弹窗的形式存在
function ViewManager.Replace(...)
	return ReplaceView(...)
end

function ViewManager.CloseAllOpenView(destroyOnLoad)
	for i = #openViewList, 1, -1 do
		openViewList[i]:Destroy(destroyOnLoad)
	end
	openViewList = {}
end

function ViewManager.CloseReplaceView(destroyOnLoad)
	if replaceView then
		replaceView:Destroy(destroyOnLoad)
	end
	replaceView = nil
end

--关闭所有view，一般场景切换到游戏需要调用该方法
--！！！注意，该文件内新加的大厅页面变量，在执行该方法是，记得关掉它
function ViewManager.CloseAllView(destroyOnLoad)
	ViewManager.CloseAllOpenView(destroyOnLoad)
	ViewManager.CloseReplaceView(destroyOnLoad)
	ViewManager.CloseMessageBox(destroyOnLoad)
	ViewManager.CloseNoticeView(destroyOnLoad)

	CC.OverlappingManager.GetInstance():clear()
end

--游戏上方往下的弹框提示
function ViewManager.ShowTip( str, second, callback)
	if iTip then iTip:Destroy() end
	local data = {};
	data.des = str;
	data.second = second;
	data.callback = callback;
	iTip = CC.uu.CreateHallView("Tip", data);
	iTip.OnDestroyFinish = function()
		iTip = nil
	end
	return iTip;
end

--关闭Tip
function ViewManager.CloseTip()
	if iTip then iTip:Destroy() end
end

--游戏上方往下的邀请提示
function ViewManager.ShowInviteTip( str, second, teamId, gameId)
	if iInviteTip then iInviteTip:Destroy() end
	local data = {};
	data.des = str;
	data.second = second;
	data.teamId = teamId;
	data.gameId = gameId;
	iInviteTip = CC.uu.CreateHallView("InviteTip", data);
	iInviteTip.OnDestroyFinish = function()
		iInviteTip = nil
	end
	return iInviteTip;
end

--关闭Tip
function ViewManager.CloseInviteTip()
	if iInviteTip then iInviteTip:Destroy() end
end

--自动转菊花的等待页面
--b：延迟转圈   time：延迟几秒
function ViewManager.ShowConnecting(b,time)
	-- logError("！！！手动调用loading请用ViewManager.ShowLoading()，自动调用的请无视\n" .. debug.traceback())
	ViewManager.CloseConnecting()
	iWaitTip = CC.uu.CreateHallView("ConnectingView",b,time)
	iWaitTip.OnDestroyFinish = function( tip )
		if iWaitTip == tip then
			iWaitTip = nil
		end
	end
	return iWaitTip
end

--关闭转菊花的等待页面
function ViewManager.CloseConnecting(destroyOnLoad)
	if iWaitTip then
		iWaitTip:Destroy(destroyOnLoad)
	end
end

--手动转菊花的等待页面
--b：延迟转圈   time：延迟几秒
function ViewManager.ShowLoading(b,time)
	ViewManager.CloseLoading()
	iLoadingTip = CC.uu.CreateHallView("ConnectingView",b,time)
	iLoadingTip.OnDestroyFinish = function( tip )
		if iLoadingTip == tip then
			iLoadingTip = nil
		end
	end
	return iLoadingTip
end

--关闭转菊花的等待页面
function ViewManager.CloseLoading(destroyOnLoad)
	if iLoadingTip then
		iLoadingTip:Destroy(destroyOnLoad)
	end
end

--调用自定义的弹窗
function ViewManager.OpenMessageBox( viewName, ... )
	ViewManager.CloseMessageBox()
	iMsgbox = CC.uu.CreateHallView(viewName, ...)
	iMsgbox.OnDestroyFinish = function( msgBox )
		if iMsgbox == msgBox then
			iMsgbox = nil
		end
	end
	iMsgbox:Show()
	return iMsgbox
end

--调用默认的MessageBox弹窗
function ViewManager.ShowMessageBox( str, okFunc, noFunc,layer)
	return ViewManager.OpenMessageBox("MessageBox", str, okFunc, noFunc, layer)
end

function ViewManager.ShowConfirmBox(str, okFunc, noFunc, layer, confirmSec)
	local box = ViewManager.OpenMessageBox("MessageBox", str, okFunc, noFunc, layer, confirmSec)
	box:SetOneButton()
	return box
end

function ViewManager.MessageBoxExtend(param)
	return ViewManager.OpenMessageBox("MessageBoxExtend",param)
end

--关闭弹窗
function ViewManager.CloseMessageBox(destroyOnLoad)
	if iMsgbox then
		iMsgbox:Destroy(destroyOnLoad)
		iMsgbox = nil
	end
end

--打开安卓返回按钮弹窗
function ViewManager.OpenBackMsgBox(str, okFunc, noFunc)
	if iBackMsgbox then return end
	iBackMsgbox = CC.uu.CreateHallView("MessageBox", str, okFunc, noFunc, 5000)
	iBackMsgbox.OnDestroyFinish = function( msgBox )
		if iBackMsgbox == msgBox then
			iBackMsgbox = nil
		end
	end
	iBackMsgbox:Show()
	return iBackMsgbox
end

function ViewManager.CloseBackMsgBox()
	if iBackMsgbox then
		iBackMsgbox:Destroy(false)
		iBackMsgbox = nil
	end
end

--聊天面板相关
function ViewManager.ShowChatPanel(data)
	if not CC.ChatManager.ChatPanelToggle() then
		return
	end
	if not iChatPanel then
		iChatPanel = CC.uu.CreateHallView("ChatPanel",data)
		iChatPanel.OnDestroyFinish = function()
			iChatPanel = nil
		end
		CC.uu.panelShowAction(iChatPanel, iChatPanel, 1)
	else
		iChatPanel:OpenPriChat(data)
	end
	return iChatPanel
end

function ViewManager.HideChatPanel()
	if iChatPanel then
		iChatPanel:Destroy()
        iChatPanel = nil
	end
end

function ViewManager.GetChatPanel()
	return iChatPanel
end

--喇叭跑马灯
function ViewManager.UpdateSpeakBoard(tip)
	if not CC.ChatManager.GetSpeakBordState() then return end

    if not iSpeakBoard then
        iSpeakBoard = CC.uu.CreateHallView("SpeakerBord")
        iSpeakBoard.OnDestroyFinish = function()
            iSpeakBoard = nil
        end
    end
    iSpeakBoard:Show(tip)
end

function ViewManager.SetSpeakBoardPos(vec3)
	if iSpeakBoard then
		iSpeakBoard:SetDeltaPos(vec3)
	else
		iSpeakBoard = CC.uu.CreateHallView("SpeakerBord")
		iSpeakBoard:Hide()
        iSpeakBoard.OnDestroyFinish = function()
            iSpeakBoard = nil
        end
        iSpeakBoard:SetDeltaPos(vec3)
	end
end

function ViewManager.SetSpeakBoardPosEx(vec3)
	if not iSpeakBoard then
		iSpeakBoard = CC.uu.CreateHallView("SpeakerBord")
		iSpeakBoard:Hide()
        iSpeakBoard.OnDestroyFinish = function()
            iSpeakBoard = nil
        end
	end
	if iSpeakBoard then
		local designHeight = 720
		local y = -(iSpeakBoard.transform.rect.height-(designHeight+vec3.y))
		vec3.y = y
		iSpeakBoard:SetDeltaPos(vec3)
	end
end

function ViewManager.SetSpeakBoardWidth(width)
	if iSpeakBoard then
		iSpeakBoard:SetWidth(width)
	else
		iSpeakBoard = CC.uu.CreateHallView("SpeakerBord")
		iSpeakBoard:Hide()
        iSpeakBoard.OnDestroyFinish = function()
            iSpeakBoard = nil
        end
        iSpeakBoard:SetWidth(width)
	end
end

function ViewManager.CloseSpeakBoard(destroyOnLoad)
	if iSpeakBoard then
		iSpeakBoard:Destroy(destroyOnLoad)
	end
end

local RewardNoticeView = nil
local RewardNoticeView_isOpen = true
local RewardNoticeView_isLeft = false
local RewardNoticeView_offset = 0
function ViewManager.ShowRewardNoticeView( data, immediately)
	if RewardNoticeView_isOpen then
		if RewardNoticeView == nil then
			RewardNoticeView = CC.uu.CreateHallView("RewardNoticeView")
		end
		RewardNoticeView:Show(data, RewardNoticeView_isLeft, RewardNoticeView_offset, immediately)
	end
end

function ViewManager.SetRewardNoticeView(isOpen, isLeft, offset)
	if isOpen == nil then
		RewardNoticeView_isOpen = true
	else
		RewardNoticeView_isOpen = isOpen
	end
	RewardNoticeView_isLeft = isLeft or false
	RewardNoticeView_offset = offset or 0
end

local ArenaNoticeView_isOpen = false
local ArenaNoticeView_isLeft = false
local ArenaNoticeView_offset = 0
local ArenaNoticeView_whiteList = {}

function ViewManager.ShowArenaNoticeView( data, immediately, gameId)
	if ArenaNoticeView_isOpen then
		if RewardNoticeView == nil then
			RewardNoticeView = CC.uu.CreateHallView("RewardNoticeView")
		end

		if gameId and ArenaNoticeView_whiteList and type(ArenaNoticeView_whiteList) == "table" and #ArenaNoticeView_whiteList > 0 then
			for _,id in ipairs(ArenaNoticeView_whiteList or {}) do
				if id == gameId then
					RewardNoticeView:Show(data, ArenaNoticeView_isLeft, ArenaNoticeView_offset, immediately)
					return
				end
			end
		else
			RewardNoticeView:Show(data, ArenaNoticeView_isLeft, ArenaNoticeView_offset, immediately)
		end
	end
end

function ViewManager.SetArenaNoticeView(isOpen, isLeft, offset, whiteList)
	ArenaNoticeView_isOpen = isOpen
	ArenaNoticeView_isLeft = isLeft or false
	ArenaNoticeView_offset = offset or 0
	ArenaNoticeView_whiteList = whiteList or {}
end

function ViewManager.CloseNoticeView(destroyOnLoad)
	if RewardNoticeView then
		RewardNoticeView:Destroy(destroyOnLoad)
		RewardNoticeView = nil
	end
end

--系统跑马灯
local CreateNoticeBord = function()
	if not iNoticeBoard then
		iNoticeBoard = CC.uu.CreateHallView("NoticeBord")
		iNoticeBoard:Hide()
        iNoticeBoard.OnDestroyFinish = function()
            iNoticeBoard = nil
        end
	end
	return iNoticeBoard
end

function ViewManager.UpdateNoticeBord(resp)
	if not ViewManager.IsSwitchOn("NoticeBord") then
		return;
	end
	if not CC.ChatManager.GetNoticeBordState() then return end

	iNoticeBoard = CreateNoticeBord()
	if iNoticeBoard then
		iNoticeBoard:Show(resp)
	end
end

function ViewManager.SetNoticeBordPos(vec3)
	iNoticeBoard = CreateNoticeBord()
	if iNoticeBoard then
		iNoticeBoard:SetDeltaPos(vec3)
	end
end

function ViewManager.SetNoticeBordWidth(width)
	iNoticeBoard = CreateNoticeBord()
	if iNoticeBoard then
		iNoticeBoard:SetWidth(width)
	end
end

function ViewManager.SetNoticeBordEffectState(state)
	iNoticeBoard = CreateNoticeBord()
	if iNoticeBoard then
		iNoticeBoard:SetEffectState(state)
	end
end

function ViewManager.SetNoticeBordPosEx(vec3)
	iNoticeBoard = CreateNoticeBord()
	if iNoticeBoard then
		local designHeight = 720
		local y = -(iNoticeBoard.transform.rect.height-(designHeight+vec3.y))
		vec3.y = y
		iNoticeBoard:SetDeltaPos(vec3)
	end
end

function ViewManager.CloseNoticeBoard(destroyOnLoad)
	if iNoticeBoard then
		iNoticeBoard:Destroy(destroyOnLoad)
		iNoticeBoard = nil
	end
end

function ViewManager.UpdateTaskProgress(str, id, second, finishCall)
	if iTaskProgress then iTaskProgress:Destroy() end
	iTaskProgress = CC.uu.CreateHallView("TaskProgress", str, id, second, finishCall)
	iTaskProgress.OnDestroyFinish = function()
		iTaskProgress = nil
	end
	iTaskProgress:GoDown()
end

--获取大厅启动场景名字
function ViewManager.GetHallRootSceneName()
	return _hallRootName
end

--获取大厅主场景名字
function ViewManager.GetHallMainSceneName()
	return _hallMainName
end

--获取当前场景名字
function ViewManager.GetTempSceneName()
	return LuaFramework.SceneManager.GetCurSceneName()
end

--判断是否大厅场景
function ViewManager.IsHallScene()
	return _isInHall
end

function ViewManager.IsGameEntering()
	return _isGameEntering
end

--判断某页面是否已经打开
function ViewManager.IsViewOpen(viewName)
	local isExist = false
	for i,v in ipairs(openViewList) do
		if v.viewName == viewName then
			isExist = true
			break
		end
	end
	return isExist
end

function ViewManager.GetCurrentView()

	if #openViewList == 0 then

		return replaceView
	end
	return openViewList[#openViewList];
end

function ViewManager.GetReplaceView()
	if replaceView then
		return replaceView
	end
end

function ViewManager.GetViewByName(viewName)
	for i,v in ipairs(openViewList) do
		if v.viewName == viewName then
			return v
		end
	end
	return nil
end
---------------------------------
	--param.items	奖励数组
	--param.title	通用奖励弹窗标题
	--param.callback	回调
	--param.tips	通用奖励弹窗Tips，用于提示玩家，例:提示玩家点卡需要去邮箱领取
	--param.gameTips	游戏内传出Tips,用于游戏显示通用奖励弹窗Tips
	--param.btnText	确定按钮改文字
	--param.splitState	是否拆分，True的话，不会合并同一个数组里相同ID的奖励
	--param.needShare 是否显示分享按钮
	--param.source	奖励源
---------------------------------
function ViewManager.OpenRewardsView(param)
	local items = param.items
	local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	local data = {};
	local index = 1
	for _,v in ipairs(items) do
		if v.Delta and propCfg[v.ConfigId] and propCfg[v.ConfigId].IsReward then
			if v.Delta > 0 then
				data[index] = {}
				data[index].Crit = v.Crit;
				data[index].ConfigId = v.ConfigId;
				data[index].Count = v.Delta;
				index = index + 1
			end
		elseif v.Count and propCfg[v.ConfigId] and propCfg[v.ConfigId].IsReward then
			if v.Count > 0 then
				data[index] = {}
				data[index].Crit = v.Crit;
				data[index].ConfigId = v.ConfigId;
				data[index].Count = v.Count;
				index = index + 1
			end
		end
	end
	param.data = data
	if not table.isEmpty(data) then
		return ViewManager.OpenOtherEx("RewardsView", param);
	end
end

function ViewManager.SetNeedToGoGameId(gameId)
	_needToGoGameId = gameId
end

function ViewManager.GetNeedToGoGameId()
	return _needToGoGameId
end

function ViewManager.SetExitToGuideId(gameId)
	_ExitToGuideId = gameId
end

function ViewManager.GetExitToGuideId(gameId)
	return _ExitToGuideId
end

function ViewManager.OpenMarsTaskRewardsView(param)
	local items = param.items
	local propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	local data = {};
	for i,v in ipairs(items) do
		if v.Delta and propCfg[v.ConfigId] and propCfg[v.ConfigId].IsReward then
			if v.Delta > 0 then
				data[i] = {}
				data[i].Crit = v.Crit;
				data[i].ConfigId = v.ConfigId;
				data[i].Count = v.Delta;
			end
		elseif v.Count and propCfg[v.ConfigId] and propCfg[v.ConfigId].IsReward then
			if v.Count > 0 then
				data[i] = {}
				data[i].Crit = v.Crit;
				data[i].ConfigId = v.ConfigId;
				data[i].Count = v.Count;
			end
		end
	end
	param.data = data
	if not table.isEmpty(data) then
		return ViewManager.OpenOtherEx("MarsTaskRewardsView", param);
	end
end

function ViewManager.OpenServiceView(param)
	local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("WebService");
	if switchOn and not CC.Platform.isWin32 and not Application.isEditor then
		-- local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebServiceUrl();
		-- Client.OpenURL(url)
		CC.ViewManager.Open("WebServiceView")
	else
		CC.ViewManager.Open("SetUpServiceView",param)
	end
end

--[[
@param
webUrl:网页链接
可选：
title:标题
]]
function ViewManager.OpenCommonWebView(param)
	if not param.webUrl then return end

	--WebView仅支持http/https协议
	if Application.isEditor or CC.Platform.isWin32 or
		not Util.CheckHttpUrl(param.webUrl) then
		Client.OpenURL(param.webUrl)
	else
		CC.ViewManager.Open("CommonWebView",param)
	end
end

function ViewManager.IsHallViewOpened()
	if replaceView then
		return true
	end
	if not table.isEmpty(openViewList) then
		return true
	end
	return false
end

return ViewManager