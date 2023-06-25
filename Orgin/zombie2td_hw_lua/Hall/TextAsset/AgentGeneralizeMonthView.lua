local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local BaseClass = CC.class2("AgentGeneralizeMonthView",ViewUIBase)

function BaseClass:ctor()
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView")

	self.curYear = self.agentDataMgr.CurYear()
	self.curMonth = self.agentDataMgr.CurMonth()
	self.curDay = self.agentDataMgr.CurDay()


end

function BaseClass:OnCreate(backCallback)
	self.backCallback = backCallback

	self:InitContent()
	self:InitTextByLanguage()
	-- self:RegisterEvent()

	self:InitItem()
end

function BaseClass:InitContent()
	self.backBtn = self:FindChild("top/backBtn")
	self:AddClick(self.backBtn,slot(self.OnBackBtnClick,self))

	self.yText = self:FindChild("top/yText")

	self.mText = self:FindChild("top/mText")

	self.numText = self:FindChild("top/numText/Text")

	self.itemPrefab = self:FindChild("item")

	self.contentRoot = self:FindChild("Scroll View/Viewport/Content")

end

function BaseClass:InitTextByLanguage()
	self:FindChild("top/numText").text = self.language.generalizenum
end

function BaseClass:InitItem()
	self.itemList = {}
	for i=1,31 do
		local go = CC.uu.newObject(self.itemPrefab, self.contentRoot)
		go:SetActive(true)
		table.insert(self.itemList,go)
	end
end

function BaseClass:OnBackBtnClick()
	if self.backCallback then
		self.backCallback()
	end
end

function BaseClass:OnShow(month,year)
	self:UpdateShow(month,year)
end

function BaseClass:UpdateShow(month,year)
	local monthInYear = year*100+month
	local data = self.agentDataMgr.GetGeneralizeMonthDataList(monthInYear)

	self.yText.text = string.format(self.language.generalizeyear,year)
	self.mText.text = self.language.generalizemonth[month]

	local totalNum = 0

	for i,go in ipairs(self.itemList) do
		local tr = go.transform
		tr:FindChild("eff"):SetActive(self.curYear == year and self.curMonth == month and i == self.curDay)
		tr:FindChild("dText").text = tostring(i)
		local num = data[tostring(i)] or 0
		totalNum = totalNum + num
		local numText = tr:FindChild("numText")
		numText.text = num
		numText:SetActive(num~=0)
	end

	self.numText.text = tostring(totalNum)
end

function BaseClass:OnHide()

end

function BaseClass:OnDestroy()
	-- self:UnRegisterEvent()
end

return BaseClass