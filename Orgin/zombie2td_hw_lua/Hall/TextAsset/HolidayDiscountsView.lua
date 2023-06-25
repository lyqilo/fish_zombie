
local CC = require("CC")
local HolidayDiscountsView = CC.uu.ClassView("HolidayDiscountsView")

function HolidayDiscountsView:ctor(param)
	self:InitVar(param);
end

function HolidayDiscountsView:InitVar(param)
    self.param = param;
    self.language = self:GetLanguage()
    --self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")

    self.GiftLevel = {Level1 = {"22018","22017","22024","22023"},Level2 = {"22019","22018","22017","22024"},Level3 = {"22020","22019","22018","22017"}}
    self.AllGiftData = {
        ["22020"] = {WareId="22020",NeedVip=3,Status=true,CountDown = -2,extrarew=30,linshi=0,ZGHD="30M",ZDHD="6.19M",ZGFL="800%",GiftTip=string.format(self.language.HQDK,300),BgIcon="300DianKa"},
        ["22019"] = {WareId="22019",NeedVip=2,Status=true,CountDown = -2,extrarew=10,linshi=0,ZGHD="9M",ZDHD="1.78M",ZGFL="600%",GiftTip=string.format(self.language.HQDK,150),BgIcon="150DianKa"},
        ["22018"] = {WareId="22018",NeedVip=1,Status=true,CountDown = -2,extrarew=4,linshi=0,ZGHD="1.3M",ZDHD="551K",ZGFL="400%",GiftTip=string.format(self.language.ZSVip,"VIP3"),BgIcon="VIP3"},
        ["22017"] = {WareId="22017",NeedVip=0,Status=true,CountDown = -2,extrarew=2,linshi=0,ZGHD="700K",ZDHD="270K",ZGFL="200%",GiftTip=string.format(self.language.HQDK,50),BgIcon="50DianKa"},
        ["22024"] = {WareId="22024",NeedVip=0,Status=true,CountDown = -2,extrarew=0,linshi=0,ZGHD="390K",ZDHD="160K",ZGFL="200%",GiftTip=string.format(self.language.HQDK,50),BgIcon="50DianKa"},
        ["22023"] = {WareId="22023",NeedVip=0,Status=true,CountDown = -2,extrarew=0,linshi=0,ZGHD="120K",ZDHD="56K",ZGFL="200%",GiftTip=string.format(self.language.HQDK,50),BgIcon="50DianKa"}}

    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    --倒计时
    self.countDown = 0
end

function HolidayDiscountsView:OnCreate()
    self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("MarqueeNode"),TextPos = 1.5,ImageBgSize = {h = 40}})
    self.walletView = CC.uu.CreateHallView("WalletView",{})
    self.walletView.transform:SetParent(self.transform, false)

    self:StartTimer( "RefreshCountDown",1,function()
        self:RefreshCountDown()
    end,-1)

	self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
    self:SelectGiftLevel()
	self:CheckMeritsIcon()
end

function HolidayDiscountsView:SelectGiftLevel(curLevel)

    local currentVipLevel = curLevel or CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    local curGiftLevel = "Level1"
    if currentVipLevel >= 1 and currentVipLevel <= 5 then
        curGiftLevel = "Level2"
    elseif currentVipLevel >= 6 then
        curGiftLevel = "Level3"
    end

    if self.Level ~= curGiftLevel then
        self.Level = curGiftLevel
        self.ShowGiftData = {}
        for i,v in ipairs(self.GiftLevel[curGiftLevel]) do
            local data = self.AllGiftData[v]
            table.insert(self.ShowGiftData,data)
        end

        self.viewCtr:LoadGiftStatus()
        self.Marquee.MessageTable = {}
        CC.Request("ReqAugGiftPayRecord")
        self:InitUI()
    end

end

