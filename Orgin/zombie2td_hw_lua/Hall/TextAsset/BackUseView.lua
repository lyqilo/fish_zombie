local CC = require("CC")

local BackUseView = CC.uu.ClassView("BackUseView")

function BackUseView:ctor(param)
    self.param = param

    self.times = 1
end

function BackUseView:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_BackpackView");
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop");
    self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")

    local viewCtrClass = require("View/BackpackView/BackUseViewCtr")
    self.viewCtr = viewCtrClass.new(self);
    
    self:InitUI()
    self.viewCtr:OnCreate()
    self:InitContent()
	self:InitTextByLanguage()
    self:AddClickEvent()
end

function BackUseView:InitUI()
    self.PropImage = self:FindChild("Layer_UI/Content/Prop/Image")
    self.PropLimit = self:FindChild("Layer_UI/Content/Prop/Image/Limit")
    self.PropName = self:FindChild("Layer_UI/Content/PropName")
    self.PropNum = self:FindChild("Layer_UI/Content/PropNum/Text")
    self.PropPrice = self:FindChild("Layer_UI/Content/Sale/PropPrice/Text")
    self.UseBtn = self:FindChild("Layer_UI/Use")
    self.UseBtnText = self:FindChild("Layer_UI/Use/Text")
    self.SaleBtn = self:FindChild("Layer_UI/Sale")
    self.SaleBtnText = self:FindChild("Layer_UI/Sale/Text")
    self.Price = self:FindChild("Layer_UI/Content/Sale")
    self.TotalCount = self:FindChild("Layer_UI/Content/Sale/TotalPrice")

    self.LessOnceBtn = self:FindChild("Layer_UI/Down")
    self.LessOnceGrayBtn = self:FindChild("Layer_UI/DownGray")
    self.AddOnecBtn = self:FindChild("Layer_UI/Up")
    self.AddOnecGrayBtn = self:FindChild("Layer_UI/UpGray")
    self.MaxBtn = self:FindChild("Layer_UI/Max")
    self.MaxGrayBtn = self:FindChild("Layer_UI/MaxGray")

    self.JumpNode = self:FindChild("Layer_UI/Content/JumpDes")
    self.JumpBtn = self:FindChild("Layer_UI/Content/JumpDes/JumpBtn")

    self.InputField = self:FindChild("Layer_UI/InputField")
	UIEvent.AddInputFieldOnValueChange(self.InputField, function( str )
		self:OnInputValueChange(str)
	end)
	
	self.LessOnceBtn:FindChild("Text").text = "-"
	self.LessOnceGrayBtn:FindChild("Text").text = "-"
	self.AddOnecBtn:FindChild("Text").text = "+"
	self.AddOnecGrayBtn:FindChild("Text").text = "+"
	self.MaxBtn:FindChild("Text").text = "Max"
	self.MaxGrayBtn:FindChild("Text").text = "Max"
	self.InputField:FindChild("Text").text = "1"
end

function BackUseView:InitTextByLanguage()
    self:FindChild("Layer_UI/Content/PropNum").text = self.language.useLable
    self:FindChild("Layer_UI/Content/Sale/PropPrice").text = self.language.priceLable
    self:FindChild("Layer_UI/Label").text = self.language.useNum
    self:FindChild("Layer_UI/Content/Sale/TotalPrice/Label").text = self.language.totalLable
    self.SaleBtnText.text = self.language.saleBtn
    self.UseBtnText.text = self.language.useBtn
    self.JumpNode.text = self.language.jumpDes
end

function BackUseView:InitContent()
    self.Id = self.param.Id
    self.count = self.param.count
    self.Jump = self.param.Jump
    self.Exchange = self.param.Exchange

    --如果有key字段表示道具使用需要key
    --计算玩家可以使用的道具数量
    if #self.param.Key > 0 then
        local keyID = self.param.Key[1].ConfigID
        local openNum = self.param.Key[1].Count
        local ownKey = CC.Player.Inst():GetSelfInfoByKey(keyID)
        self.count = ownKey / openNum
    end
    
    --如果有Exchange字段
    --为道具售卖
    if #self.Exchange > 0 and self.Exchange[1].ConfigID then
        self.minPrice = self.Exchange[1].Min
        self.maxPrice = self.Exchange[1].Max
        self.awardId = self.Exchange[1].ConfigID
    end

    local sprite = self.PropDataMgr.GetIcon(self.Id)
    self.PropName.text = self.propLanguage[self.Id]
    self.PropNum.text = self.count
    self:SetImage(self.PropImage,sprite)

    if self.minPrice then
        local str = ""
        if self.minPrice == self.maxPrice then
            str = self:ChipFormat(self.minPrice)
        else
            str = self:ChipFormat(self.minPrice).." - "..self:ChipFormat(self.maxPrice)
        end
        self.PropPrice.text = str
        self.Price:SetActive(true)
        self.UseBtn:SetActive(false)
        self.SaleBtn:SetActive(true)
    else
        self.Price:SetActive(false)
        self.UseBtn:SetActive(true)
        self.SaleBtn:SetActive(false)
    end

    if self.Jump ~= 0 then
        self.JumpNode:SetActive(true)
    end

    self:ReFreshBtnState()
