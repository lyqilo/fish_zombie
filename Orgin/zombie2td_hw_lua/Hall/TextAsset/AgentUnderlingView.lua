local CC = require("CC")
local AgentUnderlingView = CC.uu.ClassView("AgentUnderlingView")

function AgentUnderlingView:ctor(param)
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");
    self.param = param or {}

    --当前页
	self.curPage = 1
	self.totalPage = 1
	self.cursor = 0
	self.curList = {}
	self.lookType = self.param.lookType or CC.proto.client_agent_pb.PartnerRegistrationTask
end

function AgentUnderlingView:OnCreate()
	self:RegisterEvent()
	self:InitTextByLanguage();
	self:LoadSubAgentList()

	self.itemlist = {}

	self:InitContent()
end

function AgentUnderlingView:InitContent()
	self:AddClick(self:FindChild("Panel/closeBtn"),slot(self.ActionOut,self))

    self:AddClick(self:FindChild("Panel/leftBtn"), function()
        self:OnNextPage(false)
    end)
	self:AddClick(self:FindChild("Panel/rightBtn"), function()
        self:OnNextPage(true)
    end)

    self.ScrollerController = self:FindChild("Panel/content/ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:UpdateItem(tran, dataIndex, cellIndex)
	end)

	self.numText = self:FindChild("Panel/numText")
end

function AgentUnderlingView:InitTextByLanguage()
    self:FindChild("Panel/saveText").text = self.language.UnderlingSave
    self:FindChild("Panel/showText").text = self.language.UnderlingShow
    self:FindChild("Panel/content/top/idText").text = self.language.UnderlingId
    self:FindChild("Panel/content/top/vipText").text = self.language.UnderlingVip
    self:FindChild("Panel/content/top/earnText").text = self.language.UnderlingEarn
    self:FindChild("Panel/content/top/stateText").text = self.language.UnderlingState
	self:FindChild("Panel/content/top/timeText").text = self.language.UnderlingTime
	if self.lookType then
		self:FindChild("Panel/title").text = self.language.UnderlingTitle[self.lookType]
	end
end

function AgentUnderlingView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.Reflash, CC.Notifications.NW_PromoteTaskDetail)
end

function AgentUnderlingView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.NW_PromoteTaskDetail)
end

function AgentUnderlingView:OnNextPage(isNext)
	if isNext then
		if self.curPage < self.totalPage then
			local tempPage = self.curPage + 1
			self.cursor = (tempPage - 1) * 100
			self:LoadSubAgentList()
		end
	else
		if self.curPage <= self.totalPage then
			local tempPage = self.curPage - 1
			if tempPage <= 0  then
				--没有上一页
				return
			end
			self.cursor = (tempPage - 1) * 100
			self:LoadSubAgentList()
		end
	end
end

function AgentUnderlingView:LoadSubAgentList()
	CC.Request("PromoteTaskDetail", {taskType = self.lookType, cursor = self.cursor})
end

function AgentUnderlingView:Reflash(err, data)
	log("err = ".. err.."  "..CC.uu.Dump(data, "PromoteTaskDetail",10))

	self.numText.text = string.format(self.language.UnderlingTotalNum, data.completeNum)
	self.totalPage = math.ceil(data.completeNum / 100)
	if self.totalPage < 1 then
		self.totalPage = 1
	end
	if data.nextCursor <= 0 then
		self.curPage = self.totalPage
	else
		self.curPage = math.floor(data.nextCursor / 100)
	end
	self:FindChild("Panel/pageText").text = string.format("%s/%s", self.curPage, self.totalPage)
	local list = data.promoteTaskDetail
	if not list then return end
	self.curList = list
    self.ScrollerController:InitScroller(#list)
end

function AgentUnderlingView:UpdateList(list)
	list = list or self.curList
	if list == nil then
		self:ActionOut()
		return
	end
	--self:CreateItem(#list)
	for i,v in ipairs(list) do
		self:UpdateItem(i,self.itemlist[i].transform,list[i])
	end
end

function AgentUnderlingView:CreateItem(num)
	for i=#self.itemlist + 1,num do
		local go = CC.uu.newObject(self.itemPrefab, self.contentRoot)
		table.insert(self.itemlist,go)
	end
	for i=1,#self.itemlist do
		self.itemlist[i]:SetActive(i<=num)
	end
end

function AgentUnderlingView:UpdateItem(itemTr, index)
	local data = self.curList[index + 1]
	itemTr:FindChild("bg"):SetActive(index % 2 ~= 0)
	itemTr:FindChild("id").text = data.pid
	itemTr:FindChild("earn").text = CC.uu.ChipFormat(data.earn)
	itemTr:FindChild("time").text = os.date("%d-%m-%Y",data.date)
	itemTr:FindChild("state").text = self.language.UnderlingTick
    itemTr:FindChild("state"):SetActive(not data.claimStatus)
    itemTr:FindChild("tick"):SetActive(data.claimStatus)
end

function AgentUnderlingView:OnDestroy()
	self:unRegisterEvent()
end

return AgentUnderlingView