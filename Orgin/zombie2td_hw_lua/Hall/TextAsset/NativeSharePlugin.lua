local CC = require("CC")

local NativeSharePlugin = {}

NativeSharePlugin.TargetCfg = {
    ANDROID = {
        --facebook
        {packageName = "com.facebook.katana", className = "com.facebook.composer.shareintent.ImplicitShareIntentHandlerDefaultAlias"},
        --facebook messenger
        {packageName = "com.facebook.orca", className = "com.facebook.messenger.intents.ShareIntentHandler"},
        --line
        {packageName = "jp.naver.line.android", className = "jp.naver.line.android.activity.selectchat.SelectChatActivityLaunchActivity"},
        --webchat
        {packageName = "com.tencent.mm", className = "com.tencent.mm.ui.tools.ShareImgUI"},
        --QQ
        {packageName = "com.tencent.mobileqq", className = "com.tencent.mobileqq.activity.JumpActivity"},
        --twitter推文
        {packageName = "com.twitter.android", className = "com.twitter.composer.ComposerActivity"},
        --twitter私信
        {packageName = "com.twitter.android", className = "com.twitter.app.dm.DMActivity"},
        --whatsapp
        {packageName = "com.whatsapp", className = "com.whatsapp.ContactPicker"},
        --instagram
        {packageName = "com.instagram.android", className = "com.instagram.share.handleractivity.ShareHandlerActivity"},
        --复制剪贴板
        {packageName = "com.google.android.apps.docs", className = "com.google.android.apps.docs.drive.clipboard.SendTextToClipboardActivity"},
    },
    --IOS不支持自定义app
    IOS = {

    }
}

--[[
@param
title: 分享窗标题
text: 文本(必须带url)
callback: 分享回调(接收两个参数，分享结果和分享的app，不一定能成功回调)
--]]
function NativeSharePlugin.ShareText(param)
    local data = {
        title = param.title,
        text = param.text,
        target = NativeSharePlugin.TargetCfg[Util.GetPlatform()]
    }
    NativeShareUtil.ShareText(Json.encode(data), param.callback);
end

--[[
@param
title: 分享窗标题
texture: 贴图(Texture2D类型)
createdFileName: 保存的图片名(没必要别传)
callback: 分享回调(接收两个参数，分享结果和分享的app，不一定能成功回调)
--]]
function NativeSharePlugin.ShareTexture(param)
    local data = {
        title = param.title,
        createdFileName = param.createdFileName,
        target = NativeSharePlugin.TargetCfg[Util.GetPlatform()]
    }
    NativeShareUtil.ShareTexture(param.texture, Json.encode(data), param.callback);
end

return NativeSharePlugin