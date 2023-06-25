local GC = require("GC")
local CC = require("CC")
local ZTD = {}

ZTD.updateList = {}
ZTD.fixedUpdateList = {}

ZTD.gamePath = "/ZombieTower/"
ZTD.isMusicMute = GC.Sound.GetMusicVolume() > 0 and true or false
ZTD.isEffectMute = GC.Sound.GetEffectVolume() > 0 and true or false
ZTD.isSaveMode = GC.UserData.Load(ZTD.gamePath.."Setting", {isSaveMode = false}).isSaveMode
--是否提示过可开启省电模式
ZTD.isSaveTip = GC.UserData.Load(ZTD.gamePath.."Setting")["isSaveTip"] or false

function ZTD.ClassView(viewName, bundleName, baseView)
    baseView = baseView or ZTD.ViewBase or require("_ZTD_Common/ZTD_ViewBase")
    bundleName = bundleName or "prefab"
    local c = GC.class2(viewName,baseView)
    c.bundleName = bundleName
    c.viewName = viewName
    return c
end

function ZTD.CreateView(viewName, ...)
    local viewLua = require("_ZTD_View/" .. viewName)
    if viewLua then
        local view = viewLua.new(...)
        view:Create()
        return view
    end
    logError("ZTD_CreateView " .. viewName .. " not find!")
end

-- 判断是否苹果4,5,6。这几款机型运行内存低，有些地方需要做特殊处理！
function ZTD.IsLowDevice()
    local deviceInfo = Client.GetDeviceInfo()
    if deviceInfo == nil or deviceInfo == "" then
        return false
    end
    if string.find(deviceInfo, "DeviceModel") then
        if string.find(deviceInfo, "iPhone 5")
            or(string.find(deviceInfo, "iPhone 6") and not string.find(deviceInfo, "iPhone 6s"))
            or string.find(deviceInfo, "iPhone 4") then
            return true
        end
    end
    return false
end
--2分钟平均帧率低于20帧，提示玩家可开启省电模式
--6s记录一次数据，记录20组数据
local minFps = 20
local totalTime = 120
local interval = 6
local frames = 0
local lastRecordTime = 0
local recordList = {}
function ZTD.Update()
	if ZTD.isSaveTip then
		return 
	end
	if ZTD.isSaveMode then
		frames = 0
		recordList = {}
		return
	end
	if frames == 0 then
		lastRecordTime = Time.realtimeSinceStartup
	end
	frames = frames + 1
	if frames % (minFps*interval) == 0 then
		table.insert(recordList, Time.realtimeSinceStartup - lastRecordTime)
		lastRecordTime = Time.realtimeSinceStartup
	end
	if #recordList > (totalTime/interval) then
		table.remove(recordList, 1)
		local total = 0
		for _,v in ipairs(recordList) do
			total = total + v
		end

		if total > totalTime then
			log('fps过低')
			local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
			local cancelFunc = function()
			end
			local confirmFunc = function()
				ZTD.SetSaveMode(true)
			end
			ZTD.ViewManager.OpenExtenPopView(language.content, confirmFunc, cancelFunc, language.btn_open, language.btn_noopen)
			ZTD.isSaveTip = true
			GC.UserData.Save(ZTD.gamePath.."Setting", {isSaveTip = ZTD.isSaveTip})
		end
	end
	
end
--添加更新函数
function ZTD.UpdateAdd(func, target)
	if ZTD.updateList[func] then
		ZTD.UpdateRemove(ZTD.updateList[func].func, ZTD.updateList[func].target)
		ZTD.updateList[func] = nil
	end
	UpdateBeat:Add(func, target)
	local tmp = {}
	tmp.func = func
	tmp.target = target
	ZTD.updateList[func] = tmp
end

--移除更新函数
function ZTD.UpdateRemove(func, target)
	UpdateBeat:Remove(func, target)
	ZTD.updateList[func] = nil
end

