local CC = require("CC")

local WalletView = CC.uu.ClassView("WalletView")

--param 礼包wareId
function WalletView:ctor(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    --支付方式
    self.localCommodityType = CC.LocalGameData.GetLocalStateToKey("CommodityType")
    self.curSelectCommodityType = nil
    self.localAddTip = CC.LocalGameData.GetLocalStateToKey("AddTip")
end

function WalletView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
end

function WalletView:InitUI()
    if self.param.parent then
        --获取上层挂载的canvas组件,得到sortLayer和orderLayer
        self.transform:SetParent(self.param.parent, false);
        -- local canvas = CC.uu.GetCanvas(self.transform)--self.param.parent:GetComponent("Canvas")
        -- local selfCanvas = self.transform:GetComponent("Canvas")
        -- local rightCanvas = self:FindChild("RightPanel"):GetComponent("Canvas")
        -- if canvas then
        --     selfCanvas.sortingLayerName = self.param.sortingLayerName or canvas.sortingLayerName
        --     selfCanvas.sortingOrder = self.param.sortingOrder or canvas.sortingOrder + 2
        --     rightCanvas.sortingLayerName = self.param.sortingLayerName or canvas.sortingLayerName
        --     rightCanvas.sortingOrder = self.param.sortingOrder or canvas.sortingOrder + 4

        --     local transforms = self.transform:GetComponentsInChildren(typeof(UnityEngine.Transform), true)
        --     if transforms then
        --         for i = 0, transforms.Length - 1 do
        --             transforms[i].gameObject.layer = canvas.transform.gameObject.layer
        --         end
        --     end
        -- end
        --local canvasScaler = GameObject.Find("GNode/GCanvas"):GetComponent("CanvasScaler")
        --CanvasScaler未导出，大厅1280 * 720
        if self.param.width and self.param.height then
            local width = 1280 - self.param.width
            local height = 720 - self.param.height
            local scale = self.param.height / 720
            self.transform.size = Vector2(width, height)
            self.transform.localScale = Vector3(scale, scale, 1)
        end
    end

    self.DiamondNode = self:FindChild("DiamondNode")
    self:AddClick(self.DiamondNode:FindChild("Add"), function()
        Util.SaveToPlayerPrefs("autoExchange", "false")
        if self.param.parent then
            self.param.parent:SetActive(false)
        end
        CC.ViewManager.Open("StoreView", {callback = function()
            if self.param.parent then
                self.param.parent:SetActive(true)
            end
        end})
        self.DiamondNode:FindChild("Tip"):SetActive(false)
        CC.LocalGameData.SetLocalStateToKey("AddTip", true)
        self.localAddTip = true
    end)
    --默认支付方式
    self.DefaultBtn = self:FindChild("DefaultBtn")
    self.DefaultBtn:SetActive(false)
    self:AddClick(self:FindChild("DefaultBtn"), function ()
        self.viewCtr:PayWayChannelData(true)
    end)

    self.bottomItem = self:FindChild("BottomPanel/BottomScr/Item")
    self.bottomParent = self:FindChild("BottomPanel/BottomScr/Viewport/Content")
    self:AddClick(self:FindChild("BottomPanel/CloseBottom"), function ()
		self:HideBottomPanel()
    end)
    self.moreBtn = self:FindChild("BottomPanel/BottomScr/MoreBtn")
    self:AddClick(self.moreBtn, function()
        for i = 1, self.bottomParent.childCount do
            local child = self.bottomParent:GetChild(i-1);
            child:SetActive(true)
        end
        self.moreBtn:SetActive(false)
    end)
    self.rightItem = self:FindChild("RightPanel/RightScr/Item")
    self.rightParent = self:FindChild("RightPanel/RightScr/Viewport/Content")
    self:AddClick(self:FindChild("RightPanel/CloseBottom"), function ()
		self:FindChild("RightPanel"):SetActive(false)
    end)

    self:AddLongClick(self:FindChild("TipLess/Button/Image"),{
        funcClick = function ()
        end,
        funcLongClick = function (  )
            self:ShowTipPanel(true)
        end,
        funcUp = function ()
            self:FindChild("TipPanel"):SetActive(false)
        end,
        time = 0.1,
    })
    self:AddLongClick(self:FindChild("TipMore/Button/Image"),{
        funcClick = function ()
        end,
        funcLongClick = function (  )
            self:ShowTipPanel(false)
        end,
        funcUp = function ()
            self:FindChild("TipPanel"):SetActive(false)
        end,
        time = 0.1,
    })
    self:LanguageSwitch()
    if self.localCommodityType then
        --本地存的渠道有没有配置
        local channelParam = self.viewCtr:GetChannelItems(self.localCommodityType)
        if not channelParam or self.viewCtr:OnHideChannel(self.localCommodityType) then
            self.localCommodityType = nil
        else
            local icon = self.viewCtr:GetPayChannelIcon(self.localCommodityType)
            self:SetImage(self.DefaultBtn:FindChild("Icon"), icon)
            self.DefaultBtn:SetActive(true)
        end
    end
    self:SetDiamond(CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi"))
end

--语言切换
function WalletView:LanguageSwitch()
    self:FindChild("BottomPanel/BottomScr/Text"):GetComponent("Text").text = self.language.defaultTip
    self:FindChild("TipLess/Text1"):GetComponent("Text").text = self.language.oncePayTip_1
    self:FindChild("TipLess/Text2"):GetComponent("Text").text = self.language.oncePayTip_2
    self:FindChild("TipMore/Text1"):GetComponent("Text").text = self.language.morePayTip
    self:FindChild("TipPanel/PayWay/Text"):GetComponent("Text").text = self.language.payWay
    self:FindChild("TipPanel/Lack/Text"):GetComponent("Text").text = self.language.lack
    self:FindChild("TipPanel/Pay/Image"):GetComponent("Text").text = self.language.currency
    self:FindChild("TipPanel/Pay/Text"):GetComponent("Text").text = self.language.curPay
    self:FindChild("TipPanel/Remain/Text"):GetComponent("Text").text = self.language.remain
    self.moreBtn:FindChild("Text"):GetComponent("Text").text = self.language.moreWay
    self.DiamondNode:FindChild("Tip/Text"):GetComponent("Text").text = self.language.morePayWay
end

--设置砖石
function WalletView:SetDiamond(DiamondNum)
    self.DiamondNode:FindChild("Text"):GetComponent("Text").text = CC.uu.DiamondFortmat(DiamondNum)
    if self.param and self.param.exchangeWareId then
        self:ShowDefault()
    end
end

--显示默认支付按钮
function WalletView:ShowDefault()
    local giftData = self.viewCtr:GetGiftToWareId()
    if not giftData then return end
    --本地默认支付方式
    if not self.localCommodityType or CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= giftData.Price then
        self.DefaultBtn:SetActive(false)
        self.DiamondNode:FindChild("Add"):SetActive(false)
        self:FindChild("TipLess"):SetActive(false)
        self:FindChild("TipMore"):SetActive(false)
    else
        self.DefaultBtn:SetActive(true)
        self.DiamondNode:FindChild("Add"):SetActive(true)
        if not self.localAddTip then
            self.DiamondNode:FindChild("Tip"):SetActive(true)
        end
        local icon = self.viewCtr:GetPayChannelIcon(self.localCommodityType)
        self:CalePaySelect(self.localCommodityType)
        self:SetImage(self.DefaultBtn:FindChild("Icon"), icon)
    end
end

function WalletView:ShowPayTip(payData, lackDiamond, commodityType)
    --支付方式最大值>礼包钻石-余额
    local enough = payData.diamondCount - lackDiamond >= 0 and true or false
    self:FindChild("TipLess"):SetActive(enough)
    self:FindChild("TipMore"):SetActive(not enough)
    self:FindChild("TipPanel/Remain"):SetActive(enough)
    if enough then
        self:FindChild("TipPanel/Remain"):GetComponent("Text").text = payData.diamondCount - lackDiamond
    end
    self:FindChild("TipPanel/Lack"):GetComponent("Text").text = lackDiamond
    self:FindChild("TipPanel/Pay"):GetComponent("Text").text = payData.price / 100
    self:FindChild("TipPanel/Pay/Acquire"):GetComponent("Text").text = "= " .. payData.diamondCount
    local payIcon = self.viewCtr:GetPayChannelIcon(commodityType)
    self:SetImage(self:FindChild("TipPanel/PayWay"), payIcon)
end

--单次支付足够
function WalletView:ShowTipPanel(isOnce)
    self:FindChild("TipPanel"):SetActive(true)
    self:FindChild("TipPanel/Remain"):SetActive(isOnce)
end

--计算支付选择
function WalletView:CalePaySelect(commodityType)
    local giftData = self.viewCtr:GetGiftToWareId()
    if not giftData then return end
    local playerDiamond = CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi")
    local lackDiamond = giftData.Price - playerDiamond
    --local dataType = {{chipCount = 277000, commodityType = 22, diamondCount = 277, icon = "diamondIcon_1.png",
    -- id = 92001, itemType = 2, price = 5000, priceDisCount = 5300, priceDisDes = "%5", subChannel ="truemoney"}}
    if lackDiamond > 0 then
        local channelParam = self.viewCtr:GetChannelItems(commodityType)
        if not channelParam then return end
        local payData = self:GetBestPayPrice(lackDiamond, channelParam)
        if payData then
            if self.localCommodityType then
                self:ShowPayTip(payData, lackDiamond, commodityType)
            end
            return payData
        end
    else
        self:FindChild("TipLess"):SetActive(false)
        self:FindChild("TipMore"):SetActive(false)
    end
end

--获得最佳支付价格
function WalletView:GetBestPayPrice(lack, param)
    table.sort(param, function(a, b) return a.price < b.price end)
    for _,v in ipairs(param) do
        if v.diamondCount >= lack then
            return v
        end
    end
    return param[#param]
end

--支付方式渠道按钮
function WalletView:PayWayChannel(isRight, param)
    self.DefaultBtn:SetActive(isRight)
    if isRight then
        self:FindChild("RightPanel"):SetActive(true)
    else
        self:FindChild("BottomPanel"):SetActive(true)
    end
    --创建渠道按钮
    if param then
        for k,v in ipairs(param) do
            if not self.viewCtr:OnHideChannel(v.commodityType) then
                self:CreateChannelItem(isRight, v, k);
            end
        end
        if not isRight then
            self.moreBtn:SetParent(self.bottomParent)
            self.moreBtn:SetActive(true)
        end
    end
end

function WalletView:CreateChannelItem(isRight, param, index)
    local obj = {}
    obj.data = param
    --创建对应object
	local parent = isRight and self.rightParent or self.bottomParent
	local item = isRight and self.rightItem or self.bottomItem
    obj.transform = CC.uu.newObject(item, parent)
    if not isRight and index > 4 then
        obj.transform:SetActive(false)
    else
        obj.transform:SetActive(true)
    end
	--设置渠道按钮图标
	if param.icon then
		self:SetImage(obj.transform:FindChild("Icon"), param.icon);
	end
	--google和ios渠道特殊处理
	-- if param.showExtraTips then
	-- 	obj.tips = self:FindChild("Tips");
	-- 	obj.tips:SetParent(obj.transform, false);
	-- 	-- obj.tips:SetActive(true);
	-- 	self:AddClick(obj.tips, "OnClickTips");
	-- end

    obj.onSelect = function()
        --log(CC.uu.Dump(obj.data,"obj.data",10))
        local payData = self:CalePaySelect(obj.data.commodityType)
        self.curSelectCommodityType = obj.data.commodityType
        if isRight then
            self:SetImage(self.DefaultBtn:FindChild("Icon"), param.icon)
            if self.localCommodityType and self.localCommodityType ~= param.commodityType then
                self:FindChild("RightPanel"):SetActive(false)
            end
            CC.LocalGameData.SetLocalStateToKey("CommodityType", param.commodityType)
            self.localCommodityType = param.commodityType
        else
            --没有默认支付方式，得到数据，直接支付
            if payData then
                self.viewCtr:OnPay(payData)
            end
        end
	end

	UIEvent.AddToggleValueChange(obj.transform, function(selected)
			if selected then
				obj.onSelect();
			end
        end)
    if self.localCommodityType and self.localCommodityType == param.commodityType then
        obj.transform:GetComponent("Toggle").isOn = true
    end
	return obj;
end

--钻石不足，支付充值
function WalletView:PayRecharge()
    if self.localCommodityType then
        local payData = self:CalePaySelect(self.localCommodityType)
        if payData then
            self.viewCtr:OnPay(payData)
        end
    else
        --选择默认支付方式
        self.viewCtr:PayWayChannelData(false)
    end
end

--礼包购买成功
function WalletView:PayGiftSucceed(hideWallet)
    self.DefaultBtn:SetActive(hideWallet)
    self.DiamondNode:FindChild("Add"):SetActive(hideWallet)
    if not hideWallet then
        self.DiamondNode:FindChild("Tip"):SetActive(hideWallet)
    end
    self:FindChild("TipLess"):SetActive(hideWallet)
    self:FindChild("TipMore"):SetActive(hideWallet)
end

function WalletView:ChangeExchangeWareId(wareId)
    if self.param and self.param.exchangeWareId then
        self.param.exchangeWareId = wareId
        self.viewCtr:ChangeExchangeWareId(wareId)
        self:ShowDefault()
    end
end

--界面多个礼包时，设置要购买礼包wareId
function WalletView:SetBuyExchangeWareId(wareId)
    self.viewCtr:SetBuyExchangeWareId(wareId)
end

function WalletView:HideBottomPanel()
    self:FindChild("BottomPanel"):SetActive(false)
end

function WalletView:ActionIn()
end

--关闭界面
function WalletView:CloseView()
	self:Destroy()
end

function WalletView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
end

return WalletView;