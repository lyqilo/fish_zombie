--[[
	收益查询页
	EarnType.Newer人头收益已使用EarnType.Task替换
]]

local CC = require("CC")

local BaseClass = CC.uu.ClassView("AgentEarningsView")

function BaseClass:ctor(param)
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");

	self.showIndex = 0

	self.param = param
end

function BaseClass:OnCreate()
	self:LoadHistoryEarn()

	self.itemlist = {}

	self:InitContent()
	self:InitTextByLanguage();
	-- self:RegisterEvent()

	-- self:UpdateShow()
end

function BaseClass:InitContent()
	self.mask = self:FindChild("mask")
	if self.param and self.param.guideFun then
		--引导中，禁止按钮
		self:FindChild("content/closeBtn"):GetComponent("Button"):SetBtnEnable(false)
		self:DelayRun(1.1, function ( )
			self:FindChild("content/closeBtn"):GetComponent("Button"):SetBtnEnable(true)
		end)
	end
	self:AddClick(self:FindChild("content/closeBtn"),slot(self.ActionOut,self))

	self:AddClick(self:FindChild("content/main/top/Button"),slot(self.OnSwithBtnClick,self))
	self:AddClick(self:FindChild("content/Total/shareBtn"), function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnChangeAgentView, "AgentShareView")
		self:Destroy()
	end)

	self.itemPrefab = self:FindChild("content/main/item")

	self.contentRoot = self:FindChild("content/main/Scroll View/Viewport/Content")
	self.scrollView = self:SubGet("content/main/Scroll View", "ScrollRect")
	UIEvent.AddScrollRectOnValueChange(self:FindChild("content/main/Scroll View"),function (v)
		if not self.isUpdating and v.y < 0 then
			self:CheckMoreList()
		end
	end)
end

function BaseClass:InitTextByLanguage()
	self:FindChild("content/title").text = self.language.earningstitle

	self:FindChild("content/Total/Text").text = self.language.earningstotal0

	self:FindChild("content/main/top/timeText").text = self.language.earningstime
	self:FindChild("content/main/top/numText").text = self.language.earningsnum
	self:FindChild("content/main/top/nameText").text = self.language.earningstype

	self:FindChild("content/main/bottom/numText/Text").text = self.language.earningstotal0
	self:FindChild("content/main/bottom/des").text = self.language.earnViewDes
end

function BaseClass:CheckMoreList()
	if self.agentDataMgr.GetHistoryEarnCount() > self.agentDataMgr.CurHistoryEarnCount() then
		self.isUpdating = true

		self.agentDataMgr.LoadHistoryEarn(function (data)
			self.isUpdating = false
			if data then
				self:Reflash(self.showIndex)
			else
				self:ActionOut()
			end
		end,self.showIndex,self.agentDataMgr.CurHistoryEarnCount())
	end
end

function BaseClass:LoadHistoryEarn()
	self.agentDataMgr.LoadHistoryEarn(function (data)
		if data then
			self:Reflash(self.showIndex)
		else
			self:ActionOut()
		end
	end,self.showIndex,0)
end

function BaseClass:Reflash(index)
	if self.isDestroy then
		return
	end

	self:UpdateList(self.agentDataMgr.GetHistoryEarn(index))

	self:FindChild("content/main/bottom/numText/Text").text = self.language["earningstotal"..index%4]

	local totalChip = self.agentDataMgr.GetHistoryEarnTotal(index)
	local totalIntegral = self.agentDataMgr.GetHistoryIntegralEarn()
	self:FindChild("content/Total/Chip").text = self.agentDataMgr.GetHistoryEarnTotal(0)
	self:FindChild("content/Total/Integral").text = totalIntegral
	self:FindChild("content/main/bottom/numText/Chip"):SetActive(index == 1 or index == 3)
	self:FindChild("content/main/bottom/numText/ChipIcon"):SetActive(index == 1 or index == 3)
	self:FindChild("content/main/bottom/numText/Integral"):SetActive(index == 2)
	self:FindChild("content/main/bottom/numText/IntegralIcon"):SetActive(index == 2)
	self:FindChild("content/main/bottom/numText/Chip").text = totalChip
	self:FindChild("content/main/bottom/numText/Integral").text = totalIntegral
end

function BaseClass:UpdateList(list)
	list = list or {}
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
	itemTr:FindChild("time").text = os.date("%d/%m/%y-%H:%M:%S",data.endTime) --tostring(data.endTime)
	itemTr:FindChild("num").text = tostring(data.earn)
	itemTr:FindChild("name/Chip"):SetActive(data.propID ~= CC.shared_enums_pb.EPC_New_GiftVoucher)
	itemTr:FindChild("name/Integral"):SetActive(data.propID == CC.shared_enums_pb.EPC_New_GiftVoucher)
	local typeIndex = data.earnType
	if typeIndex == CC.proto.client_agent_pb.EarnFromTask then
		typeIndex = CC.proto.client_agent_pb.EarnFromNewer
	end
	itemTr:FindChild("name").text = self.language["e"..typeIndex%4]
end

function BaseClass:OnSwithBtnClick()
	self.showIndex = self.showIndex + 1
	if self.showIndex == 4 then
		self.showIndex = 0
	end
	self:Reflash(self.showIndex)
end

function BaseClass:OnDestroy()
	self.isDestroy = true
	if self.param and self.param.guideFun then
		self.param.guideFun()
	end
end

-- function BaseClass:ActionIn() end

-- function BaseClass:ActionOut() end

return BaseClass