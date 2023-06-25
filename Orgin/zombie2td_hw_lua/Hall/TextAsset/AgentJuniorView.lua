--[[
	下级信息页
]]

local CC = require("CC")

local BaseClass = CC.uu.ClassView("AgentJuniorView")

local SortType = {
	Vip = CC.proto.client_agent_pb.SortByVip,
	TotalEarn = CC.proto.client_agent_pb.SortByTotalEarn,
	TotalEarnFromShare = CC.proto.client_agent_pb.SortByTotalEarnFromShare,
	TotalEarnFromNewer = CC.proto.client_agent_pb.SortByTotalEarnFromNewer,
	TotalEarnFromTrade = CC.proto.client_agent_pb.SortByTotalEarnFromTrade,
	JoinTime = CC.proto.client_agent_pb.SortByJoinTime,
	LastActivityTime = CC.proto.client_agent_pb.SortByLastActivityTime,
}

function BaseClass:ctor()
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");

	self.isShowLeft = false

	self.curSortType = CC.proto.client_agent_pb.SortByLastActivityTime -- 1vip 2total 3time 4game 5give 6promotion
	self.reversal = false

	self.isSearchMode = false

	self.curLength = 0
end

function BaseClass:OnCreate()
	self:LoadSubAgentList()

	self.itemlist = {}

	self:InitContent()
	self:InitTextByLanguage();
	-- self:RegisterEvent()

	self:UpdateShow()
end

function BaseClass:InitContent()
	self.mask = self:FindChild("mask")

	self:AddClick(self:FindChild("content/closeBtn"),slot(self.ActionOut,self))

	self.leftBtn = self:FindChild("content/leftBtn")
	self.leftBtn:SetActive(false)
	self:AddClick(self.leftBtn,slot(self.OnUpdateBtnStatus,self))

	self.rightBtn = self:FindChild("content/rightBtn")
	self.rightBtn:SetActive(false)
	self:AddClick(self.rightBtn,slot(self.OnUpdateBtnStatus,self))

	self.frist = self:FindChild("content/main/frist")
	self.second = self:FindChild("content/main/second")

	self.itemPrefab = self:FindChild("content/main/item")
	self.tipPanel = self:FindChild("content/main/tipPanel")
	self.tipPanel:SetActive(false)
	self:AddClick(self.tipPanel:FindChild("hideBtn"), function ()
		self.tipPanel:SetActive(false)
	end)

	self.contentRoot = self:FindChild("content/main/Scroll View/Viewport/Content")
	self.scrollView = self:SubGet("content/main/Scroll View", "ScrollRect")
	UIEvent.AddScrollRectOnValueChange(self:FindChild("content/main/Scroll View"),function (v)
		if not self.isUpdating and not self.isSearchMode and v.y < 0 then
			self:CheckMoreList()
		end
	end)


	local inputField = self:FindChild("content/InputField")
	local inputFieldBtn = self:FindChild("content/InputField/Button")
	self:AddClick(inputFieldBtn,function () inputField.text = "" self:UpdateList() end)
	inputFieldBtn:SetActive(false)
	UIEvent.AddInputFieldOnEndEdit(inputField, function( str )
		self.isSearchMode = str ~= nil and str ~= ""
		inputFieldBtn:SetActive(self.isSearchMode)
		self:OnInputFieldChange(str)
	end)
	inputField:GetComponent("InputField").characterLimit = 8

	self.numText = self:FindChild("content/numText/Text")

	local btnList = {"frist/vipText","frist/totalText", "frist/totalIntegral","second/gameText","second/promotionText","second/giveText","frist/timeText"}

	self.sortBtns = {}
	self.sortSelctBtns = {}
	for i,v in ipairs(btnList) do
		self:AddClick("content/main/"..v,function () self:OnSortBtnClick(i) end)
		local btn = self:FindChild("content/main/"..v.."/Image")
		local btnSelect = self:FindChild("content/main/"..v.."/Select")
		table.insert(self.sortBtns,btn)
		table.insert(self.sortSelctBtns, btnSelect)
	end
	--默认排序
	self:OnSortBtnClick(2)
end

function BaseClass:InitTextByLanguage()
	self:FindChild("content/title").text = self.language.juniortitle

	self:FindChild("content/numText").text = self.language.juniornum
	self:FindChild("content/InputField/Placeholder").text = self.language.Placeholder
	self:FindChild("content/main/frist/nameText").text = self.language.juniorname
	self:FindChild("content/main/frist/vipText").text = self.language.vip
	self:FindChild("content/main/frist/totalText").text = self.language.e0
	self:FindChild("content/main/frist/totalIntegral").text = self.language.e0
	self:FindChild("content/main/frist/timeText").text = self.language.juniortime

	self:FindChild("content/main/second/nameText").text = self.language.juniorname
	self:FindChild("content/main/second/gameText").text = self.language.e1
	self:FindChild("content/main/second/promotionText").text = self.language.e2
	self:FindChild("content/main/second/giveText").text = self.language.e3
	self.tipPanel:FindChild("1/Text").text = self.language.UnderlingTitle[5]
	self.tipPanel:FindChild("2/Text").text = self.language.UnderlingTitle[6]
	self.tipPanel:FindChild("3/Text").text = self.language.UnderlingTitle[7]
	-- self.tipPanel:FindChild("4/Text").text = self.language.UnderlingTitle[4]
end

-- function BaseClass:RegisterEvent()
-- 	CC.HallNotificationCenter.inst():register(self,self.OnLimitTimeGiftReward,CC.Notifications.OnLimitTimeGiftReward)
-- end

-- function BaseClass:UnRegisterEvent()
-- 	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnLimitTimeGiftReward)
-- end

