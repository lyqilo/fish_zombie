local GC = require("GC")
local ZTD = require("ZTD")

local DragonTreasureView = GC.class2("ZTD_DragonTreasureView")

local ShopInfoType = 
{
    NoneType = 0,
    Materials = 1,
    MaxShopType = 2,
}

function DragonTreasureView:ctor(_, parent)
    self.parent = parent
end

function DragonTreasureView:Init()
    self:InitRequest()
    self:InitData()
    self:AddEvent()
end

function DragonTreasureView:InitData()
    --碎片商城
    self.chipShopView = ZTD.ChipShopView:new(self.parent)
    --宝箱信息
    self.boxInfoList = {}
    --当前选中的宝箱，默认值：1
    self.curBoxID = 1 
    --需要购买的碎片数量
    self.buyChipNum = 0
    --宝箱信息配置数据
    self.boxInfoCfg = self.parent.language.dragonTreasure
    --玩家碎片数据
    self.MaterialsInfo = nil
    --商城数据
    self.shopInfo = nil
    --宝箱提示开启状态
    self.tipState = false
    --碎片商城数据请求是否成功
    self.isShopReqSucc = false
    --玩家材料数据请求是否成功
    self.isMatReqSucc = false
     --对应碎片单次购买量
     self.curRatio = 20

    self.treasureBoxNode = self.parent:FindChild("root/panelList/panel_dragonTreasure/treasureBoxNode")
    self.chipNode = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipNode")
    self.tipNode = self.parent:FindChild("root/panelList/panel_dragonTreasure/tipNode")
    self.tipParent = self.parent:FindChild("root/panelList/panel_dragonTreasure/tipNode/tipParent")
    self.tip = self.parent:FindChild("root/panelList/panel_dragonTreasure/tipNode/tip"):GetComponent("Text")
    self.tipMaskBtn = self.parent:FindChild("root/panelList/panel_dragonTreasure/tipMaskBtn")
    self.chipShopNode = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode")
    self.closeBtn = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/closeBtn")

    self.chipSlider = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/sliderNode/chipSlider")
end

--协议请求
function DragonTreasureView:InitRequest()
    --商城信息
    local succCb = function(err, data)
        -- log("CSGetShopInfoReq data="..GC.uu.Dump(data.Info))
        self.shopInfo = data.Info
        self.isShopReqSucc = true
        if self.isShopReqSucc and self.isMatReqSucc then
            self:RefreshUI()
        end
    end
    local errCb = function(err, data)
        logError("CSGetShopInfoReq err="..GC.uu.Dump(err))
    end
    ZTD.Request.CSGetShopInfoReq({ShopInfoType = ShopInfoType.Materials}, succCb, errCb)

    --玩家材料信息
    local succCb = function(err, data)
        -- log("CSGetMaterialsInfoReq data="..GC.uu.Dump(data.Info))
        self.MaterialsInfo = data.Info
        self.isMatReqSucc = true
        if self.isShopReqSucc and self.isMatReqSucc then
            self:RefreshUI()
        end
    end
    local errCb = function(err, data)
        logError("CSGetMaterialsInfoReq err="..GC.uu.Dump(err))
    end
    ZTD.Request.CSGetMaterialsInfoReq(succCb, errCb)
    
end

function DragonTreasureView:AddEvent()
    self.parent:AddClick("root/panelList/panel_dragonTreasure/tipBtnNode/tipBtn", function()
        self:RefreshTip(not self.tipState)
    end)
    self.parent:AddClick("root/panelList/panel_dragonTreasure/tipMaskBtn", function()
        self:RefreshTip(false)
    end)
    self.parent:AddClick("root/panelList/panel_dragonTreasure/shopBtn", function()
        self:OpenOrCloseChipShop(true)
    end)
    self.parent:AddClick(self.closeBtn, function()
       self:OpenOrCloseChipShop(false)
    end)
end

function DragonTreasureView:RefreshUI()
    self:OpenOrCloseChipShop(false)
    self:RefreshTip(false)
    self:RefreshDiamond()
    self:RefreshBoxInfo()
    self:RefreshChipInfo()
    self:RefreshChipShopInfo()
    self:RefreshTipInfo()  
    UIEvent.AddSliderOnValueChange(self.chipSlider, function (v)
        self.chipShopView:AddSliderOnValueChange(v)
    end)
end

