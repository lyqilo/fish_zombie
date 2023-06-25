local CC = require("CC")
local MiniGameDefine = require("Model/MiniGame/MiniGameDefine")
local ViewUIBase = require("Common/ViewUIBase")
local baseClass = CC.class2("MiniGameIcon", ViewUIBase)

local iconWidth = 118
local iconHeight = 86

function baseClass:ctor()
	-- self.transform = CC.uu.LoadHallPrefab("prefab", "MiniGameIcon", parent);
	self.bundleName = "prefab"
	self.viewName = "MiniGameIcon"
	self.language = CC.LanguageManager.GetLanguage("L_MiniGameMainView");
	self.btnList = {}
	self.viewList = {}
	self.miniGameOrderlayer = 100

	self.openBtnList = false
	self.ctr = CC.MiniGameMgr.GetMiniCtr()
end

function baseClass:OnCreate(...)
	self:InitContent()
	self:RegisterEvent()

	self:UpdateShow(self.ctr:GetStatus())

	self.screenWidth = self.transform.parent.rect.width
	self.screenHeight = self.transform.parent.rect.height

	self:AddDragEvent()
end

function baseClass:InitContent()
	self.statusList = {}

	self.content = self:FindChild("Content")
	for _, v in ipairs(MiniGameDefine) do
		local rootPath = "status/" .. v.nodeName
		local tr = self:FindChild(rootPath)
		if tr then
			local item = {
				tr = tr,
				cd = self:FindChild(rootPath .. "/countdown"),
				cdTxt = self:FindChild(rootPath .. "/countdown/Text"),
				resultRoot = self:FindChild(rootPath .. "/result"),
				result = {
					self:FindChild(rootPath .. "/result/1"),
					self:FindChild(rootPath .. "/result/2"),
					self:FindChild(rootPath .. "/result/3")
				}
			}
			self:AddClick(tr, function()
				self:OnBtnClick()
			end)
			self.statusList[v.id] = item
		end
		local btnItem = self:GetMiniGameBtn(v)
		table.insert(self.btnList, btnItem)
	end

	self.animator = self:FindChild("BtnList"):GetComponent("Animator")
	self:AddClick(self:FindChild("icon"), function()
		self:OnBtnClick()
	end)
end

function baseClass:AddDragEvent()
	self.transform.onMove = function(obj, eventData)
		self:moveLimit(obj)
	end

	self.transform.onEndDrag = function()
		local pos = self.transform.localPosition
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnSetMiniIconPos, pos)
	end
end

function baseClass:moveLimit(obj)
	local moveX = math.abs(obj.localPosition.x)
	local moveY = math.abs(obj.localPosition.y)

	local limitX = (self.screenWidth / 2 - iconWidth / 2)
	local limitY = (self.screenHeight / 2 - iconHeight / 2)

	if moveX > limitX then
		local x = 0
		if obj.localPosition.x > 0 then
			x = limitX
		else
			x = 0 - limitX
		end
		obj.localPosition = Vector3(x, obj.localPosition.y, 0)
	end

	if moveY > limitY then
		local y = 0
		if obj.localPosition.y > 0 then
			y = limitY
		else
			y = 0 - limitY
		end
		obj.localPosition = Vector3(obj.localPosition.x, y, 0)
	end
end

function baseClass:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnMiniStatusUpdate, CC.Notifications.OnMiniStatusUpdate)
	CC.HallNotificationCenter.inst():register(self, self.OnMiniGameClose, CC.Notifications.OnMiniGameClose)
	CC.HallNotificationCenter.inst():register(self, self.OnSetMiniGameBet, CC.Notifications.OnSetMiniGameBet)
	CC.HallNotificationCenter.inst():register(self, self.OnSetMiniGameResult, CC.Notifications.OnSetMiniGameResult)
	CC.HallNotificationCenter.inst():register(self, self.OnSetMiniCurGame, CC.Notifications.OnSetMiniCurGame)
end

function baseClass:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnMiniStatusUpdate)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnMiniGameClose)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetMiniGameBet)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetMiniGameResult)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetMiniCurGame)
end

function baseClass:OnMiniStatusUpdate(data)
	self:UpdateShow(data)
end

function baseClass:OnBtnClick()
	-- self.mainView = CC.ViewManager.Open("MiniGameMainView")
	self.openBtnList = not self.openBtnList
	if self.openBtnList then
		self.animator:Play("Effect_UI_MINI02")
		self:FindChild("status"):SetActive(not self.openBtnList)
	else
		self.animator:Play("Effect_UI_MINI03")
		self:DelayRun(0.5, function()
			self:FindChild("status"):SetActive(not self.openBtnList)
		end)
	end
end

function baseClass:UpdateShow(data)
	for id, item in pairs(self.statusList or {}) do
		local d = data[id]
		if d then
			local state = d.state
			local countdown = d.countdown
			local result = d.result and type(d.result) == "table" and d.result.location

			if state == 1 then
				-- self:StartCountdownTimer(id, item, countdown)
				item.cd:SetActive(true)
				item.resultRoot:SetActive(false)
			else
				item.cd:SetActive(false)
				item.resultRoot:SetActive(true)
				for i, v in ipairs(item.result) do
					v:SetActive(result == i)
				end
			end
			self:StartCountdownTimer(id, item, countdown)
			item.tr:SetActive(true)
		end
	end

	for _, item in pairs(self.btnList) do
		local d = data[item.id]
		if d then
			local result = d.result and type(d.result) == "table" and d.result.location
			if d.state == 1 then
				for _, v in ipairs(item.result) do
					v:SetActive(false)
				end
			else
				for i, v in ipairs(item.result) do
					v:SetActive(result == i)
				end
			end
		end
	end
end

