-- ************************************************************
-- @File: PayInterface.lua
-- @Summary: 对子游戏暴露操作礼包购买的接口
-- @Version: 1.0
-- @Author: xxxxxx
-- @Date: 2023-04-07 14:35:40
-- ************************************************************
local CC = require("CC")

local PayInterface = {}
local M = {}
M.__index = function(t, key)
    if M[key] then
        return M[key]
    else
        return function()
            logError("无法访问 PayInterface.lua 里 函数为 " .. key .. "() 的接口, 请确认接口名字")
        end
    end
end

setmetatable(PayInterface, M)

--[[
@param
wareId: 商品id
subChannel: 渠道id
price:	购买金额
playerId：玩家id
ExchangeWareId: 商品兑换id
]]
--autoExchange字段只控制自动兑换筹码并且不会通知游戏服(游戏内不要使用)
function M.RequestPay(param)
    CC.PaymentManager.RequestPay(param)
end

--[[
    提供给子游戏调取官方付费,非官方渠道勿用
    wareId:官方计费点ID
]]
function M.RequestOfficialPay(wareId)
    local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    local wareData = wareCfg[wareId]
    if wareData then
        local param = {}
        param.wareId = wareData.Id
        param.subChannel = wareData.SubChannel
        param.price = wareData.Price
        param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
        CC.PaymentManager.RequestPay(param)
    else
        log("商品ID不存在")
    end
end

--[[
    H5游戏游戏通过WareID付费
    @data
    wareId:商品id
]]
function M.H5RequestPay(data)
    local wareId = data.wareId
    local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    local wareData = wareCfg[wareId]
    if wareData then
        local param = {}
        param.wareId = wareId
        param.subChannel = wareData.SubChannel
        param.price = wareData.Price
        param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
        param.autoExchange = data.autoExchange
        param.pin = data.pin
        param.serial = data.serial
        param.callback = data.errCallback
        CC.uu.Log(param, "PayEx:", 3)
        CC.PaymentManager.RequestPay(param)
    else
        log("商品ID不存在")
    end
end

--每日礼包支付请求
function M.RequestPayDailyGift(callback)
    if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
        return false
    end
    local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    local wareId = CC.PaymentManager.GetActiveWareIdByKey("buyu")
    local ware = wareCfg[wareId]
    local data = {}
    data.wareId = ware.Id
    data.subChannel = ware.SubChannel
    data.errCallback = function(err)
        -- 捕鱼计费点已购买提示
        if err == CC.shared_en_pb.WareAlreadyPurchased or err == CC.shared_en_pb.WareLocked then
            callback()
        end
    end
    CC.PaymentManager.RequestPay(data)
end

--购买礼包 （捕鱼vip1礼包
function M.OnNovicePay(call)
    if not CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
        CC.ViewManager.OpenAndReplace("StoreView")
        return
    end
    local wareId = CC.PaymentManager.GetActiveWareIdByKey("vip")
    local wareData = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    local wareCfg = wareData[wareId]
    local param = {}
    param.wareId = wareCfg.Id
    param.subChannel = wareCfg.SubChannel
    param.price = wareCfg.Price
    param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
    param.errCallback = call
    CC.PaymentManager.RequestPay(param)
end

--[[
@param
wareId: 礼包WareId
walletView: 钱包界面
]]
function M.DiamondBuyGift(param)
    local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    local price = wareCfg[param.wareId].Price
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
        local data = {}
        data.WareId = param.wareId
        data.ExchangeWareId = param.wareId
        data.ExtraData = param.extraData
        CC.Request("ReqBuyWithId", data)
    else
        if param.walletView then
            param.walletView:PayRecharge()
        end
    end
end

return M
