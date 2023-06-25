local GC = require("GC")
local ZTD = require("ZTD")

local WeeksCardView = GC.class2("ZTD_WeeksCardView")

function WeeksCardView:ctor(_, parent, dayIdx)
    -- log("dayIdx="..tostring(dayIdx))
    self.parent = parent
    self.dayIdx = dayIdx
    self.GiftState = true
    --周卡礼包id 30017
    self.wareId = "30017"
end

function WeeksCardView:Init() 
    self:OrderState(function(CountDown)
        self:InitData()
        self:InitUI()
        if not self.GiftState then
            self:StartCountDown(CountDown)
        else
            self:RefreshCountDown(false)
        end
    end)
end

--获取周卡礼包数据
function WeeksCardView:OrderState(func)
    ZTD.Utils.ShowWaitTip()
    local param = {}
    param.wareId = {self.wareId}
    param.succCb = function(err, data)
        if data.Items then
            -- logError("OrderState data.Items="..GC.uu.Dump(data.Items))
			for _, v in ipairs(data.Items) do
                -- GC.DataMgrCenter.Inst():GetDataByKey("Activity").SetGiftStatus(v.WareId, v.Enabled)
                -- self.GiftState = GC.SubGameInterface.ByWareIdGetState(self.wareId)
                if tonumber(v.WareId) == tonumber(self.wareId) then
                    ZTD.Utils.CloseWaitTip()
                    self.GiftState = v.Enabled
                    -- logError("GiftState="..tostring(self.GiftState))
                    if func then
                        func(v.CountDown)
                    end
                end
            end
		end
    end
    param.errCb = function(err, data)
        logError("errCb"..err)
        ZTD.Utils.CloseWaitTip()
    end
    GC.SubGameInterface.ByWareIdOrderState(param)
end

function WeeksCardView:InitData()
    self.panelItemNode = self.parent:FindChild("root/panelList/panel_weeksCard/panelItemNode")
    self.walletNode = self.parent:FindChild("root/panelList/panel_weeksCard/walletNode")
    self.countDownNode = self.parent:FindChild("root/panelList/panel_weeksCard/btnNode/countDownNode")
    self.payNode = self.parent:FindChild("root/panelList/panel_weeksCard/btnNode/btn_pay")
    self.dayText = self.parent:FindChild("root/panelList/panel_weeksCard/btnNode/countDownNode/day"):GetComponent("Text")
    self.hourText = self.parent:FindChild("root/panelList/panel_weeksCard/btnNode/countDownNode/hour"):GetComponent("Text")
    self.panel7Day = self.parent:FindChild("root/panelList/panel_weeksCard/panel_7Day")

    local param={}
    param.wareId = self.wareId
    param.parent = self.walletNode.transform
    param.width = 1136
    param.height = 640
    param.succCb = function() end
    self.hallWalletView = GC.SubGameInterface.CreateWalletView(param)

    self.orgHour = nil
    self.obj = nil
end

function WeeksCardView:InitUI()
    self:RefreshDiamond()
    self:Refresh7DayUI()
    self:AddEvent()
end

function WeeksCardView:AddEvent()
    self.parent:AddClick("root/panelList/panel_weeksCard/btnNode/btn_pay", function()
        self:OnClickBuy()
    end)
    self.parent:AddClick("root/panelList/panel_weeksCard/btnNode/countDownNode", function()
        self:CloseAllItemPanel()
        self:OrderState(function(CountDown)
            -- log("点击倒计时 礼包是否购买过="..tostring(self.GiftState))
            if not self.GiftState then
                self:StartCountDown(CountDown)
                local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
                GC.ViewManager.ShowTip(language.tips_giftColling)
            else
                self:RefreshCountDown(false)
            end
        end)
    end)
    for i = 1, 3 do
        self.parent:AddClick("root/panelList/panel_weeksCard/btnItemNode/btn_item"..i, function()
            self:OnItemClick(i)
        end)
    end
    self.parent:AddClick("root/panelList/panel_weeksCard/btn_Mask", function()
        self:OnItemClick(0)
    end)
end

--刷新钻石
function WeeksCardView:RefreshDiamond()
    local diamond = GC.uu.numberToStrWithComma(ZTD.PlayerData.GetDiamond())
    self.parent:SetText(self.hallWalletView:FindChild("DiamondNode/Text"), diamond)
end

--刷新特权卡介绍面板
function WeeksCardView:Refresh7DayUI()
    if not self.dayIdx then
        for i = 1, 3, 1 do
            local obj = self.panel7Day:GetChild(i-1):FindChild("bg")
            obj:SetActive(false)
        end
    else
        self.obj = self.panel7Day:GetChild(self.dayIdx-1):FindChild("bg")
        self.obj:SetActive(true)
        self:BreatheTweenAction()
    end
