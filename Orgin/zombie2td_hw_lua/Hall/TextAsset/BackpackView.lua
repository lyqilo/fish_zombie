local CC = require("CC")

local BackpackView = CC.uu.ClassView("BackpackView")

local Type = {
    Game = 1,
    Hall = 2
}

local BtnType = {
    None = 0,
    Use = 1,
    Sale = 2
}

local HALLFEATURES = {
    [100001] = "RenameView",
    [100002] = "TreasureView",
	[100004] = "AnniversaryTurntableView",
}

function BackpackView:ctor(param)
    self.param = param or {}

    self.callback = self.param.callback

    self.BackpackCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Backpack")
    self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	self.playerData = CC.Player.Inst():GetSelfInfo().Data.Player
    --当前背包
    self.curType = Type.Game
    --道具列表
    self.hallList = {}
    self.gameList = {}
    --道具Map
    self.propMap = {}
    --当前道具
    self.curProp = nil
end

function BackpackView:ActionIn()
	self:SetCanClick(false);
    self.transform.size = Vector2(3000, 3000)
    self.transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
            self:SetCanClick(true);
            if self.param.guideFun then
                self.viewCtr:OnCreate()
            end
    	end})
    CC.Sound.PlayHallEffect("click_boardopen");
end

function BackpackView:OnCreate()
    self.language = self:GetLanguage()
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop");
    self.viewCtr = self:CreateViewCtr(self.param)
    self:InitUI()
    if not self.param.guideFun then
        self.viewCtr:OnCreate()
    end
	self:InitTextByLanguage()
    self:AddClickEvent()
end

function BackpackView:InitUI()
    self.Content = self:FindChild("Layer_UI/Content")
    self.None = self:FindChild("Layer_UI/None")

    self.item = self:FindChild("Layer_UI/Item")
    self.hall = self:FindChild("Layer_UI/Content/Hall")
    self.hallNode = self:FindChild("Layer_UI/Content/Hall/Viewport/Content")
    self.hallTog = self:FindChild("Title/Hall")
    self.game = self:FindChild("Layer_UI/Content/Game")
    self.gameNode = self:FindChild("Layer_UI/Content/Game/Viewport/Content")
    self.gameTog = self:FindChild("Title/Game")
    self.Detail = self:FindChild("Layer_UI/Detail")

    self.PropName = self:FindChild("Layer_UI/Detail/PropName")
    self.PropImage = self:FindChild("Layer_UI/Detail/PropBG/Image")
    self.PropNum = self:FindChild("Layer_UI/Detail/PropNum")
    self.PropDes = self:FindChild("Layer_UI/Detail/PropDes")
    self.PropUseBtn = self:FindChild("Layer_UI/Detail/BtnGroup/BtnUse")
    self.PropUseBtnText = self:FindChild("Layer_UI/Detail/BtnGroup/BtnUse/Text")
    self.PropSaleBtn = self:FindChild("Layer_UI/Detail/BtnGroup/BtnSale")
    self.PropUseBtnText = self:FindChild("Layer_UI/Detail/BtnGroup/BtnSale/Text")
    self.PropSentBtn = self:FindChild("Layer_UI/Detail/BtnGroup/BtnSent")

    local chipNode = self:FindChild("NodeMgr/ChipNode")
    self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode})

    if CC.ChannelMgr.GetSwitchByKey("bHasRealStore") then
        local integralNode = self:FindChild("NodeMgr/IntegralBG")
        integralNode:SetActive(true);
        self.integralCounter = CC.HeadManager.CreateIntegralCounter({parent = integralNode})
    end

    local diamondNode = self:FindChild("NodeMgr/DiamondNode")
    self.diamondCounter = CC.HeadManager.CreateDiamondCounter({parent = diamondNode});
end

