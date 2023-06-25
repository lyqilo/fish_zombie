--***************************************************
--文件描述: 局数历史界面
--关联主体: MiniSBHistoryView.prefab
--注意事项:无
--***************************************************
local CC = require("CC")
local Request = require("View/MiniSBView/MiniSBNetwork/Request")
local MiniSBHistoryView = CC.uu.ClassView("MiniSBHistoryView")
-- local MiniSBNotification = require("View/MiniSBView/MiniSBNetwork/MiniSBNotification")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")

local initView
local query
local query2

function MiniSBHistoryView:ctor(param)
	self.mainView = param.mainView
end

function MiniSBHistoryView:OnCreate()
	-- 每次拉取多少人数
	self.loadNum = 10
	-- true 表示服务器还有数据 可以继续拉
	self.existBig = true
	self.existSmall = true
	-- 锁
	self.lock = false

	initView(self)

	local window = CC.MiniGameMgr.GetCurWindowMode()
	if window then
		self:toWindowsSize()
	else
		self:toFullScreenSize()
	end
	query(self)

	self:initLanguage()
	self:registerEvent()
end

function MiniSBHistoryView:registerEvent()
	CC.HallNotificationCenter.inst():register(self, self.toWindowsSize, CC.Notifications.OnSetWindowScreen)
	CC.HallNotificationCenter.inst():register(self, self.toFullScreenSize, CC.Notifications.OnSetFullScreen)
end

function MiniSBHistoryView:unregisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreen)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetFullScreen)
end

function MiniSBHistoryView:OnDestroy()
	self:unregisterEvent()
end

function MiniSBHistoryView:initLanguage()
	local language = self.mainView.language

	for i = 1, 2 do
		self:SubGet("InsideNode/top" .. i .. "/Text2", "Text").text = language.Date
		self:SubGet("InsideNode/top" .. i .. "/Text3", "Text").text = language.Name
		self:SubGet("InsideNode/top" .. i .. "/Text4", "Text").text = language.Bet
		self:SubGet("InsideNode/top" .. i .. "/Text5", "Text").text = language.Return
	end
end

