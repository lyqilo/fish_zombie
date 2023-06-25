local CC = require("CC")
local MiniGameDefine = require("Model/MiniGame/MiniGameDefine")
local baseClass = CC.uu.ClassView("MiniGameMainView")

local windowWidthDec = 280

local HasSwitchAnim = true

function baseClass:ctor()
	self.ctr = CC.MiniGameMgr.GetMiniCtr()
	self.language = self:GetLanguage()

	self.selectRate = 1000

	self.btnList = {}
	self.viewList = {}

	self.cdTimers = {}

	self.lastPos = self.ctr:GetLastPos()
end

function baseClass:OnCreate(...)
	self.GaussBlur = GameObject.Find("HallCamera/GaussCamera"):GetComponent("GaussBlur")
	self.oldGaussBlurValue = {self.GaussBlur.BlurRadius, self.GaussBlur.downSample}
	self.GaussBlur.BlurRadius = 0
	self.GaussBlur.downSample = 0

	self:InitContent()
	self:RegisterEvent()

	self:UpdateShow(self.ctr:GetStatus())

	self.parentWidth = self.transform.rect.width
	self.parentHeight = self.transform.rect.height

	self:WindowScreen(true)
end

function baseClass:OnActionInDone(...)
	if #self.btnList > 0 then
		local id = CC.MiniGameMgr.GetLastGameId()
		for _, v in ipairs(self.btnList) do
			if id and id == v.id then
				v.toggle.isOn = true
				return
			end
		end
		self.btnList[1].toggle.isOn = true
	end
end

function baseClass:InitContent()
	self.miniChips = self:FindChild("Node/TopPanel/MiniGameChipText")
	-- self.miniChips.text = CC.uu.NumberFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_MiniChouMa") or 0)
	self.miniChipsRoller = self.miniChips:SubGet("NumberRoller")
	self.miniChipsRoller:RollTo(CC.Player.Inst():GetSelfInfoByKey("EPC_MiniChouMa") or 0, 0)

	self.miniChipBg = self:FindChild("Node/TopPanel/ChipBg2")

	self.dropdownTransform = self:FindChild("Node/TopPanel/Dropdown")
	local dropdownItems = {"1K", "10K", "1M", "10M"}
	DropdownUI.SetDropdown(self.dropdownTransform, 0, dropdownItems, nil)
	DropdownUI.AddDropdownOnValueChange(self.dropdownTransform, function(index)
		self:SelectTimes(index)
	end)

	self:AddClick(self:FindChild("Node/TopPanel/Subtract"), function()
		self:SubtractOrAddClick(false)
	end)
	self.effectAddBtn = self:FindChild("Node/TopPanel/Add/Effect")
	self:AddClick(self:FindChild("Node/TopPanel/Add"), function()
		self:SubtractOrAddClick(true)
	end)
	self:AddClick(self:FindChild("Node/TopPanel/BtnFull"), function()
		self:FullScreen()
	end)
	self:AddClick(self:FindChild("Node/TopPanel/BtnMicrify"), function()
		self:WindowScreen()
	end)

	self:AddClick("Node/BtnClose", function()
		slot(self:ActionOut(), self)
	end)

	self.content = self:FindChild("Node/Content")
	self.btnRoot = self:FindChild("Node/LeftPanel/BtnList")
	self.btnPrefab = self:FindChild("Node/LeftPanel/BtnList/Btn")

	for _, v in ipairs(MiniGameDefine) do
		local btnItem = self:CreateBtn(v)
		table.insert(self.btnList, btnItem)
	end

	self.nodeTr = self:FindChild("Node")
	self:AddDragEvent(self.nodeTr)

	--vip礼包按钮
	self.vipGiftParent = self:FindChild("Node/vipGiftParent")
	self.vipGiftParentTarget = self.vipGiftParent:FindChild("target")
	self.giftNode = CC.SubGameInterface.CreateSelectGiftCollectionIcon({parent = self.vipGiftParentTarget})

end