end

function BackUseView:AddClickEvent()
    self:AddClick("Layer_UI/BtnClose","ActionOut")
    self:AddClick(self.AddOnecBtn,function ()
        self:ModifyQuantity(true,1)
    end)
    self:AddClick(self.LessOnceBtn,function ()
        self:ModifyQuantity(false,1)
    end)
    self:AddClick(self.MaxBtn,function ()
        self:ModifyQuantity(true,0)
    end)
    self:AddClick(self.SaleBtn,function ()
        self.viewCtr:PropSaleReq(self.Id,self.times)
    end)
    self:AddClick(self.UseBtn,function ()
        self.viewCtr:PropUse(self.Id,self.times)
    end)
    self:AddClick(self.JumpBtn,function ()
        self:CheckGameState()
    end)
end

function BackUseView:ModifyQuantity(bAdd,num)
    if num == 0 then
        self.times = self.count;
    else
        if bAdd then
	    	if self.times + num <= self.count then
                self.times = self.times + num
            else
                self.times = self.count
	    	end
	    elseif self.times - num > 0 then
	    	self.times = self.times - num
        end
    end
	self:ReFreshBtnState()
end

function BackUseView:ReFreshBtnState()
    if self.times >= self.count then
        self.AddOnecBtn:SetActive(false)
        self.AddOnecGrayBtn:SetActive(true)
        self.MaxBtn:SetActive(false)
        self.MaxGrayBtn:SetActive(true)
	else
		self.AddOnecBtn:SetActive(true)
        self.AddOnecGrayBtn:SetActive(false)
        self.MaxBtn:SetActive(true)
        self.MaxGrayBtn:SetActive(false)
	end
	if self.times == 1 then
        self.LessOnceBtn:SetActive(false)
        self.LessOnceGrayBtn:SetActive(true)
	else
        self.LessOnceBtn:SetActive(true)
        self.LessOnceGrayBtn:SetActive(false)
	end
	if self.times < 0 then
        self.times = 1
    elseif self.times > self.count then
        self.times = self.count
    end
    if self.minPrice then
        local str = ""
        if self.minPrice == self.maxPrice then
            str = self:ChipFormat(self.minPrice * self.times)
        else
            str = self:ChipFormat(self.minPrice * self.times) .." - "..self:ChipFormat(self.maxPrice * self.times)
        end
        self.TotalCount.text = str
    end
    self.InputField.text = self.times
end

function BackUseView:OnInputValueChange(str)
	if str == "-" or str == "" then
		self.InputField.text = ""
        return
    end
    local str = tonumber(str)
    if str <= 0 then
        str = 1
    elseif str > 9999 then
        str = 9999
    end
    self.times = str
    self:ReFreshBtnState()
end

function BackUseView:ChipFormat(number)
    if not number then
        logError("uu.NumberFormat:必须传值");
        return
    end

    local function formatnumberthousands(num)
        local formatted = num
        local k
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then 
                break end
            end
        return formatted
    end

    if number < 1e6 then
        return formatnumberthousands(number)
    elseif number < 1e8 then
        return formatnumberthousands(string.format("%.2f",number/1e6)).."M"
    elseif number < 1e11 then
        return formatnumberthousands(string.format("%.2f",number/1e9)).."B"
    elseif number < 1e14 then
        return formatnumberthousands(string.format("%.2f",number/1e12)).."T"
    else
        return "999.99T"
    end
end

function BackUseView:CheckGameState()
    if self.Jump == 0 then return end
    local id = self.Jump
    CC.ViewManager.CloseAllOpenView()
    CC.HallUtil.CheckAndEnter(id)
    local currentView = CC.ViewManager.GetCurrentView();
	--聚焦当前界面回调
	if currentView and currentView.OnFocusIn then
		currentView:OnFocusIn();
	end
end

function BackUseView:OnDestroy()
    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
    self.InputField = nil
end

return BackUseView