function MiniSBHistoryView:refreshAll(sCLoadRoundRecordRsp)
	self.curRoundID = sCLoadRoundRecordRsp.curRoundID
	self.preRoundID = sCLoadRoundRecordRsp.preRoundID
	self.nextRoundID = sCLoadRoundRecordRsp.nextRoundID

	self.bigAreaRecords = sCLoadRoundRecordRsp.bigAreaRecords
	self.smallAreaRecords = sCLoadRoundRecordRsp.smallAreaRecords

	self.ScrollerControllerBig:RefreshScroller(#self.bigAreaRecords, 0)
	self.ScrollerControllerSmall:RefreshScroller(#self.smallAreaRecords, 0)

	self:updateResult(sCLoadRoundRecordRsp.result)

	self.existBig = #self.bigAreaRecords == self.loadNum
	self.existSmall = #self.smallAreaRecords == self.loadNum

	self.bigTotalBet1Text.text = CC.uu.NumberFormat(sCLoadRoundRecordRsp.bigAreaAllBet or 0)
	self.bigTotalBet2Text.text = CC.uu.NumberFormat(sCLoadRoundRecordRsp.bigAreaReturnBet or 0)
	self.smallTotalBet1Text.text = CC.uu.NumberFormat(sCLoadRoundRecordRsp.smallAreaAllBet or 0)
	self.smallTotalBet2Text.text = CC.uu.NumberFormat(sCLoadRoundRecordRsp.smallAreaReturnBet or 0)
end

function MiniSBHistoryView:refresh2(sCLoadRoundRecordRsp)
	local bigs = sCLoadRoundRecordRsp.bigAreaRecords
	local smalls = sCLoadRoundRecordRsp.smallAreaRecords
	if bigs then
		local oldLen = #self.bigAreaRecords
		for _, v in ipairs(bigs) do
			table.insert(self.bigAreaRecords, v)
		end
		self.existBig = #bigs == self.loadNum
		local p = (self.ScrollRectBig.verticalNormalizedPosition / (#self.bigAreaRecords / oldLen))
		self.ScrollerControllerBig:RefreshScroller(#self.bigAreaRecords, p)
	else
		self.existBig = false
	end
	if smalls then
		local oldLen = #self.smallAreaRecords
		for _, v in ipairs(smalls) do
			table.insert(self.smallAreaRecords, v)
		end
		self.existSmall = #smalls == self.loadNum
		local p = (self.ScrollRectSmall.verticalNormalizedPosition / (#self.smallAreaRecords / oldLen))
		self.ScrollerControllerSmall:RefreshScroller(#self.smallAreaRecords, p)
	else
		self.existSmall = false
	end
end

function MiniSBHistoryView:itemData(tran, index, list)
	local rankId = index + 1
	tran.name = tostring(rankId)
	local data = list[rankId]
	-- log("itemData ：" .. tostring(data))
	if not data then
		return
	end
	local time = os.date("%H:%M %S", data.lastTime)
	tran.transform:FindChild("Bg"):SetActive(rankId % 2 == 0)
	tran.transform:FindChild("date"):GetComponent("Text").text = time
	tran.transform:FindChild("name"):GetComponent("Text").text = data.playerInfo.nick
	local returnBet = CC.uu.ChipFormat(data.returnBet)
	local allBet = CC.uu.ChipFormat(data.allBet)

	tran.transform:FindChild("bet"):GetComponent("Text").text = allBet
	tran.transform:FindChild("win"):GetComponent("Text").text = returnBet
end

function MiniSBHistoryView:updateResult(gameResult)
	-- 刷新结果
	self.roundIdText.text = "#" .. self.curRoundID
	local ds = 0
	for i, dice in ipairs(gameResult.dices) do
		local node = self.diceNodes[i]
		self:SetImage(node, "s" .. dice)
		ds = ds + dice
	end

	self.bigEffect:SetActive(false)
	self.smallEffect:SetActive(false)

	self.bigImage:SetActive(false)
	self.smallImage:SetActive(false)

	if gameResult.locationAreas == proto.Big then
		self.bigEffect:SetActive(true)
		self.smallEffect:SetActive(false)
		self.smallImage:SetActive(true)
	elseif gameResult.locationAreas == proto.Small then
		self.bigEffect:SetActive(false)
		self.bigImage:SetActive(true)
		self.smallEffect:SetActive(true)
	end

	self.resultText.text = tostring(ds)
end

query = function(self, roundID)
	local cb = function(err, sCLoadRoundRecordRsp)
		if err == proto.ErrSuccess then
			log("load history data = " .. tostring(sCLoadRoundRecordRsp))
			self:refreshAll(sCLoadRoundRecordRsp)
		else
			log("load history err = " .. err)
		end
	end
	Request.LoadRecords(0, self.loadNum - 1, cb, roundID)
end

query2 = function(self, isSmall)
	if self.lock then
		return
	end
	self.lock = true
	local cb = function(err, sCLoadRoundRecordRsp)
		self.lock = false
		if err == proto.ErrSuccess then
			self:refresh2(sCLoadRoundRecordRsp)
			log("load histpry data = " .. tostring(sCLoadRoundRecordRsp))
		else
			log("load histpry err = " .. err)
		end
	end
	if isSmall then
		self.ScrollRectSmall.verticalNormalizedPosition = 0.9
		local start = #self.smallAreaRecords
		Request.LoadRecords(start, start + self.loadNum - 1, cb, self.curRoundID)
	else
		self.ScrollRectBig.verticalNormalizedPosition = 0.9
		local start = #self.bigAreaRecords
		Request.LoadRecords(start, start + self.loadNum - 1, cb, self.curRoundID)
	end
end

initView = function(self)
	self.roundIdText = self:FindChild("InsideNode/roundId"):GetComponent("Text")
	-- 三个骰子
	self.diceNodes = {}
	for i = 1, 3 do
		local node = self:FindChild("InsideNode/DiceResult/Dice" .. i)
		table.insert(self.diceNodes, node)
	end
	self.resultText = self:FindChild("InsideNode/DiceResult/Text"):GetComponent("Text")
	self:FindChild("InsideNode/DiceResult/Text0"):GetComponent("Text").text = "+"
	self:FindChild("InsideNode/DiceResult/Text1"):GetComponent("Text").text = "+"
	self:FindChild("InsideNode/DiceResult/Text2"):GetComponent("Text").text = "="

	self.bigEffect = self:FindChild("InsideNode/Effect_UI_tai")
	self.smallEffect = self:FindChild("InsideNode/Effect_UI_xiu")
	self.bigImage = self:FindChild("InsideNode/Da")
	self.smallImage = self:FindChild("InsideNode/Xiao")

	self.bigTotalBet1Text = self:FindChild("InsideNode/Frame/total1/bet1"):GetComponent("Text")
	self.bigTotalBet2Text = self:FindChild("InsideNode/Frame/total1/bet2"):GetComponent("Text")
	self.smallTotalBet1Text = self:FindChild("InsideNode/Frame/total2/bet1"):GetComponent("Text")
	self.smallTotalBet2Text = self:FindChild("InsideNode/Frame/total2/bet2"):GetComponent("Text")

	self.ScrollerControllerBig = self:FindChild("InsideNode/Frame/ScrollerController1"):GetComponent("ScrollerController")
	self.ScrollerControllerBig:AddChangeItemListener(
		function(tran, dataIndex, cellIndex)
			self:itemData(tran, dataIndex, self.bigAreaRecords)
		end
	)
	self.ScrollerControllerBig:InitScroller(0)

	self.ScrollerControllerSmall =
		self:FindChild("InsideNode/Frame/ScrollerController2"):GetComponent("ScrollerController")
	self.ScrollerControllerSmall:AddChangeItemListener(
		function(tran, dataIndex, cellIndex)
			self:itemData(tran, dataIndex, self.smallAreaRecords)
		end
	)
	self.ScrollerControllerSmall:InitScroller(0)

	local pubScrollRect1 = self:FindChild("InsideNode/Frame/Scroller1")
	self.ScrollRectBig = pubScrollRect1:GetComponent("ScrollRect")

	local pubScrollRect2 = self:FindChild("InsideNode/Frame/Scroller2")
	self.ScrollRectSmall = pubScrollRect2:GetComponent("ScrollRect")

	UIEvent.AddScrollRectOnValueChange(
		pubScrollRect1,
		function()
			--大于1再执行不会导致切换聊天类型的刷新
			if self.ScrollRectBig.verticalNormalizedPosition < 0 then
				-- log("到底了 再请求服务器 : " .. self.ScrollRectBig.verticalNormalizedPosition)
				if self.existBig then
					query2(self, false)
				end
			end
		end
	)
	UIEvent.AddScrollRectOnValueChange(
		pubScrollRect2,
		function()
			--大于1再执行不会导致切换聊天类型的刷新
			if self.ScrollRectSmall.verticalNormalizedPosition < 0 then
				if self.existSmall then
					query2(self, true)
				end
			end
		end
	)
	self:AddClick(
		"InsideNode/Close",
		function()
			self:ActionOut()
		end
	)
	self:AddClick(
		"InsideNode/last",
		function()
			if self.preRoundID and self.preRoundID ~= 0 then
				query(self, self.preRoundID)
			end
		end
	)
	self:AddClick(
		"InsideNode/next",
		function()
			if self.nextRoundID and self.nextRoundID ~= 0 then
				query(self, self.nextRoundID)
			end
		end
	)
end

function MiniSBHistoryView:toWindowsSize()
	self:FindChild("InsideNode").localScale = Vector3(0.67, 0.67, 0.67)
end

function MiniSBHistoryView:toFullScreenSize()
	self:FindChild("InsideNode").localScale = Vector3(0.8, 0.8, 0.8)
end

return MiniSBHistoryView
