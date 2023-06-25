local CC = require("CC")
local MonopolyRankView = CC.uu.ClassView("MonopolyRankView")
local M = MonopolyRankView

--排行总数量
local rankNum = 50

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {}
    self.language = self:GetLanguage()
	
	self.myHeadIcon = nil
	self.rankHeadIconList = {}
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.rankCfg = CC.ConfigCenter.Inst():getConfigDataByKey("MonopolyConfig").rankCfg
end

function M:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
	self.viewCtr:StartRequest()
	
	self:RefreshBoxAward()
end

function M:InitContent()
	
	self.startNode = self:FindChild("Preview/ShowRange/StartNode")
	self.bubblePrefab = self:FindChild("Preview/ShowRange/Item")
	self.bubbleParent = self:FindChild("Preview/ShowRange/Parent")
	
	self.myRank = self:FindChild("Rank/MyRank")
	self.rankScrCtrl = self:FindChild("Rank/ScrollerController"):GetComponent("ScrollerController")
	
	self:AddClick("BtnClose","ActionOut")
	self:AddClick("Rank/BtnExplain","OnClickExplainBtn")
	
	self.rankScrCtrl:AddChangeItemListener(function(trans,dataIndex,cellIndex)
			self:RefreshRankItem(trans,dataIndex)
		end)
	self.rankScrCtrl:AddRycycleAction(function (trans)
			self:RycycleRankItem(trans)
		end)
	
	self.myHeadIcon = CC.HeadManager.CreateHeadIcon({parent = self.myRank:FindChild("HeadNode")})
end

function M:InitTextByLanguage()
	self:FindChild("Rank/Bg/Tips").text = self.language.ruleDesc2
	self:FindChild("Rank/Bg/Title").text = self.language.rankTitle
	self:FindChild("Rank/Bg/TimeText").text = self.language.actTime
	self.myRank:FindChild("Text").text = self.language.myRank
end

function M:RefreshUI(data)
	
	if data.myRank then
		local rank = data.myRank > 999 and "999+" or data.myRank
		self.myRank:FindChild("Text").text = string.format(self.language.myRank,rank)
	end
	
	if data.myRankData then
		self:RefreshMyRankData(data.myRankData)
	end

	if data.rankList then
		self.rankScrCtrl:InitScroller(rankNum)
	end
end

function M:RefreshBoxAward()

	local config = self.rankCfg.preview
	self:StopTimer("Bubble")
	Util.ClearChild(self.bubbleParent)
	local loopIdx = 1
	local func = function()
		for i=1,3 do
			if loopIdx > #config then
				loopIdx = 1
			end
			local data = config[loopIdx]
			local endNode = self:FindChild("Preview/ShowRange/EndNode"..i)
			self:CreateBubbleItem(data, endNode.position)
			loopIdx = loopIdx + 1
		end
	end
	func()
	self:StartTimer("Bubble", 2, func, -1)
end

function M:CreateBubbleItem(data,endPos)
	local item = CC.uu.newObject(self.bubblePrefab,self.bubbleParent)
	item.position = self.startNode.position
	local action = nil
	local actionParam = {}
	local duration = 20
	local startX = item.position.x
	local startY = item.position.y
	local endX = endPos.x
	local endY = endPos.y
	local deltaX = endX - startX
	local deltaY = endY - startY
	local hasHide = false
	local awardImage = self.propCfg[data.propId].Icon

	self:SetImage(item:FindChild("Node/Icon"),awardImage)
	item:FindChild("Node/Icon"):GetComponent("Image"):SetNativeSize()
	item:FindChild("Node/Num").text = "x"..CC.uu.NumberFormat(data.num)
	item:SetActive(true)

	table.insert(actionParam,{"to", 0, 1000, duration,function (value)
				local percent = value/1000
				item.position = Vector3(startX + deltaX*percent, startY + deltaY*percent)
				if value >= 680 and (not hasHide) then
					hasHide = true
					self:RunAction(item, {"fadeToAll", 0, 0.5, function ()
								if action ~= nil then
									self:StopAction(action)
								end
								if not CC.uu.IsNil(item) then
									CC.uu.destroyObject(item)
								end
							end})
				end
			end})
	actionParam.ease = CC.Action.EOutQuart
	action = self:RunAction(item, actionParam)
end