function ZTD.RemoveAllUpdates()
	for _, tmp in pairs(ZTD.updateList) do
		ZTD.UpdateRemove(tmp.func, tmp.target)
	end
	ZTD.updateList = {}
end

--添加固定时间更新函数
function ZTD.FixedUpdateAdd(func, target)
	if ZTD.fixedUpdateList[func] then
		ZTD.UpdateRemove(ZTD.fixedUpdateList[func].func, ZTD.fixedUpdateList[func].target)
		ZTD.fixedUpdateList[func] = nil
	end
	FixedUpdateBeat:Add(func, target)
	local tmp = {}
	tmp.func = func
	tmp.target = target
	ZTD.fixedUpdateList[func] = tmp
end

function ZTD.FixedUpdateRemove(func, target)
	FixedUpdateBeat:Remove(func, target)
	ZTD.fixedUpdateList[func] = nil
end

function ZTD.RemoveAllFixedUpdates()
	for _, tmp in pairs(ZTD.fixedUpdateList) do
		ZTD.FixedUpdateRemove(tmp.func, tmp.target)
	end
	ZTD.fixedUpdateList = {}
end

function ZTD.Init()
	ZTD.MJGame = require("MJGame")
	ZTD.Extend = require("_ZTD_Common/ZTD_Extend")
	ZTD.GameTimeClock = require("_ZTD_Common/ZTD_GameTimeClock")
	ZTD.GameTimer = require("_ZTD_Common/ZTD_GameTimer")
	ZTD.HallViewBase = require("_ZTD_Common/ZTD_HallViewBase")
	ZTD.Define = require("_ZTD_Define/ZTD_Define")

	ZTD.ViewBase = require("_ZTD_Common/ZTD_ViewBase")
	ZTD.ViewManager = require("_ZTD_Common/ZTD_ViewManager")
	
	ZTD.MathBit = require("_ZTD_Common/ZTD_MathBit")

	ZTD.TipConfig = require("_ZTD_Config/ZTD_TipConfig")

	ZTD.GameCenter = require("_ZTD_Logic/ZTD_GameCenter")
	ZTD.GameLogin = require("_ZTD_Logic/ZTD_GameLogin")
	
	--网络部分中，proto文件必须放在最前面被require
	ZTD.ClientProto = require("_ZTD_Network/ZTD_Proto")
	ZTD.NetworkHelper = require("_ZTD_Network/ZTD_NetworkHelper")
	ZTD.NetworkManager = require("_ZTD_Network/ZTD_NetworkManager")

	ZTD.Request = require("_ZTD_Network/ZTD_Request")
	
	ZTD.TimeMapBase = require("_ZTD_GoldPlay/TimeMapBase")
	
	ZTD.Notification = require("_ZTD_Model/ZTD_Notification")
	ZTD.WaitForServer = require("_ZTD_Network/ZTD_WaitForServer")
	ZTD.WaitForServerConfig = require("_ZTD_Config/ZTD_WaitForServerConfig")

	ZTD.PlayerData = require("_ZTD_Model/ZTD_PlayerData")

	ZTD.PoolManager = require("_ZTD_Manager/ZTD_PoolManager")
	ZTD.LanguageManager = require("_ZTD_Manager/ZTD_LanguageManager")
	ZTD.EffectManager = require("_ZTD_Manager/ZTD_EffectManager")
	
	ZTD.Flow = require("_ZTD_TowerDef/ZTD_Flow")
	
	ZTD.GuideData = require("_ZTD_Model/ZTD_GuideData")
	
	ZTD.ConstConfig = require("_ZTD_Config/ZTD_ConstConfig")
	ZTD.HttpErrConfig = require("_ZTD_Config/ZTD_HttpErrConfig")
	ZTD.RouteConfig = require("_ZTD_Config/ZTD_RouteConfig")
	ZTD.HeroConfig = require("_ZTD_Config/ZTD_HeroConfig")
	ZTD.EnemyConfig = require("_ZTD_Config/ZTD_EnemyConfig")
	ZTD.MapConfig = require("_ZTD_Config/ZTD_MapConfig")
	ZTD.StoreConfig = require("_ZTD_Config/ZTD_StoreConfig")
	ZTD.TrusteeshipConfig = require("_ZTD_Config/ZTD_TrusteeshipConfig")
	ZTD.EnemyTypeConfig = require("_ZTD_Config/ZTD_EnemyTypeConfig")
	ZTD.HelpConfig = require("_ZTD_Config/ZTD_HelpConfig")
	ZTD.GuideConfig = require("_ZTD_Config/ZTD_GuideConfig")
	ZTD.SkillConfig = require("_ZTD_Config/ZTD_SkillConfig")
	ZTD.RatioSetConfig = require("_ZTD_Config/ZTD_RatioSetConfig")
	ZTD.EnemyEffConfig = require("_ZTD_Config/ZTD_EnemyEffectConfig")
	ZTD.EffTransformConfig = require("_ZTD_Config/ZTD_EffectTransformConfig")
	ZTD.DragonConfig = require("_ZTD_Config/ZTD_DragonConfig")
	ZTD.BufferConfig = require("_ZTD_Config/ZTD_BufferConfig")
	ZTD.ArenaConfig = require("_ZTD_Config/ZTD_ArenaConfig")
	ZTD.PoolConfig = require("_ZTD_Config/ZTD_PoolConfig")
	ZTD.BalloonConfig = require("_ZTD_Config/ZTD_BalloonConfig")
	ZTD.TurnTableConfig = require("_ZTD_Config/ZTD_TurnTableConfig")
	ZTD.GiantConfig = require("_ZTD_Config/ZTD_GiantConfig")
	ZTD.NFTConfig = require("_ZTD_Config/ZTD_NFTConfig")
	ZTD.BearConfig = require("_ZTD_Config/ZTD_BearConfig")
	ZTD.SealConfig = require("_ZTD_Config/ZTD_SealConfig")

	ZTD.ObjectController = require("_ZTD_TowerDef/ZTD_ObjectController")
	ZTD.ObjectMgr = require("_ZTD_TowerDef/ZTD_ObjectMgr") 
	
	ZTD.SkillMgr = require("_ZTD_TowerDef/ZTD_SkillManager")

	
	ZTD.EnemyMgr = require("_ZTD_TowerDef/ZTD_EnemyMgr")
	ZTD.EnemyController = require("_ZTD_TowerDef/ZTD_EnemyController")	
	ZTD.EnemyObj = require("_ZTD_TowerDef/ZTD_EnemyObj")
	
	ZTD.TurnTableMgr = require("_ZTD_TowerDef/ZTD_TurnTableMgr")

	ZTD.BulletController = require("_ZTD_TowerDef/ZTD_BulletController")
	ZTD.BulletMgr = require("_ZTD_TowerDef/ZTD_BulletMgr")	
	ZTD.HeroController = require("_ZTD_TowerDef/ZTD_HeroController")
	ZTD.HeroMgr = require("_ZTD_TowerDef/ZTD_HeroMgr")	
	ZTD.HeroPos = require("_ZTD_TowerDef/ZTD_HeroPos")
	ZTD.HeroMenu = require("_ZTD_View/ZTD_HeroMenu")
	ZTD.CountDown = require("_ZTD_View/ZTD_CountDown")
	ZTD.MainScene = require("_ZTD_TowerDef/ZTD_Scene")
	ZTD.AttackData = require("_ZTD_TowerDef/ZTD_AttackData")
	ZTD.ComboShowTree = require("_ZTD_TowerDef/ZTD_ComboShowTree")
	ZTD.Lightning = require("_ZTD_TowerDef/ZTD_Lightning")
	ZTD.LightningMgr = require("_ZTD_TowerDef/ZTD_LightningMgr")
	
	ZTD.LoadingView = require("_ZTD_View/ZTD_LoadingView")
	ZTD.MainView = require("_ZTD_View/ZTD_MainView")
	ZTD.BattleView = require("_ZTD_View/ZTD_BattleView")
	ZTD.DragonUi = require("_ZTD_View/ZTD_DragonUi")
	ZTD.GhostFireUi = require("_ZTD_View/ZTD_GhostFireUi")
	ZTD.BalloonUi = require("_ZTD_View/ZTD_BalloonUi")
	ZTD.BalloonMgr = require("_ZTD_View/ZTD_BalloonMgr")
	ZTD.TrendDraw = require("_ZTD_View/ZTD_TrendDraw")
	ZTD.GoldPillar = require("_ZTD_View/ZTD_GoldPillar")
	ZTD.GuideMask = require("_ZTD_View/ZTD_GuideMask")
	ZTD.GiftCollectionView = require("_ZTD_View/ZTD_GiftCollectionView")
	ZTD.WeeksCardView = require("_ZTD_View/ZTD_WeeksCardView")
	ZTD.DragonTreasureView = require("_ZTD_View/ZTD_DragonTreasureView")
	ZTD.DragonTreasureRetView = require("_ZTD_View/ZTD_DragonTreasureRetView")
	ZTD.ChipShopView = require("_ZTD_View/ZTD_ChipShopView")
	ZTD.ChipShopRetView = require("_ZTD_View/ZTD_ChipShopRetView")
	ZTD.ExtendPopViewEx = require("_ZTD_View/ZTD_ExtendPopViewEx")
	ZTD.TurnTableUi = require("_ZTD_View/ZTD_TurnTableUi")
	ZTD.GiantUi = require("_ZTD_View/ZTD_GiantUi")
	ZTD.SealUi = require("_ZTD_View/ZTD_SealUi")

	ZTD.NFTData = require("_ZTD_Model/ZTD_NFTData")
	ZTD.NFTData.Init()
	ZTD.NFTCard = require("_ZTD_View/ZTD_NFTCard")
	
	ZTD.NFTView = require("_ZTD_View/ZTD_NFTView")
	ZTD.NFTHelpView = require("_ZTD_View/ZTD_NFTView")
	ZTD.PoolHelpView = require("_ZTD_View/ZTD_PoolHelpView")
	ZTD.NFTDayRecordView = require("_ZTD_View/ZTD_NFTDayRecordView")
	ZTD.NFTSeasonRecordView = require("_ZTD_View/ZTD_NFTDayRecordView")
	ZTD.NFTGetCardView = require("_ZTD_View/ZTD_NFTGetCardView")
	ZTD.NFTSellRecordView = require("_ZTD_View/ZTD_NFTSellRecordView")
	ZTD.NFTArmView = require("_ZTD_View/ZTD_NFTArmView")
	ZTD.NFTGetRewardView = require("_ZTD_View/ZTD_NFTGetRewardView")
	
	
	ZTD.Utils = require("_ZTD_Common/ZTD_Utils")
	ZTD.LockPop = require("_ZTD_Common/ZTD_LockPop")
	
	ZTD.TableData = require("_ZTD_Model/ZTD_TableData")

	ZTD.MultipleConfig = require("_ZTD_Config/ZTD_MultipleConfig")
	
	
	ZTD.GlobalTimeClock = require("_ZTD_Common/ZTD_GlobalTimeClock")
	ZTD.GlobalTimer = require("_ZTD_Common/ZTD_GlobalTimer")
	ZTD.GlobalTimer.Init()
	
	ZTD.Action = require("_ZTD_Common/ZTD_Action")
 
	ZTD.GoldData = require("_ZTD_GoldPlay/GoldData")
	
	
	ZTD.CoinFlyBase = require("_ZTD_GoldPlay/CoinFlyBase")
	ZTD.CoinFlyNormal = require("_ZTD_GoldPlay/BearMedal")
	ZTD.CoinFlyDrop = require("_ZTD_GoldPlay/CoinFlyDrop")
	ZTD.CoinFlyIconShoot = require("_ZTD_GoldPlay/CoinFlyIconShoot")
	ZTD.CoinFlyBuilderBase = require("_ZTD_GoldPlay/CoinFlyBuilderBase")
	ZTD.TextEffect = require("_ZTD_GoldPlay/TextEffect")
	ZTD.PrizeMedal = require("_ZTD_GoldPlay/PrizeMedal")
	ZTD.GiantMedal = require("_ZTD_GoldPlay/GiantMedal")
	ZTD.BearMedal = require("_ZTD_GoldPlay/BearMedal")
	-- goldplay要放在各种coin的最后
	ZTD.GoldPlay = require("_ZTD_GoldPlay/GoldPlay")
	ZTD.GoldFlyFactor = require("_ZTD_GoldPlay/GoldFlyFactor")
		
	ZTD.PoisonMedalMgr = require("_ZTD_View/ZTD_PoisonMedalMgr")

	ZTD.TouchChecker = require("_ZTD_TowerDef/ZTD_TouchChecker")
	ZTD.TouchManager = require("_ZTD_TowerDef/ZTD_TouchManager")
	
	ZTD.GirdData = require("_ZTD_Model/ZTD_GirdData")
	ZTD.DragonLogic = require("_ZTD_TowerDef/ZTD_DragonLogic")
	ZTD.GhostFireLogic = require("_ZTD_TowerDef/ZTD_GhostFireLogic")
	ZTD.GiantLogic = require("_ZTD_TowerDef/ZTD_GiantLogic")
	
	ZTD.UpdateAdd(ZTD.Update, ZTD)
