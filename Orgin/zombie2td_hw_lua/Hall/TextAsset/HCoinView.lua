local CC = require("CC")
local HCoinView = CC.uu.ClassView("HCoinView")

function HCoinView:ctor(...)
	self:InitVar(...);
end

function HCoinView:InitVar(...)
    self.param = {...}
    self.language = self:GetLanguage()
    self.countDown = 0
    self.TaskItems = {}
    self.HashRateItems = {}
    self.HCoinItems = {}
    
end

function HCoinView:OnCreate()
	self:InitNode()
    self:InitClickEvent()
    self:InitView()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()

    self:StartTimer("RefreshOnLine",60,function()
        if self.TaskItems[2] and self.TaskItems[2].data.Status == 0 then
            --在线任务未完成时每60秒刷新一次在线任务
            CC.Request("ReqBCTaskList",{PlayerID = self.viewCtr.ID})
        end
    end,-1)
    self:StartTimer("Time",1,function()
        if self.countDown > 0 then
            self.countDown = self.countDown - 1 
            self.TimeTex.text = self.countDown > 0 and CC.uu.TicketFormat(self.countDown) or "00:00:00"

            if self.countDown <= 0 then
                --倒计时完请求列表是否有火币可领取
                CC.Request("ReqBCTaskList",{PlayerID = self.viewCtr.ID})
            end 
        end
    end,-1)
    self:StartTimer("diandiandiandian",2,function()
        local len = string.len(self.dian.text)
        if len >= 6 then
            self.dian.text = "."
        else
            self.dian.text = self.dian.text.."."
        end
    end,-1)
end

function HCoinView:InitNode()
    self.TimeTex = self:FindChild("UpPart/Time")
    self.HashRate = self:FindChild("UpPart/HashRate/Text")
    self.HCion = self:FindChild("UpPart/HCoin/Text")
    self.dian = self:FindChild("UpPart/Text1/diandiandiandian")
    self.Taskitem = self:FindChild("DownPart/Scroll View/Viewport/item")
    self.TaskitemParent = self:FindChild("DownPart/Scroll View/Viewport/Content")

    self.History_HCoin = self:FindChild("History_HCoin")
    self.HisHCoinNum = self.History_HCoin:FindChild("Num")
    self.Hcoinitem = self.History_HCoin:FindChild("Scroll View/Viewport/item")
    self.HcoinitemParent = self.History_HCoin:FindChild("Scroll View/Viewport/Content")

    self.History_HashRate = self:FindChild("History_HashRate")
    self.HisHashRateNum = self.History_HashRate:FindChild("Num")
    self.HashRateitem = self.History_HashRate:FindChild("Scroll View/Viewport/item")
    self.HashRateitemParent = self.History_HashRate:FindChild("Scroll View/Viewport/Content")

    self.Time = self:FindChild("UpPart/Time")
    self.WbePanel = self:FindChild("WebPanel")
end

function HCoinView:InitClickEvent()
    self:AddClick("UpPart/HashRate/Btn",function() self:OpenPanel(1) end)
    self:AddClick("UpPart/HCoin/Btn",function() self:OpenPanel(2) end)
    self:AddClick("CenterPart/ExplainBtn","OpenExplainView")
    self:AddClick("History_HashRate/CloseBtn",function() self:ClosePanel(1) end)
    self:AddClick("History_HCoin/CloseBtn",function() self:ClosePanel(2) end)
    self:AddClick("History_HCoin/ExchangeBtn","OnClickExchange")
    self:AddClick("WebPanel/Bg/Close",function() self:ClosePanel(3) end)
end

function HCoinView:InitView()
    self:FindChild("UpPart/Text1").text = self.language.JSHQZ
    self:FindChild("UpPart/Text2").text = self.language.SYFF
    self:FindChild("CenterPart/Text").text = self.language.Tip
    self.dian.text = "."

    self.History_HCoin:FindChild("Tip").text = self.language.JL1
    self.History_HCoin:FindChild("Title/Image/Text").text = self.language.FRT
    self.History_HCoin:FindChild("Scroll View/Viewport/Empty/Text").text = self.language.NotRecord

    self.History_HashRate:FindChild("Tip").text = self.language.JL2
    self.History_HashRate:FindChild("Title/Image/Text").text = self.language.SL
    self.History_HashRate:FindChild("Scroll View/Viewport/Empty/Text").text = self.language.NotRecord
