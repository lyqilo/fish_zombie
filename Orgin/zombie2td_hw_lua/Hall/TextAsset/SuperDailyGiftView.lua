
local CC = require("CC")
local SuperDailyGiftView = CC.uu.ClassView("SuperDailyGiftView")

function SuperDailyGiftView:ctor(param)
	self:InitVar(param);
end

function SuperDailyGiftView:InitVar(param)
    self.param = param or {}
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")

    self.GiftLevel = {
        {"30336","30337","30339","30338"},
        {"30337","30338","30340","30339"},
        {"30338","30339","30341","30340"},
        {"30338","30340","30342","30341"},
    }
    self.AllGiftData = {
        ["30336"] = {WareId="30336",Status=true,Star = 1,CountDown = -2,Worth="60K-120K",ItemList = {
                        {propId = 4,num = 2},{propId = 4011,num = 1},{propId = 1152,num = 1},{propId = 1016,num = 2},
                    }},
        ["30337"] = {WareId="30337",Status=true,Star = 2,CountDown = -2,Worth="174K-680K",ItemList = {
                        {propId = 4,num = 5},{propId = 4011,num = 3},{propId = 1152,num = 3},{propId = 1006,num = 1},
                    }},
        ["30338"] = {WareId="30338",Status=true,Star = 3,CountDown = -2,Worth="305K-700K",ItemList = {
                        {propId = 4011,num = 5},{propId = 1152,num = 5},{propId = 1016,num = 2},{propId = 1006,num = 1},
                    }},
        ["30339"] = {WareId="30339",Status=true,Star = 4,CountDown = -2,Worth="620K-1.6M",ItemList = {
                        {propId = 4011,num = 10},{propId = 1152,num = 10},{propId = 1016,num = 3},{propId = 1006,num = 2},
                    }},
        ["30340"] = {WareId="30340",Status=true,Star = 5,CountDown = -2,Worth="1.89M-6M",ItemList = {
                        {propId = 4011,num = 20},{propId = 1152,num = 20},{propId = 1006,num = 1},{propId = 1007,num = 1},
                    }},
        ["30341"] = {WareId="30341",Status=true,Star = 6,CountDown = -2,Worth="3.09M-9M",ItemList = {
                        {propId = 4011,num = 30},{propId = 1152,num = 30},{propId = 1006,num = 1},{propId = 1007,num = 2},
                    }},
        ["30342"] = {WareId="30342",Status=true,Star = 7,CountDown = -2,Worth="6.3M-12M",ItemList = {
                        {propId = 4011,num = 50},{propId = 1152,num = 50},{propId = 1007,num = 2},{propId = 1017,num = 1},
                    }},
    }
    --倒计时
    self.countDown = 0
    self.GiftList = {}
end

function SuperDailyGiftView:OnCreate()
    -- self.language = self:GetLanguage()
    self.walletView = CC.uu.CreateHallView("WalletView",{})
    self.walletView.transform:SetParent(self.transform, false)
	self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()

    for i = 1, 4 do
        self.GiftList[i] = self:FindChild("GiftList/GiftItem"..i)
    end

    self:FindChild("Time").text = "เวลากิจกรรม 15/05/2023 - 24/05/2023"
    self:FindChild("Tip").text = "แพ็คเกจรายวันซื้อได้วันละ1ครั้ง\nแพ็คของขวัญจำกัดการซื้อรายวัน ยิ่งVIPสูงก็จะพบกับแพ็คเกจสุดคุ้มยิ่งกว่าเดิม"
    self:SelectGiftLevel()
end

function SuperDailyGiftView:SelectGiftLevel(curLevel)

    local playerLv = curLevel or CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    local curGiftLevel = 1
    if playerLv >= 3 and playerLv <= 5 then
        curGiftLevel = 2
    elseif playerLv >= 6 and playerLv <= 9 then
        curGiftLevel = 3
    elseif playerLv >= 10 then
        curGiftLevel = 4
    end

    if self.Level ~= curGiftLevel then
        self.Level = curGiftLevel
        self.ShowGiftData = {}
        for _,v in ipairs(self.GiftLevel[curGiftLevel]) do
            local data = self.AllGiftData[v]
            table.insert(self.ShowGiftData,data)
        end

        self.viewCtr:LoadGiftStatus()
        self:InitUI()
    end