function M:RefreshMyRankData(data)
	
	local cardImg,iconImg = self:GetCardImgByLevel(data.level)
	self:SetImage(self.myRank:FindChild("Score/Card"),cardImg)
	self:SetImage(self.myRank:FindChild("Score/Card/Icon"),iconImg)
	self.myRank:FindChild("Score/Text").text = "Lv."..data.level
end

function M:RefreshRankItem(trans,index)
	if not self.viewCtr then return end
	local rankList = self.viewCtr.rankList or {}
	local rank = index + 1
	local rankData = rankList[rank]
	
	local rewards
	for _,v in ipairs(self.rankCfg.rank) do
		if rank >= v.min and rank <= v.max then
			rewards = v.rewards
			break
		end
	end
	
	local rankImg = trans:FindChild("Rank")
	local rankImgSp = trans:FindChild("RankSp")
	trans.name = rank
	if rank <= 3 then
		self:SetImage(rankImgSp, string.format("cp_phbicon_%d",rank))
		rankImgSp:GetComponent("Image"):SetNativeSize()
		rankImg:SetActive(false)
		rankImgSp:SetActive(true)
	else
		rankImg:FindChild("Text").text = rank
		rankImg:SetActive(true)
		rankImgSp:SetActive(false)
	end
	trans:FindChild("Bubble"):SetActive(rank==1)
	--等级/图标
	trans:FindChild("Score/Text").text = rankData and "Lv."..rankData.CurrentLever or ""
	if rankData then
		local cardImg,iconImg = self:GetCardImgByLevel(rankData.CurrentLever)
		self:SetImage(trans:FindChild("Score/Card"),cardImg)
		self:SetImage(trans:FindChild("Score/Card/Icon"),iconImg)
	else
		self:SetImage(trans:FindChild("Score/Card"),"cgxb_gl_dxdk01")
		self:SetImage(trans:FindChild("Score/Card/Icon"),"cgxb_gl_dx01")
	end
	
	--奖励
	for i=1,2 do
		local item = trans:FindChild("Rewards/"..i)
		if rewards[i] then
			local sweep = item:FindChild("Sweep")
			local num = rewards[i].num
			local icon = rewards[i].icon or self.propCfg[rewards[i].propId].Icon
			self:SetImage(item,icon)
			
			--扫光
			if rewards[i].icon or self.propCfg[rewards[i].propId].Physical then
				self:SetImage(sweep,icon)
				sweep:SetActive(true)
			else
				sweep:SetActive(false)
			end
			
			item:FindChild("Text").text = num == 1 and "" or "x"..CC.uu.NumberFormat(rewards[i].num)
			item:SetActive(true)
		else
			item:SetActive(false)
		end
	end

	--头像
	local IconData = {}
	IconData.parent = trans:FindChild("HeadNode")
	IconData.playerId = rankData and rankData.PlayerId or ""
	IconData.portrait = rankData and rankData.Portrait
	if rank <= 3 then
		IconData.headFrame = "3058"
	else
		IconData.headFrame = rankData and rankData.Background
	end
	IconData.vipLevel = rankData and rankData.Level
	if not rankData then
		IconData.clickFunc = "unClick"
	end
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.rankHeadIconList[rank] = headIcon
end

function M:RycycleRankItem(trans)
	local index = tonumber(trans.transform.name)
	if self.rankHeadIconList[index] then
		self.rankHeadIconList[index]:Destroy(true)
	end
end

function M:OnClickExplainBtn()
	CC.ViewManager.Open("MonopolyRankRuleView",{curLevel = self.viewCtr.curLevel})
end

function M:GetCardImgByLevel(level)
	local lv = Mathf.Clamp(level,0,29)
	local cardImg = string.format("cgxb_gl_dxdk%02d",lv%2==0 and 1 or 2)
	local iconImg = string.format("cgxb_gl_dx%02d",math.floor(lv/3)+1)
	return cardImg,iconImg
end

function M:ActionIn()
	self:SetCanClick(false);
	self.transform.size = Vector2(125, 0)
    self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function M:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function M:OnDestroy()
	
	for _,v in pairs(self.rankHeadIconList) do
		--销毁排行榜头像
		if v then
			v:Destroy(true)
			v = nil
		end
	end

	if self.myHeadIcon then
		self.myHeadIcon:Destroy(true)
		self.myHeadIcon = nil
	end
	
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return MonopolyRankView