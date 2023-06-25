local CC = require("CC")

local UnLockVipView = CC.uu.ClassView("UnLockVipView")

function UnLockVipView:ctor(param)
	self.param = param;
    self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
    --界面类型
    self.viewType = {gameType = 1, capacityType = 2}
    --游戏类型
    self.toggleType = {CatchType = 1, BetType = 2, ChessType = 3, SlotsType = 4}
    self.gameIconList = {}
    self.capacityIconList = {}
    self.ToggleList = {}
    self.gameItemList = {}
    self.capacityItemList = {}
    --奖励描述窗口
	self.iconItemTip = nil;
end

function UnLockVipView:OnCreate()
    self.playerData = CC.Player.Inst():GetSelfInfo();
    self.vipUnlock = CC.ConfigCenter.Inst():getConfigDataByKey("VIPUnlock")
    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
	self:InitContent();
    self:RegisterEvent();
end

function UnLockVipView:InitContent()
    --游戏解锁
    self.ToggleItem = self:FindChild("BottomPanel/Game/ToggleItem")
    self.ToggleGroud = self:FindChild("BottomPanel/Game/ToggleGroud")
    self.GameItem = self:FindChild("TopPanel/GameItem")
    self.GameInfoItem = self:FindChild("BottomPanel/Game/ModeList/Scroll/Viewport/Item")
    self.GameInfoContent = self:FindChild("BottomPanel/Game/ModeList/Scroll/Viewport/Content")
    --功能解锁
    self.CapacityItem = self:FindChild("TopPanel/CapacityItem")
    self.CapacityInfoItem = self:FindChild("BottomPanel/Capacity/Scroll/Viewport/Item")
    self.CapacityInfoContent = self:FindChild("BottomPanel/Capacity/Scroll/Viewport/Content")

    self.ListGroup = self:FindChild("TopPanel/ListGroup")
    self.title = self:FindChild("Title/Text")

	self:AddClick("BtnClose", "ActionOut");
    self:AddClick("TopPanel/HideTipDes", function()
        self:ShowIconItemTip(false)
    end)
    self:InitViewUI()
end

function UnLockVipView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.DownloadProcess,CC.Notifications.DownloadGame)
    CC.HallNotificationCenter.inst():register(self,self.DownloadFail,CC.Notifications.DownloadFail)
end

function UnLockVipView:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadGame)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadFail)
end

--界面
function UnLockVipView:InitViewUI()
    self.GameInfoItem:FindChild("Btn/Text").text = self.language.GoTo
    self:FindChild("BottomPanel/Game/ModeList/GameText").text = self.language.UnlockGame
    self:FindChild("BottomPanel/Game/ModeList/FieldText").text = self.language.UnlockRoom
    local showLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    if self.param.showLevel then
        showLevel = self.param.showLevel
    end
    local data = self:GetUnlockInfo(showLevel)
    if not data then return end
    if self.param.viewType == self.viewType.gameType then
        self.title.text = self.language.GameTitle
        self:FindChild("TopPanel/Title/Text").text = self.language.GameTitle
        self:FindChild("BottomPanel/Title/Text").text = self.language.GameMore
        self:SetGameInfo(data)
        self:FindChild("BottomPanel/Game"):SetActive(true)
        self:FindChild("BottomPanel/Capacity"):SetActive(false)
    elseif self.param.viewType == self.viewType.capacityType then
        self.title.text = self.language.CapacityTitle
        self:FindChild("TopPanel/Title/Text").text = self.language.CapacityTitle
        self:FindChild("BottomPanel/Title/Text").text = self.language.CapacityMore
        self:SetCapacityInfo(data)
        self:FindChild("BottomPanel/Game"):SetActive(false)
        self:FindChild("BottomPanel/Capacity"):SetActive(true)
    end
end

function UnLockVipView:GetUnlockInfo(level)
	local viplevel = tonumber(level);
	if self.vipUnlock[viplevel + 1] then
		return self.vipUnlock[viplevel + 1]
	end
	return false
end

