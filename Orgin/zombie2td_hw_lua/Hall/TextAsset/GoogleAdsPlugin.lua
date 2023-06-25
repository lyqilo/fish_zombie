local CC = require("CC")

local GoogleAdsPlugin = {}

--官方测试id
--android
-- local appId = "ca-app-pub-3940256099942544~3347511713"   --应用id
-- adUnitId = "ca-app-pub-3940256099942544/6300978111";     --横幅广告
-- adUnitId = "ca-app-pub-3940256099942544/5224354917";     --视频广告
--ios
-- local appId = "ca-app-pub-3940256099942544~1458002511"   --应用id
-- adUnitId = "ca-app-pub-3940256099942544/2934735716";     --横幅广告
-- adUnitId = "ca-app-pub-3940256099942544/1712485313";     --视频广告

function GoogleAdsPlugin.Init()
    --需要使用广告功能再打开
    do
        return
    end
    local cfg = CC.ConfigCenter.Inst():getConfigDataByKey("SDKConfig")
    local appId = cfg[AppInfo.ChannelID].googleAdmod.appId
    if not appId or appId == "" then
        return
    end
    GoogleMobileAdsUtil.Init(appId)
end

--横幅广告
--[[
@param:
宽高
width,height 
x,y坐标(屏幕左上角为原点,横幅锚点为左上角)
adx,ady  	
事件监听
onAdLoaded
onAdFailedToLoad
onAdOpened
onAdClosed
onAdLeavingApplication
]]
function GoogleAdsPlugin.CreateBannerAds(param)
    do
        return
    end
    local cfg = CC.ConfigCenter.Inst():getConfigDataByKey("SDKConfig")
    local adUnitId = cfg[AppInfo.ChannelID].googleAdmod.bannerUnitId
    if not adUnitId or adUnitId == "" then
        CC.uu.Log("bannerUnitId is nil", "GoogleAdsPlugin.CreateBannerAds:", 3)
        return
    end
    local banner
    if param.width and param.height then
        banner = GoogleMobileAdsUtil.CreateBannerAds(adUnitId, param.width, param.height)
    else
        banner = GoogleMobileAdsUtil.CreateBannerAds(adUnitId)
    end

    if param.adx and param.ady then
        banner:SetPosition(param.adx, param.ady)
    end

    if type(param.onAdLoaded) == "function" then
        banner.OnAdLoaded = banner.OnAdLoaded + param.onAdLoaded
    end
    if type(param.onAdFailedToLoad) == "function" then
        banner.OnAdFailedToLoad = banner.OnAdFailedToLoad + param.onAdFailedToLoad
    end
    if type(param.onAdOpened) == "function" then
        banner.OnAdOpened = banner.OnAdOpened + param.onAdOpened
    end
    if type(param.onAdClosed) == "function" then
        banner.OnAdClosed = banner.OnAdClosed + param.onAdClosed
    end
    if type(param.onAdLeavingApplication) == "function" then
        banner.OnAdLeavingApplication = banner.OnAdLeavingApplication + param.onAdLeavingApplication
    end

    return banner
end

--激励广告(视频)
--[[
@param:
事件监听
onAdLoaded
onAdFailedToLoad
onAdOpening
onAdClosed
onAdFailedToShow
onUserEarnedReward
]]
function GoogleAdsPlugin.CreateRewardedAds(param)
    do
        return
    end
    local cfg = CC.ConfigCenter.Inst():getConfigDataByKey("SDKConfig")
    local adUnitId = cfg[AppInfo.ChannelID].googleAdmod.rewardedUnitId
    if not adUnitId or adUnitId == "" then
        CC.uu.Log("rewardedUnitId is nil", "GoogleAdsPlugin.CreateRewardedAds:", 3)
        return
    end
    local rewardAd = GoogleMobileAdsUtil.CreateRewardedAds(adUnitId)

    if type(param.onAdLoaded) == "function" then
        rewardAd.OnAdLoaded = rewardAd.OnAdLoaded + param.onAdLoaded
    end
    if type(param.onAdFailedToLoad) == "function" then
        rewardAd.OnAdFailedToLoad = rewardAd.OnAdFailedToLoad + param.onAdFailedToLoad
    end
    if type(param.onAdOpening) == "function" then
        rewardAd.OnAdOpening = rewardAd.OnAdOpening + param.onAdOpening
    end
    if type(param.onUserEarnedReward) == "function" then
        rewardAd.OnUserEarnedReward = rewardAd.OnUserEarnedReward + param.onUserEarnedReward
    end
    if type(param.onAdFailedToShow) == "function" then
        rewardAd.OnAdFailedToShow = rewardAd.OnAdFailedToShow + param.onAdFailedToShow
    end
    if type(param.onAdClosed) == "function" then
        rewardAd.OnAdClosed = rewardAd.OnAdClosed + param.onAdClosed
    end
    return rewardAd
end

return GoogleAdsPlugin
