local CC = require("CC")
local SafeBoxView = CC.uu.ClassView("SafeBoxView")

function SafeBoxView:ctor(param)
	self:InitVar(param);
end

function SafeBoxView:InitVar(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    self.availableAmount = 0
    self.insuranceAmount = 0
    self.miniAmount = "1M" --转入保底值，身上筹码减去这个保底值之后剩余的筹码才可转入到保险箱
    self.currentMoney = 0
    self.canInto = true
    self.canOut = true
end

function SafeBoxView:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

    self:InitView()
end

function SafeBoxView:InitView()
    self:FindChild("Bg/Toggles/Into/Background/Label").text = self.language.into
    self:FindChild("Bg/Toggles/Into/Background/Checkmark/Label").text = self.language.into
    self:FindChild("Bg/Toggles/Out/Background/Label").text = self.language.out
    self:FindChild("Bg/Toggles/Out/Background/Checkmark/Label").text = self.language.out
    self:FindChild("Bg/Toggles/Record/Background/Label").text = self.language.record
    self:FindChild("Bg/Toggles/Record/Background/Checkmark/Label").text = self.language.record
    self:FindChild("Bg/RecordPanel/Top/Time").text = self.language.time
    self:FindChild("Bg/RecordPanel/Top/Des").text = self.language.des
    self:FindChild("Bg/RecordPanel/Top/Count").text = self.language.count
    self:FindChild("Bg/RecordPanel/Empty/Text").text = self.language.notRecord
    self:FindChild("Bg/RecordPanel/BottomTip").text = self.language.recordTip

    self.scroRect = self:FindChild("Bg/RecordPanel/Scroll View"):GetComponent("ScrollRect")
	self.scroController = self:FindChild("Bg/RecordPanel/ScrollerController"):GetComponent("ScrollerController")
	self.scroController:AddChangeItemListener( function(tran,dataIndex,cellIndex) self:ShowRecord(tran,dataIndex) end)

    for i = 1,2 do
        local node = i == 1 and self:FindChild("Bg/IntoPanel") or self:FindChild("Bg/OutPanel")
        node:FindChild("Image/Current/Text").text = self.language["curNumber"..i]
        node:FindChild("Image/Box/Text").text = self.language.boxNumber
        node:FindChild("Tips").text = self.language.tip
        node:FindChild("OKBtn/Text").text = i == 1 and self.language.into or self.language.out
        
        self:AddClick(node:FindChild("OKBtn"),function() self:OnClickOK(i) end)
        self:AddClick(node:FindChild("Max"),function() self:OnClickMax(node) end)
        self:AddClick(node:FindChild("Input/InputField"),function() node:FindChild("Slider"):GetComponent("Slider").value = 0 end)

        UIEvent.AddSliderOnValueChange(node:FindChild("Slider"),function(value)
            value = value * self["factor"..i]
            node:FindChild("Input/InputField").text = math.modf(value)
             
        end)
        UIEvent.AddInputFieldOnValueChange(node:FindChild("Input/InputField"),function(str)
            local str = tonumber(str) or 0

            node:FindChild("OKBtn").interactable = str > 0
            
            local value = i == 1 and self.availableAmount or self.insuranceAmount
            if value <= 0 or str <= 0 then
                node:FindChild("Input/InputField").text = ""
                node:FindChild("Input/InputField/ShowText").text = ""
                return
            end

            node:FindChild("Input/InputField/ShowText").text = CC.uu.ChipFormat(str,true)
        end)
        
        node:FindChild("OKBtn").interactable = #(node:FindChild("Input/InputField").text) > 0
    end
    
    UIEvent.AddToggleValueChange(self:FindChild("Bg/Toggles/Into"),function(select)
        if select then
            self:ShowIntoTip()
        else
            self:FindChild("Bg/IntoPanel/Slider"):GetComponent("Slider").value = 0
            self:FindChild("Bg/IntoPanel/Input/InputField").text = ""
        end
    end)

    UIEvent.AddToggleValueChange(self:FindChild("Bg/Toggles/Out"),function(select)
        if not select then
            self:FindChild("Bg/OutPanel/Slider"):GetComponent("Slider").value = 0
            self:FindChild("Bg/OutPanel/Input/InputField").text = ""
        end
    end)
    UIEvent.AddToggleValueChange(self:FindChild("Bg/Toggles/Record"),function(select)
        if select then
            local len = #self.viewCtr.recordData
            self:FindChild("Bg/RecordPanel/Empty"):SetActive(len <= 0)
            self:FindChild("Bg/RecordPanel/Top"):SetActive(len > 0)
            if not self.initScroller then
                self.initScroller = true
                self.scroController:InitScroller(len)
            else
                self.scroController:RefreshScroller(len,1-self.scroRect.verticalNormalizedPosition)
            end
        end
    end)

    self:AddClick(self:FindChild("Mask"),function() self:ActionOut() end)
    self:AddClick("Bg/IntoPanel/Image/TipBtn",function() self:ShowIntoTip() end)

    self:ShowIntoTip()
end

function SafeBoxView:ShowIntoTip()
    if self.delay then return end
    local obj = self:FindChild("Bg/IntoPanel/Image/TipBtn/Image")
    obj:SetActive(true)
    self.delay = self:DelayRun(1.5,function()
        obj:SetActive(false)
        self.delay = nil
    end)
end

function SafeBoxView:OnClickMax(node)
    local slider = node:FindChild("Slider"):GetComponent("Slider")
    if slider.value == slider.maxValue then
        return
    end
    slider.value = slider.maxValue
end

function SafeBoxView:OnClickOK(i)
	if i == 1 then
        if self.availableAmount <= 0 then
            CC.ViewManager.ShowTip(string.format(self.language.guaranteeTip,self.miniAmount))
            return
        end
        
        local slider = self:FindChild("Bg/IntoPanel/Slider"):GetComponent("Slider")
        local inputField = self:FindChild("Bg/IntoPanel/Input/InputField")
        local num = tonumber(inputField.text) or 0
       
        if num <= 0 or num > self.availableAmount then 
            slider.value = 0
            inputField.text = ""
            CC.ViewManager.ShowTip(num <= 0 and self.language.errorTip1 or self.language.errorTip2)
            return 
        end

        self.viewCtr:ReqInto(num)
    else
        if self.insuranceAmount <= 0 then
            CC.ViewManager.ShowTip(self.language.errorTip4)
            return
        end

        local slider = self:FindChild("Bg/OutPanel/Slider"):GetComponent("Slider")
        local inputField = self:FindChild("Bg/OutPanel/Input/InputField")
        local num = tonumber(inputField.text) or 0

        if num <= 0 or num > self.insuranceAmount then 
            slider.value = 0
            inputField.text = ""
            CC.ViewManager.ShowTip(num <= 0 and self.language.errorTip1 or self.language.errorTip3)
            return 
        end

        if not CC.HallUtil.CheckSafePassWord() then 
            slider.value = 0
            inputField.text = ""
            return 
        end
        
        self.viewCtr:ReqOut(num)
    end
end

function SafeBoxView:RefreshUI(type)
    self:FindChild("Bg/IntoPanel/Image/TipBtn/Image/Text").text = string.format(self.language.guaranteeTip,self.miniAmount)
    
	self:FindChild("Bg/IntoPanel/Image/Current/Total/Count").text = self.availableAmount > 0 and CC.uu.ChipFormat(self.availableAmount) or 0
    self:FindChild("Bg/IntoPanel/Image/Box/Total/Count").text = CC.uu.ChipFormat(self.insuranceAmount)
    self:FindChild("Bg/IntoPanel/Input/InputField/Placeholder").text = self.availableAmount > 0 and self.language.intoTip or string.format(self.language.guaranteeTip,self.miniAmount)
    local maxvalue = self:GetMaxValue(self.availableAmount,1)
    self:FindChild("Bg/IntoPanel/Slider"):GetComponent("Slider").maxValue = maxvalue
    self:FindChild("Bg/IntoPanel/Max").interactable = maxvalue > 0

    self:FindChild("Bg/OutPanel/Image/Current/Total/Count").text = CC.uu.ChipFormat(self.currentMoney)
    self:FindChild("Bg/OutPanel/Image/Box/Total/Count").text = CC.uu.ChipFormat(self.insuranceAmount)
    self:FindChild("Bg/OutPanel/Input/InputField/Placeholder").text = self.insuranceAmount > 0 and self.language.outTip or self.language.errorTip4
    maxvalue = self:GetMaxValue(self.insuranceAmount,2)
    self:FindChild("Bg/OutPanel/Slider"):GetComponent("Slider").maxValue = maxvalue
    self:FindChild("Bg/OutPanel/Max").interactable = maxvalue > 0

    if type == 1 then
        self:FindChild("Bg/IntoPanel/Slider"):GetComponent("Slider").value = 0
        self:FindChild("Bg/IntoPanel/Input/InputField").text = ""
        
    elseif type == 2 then
        self:FindChild("Bg/OutPanel/Slider"):GetComponent("Slider").value = 0
        self:FindChild("Bg/OutPanel/Input/InputField").text = ""
        
    end
end

function SafeBoxView:GetMaxValue(money,flag)
   local maxvalue = money
   self["factor"..flag] = 1
   if money > 10000000000 then
       maxvalue = 1000000
       self["factor"..flag] = money/1000000
   elseif money > 1000000 then
       maxvalue = 1000
       self["factor"..flag] = money/1000
   end
  
   return maxvalue
end

function SafeBoxView:ShowRecord(tran,dataIndex)
    local data = Json.decode(self.viewCtr.recordData[dataIndex + 1])
    tran.name = dataIndex + 1
    tran:FindChild("Time").text = CC.uu.TimeOut3(data.Time)
    tran:FindChild("Des").text = data.Type == 1 and self.language.into or self.language.out
    local str = CC.uu.ChipFormat(data.SaveAmount,true)
    tran:FindChild("Count").text = data.Type == 1 and string.format("<color=#D83221FF>+%s</color>",str) or string.format("<color=#24A621FF>-%s</color>",str)
    tran:FindChild("Image"):SetActive((dataIndex + 1) % 2 == 0)
end

function SafeBoxView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
    if self.corRecord then
		coroutine.stop(self.corRecord)
		self.corRecord = nil
	end
end

return SafeBoxView    