function UnLockVipView:SetGameInfo(data)
    if data.GameUnlock then
        for i = 1, #data.GameUnlock do
            local item = nil
            local gameId = data.GameUnlock[i].GameIcon
            if not gameId then break end
            if self.gameIconList[gameId] == nil then
                item = CC.uu.newObject(self.GameItem)
                self.gameIconList[gameId] = item.transform
            else
                item = self.gameIconList[gameId]
            end
            if item then
                item:SetActive(true)
                item.transform:SetParent(self.ListGroup, false)
                local preName =  "yxrk_".. gameId
                local sprite = self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].path or "img_yxrk_1002"
                self:SetImage(item:FindChild("icon"), sprite);
                self:SetImage(item:FindChild("state/icon"), sprite);
                self:SetImage(item:FindChild("state/mask"), sprite);
                item:FindChild("undownload"):SetActive(CC.LocalGameData.GetGameVersion(gameId) == 0)
                self:AddClick(item, function()
                    CC.HallUtil.CheckAndEnter(gameId, nil, function()
                        CC.ViewManager.CloseAllOpenView()
                    end)
                end)
            end
        end
    end
    if data.CatchType and next(data.CatchType) then
        self:CreateBtnItem(data.CatchType, self.toggleType.CatchType)
    end
    if data.BetType and next(data.BetType) then
        self:CreateBtnItem(data.BetType, self.toggleType.BetType)
    end
    if data.ChessType and next(data.ChessType) then
        self:CreateBtnItem(data.ChessType, self.toggleType.ChessType)
    end
    if data.SlotsType and next(data.SlotsType) then
        self:CreateBtnItem(data.SlotsType, self.toggleType.SlotsType)
    end
    if self.ToggleList[1] then
        self.ToggleList[1]:GetComponent("Toggle").isOn = true
    end
end

function UnLockVipView:CreateBtnItem(info, toggleType)
    local toggle = nil
    toggle = CC.uu.newObject(self.ToggleItem)
    UIEvent.AddToggleValueChange(toggle, function(selected)
        if selected then
            self:RefreshGameItemInfo(info)
        end
    end)
    toggle.transform:SetParent(self.ToggleGroud, false)
    toggle:SetActive(true)
    if toggleType == self.toggleType.CatchType then
        toggle:FindChild("Text").text = self.language.CatchType
        toggle:FindChild("Select/Text").text = self.language.CatchType
    elseif toggleType == self.toggleType.BetType then
        toggle:FindChild("Text").text = self.language.BetType
        toggle:FindChild("Select/Text").text = self.language.BetType
    elseif toggleType == self.toggleType.ChessType then
        toggle:FindChild("Text").text = self.language.ChessType
        toggle:FindChild("Select/Text").text = self.language.ChessType
    elseif toggleType == self.toggleType.SlotsType then
        toggle:FindChild("Text").text = self.language.SlotsType
        toggle:FindChild("Select/Text").text = self.language.SlotsType
    end
    table.insert(self.ToggleList, toggle)
end

function UnLockVipView:RefreshGameItemInfo(data)
    for _,v in pairs(self.gameItemList) do
		v.transform:SetActive(false)
	end
    for i = 1, #data do
        local item = nil
        if self.gameItemList[i] == nil then
            item = CC.uu.newObject(self.GameInfoItem)
            self.gameItemList[i] = item.transform
        else
            item = self.gameItemList[i]
        end
        if item then
            item:SetActive(true)
            item.transform:SetParent(self.GameInfoContent, false)
            item:FindChild("GameName").text = self.language.GameIdName[data[i].GameId]
            item:FindChild("FieldName").text = self.language.FieldName[data[i].Field]
            self:AddClick(item:FindChild("Btn"), function()
                CC.HallUtil.CheckAndEnter(data[i].GameId, nil, function()
                    CC.ViewManager.CloseAllOpenView()
                end)
            end)
        end
    end
end

function UnLockVipView:DownloadProcess(data)
	local id = data.gameID
	local process = data.process
	if self.gameIconList[id] == nil then return end
	local obj = self.gameIconList[id]
	if process < 1 then
		if process == 0 then
			obj:FindChild("icon"):SetActive(false)
			obj:FindChild("undownload"):SetActive(false)
			obj:FindChild("state"):SetActive(true)
			obj:FindChild("state/slider"):SetActive(true)
			obj:FindChild("state/slider/Text").text = self.language.download_tip
			obj:FindChild("state/slider/Slider"):GetComponent("Slider").value = process
		else
			obj:FindChild("icon"):SetActive(false)
			obj:FindChild("undownload"):SetActive(false)
			obj:FindChild("state"):SetActive(true)
			obj:FindChild("state/slider"):SetActive(true)
			obj:FindChild("state/slider/Text").text = string.format("%.1f",process * 100) .. "%"
			obj:FindChild("state/slider/Slider"):GetComponent("Slider").value = process
		end
	else
		obj:FindChild("icon"):SetActive(true)
		obj:FindChild("undownload"):SetActive(false)
		obj:FindChild("state"):SetActive(false)
		--self.gameIconList[id].isClick = false
	end