end

function HCoinView:OpenPanel(flag)
    self:SetCanClick(false);
    local obj = flag == 1 and self.History_HashRate or (flag == 2 and self.History_HCoin or self.WbePanel)
    obj:SetActive(true)
    obj.transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(obj, {"scaleTo", 1, 1, flag == 3 and 0.2 or 0.3, ease=CC.Action.EOutBack, function()
            self:SetCanClick(true);
            if flag == 3 and self.viewCtr.webview then
                self.viewCtr.webview:SetVisibility(true)
            end
    end})
end

function HCoinView:ClosePanel(flag)
    if flag == 3 and self.viewCtr.webview then
        self.viewCtr.webview:SetVisibility(false)
    end
    self:SetCanClick(false);
    local obj =  flag == 1 and self.History_HashRate or (flag == 2 and self.History_HCoin or self.WbePanel)
    self:RunAction(obj, {"scaleTo", 0.5, 0.5, flag == 3 and 0.2 or 0.3, ease=CC.Action.EInBack, function()
            self:SetCanClick(true);
            obj:SetActive(false)
    end})
end

function HCoinView:OpenExplainView()
    local data = {
		title = self.language.explainTitle,
		content =self.language.explainContent,
	}
	CC.ViewManager.Open("CommonExplainView",data )
end

function HCoinView:OnClickExchange()
    if self.viewCtr.Token then
        self.viewCtr:OpenWebStore()
    else
        CC.Request("ReqBCToken",{PlayerID = self.viewCtr.ID})
    end
end

function HCoinView:ShowTask(data,isDefault)
    local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    for i,v in ipairs(data.List) do
        local task = self.TaskItems[v.TaskID] 
        if not task then
            task = {obj = CC.uu.newObject(self.Taskitem, self.TaskitemParent)}
            self.TaskItems[v.TaskID] = task
        end
        task.data = v
        local obj = task.obj
        obj:FindChild("flag/achieve"):SetActive(v.TaskType == 2)
        obj:FindChild("flag/everyday"):SetActive(v.TaskType == 1)
        obj:FindChild("task").text = v.TaskID == 5 and ((v.Status == 0 and vip < 30) and string.format(self.language["Task"..v.TaskID],vip + 1) or string.format(self.language["Task"..v.TaskID],vip)) or self.language["Task"..v.TaskID]
        obj:FindChild("progress").text = (v.ReceiveLevel < v.PendingLevel and v.ReceiveLevel or v.PendingLevel).."/"..v.PendingLevel
        obj:FindChild("reward/num").text = "+"..v.PropNum
        obj:FindChild("reward/text").text = self.language.SL

        obj:FindChild("btn/goto"):SetActive(v.Status == 0)
        if v.TaskID == 2 then
            obj:FindChild("btn/goto"):SetActive(false)
        end
        obj:FindChild("btn/goto/text").text = self.language.GoTo
        self:AddClick(obj:FindChild("btn/goto"),function ()
            local fun = self.viewCtr.TaskData.List[v.TaskID].onClick
            if fun then fun(self.viewCtr) end 
            if v.TaskID ~= 3 and v.TaskID ~= 11 and self.param and self.param[2] then self.param[2]:ActionOut() end
        end)

        obj:FindChild("btn/get"):SetActive(v.Status == 2)
        obj:FindChild("btn/get/text").text = self.language.Get
        self:AddClick(obj:FindChild("btn/get"),function()
          --请求领取算力
          CC.Request("ReqBCReceive",{PlayerID = self.viewCtr.ID,TaskID = v.TaskID})
        end)

        obj:FindChild("btn/gray"):SetActive(v.Status == 1)
        if v.TaskID == 2 then
            obj:FindChild("btn/gray"):SetActive(v.Status == 0 or v.Status == 1)
        end
        obj:FindChild("btn/gray/text").text = isDefault and self.language.GoTo or (v.Status == 0 and self.language.Get or self.language.GetOver)
        self:AddClick(obj:FindChild("btn/gray"),function () 
            if isDefault or v.Status == 0 then return end
            CC.ViewManager.ShowTip(self.language.GetOver) 
        end)

        if not obj.activeSelf then obj:SetActive(true) end
    end
    for i,v in ipairs(self.TaskItems) do
        if v.data.Status == 0 or v.data.Status == 2 then v.obj:SetSiblingIndex(v.data.TaskID - 1) end
    end
    for i,v in ipairs(self.TaskItems) do
        if v.data.Status == 1 then v.obj:SetAsLastSibling() end
    end
