local CC = require("CC")
local Config = require("View/LoyKraThong/LoyKraThongDefine")
local ViewUIBase = require("Common/ViewUIBase")
local baseClass = CC.class2("LoyKraThongWishesList",ViewUIBase)

local type1Height = Vector2(591,45)
local type2Height = Vector2(591,45)

function baseClass:ctor(btnCallback)
	self.language = CC.LanguageManager.GetLanguage("L_LoyKraThong")
	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	self.btnCallback = btnCallback
end

function baseClass:OnCreate()
	self:InitContent()
	self:InitTextByLanguage()
	-- self:RegisterEvent()
end

function baseClass:InitContent()
	self:AddClick("mask",slot(self.OnBtnCloseClick,self))

	self.grid = self:SubGet("ScrollView/Viewport/Grid","GridLayoutGroup")
	self.itemList = {}
	for i=1,4 do
		local item = {}
		local itemPath = "ScrollView/Viewport/Grid/item"..i
		item.transform = self:FindChild(itemPath)
		item.placeText = self:SubGet(itemPath.."/placeText","Text")
		item.rankText = self:SubGet(itemPath.."/rankText","Text")
		item.awardText = self:SubGet(itemPath.."/awardText","Text")
		item.scoreText = self:SubGet(itemPath.."/scoreText","Text")
		table.insert(self.itemList,item)
	end

	-- self:AddClick("BtnClose",slot(self.OnBtnCloseClick,self))

	self:AddClick("btn",slot(self.OnWinnersBtnClick,self))
end

function baseClass:InitTextByLanguage()
	self:FindChild("Image/Image (1)/Text").text = self.language.wishListTitle
	self:FindChild("btn/Text").text = self.language.wishListBtn
end

function baseClass:OnBtnCloseClick()
	self:SetActive(false)
end

function baseClass:OnWinnersBtnClick()
	if self.btnCallback and self.wishType then
		self.btnCallback(self.wishType)
	end
end

function baseClass:OnShow()

end

--[[
	data = {
		Number = 1,
		ConfigId = 1,
		Count = 1,
		Score = 10,
	}
]]
function baseClass:InitList(wishType)
	self.wishType = wishType
	local data
	if wishType == 1 then
		self.grid.cellSize = type1Height
		data = Config.wishListData1
	else
		self.grid.cellSize = type2Height
		data = Config.wishListData2
	end
	for i,item in ipairs(self.itemList) do
		item.placeText.text = string.format(self.language.wishListPlaceText,data[i].Number)
		item.rankText.text = string.format(self.language.wishListRankText,data[i].Number)
		item.awardText.text = self.PropDataMgr.GetLanguageDesc(data[i].ConfigId,data[i].Count)
		item.scoreText.text = string.format(self.language.wishListScoreText,data[i].Score)
	end
end

function baseClass:OnHide()
	self.wishType = nil
end

function baseClass:OnDestroy()
	-- self:UnRegisterEvent()
end

return baseClass