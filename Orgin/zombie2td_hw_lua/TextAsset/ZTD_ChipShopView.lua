local GC = require("GC")
local ZTD = require("ZTD")

local ChipShopView = GC.class2("ZTD_ChipShopView")

local ShopInfoType = 
{
    NoneType = 0,
    Materials = 1,
    MaxShopType = 2,
}

function ChipShopView:ctor(_, parent)
    self.parent = parent
end

function ChipShopView:Init()
    self:InitData()
    self:AddEvent()
    self:RefreshUI()
end

function ChipShopView:InitData()
    self.boxInfoList = self.parent.viewList["dragonTreasure"].boxInfoList
    --宝箱信息配置数据
    self.boxInfoCfg = self.parent.language.dragonTreasure
    --商城碎片信息
    self.chipInfoList = {}
    --注：碎片和宝箱一一对应
    --需要购买的碎片类型，默认购买第一种碎片
    self.curChipID = 1
    --需要购买的碎片数量
    self.buyChipNum = 10
    --需要购买的碎片价格
    self.buyChipPrice = 1
    --对应碎片单次购买量
    self.curRatio = self.boxInfoList[self.curChipID].ShopNum
    --对应碎片购买下限
    self.curLowerLimit = self.boxInfoList[self.curChipID].ShopNum
    --对应碎片购买上限
    self.curUpperLimit = self.boxInfoList[self.curChipID].ShopNum * 100
    --商城数据
    self.Info = nil
    --碎片数据
    self.MaterialsInfo = nil
    --碎片商城数据请求是否成功
    self.isShopReqSucc = false
    --玩家材料数据请求是否成功
    self.isMatReqSucc = false

    self.chipShopNode = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/chipShopNode")
    self.chipNode = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/chipNode")
    self.buyBtn = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/bugBtn")
    self.addBtn = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/sliderNode/add")
    self.subBtn = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/sliderNode/sub")
    self.chipSliderValue = self.parent:FindChild("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/sliderNode/chipSlider"):GetComponent("Slider")
end

function ChipShopView:AddEvent()
    self.parent:AddClick(self.buyBtn, function()
        self:OnClickBuy()
    end)
    self.parent:AddClick(self.addBtn, function()
        self:OnClickAdd()
    end)
    self.parent:AddClick(self.subBtn, function()
        self:OnClickSub()
    end)
end

function ChipShopView:AddSliderOnValueChange(v)
    if self.curRatio > 1 then
        v = v / self.curRatio
        v = math.ceil(v) * self.curRatio
        self.chipSliderValue.value = v
    end
    -- logError("v="..tostring(v))
    -- logError("AddSliderOnValueChange self.chipInfoList="..GC.uu.Dump(self.chipInfoList))
    self.buyChipNum = v
    self.buyChipPrice = v * self.chipInfoList[self.curChipID].Price
    self.buyChipPrice = self.buyChipPrice / self.curRatio
    self:RefreshBuyInfo(self.curChipID, v, self.buyChipPrice)    
end

function ChipShopView:RefreshUI()
    self:RefreshDiamond()
    self:RefreshChipShopInfo()
    self:RefreshChipInfo()
    self:RefreshSlider()
    -- log("RefreshUI self.chipInfoList="..GC.uu.Dump(self.chipInfoList))
end

