local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local baseClass = CC.class2("LoyKraThongWinnersList",ViewUIBase)

function baseClass:ctor()
	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
end

function baseClass:OnCreate(...)
	self.language = CC.LanguageManager.GetLanguage("L_LoyKraThong")
	self:InitContent()
	self:InitTextByLanguage()
	-- self:RegisterEvent()
end

function baseClass:InitContent()
	self:AddClick("mask",slot(self.OnBtnCloseClick,self))

	self.itemList = {}
	for i=1,10 do
		local item = {}
		local itemPath = "ScrollView/Viewport/Content/Grid/item"..i
		item.transform = self:FindChild(itemPath)
		item.nameText = self:SubGet(itemPath.."/nameText","Text")
		item.scoreText = self:SubGet(itemPath.."/scoreText","Text")
		table.insert(self.itemList,item)
	end

	self.ContentTr = self:FindChild("ScrollView/Viewport/Content")
	self.fourSignTr = self:FindChild("ScrollView/Viewport/Content/Text")

	self:AddClick("BtnClose",slot(self.OnBtnCloseClick,self))
end

function baseClass:InitTextByLanguage()
	self:FindChild("Image/Image (1)/Text").text = self.language.winnerTitle
	self:FindChild("ScrollView/Viewport/Content/Text").text = "4"
end

function baseClass:OnBtnCloseClick()
	self:SetActive(false)
end

function baseClass:InitList(wishType,data)
	if data == nil then
		self.ContentTr:SetActive(false)
		return
	end

	-- if (wishType == 2 and #data ~= 10) or (wishType == 1 and #data ~= 6) then
	-- 	logError(CC.uu.Dump(data,"LoyKraThongWinnersList InitList",10))
	-- end

	self.ContentTr:SetActive(true)
	local isType2 = #data > 6 -- 筹码许愿也改成10个
	self.fourSignTr:SetActive(isType2)
	for i=7,10 do
		local item = self.itemList[i]
		item.transform:SetActive(isType2)
	end
	if isType2 then
		self.ContentTr.height = 442
	else
		self.ContentTr.height = 293
	end

	for i,v in ipairs(data) do
		local item = self.itemList[i]
		item.nameText.text = v.Name
		if v.Reward then
			item.scoreText.text = self.PropDataMgr.GetLanguageDesc(v.Reward.ConfigId,v.Reward.Count)
		end
	end

	for i=#data+1,6 do
		local item = self.itemList[i]
		item.transform:SetActive(false)
	end
end

function baseClass:OnShow( ... )
	-- body
end

function baseClass:OnHide( ... )
	-- body
end

function baseClass:OnDestroy( ... )
	-- body
end

return baseClass