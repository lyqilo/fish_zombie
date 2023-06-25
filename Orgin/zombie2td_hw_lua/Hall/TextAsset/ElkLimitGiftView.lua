local CC = require("CC")
local ElkLimitGiftView = CC.uu.ClassView("ElkLimitGiftView")

function ElkLimitGiftView:ctor(param)
	self:InitVar(param);
end

function ElkLimitGiftView:InitVar(param)
    self.param = param
    self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.countDown = 0
    self.isNotBuy = true
    self.ElkGift = {"30118","30119","30120"}
    self.Gifts = {{wareId = "30118",value = 1000000,minGet = "325K",limitBuy = 0,buyTime = 0,stock = 0, maxRebate = "250%",propNum = "x1"},
                  {wareId = "30119",value = 3000000,minGet = "1.01M",limitBuy = 0,buyTime = 0,stock = 0,maxRebate = "300%",propNum = "x3"},
                  {wareId = "30120",value = 8000000,minGet = "2M",limitBuy = 0,buyTime = 0,stock = 0,maxRebate = "400%",propNum = "x16"},
                  {wareId = "30121",value = 200000,minGet = "60K",limitBuy = 0,buyTime = 0,propNum = "x1"},
                  {wareId = "30122",value = 2000000,minGet = "650K",limitBuy = 0,buyTime = 0,propNum = "x2"},
                  {wareId = "30123",value = 20000000,minGet = "7.4M",limitBuy = 0,buyTime = 0,propNum = "x30"},
                }
    self.GiftStockCfg ={{500,80,50},{600,150,100}}           
end

function ElkLimitGiftView:OnCreate()
	self:InitNode()
    self:InitView()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
end

function ElkLimitGiftView:InitNode()
    self.BroadCast = self:FindChild("BroadCast")
    self.tipTextBgLength = (self:FindChild("BroadCast/Bg"):GetComponent('RectTransform').rect.width - 15)/2
    self.tipText = self:FindChild("BroadCast/Bg/Text")
    self.TipText = self:FindChild("Bg/Lion/Tip")
    self.TimeText = self:FindChild("Bg/Lion/Time"):GetComponent("Text")
    self.TimeAnimator = self:FindChild("Bg/Lion/Time"):GetComponent("Animator")
end

function ElkLimitGiftView:InitView()
    if self.param then
        self:FindChild("Mask"):SetActive(false)
        self:FindChild("CloseBtn"):SetActive(false)
    end
   
    self.TipText.text = self.language.Start
    self:FindChild("Down/Gift1/Text").text = self.language.Tip1
    for i,v in ipairs(self.Gifts) do
        local gift = i<4 and self:FindChild("Up/Gift"..i) or self:FindChild("Down/Gift"..i-3)
        if i < 4 then
            gift:FindChild("Surplus/Num").text = string.format(self.language.Surplus,v.stock)
            gift:FindChild("Discounts/Text").text = string.format(self.language.MaxRebate,v.maxRebate)
        end
        if i == 4 then
            gift:FindChild("MaybeGet/Num").text = v.propNum
        else
            gift:FindChild("Rewared2/Num").text = v.propNum
        end
        gift:FindChild("Name").text = i<4 and self.language["Name"..i] or self.language.Name4
        gift:FindChild("BuyBtn/Text").text = string.format(i<4 and self.language.RushBuy or self.language.Buy,0)
        gift:FindChild("BuyBtn/Gray/Text").text = string.format(i<4 and self.language.RushBuy or self.language.Buy,0)
        gift:FindChild("Value/Text").text = self.language.BestValue
        gift:FindChild("Value/Num").text = v.value
        gift:FindChild("Rewared1/Text").text = string.format(self.language.MinGet,v.minGet)
        gift:FindChild("MaybeGet/Text").text = self.language.MaybeGet
        gift:FindChild("BuyBtn/Price").text = self.wareCfg[v.wareId].Price
     
        gift:FindChild("BuyBtn/Gray"):SetActive(true)
        self:AddClick(gift:FindChild("BuyBtn"),function() self:BuyGift(v) end)
        self:AddClick(gift:FindChild("BuyBtn/Gray"),function() self:ShowTopTip(i<4,v) end)
    end
    self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
    self:LaunchTimer()
end

function ElkLimitGiftView:InitClickEvent()
    self:AddClick(self:FindChild("ExplainBtn"),"OpenExplainView")
    self:AddClick(self:FindChild("CloseBtn"),"Destroy")
