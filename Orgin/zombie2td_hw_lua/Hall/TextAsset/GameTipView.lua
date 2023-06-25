local CC = require("CC")
local GameTipView = CC.uu.ClassView("GameTipView")

function GameTipView:ctor(param)
    self.param = param or {}
    self.gameItemArray = {}
end

function GameTipView:OnCreate()
    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    self.language = self:GetLanguage()
    self:InitUI()
    self:RegisterEvent()
end

function GameTipView:OnDestroy()
    self:UnRegisterEvent()
end

function GameTipView:InitUI()
    self:InitTextByLanguage()
    self.gameIndo = CC.LocalGameData.GetRecentGame() or {}
    self:InitGameList()
	self:AddClickEvent()
end

function GameTipView:InitTextByLanguage()
    local farme = self:FindChild("Frame")
    local index = self.param.tipType or 1
    farme:FindChild("Tittle/Text"):SetText(self.language.Title)
	farme:FindChild("BtnCancel/Text"):SetText(self.language.CancelText)
    if index ~= 3 then
        farme:FindChild("BtnContinues/Text"):SetText(self.language.ContinuesText)
    else
        farme:FindChild("BtnContinues/Text"):SetText(self.language.ContinuesLook)
    end
    farme:FindChild("Text"):SetText(self.language.ContentText[index])
end

function GameTipView:InitGameList()
    local unitItem = self:FindChild("Frame/ItemList/unitItem")
    if table.isEmpty(self.gameIndo) then
        self.gameIndo = {3002}
    end
    for _,gameId in ipairs(self.gameIndo) do
        local data = self.gameDataMgr.GetInfoByID(gameId)
        if data then
            local item = CC.uu.UguiAddChild(unitItem.parent, unitItem, tostring(gameId))
            local preName = string.format("yxrk_%d",gameId)
            local sprite = self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].path or "img_yxrk_1002"
            local icon = item:FindChild("icon")
            local state = item:FindChild("state")
            self:SetImage(icon, sprite)
            self:SetImage(state:FindChild("icon"), sprite)
            self:SetImage(state:FindChild("mask"), sprite)

            self:AddClick(item, function() self:OnClickGameItem(gameId) end)
            self.gameItemArray[gameId] = item
        end
    end
end

function GameTipView:AddClickEvent()
    self:AddClick("Frame/BtnCancel", function()
        self:ActionOut()
        if self.param.cancelFunc then
            CC.uu.SafeDoFunc(self.param.cancelFunc)
        end
    end)
    self:AddClick("Frame/BtnContinues", function()
        local index = self.param.tipType or 1
        if index ~= 3 then
            if self.gameIndo[1] then
                self:OnClickGameItem(self.gameIndo[1])
            end
        end
        self:ActionOut()
        if self.param.okFunc then
            CC.uu.SafeDoFunc(self.param.okFunc)
        end
    end)
    self:AddClick("Mask", function() self:ActionOut() end)
end

function GameTipView:OnClickGameItem(gameId)
    CC.HallUtil.CheckAndEnter(gameId)
end

function GameTipView:DownloadProcess(data)
	local id = data.gameID
    local process = data.process
    if self.gameItemArray[id] == nil then return end

	local obj = self.gameItemArray[id]
	if process < 1 then
		if process == 0 then
			obj:FindChild("icon"):SetActive(false)
			obj:FindChild("state"):SetActive(true)
			obj:FindChild("state/slider"):SetActive(true)
			obj:FindChild("state/slider/Text").text = self.language.download_tip
			obj:FindChild("state/slider/Slider"):GetComponent("Slider").value = process
		else
			obj:FindChild("icon"):SetActive(false)
			obj:FindChild("state"):SetActive(true)
			obj:FindChild("state/slider"):SetActive(true)
			obj:FindChild("state/slider/Text").text = string.format("%.1f",process * 100) .. "%"
			obj:FindChild("state/slider/Slider"):GetComponent("Slider").value = process
		end
	else
		obj:FindChild("icon"):SetActive(true)
		obj:FindChild("state"):SetActive(false)
	end
end

function GameTipView:DownloadFail(gameId)
    if self.gameItemArray[gameId] == nil then
        return
    end
	local obj = self.gameItemArray[gameId]
	obj:FindChild("icon"):SetActive(true)
	obj:FindChild("undownload"):SetActive(true)
	obj:FindChild("state"):SetActive(false)
end

function GameTipView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.DownloadProcess,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():register(self,self.DownloadFail,CC.Notifications.DownloadFail)
end

function GameTipView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadFail)
end

function GameTipView:Unlock(lv)
	local language = CC.LanguageManager.GetLanguage("L_Tip")
	CC.ViewManager.ShowMessageBox(string.format(language.enterGame_tip,lv),
	function ()
		if lv > 1 and lv <= 3 then
			CC.SubGameInterface.OpenVipBestGiftView({needLevel = lv})
		elseif CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
			CC.ViewManager.OpenEx("SelectGiftCollectionView")
		else
			CC.ViewManager.Open("StoreView")
		end
	end,
	function ()
		--取消不作任何处理
	end)
end

return GameTipView