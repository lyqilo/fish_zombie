
local CC = require("CC")

local GameDataMgr = {}

local _gameList = {}
local _fishGame = {}
local _slotsGame = {}
local _pokerGame = {}
local _gameDataMap = {}
local _storeConfig = {}
local _realAuthConfig = {}
local isInit = false
local _forceUpdateVersionList = {}

local _selectID = nil
--第三方游戏
local _thirdGame = {}

--竞技场
local _arenaList = {}
local _arenaMap = {}

local _AFConversionData = {}

local _SubscribeList = {}
local _NeedSubscribeList = {}
local _QueueList = {}
local _SubscribeGameInfo = nil

--新手引导
local _Guide = {}
local chipTip = false

function GameDataMgr.InitGameData(data)
  for i,v in ipairs(data.data) do
    if math.floor(v.GameID/1000) ~= 0 then   --游戏ID为1001以上,大厅ID为1 (便于区分)
      if not _gameDataMap[v.GameID] then
        _gameDataMap[v.GameID] = {}
        _gameDataMap[v.GameID].GameID = v.GameID
        _gameDataMap[v.GameID].ProjectName = v.ProjectName
        _gameDataMap[v.GameID].ResourceName = v.ResourceName
        _gameDataMap[v.GameID].GameName = v.GameName
        _gameDataMap[v.GameID].GameTypeID = v.GameTypeID
        _gameDataMap[v.GameID].IsHallGroup = v.IsHallGroup
        _gameDataMap[v.GameID].IsRecommendGame = v.IsRecommendGame
        _gameDataMap[v.GameID].IsGoldPoolShow = v.IsGoldPoolShow
        _gameDataMap[v.GameID].IsReload = v.IsReload
        _gameDataMap[v.GameID].VipUnlock = v.VipUnlock
        _gameDataMap[v.GameID].VipShow = v.VipShow or 0
        _gameDataMap[v.GameID].Tag = v.Tag
        _gameDataMap[v.GameID].IsCommingSoon = v.IsCommingSoon
        _gameDataMap[v.GameID].H5Url = v.H5Url
        table.insert(_gameList,v.GameID)
        if v.GameType then
          --游戏类型
          if v.GameType == 1 then
            table.insert(_fishGame,v.GameID)
          elseif v.GameType == 2 then
            table.insert(_slotsGame,v.GameID)
          elseif v.GameType == 3 then
            table.insert(_pokerGame,v.GameID)
          end
        end
        if v.OpenURL then
          _gameDataMap[v.GameID].OpenURL = v.OpenURL
        end
        -- if #v.Group > 0 then
        --   for k, value in pairs(v.Group) do
        --     _gameDataMap[v.GameID][value.GroupID] = value
        --   end
        -- end
      end
    end
  end
  isInit = true
end

function GameDataMgr.IsInit()
  return isInit
end

--[[
    每个引导所对应的flag做好记录，上线后只可添加不可更改
    1-9：新手引导
    10-13：签到任务引导
    ...
    24-27:高v引导
    28:改名卡引导
    30:资讯引导，29：资讯赠送功能引导
]]

--引导
function GameDataMgr.SetGuide(flag,isSingle)
  if isSingle then
    _Guide.TotalFlag = _Guide.TotalFlag or 0
    _Guide.TotalFlag = bit.bor(_Guide.TotalFlag, bit.lshift(1,flag))
  else
    if flag < 9 then
      _Guide.state = true
    else
      _Guide.state = false
    end
    _Guide.Flag = CC.uu.isNumber(flag) and flag or 0
  end
end

function GameDataMgr.GetGuide()
  return _Guide
end

function GameDataMgr.CleanGuide()
  _Guide = {}
end

function GameDataMgr.SetTotalFlag(totalFlag)
  _Guide.TotalFlag = totalFlag or 0
end

function GameDataMgr.GetSingleFlag(flag)
  if not _Guide.TotalFlag then
    return true
  end
  _Guide.TotalFlag = _Guide.TotalFlag or 0
  return bit.band(_Guide.TotalFlag, bit.lshift(1,flag)) > 0
end

--玩家类型
function GameDataMgr.SetPlayerType(PlayerType)
  _Guide.PlayerType = PlayerType
end
function GameDataMgr.GetPlayerType()
  return _Guide.PlayerType or ""
end

--游客筹码过多提示
function GameDataMgr.SetChipTip()
  chipTip = true
end
function GameDataMgr.GetChipTip()
  return chipTip
end

function GameDataMgr.GetGameList()
  return _gameList
end

