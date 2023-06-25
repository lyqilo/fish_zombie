local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local BaseClass = CC.class2("AgentGeneralizeYearView",ViewUIBase)

function BaseClass:ctor()
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView")

	self.curYear = self.agentDataMgr.CurYear()
	self.curMonth = self.agentDataMgr.CurMonth()

	self.showYear = self.curYear
end

function BaseClass:OnCreate(itemCallback)
	self.itemCallback = itemCallback

	self:InitContent()
	self:InitTextByLanguage()
	-- self:RegisterEvent()

	self:InitItem()

	-- self:UpdateShow()
end

function BaseClass:InitContent()
	self.leftBtn = self:FindChild("top/leftBtn")
	self:AddClick(self.leftBtn,slot(self.OnLeftBtnClick,self))

	self.rightBtn = self:FindChild("top/rightBtn")
	self:AddClick(self.rightBtn,slot(self.OnRightBtnClick,self))

	self.yText = self:FindChild("top/yText")
	self.yText.text = string.format(self.language.generalizeyear,self.showYear)

	self.numText = self:FindChild("top/numText/Text")

	self.itemPrefab = self:FindChild("item")

	self.contentRoot = self:FindChild("Scroll View/Viewport/Content")

end

function BaseClass:InitTextByLanguage()
	self:FindChild("top/numText").text = self.language.generalizenum
end

function BaseClass:InitItem()
	self.itemList = {}
	for i=1,12 do
		local go = CC.uu.newObject(self.itemPrefab, self.contentRoot)
		go:SetActive(true)
		go.transform:FindChild("mText").text = self.language.generalizemonth[i]

		self:AddClick(go.transform,function ()
			if self.itemCallback then
				self.itemCallback(i,self.showYear)
			end
		end)
		table.insert(self.itemList,go)
	end
end

function BaseClass:OnLeftBtnClick()
	self.showYear = self.showYear - 1
	self:UpdateShow()
end

function BaseClass:OnRightBtnClick()
	self.showYear = self.showYear + 1
	self:UpdateShow()
end

function BaseClass:OnShow()

end

function BaseClass:UpdateShow()
	local data = self.agentDataMgr.GetGeneralizeDataList()

	if data[tostring(self.showYear-1)] then
		self.leftBtn:SetActive(true)
	else
		self.leftBtn:SetActive(false)
	end

	if data[tostring(self.showYear+1)] then
		self.rightBtn:SetActive(true)
	else
		self.rightBtn:SetActive(false)
	end

	self.yText.text = string.format(self.language.generalizeyear,self.showYear)

	local totalNum = 0

	for i,go in ipairs(self.itemList) do
		local tr = go.transform
		tr:FindChild("eff"):SetActive(self.showYear == self.curYear and i == self.curMonth)
		local num = data[tostring(self.showYear)] and data[tostring(self.showYear)][tostring(i)] or 0
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