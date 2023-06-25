local CC = require("CC")
local NewElkLimitGiftView = CC.uu.ClassView("NewElkLimitGiftView")

function NewElkLimitGiftView:ctor(param)
	self:InitVar(param);
end

function NewElkLimitGiftView:InitVar(param)
    self.param = param
    self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
    self.countDown = 0
    self.isStart = false
    self.giftObj = {{},{}}
    self.curWareId = {}
    self.curStock = {0,0,0}
    self.time = {"20:00","20:10","20:20","20:30","20:40","20:50","21:00","21:10","21:20","21:30","21:40","21:50","22:00"}
	self.wareData = {
		["30258"] = {id = 2,	count = 10000,	stock = 150,wareId = "30258",price = 1000},
		["30259"] = {id = 2,	count = 50000,	stock = 20,	wareId = "30259",price = 1000},
		["30260"] = {id = 2,	count = 100000,	stock = 10,	wareId = "30260",price = 1000},
		["30261"] = {id = 10011,count = 1,		stock = 4,	wareId = "30261",price = 1000},
		["30262"] = {id = 10012,count = 1,		stock = 3,	wareId = "30262",price = 1000},
		["30263"] = {id = 20059,count = 1,		stock = 1,	wareId = "30263",price = 10000},}
	self.statusCfg = {
		{"30258","30259","30260"},
		{"30258","30259","30261"},
		{"30258","30259","30260"},
		{"30258","30261","30262"},
		{"30258","30259","30260"},
		{"30258","30259","30261"},
		{"30261","30262","30263"},
		{"30258","30259","30260"},
		{"30258","30259","30261"},
		{"30258","30261","30262"},
		{"30258","30259","30260"},
		{"30258","30259","30261"},
		{"30261","30262","30263"},}
	self.totalTimes = #self.statusCfg
    --self.rewardConfig = {{{id = 2,count = 10000,stock = 150,wareId = "30258"},{id = 2,count = 50000,stock = 20,wareId = "30259"},{id = 2,count = 100000,stock = 10,wareId = "30260"}},
                         --{{id = 10011,count = 1,stock = 4,wareId = "30261"},{id = 10012,count = 1,stock = 3,wareId = "30262"},{id = 20026,count = 1,stock = 1,wareId = "30263"}},
                         --{{id = 10011,count = 1,stock = 50,wareId = "30261"},{id = 10012,count = 1,stock = 50,wareId = "30262"},{id = 20074,count = 1,stock = 1,wareId = "30264"}},
                        --}     
end

function NewElkLimitGiftView:OnCreate()
	self:InitNode()
    self:InitView()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()

    self:ReqStock()
    self:ReqRecord()
end

function NewElkLimitGiftView:ReqStock()
    --定时请求礼包库存
    self:StartTimer("ReqStockPackGetReqStockPackGet",3,function()
        if self.isStart and #self.curWareId > 0 then
            CC.Request("ReqStockPackGet",{PackIDs = self.curWareId})
        end
    end,-1)
end

function NewElkLimitGiftView:ReqRecord()
    CC.Request("ReqRecordGet",{packType = CC.proto.client_pack_pb.TemporaryPack})
    --定时请求跑马灯
    self:StartTimer("ReqRecordGetReqRecordGet",30,function()
        if self.OverText.activeSelf then return  end

        CC.Request("ReqRecordGet",{packType = CC.proto.client_pack_pb.TemporaryPack})
    end,-1)
end

function NewElkLimitGiftView:InitNode()  
    self.TipText = self:FindChild("Bg/Lion/Tip")
    self.TimeText = self:FindChild("Bg/Lion/Time")
    self.OverText = self:FindChild("Bg/Lion/Over")
    self.TimeAnimator = self:FindChild("Bg/Lion/Time"):GetComponent("Animator")
end

function NewElkLimitGiftView:InitView()
    
    for i = 1, 3 do
        table.insert(self.giftObj[1],self:FindChild("Up/Gift"..i))
        table.insert(self.giftObj[2],self:FindChild("Down/Gift"..i))
        self:FindChild("Up/Gift"..i.."/BuyBtn/Price").text = 1000
        self:FindChild("Up/Gift"..i.."/BuyBtn/Text").text = self.language.tex4
        self:FindChild("Up/Gift"..i.."/BuyBtn/Gray/Price").text = 1000
        self:FindChild("Up/Gift"..i.."/BuyBtn/Gray/Text").text = self.language.tex4
        
        self:AddClick(self:FindChild("Up/Gift"..i.."/BuyBtn/Gray"),"OnGrayClick")
        self:AddClick(self:FindChild("Up/Gift"..i.."/BuyBtn"),function() self:BuyGift(i) end,nil,true)
    end

    self:FindChild("Text").text = self.language.tex8
    self.OverText.text = self.language.tex15

    self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("MarqueeNode"),TextPos = 1.5})
    self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})

    self:LaunchTimer()
end

function NewElkLimitGiftView:InitClickEvent()
    self:AddClick(self:FindChild("ExplainBtn"),"OpenExplainView",nil,true)
    self:AddClick(self:FindChild("CloseBtn"),"ActionOut",nil,true)
end

function NewElkLimitGiftView:OpenExplainView()
    local data = {
		title = self.language.explainTitle,
		content =self.language.explainContent,
        alignment = UnityEngine.TextAnchor.MiddleCenter,
	}
	CC.ViewManager.Open("CommonExplainView",data)
end

function NewElkLimitGiftView:OnGrayClick()
   if self.OverText.activeSelf then
       CC.ViewManager.ShowTip(self.language.tex15)
   elseif not self.isStart then
       CC.ViewManager.ShowTip(self.language.tex12)
   else
       CC.ViewManager.ShowTip(self.language.tex13)
   end
