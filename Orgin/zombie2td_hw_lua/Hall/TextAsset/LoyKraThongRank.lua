local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local baseClass = CC.class2("LoyKraThongRank",ViewUIBase)

local GetPercentValue = function ( total, i )
	local percent = 1
	if i == 1 then
		percent = 0.25
	elseif i == 2 then
		percent = 0.15
	elseif i == 3 then
		percent = 0.10
	elseif i >= 4 and i <= 10 then
		percent = 0.04
	elseif i >= 11 and i <= 30 then
		percent = 0.0075
	elseif i >= 31 and i <= 50 then
		percent = 0.0035
	else
		percent = 0
	end
	return CC.uu.ChipFormat(math.floor(total * percent))
end

function baseClass:ctor()
	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")

	self.jackpotValue = 0
	self.rankData = {}
end

function baseClass:OnCreate(...)
	self.language = CC.LanguageManager.GetLanguage("L_LoyKraThong");
	self:InitContent()
	self:InitTextByLanguage()
	self:RegisterEvent()
end

function baseClass:InitContent()
	self.topList = {}
	for i=1,3 do
		local itemPath = "top"..i
		local item = {}
		item.transform = self:FindChild(itemPath)
		local headRoot = self:FindChild(itemPath.."/headNode")
		item.head = CC.HeadManager.CreateHeadIcon({parent = headRoot, playerId = ""})
		item.nameText = self:SubGet(itemPath.."/name/Text","Text")
		item.transform:SetActive(false)
		table.insert(self.topList,item)
	end

	self.itemPrefab = self:FindChild("item")
	self.grid = self:FindChild("ScrollView/Viewport/Grid")
	self.itemList = {}

	self.selfItem = {}
	self.selfItem.noRankTr = self:FindChild("me/noRank")
	self.selfItem.noRankTr:SetActive(true)
	self.selfItem.numTextTr = self:FindChild("me/numText")
	self.selfItem.numTextTr:SetActive(false)
	self.selfItem.numText = self:SubGet("me/numText","Text")
	self.selfItem.nameText = self:SubGet("me/nameText","Text")
	self.selfItem.nameText.text = CC.Player.Inst():GetSelfInfoByKey("Nick")
	self.selfItem.scoreText = self:SubGet("me/scoreText","Text")
	self.selfItem.scoreText.text = "0"
	self.selfItem.percentText = self:SubGet("me/percentText","Text")
	self.selfItem.percentText.text = "0"
	local selfheadRoot = self:FindChild("me/headNode")
	self.selfItem.head = CC.HeadManager.CreateHeadIcon({parent = selfheadRoot})

	self:AddClick("BtnClose",slot(self.OnBtnCloseClick,self))
end

function baseClass:InitTextByLanguage()
	self:FindChild("Text").text = self.language.rankText
	self:FindChild("Text (1)").text = self.language.rankText1
	self:FindChild("Text (2)").text = self.language.rankText2
	self:FindChild("Text (3)").text = self.language.rankText3
end

function baseClass:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnGetWaterLampWishRankRsp,CC.Notifications.NW_ReqGetWaterLampWishRank)
	-- CC.HallNotificationCenter.inst():register(self,self.OnUpdateJackpot,CC.Notifications.OnUpdateJackpot)
end

function baseClass:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetWaterLampWishRank)
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnUpdateJackpot)
end

function baseClass:OnGetWaterLampWishRankRsp(errCode, data)
	-- self.activityDataMgr.SetActivityInfoByKey("LoyKraThong", {redDot=false});
	if errCode == 0 then
		log(CC.uu.Dump(data,"OnGetWaterLampWishRankRsp",10))
		self.rankData = data.Ranks or {}
		self.myRank = data.MyRank or {}
		self:OnRefreshUI()
	else
		logError(errCode)
	end

end

function baseClass:SetJackpot(value)
	self.jackpotValue = value or 0
end

function baseClass:OnBtnCloseClick()
	self:SetActive(false)
end

function baseClass:OnShow()
	local data = {}
	data.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
    data.Length = 50
    data.WishType = 0
    data.RankType = 2
	CC.Request("ReqGetWaterLampWishRank",data)
	-- self:OnRefreshUI()