--刷新碎片商城信息
function ChipShopView:RefreshChipShopInfo()
   for k, v in ipairs(self.boxInfoList) do
        local item = ZTD.Extend.LoadPrefab("ZTD_ChipShopItem", self.chipShopNode)
        item:GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", v.ChipBgIcon)
        item:FindChild("chipIcon"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", self.boxInfoCfg[k].ShopChipIcon)
        item:FindChild("chipIcon"):GetComponent("Image"):SetNativeSize()
        item:FindChild("chipNum"):GetComponent("Text").text = v.ShopNum
        item:FindChild("diamondNum"):GetComponent("Text").text = v.ShopPrice
        if k == self.curChipID then
            item:FindChild("selectIcon"):SetActive(true)
        end
        if not self.chipInfoList[k] then
            self.chipInfoList[k] = {}
        end
        self.chipInfoList[k].shopObj = item
        self.chipInfoList[k].ShopID = v.ShopID
        self.chipInfoList[k].Num = v.ShopNum
        self.chipInfoList[k].Price = v.ShopPrice
        self.chipInfoList[k].Name = v.ShopName
        self:RefreshBuyInfo(k, v.ShopNum, v.ShopPrice)
        item.onClick = function ()
            if self.curChipID == k then
                return
            end
            self:RefreshBuyID(k)
            self.buyChipNum = self.chipInfoList[self.curChipID].Num
            self:RefreshAllChipShop()
            self:RefreshSelect()
        end
    end
end

--刷新玩家碎片数据
function ChipShopView:RefreshChipInfo()
    for k, v in ipairs(self.boxInfoList) do
        local item = ZTD.Extend.LoadPrefab("ZTD_ChipItem", self.chipNode)
        item:FindChild("Image"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", self.boxInfoCfg[k].ChipIcon)
        item:FindChild("Text"):GetComponent("Text").text = v.TotalNum
        if not self.chipInfoList[k] then
            self.chipInfoList[k] = {}
        end
        self.chipInfoList[k].chipObj = item
        self.chipInfoList[k].TotalNum = v.TotalNum
        self.chipInfoList[k].PropsID = v.PropsID
    end
end

--刷新碎片
function ChipShopView:RefreshChip(PropsID, Num, isDrop)
    if not self.chipInfoList then return end
    local TotalNum = nil
    for k, v in ipairs(self.chipInfoList) do
        if v.PropsID == PropsID then
            if isDrop then
                TotalNum = v.TotalNum + Num
            else
                TotalNum = Num
            end
            v.TotalNum = TotalNum
            v.chipObj:FindChild("Text"):GetComponent("Text").text = TotalNum
            -- log("TotalNum="..tostring(TotalNum))
            if not isDrop then
                ZTD.PlayerData.SetChipNumByID(PropsID, TotalNum)
            end
            ZTD.Notification.GamePost(ZTD.Define.OnPushChipRedPoint)
            return
        end
    end
end

--刷新钻石
function ChipShopView:RefreshDiamond()
    local diamond = GC.uu.numberToStrWithComma(ZTD.PlayerData.GetDiamond())
    self.parent:SetText("root/panelList/panel_dragonTreasure/chipShopNode/panel_chipShop/diamondNode/Text", diamond)
end

--刷新选中框
function ChipShopView:RefreshSelect()
    for k, v in ipairs(self.chipInfoList) do
        if k == self.curChipID then
            v.shopObj:FindChild("selectIcon"):SetActive(true)
        else
            v.shopObj:FindChild("selectIcon"):SetActive(false)
        end
    end
end

--选中的碎片对应购买量信息
function ChipShopView:GetBuyInfo()
    local buyNum = 0
    local buyPrice = 0
    buyNum = self.buyChipNum
    buyPrice = buyNum * self.chipInfoList[self.curChipID].Price
    self.buyChipNum = buyNum
    self.buyChipPrice = buyPrice
    return buyNum, buyPrice
end

--刷新所有碎片
function ChipShopView:RefreshAllChipShop()
    for k, v in ipairs(self.chipInfoList) do
        if k == self.curChipID then
            self:RefreshSlider()
        else
            self:RefreshBuyInfo(k, v.Num, v.Price)
        end
    end
end

--刷新选中碎片类型
function ChipShopView:RefreshBuyID(id)
    self.curChipID = id
    self.curRatio = self.chipInfoList[self.curChipID].Num
    self.curLowerLimit = self.chipInfoList[self.curChipID].Num
    self.curUpperLimit = self.chipInfoList[self.curChipID].Num * 100
end

--刷新某种碎片购买信息
function ChipShopView:RefreshBuyInfo(id, Num, Price)
    if not id then return end
    local shopObj = self.chipInfoList[id].shopObj
    local numText = shopObj:FindChild("chipNum"):GetComponent("Text")
    numText.text = Num
    local priceText = shopObj:FindChild("diamondNum"):GetComponent("Text")
    priceText.text = Price
end

--刷新Slider
function ChipShopView:RefreshSlider()
    -- log("RefreshSlider self.chipInfoList="..GC.uu.Dump(self.chipInfoList))
    -- logError("state="..tostring(state))
    --注：minvalue, maxvalue, value赋值顺序不能更改，影响监听v值结果
    local value = self.buyChipNum
    -- logError("value="..tostring(value))
    self.chipSliderValue.minValue = self.curLowerLimit
    self.chipSliderValue.maxValue = self.curUpperLimit
    self.chipSliderValue.value = value
end

--点击购买
function ChipShopView:OnClickBuy()
    if self.buyChipPrice > ZTD.PlayerData.GetDiamond() then
        local playerId = ZTD.PlayerData.GetPlayerId()
        local param = {
            ChouMa = ZTD.TableData.GetData(playerId, "Money"),
            Integral = GC.SubGameInterface.GetHallIntegral(),
        }
        GC.SubGameInterface.ExOpenShop(param)
        return
    end
    -- log("RefreshChipShopInfo self.chipInfoList="..GC.uu.Dump(self.chipInfoList))
    local succCb = function(err, data)
        -- log("CSShopBuyReq data="..GC.uu.Dump(data))
        ZTD.ViewManager.Open("ZTD_ChipShopRetView", {PropsID = data.PropsID, buyChipNum = data.PropsNum})
    end
    local errCb = function(err, data)
        logError("CSShopBuyReq err="..GC.uu.Dump(err))
    end
    local PropsID = self:GetChipID(self.curChipID)
    --购买请求
    ZTD.Request.CSShopBuyReq({PropsID = PropsID, PropsNum = self.buyChipNum}, succCb, errCb)
end

--点击增加
function ChipShopView:OnClickAdd()
    -- logError("buyChipNum="..tostring(self.buyChipNum))
    -- logError("curUpperLimit="..tostring(self.curUpperLimit))
    -- logError("curRatio="..self.curRatio)
    if self.buyChipNum >= self.curUpperLimit then return end
    self.buyChipNum = self.buyChipNum + 1 * self.curRatio
    -- logError("buyChipNum="..tostring(self.buyChipNum))
    self:RefreshSlider()
end

--点击减少
function ChipShopView:OnClickSub()
    -- logError("buyChipNum="..tostring(self.buyChipNum))
    -- logError("curLowerLimit="..tostring(self.curLowerLimit))
    if self.buyChipNum <= self.curLowerLimit then return end
    self.buyChipNum = self.buyChipNum - 1 * self.curRatio
    self:RefreshSlider()
end

--碎片ID转换
function ChipShopView:GetChipID(id)
    id = id + 1
    return tonumber("111"..id)
end

function ChipShopView:Release()
    if self.chipInfoList then
        for k, v in ipairs(self.chipInfoList) do
            GC.uu.destroyObject(v.shopObj)
            GC.uu.destroyObject(v.chipObj)
        end
        self.chipInfoList = {}
    end
end

return ChipShopView