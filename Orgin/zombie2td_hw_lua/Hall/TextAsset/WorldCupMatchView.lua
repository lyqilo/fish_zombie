local CC = require("CC")
local WorldCupMatchView = CC.uu.ClassView("WorldCupMatchView")
local M = WorldCupMatchView

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param
    self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")
	self.matchItemList = {}
	self.dateStartIndex = 1
	self.curPage = 1
end

function M:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
	self:InitDropdown()
	self:InitSchedule()
	
	self.viewCtr:StartRequest()
end

function M:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function M:InitContent()
	
	self.scheduleNode = self:FindChild("LeftPanel/Node")
	
	self.rightPanel = self:FindChild("RightPanel")
	self.allMatchPage = self.rightPanel:FindChild("All")
	self.eliminatorPage = self.rightPanel:FindChild("Eliminator")
	self.matchItem = self.allMatchPage:FindChild("Item")
	self.matchList = self.allMatchPage:FindChild("Scroll View/Viewport/Content")
	self.dropDownComp = self.rightPanel:FindChild("Top/Dropdown"):GetComponent("Dropdown")
	self.pageText = self.allMatchPage:FindChild("Page")
	self.btnFront = self.allMatchPage:FindChild("Page/Front")
	self.btnNext = self.allMatchPage:FindChild("Page/Next")
	self.emptyImg = self.allMatchPage:FindChild("Empty")
	
	self.dateList = {}
	for i=1,6 do
		self.dateList[i] = self.allMatchPage:FindChild("Date/"..i)
		UIEvent.AddToggleValueChange(self.dateList[i], function(selected)
				if selected then
					self:OnDateToggleChange(i)
				end
			end)
	end
	self:AddClick(self.btnFront,function ()
			self:OnSwitchMatchPage(self.curPage-1)
		end)
	self:AddClick(self.btnNext,function ()
			self:OnSwitchMatchPage(self.curPage+1)
		end)
	
end

function M:InitTextByLanguage()
	
	self.matchItem:FindChild("Time/Bg/Text").text = ":"
	self.matchItem:FindChild("Team/NText").text = "VS"
	self.matchItem:FindChild("Team/LText").text = "VS"
	self.matchItem:FindChild("Status/Waiting/Text").text = self.language.matchWait
	self.matchItem:FindChild("Status/Playing/Text").text = self.language.matchPlay
end

function M:InitSchedule()
	local data = self.viewCtr.worldCupData.GetHomePageData()
	if not data or table.isEmpty(data) then return end
	self.scheduleBoard = CC.uu.CreateHallView("ScheduleBoard",data.TodayGames)
	self.scheduleBoard.transform:SetParent(self.scheduleNode, false)
end

function M:InitDropdown()
	self.dropDownComp:ClearOptions()
	local dropDownList = {
		[1] = {option = self.language.allMatch},
		[2] = {option = self.language.eliminator},
	}
	local OptionData = UnityEngine.UI.Dropdown.OptionData
	for i,v in ipairs(dropDownList) do
		local data = OptionData.New(v.option)
		self.dropDownComp.options:Add(data)
	end
	UIEvent.AddDropdownValueChange(
		self.dropDownComp.transform,
		function (value)
			self:OnDropdownValueChange(value)
		end)
	self.curOption = 0
	self.dropDownComp.value = self.curOption
	self.dropDownComp:RefreshShownValue()
end

function M:OnDropdownValueChange(value)

	if value == 0 then

	elseif value == 1 then
		self.viewCtr:ReqGetWorldCupChampionSchedule()
	end
	self.allMatchPage:SetActive(value==0)
	self.eliminatorPage:SetActive(value==1)
end

function M:RefreshDate(initIdx)
	for i=1,6 do
		local index = self.dateStartIndex + i-1
		local item = self.dateList[i]
		if self.viewCtr.dateInfoList[index] then
			local ts = self.viewCtr.dateInfoList[index]
			local timeInfo = CC.TimeMgr.GetConvertTimeInfo(ts)
			item:FindChild("Checkmark/Week").text = self.language.wday[timeInfo.wday]
			item:FindChild("Checkmark/Date").text = string.format("%02d/%02d",timeInfo.day,timeInfo.month)
			item:FindChild("Background/Week").text = self.language.wday[timeInfo.wday]
			item:FindChild("Background/Date").text = string.format("%02d/%02d",timeInfo.day,timeInfo.month)
			item:SetActive(true)
		else
			item:SetActive(false)
		end
	end
	self.dateList[initIdx or 1]:GetComponent("Toggle").isOn = false
	self.dateList[initIdx or 1]:GetComponent("Toggle").isOn = true
end