end

function baseClass:OnRefreshUI()
	self:RefreshRankList()
	self:RefreshTopThree()
	self:RefreshMyRank()
end


--[[
message WaterLampWishRank {
	required int64 PlayerId = 1;
	required string Name = 2;
	optional int64 Reward = 3;
	required int64 VIP = 4;
	required string Portrait = 5;
	optional int64 Score = 6;
}
]]
function baseClass:RefreshRankList()
	for i=1,#self.rankData do
		local data = self.rankData[i]
		local item = self.itemList[i]
		if item == nil then
			item = self:CreateOneItem()
		end
		item.numText.text = tostring(i)
		item.nameText.text = data.Name
		item.scoreText.text = tostring(data.Score)
		item.percentTr.text = GetPercentValue(self.jackpotValue,i)
		if i == 1 then
			item.percentTr.x = 203
			item.awardTr:SetActive(true)
			local iconSpriteName = self.PropDataMgr.GetIcon(CC.shared_enums_pb.EPC_300Card,1) -- self.PropDataMgr.GetIcon(data.PropId,data.Count)
			if iconSpriteName then
				CC.uu.SetHallImage(item.awardImage, iconSpriteName)
				item.awardImage:SetNativeSize()
			end
			item.awardText.text = self.PropDataMgr.GetLanguageDesc(CC.shared_enums_pb.EPC_300Card,1) -- self.PropDataMgr.GetLanguageDesc(data.PropId,data.Count)
		else
			item.percentTr.x = 245
			item.awardTr:SetActive(false)
		end
		item.transform:SetActive(true)
	end

	for i=#self.rankData+1,#self.itemList do
		local item = self.itemList[i]
		item.transform:SetActive(false)
	end
end

function baseClass:CreateOneItem()
	local item = {}
	local go = CC.uu.newObject(self.itemPrefab,self.grid)
	local tr = go.transform
	item.transform = tr
	item.numText = tr:SubGet("numText","Text")
	item.nameText = tr:SubGet("nameText","Text")
	item.scoreText = tr:SubGet("scoreText","Text")
	item.percentTr = tr:FindChild("percentText")
	item.percentText = tr:SubGet("percentText","Text")
	item.awardTr = tr:FindChild("award")
	item.awardImage = tr:SubGet("award/Image","Image")
	item.awardText = tr:SubGet("award/Text","Text")
	table.insert(self.itemList,item)
	return item
end

function baseClass:RefreshTopThree()
	for i=1,3 do
		local data = self.rankData[i]
		local item = self.topList[i]
		if data then
			item.head:RefreshOtherUI({playerId = self.rankData[i].PlayerId,
									portrait = self.rankData[i].Portrait,
									showChat = false,
									vipLevel = self.rankData[i].VIP,
									-- clickFunc = "unClick"
								})
			item.nameText.text = self.rankData[i].Name
			item.transform:SetActive(true)
		else
			item.transform:SetActive(false)
		end
	end
end

function baseClass:RefreshMyRank()
	if self.myRank == nil then
		logError("RefreshMyRank")
		return
	end
	local rank = self.myRank.Rank
	if rank and (rank > 50 or rank <= 0) then
		self.selfItem.noRankTr:SetActive(true)
		self.selfItem.numTextTr:SetActive(false)
		self.selfItem.percentText.text = "0"
	else
		self.selfItem.noRankTr:SetActive(false)
		self.selfItem.numTextTr:SetActive(true)
		self.selfItem.numText.text = tostring(rank)
		self.selfItem.percentText.text = GetPercentValue(self.jackpotValue,rank)
	end
	-- self.selfItem.nameText.text = CC.Player.Inst():GetSelfInfoByKey("Nick")
	self.selfItem.scoreText.text = tostring(self.myRank.Data.Score)

	-- self.selfItem.head:RefreshOtherUI({portrait = "", showChat = false, vipLevel = nil, clickFunc = "unClick"})
end

function baseClass:OnHide( ... )
	-- body
end

function baseClass:OnDestroy( ... )
	for i=1,3 do
		local item = self.topList[i]
		item.head:Destroy()
	end
	self.selfItem.head:Destroy()
	self:UnRegisterEvent()
end

return baseClass