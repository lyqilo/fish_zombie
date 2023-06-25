--***************************************************
--文件描述: 个人历史界面
--关联主体: MiniSBMyHistoryView.prefab
--注意事项:无
--***************************************************
local CC = require("CC")
local Request = require("View/MiniSBView/MiniSBNetwork/Request")
local MiniSBMyHistoryView = CC.uu.ClassView("MiniSBMyHistoryView")
-- local MiniSBNotification = require("View/MiniSBView/MiniSBNetwork/MiniSBNotification")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")

local initView
local query

function MiniSBMyHistoryView:ctor(param)
	self.mainView = param.mainView
end

function MiniSBMyHistoryView:OnCreate()
	-- 每次拉取多少人数
	self.loadNum = 10
	-- true 表示服务器还有数据 可以继续拉
	self.exist = true
	-- 锁
	self.lock = false
	self.recordList = {}

	initView(self)

	query(self)
	self:initLanguage()
	self:registerEvent()

	local window = CC.MiniGameMgr.GetCurWindowMode()
	if window then
		self:toWindowsSize()
	else
		self:toFullScreenSize()
	end
end

function MiniSBMyHistoryView:registerEvent()
	CC.HallNotificationCenter.inst():register(self, self.toWindowsSize, CC.Notifications.OnSetWindowScreen)
	CC.HallNotificationCenter.inst():register(self, self.toFullScreenSize, CC.Notifications.OnSetFullScreen)
end

function MiniSBMyHistoryView:unregisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreen)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetFullScreen)
end

function MiniSBMyHistoryView:OnDestroy()
	self:unregisterEvent()
end

function MiniSBMyHistoryView:initLanguage()
	local language = self.mainView.language
	self.language = language

	local roomIdText = self:SubGet("InsideNode/top/num", "Text")
	local dateText = self:SubGet("InsideNode/top/date", "Text")
	local resultText = self:SubGet("InsideNode/top/result", "Text")
	local diceResultText = self:SubGet("InsideNode/top/dices", "Text")
	local betText = self:SubGet("InsideNode/top/bet", "Text")
	local returnText = self:SubGet("InsideNode/top/bet2", "Text")
	local winText = self:SubGet("InsideNode/top/win", "Text")

	roomIdText.text = language.RoomID
	dateText.text = language.Date
	resultText.text = language.Result
	diceResultText.text = language.DiceResult
	betText.text = language.BetCountTextLowerCase
	returnText.text = language.ReturnText
	winText.text = language.WinText
end

function MiniSBMyHistoryView:refresh(sCLoadPlayerRecordRsp)
	local oldLen = #self.recordList
	if sCLoadPlayerRecordRsp.records then
		for _, v in ipairs(sCLoadPlayerRecordRsp.records) do
			table.insert(self.recordList, v)
		end
	end

	local p = (self.ScrollRect.verticalNormalizedPosition / (#self.recordList / oldLen))

	self.ScrollerController:RefreshScroller(#self.recordList, p)

	self.exist = #sCLoadPlayerRecordRsp.records == self.loadNum
end

function MiniSBMyHistoryView:itemData(tran, index)
	local rankId = index + 1
	tran.name = tostring(rankId)
	local data = self.recordList[rankId]
	if not data then
		return
	end
	local dicesStr = data.result.dices[1]
	local dicesNum = data.result.dices[1]
	for i = 2, 3 do
		local d = data.result.dices[i]
		dicesStr = dicesStr .. "-" .. d
		dicesNum = dicesNum + d
	end
	local myAreasStr = self.language.Big
	if data.myAreas == proto.Small then
		myAreasStr = self.language.Small
	end
	local time = os.date("%d-%m-%y %H:%M %S", data.lastTime)
	dicesStr = dicesStr .. " " .. dicesNum
	tran.transform:FindChild("Bg"):SetActive(rankId % 2 == 0)
	tran.transform:FindChild("num"):GetComponent("Text").text = "#" .. data.roundID
	tran.transform:FindChild("date"):GetComponent("Text").text = time
	tran.transform:FindChild("result"):GetComponent("Text").text = myAreasStr
	tran.transform:FindChild("dices"):GetComponent("Text").text = dicesStr
	local allBet = CC.uu.ChipFormat(data.allBet)
	local returnBet = CC.uu.ChipFormat(data.returnBet)
	-- local gainBet = CC.uu.ChipFormat(data.gainBet)

	local gainBet = 0
	if data.gainBet > 0 then
		gainBet = (data.allBet - data.returnBet) * 2 --  包括抽水
	end
	local gainBetStr = CC.uu.ChipFormat(gainBet)

	tran.transform:FindChild("bet"):GetComponent("Text").text = allBet
	tran.transform:FindChild("bet2"):GetComponent("Text").text = returnBet
	tran.transform:FindChild("win"):GetComponent("Text").text = gainBetStr
end

--@region 数据model
query = function(self)
	if self.lock then
		return
	end
	self.lock = true
	local cb = function(err, sCLoadPlayerRecordRsp)
		self.lock = false
		if err == proto.ErrSuccess then
			log("load my histpry data = " .. tostring(sCLoadPlayerRecordRsp))
			self:refresh(sCLoadPlayerRecordRsp)
		else
			log("load my histpry err = " .. err)
		end
	end
	self.ScrollRect.verticalNormalizedPosition = 0.9
	local start = #self.recordList
	Request.LoadPlayerRecords(start, start + self.loadNum - 1, cb)
end

initView = function(self)
	self.ScrollerController = self:FindChild("InsideNode/Frame/ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(
		function(tran, dataIndex, cellIndex)
			self:itemData(tran, dataIndex, cellIndex)
		end
	)
	self.ScrollerController:InitScroller(0)

	local pubScrollRect = self:FindChild("InsideNode/Frame/Scroller")
	self.ScrollRect = pubScrollRect:GetComponent("ScrollRect")
	UIEvent.AddScrollRectOnValueChange(
		pubScrollRect,
		function()
			--大于1再执行不会导致切换聊天类型的刷新
			if self.ScrollRect.verticalNormalizedPosition < 0 then
				-- log("到底了 再请求服务器")
				if self.exist then
					query(self)
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
end

function MiniSBMyHistoryView:toWindowsSize()
	self:FindChild("InsideNode").localScale = Vector3(0.9, 0.9, 0.9)
end

function MiniSBMyHistoryView:toFullScreenSize()
	self:FindChild("InsideNode").localScale = Vector3(1, 1, 1)
end

return MiniSBMyHistoryView