function BackpackView:InitTextByLanguage()
    self:FindChild("Title/Hall/Label").text = self.language.hallTitle
    self:FindChild("Title/Game/Label").text = self.language.gameTitle
    self:FindChild("Layer_UI/Detail/BtnGroup/BtnSale/Text").text = self.language.saleBtn
    self:FindChild("Layer_UI/Detail/BtnGroup/BtnUse/Text").text = self.language.useBtn
    self:FindChild("Layer_UI/Detail/BtnGroup/BtnSent/Text").text = self.language.sendBtn
    self:FindChild("Layer_UI/None/NoneTips").text = self.language.nothing
end

function BackpackView:AddClickEvent()
    self:AddClick("Layer_UI/BtnClose","ActionOut")
    self:AddClick("Title/Hall","ClickHall")
    self:AddClick("Title/Game","ClickGame")
    self:AddClick("Layer_UI/Detail/BtnGroup/BtnUse","ClickProp")
    self:AddClick("Layer_UI/Detail/BtnGroup/BtnSale","ClickProp")
    self:AddClick("Layer_UI/Detail/BtnGroup/BtnSent","ClickSent")
end

function BackpackView:InitSelectInfo(param)
    self.curType = param.Type
    self.selectedID = param.Id
end

function BackpackView:StartGuide()
    self:DelayRun(0.01,function ()
        if self.param.guideFun and self.propMap[self.selectedID] then
            self.param.guideFun(self.propMap[self.selectedID].item,self.Detail)
        end
    end)
end

function BackpackView:RefreshToggle()
    if self.curType == Type.Hall then
        self:ClickHall()
    else
        self:ClickGame()
    end
end

function BackpackView:ClickHall()
    self.curType = Type.Hall
    self.hallTog:GetComponent("Toggle").isOn = true
    self.Detail:SetActive(false)
    if #self.hallList > 0 then
        self.Content:SetActive(true)
        self.None:SetActive(false)
        self:ItemClick(self.hallList[1].value.Id)
    else
        self.Content:SetActive(false)
        self.None:SetActive(true)
    end
    self.hall:SetActive(true)
    self.game:SetActive(false)
end

function BackpackView:ClickGame()
    self.curType = Type.Game
    self.gameTog:GetComponent("Toggle").isOn = true
    self.Detail:SetActive(false)
    if #self.gameList > 0 then
        self.Content:SetActive(true)
        self.None:SetActive(false)
        self:ItemClick(self.gameList[1].value.Id)
    else
        self.Content:SetActive(false)
        self.None:SetActive(true)
    end
    self.hall:SetActive(false)
    self.game:SetActive(true)
end

function BackpackView:ClickProp()
    if math.floor(self.curProp.Jump / 100000) > 0 then
		local param = nil
		if self.curProp.Jump == 100001 then
			--区分改名卡28和52
			param = {}
			param.consumeProp = self.curProp.Id
		end
		if self.curProp.Jump == 100003 then
			if self.playerData.Telephone == "" then
                if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("OTPVerify") then
                    CC.ViewManager.OpenAndReplace("BindTelView")
                else
                    CC.ViewManager.ShowTip(CC.LanguageManager.GetLanguage("L_PersonalInfoView").otpClose)
                end
            else
                --在子游戏不进行解绑手机
                if not CC.ViewManager.IsHallScene() then
                    return
                end
				
				CC.HallUtil.UnBindTelephone()
			end
            return
		end
        CC.ViewManager.OpenAndReplace(HALLFEATURES[self.curProp.Jump],param)
        return
    end

    local info = self.curProp.ActiveView
    if not table.isEmpty(info) then
        local switch = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey(info.SubInterface).switchOn
        if switch then
            if info.MainView then
                CC.ViewManager.OpenAndReplace(info.MainView,{currentView = info.SubInterface})
            else
                CC.ViewManager.OpenAndReplace(info.SubInterface)
            end
            return
        end
    end

    if self.curProp.Jump ~= 0 and self.curProp.ExchangeId == 0 then
        CC.ViewManager.Open("BackJumpView",self.curProp)
    else
        if self:CheckIsBattery_Chip(self.curProp.Id) then
            local lan = CC.LanguageManager.GetLanguage("L_BatteryLotteryView")
            CC.ViewManager.ShowMessageBox(lan.SkinExchangeTip,function() CC.ViewManager.Open("BackUseView",self.curProp) end):SetOneButton()
        else
            CC.ViewManager.Open("BackUseView",self.curProp)
        end
    end