function HolidayDiscountsView:InitUI()
    self:FindChild("Time").text = self.language.Time
    self:FindChild("Explain").text = self.language.HDSM
    self:FindChild("LimiBuyTip").text = self.language.BuyTip
    self:FindChild("Tip").text = self.language.BCYCJ
    self:FindChild("Tip"):SetActive(not (self.Level == "Level3"))
	self:FindChild("Merits/Bubble/Image/Text").text = self.language.meritsTip

    for i = 1, 4 do
        local Data = self.ShowGiftData[i]
		-- self:FindChild("GiftList/GiftItem"..i.."/Introduce/Title").text = self.language["Gift"..i]
        self:FindChild("GiftList/GiftItem"..i.."/Introduce/Top/1/Tip1").text = self.language.ZGFL
        self:FindChild("GiftList/GiftItem"..i.."/Introduce/Top/1/Tip2").text = Data.ZGFL
        self:FindChild("GiftList/GiftItem"..i.."/Introduce/Top/2/Tip1").text = string.format(self.language.ZGHD,Data.ZGHD) 
        self:FindChild("GiftList/GiftItem"..i.."/Introduce/Top/2/Tip2").text = string.format(self.language.ZDHD,Data.ZDHD)
        self:FindChild("GiftList/GiftItem"..i.."/Introduce/Bottom").text = Data.GiftTip
        -- self:FindChild("GiftList/GiftItem"..i.."/Introduce/Bottom2").text = Data.linshi > 0 and string.format(self.language.witchHat,Data.linshi) or ""
        self:FindChild("GiftList/GiftItem"..i.."/Introduce/Bottom2").text = Data.extrarew > 0 and string.format(self.language.snow,Data.extrarew) or ""
        self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/Exchange/Price").text = self.wareCfg[Data.WareId].Price
        self:FindChild("GiftList/GiftItem"..i.."/Vip/Text").text = Data.NeedVip

        local bgParent = self:FindChild("GiftList/GiftItem"..i.."/Bg")
        for i = 1,bgParent.childCount do
            local childobj = bgParent:GetChild(i-1)
            childobj:SetActive(childobj.name == Data.BgIcon)
        end

        self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/CountDown"):SetActive(not Data.Status)
        self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/Exchange"):SetActive(Data.Status)
        self:FindChild("GiftList/GiftItem"..i.."/Vip"):SetActive(not (CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= Data.NeedVip))
		self:FindChild("GiftList/GiftItem"..i.."/Bg/Coin"):SetActive(true)

        self:AddClick(self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/Exchange/BG"), function() self:OnClickExchangeBtn(Data) end,nil,true)
        self:AddClick(self:FindChild("GiftList/GiftItem"..i.."/Vip"), function() self:OnClickVipBtn(Data) end,nil,true)
        self:AddClick(self:FindChild("GiftList/GiftItem"..i.."/Bg"), function() self:OnClickExchangeBtn(Data) end,nil,true)
    end
	self.MeritsIcon = self:FindChild("Merits")
	self:AddClick(self.MeritsIcon,function ()
			local bubble = self.MeritsIcon:FindChild("Bubble")
			bubble:SetActive(true)
			self:DelayRun(3,function ()
					bubble:SetActive(false)
				end)
		end)
	self:AddClick(self.MeritsIcon:FindChild("Bubble/Close"),function ()
			self.MeritsIcon:FindChild("Bubble"):SetActive(false)
		end)

end


function HolidayDiscountsView:OnClickExchangeBtn(Data)
    if not Data.Status then
        CC.ViewManager.ShowTip(self.language.BuyTip)
        return
    end
    local currentVipLevel=CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    if currentVipLevel < Data.NeedVip then
        local box = CC.ViewManager.ShowMessageBox(self.language.VipDJBZ,
            function()
                if CC.ViewManager.IsViewOpen("DailyGiftCollectionView") then
                    CC.ViewManager.GetCurrentView():ActionOut()
                end
                local openView="NoviceGiftView"
                if Data.NeedVip<=1 then
                    openView="NoviceGiftView"
                elseif Data.NeedVip>1 then
                    openView="VipThreeCardView"
                end
                CC.ViewManager.Open("SelectGiftCollectionView", {currentView = openView,closeFunc=function ()
                    CC.ViewManager.Open("DailyGiftCollectionView",{currentView="HolidayDiscountsView"})
                end})
			end)
        box:SetOneButton();
        return
    end
    local price = self.wareCfg[Data.WareId].Price
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
        CC.Request("ReqBuyWithId",{WareId = Data.WareId, ExchangeWareId = Data.WareId});
    else
        if self.walletView then
            self.walletView:SetBuyExchangeWareId(Data.WareId)
            self.walletView:PayRecharge()
        end
    end

end

function HolidayDiscountsView:OnClickVipBtn(Data)
    local currentVipLevel=CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    if currentVipLevel < Data.NeedVip then
        local box = CC.ViewManager.ShowMessageBox(self.language.VipDJBZ,
            function()
                if CC.ViewManager.IsViewOpen("DailyGiftCollectionView") then
                    CC.ViewManager.GetCurrentView():ActionOut()
                end
                local openView="NoviceGiftView"
                if Data.NeedVip <= 1 then
                    openView="NoviceGiftView"
                elseif Data.NeedVip > 1 then
                    openView="VipThreeCardView"
                end
                CC.ViewManager.Open("SelectGiftCollectionView", {currentView = openView,closeFunc=function ()
                    CC.ViewManager.Open("DailyGiftCollectionView",{currentView="HolidayDiscountsView"})
                end})
			end)
        box:SetOneButton();
    end
end

function HolidayDiscountsView:RefreshCountDown()
    if self.countDown <= 0 then return end
    self.countDown = self.countDown - 1
    for i, v in ipairs(self.ShowGiftData) do
        if not v.Status then
            self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/CountDown/Text").text = CC.uu.TicketFormat(self.countDown)
        end
    end
    if self.countDown <= 0 then
        self.viewCtr:LoadGiftStatus()
    end
end

function HolidayDiscountsView:RefreshUI()
    for i,data in ipairs(self.ShowGiftData) do
        self:RefreshBtn(i,data.Status)
        if self.countDown > 0 then
            self:FindChild("GiftList/GiftItem"..i.."/BottomBtn/CountDown/Text").text = CC.uu.TicketFormat(self.countDown)
        end
        self:FindChild("GiftList/GiftItem"..i.."/Vip"):SetActive(not (CC.Player.Inst():GetSelfInfoByKey("EPC_Level")>=data.NeedVip))
    end
end

function HolidayDiscountsView:RefreshBtn(index,status)
    self:FindChild("GiftList/GiftItem"..index.."/BottomBtn/CountDown"):SetActive(not status)
    self:FindChild("GiftList/GiftItem"..index.."/BottomBtn/Exchange"):SetActive(status)
end

function HolidayDiscountsView:CheckMeritsIcon()
	-- local switchOn = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("DonateView").switchOn
	-- self.MeritsIcon:SetActive(switchOn)
end

function HolidayDiscountsView:ActionIn()
    self:SetCanClick(false);
    -- self.transform.size = Vector2(125, 0)
	-- self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function HolidayDiscountsView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function HolidayDiscountsView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function HolidayDiscountsView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function HolidayDiscountsView:OnDestroy()
    self:StopTimer("RefreshCountDown")
    if self.Marquee then
        self.Marquee:Destroy()
        self.Marquee = nil
    end
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    if self.walletView then
		self.walletView:Destroy()
	end
end

return HolidayDiscountsView