function baseClass:CreateBtn(v)
	local btnItem = {}
	btnItem.id = v.id
	local btn = CC.uu.newObject(self.btnPrefab, self.btnRoot)
	btn.name = v.nodeName
	btn:FindChild("Background/gameName").text = self.language[v.key]
	btn:SetActive(true)
	btnItem.btn = btn
	btnItem.toggle = btn:GetComponent("Toggle")
	btnItem.bg = btn:FindChild("Background")
	btnItem.effect = btn:FindChild("Effcet_XiaoTingTuBiao")
	btnItem.effect:SetActive(false)
	self:SetImage(btnItem.bg, v.cdIcon)
	btnItem.gameText = btn:FindChild("Background/gameText")
	btnItem.gameText.text = ""
	btnItem.auto = btn:FindChild("Background/auto")
	btnItem.auto:SetActive(false)
	btnItem.winEff = btn:FindChild("Background/win")
	btn:FindChild("Background/win/Text").text = self.language.win
	btnItem.gameEff = btn:FindChild("Background/ready")
	btnItem.gameEffText = btn:FindChild("Background/ready/Text")
	btnItem.cd = btn:SubGet("Background/cd", "Image")
	btnItem.cd:SetActive(true)
	btnItem.cd.fillAmount = 0
	UIEvent.AddToggleValueChange(btn,
		function(selected)
			if selected then
				if CC.MiniGameMgr.GetCurMiniGameId() == v.id then
					return
				end

				if self.currentView then
					if not CC.uu.IsNil(self.currentView.transform) then
						if HasSwitchAnim then
							local node = self.currentView.transform
							self:RunAction(
								node,
								{
									{
										"scaleToEx",
										0,
										0,
										0,
										0.15,
										ease = CC.Action.EInSine,
										function()
											node.localPosition = Vector3(9999, 9999, 0)
											-- node:SetActive(false)
										end
									}
								}
							)
						else
							self.currentView.transform.localPosition = Vector3(9999, 9999, 0)
						end
					end
					self.currentView = nil
				end

				if self.viewList[v.id] then
					if not CC.uu.IsNil(self.viewList[v.id].transform) then
						if HasSwitchAnim then
							local node = self.viewList[v.id].transform
							node.localPosition = Vector3(0, 0, 0)
							-- node:SetActive(true)
							self:RunAction(
								node,
								{
									{
										"scaleToEx",
										1,
										1,
										1,
										0.15,
										ease = CC.Action.EInSine
									}
								}
							)
						else
							self.viewList[v.id].transform.localPosition = Vector3.zero
						end
					end
					self.currentView = self.viewList[v.id]
				else
					if v.view and v.view ~= "" then
						self.ctr:OpenMiniGame(
							v.id,
							function(ip)
								-- "172.13.0.119:30001"
								log(ip)
								-- self.currentView = CC.uu.CreateHallView(v.view,{serverIp=ip})
								local viewClass = require(v.viewPath)
								self.currentView = viewClass.new({serverIp = ip})
								self.currentView:Create()
								self.currentView.transform:SetParent(self.content, false)
								self.viewList[v.id] = self.currentView
							end
						)
					end
				end

				CC.MiniGameMgr.SetCurMiniGameId(v.id)

				self:SetImage(btnItem.bg, v.icon)
				btnItem.cd:SetActive(false)
				btnItem.effect:SetActive(true)
			else
				self:SetImage(btnItem.bg, v.cdIcon)
				btnItem.cd:SetActive(true)
				btnItem.effect:SetActive(false)
			end
		end
	)
	return btnItem
end

function baseClass:SelectTimes(index)
	if index == 0 then
		self.selectRate = 1000
	elseif index == 1 then
		self.selectRate = 10000
	elseif index == 2 then
		self.selectRate = 1000000
	elseif index == 3 then
		self.selectRate = 10000000
	end
end

function baseClass:SubtractOrAddClick(isAdd)
	if CC.ViewManager.IsHallScene() then
		self.ctr:HallAndMiniConvert(self.selectRate, isAdd)
		self.effectAddBtn:SetActive(false)
	else
		CC.ViewManager.ShowTip(self.language.inGame)
	end
end

