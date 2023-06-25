local CC = require("CC")

local M = CC.uu.ClassView("GameExitTipView")

--[[
gameList = {id,id}    
cancelFunc
exitFunc
gameFunc(gameId, defaultFunc)
]]
function M:ctor(param)
    self.param = param
    self.gameStatus = {}
    self.gameItemArray = {}
end

function M:GlobalNode()
    if self.param.parent then
        return self.param.parent
    else
        return self.super.GlobalNode(self)
    end
end

function M:OnCreate()
    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    self.language = self:GetLanguage()
    self:InitUI()
    self:RegisterEvent()
end

function M:OnDestroy()
    self:UnRegisterEvent()
end

function M:InitUI()
    self:InitTextByLanguage()
    self:InitGameList()
	self:AddClickEvent()
end

function M:InitTextByLanguage()
    local farme = self:FindChild("Frame")
    farme:FindChild("Tittle/Text"):SetText(self.language.Title)
	farme:FindChild("BtnExit/Text"):SetText(self.language.ExitText)
    farme:FindChild("BtnContinues/Text"):SetText(self.language.ContinuesText)
    farme:FindChild("Text"):SetText(self.language.ChangeGame)
end

function M:InitGameList()
    local unitItem = self:FindChild("Frame/ItemList/unitItem")
    for _,gameId in ipairs(self.param.gameList) do
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

            icon:FindChild("hot"):SetActive(data.Tag == 1)
            icon:FindChild("new"):SetActive(data.Tag == 2)
            icon:FindChild("vip"):SetActive(data.Tag == 3)
            icon:FindChild("match"):SetActive(data.Tag == 4)

            self:AddClick(item, function() self:OnClickGameItem(gameId) end)

            self.gameItemArray[gameId] = item
        end
    end
end

function M:AddClickEvent()
    self:AddClick("Frame/BtnExit", function() 
        self:ActionOut()
        CC.uu.SafeDoFunc(self.param.exitFunc)
    end)
    self:AddClick("Frame/BtnContinues", function() 
        self:ActionOut() 
        CC.uu.SafeDoFunc(self.param.cancelFunc)
    end)
    self:AddClick("Mask", function() self:ActionOut() end)
end

function M:OnClickGameItem(gameId)
    if CC.LocalGameData.GetGameVersion(gameId) == 0 then
        -- 未下载
        if self.gameStatus[gameId] then
            CC.ViewManager.ShowTip(self.language.TipDownloading)
        else
            self.gameStatus[gameId] = true
            CC.HallUtil.EnterGame(gameId, nil, function()
                self.gameStatus[gameId] = nil
            end)
        end
    else
        local func = function()
            CC.ResDownloadManager.CheckGame(gameId,function ()
                local defaultFunc = function() 
                    local IsHallGroup = self.gameDataMgr.GetIsHallGroupByID(gameId)
                    if IsHallGroup == 1 then
                        CC.ViewManager.SetNeedToGoGameId(gameId)
                    else
                        if CC.HallTool.CheckEnterLimit(gameId) then
                            CC.ViewManager.SubGameToGame(gameId,function(enterFunc,gameData) enterFunc(gameData) end)
                        else
                            local vipLimit = self.gameDataMgr.GetVipUnlockByID(gameId)
                            local info = self.HallDefine.UnlockCondition[gameId]
                            if info then
                                local view = info.View
                                local lock = info.Lock
                                if not lock or CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("EPC_LockLevel") then
                                    CC.ViewManager.Open(view)
                                else
                                    self:Unlock(vipLimit)
                                end
                            else
                                self:Unlock(vipLimit)
                            end
                        end
                    end
                    
                end
                self:ActionOut()
                CC.uu.SafeDoFunc(self.param.gameFunc, gameId, defaultFunc)
            end)
        end
        CC.HallUtil.CheckGroupConfig(gameId, func)
    end
end
function M:DownloadProcess(data)
	local id = data.gameID
    local process = data.process
    if self.gameItemArray[id] == nil then return end

	local obj = self.gameItemArray[id]
	if process < 1 then
		if process == 0 then
			obj:FindChild("icon"):SetActive(false)
			-- obj:FindChild("undownload"):SetActive(false)
			obj:FindChild("state"):SetActive(true)
			obj:FindChild("state/slider"):SetActive(true)
			obj:FindChild("state/slider/Text").text = self.language.download_tip
			obj:FindChild("state/slider/Slider"):GetComponent("Slider").value = process
		else
			obj:FindChild("icon"):SetActive(false)
			-- obj:FindChild("undownload"):SetActive(false)
			obj:FindChild("state"):SetActive(true)
			obj:FindChild("state/slider"):SetActive(true)
			obj:FindChild("state/slider/Text").text = string.format("%.1f",process * 100) .. "%"
			obj:FindChild("state/slider/Slider"):GetComponent("Slider").value = process
		end
	else
		obj:FindChild("icon"):SetActive(true)
		-- obj:FindChild("undownload"):SetActive(false)
		obj:FindChild("state"):SetActive(false)
	end
end

function M:DownloadFail(gameId)
    if self.gameItemArray[gameId] == nil then 
        return 
    end
    
	self.gameStatus[gameId] = nil
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.DownloadProcess,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():register(self,self.DownloadFail,CC.Notifications.DownloadFail)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadFail)
end

function M:Unlock(lv)
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

return M