end

function ElkLimitGiftView:OpenExplainView()
    local data = {
		title = self.language.explainTitle,
		content =self.language.explainContent,
	}
	CC.ViewManager.Open("CommonExplainView",data )
end

function ElkLimitGiftView:BuyGift(data)
    if self.countDown < 5 and (data.wareId == "30118" or data.wareId == "30119" or data.wareId == "30120")then return end
    if data.buyTime >= data.limitBuy then return end
    local wareInfo = self.wareCfg[data.wareId]
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= wareInfo.Price then
        CC.Request("ReqBuyWithId",{WareId = wareInfo.Id , ExchangeWareId = wareInfo.Id})
    else
		if self.walletView then
			self.walletView:SetBuyExchangeWareId(wareInfo.Id)
            self.walletView:PayRecharge()
		end
    end
end

function ElkLimitGiftView:ShowTopTip(isLimitTime,gift)
    if isLimitTime then
        if self.isNotBuy then
            CC.ViewManager.ShowTip(self.language.TimeNotEnough)
            return
        elseif gift.stock <= 0 then 
            CC.ViewManager.ShowTip(self.language.StockNotEnough)
            return
        end
    end
    if gift.buyTime >= gift.limitBuy then
        CC.ViewManager.ShowTip(self.language.LimitBuy)
    end
end

function ElkLimitGiftView:RefreshView(param)
    if param.refreshTime then
        if self.isNotBuy then
            self.TipText.text = self.language.Start
        else
            self.TipText.text = self.language.End
        end
    end
    for i,v in ipairs(self.Gifts) do
        local result = v.limitBuy-v.buyTime >= 0 and v.limitBuy-v.buyTime or 0
        if i < 4 then
            if param.refreshStock then
                self:FindChild("Up/Gift"..i.."/Surplus/Num").text = string.format(self.language.Surplus,v.stock > 0 and v.stock or 0) 
            end
            self:FindChild("Up/Gift"..i.."/BuyBtn/Gray"):SetActive(v.buyTime >= v.limitBuy or v.stock <= 0 or self.isNotBuy)
            self:FindChild("Up/Gift"..i.."/BuyBtn/Text").text = string.format(self.language.RushBuy,result)
            self:FindChild("Up/Gift"..i.."/BuyBtn/Gray/Text").text = string.format(self.language.RushBuy,result)
        else
            if param.refreshStock or param.refreshTime then
                return
            end
            self:FindChild("Down/Gift"..(i-3).."/BuyBtn/Gray"):SetActive(v.buyTime >= v.limitBuy)
            self:FindChild("Down/Gift"..(i-3).."/BuyBtn/Text").text = string.format(self.language.Buy,result)
            self:FindChild("Down/Gift"..(i-3).."/BuyBtn/Gray/Text").text = string.format(self.language.Buy,result)
        end
    end
end

function ElkLimitGiftView:LaunchTimer()
    self:StartTimer("CountDown",1,function()
        if self.countDown <= 0 then 
			self.TimeText.text = CC.uu.TicketFormat(0)
            return 
        end
        self.countDown = self.countDown - 1
        if not self.isNotBuy and self.countDown <= 1800 and not self.TimeAnimator.enabled then
            self.TimeAnimator.enabled = true
            self.TimeText.color = Color(1,0.13,0.07,1)
        end
        self.TimeText.text = CC.uu.TicketFormat(self.countDown)
        if self.countDown <= 0 then
            self.TimeAnimator.enabled = false
            self.TimeAnimator.transform.localScale = Vector3(1,1,1)
            self.TimeText.color = Color(0,0.89,0.18,1)
            self:DelayRun(1,function()
                CC.Request("ReqRemainTime",{packType = CC.proto.client_pack_pb.ChristmasAllPack})
                CC.Request("ReqTimesbuy",{PackIDs = self.ElkGift})
            end)
        end
    end,-1)
end

function ElkLimitGiftView:ActionIn()
    self:SetCanClick(false);
    --self.transform.size = Vector2(125, 0)
	--self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function ElkLimitGiftView:ActionOut()
    self:SetCanClick(false);
	-- self:RunAction(self.transform, {
	-- 		{"fadeToAll", 0, 0.5, function() self:Destroy() end},
    --     })
    self:Destroy()
end

function ElkLimitGiftView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
    if self.walletView then
        self.walletView:Destroy()
        self.walletView = nil
	end
end

return ElkLimitGiftView    