end

function UnLockVipView:DownloadFail(id)
	if self.gameIconList[id] == nil then return end
	local obj = self.gameIconList[id]
	obj:FindChild("icon"):SetActive(true)
	obj:FindChild("undownload"):SetActive(true)
	obj:FindChild("state"):SetActive(false)
	--self.gameIconList[id].isClick = false
end

function UnLockVipView:SetCapacityInfo(data)
    if data.CapacityUnlock then
        for i = 1, #data.CapacityUnlock do
            local item = nil
            if self.capacityIconList[i] == nil then
                item = CC.uu.newObject(self.CapacityItem)
                self.capacityIconList[i] = item.transform
            else
                item = self.capacityIconList[i]
            end
            if item then
                item:SetActive(true)
                item.transform:SetParent(self.ListGroup, false)
                local info = data.CapacityUnlock[i]
                local iconId = info.Icon
                local sprite = self.HallDefine.VIPNewRights[iconId].Icon
                self:SetImage(item:FindChild("icon"), sprite);
                item.transform:FindChild("new"):SetActive(info.New)
                item.transform:FindChild("max"):SetActive(info.Max)
                item.transform:FindChild("up"):SetActive(info.Up)
                if self.HallDefine.VIPNewRights[iconId].openTip then
                    self:AddClick(item, function()
                        local param = {}
                        param.node = item:FindChild("node")
                        param.icon = sprite
                        local num1 = info.Des1 > 0 and info.Des1 or ""
                        local num2 = info.Des2 > 0 and info.Des2 or ""
                        param.propName = self.language.rightsIcon[iconId].name
                        param.propDes = string.format(self.language.rightsIcon[iconId].tip, num1, num2)
                        param.propId = 2
                        self:ShowIconItemTip(true, param)
                    end)
                end
            end
        end
    end
    if data.TurntableCount and next(data.TurntableCount) then
        self:CreateCapacityItem(data.TurntableCount, 1)
    end
    if data.TurntableLayer and next(data.TurntableLayer) then
        self:CreateCapacityItem(data.TurntableLayer, 2)
    end
    if data.TurntablePayCount and next(data.TurntablePayCount) then
        self:CreateCapacityItem(data.TurntablePayCount, 3)
    end
    if data.LoginReward and next(data.LoginReward) then
        self:CreateCapacityItem(data.LoginReward, 4)
    end
    if data.WeekendReward and next(data.WeekendReward) then
        self:CreateCapacityItem(data.WeekendReward, 5)
    end
end

function UnLockVipView:CreateCapacityItem(data, index)
    local item = nil
    item = CC.uu.newObject(self.CapacityInfoItem)
    if item then
        item:SetActive(true)
        item.transform:SetParent(self.CapacityInfoContent, false)
        item:FindChild("Text").text = string.format(self.language.CapacityInfo[index], data.Count)
        item.transform:FindChild("New"):SetActive(data.New)
        item.transform:FindChild("Max"):SetActive(data.Max)
        item.transform:FindChild("Up"):SetActive(data.Up)
    end
end

function UnLockVipView:ShowIconItemTip(isShow, param)
    --提示框
    if isShow then
        if not self.iconItemTip then
            self.iconItemTip = CC.ViewCenter.CommonItemDes.new();
            self.iconItemTip:Create({parent = param.node});
        end
        param.parent = param.node
        self.iconItemTip:Show(param);
    else
        if not self.iconItemTip then return end;
        self.iconItemTip:Hide();
    end
end

function UnLockVipView:OnDestroy()
    self:UnRegisterEvent();
    if self.iconItemTip then
		self.iconItemTip:Destroy();
		self.iconItemTip = nil;
	end
end

return UnLockVipView;