--第三方游戏列表
function GameDataMgr.SetThirdGameList(data)
  for _,v in ipairs(data.data1) do
    if math.floor(v.GameID/1000) ~= 0 then
      if not _thirdGame[v.GameID] then
        _thirdGame[v.GameID] = {}
        _thirdGame[v.GameID].GameID = v.GameID
        _thirdGame[v.GameID].ProjectName = v.ProjectName
        _thirdGame[v.GameID].ResourceName = v.ResourceName
        _thirdGame[v.GameID].GameName = v.GameName
        _thirdGame[v.GameID].IsOpen = v.IsOpen
      end
    end
  end
end

function GameDataMgr.GetThirdGameList()
  return _thirdGame
end

function GameDataMgr.GetThirdGameNameByID(id)
  if not _thirdGame[id] then
    return nil
  else
    return _thirdGame[id].ProjectName
  end
end

function GameDataMgr.GetFishGameList()
  return _fishGame
end

function GameDataMgr.GetSlotsGameList()
  return _slotsGame
end

function GameDataMgr.GetPokerGameList()
  return _pokerGame
end

function GameDataMgr.GetInfoByID(id)
  return _gameDataMap[id]
end

function GameDataMgr.GetGroupConfigByID(id)
  if _gameDataMap[id] then
    return _gameDataMap[id].GroupConfig
  end
end

function GameDataMgr.SetGroupConfigByID(id, config)
  if _gameDataMap[id] then
    _gameDataMap[id].GroupConfig = config

    --兼容老代码
    for _,v in pairs(config) do
      _gameDataMap[id][v.GroupID] = v;
    end
  end
end

function GameDataMgr.GetGroupInfo(GameID,GroupID)
  if _gameDataMap[GameID] then
    for i,v in ipairs(_gameDataMap[GameID]) do
      if v.GroupID == GroupID then
        return _gameDataMap[GameID][i]
      end
    end
  end
end

function GameDataMgr.GetGameNameByID(id)
  if _thirdGame[id] then
    --第三方游戏
    return _thirdGame[id].GameName
  elseif not _gameDataMap[id] then
    return nil
  else
    return _gameDataMap[id].GameName
  end
end

function GameDataMgr.GetProNameByID(id)
  if _thirdGame[id] then
    --第三方游戏
    return _thirdGame[id].ProjectName
  elseif not _gameDataMap[id] then
    return nil
  else
    return _gameDataMap[id].ProjectName
  end
end

function GameDataMgr.GetResNameByID(id)
  if _thirdGame[id] then
    --第三方游戏
    return _thirdGame[id].ResourceName or GameDataMgr.GetProNameByID(id)
  elseif not _gameDataMap[id] then
    return nil
  else
    return _gameDataMap[id].ResourceName or GameDataMgr.GetProNameByID(id)
  end
end

function GameDataMgr.GetTypeByID(id)
  return _gameDataMap[id].GameTypeID
end

function GameDataMgr.GetIsHallGroupByID(id)
  return _gameDataMap[id] and _gameDataMap[id].IsHallGroup
end

function GameDataMgr.GetIsRecommendGameByID(id)
  return _gameDataMap[id].IsRecommendGame
end

function GameDataMgr.GetIsGoldPoolShowByID(id)
  return _gameDataMap[id].IsGoldPoolShow
end

function GameDataMgr.GetIsReloadByID(id)
  if not _gameDataMap[id] then
    return 0
  else
    return _gameDataMap[id].IsReload or 0
  end
end

function GameDataMgr.GetVipUnlockByID(id)
  if _gameDataMap[id] then
    return _gameDataMap[id].VipUnlock
  else
    return 0
  end
end

function GameDataMgr.GetOpenURLByID(id)
  if _gameDataMap[id] and _gameDataMap[id].OpenURL then
    return _gameDataMap[id].OpenURL
  end
  return nil
end

local _SwitchClickData = {
	--赠送功能
	GiveGiftSearchView = {ID = 1,Times = 0},
	--邮箱
	MailView = {ID = 2,Times = 0},
	--VIP
	VipView = {ID = 3,Times = 0},
	--商场
	StoreView = {ID = 4,Times = 0},
	--实物商场
	TreasureView = {ID = 5,Times = 0},
	--排行榜
	RankingListView = {ID = 6,Times = 0},
	--好友
	FriendView = {ID = 7,Times = 0},
	--活动
	ActiveView = {ID = 8,Times = 0},
	--礼包合辑
	SelectGiftCollectionView = {ID = 9,Times = 0},
	--免费合辑
	FreeChipsCollectionView = {ID = 10,Times = 0},
	--设置
	SetUpSoundView = {ID = 11,Times = 0},
  --元旦活动充值统计
  BlessActivityBuy = {ID = 12, Times = 0},
  --泼水节
  WaterSprinklingView = {ID = 999, Times = 0},
}

