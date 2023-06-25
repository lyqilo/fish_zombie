-- ************************************************************
-- @File: ShareInterface.lua
-- @Summary: 对子游戏暴露的一些分享相关的接口
-- @Version: 1.0
-- @Author: xxxxxx
-- @Date: 2023-04-08 11:48:05
-- ************************************************************
local CC = require("CC")

local ShareInterface = {}
local M = {}
M.__index = function(t, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 ShareInterface.lua 里 函数为 " .. key .. "() 的接口, 请确认接口名字")
        end
    end
end

setmetatable(ShareInterface, M)

--[[
@param
extraData:
    gameId:游戏id(必传)
    其他扩展参数(通过邀请链接回传游戏)
title:分享的标题
content:分享的文本内容
delayTime:延迟显示菊花的时间(默认1秒)
timeOut:请求超时时间(默认15秒)
errCb:失败回调
]]
-- ************************************************************
-- @FuncName: InviteFriendFromLine  通过生成链接和分享到line,邀请好友
-- @Param1: param
-- ************************************************************
function M.InviteFriendFromLine(param)
    if not CC.HallUtil.JudgeHaveLineApp() then
        return
    end
    local delayTime = param.delayTime or 1
    CC.ViewManager.ShowConnecting(true, delayTime)
    local shareUrl =
        CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetGameInvitationUrl(
        {
            title = param.title,
            desc = param.content,
            channelId = AppInfo.ChannelID,
            extraData = Util.EncodeBase64(Json.encode(param.extraData))
        }
    )
    CC.HttpMgr.Get(
        shareUrl,
        function(www)
            CC.ViewManager.CloseConnecting()
            local result = Json.decode(www.downloadHandler.text)
            M.ShareTextToLine(result.data)
        end,
        function(err)
            CC.uu.Log(err, "InviteFriendFromLine:", 3)
            CC.ViewManager.CloseConnecting()
            if param.errCb then
                param.errCb()
            end
        end,
        function()
        end,
        param.timeOut
    )
end

--[[
@param
extraData:
    gameId:游戏id(必传)
    其他扩展参数(通过邀请链接回传游戏)
title:分享的标题
content:分享的文本内容
delayTime:延迟显示菊花的时间(默认1秒)
timeOut:请求超时时间(默认15秒)
errCb:失败回调
]]
function M.InviteFriendFromFacebook(param)
    if not CC.HallUtil.JudgeHaveFacebookApp() then
        return
    end
    local delayTime = param.delayTime or 1
    CC.ViewManager.ShowConnecting(true, delayTime)
    local shareUrl =
        CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetGameInvitationUrl(
        {
            title = param.title,
            desc = param.content,
            channelId = AppInfo.ChannelID,
            extraData = Util.EncodeBase64(Json.encode(param.extraData))
        }
    )
    CC.HttpMgr.Get(
        shareUrl,
        function(www)
            CC.ViewManager.CloseConnecting()
            local result = Json.decode(www.downloadHandler.text)
            local fbParam = {
                contentURL = result.data
                -- contentTitle = title,
                -- contentDescription = content
            }
            M.ShareLinkToFacebook(fbParam)
        end,
        function(err)
            CC.uu.Log(err, "InviteFriendFromFacebook:", 3)
            CC.ViewManager.CloseConnecting()
            if param.errCb then
                param.errCb()
            end
        end,
        function()
        end,
        param.timeOut
    )
end

function M.ShareTextToLine(content)
    CC.uu.Log(content, "ShareTextToLine11:")
    if not CC.HallUtil.JudgeHaveLineApp() then
        return false
    end
    CC.uu.Log(content, "ShareTextToLine22:")
    CC.LinePlugin.ShareText(content)
    CC.uu.Log(content, "ShareTextToLine33:")
    return true
end

function M.ShareTextToOther(param)
    CC.NativeSharePlugin.ShareText(param)
    return true
end

--[[
@param
contentURL:分享到facebook链接
callback:分享回调
]]
function M.ShareLinkToFacebook(param)
    CC.uu.Log(param.contentURL, "ShareLinkToFacebook11:")
    if not CC.HallUtil.JudgeHaveFacebookApp() then
        return false
    end
    CC.uu.Log(param.contentURL, "ShareLinkToFacebook22:")
    local cb = param.callback or function(status)
        end
    CC.FacebookPlugin.ShareLink(param.contentURL, cb)
    CC.uu.Log(param.contentURL, "ShareLinkToFacebook33:")
    return true
end

-- 图片分享连接
--[[
@param
extraData:
    gameId:游戏id(必传)
    其他扩展参数(通过连接回传游戏)
webTitle:链接标题(可缺省)
webText:链接描述内容(可缺省)
file:图片文件 Texture2D(可缺省)
succCb(url,imgUrl):成功回调 带回分享短连接和上传的图片地址
errCb:错误回调
]]
function M.GetTextureShareLink(param)
    param.extraData = param.extraData or {}
    param.succCb = param.succCb or function()
        end
    param.errCb = param.errCb or function()
        end

    CC.ViewManager.ShowLoading(true)
    local data = {
        webText = param.webText,
        webTitle = param.webTitle,
        file = param.file,
        urlData = {
            extraData = Util.EncodeBase64(Json.encode(param.extraData))
        },
        succCb = function(url, imgUrl)
            CC.ViewManager.CloseLoading()
            param.succCb(url, imgUrl)
        end,
        errCb = function()
            CC.ViewManager.CloseLoading()
            param.errCb()
        end
    }
    CC.HallUtil.CreateShareLink(data)
end

return M
