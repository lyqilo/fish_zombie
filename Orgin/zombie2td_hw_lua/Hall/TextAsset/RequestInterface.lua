-- ************************************************************
-- @File: RequestInterface.lua
-- @Summary: 对子游戏暴露操作网络的一些接口
-- @Version: 1.0
-- @Author: luo qiu zhang
-- @Date: 2023-03-28 10:24:49
-- ************************************************************
local CC = require("CC")
local RequestInterface = {}
local M = {}
M.__index = function(t, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 RequestInterface.lua 里 函数为 " .. key .. "() 的接口, 请确认接口名字")
        end
    end
end
setmetatable(RequestInterface, M)

function M.ReqOnlineFriends(cursor, count, succCb, errCb)
    local param = {}
    param.Cursor = cursor
    param.Count = count
    CC.Request("ReqLoadFriendsForTeam", param, succCb, errCb)
end

function M.ReqInviteFriend(playerId, succCb, errCb)
    local param = {}
    param.PlayerId = playerId
    CC.Request("ReqInviteFriend", param, succCb, errCb)
end

function M.ReqInviteAnswer(teamId, bIsAgree, succCb, errCb)
    local param = {}
    param.TeamId = teamId
    param.IsAgree = bIsAgree
    CC.Request("ReqInviteAnswer", param, succCb, errCb)
end

function M.ReqDisbandTeam(teamId, succCb, errCb)
    local param = {}
    param.TeamId = teamId
    CC.Request("ReqDisbandTeam", param, succCb, errCb)
end

function M.ReqLoadPlayerTeam(succCb, errCb)
    local param = {}
    CC.Request("ReqLoadPlayerTeam", param, succCb, errCb)
end

function M.ReqAllocServer(param)
    local data = {}
    data.GameId = param.gameId
    data.GroupId = param.groupId
    CC.Request("ReqAllocServer", data, param.allocSuccCb, param.allocErrCb)
    --检测版本号判断是否需要强更
    -- local hallId = 1;
    -- local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game");
    -- CC.Request.GetResourceVersionInfo({gameIds = {hallId, param.gameId}}, function(err, result)
    --         local hallVersion, gameVersion;
    --         for _,v in ipairs(result.Items) do
    --             if v.GameID == hallId then
    --                 hallVersion = v.Version;
    --             elseif v.GameID == param.gameId then
    --                 gameVersion = v.Version;
    --             end
    --         end

    --         -- logError("localHallVersion:"..gameDataMgr.GetHallForceUpdateVersion().."   updateHallVersion:"..tostring(hallVersion))
    --         -- logError("localGameVersion:"..gameDataMgr.GetGameForceUpdateVersion(param.gameId).."   updateGameVersion:"..tostring(gameVersion))
    --         if gameVersion and gameDataMgr.GetGameForceUpdateVersion(param.gameId) then
    --             if tonumber(gameVersion) > gameDataMgr.GetGameForceUpdateVersion(param.gameId) then
    --                 local language = CC.LanguageManager.GetLanguage("L_ResDownloadManager");
    --                 if hallVersion and gameDataMgr.GetHallForceUpdateVersion() then
    --                     if tonumber(hallVersion) > gameDataMgr.GetHallForceUpdateVersion() then
    --                         --游戏和大厅都需要强更则直接弹窗提示关闭应用
    --                         local box = CC.ViewManager.ShowMessageBox(language.check_hall_forceUpdate, function()
    --                                 Application.Quit();
    --                             end);
    --                         box:SetOneButton();
    --                         return;
    --                     end
    --                 end
    --                     --只有游戏需要强更则踢回大厅
    --                 local box = CC.ViewManager.ShowMessageBox(language.check_game_forceUpdate, function()
    --                         param.backToHallCb();
    --                         gameDataMgr.SetGameForceUpdateVersion(param.gameId,gameVersion);
    --                     end);
    --                 box:SetOneButton();
    --                 return;
    --             end
    --         end

    --         --不需要强更的情况获取游戏服ip
    --         CC.Request.ReqAllocServer(param.gameId, param.groupId, param.allocSuccCb, param.allocErrCb);
    --     end, function(err, result)

    --         CC.Request.ReqAllocServer(param.gameId, param.groupId, param.allocSuccCb, param.allocErrCb);
    --     end)
end

function M.ReqLoadPlayerWithPropType(param)
    local data = {
        playerId = CC.Player.Inst():GetSelfInfoByKey("Id"),
        propTypes = param.propTypes
    }
    CC.Request("ReqLoadPlayerWithPropType", data, param.succCb, param.errCb)
end

--[[
@param
gameId:游戏id
isCreator:是否房主
succCb:成功回调
errCb:失败回调
]]
function M.ReqPrivateGameRecord(param)
    local data = {}
    data.GameId = param.gameId
    data.IsCreator = param.isCreator
    CC.Request("ReqPrivateGameRecord", data, param.succCb, param.errCb)
end

--[[
@param
gameId:游戏id
propId:道具id (筹码:GC.shared_enums_pb.EPC_ChouMa)
succCb:成功回调
errCb:失败回调
]]
function M.ReqPrivateTotalProp(param)
    local data = {}
    data.GameId = param.gameId
    data.PropId = param.propId
    CC.Request("ReqPrivateTotalProp", data, param.succCb, param.errCb)
end

--[[
@param
gameId:游戏id
propId:道具id
succCb:成功回调
errCb:失败回调
]]
function M.ReqPrivateTodayProp(param)
    local data = {}
    data.GameId = param.gameId
    data.PropId = param.propId
    CC.Request("ReqPrivateTodayProp", data, param.succCb, param.errCb)
end

--[[
@param
playerId:玩家id
gameId:游戏id
succCb:成功回调
errCb:失败回调
]]
function M.ReqPrivateRoomList(param)
    local data = {}
    data.PlayerId = param.playerId
    data.GameId = param.gameId
    CC.Request("ReqPrivateRoomList", data, param.succCb, param.errCb)
end

--[[
@param
index:页数编号(目前一页50条数据)
succCb:成功回调
errCb:失败回调
]]
function M.ReqFriendList(param)
    CC.Request("ReqLoadFriendsList", {Index = param.index}, param.succCb, param.errCb)
end

--[[
@param
playerId:玩家id
succCb:成功回调
errCb:失败回调
]]
function M.ReqAddFriend(param)
    CC.Request("ReqAddFriend", {FriendId = param.playerId}, param.succCb, param.errCb)
end

--[[
@param
playerId:玩家id
succCb:成功回调
errCb:失败回调
]]
function M.ReqLoadPlayerGameInfo(param)
    CC.Request("ReqLoadPlayerGameInfo", {PlayerId = param.playerId}, param.succCb, param.errCb)
end

--[[
@param
gameId:游戏id
groupId:场id
succCb:成功回调
errCb:失败回调
]]
function M.ReqGameTableList(param)
    local data = {}
    data.GameId = param.gameId
    data.GroupId = param.groupId
    CC.Request("ReqTableList", data, param.succCb, param.errCb)
end

function M.H5ExchangeChip(param)
    local cb = param.errCallback
    local data = {}
    data.Id = CC.shared_enums_pb.EP_Diamond_Chip
    data.Amount = param.Amount
    data.GameId = param.GameId or 1
    data.GroupId = param.GroupId or 0
    CC.Request(
        "Exchange",
        data,
        function(err, data)
            if err == 0 then
                log("H5兑换筹码成功")
            end
        end,
        function(err)
            cb(err)
        end
    )
end

--[[
    param = {
        gameId,
        dwPlayerId, -- 玩家ID，可缺省
        nVipLevel, -- 玩家vip 等级，可缺省
        lPlayerMoney, -- 玩家身上剩余金币数量
        lDelta, -- 玩家输赢情况
    }

    CC.Notifications.OnLimitTimeGiftShow -- 监听礼包掉落通知，调用ShowLimitTimeGiftView(parent,target)
    CC.Notifications.OnLimitTimeGiftTimeOut -- 监听礼包购买时间到，暂无发现有什么用，子游戏自己视情况决定是否监听
]]
function M.ReqLimitTimeGift(param)
    local Mgr = CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift")
    Mgr.ReqGift(param)
end

-- ************************************************************
-- PropUse  使用背包道具
-- @ConfigId : 道具ID
-- @Count : 道具数量
-- 返回err和data数组
-- err为0，请求成功
-- ************************************************************
function M.PropUse(param)
    local data = {}
    data.ConfigId = param.ConfigId
    data.Count = param.Count
    data.GameId = CC.ViewManager.GetCurGameId() or 1
    data.GroupId = CC.ViewManager.GetCurGroupId() or 0
    CC.Request(
        "PropUse",
        data,
        function(err, data)
            if err == 0 then
                CC.HallNotificationCenter.inst():post(CC.Notifications.OnPropUse, {err = err, data = data})
            else
                CC.HallNotificationCenter.inst():post(CC.Notifications.OnPropUse, {err = err})
            end
        end
    )
end

function M.ByWareIdOrderState(param)
    CC.Request("GetOrderStatus", param.wareId, param.succCb, param.errCb)
end

return M