end

function BackpackView:CheckIsBattery_Chip(id)
    --之后有新的炮台碎片需要弹二次确认框就往这里加碎片 id
    local battery_chip = {CC.shared_enums_pb.EPC_Common_BatteryTicket_1122,CC.shared_enums_pb.EPC_ZhuQue_Battery_Chip,CC.shared_enums_pb.EPC_WhiteTiger_Battery_Chip,
                          CC.shared_enums_pb.EPC_JadeHare_Battery_Chip,CC.shared_enums_pb.EPC_Cake_Battery,CC.shared_enums_pb.EPC_WaterGun_Battery_Chip
                         }
    for i,v in ipairs(battery_chip) do
        if id == v then return true end
    end
    return false
end

function BackpackView:ClickSent()
    if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 28 then
        CC.ViewManager.ShowTip(self.language.unableSent)
        return
    end
    CC.ViewManager.Open("PropSentView",self.curProp)
end

function BackpackView:InitBackPack(param)
    local completeNum = 0
    if #param >= 0 then
        self.co_InitProp = coroutine.start(function ()
            for i, v in ipairs(param) do
                self:CreateProp(v)
                if v.Id == self.selectedID then
                    self:ItemClick(v.Id)
                end
                completeNum = completeNum + 1
                if completeNum == #param then
                    self:RefreshToggle()
                    if self.param.guideFun then
                        self:StartGuide()
                    end
                end
                coroutine.step(0)
            end
        end)
    end
end

function BackpackView:CreateProp(param)
    local id = param.Id
    local types = param.Page
    local count = param.count
    local tempList = nil
    local item = nil
    if types == Type.Hall then
        item = CC.uu.newObject(self.item, self.hallNode)
        tempList = self.hallList
    else
        item = CC.uu.newObject(self.item, self.gameNode)
        tempList = self.gameList
    end
    item.name = id
    local spriteNode = item:FindChild("Prop")
    local countText = item:FindChild("Prop/Count")
    local sprite = self.PropDataMgr.GetIcon(id)
    self:SetImage(spriteNode,sprite)
    -- spriteNode:GetComponent("Image"):SetNativeSize()
    countText.text = count
    local prop = {}
    prop.item = item
    prop.count = countText
    prop.value = param
    table.insert(tempList,prop)
    self.propMap[id] = prop
    local itemDesNode = item:FindChild("ItemDesNode");
    local btnData = {};
    btnData.funcLongClick = function()
        local data = {};
        data.node = itemDesNode;
        data.value = param;
        self:ShowRewardItemTip(true,data);
    end
    btnData.funcUp = function()
        self:ShowRewardItemTip(false);
    end
    btnData.funcClick = function()
        self:ItemClick(id);
    end
    btnData.time = 0.2;
    self:AddLongClick(item, btnData);
    return prop
end

function BackpackView:RefrshBackPack(param)
    for i, v in ipairs(param) do
        local id = v.Id
        local count = v.count
        if self.propMap[id] then
            self:RefreshNum(id)
        elseif count and count > 0 then
            self:AddProp(v)
        end
    end
    self:RefreshToggle()
end

function BackpackView:RefreshNum(id)
    local propData = self.propMap[id]
    local propCount = CC.Player.Inst():GetSelfInfoByKey(id)
    if propCount > 0 then
        propData.count.text = propCount
        propData.value.count = propCount
    else
        self:DestroyItem(propData)
    end
end

function BackpackView:DestroyItem(param)
    local types = param.value.Page
    local id = param.value.Id
    local item = param.item
    GameObject.Destroy(item.gameObject)
    if types == Type.Game then
        self:RemoveList(self.gameList,id)
    else
        self:RemoveList(self.hallList,id)
    end
    self.propMap[id] = nil
end

function BackpackView:RemoveList(list,id)
    local index = nil
    for i, v in ipairs(list) do
        local value = v.value
        if value.Id == id then
            index = i
            break
        end
    end
    table.remove(list,index)