end

--外发光呼吸动画
function WeeksCardView:BreatheTweenAction()
    if self._loopAct == nil then
		self._loopAct = ZTD.Extend.RunAction(self.obj, {
            {"fadeToAll", 51, 1.5},
            {"delay", 0.5},
            {"fadeToAll", 255, 1.5},
            loop = 1073741823,
            })
	end			
end

--刷新倒计时
function WeeksCardView:RefreshCountDown(state, day, hour)
    -- log("RefreshCountDown")
    self.payNode:SetActive(not state)
    self.countDownNode:SetActive(state)
    if day and hour then
        self.dayText.text = day
        self.hourText.text = hour
    end
end

function WeeksCardView:TimeFormat(Second)
    local text = GC.uu.TicketFormat2(Second)
    local temp = string.split(text, ":")
    -- log("周卡倒计时 temp="..GC.uu.Dump(temp))
    local day = temp[1]%10
    local hour = temp[2]
    return day, hour
end

--开始倒计时
function WeeksCardView:StartCountDown(Second)
    -- log("Second="..Second)
    local day, hour = self:TimeFormat(Second)
    self.orgHour = hour
    -- log("day = "..tostring(day).."  hour="..hour)
    self:RefreshCountDown(true, day, hour)

    self.parent:StartTimer("CountDown", 1, function()
        Second = Second - 1
        if Second < 0 then
            self.parent:StopTimer("CountDown")
            self:RefreshCountDown(false)
            return
        end
        -- logError("Second="..Second)
        local day, hour = self:TimeFormat(Second)
        -- log("day = "..tostring(day).."  hour="..hour.."  orgHour="..self.orgHour)
        if self.orgHour - hour > 0 then
            self:RefreshCountDown(true, day, hour)
        end
    end, -1)
end

--点击支付
function WeeksCardView:OnClickBuy()
    self:CloseAllItemPanel()
    self:OrderState(function(CountDown)
        if not self.GiftState then
            self:StartCountDown(CountDown)
            -- log("点击购买 礼包是否购买过="..tostring(self.GiftState))
            local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
            GC.ViewManager.ShowTip(language.tips_gift)
        else
            self:RefreshCountDown(false)
            local param = {}
            param.wareId = self.wareId
            param.walletView = self.hallWalletView
            GC.SubGameInterface.DiamondBuyGift(param)
        end
    end)
end

--点击奖品
function WeeksCardView:OnItemClick(id)
    for i = 1, 3 do
        local obj = self.panelItemNode:GetChild(i-1)
        obj:FindChild("Image/Text"):GetComponent("Text").text = self:GetItemPanelText(i) 
        local state = obj.transform.activeSelf
        if id == i then
            obj:SetActive(not state)
        else
            obj:SetActive(false)
        end
    end
end

--购买成功显示奖励
function WeeksCardView:ShowRewards(data)
    local item = {}
    for k, v in pairs(data.Rewards) do
        item[k] = {}
        item[k].ConfigId = v.ConfigId
        item[k].Count = v.Count
    end
    -- log("周卡礼包显示奖励！！！"..GC.uu.Dump(item))
    self.GiftState = false
    -- GC.DataMgrCenter.Inst():GetDataByKey("Activity").SetGiftStatus(self.wareId, false)
    GC.ViewManager.OpenRewardsView({items = item})
end

--获取对应ItemPanel文本
function WeeksCardView:GetItemPanelText(id)
    if id == 1 then
        return self.parent.language.txt_panel_weeksCard_item1
    elseif id == 2 then
        return self.parent.language.txt_panel_weeksCard_item2
    elseif id == 3 then
        return self.parent.language.txt_panel_weeksCard_item3
    end
end

--关闭所有ItemPanel
function WeeksCardView:CloseAllItemPanel()
    for i = 1, 3 do
        local obj = self.panelItemNode:GetChild(i-1)
        obj:SetActive(false)
    end
end

function WeeksCardView:Release()
    -- GC.UserData.Save(ZTD.gamePath.."GiftState", {GiftState = self.GiftState})
    if self._loopAct then
        ZTD.Extend.StopAction(self._loopAct)
        self._loopAct = nil
        ZTD.Extend.RunAction(self.obj, {{"fadeToAll", 255, 0},})
    end	
    self.parent:StopTimer("CountDown")
    GC.SubGameInterface.DestroyWalletView(self.hallWalletView)
end

return WeeksCardView