function GameDataMgr.ReSetSwitchClick()
  for k, v in pairs(_SwitchClickData) do
    v.Times = 0
  end
end

function GameDataMgr.SetSwitchClick(viewName)
  if _SwitchClickData[viewName] then
    _SwitchClickData[viewName].Times = _SwitchClickData[viewName].Times + 1
  else
    logWarn("SetSwitchClick "..viewName.." nil")
  end
end

function GameDataMgr.GetSwitchCfg()
  return _SwitchClickData
end

function GameDataMgr.SetArenaInfo(param)
  local data = param.data
  local List = param.List
  _arenaList = {}
  _arenaMap = {}

  for i,v in ipairs(List) do
    --竞技场列表排序
    --1,2,3,4,5,6 排序后变为6,4,2,1,3,5
    if i % 2 == 0 then
      table.insert(_arenaList,1,v)
    else
      table.insert(_arenaList,v)
    end
  end

  for i,v in ipairs(data) do
    if not _arenaMap[v.GameID] then
      _arenaMap[v.GameID] = {}
      _arenaMap[v.GameID].IsOpen = v.IsOpen
      _arenaMap[v.GameID].CompetitionInfo = v.CompetitionInfo
      _arenaMap[v.GameID].ProjectName = v.ProjectName
      _arenaMap[v.GameID].GameName = v.GameName
    end
  end
end

function GameDataMgr.GetArenaList()
  return _arenaList
end

function GameDataMgr.GetArenaInfoByID(id)
  if _arenaMap[id] then
    return _arenaMap[id]
  end
end

function GameDataMgr.SetStoreCfg(data)
  _storeConfig = {}
	_storeConfig = data;
	if data.RealAuth then
		GameDataMgr.SetRealAuthCfg(data.RealAuth)
	end
end

function GameDataMgr.GetStoreCfg()
  return _storeConfig;
end

function GameDataMgr.SetRealAuthCfg(data)
	_realAuthConfig = {}
	for _,v in pairs(data) do
		local t = {}
		t.BankEnum = v.BankEnum
		t.AmountLimit = v.AmountLimit
		t.InputType = v.InputType or 1
		t.Desc = v.Desc
		_realAuthConfig[v.CommodityType] = t
	end
end

function GameDataMgr.GetRealAuthCfg()
	return _realAuthConfig
end

function GameDataMgr.SetForceUpdateVersion(versionList)
  _forceUpdateVersionList = {};
  for _, v in ipairs(versionList) do
    _forceUpdateVersionList[v.GameID] = v.Version;
  end
end

function GameDataMgr.GetForceUpdateVersion()
  return _forceUpdateVersionList;
end

function GameDataMgr.GetHallForceUpdateVersion()
  local hallId = 1;
  return _forceUpdateVersionList[hallId] and tonumber(_forceUpdateVersionList[hallId]);
end

function GameDataMgr.SetHallForceUpdateVersion(version)
  local hallId = 1;
  _forceUpdateVersionList[hallId] = version;
end

function GameDataMgr.GetGameForceUpdateVersion(gameId)
  if not _forceUpdateVersionList[gameId] then
    logError("GameDataMgr:not gameId version");
    return
  end
  return _forceUpdateVersionList[gameId] and tonumber(_forceUpdateVersionList[gameId]);
end

function GameDataMgr.SetGameForceUpdateVersion(gameId, version)

    _forceUpdateVersionList[gameId] = version;
end

function GameDataMgr.SetSelectViewGameID(id)
  _selectID = id
end

function GameDataMgr.GetSelectViewGameID()
  local id = _selectID
  _selectID = nil
  return id
end

function GameDataMgr.SetAFConversionData(data)
  _AFConversionData = data
end

function GameDataMgr.GetAFConversionData()
  return _AFConversionData
end

function GameDataMgr.SetSubscribeList(data)
  _SubscribeList = data.GameIDs
  _NeedSubscribeList = data.GameIDsSubing
  _QueueList = data.GameIDsQueueing
  CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshSubscribeList)
end

function GameDataMgr.GetSubscribeList()
  return _SubscribeList
end

function GameDataMgr.GetNeedSubscribeList()
  return _NeedSubscribeList
end

function GameDataMgr.GetQueueList()
  return _QueueList
end

function GameDataMgr.SetSubscribeGameInfo(data)
  _SubscribeGameInfo = {}
  for i,v in ipairs(data) do
    _SubscribeGameInfo[v.Id] = v
  end
end

function GameDataMgr.GetSubscribeGameInfoById(id)
  if _SubscribeGameInfo and _SubscribeGameInfo[id] then
    return _SubscribeGameInfo[id]
  else
    return nil
  end
end

return GameDataMgr