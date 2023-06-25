
local CC = require("CC")
local WorldCupRankView = CC.uu.ClassView("WorldCupRankView")

function WorldCupRankView:ctor(param)

	self:InitVar(param);
end

function WorldCupRankView:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function WorldCupRankView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self.IconTab = {}
	self.RankData = {}
	self.RankRewards = {}
	self.RankIconNum = 0
	self:InitContent()
	self:InitTextByLanguage()
	self:InitGameJackpots()
	if self:GetTime() then
		self.viewCtr:ReqChampionInfo()
	end
end

function WorldCupRankView:GetTime()
	local nextTime = 1671372000
	local nowTime = os.time()
	local time = nextTime - nowTime
	if time > 0 then
		return false
	else
		return true
	end
end

function WorldCupRankView:InitVar(param)
	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop");

	self.param = param;
end

function WorldCupRankView:InitContent()
	self:InitScroll()

	local countryId = CC.LocalGameData.GetWorldCupChampionData()
	if countryId then
		self:SetChampionCountryImage(countryId)
	end
end

--创建ScrollView
function WorldCupRankView:InitScroll()
	self.LoopScrollRect = self:FindChild("Frame/Right/Rank/ScrollView"):GetComponent("LoopScrollRect")
	self.VerticalLayoutGroup = self.LoopScrollRect.transform:FindChild("Viewport/Content"):GetComponent("VerticalLayoutGroup")
	self.LoopScrollRect:AddChangeItemListener(function(tran,index) 	
		self:ItemData(tran,index)
	end)

	self.LoopScrollRect:ToPoolItemListenner(function(tran,index) 	
		self:ReturnToPool(tran,index)
	end)
	
end

--延迟一帧执行显示排行榜
function WorldCupRankView:ShowRank()
	self.co = CC.uu.DelayRun(0.016,function()
		CC.uu.CancelDelayRun(self.co)
		-- self:SetNewLen(self.LoopScrollRect)
		self.LoopScrollRect.totalCount = 50
	end)
	self:ShowUserInfo()
end

function WorldCupRankView:ShowUserInfo(info)
	self:FindChild("Frame/Right/MyRank/ItemImg/ItemText").text = self.RankData.MyRank
	local source = self.RankData.MyScore > 0 and self.RankData.MyScore or 0
	self:FindChild("Frame/Right/MyRank/ItemMoneyImg/ItemMoneyText").text = CC.uu.ChipFormat(source)
	self:FindChild("Frame/Right/MyRank/RightPanel/Cm/ItemText").text = "0"

	local headNode = self:FindChild("Frame/Right/MyRank/ItemHeadMask/Node")
	if headNode.childCount <= 0 then
		self.RankIconNum = self.RankIconNum +1
		local param = {}
		param.parent = headNode
		param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id");
		param.unShowVip = true
		param.headFrame = 0
		self:SetHeadIcon(param,self.RankIconNum)
	end

	if CC.uu.isTable(info) then
		for i, v in ipairs(info) do
			if v.ConfigId == 2 then
				self:FindChild("Frame/Right/MyRank/RightPanel/Cm/ItemText").text = CC.uu.ChipFormat(v.Count)
			end
			if #info > 1 and v.ConfigId ~= 2
			and v.ConfigId ~= CC.shared_enums_pb.EPC_Avatar_Box_WorldCup1 and v.ConfigId ~= CC.shared_enums_pb.EPC_Avatar_Box_WorldCup2
			and v.ConfigId ~= CC.shared_enums_pb.EPC_Avatar_Box_WorldCup3 and v.ConfigId ~= CC.shared_enums_pb.EPC_Avatar_Box_WorldCupGiftpack then
				self:FindChild("Frame/Right/MyRank/RightPanel/ItemText").text = self.propLanguage[v.ConfigId]
				self:FindChild("Frame/Right/MyRank/RightPanel/ItemText"):SetActive(true)
				self:SetImage(self:FindChild("Frame/Right/MyRank/Image"),self.propCfg[v.ConfigId].Icon)
				self:FindChild("Frame/Right/MyRank/Image"):SetActive(false)
			end
		end
	end
end