function M:RefreshMatchList(param)
	local itemList = self.matchItemList

	self.emptyImg:SetActive(table.isEmpty(param))
	
	if #itemList > #param then
		for i = #param+1, #itemList do
			itemList[i].transform:SetActive(false)
		end
	end

	for i,v in ipairs(param) do
		if itemList[i] then
			itemList[i].data = v
			itemList[i].onRefreshData(v)
		else
			local item = self:CreateMatchItem(v)
			table.insert(itemList, item)
		end
	end
end

function M:CreateMatchItem(param)
	local item = {}
	item.data = param
	item.transform = CC.uu.newObject(self.matchItem, self.matchList)
	
	item.onRefreshData = function(param)
		local status = param.status
		local timeInfo = CC.TimeMgr.GetConvertTimeInfo(param.startTime)
		item.transform:FindChild("Group").text = param.gameName
		item.transform:FindChild("Time/Hour").text = string.format("%02d",timeInfo.hour)
		item.transform:FindChild("Time/Min").text = string.format("%02d",timeInfo.min)
		for i=1,2 do
			self:SetImage(item.transform:FindChild(string.format("Team/%d",i)),self:GetCircleIconById(param.countrys[i].CountryId))
			item.transform:FindChild(string.format("Team/%d/Name",i)).text = self.language.countryName[param.countrys[i].CountryId]
		end
		item.transform:FindChild("Team/NText"):SetActive(status~=1)
		item.transform:FindChild("Team/LText"):SetActive(status==1)
		item.transform:FindChild("Status/Waiting"):SetActive(status==0)
		item.transform:FindChild("Status/Playing"):SetActive(status==1)
		item.transform:FindChild("Status/Result"):SetActive(status==2)
		item.transform:FindChild("Status/Result").text = string.format("%d:%d",param.countrys[1].Score,param.countrys[2].Score)
		
		item.transform:SetActive(true)
	end
	
	item.onRefreshData(param)
	
	return item
end

function M:RefreshEliminatorList(data)
	local content = self.eliminatorPage:FindChild("Content/")
	for k,v in ipairs(data) do
		for i=1,#v do
			local param = v[i]
			local showNode = param.status == 1 and "Light" or "Dark"
			local item = self.eliminatorPage:FindChild(string.format("Content/%d/%d/%s",k,i,showNode))
			local timeInfo = CC.TimeMgr.GetConvertTimeInfo(param.gameStartTime)
			item:FindChild("Match").text = self.language.matchPhase[k]
			item:FindChild("Time").text = string.format("%02d:%02d",timeInfo.hour,timeInfo.min)
			for j=1,2 do
				self:SetImage(item:FindChild("Team"..j),self:GetCircleIconById(param.country[j].CountryId))
			end
			item:SetActive(true)
		end
	end
end

function M:OnDateToggleChange(index)
	local dateIndex = self.dateStartIndex + index-1
	self.curPage = dateIndex
	self.pageText.text = dateIndex
	self.viewCtr:ReqGetWorldCupSchedule(dateIndex)
end

function M:OnSwitchMatchPage(page)
	if not self.viewCtr.dateInfoList then return end
	if page < 1 or page > #self.viewCtr.dateInfoList then return end
	
	if page >= self.dateStartIndex+6 then
		self.dateStartIndex = self.dateStartIndex + 6
		self:RefreshDate()
	elseif page < self.dateStartIndex then
		self.dateStartIndex = self.dateStartIndex - 6
		self:RefreshDate(6)
	else
		self.dateList[page-self.dateStartIndex+1]:GetComponent("Toggle").isOn = true
	end
end

function M:GetCircleIconById(id)
	return "circle_"..id
end

function M:ActionIn()
	local node = self:FindChild("RightPanel");
	local x,y = node.x,node.y;
	node.x = -1150;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("LeftPanel");
	local x,y = node.x,node.y;
	node.x = -1730;
	self:RunAction(node, {"localMoveTo", x, y, 0.3, delay = 0.1, ease = CC.Action.EOutSine, function() end})
end

function M:ActionOut(cb)

	local node = self:FindChild("LeftPanel");
	self:RunAction(node, {"localMoveTo", -1730, node.y, 0.3, ease = CC.Action.EOutSine, function() end})

	local node = self:FindChild("RightPanel");
	self:RunAction(node, {"localMoveTo", -1150, node.y, 0.3, delay = 0.1, ease = CC.Action.EOutSine, function()
				self:Destroy();
				if cb then cb() end
			end})
end

function M:OnDestroy()
	
	if self.scheduleBoard then
		self.scheduleBoard:Destroy()
		self.scheduleBoard = nil
	end
	
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return WorldCupMatchView