function baseClass:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnMiniGameBetShortage, CC.Notifications.OnMiniGameBetShortage)
	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self, self.OnMiniStatusUpdate, CC.Notifications.OnMiniStatusUpdate)
	CC.HallNotificationCenter.inst():register(self, self.OnMiniGameClose, CC.Notifications.OnMiniGameClose)
	CC.HallNotificationCenter.inst():register(self, self.OnSetMiniGameAuto, CC.Notifications.OnSetMiniGameAuto)
	CC.HallNotificationCenter.inst():register(self, self.OnSetMiniGameBet, CC.Notifications.OnSetMiniGameBet)
	CC.HallNotificationCenter.inst():register(self, self.OnSetMiniGameResult, CC.Notifications.OnSetMiniGameResult)
	CC.HallNotificationCenter.inst():register(self, self.OnSetWindowScreenComplete, CC.Notifications.OnSetWindowScreenComplete)
end

function baseClass:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnMiniGameBetShortage)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnMiniStatusUpdate)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnMiniGameClose)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetMiniGameAuto)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetMiniGameBet)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetMiniGameResult)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreenComplete)
end

function baseClass:OnMiniGameBetShortage()
	self.effectAddBtn:SetActive(true)
end

function baseClass:OnChangeSelfInfo(props, source)
	for _, v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_MiniChouMa then
			local miniCount = v.Count
			local miniDelta = v.Delta
			if source and source == CC.shared_transfer_source_pb.TS_Game and miniDelta and miniDelta > 0 then
				-- self:PlayWinAnim(miniDelta)
				self:DelayRun(5, function()
					self.miniChipsRoller:RollTo(miniCount, 2)
				end)
			else
				--self.miniChips.text = CC.uu.NumberFormat(miniCount)
				self.miniChipsRoller:RollTo(miniCount, 0)
			end
		end
	end
end

function baseClass:PlayWinAnim(delta)
	CC.Sound.PlayHallEffect("minigamewinaddchips")
	local animGo = CC.uu.LoadHallPrefab("MiniGame/prefab", "MiniGameWinAnim", self.miniChipBg, "MiniGameWinAnim", nil)
	animGo:FindChild("Text").text = "+" .. CC.uu.ChipFormat(delta)
	self:DelayRun(2, function()
		GameObject.Destroy(animGo.gameObject)
	end)
end

function baseClass:OnMiniStatusUpdate(data)
	self:UpdateShow(data)
end

function baseClass:UpdateShow(data, timeStamp)
	for id, d in pairs(data or {}) do
		for _, item in ipairs(self.btnList) do
			if id == item.id then
				local countdown = d.countdown

				if self.cdTimers[item.id] then
					self.cdTimers[item.id]:Stop()
				end
				item.cd.fillAmount = 0
				if d.state == 1 then
					local passTime
					if timeStamp then
						passTime = os.difftime(os.time(), timeStamp)
					-- if passTime <= countdown then
					-- 	countdown = countdown - passTime
					-- end
					end
					self:StartCD(item, countdown, passTime)
					item.gameText.text = ""
				end
			end
		end
	end
end

function baseClass:StartCD(item, time, pTime)
	local passTime = pTime or 0
	local timer
	timer = FrameTimer.New(
		function()
			passTime = passTime + Time.deltaTime
			if passTime <= time then
				local cd = 1.0 * passTime / time
				item.cd.fillAmount = cd
			else
				item.cd.fillAmount = 1
				timer:Stop()
				timer = nil
			end
		end,
		1,
		-1
	)
	timer:Start()
	self.cdTimers[item.id] = timer
end

function baseClass:OnMiniGameClose()
	self:Destroy()
end

function baseClass:OnSetMiniGameAuto(gameId, bValue)
	for _, item in ipairs(self.btnList) do
		if item.id == gameId and bValue ~= nil then
			item.auto:SetActive(bValue)
			return
		end
	end
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
	if nValue and nValue > 0 then
		self:PlayWinAnim(nValue)
	end

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