--刷新宝箱数据
function DragonTreasureView:RefreshBoxInfo()
    for k, v in ipairs(self.boxInfoCfg) do
        local item = ZTD.Extend.LoadPrefab("ZTD_TreasureBoxItem", self.treasureBoxNode)
        item:FindChild("boxName"):GetComponent("Text").text = v.Name
        item:GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", v.BgIcon)
        item:FindChild("boxIcon"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", v.BoxIcon)
        item:FindChild("chipIcon"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", v.ChipIcon)
        item:FindChild("chipNum"):GetComponent("Text").text = v.ChipNum
        item:FindChild("exchangeBtn").onClick = function ()
            self.curBoxID = k
            self:OnClickExchange()
        end
        if not self.boxInfoList[k] then
            self.boxInfoList[k] = {}
        end
        self.boxInfoList[k].boxObj = item
        self.boxInfoList[k].ChipNum = v.ChipNum
        self.boxInfoList[k].TypeID = v.typeID
        self.boxInfoList[k].ID = v.ID
        self.boxInfoList[k].Name = v.Name
        self.boxInfoList[k].Tip = v.Tip
        self.boxInfoList[k].ChipBgIcon = v.chipBgIcon
    end
end

--刷新碎片数据
function DragonTreasureView:RefreshChipInfo()
    for k, v in ipairs(self.MaterialsInfo) do
        local item = ZTD.Extend.LoadPrefab("ZTD_ChipItem", self.chipNode)
        item:FindChild("Image"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", self.boxInfoCfg[k].ChipIcon)
        item:FindChild("Text"):GetComponent("Text").text = v.TotalNum
        if not self.boxInfoList[k] then
            self.boxInfoList[k] = {}
        end
        self.boxInfoList[k].chipObj = item
        self.boxInfoList[k].TotalNum = v.TotalNum
        self.boxInfoList[k].PropsID = v.PropsID
    end
end

--刷新碎片商城数据
function DragonTreasureView:RefreshChipShopInfo()
    for k, v in ipairs(self.shopInfo) do
        self.boxInfoList[k].ShopID = v.ShopID
        self.boxInfoList[k].ShopNum = v.Num
        self.boxInfoList[k].ShopPrice = v.Price
        self.boxInfoList[k].ShopName = v.Name
    end
end

--刷新碎片
function DragonTreasureView:RefreshChip(PropsID, Num, isDrop)
    local TotalNum = nil
    self.chipShopView:RefreshChip(PropsID, Num, isDrop)
    for k, v in ipairs(self.boxInfoList) do
        if v.PropsID == PropsID then
            if isDrop then
               TotalNum = v.TotalNum + Num
            else 
                TotalNum = Num
            end
            v.TotalNum = TotalNum
            v.chipObj:FindChild("Text"):GetComponent("Text").text = TotalNum
            -- log("TotalNum = "..tostring(TotalNum))
            if not isDrop then
                ZTD.PlayerData.SetChipNumByID(PropsID, TotalNum)
            end
            ZTD.Notification.GamePost(ZTD.Define.OnPushChipRedPoint)
            return
        end
    end
end

--刷新奖励说明
function DragonTreasureView:RefreshTipInfo()
    self.tip.text = self.parent.language.txt_panel_dragonTreasure_tip
    for k, v in ipairs(self.boxInfoList) do
        local item = ZTD.Extend.LoadPrefab("ZTD_TreasureTipItem", self.tipParent)
        item:FindChild("Text"):GetComponent("Text").text = self.boxInfoCfg[k].Name
        item:FindChild("Text (1)"):GetComponent("Text").text = self.boxInfoCfg[k].Tip
        item:FindChild("Image"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", self.boxInfoCfg[k].BoxIcon)
        v.tipObj = item
    end
end

--刷新钻石
function DragonTreasureView:RefreshDiamond()
    local diamond = GC.uu.numberToStrWithComma(ZTD.PlayerData.GetDiamond())
    self.parent:SetText("root/panelList/panel_dragonTreasure/diamondNode/Text", diamond)
    self.chipShopView:RefreshDiamond()
end

--点击兑换
function DragonTreasureView:OnClickExchange()
    -- log("self.boxInfoList="..GC.uu.Dump(self.boxInfoList))
    local ShopNum = self.boxInfoList[self.curBoxID].ShopNum
    local offsetNum = self.boxInfoList[self.curBoxID].ChipNum - self.boxInfoList[self.curBoxID].TotalNum
    self.curRatio = math.ceil(offsetNum / ShopNum)
    self.buyChipNum = self.curRatio * ShopNum
    self.buyChipPrice = (self.buyChipNum / ShopNum) * self.boxInfoList[self.curBoxID].ShopPrice
    -- log("buyChipNum="..self.buyChipNum.."  buyChipPrice="..self.buyChipPrice)
    local buyChipName = self:GetChipNameByBoxID()
    -- 碎片不足，跳转到碎片商城
    if self.buyChipNum > 0 then
        local str = string.format(self.parent.language.txt_panel_dragonTreasure_shopPop, self.buyChipPrice, self.buyChipNum, buyChipName)
        local sortingOrder = self.parent.transform:GetComponent("Canvas").sortingOrder + 2
        local confirmFunc = function()
            self:OnClickBuy()
        end
        ZTD.ViewManager.Open("ZTD_ExtendPopViewEx", str, confirmFunc, nil, sortingOrder)
        return
    end

    local succCb = function(err, data)
        -- log("CSExchangeBoxReq data="..GC.uu.Dump(data))
        ZTD.ViewManager.Open("ZTD_DragonTreasureRetView", data)
    end
    local errCb = function(err, data)
        logError("CSExchangeBoxReq err="..GC.uu.Dump(err))
    end
    local TypeID = self.boxInfoList[self.curBoxID].TypeID
    -- log("TypeID="..tostring(TypeID))
    --兑换请求
    ZTD.Request.CSExchangeBoxReq({TypeID = TypeID}, succCb, errCb)
end

--点击购买
function DragonTreasureView:OnClickBuy()
    local playerId = ZTD.PlayerData.GetPlayerId()
    local diamond = ZTD.PlayerData.GetDiamond()
    if self.buyChipPrice > diamond then
        --打开大厅商城
        local param = {
            ChouMa = ZTD.TableData.GetData(playerId, "Money"),
            Integral = GC.SubGameInterface.GetHallIntegral(),
        }
        GC.SubGameInterface.ExOpenShop(param)
    else
        local succCb = function(err, data)
            -- log("CSShopBuyReq data="..GC.uu.Dump(data))
            self:OnClickExchange()
            -- ZTD.ViewManager.Open("ZTD_ChipShopRetView", {PropsID = data.PropsID, buyChipNum = data.PropsNum})
        end
        local errCb = function(err, data)
            logError("CSShopBuyReq err="..GC.uu.Dump(err))
        end
        local PropsID = self:GetChipID(self.curBoxID)
        --购买请求
        ZTD.Request.CSShopBuyReq({PropsID = PropsID, PropsNum = self.buyChipNum}, succCb, errCb)
    end
end

--刷新奖励介绍
function DragonTreasureView:RefreshTip(state)
    self.tipState = state
    self.tipNode:SetActive(state)
    self.tipMaskBtn:SetActive(state)
end

--打开或关闭碎片商城
function DragonTreasureView:OpenOrCloseChipShop(state)
    if self.chipShopNode == nil then
        return
    end
    if state == true then
        self.chipShopNode:SetActive(true)
        self.chipShopView:Init()
    elseif state == false then
        self.chipShopNode:SetActive(false)
        self.chipShopView:Release()
    end
end

--根据宝箱ID获取对应碎片名称
function DragonTreasureView:GetChipNameByBoxID()
    local boxID = self.boxInfoList[self.curBoxID].ID
    -- log("boxID="..tostring(boxID))
    if boxID == 1001 then
        return self.parent.language.txt_panel_dragonTreasure_chip1
    elseif boxID == 1002 then
        return self.parent.language.txt_panel_dragonTreasure_chip2
    elseif boxID == 1003 then
        return self.parent.language.txt_panel_dragonTreasure_chip3
    elseif boxID == 1004 then
        return self.parent.language.txt_panel_dragonTreasure_chip4
    end
end

--碎片ID转换
function DragonTreasureView:GetChipID(id)
    id = id + 1
    return tonumber("111"..id)
end

function DragonTreasureView:Release()
    self:OpenOrCloseChipShop(false)
    if self.boxInfoList then
        for k, v in ipairs(self.boxInfoList) do
            GC.uu.destroyObject(v.boxObj)
            GC.uu.destroyObject(v.chipObj)
            GC.uu.destroyObject(v.tipObj)
        end
       self.boxInfoList = nil
    end
end

return DragonTreasureView