function BaseClass:OnUpdateBtnStatus()
	self.isShowLeft = not self.isShowLeft
	self.leftBtn:SetActive(self.isShowLeft)
	self.rightBtn:SetActive(not self.isShowLeft)

	self.frist:SetActive(self.isShowLeft)
	self.second:SetActive(not self.isShowLeft)

	if self.isShowLeft then
		self.contentRoot.x = 0
	else
		self.contentRoot.x = -916
	end
end

local upsideDownVector3 = Vector3(0,0,180)

function BaseClass:OnUpdateSortBtn()
	for i,v in ipairs(self.sortBtns) do
		v:SetActive(i ~= self.curSortType)
	end
	for i,v in ipairs(self.sortSelctBtns) do
		v:SetActive(i == self.curSortType)
		if i == self.curSortType then
			v.localEulerAngles = self.reversal and upsideDownVector3 or Vector3.zero
		end
	end
end

function BaseClass:UpdateShow()
	self:OnUpdateBtnStatus()

	self:OnUpdateSortBtn()
end

function BaseClass:Reflash(data)
	if self.isDestroy then
		return
	end

	self:UpdateList(data)

	self.numText.text = tostring(self.agentDataMgr.GetJuniorCount())
end

function BaseClass:LoadSubAgentList()
	self.agentDataMgr.LoadSubAgentList(function (data)
		if data then
			self:Reflash(data)
		else
			self:ActionOut()
		end
	end,self.curSortType,0,self.reversal)
end

function BaseClass:UpdateList(list)
	list = list or self.agentDataMgr.GetJuniorDataListBySortType(self.curSortType,self.reversal)

	if list == nil then
		logError("list == nil")
		self:ActionOut()
		return
	end

	if not self.isSearchMode then
		self.curLength = #list
	end

	self:CreateItem(#list)
	for i,v in ipairs(list) do
		self:UpdateItem(i,self.itemlist[i].transform,list[i])
	end
end

function BaseClass:CreateItem(num)
	for i=#self.itemlist + 1,num do
		local go = CC.uu.newObject(self.itemPrefab, self.contentRoot)
		table.insert(self.itemlist,go)
	end

	for i=1,#self.itemlist do
		self.itemlist[i]:SetActive(i<=num)
	end
end

function BaseClass:UpdateItem(index,itemTr,data)
	itemTr:FindChild("bg"):SetActive(index%2==0)
	local name = tostring(data.agentId)
	itemTr:FindChild("nameText1").text = name
	itemTr:FindChild("nameText2").text = name
	itemTr:FindChild("vip/Text").text = tostring(data.vip)
	itemTr:FindChild("total").text = CC.uu.ChipFormat(data.totalEarn)
	itemTr:FindChild("totalIntegral").text = CC.uu.ChipFormat(data.totalGiftEarn)
	itemTr:FindChild("time").text = os.date("%d-%m-%Y",data.lastActivityTime) -- tostring(data.lastActivityTime) -- os.date("%d-%m-%Y")
	itemTr:FindChild("game").text = CC.uu.ChipFormat(data.totalEarnFromShare)
	itemTr:FindChild("give").text = CC.uu.ChipFormat(data.totalEarnFromTrade)
	if data.totalEarnFromTask > 0 then
		itemTr:FindChild("promotion/tipBtn"):SetActive(true)
		self:AddClick(itemTr:FindChild("promotion"), function ()
			self.tipPanel.transform:SetParent(itemTr:FindChild("promotion/tipBtn"), false)
			self.tipPanel.localPosition = Vector3.zero
			self.tipPanel:SetActive(true)
			self:UpdateTipData(data.earnFromNewerTask)
		end)
	else
		itemTr:FindChild("promotion/tipBtn"):SetActive(false)
	end
	itemTr:FindChild("promotion/num").text = CC.uu.ChipFormat(data.totalEarnFromTask)
end

function BaseClass:UpdateTipData(data)
	self.tipPanel:FindChild("1/num").text = data.TaskFive
	self.tipPanel:FindChild("2/num").text = data.TaskSix
	self.tipPanel:FindChild("3/num").text = data.TaskSeven
end

function BaseClass:CheckMoreList()
	if self.agentDataMgr.GetJuniorCount() > self.curLength then
		self.isUpdating = true
		self.agentDataMgr.LoadSubAgentList(function (data)
			self.isUpdating = false
			if data then
				self:Reflash(data)
			else
				self:ActionOut()
			end
		end,self.curSortType,self.curLength,self.reversal)
	end
end

function BaseClass:OnInputFieldChange(str)
	logError(str)
	if not self.isSearchMode then
		self:UpdateList()
	else
		self.agentDataMgr.SearchSubAgent(function (p)
			self:UpdateList(p or {})
		end,tonumber(str))
	end
end

function BaseClass:OnSortBtnClick(index)
	if self.isSearchMode then
		return
	end

	if self.curSortType == index then
		self.reversal = not self.reversal
	else
		self.reversal = false
	end

	self.curSortType = index

	self:OnUpdateSortBtn()

	self.scrollView:StopMovement()
	self.scrollView.verticalNormalizedPosition = 1

	-- self.scrollView:SetNormalizedPosition(1, 1)

	-- self:UpdateList()
	self.agentDataMgr.LoadSubAgentList(function (data)
		if data then
			self:Reflash(data)
		else
			self:ActionOut()
		end
	end,self.curSortType,0,self.reversal)
end

function BaseClass:OnDestroy()
	self.isDestroy = true
end

-- function BaseClass:ActionIn() end

-- function BaseClass:ActionOut() end

return BaseClass