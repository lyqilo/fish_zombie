--***************************************************
--文件描述: 排行榜界面
--关联主体: MiniSBRankingView.prefab
--注意事项:无
--***************************************************
local CC = require("CC")
local Request = require("View/MiniSBView/MiniSBNetwork/Request")
local MiniSBRankingView = CC.uu.ClassView("MiniSBRankingView")
-- local MiniSBNotification = require("View/MiniSBView/MiniSBNetwork/MiniSBNotification")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")

local initView
local query

function MiniSBRankingView:ctor(param)
	self.mainView = param.mainView
end

function MiniSBRankingView:OnCreate()
	initView(self)
	self:registerEvent()
	query(self)

	local window = CC.MiniGameMgr.GetCurWindowMode()
	if window then
		self:toWindowsSize()
	else
		self:toFullScreenSize()
	end

	self.textColor = {
		Color(0.97, 0.87, 0.19, 1),
		Color(0.77, 0.79, 0.86, 1), --c6cadd
		Color(0.95, 0.61, 0.34, 1)
	}
	self:initLanguage()
end

function MiniSBRankingView:registerEvent()
	CC.HallNotificationCenter.inst():register(self, self.toWindowsSize, CC.Notifications.OnSetWindowScreen)
	CC.HallNotificationCenter.inst():register(self, self.toFullScreenSize, CC.Notifications.OnSetFullScreen)
end

function MiniSBRankingView:unregisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreen)
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetFullScreen)
end

function MiniSBRankingView:OnDestroy()
	self:unregisterEvent()
end

function MiniSBRankingView:initLanguage()
	local language = self.mainView.language
	-- 提示输入
	local rankText = self:SubGet("InsideNode/top/Rank", "Text")
	local nameText = self:SubGet("InsideNode/top/Name", "Text")
	local chipCountText = self:SubGet("InsideNode/top/ChipCount", "Text")

	rankText.text = language.Rank
	nameText.text = language.NameText
	chipCountText.text = language.ChipCount
end

function MiniSBRankingView:refresh(sCLoadPlayerRankRsp)
	self.rankList = sCLoadPlayerRankRsp.ranks
	self.ScrollerController:RefreshScroller(#self.rankList, 0)
end

function MiniSBRankingView:itemData(tran, index)
	local rankId = index + 1
	tran.name = tostring(rankId)
	local data = self.rankList[rankId]
	-- log("itemData ：" .. tostring(data))
	if not data then
		return
	end

	tran.transform:FindChild("Bg"):SetActive(rankId % 2 == 0)
	local nameText = tran.transform:FindChild("name"):GetComponent("Text")
	nameText.text = data.playerInfo.nick
	local winCoin = CC.uu.ChipFormat(data.winCoin)
	tran.transform:FindChild("win"):GetComponent("Text").text = winCoin

	local rankNum = tran.transform:FindChild("rankNum")
	local rankImage = tran.transform:FindChild("rankImage")
	if rankId > 3 then
		rankNum:GetComponent("Text").text = tostring(rankId)
		rankNum:SetActive(true)
		rankImage:SetActive(false)

		nameText.color = Color(0.87, 0.71, 0.47, 1)
	else
		self:SetImage(rankImage, "d" .. rankId)
		rankNum:SetActive(false)
		rankImage:SetActive(true)

		nameText.color = self.textColor[rankId]
	end
end

query = function(self)
	local cb = function(err, sCLoadPlayerRankRsp)
		if err == proto.ErrSuccess then
			log("loadranking data = " .. tostring(sCLoadPlayerRankRsp))
			self:refresh(sCLoadPlayerRankRsp)
		else
			log("loadranking err = " .. err)
		end
	end
	Request.RankListReq(0, 9, cb)
end

initView = function(self)
	self.ScrollerController = self:FindChild("InsideNode/Frame/ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(
		function(tran, dataIndex, cellIndex)
			self:itemData(tran, dataIndex, cellIndex)
		end
	)
	self.ScrollerController:InitScroller(0)
	self:AddClick(
		"InsideNode/Close",
		function()
			self:ActionOut()
		end
	)
end

function MiniSBRankingView:toWindowsSize()
	self:FindChild("InsideNode").localScale = Vector3(0.9, 0.9, 0.9)
end

function MiniSBRankingView:toFullScreenSize()
	self:FindChild("InsideNode").localScale = Vector3(1, 1, 1)
end

return MiniSBRankingView
