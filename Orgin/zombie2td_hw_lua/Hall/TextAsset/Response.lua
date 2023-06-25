local CC = require("CC")
local Notifications = CC.Notifications
local HallNotificationCenter = CC.HallNotificationCenter
local Response = {}
--所有信息处理

--用户的初始数据
function Response.Push_PropChanged(data)
    HallNotificationCenter.inst():post(Notifications.LotteryPropChange,data) 
end
function Response.PushGameInfo(data)
    HallNotificationCenter.inst():post(Notifications.LotteryGameInfo,data) 
end

function Response.LoginWithTokenRsp(data)
    HallNotificationCenter.inst():post(Notifications.LoginWithTokenRsp,data) 
end
function Response.PurchaseLotteryRsp(data)
    HallNotificationCenter.inst():post(Notifications.PurchaseLotteryRsp,data) 
end
function Response.RandLotteryNumberRsp(data)
    HallNotificationCenter.inst():post(Notifications.RandLotteryNumberRsp,data) 
end  
function Response.PushPastLotteryRecord(data)
    HallNotificationCenter.inst():post(Notifications.PastLotteryRecord,data) 
end  
function Response.PushPurchaseRecord(data)
    HallNotificationCenter.inst():post(Notifications.PurchaseRecord,data) 
end  
function Response.PushPurchaseDetail(data)
    HallNotificationCenter.inst():post(Notifications.PurchaseDetail,data) 
end  
function Response.RewardPoolDataChangeNtf(data)
    HallNotificationCenter.inst():post(Notifications.RewardPoolDataChangeNtf,data) 
end  
function Response.LotteryLatternNtf(data)
    HallNotificationCenter.inst():post(Notifications.LotteryLatternNtf,data) 
end
function Response.OpenRewardNtf(data  )
    HallNotificationCenter.inst():post(Notifications.OpenRewardNtf,data) 
end
function Response.FirstPrizeRecodeRsp(data  )
    HallNotificationCenter.inst():post(Notifications.FirstPrizeRecodeRsp,data) 
end
function Response.LotteryRankRsp(data  )
    HallNotificationCenter.inst():post(Notifications.LotteryRankListRsp,data) 
end
function Response.LotteryPingRsp(data  )
    HallNotificationCenter.inst():post(Notifications.LotteryPingRsp,data) 
end
function Response.Nil(  )
end  
return Response