end

function NewElkLimitGiftView:BuyGift(index)
    if self.curStock[index] <= 0 then
        CC.ViewManager.ShowTip(self.language.tex13)
        return
    end
    if #self.curWareId <=0 or not self.isStart then return end

    local wareId = self.curWareId[index]
    local prop = self.viewCtr:GetPropId(self.wareCfg[wareId].Currency)
	if CC.Player.Inst():GetSelfInfoByKey(prop) >= self.wareCfg[wareId].Price then
        CC.Request("ReqBuy",{PackID = wareId})
    else
		CC.ViewManager.ShowTip(string.format(self.language.tex14,self.propLanguage[prop]))
    end
end

function NewElkLimitGiftView:RefreshView(param)
    if param.refreshTime then
        self.TipText.text = self.isStart and self.language.tex10 or self.language.tex9

        for i,v in ipairs(self.giftObj[1]) do
            v:FindChild("BuyBtn/Gray"):SetActive(not self.isStart)
        end
    end
    if param.activityOver then
        self.TipText.text = ""
        self.TimeText.text = ""
        self.OverText:SetActive(true)
    end
    if param.refreshStock then
        for i,v in ipairs(self.giftObj[1]) do
            v:FindChild("Surplus").text = string.format(self.language.tex2,self.curStock[i] <= 0 and 0 or self.curStock[i])
            v:FindChild("BuyBtn/Gray"):SetActive(self.curStock[i] <= 0)
        end
    end
    if param.refreshBatch then
        self.curWareId = {}
        self.curStock = {0,0,0}
        for i = 1, 3 do
            local upObj, downObj = self.giftObj[1][i],self.giftObj[2][i]
            local curRewardConfig = self.wareData[self.statusCfg[param.refreshBatch][i]]--self.rewardConfig[param.refreshBatch][i]
            local netRewardConfig = param.refreshBatch >= self.totalTimes and {} or self.wareData[self.statusCfg[param.refreshBatch+1][i]]--self.rewardConfig[param.refreshBatch +1][i]
            self.curWareId[i] = curRewardConfig.wareId

            self:SetImage(upObj:FindChild("Rewared/Icon"),self.propCfg[curRewardConfig.id].Icon)
            upObj:FindChild("Rewared/Icon"):GetComponent("Image"):SetNativeSize()
            upObj:FindChild("Image/Name").text = self.propLanguage[curRewardConfig.id]
            upObj:FindChild("Rewared/Text").text = "x"..curRewardConfig.count
			upObj:FindChild("BuyBtn/Price").text = curRewardConfig.price
			upObj:FindChild("BuyBtn/Gray/Price").text = curRewardConfig.price
            if self.OverText.activeSelf then
                upObj:FindChild("Surplus").text = string.format(self.language.tex2,0)
            elseif not self.isStart then
                upObj:FindChild("Surplus").text = string.format(self.language.tex2,curRewardConfig.stock)
            end

            downObj:FindChild("Empty"):SetActive(param.refreshBatch >= self.totalTimes)
            downObj:FindChild("Details"):SetActive(not (param.refreshBatch >= self.totalTimes))
            if not (param.refreshBatch >= self.totalTimes) then
                self:SetImage(downObj:FindChild("Details/Rewared/Icon"),self.propCfg[netRewardConfig.id].Icon)
                downObj:FindChild("Details/Rewared/Icon"):GetComponent("Image"):SetNativeSize()
                downObj:FindChild("Details/Image/Name").text = self.propLanguage[netRewardConfig.id]
                downObj:FindChild("Details/Rewared/Text").text = "x"..netRewardConfig.count
                downObj:FindChild("Details/Surplus").text = string.format(self.language.tex2,netRewardConfig.stock)
                local currency = self.viewCtr:GetPropId(self.wareCfg[netRewardConfig.wareId].Currency)  
                downObj:FindChild("Details/Text").text = string.format(self.language.tex7,self.time[param.refreshBatch+1],netRewardConfig.price,self.propLanguage[currency])
            end
        end
    end
    
end

function NewElkLimitGiftView:LaunchTimer()
    self:StartTimer("CountDown",1,function()
        if self.countDown <= 0 then 
            return 
        end
        self.countDown = self.countDown - 1
        if self.countDown <= 60 and not self.TimeAnimator.enabled then
            self.TimeAnimator.enabled = true
            self.TimeText.color = Color(1,0.13,0.07,1)
        end
        self.TimeText.text = CC.uu.TicketFormat(self.countDown)
        if self.countDown <= 0 then
            self.TimeAnimator.enabled = false
            self.TimeAnimator.transform.localScale = Vector3(1,1,1)
            self.TimeText.color = Color(0,0.89,0.18,1)
            self.isStart = false
            self:DelayRun(1,function()
                CC.Request("ReqRemainTime",{packType = CC.proto.client_pack_pb.TemporaryPack})
            end)
        end
    end,-1)
end

function NewElkLimitGiftView:ActionIn()
	self:SetCanClick(false);
    self.transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
end

function NewElkLimitGiftView:ActionOut()
	self:SetCanClick(false);
    self:FindChild("Mask"):SetActive(false)
    self.walletView:SetActive(false)
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})
end

function NewElkLimitGiftView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
    if self.walletView then
        self.walletView:Destroy()
        self.walletView = nil
	end
    if self.Marquee then
        self.Marquee:Destroy()
        self.Marquee = nil
    end

end

return NewElkLimitGiftView    