function baseClass:WindowScreen(noAnim)
	self:SetCanClick(false)
	self:FindChild("Node/TopPanel/BtnFull"):SetActive(true)
	self:FindChild("Node/TopPanel/BtnMicrify"):SetActive(false)
	self.nodeTr.localPosition = self.lastPos
	self.nodeTr.sizeDelta = Vector2(-windowWidthDec, 0)

	local pos = self.transform.localPosition
	self.transform.localPosition = Vector3(pos.x, pos.y - 30, pos.z)

	CC.MiniGameMgr.SetCurWindowMode(true)
	if noAnim then
		self.nodeTr.localScale = Vector3(0.8, 0.8, 0.8)
		self:SetCanClick(true)
	else
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnSetWindowScreen)
		self:RunAction(
			self.nodeTr,
			{
				{
					"scaleToEx",
					0.8,
					0.8,
					0.8,
					0.3,
					ease = CC.Action.EOutBack,
					function()
						self:SetCanClick(true)
					end
				}
			}
		)
	end
end

function baseClass:FullScreen()
	self:SetCanClick(false)
	self:FindChild("Node/TopPanel/BtnFull"):SetActive(false)
	self:FindChild("Node/TopPanel/BtnMicrify"):SetActive(true)
	self.lastPos = self.nodeTr.localPosition
	self.nodeTr.localPosition = Vector3.zero
	self.nodeTr.sizeDelta = Vector2(0, 0)

	local pos = self.transform.localPosition
	self.transform.localPosition = Vector3(pos.x, pos.y + 30, pos.z)

	CC.MiniGameMgr.SetCurWindowMode(false)
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnSetFullScreen)
	self:RunAction(
		self.nodeTr,
		{
			{
				"scaleToEx",
				1,
				1,
				1,
				0.3,
				ease = CC.Action.EOutBack,
				function()
					self:SetCanClick(true)
				end
			}
		}
	)
end

function baseClass:OnSetWindowScreenComplete(width)
	-- self:FindChild("Node").sizeDelta = Vector2(-width,0)
end

function baseClass:AddDragEvent(target)
	target.onMove = function(obj, pos)
		if CC.MiniGameMgr.GetCurWindowMode() then
			self:moveLimit(obj)
		else
			obj.localPosition = Vector3.zero
		end
	end
	target.onEndDrag = function(obj, pos)
		if CC.MiniGameMgr.GetCurWindowMode() then
			self.lastPos = self.nodeTr.localPosition
		end
	end
end

function baseClass:moveLimit(obj)
	local moveX = math.abs(obj.localPosition.x)
	local moveY = math.abs(obj.localPosition.y)

	local limitX = self.parentWidth / 1.5
	local limitY = self.parentHeight / 1.5

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

function baseClass:ActionOut()
	self:SetCanClick(false)
	self:RunAction(self.nodeTr,
		{
			{
				"localMoveTo",
				-self.parentWidth * 2,
				CC.MiniGameMgr.GetCurWindowMode() and self.lastPos.y or 0,
				0.5,
				ease = CC.Action.EOutBack,
				function()
					self:Destroy()
				end
			}
		}
	)
end

function baseClass:ActionIn()
	self.nodeTr.x = -self.parentWidth
	self.nodeTr.y = self.lastPos.y
	self:SetCanClick(false)
	self:RunAction(self.nodeTr,
		{
			{
				"localMoveTo",
				self.lastPos.x,
				self.lastPos.y,
				0.5,
				ease = CC.Action.EOutBack,
				function()
					self:SetCanClick(true)
					self:OnActionInDone()
				end
			}
		}
	)
end

function baseClass:OnDestroy()
	log("MiniGameMainView OnDestroy----------------")
	self.ctr:SetLastPos(self.lastPos)
	CC.SubGameInterface.DestroySelectGiftCollectionIcon(self.giftNode)
	self.GaussBlur.BlurRadius = self.oldGaussBlurValue[1]
	self.GaussBlur.downSample = self.oldGaussBlurValue[2]

	CC.MiniGameMgr.SetLastGameId()
	for _, timer in pairs(self.cdTimers) do
		timer:Stop()
		timer = nil
	end
	for k, v in pairs(self.viewList) do
		v:Destroy()
		v = nil
	end
	self:UnRegisterEvent()
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnMiniGameClose)

	self.miniChipsRoller = nil
	for _, v in ipairs(self.btnList) do
		v.toggle = nil
		v.cd = nil
	end
	self.btnList = {}
end

return baseClass