end

function BackpackView:AddProp(param)
    local prop = self:CreateProp(param)
    local item = prop.item
    item.transform:SetSiblingIndex(self:SearchPropIndex(prop))
end

function BackpackView:SearchPropIndex(param)
    local index = 0
    local value = param.value
    local types = value.Page
    local _id = value.Id

    local _sort = param.Type
    if types == Type.Game then
        index = #self.gameList
        for i, v in ipairs(self.gameList) do
            local id = v.value.Id
            local sort = v.value.Type
            if _sort < sort then
                index = i
            elseif _sort == sort and _id < id then
                index = i
            end
        end
        table.insert(self.gameList,index,param)
    else
        index = #self.hallList
        for i, v in ipairs(self.hallList) do
            local id = v.value.Id
            local sort = v.value.Type
            if _sort < sort then
                index = i
            elseif _sort == sort and _id < id then
                index = i
            end
        end
        table.insert(self.hallList,index,param)
    end
    return index - 1
end

function BackpackView:ShowRewardItemTip(isShow, param)
    if isShow then
        if #param.value.Tips <= 0 then return end
		if not self.rewardItemTip then
			self.rewardItemTip = CC.ViewCenter.PackbackItemDes.new();
			self.rewardItemTip:Create({parent = param.node});
        end
		local data = {
			parent = param.node,
			value = param.value,
		}
        self.rewardItemTip:Show(data);
	else
		if not self.rewardItemTip then return end;
		self.rewardItemTip:Hide();
	end
end

function BackpackView:ItemClick(id)
    if self.propMap[id] then
        self.Detail:SetActive(true)
        local value = self.propMap[id].value
        for k, v in pairs(self.propMap) do
            if v.value.Id == id then
                v.item:FindChild("Click"):SetActive(true)
            else
                v.item:FindChild("Click"):SetActive(false)
            end
        end
        self:RefreshDetailInfo(value)
    end
end

function BackpackView:RefreshDetailInfo(value)
    self.curProp = value
    local id = value.Id
    local count = value.count
    local sprite = self.PropDataMgr.GetIcon(id)
    local btnState = self:GetBtnState(value)

    self.PropName.text = self.propLanguage[id] or ""
    self.PropNum.text = self.language.numLable..count
    self.PropDes.text = self.propLanguage["des"..id] or ""
    self:SetImage(self.PropImage,sprite)
    -- self.PropImage:GetComponent("Image"):SetNativeSize()
    if btnState == BtnType.Use then
        self.PropUseBtn:SetActive(true)
        self.PropSaleBtn:SetActive(false)
    elseif btnState == BtnType.Sale then

        self.PropUseBtn:SetActive(false)
        self.PropSaleBtn:SetActive(true)
    else
        self.PropUseBtn:SetActive(false)
        self.PropSaleBtn:SetActive(false)
    end
    self.PropSentBtn:SetActive(value.isCanSend)
end

function BackpackView:GetBtnState(value)
    if not table.isEmpty(value.ActiveView) then
        local switch = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey(value.ActiveView.SubInterface).switchOn
        if switch then
            return BtnType.Use
        end
        return BtnType.Sale
    end
    local Jump = value.Jump
    local Exchange = value.Exchange
    if Jump ~= 0 then
        return BtnType.Use
    elseif not table.isEmpty(Exchange) then
        return BtnType.Sale
    else
        return BtnType.None
    end
end

function BackpackView:OnDestroy()
    if self.chipCounter then
		self.chipCounter:Destroy()
		self.chipCounter = nil
	end
	if self.integralCounter then
		self.integralCounter:Destroy()
		self.integralCounter = nil
	end
	if self.diamondCounter then
		self.diamondCounter:Destroy()
		self.diamondCounter = nil
	end
    if self.co_InitProp then
        coroutine.stop(self.co_InitProp)
        self.co_InitProp = nil
    end
    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
    if self.rewardItemTip then
		self.rewardItemTip:Destroy();
		self.rewardItemTip = nil;
    end
    if self.callback then
        self.callback()
    end
end

return BackpackView