end

function HCoinView:ShowHashRateHistory(data)
    self.History_HashRate:FindChild("Scroll View/Viewport/Empty"):SetActive(#data.List <= 0)

    for i,v in ipairs(data.List) do
        local obj = self.HashRateItems[i]
        if not obj then
            obj = CC.uu.newObject(self.HashRateitem, self.HashRateitemParent)
            table.insert(self.HashRateItems,obj)
        end
        obj:FindChild("flag/add"):SetActive(v.IsAdd == 1)
        obj:FindChild("flag/minus"):SetActive(v.IsAdd == 2)
        obj:FindChild("time").text = CC.uu.TimeOut3(v.ReceiveTime)
        obj:FindChild("reasons").text = v.TaskID == 5 and string.format(self.language["Task"..v.TaskID], v.ReceiveLevel) or self.language["Task"..v.TaskID]
        obj:FindChild("hashRate/num").text = "+".. CC.uu.numberToStrWithComma(v.PropNum)
        obj:FindChild("hashRate/text").text = self.language.SL

        if not obj.activeSelf then obj:SetActive(true) end
    end
end

function HCoinView:ShowHCoinHistory(data)
    self.History_HCoin:FindChild("Scroll View/Viewport/Empty"):SetActive(#data.List <= 0)

    for i,v in ipairs(data.List) do
        local obj = self.HCoinItems[i]
        if not obj then
            obj = CC.uu.newObject(self.Hcoinitem, self.HcoinitemParent)
            table.insert(self.HCoinItems,obj)
        end
        obj:FindChild("flag/add"):SetActive(v.IsAdd == 1)
        obj:FindChild("flag/minus"):SetActive(v.IsAdd == 2)
        obj:FindChild("time").text = CC.uu.TimeOut3(v.CreateTime / 1000)
        obj:FindChild("reasons").text = v.BalanceType == 1 and self.language.ZhuanZhang or (v.BalanceType == 2 and self.language.Buy or self.language.Earnings)
        local num = self:HCionNumDeal(v.Balance)
        obj:FindChild("hcoin/num").text = v.IsAdd == 1 and "+"..num or "-"..num
        obj:FindChild("hcoin/text").text = self.language.FRT

        if not obj.activeSelf then obj:SetActive(true) end
    end
end

function HCoinView:RefreshHashRateAndHCoin(hashRate,hCoin)
    hashRate = CC.uu.numberToStrWithComma(hashRate)
    self.HashRate.text = hashRate
    self.HisHashRateNum.text = hashRate
    
    --hCoin = 111
    hCoin = self:HCionNumDeal(hCoin)
    self.HCion.text = hCoin
    self.HisHCoinNum.text = hCoin
end

function HCoinView:HCionNumDeal(hCoin)
    if hCoin <= 0 then return 0  end
    if hCoin < 100 then
        if hCoin % 10 ~= 0  then
            hCoin = CC.uu.keepDecimal(hCoin/1000000,6,true)
        else
            hCoin = CC.uu.keepDecimal(hCoin/1000000,5,true)
        end
    else
        hCoin = hCoin / 1000000
    end
    local tb = tostring(hCoin):split(".")
    if tb[1] and tb[2] then
        hCoin = CC.uu.numberToStrWithComma(tonumber(tb[1])).."."..tb[2]
    end
    return hCoin
end

function HCoinView:ActionIn()
    self:SetCanClick(false);
    self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function HCoinView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
        })
    self:Destroy()
end

function HCoinView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
end

return HCoinView    