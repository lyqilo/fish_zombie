
local CC = require("CC")
local MonthCardView = CC.uu.ClassView("MonthCardView")

function MonthCardView:ctor(viewParam,language,btnName,collection)

	self:InitVar(viewParam,language,btnName,collection);
end

function MonthCardView:InitVar(viewParam,language,btnName,collection)
    self.param = viewParam or {}
    self.collection = collection
	self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.monthcard_pb = CC.proto.client_month_card_pb
    self.wareId1 = "30253"
    self.wareId2 = "30254"
    self.time1 = 0
    self.time2 = 0
    self.rewardCfg = {{{count = "+1399999",des = self.language.chipRew,icon = 2},{count = "+12999",des = self.language.everyRew,icon = 2},
                       {count = "+1",des = self.language.limiFrame,icon = 3034},{count = "x2",des = self.language.loginDouRew,icon = "grzx_icon_19"},
                       {count = "+1",des = self.language.reliefTime,icon = "grzx_icon_04"},{count = "+10%",des = self.language.vipDotExch,icon = "grzx_icon_17"},
                       {count = "+6",des = self.language.everyVipSuffer,icon = "grzx_icon_18"},
                      },
                      {{count = "+3799999",des = self.language.chipRew,icon = 2},{count = "+34999",des = self.language.everyRew,icon = 2},
                       {count = "-10%",des = self.language.sendReve,icon = "grzx_icon_16"},{count = "+10%",des = self.language.vipDotExch,icon = "grzx_icon_17"},
                       {count = "+1",des = self.language.reliefTime,icon = "grzx_icon_04"},{count = "+2000",des = self.language.relief,icon = "grzx_icon_04"},
                       {count = "+16",des = self.language.everyVipSuffer,icon = "grzx_icon_18"}
                      },
                     }
end

function MonthCardView:OnCreate()
    self:InitView()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()

    self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
    self:DelayRun(1,function() self:FindChild("Right/Image (1)"):GetComponent("Animator").enabled = true end)

    self:CheckTime()
end

function MonthCardView:CheckTime()
    self:StartTimer("EPC_Super_CountDown",1,function()
        if self.time1 > 0 then
            self.time1 = self.time1 - 1
            if self.time1 <= 0 then
                if CC.Player.Inst():GetSelfInfoByKey("EPC_Super") > 0 then
                    CC.Player.Inst():ChangeProp({Items = {{ConfigId = CC.shared_enums_pb.EPC_Super,Count = 0}}})
                end
                self:RefreshUI(self.monthcard_pb.Super,{time = "",buyBtn = true,receBtn = false,grayBtn = false})
                CC.ViewManager.ShowTip(string.format(self.language.expiry,self.language.card1))
            end
        end
    end,-1)
    self:StartTimer("EPC_Supreme_CountDown",1,function()
        if self.time2 > 0 then
            self.time2 = self.time2 - 1
            if self.time2 <= 0 then
                if CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") > 0 then
                    CC.Player.Inst():ChangeProp({Items = {{ConfigId = CC.shared_enums_pb.EPC_Supreme,Count = 0}}})
                end
                self:RefreshUI(self.monthcard_pb.Supreme,{time = "",buyBtn = true,receBtn = false,grayBtn = false})
                CC.ViewManager.ShowTip(string.format(self.language.expiry,self.language.card2))
            end
        end
    end,-1)
end

function MonthCardView:InitView()
    for i = 1,#(self.rewardCfg) do
        local node = i == 1 and "Left" or "Right"
        self:FindChild(node.."/Worth").text = string.format(self.language.totalVa,i == 1 and "2.4M" or "5.5M") 
        self:FindChild(node.."/Text").text = self.language.morePrivi
        self:FindChild(node.."/BuyBtn/Price").text = self.wareCfg[self["wareId"..i]].Price
        self:FindChild(node.."/ReceBtn/Text").text = self.language.receRew
        self:FindChild(node.."/GrayBtn/Text").text = self.language.tomorrowRece
        for index = 1, 7 do
            local cfg = self.rewardCfg[i][index]
            self:FindChild(node.."/Reward/"..index.."/Text").text = string.format("%s <color=#FFF222FF><size=22>%s</size></color>",string.format(cfg.des,""),cfg.count)
        end

        self:AddClick(self:FindChild(node.."/RockNode/PriviBtn"),function() CC.ViewManager.Open("MonthCardPriviView") end)
        self:AddClick(self:FindChild(node.."/BuyBtn"),function() self:BuyMonthCard(i) end,nil,true)
        self:AddClick(self:FindChild(node.."/ReceBtn"),function() self:ReceReward(i) end,nil,true)
        self:AddClick(self:FindChild(node.."/GrayBtn"),function() CC.ViewManager.ShowTip(self.language.tomorrowRece) end,nil,true)
    end
end

function MonthCardView:BuyMonthCard(index)

    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.wareCfg[self["wareId"..index]].Price then
        CC.Request("ReqBuyWithId",{WareId = self["wareId"..index], ExchangeWareId = self["wareId"..index]})
    else
        if self.walletView then
            self.walletView:SetBuyExchangeWareId(self["wareId"..index])
            self.walletView:PayRecharge()
        end
    end
end

function MonthCardView:ReceReward(index)
    CC.Request("ReqTakeMothCardDaily",{cardType = index == 1 and self.monthcard_pb.Super or self.monthcard_pb.Supreme})
end

function MonthCardView:RefreshUI(type,data)
    local node = type == self.monthcard_pb.Super and "Left" or "Right"
    if data.time then
        if data.time == "" then
            self:FindChild(node.."/Time"):SetActive(false)
        else
            self:FindChild(node.."/Time"):SetActive(true)
        end
        self:FindChild(node.."/Time/Text").text = data.time
    end
    if data.buyBtn ~= nil then
        self:FindChild(node.."/BuyBtn"):SetActive(data.buyBtn)
    end
    if data.receBtn ~= nil then
        self:FindChild(node.."/ReceBtn"):SetActive(data.receBtn)
    end
    if data.grayBtn ~= nil then
        self:FindChild(node.."/GrayBtn"):SetActive(data.grayBtn)
    end
end

function MonthCardView:ActionIn()
    self:SetCanClick(false);
    self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function MonthCardView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
        });
    self:Destroy()
end

function MonthCardView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil;
    end
    if self.walletView then
        self.walletView:Destroy()
        self.walletView = nil
	end
end

return MonthCardView