function WorldCupRankView:ItemData(tran,index)
	local  rankId = index + 1
	tran.name = tostring(rankId)
	self.RankIconNum = self.RankIconNum +1
	local itemData = self.RankData
	local rewardData = self.RankRewards[rankId]
	if  rankId <= 3 then
		tran:FindChild("ImgPanel"):SetActive(true)
		self:ShowTopUI(tran,rankId)
		tran:FindChild("ItemMoneyImg"):SetActive(true)
		tran:FindChild("RightPanel"):SetActive(true)
		tran:FindChild("Image"):SetActive(true)
	else
		tran:FindChild("ImgPanel"):SetActive(false)
		-- tran:FindChild("ItemMoneyImg"):SetActive(false)
		tran:FindChild("Image"):SetActive(false)
	end

	tran:FindChild("ItemImg/ItemText").text = rankId

	if #rewardData.Rewards < 2 then
		tran:FindChild("RightPanel/ItemText"):SetActive(false)
		tran:FindChild("RightPanel/Cm"):SetActive(true)
	else
		tran:FindChild("RightPanel/ItemText"):SetActive(true)
		tran:FindChild("RightPanel/Cm"):SetActive(true)
	end

	for i, v in ipairs(rewardData.Rewards) do
		if v.ConfigId == 2 then
			tran:FindChild("RightPanel/Cm/ItemText").text = CC.uu.ChipFormat(v.Count)
		end
		if #rewardData.Rewards > 1 and v.ConfigId ~= 2
		and v.ConfigId ~= CC.shared_enums_pb.EPC_Avatar_Box_WorldCup1 and v.ConfigId ~= CC.shared_enums_pb.EPC_Avatar_Box_WorldCup2
		and v.ConfigId ~= CC.shared_enums_pb.EPC_Avatar_Box_WorldCup3 and v.ConfigId ~= CC.shared_enums_pb.EPC_Avatar_Box_WorldCupGiftpack then
			tran:FindChild("RightPanel/ItemText").text = self.propLanguage[v.ConfigId]
			self:SetImage(tran:FindChild("Image"),self.propCfg[v.ConfigId].Icon)
		end
	end

	--头像
	local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	
	local rankNum  = #self.RankData.Rank
	if rankNum >= rankId then
		local param = {}
		param.parent = headNode
		--玩家自己是否有在排行榜
		local userId = CC.Player.Inst():GetSelfInfoByKey("Id")
		if userId == itemData.Rank[rankId].Player.Id then
			self:ShowUserInfo(rewardData.Rewards)
		end
		param.playerId = itemData.Rank[rankId].Player.Id
		param.portrait = itemData.Rank[rankId].Player.Portrait
		param.unShowVip = true
		param.unChangeHeadFrame = true
		param.headFrame = 0
		tran:FindChild("ItemMoneyImg/ItemMoneyText").text = CC.uu.ChipFormat(itemData.Rank[rankId].Score)
		self:SetHeadIcon(param,self.RankIconNum)
		tran.transform:FindChild("ItemHeadMask/Image"):SetActive(false)
	else
		tran:FindChild("ItemMoneyImg/ItemMoneyText").text = "0"
		tran.transform:FindChild("ItemHeadMask/Image"):SetActive(true)
	end
	
	-- param.vipLevel = itemData.Player.Level
	-- param.playerName = itemData.Player.Nick

	self:TranLocalMoveTo(self.VerticalLayoutGroup,tran,index,rankId,self.LoopScrollRect,6)
end

--执行dotween
function WorldCupRankView:TranLocalMoveTo(VerticalLayoutGroup,tran,index,rankId,LoopScrollRect,len)
	if VerticalLayoutGroup.enabled == false then
		tran.transform.localPosition = Vector3(630,-48 + (index * -104),0)
		self:RunAction(tran, {"localMoveTo", 0, -48 + (index * -104),0.1 * rankId, function()
			local count = 0
			if len <= 4 then
				count = len
			elseif len >= 6  then
				count = 6
			end
			if rankId >= count then
	  			VerticalLayoutGroup.enabled = true
	  			self:RankListCount(LoopScrollRect,len)
	  			return
	  		end
		end})
	end
end

--设置循环列表长度
function WorldCupRankView:RankListCount(loopscrollrect,len)
	local count = len
	if count  == 0 then
		loopscrollrect:ClearCells()
	else 
		loopscrollrect.totalCount = len
	end
end

--确定初始化的长度
function WorldCupRankView:SetNewLen(LoopScrollRect,len)
	self.VerticalLayoutGroup.enabled = false
	if self.RankDataMgr.GetRankMgrLen(self.indexPage) < 5 then
		self:RankListCount(LoopScrollRect,self.RankDataMgr.GetRankMgrLen(self.indexPage))
	else
		self:RankListCount(LoopScrollRect,6)
	end
end

function WorldCupRankView:ReturnToPool(tran,index)
	local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)	
end

function WorldCupRankView:SetHeadIcon(param,i)
	local HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = HeadIcon
end

function WorldCupRankView:ShowTopUI(tran,rankId)
	tran:FindChild("ImgPanel/1"):SetActive(false)
	tran:FindChild("ImgPanel/2"):SetActive(false)
	tran:FindChild("ImgPanel/3"):SetActive(false)
	tran:FindChild("ImgPanel/"..rankId):SetActive(true)
end

function WorldCupRankView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
		end
	end	
end

function WorldCupRankView:InitGameJackpots()
	CC.HallNotificationCenter.inst():post(CC.Notifications.WorldCupJackpotChange, {type = "rank", node = self:FindChild("Frame/Left/Image/Jp/Jackpot/Value")});
end

function WorldCupRankView:SetChampionCountryImage(id)
	self:FindChild("Frame/Left/Image/Down/Image"):SetActive(true)
	self:FindChild("Frame/Left/Image/Down/Effect_dt_sjb_guanjun"):SetActive(false)
	self:SetImage(self:FindChild("Frame/Left/Image/Down/Image"), "circle_"..id);
end

function WorldCupRankView:InitTextByLanguage()
	self:FindChild("Frame/Right/Title/Text").text = self.language.scoreRank
end

function WorldCupRankView:ActionIn()
	local node = self:FindChild("Frame/Right");
	local x,y = node.x,node.y;
	node.x = -1100;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("Frame/Left");
	local x,y = node.x,node.y;
	node.x = -1300;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, delay = 0.1, ease = CC.Action.EOutSine, function() end})
end

function WorldCupRankView:ActionOut(cb)
	local node = self:FindChild("Frame/Left");
	self:RunAction(node, {"localMoveTo", -1300, node.y, 0.3, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("Frame/Right");
	self:RunAction(node, {"localMoveTo", -1100, node.y, 0.3, delay = 0.1, ease = CC.Action.EOutSine, function() 
		self:Destroy()
		cb()
	end})
end

function WorldCupRankView:OnDestroy()

	for _,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
	end
	
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return WorldCupRankView