end

function SuperDailyGiftView:InitUI()
    for i = 1, 4 do
        local Data = self.ShowGiftData[i]
        self.GiftList[i]:FindChild("Content/Worth").text = Data.Worth
        self.GiftList[i]:FindChild("BottomBtn/Exchange/Price").text = self.wareCfg[Data.WareId].Price

        local bgParent = self.GiftList[i]:FindChild("Bg")
        for k = 1,bgParent.childCount do
            local childobj = bgParent:GetChild(k-1)
            childobj:SetActive(self.Level == k)
        end
        for k = 1, 7 do
            self.GiftList[i]:FindChild(string.format("Star/%d", k)):SetActive(Data.Star >= k)
        end

        for k = 1, 4 do
            local node = self.GiftList[i]:FindChild(string.format("Content/ItemList/%d", k))
            self:SetImage(node:FindChild("Icon"), self.propCfg[Data.ItemList[k].propId].Icon)
            local strNum = Data.ItemList[k].num == 0 and "" or string.format("x%s", Data.ItemList[k].num)
            node:FindChild("Text").text = strNum
            if Data.ItemList[k].propId == 2 then
                node:FindChild("Text").text = "ชิป"
            end
        end

        self:RefreshBtn(i, Data.Status)
        self:AddClick(self.GiftList[i]:FindChild("BottomBtn/Exchange"), function()
            self:OnClickExchangeBtn(Data)
        end,nil,true)
    end
    self:AutoRoll()
end

function SuperDailyGiftView:OnClickExchangeBtn(Data)
    if not Data.Status then
        CC.ViewManager.ShowTip("แพ็คเกจประจำวันทุกรายการจำกัดซื้อวันละ1ครั้ง")
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

function SuperDailyGiftView:RefreshCountDown()
    self:UpdataCountDown()
    self:StopTimer("SuperDailyGiftCountDown")
    self:StartTimer( "SuperDailyGiftCountDown",1,function()
        self.countDown = self.countDown - 1
        self:UpdataCountDown()
        if self.countDown <= 0 then
            self:StopTimer("SuperDailyGiftCountDown")
            self.viewCtr:LoadGiftStatus()
        end
    end,-1)
end

function SuperDailyGiftView:UpdataCountDown()
    for i, v in ipairs(self.ShowGiftData) do
        if not v.Status then
            self.GiftList[i]:FindChild("BottomBtn/CountDown/Text").text = CC.uu.TicketFormat(self.countDown)
        end
    end
end

function SuperDailyGiftView:RefreshUI()
    for i,data in ipairs(self.ShowGiftData) do
        self:RefreshBtn(i,data.Status)
    end
    if self.countDown > 0 then
        self:RefreshCountDown()
    end
end

function SuperDailyGiftView:RefreshBtn(index,status)
    self.GiftList[index]:FindChild("BottomBtn/CountDown"):SetActive(not status)
    self.GiftList[index]:FindChild("BottomBtn/Exchange"):SetActive(status)
end

function SuperDailyGiftView:AutoRoll()
    self:StopTimer("AutoRollItem")
    local countDown = 1
    self:StartTimer( "AutoRollItem",1,function()
        countDown = countDown + 1
        if countDown >= 2 then
            countDown = 0
            for i = 1, 4 do
                -- self:DelayRun(0.2*i, function ()
                    for k = 1, 4 do
                        local node = self.GiftList[i]:FindChild(string.format("Content/ItemList/%d", k))
                        self:RunAction(node, {"localMoveTo", node.localPosition.x - 64, 0, 0.4*i, function()
                            if node.localPosition.x <= -126 then
                                node.localPosition = Vector3(130,0,0)
                            end
                        end})
                    end
                -- end)
            end
        end
    end,-1)
end

function SuperDailyGiftView:ActionIn()
    self:SetCanClick(false);
    if self.param and self.param.isOffset then
        self.transform.localPosition = Vector3(125/2, 0, 0)
    end
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function SuperDailyGiftView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function SuperDailyGiftView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function SuperDailyGiftView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function SuperDailyGiftView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    if self.walletView then
		self.walletView:Destroy()
	end
end

return SuperDailyGiftView