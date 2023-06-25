local CC = require("CC")
local NetworkManager = require("Model/LotteryNetwork/NetworkManager")
local MessageManager = require("Model/LotteryNetwork/MessageManager")
local Request = {}


local REQUESTLIST = NetworkManager.REQUESTLIST

--[[
这些接口完全可以根据proto自动生成，会的同学可以搞一下
]]

local MakeMessage = function(name)
    local config = MessageManager.Inst():GetRequestProConfig(name)
    local req = NetworkManager.MakeMessage(config.name)
    return req
end

function Request.LoginWithToken(usr,pwd,cb)
    local pbName = REQUESTLIST.LOGIN
    local req = MakeMessage(pbName)
    req.PlayerId = usr
    req.Token = pwd
    NetworkManager.Request(pbName,req,cb)
end

function Request.PurchaseLotteryReq(szLotteryNumber,lPrice,nPurchaseNum,cb)
    local pbName = REQUESTLIST.CSPurchaseLotteryReq
    local req = MakeMessage(pbName)
    req.szLotteryNumber = szLotteryNumber
    req.lPrice = lPrice
    req.nPurchaseNum = nPurchaseNum
    NetworkManager.Request(pbName,req,cb)
end

function Request.RandLotteryNumberReq(cb)
    local pbName = REQUESTLIST.CSRandLotteryNumberReq
    local req = MakeMessage(pbName)
    NetworkManager.Request(pbName,req,cb)
end

function Request.LotteryPurchaseRecodeReq(nCapacity,nStartIndex,nEndIndex,cb)
    local pbName = REQUESTLIST.CSLotteryPurchaseRecodeReq
    local req = MakeMessage(pbName)
    req.nCapacity = nCapacity
    req.nStartIndex = nStartIndex
    req.nEndIndex = nEndIndex
    NetworkManager.Request(pbName,req,cb)
end

function Request.LotteryHistoryRecodeReq(nCapacity,nStartIndex,nEndIndex,cb)
    local pbName = REQUESTLIST.CSLotteryHistoryRecodeReq
    local req = MakeMessage(pbName)
    req.nCapacity = nCapacity
    req.nStartIndex = nStartIndex
    req.nEndIndex = nEndIndex
    NetworkManager.Request(pbName,req,cb)
end

function Request.LotteryDetailRecodeReq(szIssue,nCapacity,nStartIndex,nEndIndex,cb)
    local pbName = REQUESTLIST.CSLotteryDetailRecodeReq
    local req = MakeMessage(pbName)
    req.szIssue = szIssue
    req.nCapacity = nCapacity
    req.nStartIndex = nStartIndex
    req.nEndIndex = nEndIndex
    NetworkManager.Request(pbName,req,cb)
end

function Request.LotteryLatternReq(cb)
    local pbName = REQUESTLIST.CSLotteryLatternReq
    local req = MakeMessage(pbName)
    NetworkManager.Request(pbName,req,cb)
end

function Request.FirstPrizeRecodeReq(szIssue,nCapacity,nStartIndex,nEndIndex,cb)
    local pbName = REQUESTLIST.CSFirstPrizeRecodeReq
    local req = MakeMessage(pbName)
    req.szIssue = szIssue
    req.nCapacity = nCapacity
    req.nStartIndex = nStartIndex
    req.nEndIndex = nEndIndex
    NetworkManager.Request(pbName,req,cb)
end

function Request.LotteryRankListReq(nCapacity,nStartIndex,nEndIndex,cb)
    local pbName = REQUESTLIST.CSLotteryRankReq
    local req = MakeMessage(pbName)
    req.nCapacity = nCapacity
    req.nStartIndex = nStartIndex
    req.nEndIndex = nEndIndex
    NetworkManager.Request(pbName,req,cb)
end

function Request.LotteryPingReq(timeStamp,cb)
    local pbName = REQUESTLIST.CSPingReq
    local req = MakeMessage(pbName)
    req.lTimeStamp = timeStamp
    NetworkManager.Request(pbName,req,cb)
end

return Request


