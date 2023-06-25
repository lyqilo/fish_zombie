local GC = require("GC")
local ZTD = require("ZTD")
--NFT系统界面
local NFTView = ZTD.ClassView("ZTD_NFTView")
local FormatNum = GC.uu.numberToStrWithComma
--最高品质
local maxGrade = 6
local maxNFTTab = 5
local OptionData = UnityEngine.UI.Dropdown.OptionData

local boxKindList = {
	[1] = "box_gold",
	[2] = "box_silver",
	[3] = "box_copper"
}

function NFTView:OnCreate()
	self.config = self._args[1]
	ZTD.NFTConfig.maxSeasonRank = self.config.rank_prize[#self.config.rank_prize].end_rank-3
	
	self.cb = self._args[2]
	self.cardList = {}
	self.dayRankList = {}
	self.seasonRankList = {}
	self.nftCardParent = self:FindChild("root")
	self:PlayAnimAndEnter()

	self:InitLan()
	ZTD.NFTData.SetFRT(self.config.frt_count)
	ZTD.MainScene.HideCamera()
    self:InitBtn()
    self:InitUI()
	self:SetCD()
	self:SelectItem(1)
	self:IsGetCard()
	self:Register()
	
end

--注册通知
function NFTView:Register()
	--ZTD.Notification.GameRegister(self, ZTD.Define.MsgRefreshGold, self.OnRefreshGold)
	--大厅道具变更推送
	--ZTD.Notification.GameRegister(self, ZTD.Define.OnPushPropsInfo, self.OnPushPropsInfo)
	ZTD.Notification.GameRegister(self, ZTD.Define.MsgRefreshFRT, self.OnRefreshFRT)
end

function NFTView:InitUI()
	
	self.goldText = self:GetCmp("root/Top/Gold/Text", "Text")
	self.dimond = self:GetCmp("root/Top/Dimond/Text", "Text")
	self.frt = self:GetCmp("root/Top/FRT/Text", "Text")
	
	self.dayPoolRed = self:FindChild("root/Left/BtnItem1/ImageRed")
	self.seasonPoolRed = self:FindChild("root/Left/BtnItem2/ImageRed")
	self.packRed = self:FindChild("root/Left/BtnItem3/ImageRed")
	self.marketRed = self:FindChild("root/Left/BtnItem4/ImageRed")
	
	self.dayCDNormal = self:GetCmp("root/Left/BtnItem1/ImageNormal/TextCD", "Text")
	self.dayCDSelected = self:GetCmp("root/Left/BtnItem1/ImageSelected/TextCD", "Text")
	self.seasonCDNormal= self:GetCmp("root/Left/BtnItem2/ImageNormal/TextCD", "Text")
	self.seasonCDSelected = self:GetCmp("root/Left/BtnItem2/ImageSelected/TextCD", "Text")
	
	self:RefreshGold(ZTD.GoldData.Gold.Show)
	self:OnRefreshFRT(self.config.frt_count)
	
	self.dayPoolRed:SetActive(self.config.has_daily_reward)
	self.seasonPoolRed:SetActive(self.config.has_season_reward)
	self.packRed:SetActive(ZTD.Flow.hasNewCard or false)
	self.marketRed:Hide()

	
	local diamond = FormatNum(ZTD.PlayerData.GetDiamond())
	self.dimond .text = diamond
	
	--self:FindChild("root/Item5"):SetActive(true)
end
--倒计时
function NFTView:SetCD()	
	local stamp = Util.GetTimeStamp(true)
	local dayTime = self.config.day_pool_end_stamp - stamp
	local seasonTime = self.config.season_pool_end_stamp - stamp
	self.dayCDNormal.text = GC.uu.TicketFormat(dayTime)
	self.dayCDSelected.text = GC.uu.TicketFormat(dayTime)
	self.seasonCDNormal.text = GC.uu.TicketFormat(seasonTime)
	self.seasonCDSelected.text = GC.uu.TicketFormat(seasonTime)
	self:StartTimer("CountDown", 1, function ()
		dayTime = dayTime - 1
		seasonTime = seasonTime - 1
		self.dayCDNormal.text = GC.uu.TicketFormat(dayTime)
		self.dayCDSelected.text = GC.uu.TicketFormat(dayTime)
		self.seasonCDNormal.text = GC.uu.TicketFormat2(seasonTime)
		self.seasonCDSelected.text = GC.uu.TicketFormat2(seasonTime)
	end, 999999999)
end--[[
function NFTView:OnPushPropsInfo(data)	
	for _, v in ipairs(data.Info) do--金币变动
		if v.PropsID == 2 then
			self.gold = self.gold + v.AddNum
			self.goldText.text = FormatNum(self.gold)
		end
	end
end--]]
function NFTView:RefreshGold(gold)
	self.gold = gold
	self.goldText.text = FormatNum(gold)
end

function NFTView:OnRefreshFRT(frt)
	local tmp = (frt or ZTD.NFTData.GetFRT())/1000000
	
	self.frt.text = ZTD.Extend.FormatSpecNum(tmp,6)
end


function NFTView:InitBtn()
	for i=1, 5 do
		self["ItemSelected" .. i] = self:FindChild("root/Left/BtnItem"..i.."/ImageSelected")
		self:AddClick("root/Left/BtnItem"..i, function()
			self:SelectItem(i)
		end)
	end
	
    self:AddClick("root/Top/BtnClose", function()
        self:Destroy()
    end)
	local btnApp = self:FindChild("root/Left/BtnApp")
	ZTD.Extend.RunAction(btnApp,{
		{"localMoveBy", 0, 14,0,0.5, ease = ZTD.Action.EOutQuad},
		{"localMoveBy", 0, -14,0,0.5, ease = ZTD.Action.EInQuad},
		
		loop = {999999,ZTD.Action.LTRestart}
	})
    self:AddClick(btnApp, function()
		--local phone = tostring(GC.SubGameInterface.GetTelephone()) or ""
		local data = {
			account = self.config.account,
			frt = (ZTD.NFTData.GetFRT() or 0)/1000000
		}
		ZTD.ViewManager.Open("ZTD_NFTFRTAppView", data)
    end)
end

--请求判断今日是否获取绑定卡牌
function NFTView:IsGetCard()
	ZTD.Request.HttpRequest("ReqIsCard", {
	
	}, function (data)
		-- 是否显示获取卡牌
		if not data.Success then
			ZTD.Request.HttpRequest("ReqGetCard", {
			}, function(data)
				ZTD.NFTData.NewCard(data.Result)
				self:GetCard(data.Result.ID, 4,function ()
					self.packRed:SetActive(true)
				end, {localPos = self:FindChild("root/Left/BtnItem3").localPosition})
			end, function ()
			end, false)
		end
	end, function ()
	end, false)
end

--今日奖池/赛季奖池/我的卡包/交易所
function NFTView:SelectItem(idx)
	if self.selectItem == idx then
		return
	end
	-- if idx == 5 then
	-- 	self:Openpleasedevelopment()
	-- 	return
	-- end
	self.selectItem = idx
	for i=1, maxNFTTab do
		if idx == i then
			self:FindChild("root/Item" .. i):SetActive(true)
			self["ItemSelected" .. i]:Show()
		else
			self:FindChild("root/Item" .. i):SetActive(false)
			self["ItemSelected" .. i]:Hide()
		end
	end

	if idx==1 then
		self:ShowDayPool()
	elseif idx==2 then
		self:ShowSeasonPool()
	elseif idx==3 then
		self:ShowPack()
	elseif idx==4 then
		self:ShowMarket() 
	elseif idx==5 then
		self:Openpleasedevelopment() 
	end
	
end

--创建nft 卡片
function NFTView:CreateNFTCard(id, parent)
	local data = ZTD.NFTData.GetCard(id)
	local card = ZTD.NFTCard:new(data, parent or self.nftCardParent)
	table.insert(self.cardList, card)

	return card
end
--移除nft 卡片
function NFTView:RemoveNFTCard(card)
	for i,v in pairs(self.cardList) do
		if v == card then
			table.remove(self.cardList,i)
			card:Release()
			break
		end
	end
end
--移除nft 卡片
function NFTView:RemoveAllNFTCard()
	for i=#self.cardList,1,-1 do
		self.cardList[i]:Release()
	end
	self.cardList = {}
end
--算力变化
function NFTView:CardPowerChange(id, power)
	for _,card in pairs(self.cardList) do
		if card.id == id then
			card:SetPower(power)
		end
	end
	
	local power = 0
	for pos,id in pairs(self.armedList) do
		if id ~= "" then
			local data = ZTD.NFTData.GetCard(id)
			power = power + data.power
		end
	end
	self.selfPowerText.text = FormatNum(power)
end




-----------------------今日奖池相关 开始-------------

--显示每日奖池
function NFTView:ShowDayPool(data)
	--第一次做初始化
    if not self.firstShowDayPool then
		self.firstShowDayPool = true
		self:InitDayPool()
	end
	self.dayScrollCtr:ClearAll()
	self.dayScrollCtr:InitScroller(0)
	self:ReqCurDayRank(0)
	self:ReqDayPool()
	self:ReqTotalPower()
end

--每日奖池信息设置
function NFTView:SetDayPool(pool)
	self.dayPool = pool
	if not self.curDayPool then
		self.curDayPool = pool
		self.dayPoolText.text = FormatNum(math.floor(self.curDayPool))
		--return
	end
	--[[if self.curDayPool < self.dayPool*0.8 then
		self.curDayPool = self.dayPool*0.8
	end--]]
	if self.dayPoolTimer then
		self:StopTimer("DayPool")
	end
	local interval = 0.1
	self.dayPoolInterval = 0
	local delta = (self.dayPool-self.curDayPool)/5*interval
	delta = delta < 1 and 1 or delta
	--奖池滚动
	self.dayPoolTimer = self:StartTimer("DayPool", interval, function ()
		self.dayPoolInterval = self.dayPoolInterval + interval
		--120s请求一次数据
		if self.dayPoolInterval > 10 then
			self.dayPoolInterval = 0
			self:ReqDayPool()
		end
		if self.selectItem == 1 and self.curDayPool < self.dayPool then
			self.curDayPool = self.curDayPool+delta
			self.dayPoolText.text = FormatNum(math.floor(self.curDayPool))
		end
		
end,10/interval+10)

end

function NFTView:SetMineRank(data)
	--print("========== NFTView:SetMineRank start == ", data)
	if tostring(data) == "userdata: NULL" or data.rank == 0 then
		--print("========== NFTView:SetMineRank 11111111")
		self.rankDayMineText.text = self.lan.noRank
		self.powerDayMineText.text = 0
		self.rewardDayMineText.text =  0
		self.rewardFRTDayMineText.text = 0
		self:FindChild("root/Item1/Bottom/Top"):Hide()
		
	else
		self.rankDayMineText.text = data.rank 
		self.powerDayMineText.text = FormatNum(data.power)
		self.rewardDayMineText.text = FormatNum(data.prize.prize.gold or 0)
		self.rewardFRTDayMineText.text = ZTD.Extend.FormatSpecNum((data.prize.prize.frt or 0)/1000000, 6)

		--print("========== NFTView:SetMineRank 22222222222")
		if data.rank < 4 then
			self:FindChild("root/Item1/Bottom/Top"):Show()
			for i=1,3 do
				self:FindChild("root/Item1/Bottom/Top/Top"..i):SetActive(data.rank == i)
			end
		else
			self:FindChild("root/Item1/Bottom/Top"):Hide()
		end
		--print("========== NFTView:SetMineRank 33333333333")
	end

end

function NFTView:DealDayRankData(data, reset)
	
	self:SetMineRank(data.my_record)
	self:SetText("root/Top/TextSeasonIdx", string.format('(%s)', data.season_info.season_name))
	--[[if data.season_info then
		self:SetDayPool(data.season_info.total_pool or 0)
		self.curDayPowerText.text = data.season_info.total_power or 0
	end--]]
	
	if not data.records or #data.records == 0 then
		--print("DealDayRankData data.records === nul")
		return
	end
	if reset then--重新拉数据
		self.dayRankList = table.copy(data.records)
		self.dayScrollCtr:ClearAll()
		if #self.dayRankList > 0 then
			self.dayScrollCtr:InitScroller(#self.dayRankList)
		end
	else
		
		local oldIndex = #self.dayRankList-5
		oldIndex = oldIndex > 0 and oldIndex or 0
		for _,v in ipairs(data.records) do
			table.insert(self.dayRankList, v)
		end
		local progress = 1-self.dayScrollCtr:GetComponent("ScrollRect").verticalNormalizedPosition
		self.dayScrollCtr:RefreshScroller(#self.dayRankList,progress)
		self.dayScrollCtr.myScroller:JumpToDataIndex(oldIndex)
	end
end
--请求每日奖池排行
--offset数据偏移量
function NFTView:ReqCurDayRank(offset)
	--每次拉取的数据量
	local count = 20
	offset = offset or 0
	ZTD.Request.HttpRequest("ReqCurDayRank", {
		page = {
			limit = count,
			offset = offset,
		}
	}, function (data)
		if not data.records or #data.records < count then
			--没有更多数据了，别拉了
			self.noMoreCurDayRankData = true
		else
			self.noMoreCurDayRankData = false
		end
		--print("======== DealDayRankData ======")
		self:DealDayRankData(data, offset==0)

	end, function ()
		logError("ReqCurDayRank error")
	end, true)
end
--请求每日奖池
function NFTView:ReqDayPool()
	ZTD.Request.HttpRequest("ReqDayPool", {
		
	}, function (data)
		
		self:SetDayPool(data.value)
	end, function ()
		logError("ReqDayPool error")
	end, false)
end
--请求总算力
function NFTView:ReqTotalPower()
	ZTD.Request.HttpRequest("ReqTotalPower", {
		
	}, function (data)
		self.curDayPowerText.text = FormatNum(data.value)
		--self:SetDayPool(data.value)
	end, function ()
		logError("ReqTotalPower error")
	end, false)
end
--首次打开初始化信息
function NFTView:InitDayPool()
	self.dayPool = 0
    self:AddClick("root/Item1/Top/BtnRecord", function()
			self:OpenDayPoolRecord()
		end)
    self:AddClick("root/Item1/Top/BtnHelp", function()
			self:OpenHelp("dayPool")
		end)
	self.btnDayGetReward = self:FindChild("root/Item1/Bottom/BtnGetReward")
	self.btnDayGetRewardRed = self:FindChild("root/Item1/Bottom/BtnGetReward/ImageRed")
	self.btnDayGetRewardGray = self:FindChild("root/Item1/Bottom/BtnGetReward/ImageGray02")
	self.btnDayGetRewardRed:SetActive(self.config.has_daily_reward)
	self.btnDayGetRewardGray:SetActive(not self.config.has_daily_reward)
	self:AddClick(self.btnDayGetReward, function()
			if self.config.has_daily_reward then
				self:ReqPoolReward(1)
			else
				ZTD.ViewManager.ShowTip(self.lan.noReward)
			end
		end)
	
    
	self.curDayPowerText = self:GetCmp("root/Item1/Top/TextCurAllPower", "Text")
	
	self.dayPoolText = self:GetCmp("root/Item1/Top/DayPool/Text", "Text")
	self.dayPoolText.text = FormatNum(self.curDayPool)
	
	self.rankDayMineText = self:GetCmp("root/Item1/Bottom/TextRankMine", "Text")
	self.powerDayMineText = self:GetCmp("root/Item1/Bottom/TextPowerMine", "Text")
	self.rewardDayMineText = self:GetCmp("root/Item1/Bottom/TextRewardMine", "Text")
	self.rewardFRTDayMineText = self:GetCmp("root/Item1/Bottom/TextRewardFRTMine", "Text")
	
	--滚动列表相关
	self.dayScrollCtr = self:FindChild("root/Item1/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.dayScrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)

		self:DayItemInit(tran,dataIndex,cellIndex)
	end)
end

--每日奖池玩法
function NFTView:DayItemInit(tran,dataIndex,cellIndex)
	dataIndex = dataIndex + 1
	tran:FindChild("ImageClick").onClick = nil
	if not self.dayRankList[dataIndex] then
		return
	end
	--最后一条数据，还有新的数据，go get it
	if not self.noMoreCurDayRankData and dataIndex == #self.dayRankList then
		self:ReqCurDayRank(dataIndex)
	end
	local data = self.dayRankList[dataIndex]
	
	data.rank = data.rank or 99
	local idx = 4
	if data.rank < 4 then
		idx = data.rank
	end
	local item
	for i=1, 4 do
		if i==idx then
			item = tran:FindChild("ImageRank" .. i)
			item:Show()
		else
			tran:FindChild("ImageRank" .. i):Hide()
		end
		
	end
	-- log(".==============  "..GC.uu.Dump(data))
	self:AddClick(tran:FindChild("ImageClick"), function()
		--ZTD.ViewManager.Open("ZTD_PlayerInfoView",data)
		self:ReqNFTUserInfo(data.uid)
	end)
	self:SetNodeText(item, "TextRank", data.rank)
	self:SetNodeText(item, "TextNick", data.name)
	self:SetNodeText(tran, "TextPower", FormatNum(data.power))
	
	self:SetNodeText(tran, "TextReward", FormatNum(data.prize.prize.gold or 0))
	self:SetNodeText(tran, "TextFRTReward", ZTD.Extend.FormatSpecNum((data.prize.prize.frt or 0)/1000000, 6))
end
--每日奖池玩法
function NFTView:OpenHelp(helpType, data)
    ZTD.ViewManager.OpenMessageBox("ZTD_NFTHelpView", helpType, data)
end
--每日奖池记录
function NFTView:OpenDayPoolRecord()
    ZTD.ViewManager.Open("ZTD_NFTDayRecordView")
end
--领取奖池奖金 2:赛季奖励， 1:每日奖励
function NFTView:ReqPoolReward(_type)
	
    ZTD.Request.HttpRequest("ReqPoolReward", {
		prize_type = _type
	}, function (data)
		GC.Sound.PlayEffect("ZTD_nftGet")
		if _type == 2 then
			self.config.has_season_reward = false
			self.btnSeasonGetRewardRed:Hide()
			self.btnSeasonGetRewardGray:Show()
			local tmp = {}
			tmp._type = 2
			-- tmp.gold = data.prize.gold or 0
			tmp.prize = data.prize
			if data.prize.frt and data.prize.frt > 0 then
				-- tmp.frt = data.prize.frt/1000000
				ZTD.NFTData.SetFRT(ZTD.NFTData.GetFRT()+data.prize.frt)
				self:OnRefreshFRT()
			end
			ZTD.ViewManager.Open("ZTD_NFTGetRewardView", tmp)
			self.seasonPoolRed:Hide()
		else
			self.config.has_daily_reward = false
			self.btnDayGetRewardRed:Hide()
			self.dayPoolRed:Hide()
			self.btnDayGetRewardGray:Show()
			local tmp = {}
			tmp._type = 1
			--tmp.gold = data.prize.gold or 0
			tmp.prize = data.prize
			if data.prize.frt and data.prize.frt > 0 then
				-- tmp.frt = data.prize.frt/1000000
				ZTD.NFTData.SetFRT(ZTD.NFTData.GetFRT()+data.prize.frt)
				self:OnRefreshFRT()
			end
			ZTD.ViewManager.Open("ZTD_NFTGetRewardView", tmp)
		end
			

	end, function (err)
		logError("ReqPoolReward error")
	end, true)
end

-----------------------今日奖池相关 结束-------------

---------------------------------分割线-----------------------------------------------------------------

-----------------------赛季奖池相关 开始-------------

--显示赛季奖池
function NFTView:ShowSeasonPool()
    --第一次做初始化
    if not self.firstShowSeasonPool then
		self.firstShowSeasonPool = true
		self:InitSeasonPool()
	end
	self.seasonScrollCtr:ClearAll()
	self.seasonScrollCtr:InitScroller(0)
	self:ReqCurSeasonRank( 0)
	self:ReqSeasonPool()

end


--赛季奖池滚动列表
function NFTView:SetSeasonPool(pool)
	self.seasonPool = pool
	if not self.curSeasonPool then
		self.curSeasonPool = pool
		self.seasonPoolText.text = FormatNum(math.floor(self.curSeasonPool))
		--return
	end
	if self.seasonPoolTimer then
		self:StopTimer("SeasonPool")
	end
	local interval = 0.1
	self.seasonPoolInterval = 0
	local delta = (self.seasonPool-self.curSeasonPool)/5*interval
	delta = delta < 1 and 1 or delta
	--奖池滚动
	self.seasonPoolTimer = self:StartTimer("SeasonPool", interval, function ()
		self.seasonPoolInterval = self.seasonPoolInterval + interval
		--120s请求一次数据
		if self.seasonPoolInterval > 10 then
			self.seasonPoolInterval = 0
			self:ReqSeasonPool()
		end
		if self.selectItem == 2 and self.curSeasonPool < self.seasonPool then
			self.curSeasonPool = self.curSeasonPool+delta
			self.seasonPoolText.text = FormatNum(math.floor(self.curSeasonPool))
		end
		
	end,10/interval+10)
	
end

function NFTView:SetMineSeasonRank(data)
	--print("SetMineSeasonRank start === ", data)
	local boxPanel = self:FindChild("root/Item2/Bottom/boxPanel")
	if tostring(data) == "userdata: NULL" or data.rank == 0 then
		self.rankSeasonMineText.text = self.lan.noRank
		self.powerSeasonMineText.text = 0
		self.rewardSeasonMineText.text = 0
		self:SetBoxInfo(boxPanel, {}, true)
		self:FindChild("root/Item2/Bottom/Top"):Hide()
	else
		self.rankSeasonMineText.text = data.rank
		self.powerSeasonMineText.text = FormatNum(data.power)
		local ratio = self:GetRatioByRank(data.rank)
		local str = FormatNum(data.prize.prize.gold or 0)--..string.format("(%.1f%%)",ratio)
		self.rewardSeasonMineText.text = str		
		self:SetBoxInfo(boxPanel, data.prize.prize, true)		
		if data.rank < 4 then
			self:FindChild("root/Item2/Bottom/Top"):Show()
			for i=1,3 do
				self:FindChild("root/Item2/Bottom/Top/Top"..i):SetActive(data.rank == i)
			end
		else
			self:FindChild("root/Item2/Bottom/Top"):Hide()
		end
	end
	LayoutRebuilder.ForceRebuildLayoutImmediate(boxPanel)
end
--分红比例
function NFTView:GetRatioByRank(rank)
	for _,v in ipairs(self.config.rank_prize) do
		if rank >= v.start_rank and rank <= v.end_rank then
			return v.ratio*100
		end
	end
	return 0
end
function NFTView:SetTop3(data)
	for _,v in ipairs(data) do
		local icon = self:FindChild("root/Item2/Top/Top"..v.rank.."/Mask/ImagePortrail")
		GC.SubGameInterface.SetHeadIcon(v.avatar, icon, v.uid)
		self:SetText("root/Item2/Top/Top"..v.rank.."/TextName", v.name)
		self:SetText("root/Item2/Top/Top"..v.rank.."/TextPower", 
		self.lan.power_..FormatNum(v.power))
			
		local ratio = v.prize.prize.gold / self.seasonPool * 100
		local str = FormatNum(v.prize.prize.gold or 0)--..string.format("(%.1f%%)",ratio)
		self:SetGoldPos(v.rank, str, tostring(v.prize.prize.gold or 0))
		self:SetText("root/Item2/Top/Top"..v.rank.."/goldPanel/TextReward", str)	
		self:FindChild("root/Item2/Top/Top"..v.rank.."/ImageClick").onClick = nil
		self:AddClick("root/Item2/Top/Top"..v.rank.."/ImageClick", function()
			--ZTD.ViewManager.Open("ZTD_PlayerInfoView")
			self:ReqNFTUserInfo(1)
		end)

	end

	for i = 1, 3 do
		local boxPanel = self:FindChild("root/Item2/Top/Top"..i.."/boxPanel")
		if data and data[i] then
			self:SetBoxInfo(boxPanel, data[i].prize.prize)
		else
			self:SetBoxInfo(boxPanel, {}, true)
			self:SetText("root/Item2/Top/Top"..i.."/TextName", "nick")
			self:SetText("root/Item2/Top/Top"..i.."/TextPower", self.lan.power_)
			self:SetGoldPos(i, "0", "0")
			self:SetText("root/Item2/Top/Top"..i.."/goldPanel/TextReward", "0")
			self:FindChild("root/Item2/Top/Top"..i.."/Mask/ImagePortrail"):GetComponent("Image").sprite = ResMgr.LoadAssetSprite("uiPrefab", "head_p_014")
			self:FindChild("root/Item2/Top/Top"..i.."/ImageClick").onClick = nil
		end
	end
end


function NFTView:SetGoldPos(iRank, str, sGold)
	-- 逗号的宽度不一样
	local width
	if #str > #sGold then
		width = (25 + (#sGold * 12.1) + ((#str - #sGold) * 3.3) ) / 2
	else
		width = (25 + #str * 12.1) / 2
	end
	self:FindChild("root/Item2/Top/Top"..iRank.."/goldPanel/Image").localPosition = Vector3(- width + 8, 0, 0)
	self:FindChild("root/Item2/Top/Top"..iRank.."/goldPanel/TextReward").localPosition = Vector3(- width + 23, 0, 0)
end

function NFTView:SetBoxInfo(boxPanel, data, bShow)
	for i = 1, #boxKindList do
		local box = boxPanel:GetChild(i - 1)
		if data and data[boxKindList[i]] then
			if i == 1 and not bShow then
				box:SetActive(data[boxKindList[i]] > 0)	
			elseif i == 2 and not bShow then
				box:SetActive(data[boxKindList[i]] > 0 or data[boxKindList[i - 1]] > 0)	
			end		
			box:GetComponent("RectTransform").sizeDelta = Vector2(data[boxKindList[i]] < 10 and 48 or 58, 30)
			box:FindChild("Text"):GetComponent("Text").text = string.format("X<color=#FFD306>%s</color>", data[boxKindList[i]])
		else
			box:SetActive(bShow)	
			box:GetComponent("RectTransform").sizeDelta = Vector2(58, 30)
			box:FindChild("Text"):GetComponent("Text").text = string.format("X<color=#FFD306>%s</color>", "00")
		end
	end
end


function NFTView:getChestSum(data,Ctype)

	if Ctype == 1 then
		local lvl1 = data/10000
		-- local lv12 = (data%10000)/100
		-- local lvl3 = data%100
		return math.floor(lvl1)
	elseif Ctype == 2 then
		local lv12 = (data%10000)/100
		return math.floor(lv12)
	elseif Ctype == 3 then
		local lvl3 = data%100
		return math.floor(lvl3)
	end
	return 0
end

function NFTView:DealSeasonRankData(data, reset)
	self:SetMineSeasonRank(data.my_record)
	self.seasonPool = data.season_info.total_pool
	--[[if data.season_info then
		self:SetSeasonPool(data.season_info.total_pool or 0)
	end--]]

	if not data.records or #data.records == 0 then
		return
	end
	if reset then--重新拉数据
		self.seasonRankList = table.copy(data.records)
		local top3 = {}
		for i=1,3 do
			if self.seasonRankList[1] then
				table.insert(top3,self.seasonRankList[1])
				table.remove(self.seasonRankList, 1)
			end
		end
		self:SetTop3(top3)
		self.seasonScrollCtr:ClearAll()
		if #self.seasonRankList > 0 then
			self.seasonScrollCtr:InitScroller(#self.seasonRankList)
		end
	else
		local oldIndex = #self.seasonRankList-2
		for _,v in ipairs(data.records) do
			table.insert(self.seasonRankList, v)
		end
		local progress = 1-self.seasonScrollCtr:GetComponent("ScrollRect").verticalNormalizedPosition
		self.seasonScrollCtr:RefreshScroller(#self.seasonRankList,progress)
		self.seasonScrollCtr.myScroller:JumpToDataIndex(oldIndex)
	end
end
--请求赛季奖池信息
--offset数据偏移量
function NFTView:ReqCurSeasonRank(offset)
	--每次拉取的数据量
	local count = 20
	offset = offset or 0
	ZTD.Request.HttpRequest("ReqCurSeasonRank", {
		page = {
			limit = count,
			offset = offset,
		}
	}, function (data)

		if not data.records or #data.records < count then
			--没有更多数据了，别拉了
			self.noMoreCurSeasonRankData = true
		else
			self.noMoreCurSeasonRankData = false
		end
		--print("========= DealSeasonRankData start ====")
		self:DealSeasonRankData(data, offset==0)

	end, function ()
		logError("ReqCurSeasonRank error")
	end, true)
end
--请求赛季奖池
function NFTView:ReqSeasonPool()
	ZTD.Request.HttpRequest("ReqSeasonPool", {
		
	}, function (data)
		
		self:SetSeasonPool(data.value)
	end, function ()
		logError("ReqSeasonPool error")
	end, false)
end

--首次打开初始化信息
function NFTView:InitSeasonPool()
	self.seasonPool = 0
	--print("NFTView:InitSeasonPool() === start")
    self:AddClick("root/Item2/Top/BtnSeasonRecord", function()
			self:OpenSeasonPoolRecord()
		end)
    self:AddClick("root/Item2/Top/BtnHelp", function()
			self:OpenHelp("seasonPool", self.config.rank_prize)
		end)
	
	self.btnSeasonGetReward = self:FindChild("root/Item2/Bottom/BtnGetReward")
	self.btnSeasonGetRewardRed = self:FindChild("root/Item2/Bottom/BtnGetReward/ImageRed")
	self.btnSeasonGetRewardGray = self:FindChild("root/Item2/Bottom/BtnGetReward/ImageGray02")
	self.btnSeasonGetRewardRed:SetActive(self.config.has_season_reward)
	self.btnSeasonGetRewardGray:SetActive(not self.config.has_season_reward)
	self:AddClick(self.btnSeasonGetReward, function()
			if self.config.has_season_reward then
				self:ReqPoolReward(2)
			else
				ZTD.ViewManager.ShowTip(self.lan.noReward)
			end
		end)
    
		
	self.seasonPoolText = self:GetCmp("root/Item2/Top/SeasonPool/Text", "Text")
	self.seasonPoolText.text = FormatNum(self.curSeasonPool)
	
	self.rankSeasonMineText = self:GetCmp("root/Item2/Bottom/TextRankMine", "Text")
	self.powerSeasonMineText = self:GetCmp("root/Item2/Bottom/TextPowerMine", "Text")
	self.rewardSeasonMineText = self:GetCmp("root/Item2/Bottom/TextRewardMine", "Text")
	self.rewardFRTSeasonMineText = self:GetCmp("root/Item2/Bottom/TextRewardFRTMine", "Text")
	
	--滚动列表相关
	self.seasonScrollCtr = self:FindChild("root/Item2/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.seasonScrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:SeasonItemInit(tran,dataIndex,cellIndex)
	end)
	
	self.btnTips3 = self:FindChild("root/Item2/Bottom/boxPanel/Panel3/btnTips3")
	self.btnTips2 = self:FindChild("root/Item2/Bottom/boxPanel/Panel2/btnTips2")
	self.btnTips1 = self:FindChild("root/Item2/Bottom/boxPanel/Panel1/btnTips1")
	self:AddClick(self.btnTips3, function()
		self:OnbtnchestTips(3)
	end)
	self:AddClick(self.btnTips2, function()
		self:OnbtnchestTips(2)
	end)
	self:AddClick(self.btnTips1, function()
		self:OnbtnchestTips(1)
	end)
	self:InitchestTips()
	self:OnbtnchestTips(-1)
	--print("NFTView:InitSeasonPool() === end")
end

--赛季奖池玩法
function NFTView:SeasonItemInit(tran,dataIndex,cellIndex)
	--print("=== NFTView:SeasonItemInit == ", dataIndex)
	dataIndex = dataIndex + 1
	tran:FindChild("ImageClick").onClick = nil
	if  not self.seasonRankList[dataIndex] then
		return
	end
	--最后一条数据，拉新的数据
	if not self.noMoreCurSeasonRankData and dataIndex == #self.seasonRankList then
		self:ReqCurSeasonRank(dataIndex + 3)
	end
	local data = self.seasonRankList[dataIndex]
	local idx = 4
	if data.rank < 4 then
		idx = data.rank
	end
	local item
	for i=1, 4 do
		if i==idx then
			item = tran:FindChild("ImageRank" .. i)
			item:Show()
		else
			tran:FindChild("ImageRank" .. i):Hide()
		end
	end
	self:AddClick(tran:FindChild("ImageClick"), function()
		--ZTD.ViewManager.Open("ZTD_PlayerInfoView")
		self:ReqNFTUserInfo(1)
	end)
	self:SetNodeText(item, "TextRank", data.rank)
	self:SetNodeText(item, "TextNick", data.name)
	self:SetNodeText(tran, "TextPower", FormatNum(data.power))
	local ratio = self:GetRatioByRank(data.rank)
	local str = FormatNum(data.prize.prize.gold or 0)
	self:SetNodeText(tran, "goldPanel/TextReward", str)
	local sGold = tostring(data.prize.prize.gold or 0)
	local width
	if #str > #sGold then
		width = (25 + (#sGold * 13.1) + ((#str - #sGold) * 4.4) ) / 2
	else
		width = (25 + #str * 13.1) / 2
	end
	tran:FindChild("goldPanel/Image").localPosition = Vector3(- width, 0, 0)
	tran:FindChild("goldPanel/TextReward").localPosition = Vector3(- width + 15, 0, 0)
	local prize = {
		box_gold = self:getChestSum(data.power,1),
		box_silver = self:getChestSum(data.power,2),
		box_copper = self:getChestSum(data.power,3),
	}
	self:SetBoxInfo(tran:FindChild("boxPanel"), prize)
end


--赛季奖池记录
function NFTView:OpenSeasonPoolRecord()
    ZTD.ViewManager.Open("ZTD_NFTSeasonRecordView", self.config)
end

--赛季宝箱内容提示
function NFTView:OnbtnchestTips(index) 
	--print("======== NFTView:OnbtnchestTips == ", index)
	if index > 0 and index < 4 then
		for i = 1, 3 do
			local chestTips02 = self:FindChild("root/Item2/Bottom/boxPanel/Panel"..i.."/chestTips"..i)
			if i ~= index then
				chestTips02:SetActive(false)
			end
		end
		local chestTips = self:FindChild("root/Item2/Bottom/boxPanel/Panel"..index.."/chestTips"..index)
		chestTips:SetActive(true)
		-- chestTips:Getcomponent("Button").interactable = false
		ZTD.GameTimer.DelayRun(5, function()
			self:OnSetChestTips(index,false)
		end)
	else
		for i = 1, 3 do
			local chestTips02 = self:FindChild("root/Item2/Bottom/boxPanel/Panel"..i.."/chestTips"..i)
			if chestTips02 then
				chestTips02:SetActive(false)
			end
		end
	end
end

function NFTView:OnSetChestTips(index, isActive) 
	--print("======== NFTView:OnSetChestTips == ", index)
	if index > 0 and index < 4 then
		local chestTips = self:FindChild("root/Item2/Bottom/boxPanel/Panel"..index.."/chestTips"..index)
		chestTips:SetActive(isActive)
		-- if isActive == false then
		-- 	chestTips:Getcomponent("Button").interactable = true
		-- end
	end
end

function NFTView:InitchestTips()
	--print("======== NFTView:InitchestTips")
	for i = 1, 3 do
		local TipsText = self:FindChild("root/Item2/Bottom/boxPanel/Panel"..i.."/chestTips"..i.."/Text")
		if i == 1 then 
			TipsText.text = self.lan.nftGoldChest
		elseif i == 2 then
			TipsText.text = self.lan.nftSilverChest
		elseif i == 3 then 
			TipsText.text = self.lan.nftBronzeChest
		end
	end
end


-----------------------赛季奖池相关 结束-------------

---------------------------------分割线-----------------------------------------------------------------

-----------------------我的卡包相关 开始-------------

--显示卡包
function NFTView:ShowPack()
    --第一次做初始化
    if not self.firstShowPack then
		self.firstShowPack = true
		self:InitPack()
	end
	ZTD.Flow.hasNewCard = false
	if not self.reqPack then
		self:ReqPack(function ()
			self:SetPack()
		end)
	else
		self:SetPack()
	end
	
end
--请求卡包
function NFTView:ReqPack(cb)
	ZTD.Request.HttpRequest("ReqPack", {
		
	}, function (data)
		ZTD.NFTData.RemoveAllCard()
		self.reqPack = true
		if tostring(data.Cards) ~= "userdata: NULL" then
			for _,v in pairs(data.Cards) do
				ZTD.NFTData.NewCard(v)
			end
		end
		if cb then
			cb()
		end
	end, function ()
		logError("ReqPack error")
	end, true)
end

--一键放入合成
function NFTView:OneKeySelect()
	if table.length(self.composeList) == 5 then
		return
	end
	local list = ZTD.NFTData.GetGradeCardList(self.curPackGrade)
	for i=#list, 1, -1 do
		if list[i].armPos > 0 then
			table.remove(list,i)
		end
	end

	for _,v in pairs(self.composeList) do
		for ii,vv in pairs(list) do
			if v == vv.id then
				table.remove(list,ii)
				break
			end
		end
	end
	for i=4,8 do
		if not self.composeList[i] and list[1] then
			local card = self:CreateNFTCard(list[1].id)
			self.cardPosList[i].SetCard(card)
			--card:SetParent(self.cardPosList[i].trans)
			card:ResetScale()
			self.composeList[i] = card.id
			table.remove(list,1)
		end
	end
	self:CheckComposeNum()
end
--检查合成卡的数量
function NFTView:CheckComposeNum()
	for _,item in pairs(self.packCardList) do
		for _,card in pairs(item) do
			local tag = false
			for _,id in pairs(self.composeList) do
				if id == card.id then
					tag = true 
					break
				end
			end
			card:SetComposed(tag)
		end
	end
	local grade
	for _,id in pairs(self.composeList) do
		local data = ZTD.NFTData.GetCard(id)
		grade = grade or data.grade
		if grade ~= data.grade then
			ZTD.ViewManager.ShowTip(self.lan["need5"])
			self.composeCost.text = 0
			self.composePower.text = 0
			self.btnComposeGray:Show()
			return
		end
	end

	if table.length(self.composeList) == 5  then
		local totalBasePower = 0
		local totalExPower = 0
		for _,v in pairs(self.composeList) do
			local data = ZTD.NFTData.GetCard(v)
			totalBasePower = totalBasePower + data.basePower
			totalExPower = totalExPower + data.exPower
		end
		local cost = ZTD.NFTConfig.CalComposeCost(self.curPackGrade, totalBasePower)
		self.composeCost.text = cost
		if self.curPackGrade < maxGrade then
			local cfg = ZTD.NFTConfig.GetGradeConfig(self.curPackGrade + 1)
			local str = string.format("%d ~ %d <color=#00ff2c>+%d</color>", 
				cfg.min_base_power, cfg.max_base_power, totalExPower)
			self.composePower.text = str
		end
		
		self.btnComposeGray:Hide()
	else
		self.composeCost.text = 0
		self.composePower.text = 0
		self.btnComposeGray:Show()
	end
end
--重置合成栏位
function NFTView:ResetComposePos()
	for i=4,8 do
		local card = self.cardPosList[i].card
		if card then
			self:RemoveNFTCard(card)
			self.cardPosList[i].SetCard()
		end
	end
	self.composeList = {}
	self.composeCost.text = 0
	self.composePower.text = 0
	self.btnComposeGray:Show()
	
end
--获得卡片
--_type 1合成  2洗练  3购买  4每日赠送
function NFTView:GetCard(id, _type, cb, data)
	ZTD.ViewManager.Open("ZTD_NFTGetCardView", id, _type, cb, data)
end
--合成成功
function NFTView:ComposeSuccess(data)
	if data.Balance then
		self:OnRefreshFRT(data.Balance)
	end
	
	ZTD.NFTData.NewCard(data.Result)
	for _,id in pairs(self.composeList) do
		ZTD.NFTData.RemoveCard(id)
	end
	self:ResetComposePos()

	self:GetCard(data.Result.ID, 1,function ()
		self:SetPackScroll(self.curPackGrade)
	end)
end
--合成
function NFTView:CheckReqCompose()
	if table.length(self.composeList) ~= 5 then
		ZTD.ViewManager.ShowTip(self.lan["need5"])
		return
	end
	local grade
	for _,id in pairs(self.composeList) do
		local data = ZTD.NFTData.GetCard(id)
		grade = grade or data.grade
		if grade ~= data.grade then
			ZTD.ViewManager.ShowTip(self.lan["need5"])
			self.composeCost.text = 0
			self.composePower.text = 0
			self.btnComposeGray:Show()
			return
		end
	end
	
	if self.curPackGrade == maxGrade then
		ZTD.ViewManager.ShowTip(self.lan["maxGrade"])
		return
	end

	if self:IsHaveBindingCard() then
		local confirmFunc = function()
			self:ReqCompose()
		end

		local cancelFunc = function()

		end
		ZTD.ViewManager.OpenExtenPopView(self.lan.hintBinding, confirmFunc, cancelFunc, self.lan.sure, self.lan.cancel, 220)
		return
	end

	self:ReqCompose()
end

function NFTView:ReqCompose()
	local list = {}
	for _,v in pairs(self.composeList) do
		table.insert(list, v)
	end
	ZTD.Request.HttpRequest("ReqCompose", {
		CardIds = list
	}, function (data)
		if data.Success then
			self:ComposeSuccess(data)
		else
			logError("ReqCompose Failed:" .. data.Success)
		end
	end, function ()
		logError("NFTCompose error")
	end, true)
end

function NFTView:IsHaveBindingCard()
	for _,id in pairs(self.composeList) do
		local data = ZTD.NFTData.GetCard(id)
		if data and data.status == 1 then
			return true
		end
	end
	return false
end


function NFTView:ArmSuccess()
	local oldArmedList = ZTD.NFTData.GetArmedList()
	for _,v in pairs(self.packCardList) do
		for _,card in ipairs(v) do
			for _,id in pairs(oldArmedList) do
				if card.id == id  then
					card:SetArmed(false)
				end
			end
		end
	end
	ZTD.NFTData.SetArmedList(self.armedList)
	
	for _,v in pairs(self.packCardList) do
		for _,card in ipairs(v) do
			for _,id in pairs(self.armedList) do
				if card.id == id  then
					card:SetArmed(true)
				end
			end
		end
	end
	local power = 0
	for _,id in pairs(self.armedList) do
		if "" ~= id  then
		local data = ZTD.NFTData.GetCard(id)
			power = power + data.power
		end
	end

	self.selfPowerText.text = FormatNum(power)
end
--

--请求服务器装备对应nft卡，装备栏位pos装备对应id卡片
function NFTView:ReqArm()
    ZTD.Request.HttpRequest("ReqArm", {
		CardIds = self.armedList,
	}, function (data)
		
		if data.Success then
			logError("ReqArm success")
			self:ArmSuccess()
			--self:RefreshPackScroll()
			GC.Sound.PlayEffect("ZTD_nftArm")
		else
			logError("ReqArm failed")
			self:SetPack()
		end
		
	end, function ()
		logError("ReqArm error")
		self:SetPack()
	end, true)
end

--拖拽卡片--1~3是装备栏  4~8是合成栏 9是新创建出来的卡片虚拟栏
function NFTView:DragCard(origin, target)
	if target == origin then
		target.card:SetPosition(Vector2.zero)
		target.card:SetParent(target.trans)
		target.card:ResetScale()
		return
	end
	local needReqArm = false
	--装备位，先下
	if origin.pos < 4 then
		self.armedList[origin.pos] = ""
		needReqArm = true
	end
		
	if target then
		
		if target.pos < 4 then
			self.armedList[target.pos] = origin.card.id
			needReqArm = true
		end
		--目标位置有卡，交换卡片
		if target.card then
			if origin.pos < 4 then
				self.armedList[origin.pos] = target.card.id
				needReqArm = true
			end--[[
			if target.pos < 9 then
				target.card:SetComposed(false)
			end--]]
			--9号位是新创建的卡片
			if origin.pos == 9 then
				self:RemoveNFTCard(target.card)
				target.SetCard(origin.card)
				origin.SetCard()
			else
				local card = origin.card
				origin.SetCard(target.card)
				target.SetCard(card) 
			end
		else
			
			target.SetCard(origin.card)
			origin.SetCard()
		end
	else
		--没有点中目标，释放卡片
		self:RemoveNFTCard(origin.card)
		origin.SetCard()
	end
	

	--合成列表
	self.composeList = {}
	for _,v in pairs(self.cardPosList) do
		if v.card and v.pos > 3 and v.pos < 9 then
			self.composeList[v.pos] = v.card.id
		end
	end
	if needReqArm then
		self:ReqArm()
	end
	
	self:CheckComposeNum()
end
--设置拖拽附着点事件
function NFTView:AddCardPosEvent(cardPos)
    
	self:AddOnDown(cardPos.trans, function (eventData)
		if not cardPos.card then return end
		cardPos.downPos = eventData.position
	end)
	self:AddOnDrag(cardPos.trans, function (eventData)
		if not cardPos.card then return end
		if cardPos.isDragging then 
			local pos = ZTD.MainScene.ScreenToUILocalPos(eventData.position)
			cardPos.card:SetPosition(pos)
			return
		else
			local dis = Vector2.Distance(cardPos.downPos, eventData.position)
			if dis > 0.5 then
				cardPos.isDragging = true
				local pos = ZTD.MainScene.ScreenToUILocalPos(eventData.position)
				
				cardPos.card:SetParent(self.nftCardParent)
				cardPos.card:SetScale(Vector3.one*0.5)
				cardPos.card:SetPosition(pos)
			end
		end
		
	end)
	self:AddOnUp(cardPos.trans, function (eventData)
		if not cardPos.card then return end
		--没有移动，就是点击效果
		if not cardPos.isDragging then
			if cardPos.pos < 4 then
				self:ShowEnhance(cardPos.card.id)
			end
			return
		end
		local origin = cardPos
		local target 
		local info = ZTD.MainScene.ScreenRayToWorld(eventData.position, 
			LayerMask.GetMask("layer20"))
		if info then
			for i,v in pairs(self.cardPosList) do
				if v.trans == info.transform then
					target = v
					break
				end
			end
		end
	
		self:DragCard(origin, target)
		
		cardPos.isDragging = false
	end)
end

--打开洗练面板
function NFTView:ShowEnhance(id)
	self.enhanceID = id
	local data = ZTD.NFTData.GetCard(id)
	self.btnArm:SetActive(data.armPos==0)
	self.btnUnArm:SetActive(data.armPos>0)
	self.enhanceCard = self:CreateNFTCard(id, self.enhancePanel:FindChild("Card"))
	--self.enhanceCard:SetParent(self.enhancePanel:FindChild("Card"))
	self.enhaneCurPower.text = data.power
	
	local cfg = ZTD.NFTConfig.GetGradeConfig(data.grade)
	self.enhaneCost.text = cfg.enhanceCost
	local str = [[<color=#D6DFF3>%d</color><color=#9FFF5F> +%d~%d</color>]]
	self.enhaneEnhancePower.text = string.format(str,
		data.power,cfg.min_enhancement_power,cfg.max_enhancement_power)
	self.enhancePanel:Show()
	self:CheckEnhanceMax()
end

--是否洗练最大
function NFTView:CheckEnhanceMax()
	local data = ZTD.NFTData.GetCard(self.enhanceID)
	local cfg = ZTD.NFTConfig.GetGradeConfig(data.grade)
	if data.exPower == cfg.exPowerMax then
		self.btnEnhanceGray:Show()
	else
		self.btnEnhanceGray:Hide()
	end
end
--隐藏洗练面板
function NFTView:HideEnhance()
	if self.enhanceCard then
		self:RemoveNFTCard(self.enhanceCard)
	end
	self.enhanceID = nil
	self.enhanceCard = nil
	self.enhancePanel:Hide()
end
--打开装备面板
function NFTView:ShowArmPanel(id)
	ZTD.ViewManager.Open("ZTD_NFTArmView", function (pos)
		--如果原来有卡先下
		if self.cardPosList[pos].card then
			self:RemoveNFTCard(self.cardPosList[pos].card)
		end
		self.armedList[pos] = id
		local card
		for i=4,8 do
			if self.cardPosList[i].card and 
			self.cardPosList[i].card.id == id then
				card = self.cardPosList[i].card
				self.cardPosList[i].SetCard()
				self.composeList[i] = nil
				break
			end
		end
		if not card then
			card = self:CreateNFTCard(id)
		else
			self:CheckComposeNum()
		end
		self.cardPosList[pos].SetCard(card)
		self:ReqArm()
	end)
end
--洗练成功
function NFTView:EnhanceSuccess(data)
	if data.Balance then
		self:OnRefreshFRT(data.Balance)
	end
	local power = data.Result.BasePower + data.Result.ExtendPower
	self.enhaneCurPower.text = power
	ZTD.NFTData.SetCardPower(data.Result.ID, data.Result.BasePower, data.Result.ExtendPower)
	local cfg = ZTD.NFTConfig.GetGradeConfig(ZTD.NFTData.GetCard(self.enhanceID).grade)
	local str = [[<color=#D6DFF3>%d</color><color=#9FFF5F> +%d~%d</color>]]
	self.enhaneEnhancePower.text = string.format(str,
		power,cfg.min_enhancement_power,cfg.max_enhancement_power)
	ZTD.ViewManager.ShowTip(self.lan.enhanceSuccess)
	self:CardPowerChange(data.Result.ID, power)
	--self:RefreshPackScroll()
	self:PlayEff("TD_Effect_qklpaiguang", self.enhanceCard.transform, 1)
	self:CheckEnhanceMax()
end

--洗练
function NFTView:ReqEnhance(id)
	if not self.enhanceID then
		return
	end
	GC.Sound.PlayEffect("ZTD_nftEnhance")
	ZTD.Request.HttpRequest("ReqEnhance", {
		CardId = self.enhanceID,
	}, function (data)
		if data.Success then
			self:EnhanceSuccess(data)
		else
			logError("Enhance Failed")
		end
		
	end, function ()
		logError("Enhance error")
	end, true)

	
end
--首次打开初始化信息
function NFTView:InitPack()
	
    self:AddClick("root/Item3/Compose/BtnOneKey", function()
			self:OneKeySelect()
		end)
	self.btnComposeGray = self:FindChild("root/Item3/Compose/BtnCompose/Gray")
    self:AddClick("root/Item3/Compose/BtnCompose", function()
			self:CheckReqCompose()
		end)
	 self:AddClick("root/Item3/Power/BtnHelp", function()
			self:OpenHelp("pack")
		end)	
	
    self:AddClick("root/Item3/EnhancePanel/BtnEnhance", function()
			self:ReqEnhance()
		end)
	self.btnArm = self:FindChild("root/Item3/EnhancePanel/BtnArm")
	self.btnUnArm = self:FindChild("root/Item3/EnhancePanel/BtnUnArm")
	self.btnEnhanceGray = self:FindChild("root/Item3/EnhancePanel/BtnEnhance/Gray")
    self:AddClick(self.btnArm, function()
			self:ShowArmPanel(self.enhanceID)
			self:HideEnhance()
		end)
    self:AddClick(self.btnUnArm, function()
			for pos,id in pairs(self.armedList) do
				if id == self.enhanceID then
					self.armedList[pos] = ""
					self:RemoveNFTCard(self.cardPosList[pos].card)
					self.cardPosList[pos].SetCard()
					break
				end	
			end
			self:ReqArm()
			self:HideEnhance()
		end)
    self:AddClick("root/Item3/EnhancePanel/Mask", function()
			self:HideEnhance()
		end)
    self:AddClick("root/Item3/EnhancePanel/BtnClose", function()
			self:HideEnhance()
		end)

	for i=1, maxGrade do
		self["packGradeSelected" .. i] = self:FindChild("root/Item3/Grade/GradePanel/BtnGrade"..i.."/ImageSelected")
		self:AddClick("root/Item3/Grade/GradePanel/BtnGrade"..i, function()
			self:ResetComposePos()
			self:SetPackScroll(i)
		end)
	end
		
	--拖拽附着点
	self.cardPosList = {}
	--1~3是装备栏  4~8是合成栏 9是新创建出来的卡片虚拟栏
	for i=1,8 do
		local tmp = {}
		tmp.trans = self:FindChild("root/Item3/CardPos/Card" .. i)
		--附着的card 
		tmp.SetCard = function (nftcard)
			tmp.card = nftcard
			
			if nftcard then
				nftcard:SetParent(tmp.trans)
				nftcard:ResetScale()
				if tmp.pos < 4 then
					nftcard:SetCameraSize(5)
				else
					nftcard:SetCameraSize(3)
				end
			end
		end
		--tmp.card = nil
		tmp.pos = i
		self.cardPosList[i] = tmp
		self:AddCardPosEvent(tmp)
	end

	self.selfPowerText = self:GetCmp("root/Item3/Power/TextSelfPower", "Text")
	self.composeCost = self:GetCmp("root/Item3/Compose/BtnCompose/TextCost", "Text")
	self.composePower = self:GetCmp("root/Item3/Compose/TextComposePower", "Text")
	self.enhancePanel = self:FindChild("root/Item3/EnhancePanel")
	self.enhaneCost = self:GetCmp("root/Item3/EnhancePanel/FRTCost/Text", "Text")
	self.enhaneCurPower = self:GetCmp("root/Item3/EnhancePanel/TextCurPower", "Text")
	self.enhaneEnhancePower = self:GetCmp("root/Item3/EnhancePanel/TextEnhancePower", "Text")
	
	--滚动列表相关
	self.packScrollCtr = self:FindChild("root/Item3/Grade/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.packScrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:PackItemInit(tran,dataIndex,cellIndex)
	end)

	self.packList = {}
	self.packCardList = {}
	self.composeList = {}
	--self:SetPackScroll(1)

end

--清空背包
function NFTView:ClearAllPackCard()
	for tran,v in pairs(self.packCardList) do
		for i=#v, 1, -1 do
			self:RemoveNFTCard(v[i])
			table.remove(v, i)
		end
		
	end
	self.packCardList = {}
end
--设置背包滚动列表
function NFTView:PackItemInit(tran,dataIndex,cellIndex)
	
	if not self.packList[dataIndex*3+1] then
		return
	end

	if self.packCardList[tran] and #self.packCardList[tran] > 0 then
		for i=#self.packCardList[tran], 1, -1 do
			self:RemoveNFTCard(self.packCardList[tran][i])
		end
	end
	self.packCardList[tran] = {}
	for i=1,3 do
		local data = self.packList[dataIndex*3 + i]
		if data then
			local card = tran:FindChild("Card" .. i)
			local nftcard = self:CreateNFTCard(data.id, card)
			nftcard:SetArmed(nftcard:IsArmed())
			--nftcard:SetParent(card)
			nftcard:SetScale(Vector3.one*0.6)
			nftcard:SetCameraSize(3)
			table.insert(self.packCardList[tran], nftcard)
			--[[
			for i=1,maxGrade do
				card:FindChild("Grade"..i):SetActive(i==data.grade)
			end
			self:SetNodeText(card, "TextPower", data.power)
			card:FindChild("ImageArmed"):SetActive(data.armPos > 0)--]]
			--点击事件
			self:AddClick(card, function (eventData)
				self:ShowEnhance(data.id)
			end)
			local script = card:GetComponent("DragEx")
			script.func1 = function ()
				self.packScrollDownPos = Input.mousePosition
			end
			script.func2 = function ()
				if self.packScrollDragging then 
					local pos = ZTD.MainScene.ScreenToUILocalPos(Input.mousePosition)
					self.packScrollCardPos.card:SetPosition(pos)
					return
				else
				--横向移动超过一定距离视为拖拽
					local vec = self.packScrollDownPos - Input.mousePosition
					if vec.x > 40 then
						
						self.packScrollDragging = true
						local tmp
						for i=1,8 do
							if self.cardPosList[i].card and self.cardPosList[i].card.id == data.id then
								tmp = self.cardPosList[i]
								break
							end
						end
						
						if tmp then
							if tmp.pos > 3 then
								local tmp1 = {}
								tmp1.trans = tran
								--附着的card 
								tmp1.SetCard = function (card)
									tmp1.card = card
								end
								tmp1.pos = 9
								self.cardPosList[9] = tmp1
								tmp1.SetCard(tmp.card)
								tmp.SetCard()
								self.packScrollCardPos = tmp1
								
							else
								self.packScrollCardPos = tmp
							end
							
						else
							tmp = {}
							tmp.trans = tran
							--附着的card 
							tmp.SetCard = function (card)
								tmp.card = card
							end
							local card = self:CreateNFTCard(data.id)
							tmp.pos = 9
							self.cardPosList[9] = tmp
							tmp.SetCard(card)
							self.packScrollCardPos = tmp
						end
						
						self.packScrollCardPos.card:SetParent(self.nftCardParent)
						self.packScrollCardPos.card:SetScale(Vector3.one*0.5)
						local pos = ZTD.MainScene.ScreenToUILocalPos(Input.mousePosition)
						self.packScrollCardPos.card:SetPosition(pos)
					end
				end
			end
			script.func3 = function (eventData)
				--没有拖拽且位移量小，就是点击
				if not self.packScrollCardPos then
					--[[local dis = Vector2.Distance(self.packScrollDownPos, Input.mousePosition)
					if dis < 30 then
						self:ShowEnhance(data.id)
					end--]]
					return
				end
				
				local origin = self.packScrollCardPos
				local target 
				local info = ZTD.MainScene.ScreenRayToWorld(Input.mousePosition, 
					LayerMask.GetMask("layer20"))
				if info then
					for i,v in pairs(self.cardPosList) do
						if v.trans == info.transform then
							target = v
							break
						end
					end
				end
				--点中目标
				--if target then
					self:DragCard(origin, target)
				--else--没有点中目标，释放卡片
					--[[self:RemoveNFTCard(self.packScrollCardPos.card)
					self.packScrollCardPos.SetCard(nil)
				end--]]
				self.packScrollCardPos = nil
				self.packScrollDragging = false
			end
		
		else
			--tran:FindChild("Card"..i):Hide()
		end
	end
	
end
--设置背包滚动列表
function NFTView:SetPackScroll(grade)
	for i=1,maxGrade do
		self["packGradeSelected" .. i]:SetActive(i==grade)
	end
	self.curPackGrade = grade
	self:ClearAllPackCard()
	self.packScrollCtr:ClearAll()
	self.packList = ZTD.NFTData.GetGradeCardList(grade)
	self.packScrollCtr:InitScroller(math.ceil(#self.packList/3))
end


--设置装备卡片
function NFTView:SetArmedCard()
	self.armedList = ZTD.NFTData.GetArmedList()
	
	for i=1,3 do
		if self.cardPosList[i].card then
			self:RemoveNFTCard(self.cardPosList[i].card)
			self.cardPosList[i].SetCard()
		end
	end
	local power = 0
	for pos,id in pairs(self.armedList) do
		if id ~= "" then
			local nftcard = self:CreateNFTCard(id, self.cardPosList[pos].trans)
			self.cardPosList[pos].card = nftcard
			--nftcard:SetParent(self.cardPosList[pos].trans)
			--nftcard:ResetScale()
			power = power + nftcard.data.power
			--self.cardPosList[pos]:SetCard(card)
		end
	end
	
	self.selfPowerText.text = FormatNum(power)
end
--设置背包
function NFTView:SetPack()
	self.packRed:Hide()
	self:ResetComposePos()
	self:SetArmedCard()
	local grade = maxGrade
	for i=maxGrade, 1, -1 do
		local list = ZTD.NFTData.GetGradeCardList(i)
		if #list > 0 then
			grade = i
			break
		end
	end
	self:SetPackScroll(grade)
end

-----------------------我的卡包相关 结束-------------

---------------------------------分割线-----------------------------------------------------------------

-----------------------交易所相关 开始-------------

--显示交易所
function NFTView:ShowMarket()
    --第一次做初始化
    if not self.firstShowMarket then
		self.firstShowMarket = true
		self:InitMarket()
	end
	
	self:SelectMarketItem(1)
	
end

--首次打开初始化信息
function NFTView:InitMarket()
	self.marketItemList = {}
	self.sellingItemList = {}
	for i=1,3 do
		self["marketItem"..i] = self:FindChild("root/Item4/Item"..i)
	end
	
    for i=1,3 do
		self:AddClick("root/Item4/BtnItem"..i, function()
			self:SelectMarketItem(i)
		end)
	end
   
	self:AddClick("root/Item4/Item1/Top/BtnRefresh", function()
		self:ReqMarket(0)
	end)
	self.marketDrop = self:GetCmp("root/Item4/Item1/Top/Dropdown","Dropdown")

	local op = OptionData.New(self.lan.allCard)
	self.marketDrop.options:Add(op)
	for i=maxGrade,1,-1 do
		local op = OptionData.New(string.format(self.lan.gradeCard, i))
		self.marketDrop.options:Add(op)
	end
	self.marketDrop:RefreshShownValue()
	self.marketGrade = 0
	local grade = {0,6,5,4,3,2,1}
	UIEvent.AddDropdownValueChange(self:FindChild("root/Item4/Item1/Top/Dropdown"), function (val)
		--if not self.marketGrade == tonumber(val) then
			self.marketGrade = grade[tonumber(val)+1]
			self:ReqMarket(0)
		--end
	end)
	self.marketScrollCtr = self:FindChild("root/Item4/Item1/Top/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.marketScrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:MarketItemInit(tran,dataIndex,cellIndex)
	end)
	
	self.taxText = self:FindChild("root/Item4/TextTax")
	
	--寄售相关
	for i=1,maxGrade do
		self["sellScrollItem"..i] = self:FindChild("root/Item4/Item2/Left/BtnGrade"..i.."/ImageSelected")
		self:AddClick("root/Item4/Item2/Left/BtnGrade"..i, function()
			self:SetSellScroll(i)
		end)
	end
	self.sellPriceList = {}
	
	self.imgSellCard = self:FindChild("root/Item4/Item2/Right/Card")
	self.performText = self:FindChild("root/Item4/Item2/Right/TextPerform")
	self.sellInputField = self:GetCmp("root/Item4/Item2/Right/InputField", "InputField")
	self.performText.text = string.format(self.lan.curPerform, 0)
	self.sellPrice = 0
	UIEvent.AddInputFieldOnEndEdit(self:FindChild("root/Item4/Item2/Right/InputField"),
	function (val)
		
		if val == "" or tonumber(val) < 0.01 or tonumber(val) > 100000000 then
			ZTD.ViewManager.ShowTip(self.lan.illegalPrice)
			self.sellPrice = 0
			self.sellInputField.text = 0
			return
		end
		if not self.selectSellCard then
			--ZTD.ViewManager.ShowTip(self.lan.noSelectCard)
			return
		end
		val = string.format("%.2f", tonumber(val))
		self.sellPrice = tonumber(val)
		self.sellInputField.text = tonumber(val)
		self.sellPriceList[self.selectSellCard.id] = tonumber(val)
		local perform = self.selectSellCard.data.power/val*10
		self.performText.text = string.format(self.lan.curPerform, perform)
	end)
	self:AddClick("root/Item4/Item2/Right/BtnSell", function()
		self:ReqSellCard()
	end)
	self.sellScrollCtr = self:FindChild("root/Item4/Item2/Left/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.sellScrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:SellItemInit(tran,dataIndex,cellIndex)
	end)
	self.curSellIdx = 5
	self.sellCardList = {}
	
	--在售相关
	self:AddClick("root/Item4/Item3/BtnSellRecord", function()
		self:OpenSellRecord()
	end)
	self.sellingScrollCtr = self:FindChild("root/Item4/Item3/CustomScroll/Scroller"):GetComponent("ScrollerController")
	self.sellingScrollCtr:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:SellingItemInit(tran,dataIndex,cellIndex)
	end)
	self.sellingList = {}
end

--
function NFTView:MarketItemInit(tran,dataIndex,cellIndex)
	--最后一条数据，还有新的数据，go get it
	
	if not self.noMoreShopData and (dataIndex*2+2) >= #self.marketList then
		self:ReqMarket(dataIndex*2+2)
	end
	if not self.marketList[dataIndex*2+1] then
		return
	end
	if self.marketItemList[tran] and #self.marketItemList[tran] > 0 then
		for i=#self.marketItemList[tran], 1, -1 do
			local tab = self.marketItemList[tran][i]
			ZTD.PoolManager.RemoveGameItem(tab.modelName, tab.model)
			--GameObject.Destroy(tab.renderTexture)
		end
	end
	self.marketItemList[tran] = {}
	for i=1, 2 do
		local data = self.marketList[dataIndex*2+i]
		if data then
			tran:FindChild("Item"..i):Show()
			for j=1,maxGrade do
				tran:FindChild("Item"..i.."/Card/Grade"..j):SetActive(data.Quality==j)
			end
			--模型显示相关
			local cfg = ZTD.NFTConfig.GetGradeConfig(data.Quality)
			local enmeyRoot = tran:FindChild("Item"..i.."/Card/CameraRoot/Camera/EnemyRoot")

			local cameraTran = tran:FindChild("Item"..i.."/Card/CameraRoot")
			cameraTran.transform.position = Vector3(0,ZTD.Flow.cameraIdx*2000,0)
			ZTD.Flow.cameraIdx = ZTD.Flow.cameraIdx + 1
			if ZTD.Flow.cameraIdx > ZTD.Flow.maxIdx then
				ZTD.Flow.cameraIdx = 1
			end
			local camera = tran:FindChild("Item"..i.."/Card/CameraRoot/Camera"):GetComponent("Camera")
			if not camera.targetTexture then
				camera.targetTexture = UnityEngine.RenderTexture(215,263,1)
				local monsterImage = tran:FindChild("Item"..i.."/Card/BG/MonsterShow"):GetComponent("RawImage")
				monsterImage.texture = camera.targetTexture
				monsterImage.gameObject:SetActive(true)
			end
			local monsterModel = ZTD.PoolManager.GetGameItem(cfg.modelName)
			monsterModel:SetParent(enmeyRoot)
			monsterModel.localPosition = cfg.modelPos
			monsterModel.localRotation = Quaternion.Euler(cfg.modelRot.x,cfg.modelRot.y,cfg.modelRot.z)
			monsterModel.localScale = cfg.modelScale
			local animator = monsterModel:GetComponentInChildren(typeof(UnityEngine.Animator))
			animator.speed = math.random(80,120)/100
			
			local tab = {}
			tab.model = monsterModel
			tab.modelName = cfg.modelName
			tab.renderTexture = camera.targetTexture
			table.insert(self.marketItemList[tran], tab)
			
			
			for j=1,maxGrade do
				tran:FindChild("Item"..i.."/Grade/Grade"..j):SetActive(data.Quality>=j)
			end
			
			
			local power = data.BasePower+data.ExtendPower
			self:SetNodeText(tran,"Item"..i.."/TextPower",power)
			local str =string.format("%d<color=#00ff2c>+%d</color>",
				data.BasePower, data.ExtendPower)
			self:SetNodeText(tran,"Item"..i.."/TextExPower",str)
			self:SetNodeText(tran,"Item"..i.."/TextPerform",string.format("%.2f%%", power/data.Price*10*1000000))
			local tempPrice = data.Price/1000000
			if self.config.fee and self.config.fee ~= nil and self.config.fee > 0 then
				tempPrice = tempPrice * (1+self.config.fee/100)
			end
			self:SetNodeText(tran,"Item"..i.."/TextPrice",tempPrice)
			if data.Uid == ZTD.PlayerData.GetPlayerId() then
				tran:FindChild("Item"..i.."/BtnBuy"):Hide()
				tran:FindChild("Item"..i.."/TextSelling"):Show()
			else
				tran:FindChild("Item"..i.."/BtnBuy"):Show()
				tran:FindChild("Item"..i.."/TextSelling"):Hide()
				self:AddClick(tran:FindChild("Item"..i.."/BtnBuy"), function ()
					if data.Price >= 100000000 then
						ZTD.ViewManager.Open("ZTD_NFTBuyConfirmView",{
								id = data.Id,
								power = power,
								basePower = data.BasePower,
								exPower = data.ExtendPower,
								price = data.Price/1000000,
								grade = data.Quality,
								armPos = 0
							},function (isSure)
								if isSure then
									self:ReqBuyCard(data.Id)
								end
								
							end)
					else
						self:ReqBuyCard(data.Id)
					end
					
				end)
			end
			
		else
			tran:FindChild("Item"..i):Hide()
		end
	end

end
--清空
function NFTView:ClearAllSellCard()
	for tran,v in pairs(self.sellCardList) do
		for i=#v, 1, -1 do
			self:RemoveNFTCard(v[i])
			table.remove(v, i)
		end
		
	end
	self.sellCardList = {}
end


function NFTView:SellItemInit(tran,dataIndex,cellIndex)

	if not self.sellList[dataIndex*5+1] then
		return
	end
	if self.sellCardList[tran] and #self.sellCardList[tran] > 0 then
		for i=#self.sellCardList[tran], 1, -1 do
			self:RemoveNFTCard(self.sellCardList[tran][i])
		end
	end
	self.sellCardList[tran] = {}
	for i=1,5 do
		local data = self.sellList[dataIndex*5 + i]
		if data then
			
			local card = tran:FindChild("Card" .. i)
			
			card:Show()
			local nftcard = self:CreateNFTCard(data.id, card)
			nftcard:SetCameraSize(3)
			table.insert(self.sellCardList[tran], nftcard)
			
			--点击事件
			self:AddClick(card, function ()
				if nftcard:IsArmed() then
					ZTD.ViewManager.ShowTip(self.lan.armedCannotSell)
					return
				end

				if nftcard:IsBinDing() then
					ZTD.ViewManager.ShowTip(self.lan.noSellBinding)
					return
				end

				if self.selectSellItem ~= nil then
					self.selectSellItem:SetSelected(false)
				end
				self.selectSellItem = nftcard
				self.selectSellItem:SetSelected(true)
				if self.selectSellCard ~= nil then
					self:RemoveNFTCard(self.selectSellCard)
				end
				self.selectSellCard = self:CreateNFTCard(data.id, self.imgSellCard)
			
				if self.sellPriceList[self.selectSellCard.id] then
					self.sellInputField.text = self.sellPriceList[self.selectSellCard.id]
					self.sellPrice = self.sellPriceList[self.selectSellCard.id]
				else
					self.sellInputField.text = 0
					self.sellPrice = 0
				end
			end)
		
		else
			tran:FindChild("Card"..i):Hide()
		end
	end
end
--
function NFTView:SellingItemInit(tran,dataIndex,cellIndex)
	if not self.sellingList[dataIndex*2+1] then
		return
	end
	if self.sellingItemList[tran] and #self.sellingItemList[tran] > 0 then
		for i=#self.sellingItemList[tran], 1, -1 do
			local tab = self.sellingItemList[tran][i]
			ZTD.PoolManager.RemoveGameItem(tab.modelName, tab.model)
			--GameObject.Destroy(tab.renderTexture)
		end
	end
	self.sellingItemList[tran] = {}
	for i=1, 2 do
		local data = self.sellingList[dataIndex*2+i]
		if data then
			tran:FindChild("Item"..i):Show()
			for j=1,maxGrade do
				tran:FindChild("Item"..i.."/Card/Grade"..j):SetActive(data.Quality==j)
			end
			for j=1,maxGrade do
				tran:FindChild("Item"..i.."/Grade/Grade"..j):SetActive(data.Quality>=j)
			end
			
			--模型显示相关
			local cfg = ZTD.NFTConfig.GetGradeConfig(data.Quality)
			local enmeyRoot = tran:FindChild("Item"..i.."/Card/CameraRoot/Camera/EnemyRoot")

			local cameraTran = tran:FindChild("Item"..i.."/Card/CameraRoot")
			cameraTran.transform.position = Vector3(0,ZTD.Flow.cameraIdx*2000,0)
			ZTD.Flow.cameraIdx = ZTD.Flow.cameraIdx + 1
			if ZTD.Flow.cameraIdx > ZTD.Flow.maxIdx then
				ZTD.Flow.cameraIdx = 1
			end
			local camera = tran:FindChild("Item"..i.."/Card/CameraRoot/Camera"):GetComponent("Camera")
			if not camera.targetTexture then
				camera.targetTexture = UnityEngine.RenderTexture(215,263,1)
				local monsterImage = tran:FindChild("Item"..i.."/Card/BG/MonsterShow"):GetComponent("RawImage")
				monsterImage.texture = camera.targetTexture
				monsterImage.gameObject:SetActive(true)
			end
			
	
			local monsterModel = ZTD.PoolManager.GetGameItem(cfg.modelName)
			monsterModel:SetParent(enmeyRoot)
			monsterModel.localPosition = cfg.modelPos
			monsterModel.localRotation = Quaternion.Euler(cfg.modelRot.x,cfg.modelRot.y,cfg.modelRot.z)
			monsterModel.localScale = cfg.modelScale
			local animator = monsterModel:GetComponentInChildren(typeof(UnityEngine.Animator))
			animator.speed = math.random(80,120)/100
			
			local tab = {}
			tab.model = monsterModel
			tab.modelName = cfg.modelName
			tab.renderTexture = camera.targetTexture
			table.insert(self.sellingItemList[tran], tab)
			
			
			local power = data.BasePower+data.ExtendPower
			self:SetNodeText(tran,"Item"..i.."/TextPower",power)
			local str =string.format("%d<color=#00ff2c>+%d</color>",
				data.BasePower, data.ExtendPower)
			self:SetNodeText(tran,"Item"..i.."/TextExPower",str)
			self:SetNodeText(tran,"Item"..i.."/TextPerform",string.format("%.2f%%", power/data.Price*10*1000000))
			self:SetNodeText(tran,"Item"..i.."/TextPrice",data.Price/1000000)
			self:AddClick(tran:FindChild("Item"..i.."/BtnCancel"), function ()
				self:ReqCancelSell(data.Id)
			end)
		else
			tran:FindChild("Item"..i):Hide()
		end
	end
end
--打开出售记录
function NFTView:OpenSellRecord()
	ZTD.ViewManager.Open("ZTD_NFTSellRecordView")
end
--清除市场滚动列表
function NFTView:ClearMarketScroll()
	if not self.marketItemList then
		return
	end
	for _,item in pairs(self.marketItemList) do
		if #item > 0 then
			for i=#item, 1, -1 do
				local tab = item[i]
				ZTD.PoolManager.RemoveGameItem(tab.modelName, tab.model)
				--GameObject.Destroy(tab.renderTexture)
			end
		end
	end
	
	self.marketScrollCtr:ClearAll()
end
--清除市场滚动列表
function NFTView:ClearSellingScroll()
	if not self.sellingItemList then
		return
	end
	for _,item in pairs(self.sellingItemList) do
		if #item > 0 then
			for i=#item, 1, -1 do
				local tab = item[i]
				ZTD.PoolManager.RemoveGameItem(tab.modelName, tab.model)
				--GameObject.Destroy(tab.renderTexture)
			end
		end
	end

	self.sellingScrollCtr:ClearAll()
end
--
function NFTView:DealMarketData(data, reset)

	if not data.fee or data.fee == 0 then
		self.taxText.text = self.lan.tradeFree
	else
		self.taxText.text = string.format(self.lan.tradeTax, data.fee/100)
	end

	
	if not data.ShopArray or #data.ShopArray == 0 then
		self.marketList = {}
		self:ClearMarketScroll()
		self.marketScrollCtr:InitScroller(0)
		return
	end
	if reset then--重新拉数据
		self.marketList = table.copy(data.ShopArray)
		self:ClearMarketScroll()
		if #self.marketList > 0 then
			self.marketScrollCtr:InitScroller(math.ceil(#self.marketList/2))
		end
	else
		local oldIndex = math.floor(#self.marketList/2)-3
		oldIndex = oldIndex > 0 and oldIndex or 0
		for _,v in ipairs(data.ShopArray) do
			table.insert(self.marketList, v)
		end
		local progress = 1-self.marketScrollCtr:GetComponent("ScrollRect").verticalNormalizedPosition

		self.marketScrollCtr:RefreshScroller(math.ceil(#self.marketList/2),progress)
		self.marketScrollCtr.myScroller:JumpToDataIndex(oldIndex-3)
	end
	
end
--请求在售商品数据
--type 请求类型0默认排序（依据上架时间）1品质降序，2品质升序 3算力降序序， 4算力升序，5价格降序，6价格升序
--page 页面
function NFTView:ReqMarket(offset)
	local count = 20
	offset = offset or 0
	ZTD.Request.HttpRequest("ReqMarket", {
		SeasonId = self.config.season_id,
		Limit = count,
		Offset = offset,
		Quality = self.marketGrade or 0,
	}, function (data)
		
		if not data.ShopArray or #data.ShopArray < count then
			--没有更多数据了，别拉了
			self.noMoreShopData = true
		else
			self.noMoreShopData = false
		end
		self:DealMarketData(data, offset==0)
		
	end, function ()
		logError("CSReqMarket error")
	end, true)
end
--通过商品id获取对应商品
function NFTView:GetShop(id)
	for _,v in pairs(self.marketList) do
		if v.Id == id then
			return v
		end
	end
end
--购买指定卡片
function NFTView:ReqBuyCard(id)
	ZTD.Request.HttpRequest("ReqBuyCard", {
		ID = id,
	}, function (data)
		
		local shop = self:GetShop(id)
		ZTD.NFTData.NewCard({
			ID = shop.CardId,
			BasePower = shop.BasePower,
			ExtendPower = shop.ExtendPower,
			Quality = shop.Quality,
			Equip = 0
		})
		self:GetCard(shop.CardId, 3)
		ZTD.NFTData.SetFRT(data.LeftFrt)
		self:OnRefreshFRT()
		self:ReqMarket()
	end, function ()
		logError("BuyCard error")
		self:ReqMarket()
	end, true)
end
--出售指定卡片
function NFTView:ReqSellCard()
	if not self.selectSellCard then
		--ZTD.ViewManager.ShowTip(self.lan.noSelectCard)
		return
	end
	if not self.sellPrice or self.sellPrice <= 0 then
		ZTD.ViewManager.ShowTip(self.lan.illegalPrice)
		return
	end
	ZTD.Request.HttpRequest("ReqSellCard", {
		Price = self.sellPrice,
		CardId = self.selectSellCard.data.id,
	}, function (data)
		
		if data.Success then
			ZTD.ViewManager.ShowTip(self.lan.reqSellSuccess)
			ZTD.NFTData.RemoveCard(self.selectSellCard.data.id)
			self:RemoveNFTCard(self.selectSellCard)
			self.selectSellCard = nil
			self.selectSellItem = nil
			self:SetSellScroll()
		else
			ZTD.ViewManager.ShowTip(self.lan.reqFailed)
		end
	end, function ()
		logError("ReqSellCard error")
	end, true)
end

function NFTView:ReqCancelSell(id)
	ZTD.Request.HttpRequest("ReqCancelSell", {
		ID = id
	}, function (data)
		
		for i,v in pairs(self.sellingList) do
			if v.Id == id then
				
				ZTD.NFTData.NewCard({
					ID = v.CardId,
					BasePower = v.BasePower,
					ExtendPower = v.ExtendPower,
					Quality = v.Quality,
					Equip = 0
				})
				table.remove(self.sellingList, i)
				break
			end
		end
		self:ClearSellingScroll()
		self.sellingScrollCtr:InitScroller(math.ceil(#self.sellingList/2))
	end, function ()
		logError("ReqCancelSell error")
	end, true)
end
--
function NFTView:DealSellingData(data, reset)
	if not data.ShopArray or #data.ShopArray == 0 then
		return
	end
	
	self:ClearSellingScroll()
	self.sellingList = table.copy(data.ShopArray)
	if #self.sellingList > 0 then
		
		local count = math.ceil(#self.sellingList/2)
		self.sellingScrollCtr:InitScroller(count)
	end

end
function NFTView:ReqSellingData()
	ZTD.Request.HttpRequest("ReqSellingData", {
		
	}, function (data)
		
		self:DealSellingData(data)
		
	end, function ()
		logError("ReqSellingData error")
	end, true)
end

function NFTView:SetSellScroll(idx)
	self:ClearAllSellCard()
	self.curSellIdx = idx or self.curSellIdx
	for i=1,maxGrade do
		self["sellScrollItem"..i]:SetActive(self.curSellIdx==i)
	end
	
	self.sellList = ZTD.NFTData.GetGradeCardList(self.curSellIdx)
	for i=#self.sellList, 1, -1 do
		if self.sellList[i].armPos > 0 or self.sellList[i].status == 1 then
			table.remove(self.sellList, i)
		end
	end

	self.sellScrollCtr:ClearAll()
	self.sellScrollCtr:InitScroller(math.ceil(#self.sellList/5))
	if self.selectSellCard then
		self:RemoveNFTCard(self.selectSellCard)
		self.selectSellCard = nil
		self.selectSellItem = nil
	end
end

function NFTView:SelectMarketItem(idx)
	for i=1, 3 do
		self:FindChild("root/Item4/BtnItem"..i.."/ImageSelected"):SetActive(i==idx)
		self["marketItem"..i]:SetActive(i==idx)
	end
	--在售列表需要拉数据
	if idx == 3 then
		self:ClearSellingScroll()
		self:ReqSellingData()
	elseif idx == 1 then
		self:ClearMarketScroll()
		self:ReqMarket(0)
	elseif idx == 2 then
		local function cb()
			local grade = maxGrade
			for i=maxGrade, 1, -1 do
				local list = ZTD.NFTData.GetGradeCardList(i)
				local tag
				for j=#list,1,-1 do
					if list[j].armPos == 0 then
						tag = true
						break
					end
				end
				if tag then
					grade = i
					break
				end
			end
			self:SetSellScroll(grade)
		end
		if not self.reqPack then
			self:ReqPack(cb)
		else
			cb()
		end
	end
end

-----------------------交易所相关 结束-------------




function NFTView:OnDestroy()
	ZTD.Notification.GameUnregisterAll(self)
	self:ClearMarketScroll()
	self:ClearSellingScroll()
	self:RemoveAllNFTCard()
	ZTD.MainScene.ShowCamera()
	if self.cb then
		self.cb()
	end
end


-----------------------NFT宝箱界面 start-----------------------------------
--NFT宝箱界面
function NFTView:Openpleasedevelopment()
	    --第一次做初始化
	if not self.firstShowOrepool then
		self.firstShowOrepool = true
		self:initOpenpl()
	end
	--ZTD.ViewManager.ShowTip(self.lan.pleasedevelopment)
	self:SelectOpenplItem(self.SelectOpenplindex)
	self:Reqboxes()
	
end

function NFTView:Reqboxes()
	ZTD.Request.HttpRequest("ReqBoxes", {

	}, function (data)
		-- log("======= Reqboxes == "..GC.uu.Dump(data))
		self:updateOpenpldata(data)

	end, function ()
		logError("ReqBoxes error")
	end, false)
end

function NFTView:ReqOpenbox(type,index)
	if type < 0 or index < 0 then
		logError("ReqOpenbox error  type < 0 or index < 0 ")
		return
	end
	ZTD.Request.HttpRequest("ReqOpenbox", {
		type = type,
		total = index,
	}, function (data)
		-- log("======= ReqOpenbox == "..GC.uu.Dump(data))
		local tempdata = {}
		tempdata._type = 3
		tempdata.prize = {}
		for _, v in ipairs(data.box_frt) do
			table.insert(tempdata.prize, {name = "frt", val = v})
		end
		ZTD.ViewManager.Open("ZTD_NFTGetRewardView", tempdata)
		self:Reqboxes()
	end, function ()
		logError("ReqOpenbox error")
	end, false)
end

function NFTView:initOpenpl()

	self.SelectOpenplindex = 1
	self.SelectOpenplTen = 10
	self.NFTOrepoolData = {}
	-- self:AddClick("root/Item5/BtnItem1", function()
	-- 	-- self:SelectMarketItem(i)
	-- end)
 
	for i = 1, 3 do
		self:AddClick("root/Item5/NFTItem1/nftChestNode"..i, function()
			self:SelectOpenplItem(i)
		end)
	end

	self:AddClick("root/Item5/NFTItem1/nftNode/BtnNode1", function()
		self:OnNFTOpenpl01()
	end)
	self:AddClick("root/Item5/NFTItem1/nftNode/BtnNode10", function()
		self:OnNFTOpenpl10()
	end)
	self.notBtnNode01 = self:FindChild("root/Item5/NFTItem1/nftNode/notBtnNode1")
	self.notBtnNode10 = self:FindChild("root/Item5/NFTItem1/nftNode/notBtnNode10")
	self:AddClick(self.notBtnNode01, function()
		self:OnNotOpenpl()
	end)
	self:AddClick(self.notBtnNode10, function()
		self:OnNotOpenpl()
	end)
	self.nftNode = self:FindChild("root/Item5/NFTItem1/nftNode")
	self.BtnNode10Test = self:GetCmp("root/Item5/NFTItem1/nftNode/BtnNode10/Test", "Text")
	self.notBtnNode10Test = self:GetCmp("root/Item5/NFTItem1/nftNode/notBtnNode10/Test", "Text")
	self.NFTString1 = self:GetCmp("root/Item5/NFTItem1/nftNode/NFTString1", "Text")
	self.NFTString2 = self:GetCmp("root/Item5/NFTItem1/nftNode/picbg/NFTString2", "Text")
	self.Chestpic = self:FindChild("root/Item5/NFTItem1/nftNode/Chestpic")
	self.NFTpictip = self:FindChild("root/Item5/NFTItem1/nftNode/NFTpictip")

	self.selectpic1 = self:FindChild("root/Item5/NFTItem1/nftChestNode1/selectpic1")
	self.selectpic2 = self:FindChild("root/Item5/NFTItem1/nftChestNode2/selectpic2")
	self.selectpic3 = self:FindChild("root/Item5/NFTItem1/nftChestNode3/selectpic3")

	self.chestSum1 = self:GetCmp("root/Item5/NFTItem1/nftChestNode1/inventoryNode/chestTest1", "Text")
	self.chestSum2 = self:GetCmp("root/Item5/NFTItem1/nftChestNode2/inventoryNode/chestTest2", "Text")
	self.chestSum3 = self:GetCmp("root/Item5/NFTItem1/nftChestNode3/inventoryNode/chestTest3", "Text")
	self.chestSum1.text = string.format(self.lan.chestSum, 0)  
	self.chestSum2.text = string.format(self.lan.chestSum, 0)  
	self.chestSum3.text = string.format(self.lan.chestSum, 0) 

	self.BtnNode10Test.text = string.format(self.lan.openboxOTen, self.SelectOpenplTen) 
	self.notBtnNode10Test.text = string.format(self.lan.openboxOTen, 10) 
end

function NFTView:SelectOpenplItem(idx)
	self.SelectOpenplindex = idx
	for i = 1, 3 do
		if idx ~= i then
			self["selectpic"..i]:SetActive(false)
		else
			self["selectpic"..i]:SetActive(true)
		end
	end
	if self.NFTOrepoolData and #self.NFTOrepoolData > 0 then
		if self.NFTOrepoolData[self.SelectOpenplindex].number > 0 and self.NFTOrepoolData[self.SelectOpenplindex].number < 10 then
			self.SelectOpenplTen = self.NFTOrepoolData[self.SelectOpenplindex].number
		else
			self.SelectOpenplTen = 10
		end
	else
		self.SelectOpenplTen = 10
	end
	if self.NFTOrepoolData and #self.NFTOrepoolData > 0 and self.NFTOrepoolData[self.SelectOpenplindex].number <= 0 then
		self.notBtnNode01:SetActive(true)
		self.notBtnNode10:SetActive(true)
	else
		self.notBtnNode01:SetActive(false)
		self.notBtnNode10:SetActive(false)
	end
	self.BtnNode10Test.text = string.format(self.lan.openboxOTen, self.SelectOpenplTen) 
	self.NFTString1.text = ""..self.lan.chestTpyeText[self.SelectOpenplindex]

	if self.NFTOrepoolData and self.NFTOrepoolData[self.SelectOpenplindex] then
		local minvalue = ZTD.Extend.FormatSpecNum(self.NFTOrepoolData[self.SelectOpenplindex].min_value/1000000, 6)
		local maxvalue = ZTD.Extend.FormatSpecNum(self.NFTOrepoolData[self.SelectOpenplindex].max_value/1000000, 6)
		self.NFTString2.text = string.format(self.lan.chestText[self.SelectOpenplindex], minvalue, maxvalue)
	end	
	self.nftNode:GetComponent("Image").sprite = ResMgr.LoadAssetSprite("uiPrefab", "kbx_ysb"..idx);
	self.Chestpic:GetComponent("Image").sprite = ResMgr.LoadAssetSprite("uiPrefab", "XD_icon"..idx);
	self.NFTpictip:GetComponent("Image").sprite = ResMgr.LoadAssetSprite("uiPrefab", "kbx_tip"..idx);
end
function NFTView:OnNotOpenpl()
	ZTD.ViewManager.ShowTip(self.lan.orepoolInsufficientQuantity)
end

function NFTView:OnNFTOpenpl01()
	if self.NFTOrepoolData and self.NFTOrepoolData[self.SelectOpenplindex].number and self.NFTOrepoolData[self.SelectOpenplindex].number >= 1 then
		self:ReqOpenbox(self.SelectOpenplindex, 1)
	else
		ZTD.ViewManager.ShowTip(self.lan.orepoolInsufficientQuantity)
	end
end

function NFTView:OnNFTOpenpl10()
	if self.NFTOrepoolData and self.NFTOrepoolData[self.SelectOpenplindex].number and self.NFTOrepoolData[self.SelectOpenplindex].number >= self.SelectOpenplTen then
		self:ReqOpenbox(self.SelectOpenplindex, self.SelectOpenplTen)
	else
		ZTD.ViewManager.ShowTip(self.lan.orepoolInsufficientQuantity)
	end
end

function NFTView:updateOpenpldata(data)
	-- log("======= updateOpenpldata == "..GC.uu.Dump(data))
	self.NFTOrepoolData[1] = data.gold   -- 金箱子数量
	self.NFTOrepoolData[2] = data.silver-- 银箱子数量
	self.NFTOrepoolData[3] = data.copper -- 铜箱子数量
	
	self.chestSum1.text = string.format(self.lan.chestSum, self.NFTOrepoolData[1].number)  
	self.chestSum2.text = string.format(self.lan.chestSum, self.NFTOrepoolData[2].number)  
	self.chestSum3.text = string.format(self.lan.chestSum, self.NFTOrepoolData[3].number) 

	-- self.NFTOrepoolData[4] = ZTD.Extend.FormatSpecNum(data.gold_value/1000000, 6)
	-- self.NFTOrepoolData[5] = ZTD.Extend.FormatSpecNum(data.silver_value/1000000, 6) 
	-- self.NFTOrepoolData[6] = ZTD.Extend.FormatSpecNum(data.copper_value/1000000, 6)
	
	if self.NFTOrepoolData and self.NFTOrepoolData[self.SelectOpenplindex] then
		local minvalue = ZTD.Extend.FormatSpecNum(self.NFTOrepoolData[self.SelectOpenplindex].min_value/1000000, 6)
		local maxvalue = ZTD.Extend.FormatSpecNum(self.NFTOrepoolData[self.SelectOpenplindex].max_value/1000000, 6)
		self.NFTString2.text = string.format(self.lan.chestText[self.SelectOpenplindex], minvalue, maxvalue)
	end	

	if self.NFTOrepoolData and self.NFTOrepoolData[self.SelectOpenplindex] then
		if self.NFTOrepoolData[self.SelectOpenplindex].number > 0 and self.NFTOrepoolData[self.SelectOpenplindex].number < 10 then
			self.SelectOpenplTen = self.NFTOrepoolData[self.SelectOpenplindex].number
		else
			self.SelectOpenplTen = 10
		end
		self.BtnNode10Test.text = string.format(self.lan.openboxOTen, self.SelectOpenplTen) 
	end
	if self.NFTOrepoolData and #self.NFTOrepoolData > 0 and self.NFTOrepoolData[self.SelectOpenplindex].number <= 0 then
		self.notBtnNode01:SetActive(true)
		self.notBtnNode10:SetActive(true)
	else
		self.notBtnNode01:SetActive(false)
		self.notBtnNode10:SetActive(false)
	end
end

function NFTView:ReqNFTUserInfo(typeID)
	if not typeID or typeID == nil then
		logError("ReqNFTUserInfo error typeID === null ")
		return
	end
	ZTD.Request.HttpRequest("ReqNFTUserInfo", {
		s_uid = typeID,
		-- total = index,
	}, function (data)
		log("======= ReqNFTUserInfo == "..GC.uu.Dump(data))
		ZTD.ViewManager.Open("ZTD_PlayerInfoView",data)
	end, function ()
		logError("ReqNFTUserInfo error")
	end, false)
end

-----------------------NFT宝箱界面 end-----------------------------------

return NFTView