function baseClass:StartCountdownTimer(key, item, countdown)
	if countdown < 0 then return end
	local cd = countdown
	item.cdTxt.text = cd
	self:StopTimer(key)
	self:StartTimer(key, 1, function()
		cd = cd - 1
		if cd < 0 then
			self.ctr:ReqLoadMiniStatus()
			self:StopTimer(key)
			item.cd:SetActive(false)
			return
		end
		item.cdTxt.text = tostring(cd)
	end, -1)
end

function baseClass:GetMiniGameBtn(v)
	local btnItem = {}
	btnItem.id = v.id
	local item = self:FindChild("BtnList/zhuanpan/" .. v.nodeName)
	item:FindChild("Background/gameName").text = self.language[v.key]
	item:SetActive(true)
	btnItem.item = item
	btnItem.bg = item:FindChild("Background")
	btnItem.effect = item:FindChild("Effcet_XiaoTingTuBiao")
	btnItem.effect:SetActive(false)
	self:SetImage(btnItem.bg, v.cdIcon)
	btnItem.icon = v.icon
	btnItem.cdIcon = v.cdIcon
	btnItem.gameText = item:FindChild("Background/gameText")
	btnItem.gameText.text = ""
	btnItem.winEff = item:FindChild("Background/win")
	item:FindChild("Background/win/Text").text = self.language.win
	btnItem.gameEff = item:FindChild("Background/ready")
	btnItem.gameEffText = item:FindChild("Background/ready/Text")
	btnItem.cd = item:SubGet("Background/cd", "Image")
	btnItem.cd:SetActive(true)
	btnItem.cd.fillAmount = 0
	btnItem.result = {
		item:FindChild("Background/result/1"),
		item:FindChild("Background/result/2"),
		item:FindChild("Background/result/3")
	}
	self:AddClick(btnItem.bg, function()
		self:OnBtnClick()
		if self.viewList[v.id] then
			self.currentView = self.viewList[v.id]
			CC.MiniGameMgr.SetCurMiniGameId(v.id)
		else
			if v.view and v.view ~= "" then
				self.ctr:OpenMiniGame(v.id, function(ip)
					-- "172.13.0.119:30001"
					log(ip)
					-- self.currentView = CC.uu.CreateHallView(v.view,{serverIp=ip})
					local viewClass = require(v.viewPath)
					self.currentView = viewClass.new({serverIp = ip})
					self.currentView:Create()
					--self.currentView.transform:SetParent(self.content, false)
					self.currentView.transform.localScale = Vector3(0.9, 0.9, 0.9)
					self.viewList[v.id] = self.currentView
					--界面创建后设置
					CC.MiniGameMgr.SetCurMiniGameId(v.id)
				end)
			end
		end

		self:SetImage(btnItem.bg, v.icon)
		btnItem.cd:SetActive(false)
		btnItem.effect:SetActive(true)
	end)
	return btnItem
end


function baseClass:OnSetMiniGameBet(gameId, nValue)
	for _, item in ipairs(self.btnList) do
		if item.id == gameId and nValue and nValue >= 0 then
			if nValue > 0 then
				item.gameText.text = "bet:" .. CC.uu.ChipFormat(nValue)
			else
				item.gameText.text = ""
			end
			return
		end
	end
end

function baseClass:OnSetMiniGameResult(gameId, nValue)
	for _, item in ipairs(self.btnList) do
		if item.id == gameId and nValue then
			if nValue > 0 then
				item.gameText.text = "win:" .. CC.uu.ChipFormat(nValue)
				item.winEff:SetActive(true)
				self:DelayRun(2, function()
					item.winEff:SetActive(false)
				end)
			else
				item.gameText.text = ""
				item.gameEff:SetActive(true)
				item.gameEffText.text = self.language.ready
				self:DelayRun(2, function()
					item.gameEff:SetActive(false)
				end)
			end
			return
		end
	end
end

function baseClass:OnMiniGameClose(gameId)
	for _, item in ipairs(self.btnList) do
		if item.id == gameId then
			self:SetImage(item.bg, item.cdIcon)
			item.cd:SetActive(true)
			item.effect:SetActive(false)
			if self.viewList[gameId] then
				if not CC.uu.IsNil(self.viewList[gameId].transform) then
					local node = self.viewList[gameId].transform
						self:RunAction(node,{{"scaleToEx", 0, 0, 0, 0.15, ease = CC.Action.EInSine, function()
							self.viewList[gameId]:Destroy()
							self.viewList[gameId] = nil
							if CC.MiniGameMgr.GetCurMiniGameId() == gameId then
								--当前选择游戏关闭
								CC.MiniGameMgr.SetCurMiniGameId(-1)
							end
						end}})
				end
			end
			return
		end
	end
end

function baseClass:OnSetMiniCurGame(gameId)
	if gameId < 0 then return end
	for k, v in pairs(self.viewList) do
		if k == gameId then
			self.miniGameOrderlayer = self.miniGameOrderlayer + 50
			v:SetSortingOrder(self.miniGameOrderlayer)
			if not CC.uu.IsNil(v.transform) then
				self:RunAction(v.transform,{{"scaleToEx", 0.9, 0.9, 0.9, 0.15, ease = CC.Action.EInSine}})
			end
		else
			if not CC.uu.IsNil(v.transform) then
				self:RunAction(v.transform,{{"scaleToEx", 0.5, 0.5, 0.5, 0.15, ease = CC.Action.EInSine}})
			end
		end
	end
end

function baseClass:OnDestroy()
	self:UnRegisterEvent()
	self:CancelAllDelayRun()
	for _, v in pairs(self.viewList) do
		v:Destroy()
		v = nil
	end
	for _, v in ipairs(self.btnList) do
		v.cd = nil
	end
	self.btnList = {}
end

return baseClass