end

function ZTD.SetMusicMute(isMute)
	ZTD.isMusicMute = isMute
	if not isMute then
		GC.Sound.SetMusicVolume(0)
	else
		ZTD.PlayBackMusic(ZTD.currentMusicName)
	end
end

function ZTD.PlayBackMusic(name)
	ZTD.currentMusicName = name
	if ZTD.isMusicMute then
		GC.Sound.PlayBackMusic(name)
		GC.Sound.SetMusicVolume(1)
	else
		GC.Sound.SetMusicVolume(0)
	end
end

function ZTD.SetEffectMute(isMute)
	ZTD.isEffectMute = isMute
	if isMute then
		GC.Sound.SetEffectVolume(1)
	else
		GC.Sound.SetEffectVolume(0)
	end
end

local AudioRecord = {}

function ZTD.StopMusicEffect(name)
	GC.Sound.StopExtendEffect(name);
end	

function ZTD.PlayMusicEffect(name, volume, isLoop, isIgnoreRecrod)
	if ZTD.isEffectMute then
		if isLoop then
			GC.Sound.PlayLoopEffect(name)
		else
			--GC.Sound.PlayEffect(name, volume)
			--if AudioRecord[name] then
			--	LuaFramework.SoundManager.StopExtendSound(AudioRecord[name]);
			--end	
			if isIgnoreRecrod then
				GC.Sound.PlayEffect(name, volume)
			else
				if not AudioRecord[name] then
					local audio = LuaFramework.SoundManager.PlayExtendSound(name, GC.SubGameInterface.GetSoundVolume());
					AudioRecord[name] = audio;
				end

				if not AudioRecord[name].isPlaying then
					AudioRecord[name]:Play();
				end
			end	
		end
		GC.Sound.SetEffectVolume(1)
	else
		GC.Sound.SetEffectVolume(0)
	end
end

function ZTD.SetSaveMode(isSave)
	ZTD.isSaveMode = isSave
	UnityEngine.Application.targetFrameRate = ZTD.isSaveMode and 28 or 38;
	GC.UserData.Save(ZTD.gamePath.."Setting", {isSaveMode = ZTD.isSaveMode})
	if ZTD.Flow and ZTD.Flow.GetHeroMgr() then
		ZTD.Flow.GetHeroMgr():SetSaveMode()
	end
end

function ZTD.Destroy()
	ZTD.RemoveAllFixedUpdates()
	ZTD.RemoveAllUpdates()
end

return ZTD