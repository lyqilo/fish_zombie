local CC = require("CC")

local WorldCupRecordView = CC.uu.ClassView("WorldCupRecordView")
local M = WorldCupRecordView

function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {};
	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")

    --当前查看的记录 1(投注记录)2(中奖记录)
    self.curRecord = 1
end

function M:OnCreate()
	self:InitUI()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	self:InitTextByLanguage()
	self:AddClickEvent()
end

function M:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function M:InitUI()
    self.topPanel = self:FindChild("TopPanel")
	self.midPanel = self:FindChild("MidPanel")

    self.topDropdown = self.topPanel:FindChild("Dropdown"):GetComponent("Dropdown")

    self.betContent = self.midPanel:FindChild("BetContent")
    self.winContent = self.midPanel:FindChild("WinContent")
    --投注记录
    self.betDropdown = self.betContent:FindChild("top/Dropdown"):GetComponent("Dropdown")
    self.recordBetScroRect = self.betContent:FindChild("ScrollView"):GetComponent("ScrollRect")
    self.BetScrollerController = self.betContent:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.BetScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:UpdateBetItem(tran, dataIndex, cellIndex)
	end)
    --中奖记录
    self.winDropdown = self.winContent:FindChild("top/Dropdown"):GetComponent("Dropdown")
    self.recordWinScroRect = self.winContent:FindChild("ScrollView"):GetComponent("ScrollRect")
    self.WinScrollerController = self.winContent:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.WinScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:UpdateWinItem(tran, dataIndex, cellIndex)
	end)

    self.pageText = self.midPanel:FindChild("Page")
end

function M:InitTextByLanguage()
	self.topPanel:FindChild("BetRecord/Label").text = self.language.berRecord
    self.topPanel:FindChild("WinRecord/Label").text = self.language.winRecord

    self.betContent:FindChild("top/result").text = self.language.guessResult
    self.betContent:FindChild("top/betNum").text = self.language.betAmount
    self.betContent:FindChild("top/rate").text = self.language.betRate
    self.betContent:FindChild("top/time").text = self.language.betTime
    self.betContent:FindChild("Item/result/Image/Draw").text = self.language.draw
    self.winContent:FindChild("top/time").text = self.language.betTime
    self.winContent:FindChild("top/result").text = self.language.guessResult
    self.winContent:FindChild("top/betNum").text = self.language.betAmount
    self.winContent:FindChild("top/rate").text = self.language.betRate
    self.winContent:FindChild("top/rewardNum").text = self.language.betReward
    self.winContent:FindChild("Bottom/Earn/Text").text = self.language.betEarn
    self.winContent:FindChild("Item/result/Image/Draw").text = self.language.draw
end

function M:AddClickEvent()
    self:AddClick(self.midPanel:FindChild("Page/Front"),function ()
        if self.viewCtr.curPage > 1 then
            self:OnSwitchPage(false)
        end
    end)
    self:AddClick(self.midPanel:FindChild("Page/Next"),function ()
        if self.viewCtr.curPage < self.viewCtr.totalPage then
            self:OnSwitchPage(true)
        end
    end)
    UIEvent.AddToggleValueChange(self.topPanel:FindChild("BetRecord"),function(selected)
        if selected then
            self.curRecord = 1
            self.viewCtr.curPage = 1
            self.viewCtr:ReqGetWorldCupBetRecord()
        end
    end)
    UIEvent.AddToggleValueChange(self.topPanel:FindChild("WinRecord"),function(selected)
        if selected then
            self.curRecord = 2
            self.viewCtr.curPage = 1
            self.viewCtr:ReqGetWorldCupWinRecord()
        end
    end)
    --下拉框
    local OptionData = UnityEngine.UI.Dropdown.OptionData
    self.topDropdown:ClearOptions()
    for i = 1, 3 do
        local option = self.language.recordList[i]
        local data = OptionData.New(option)
        self.topDropdown.options:Add(data)
    end
    UIEvent.AddDropdownValueChange(self.topDropdown.transform, function (value)
		self:OnTopDropdownValueChange(value)
	end)
	self.topDropdown.value = 0
	self.topDropdown:RefreshShownValue()
    --投注记录
    self.betDropdown:ClearOptions()
    for i = 1, 3 do
        local option = self.language.recordAreaList[i]
        local data = OptionData.New(option)
        self.betDropdown.options:Add(data)
    end
    UIEvent.AddDropdownValueChange(self.betDropdown.transform, function (value)
		self:OnBetDropdownValueChange(value)
	end)
	self.betDropdown.value = 0
	self.betDropdown:RefreshShownValue()
    --中奖记录
    self.winDropdown:ClearOptions()
    for i = 1, 3 do
        local option = self.language.recordAreaList[i]
        local data = OptionData.New(option)
        self.winDropdown.options:Add(data)
    end
    UIEvent.AddDropdownValueChange(self.winDropdown.transform, function (value)
		self:OnWinDropdownValueChange(value)
	end)
	self.winDropdown.value = 0
	self.winDropdown:RefreshShownValue()
end

--切换页
function M:OnSwitchPage(isNext)
    self.viewCtr.curPage = isNext and self.viewCtr.curPage + 1 or self.viewCtr.curPage - 1
    if self.curRecord == 1 then
        self.viewCtr:ReqGetWorldCupBetRecord()
    elseif self.curRecord == 2 then
        self.viewCtr:ReqGetWorldCupWinRecord()
    end
end

--投注类型dropdown变化
function M:OnTopDropdownValueChange(value)
    self.viewCtr:SetGameType(value)
    if self.curRecord == 1 then
        self.viewCtr:ReqGetWorldCupBetRecord()
    elseif self.curRecord == 2 then
        self.viewCtr:ReqGetWorldCupWinRecord()
    end
end

--投注记录dropdown变化
function M:OnBetDropdownValueChange(value)
    self.viewCtr:SetBetRecentDay(value)
    self.viewCtr:ReqGetWorldCupBetRecord()
end

--中奖记录dropdown变化
function M:OnWinDropdownValueChange(value)
    self.viewCtr:SetWinRecentDay(value)
    self.viewCtr:ReqGetWorldCupWinRecord()
end

function M:UpdateBetItem(itemTr, index)
    --数据位置index
    local dataIndex = index + (self.viewCtr.curPage - 1) * 10 + 1
	local data = self.viewCtr.betRecordList[self.viewCtr.curGameTpye][self.viewCtr.betRecentDay][dataIndex]
    if not data then return end
    itemTr.name = tostring(index + 1)
	if data.OrderId then
        local number = #tostring(data.OrderId)
        if number >= 6 then
            for i = 1, 6 do
                itemTr:FindChild("id/"..i.."/Text").text = string.sub(data.OrderId,i,i)
            end
        end
    end
    itemTr:FindChild("betNum").text = CC.uu.Chipformat2(data.BetAmount)
    itemTr:FindChild("rate").text = data.BetOdds
    local date = CC.TimeMgr.GetTimeFormat3(data.BetTime)
    local time = CC.TimeMgr.GetTimeFormat2(data.BetTime)
	itemTr:FindChild("time").text = string.format("%s\n%s", date, time)
    if data.GameType == CC.shared_enums_pb.WC_GroupGame then
        --单场投注
        if data.Country and #data.Country >= 2 then
            local icon = "square_" .. data.Country[1].CountryId
            self:SetImage(itemTr:FindChild("result/Left/icon"), icon)
            local icon2 = "square_" .. data.Country[2].CountryId
            self:SetImage(itemTr:FindChild("result/Right/icon"), icon2)
            itemTr:FindChild("result/Left").localPosition = Vector3(-95,0,0)
            itemTr:FindChild("result/Image"):SetActive(true)
            itemTr:FindChild("result/Right"):SetActive(true)
            if data.BetCountryId == data.Country[1].CountryId or data.BetCountryId == data.Country[2].CountryId then
                itemTr:FindChild("result/Left/win"):SetActive(data.BetCountryId == data.Country[1].CountryId)
                itemTr:FindChild("result/Left/mask"):SetActive(data.BetCountryId ~= data.Country[1].CountryId)
                itemTr:FindChild("result/Right/win"):SetActive(data.BetCountryId == data.Country[2].CountryId)
                itemTr:FindChild("result/Right/mask"):SetActive(data.BetCountryId ~= data.Country[2].CountryId)
                itemTr:FindChild("result/Image/Win"):SetActive(true)
                itemTr:FindChild("result/Image/Draw"):SetActive(false)
            else
                itemTr:FindChild("result/Left/win"):SetActive(false)
                itemTr:FindChild("result/Left/mask"):SetActive(false)
                itemTr:FindChild("result/Right/win"):SetActive(false)
                itemTr:FindChild("result/Right/mask"):SetActive(false)
                itemTr:FindChild("result/Image/Win"):SetActive(false)
                itemTr:FindChild("result/Image/Draw"):SetActive(true)
            end
        end
    elseif data.GameType == CC.shared_enums_pb.WC_ChampionGame then
        --冠军投注
        local icon = "square_" .. data.BetCountryId
        self:SetImage(itemTr:FindChild("result/Left/icon"), icon)
        itemTr:FindChild("result/Left").localPosition = Vector3.zero
        itemTr:FindChild("result/Left/win"):SetActive(true)
        itemTr:FindChild("result/Left/mask"):SetActive(false)
        itemTr:FindChild("result/Image"):SetActive(false)
        itemTr:FindChild("result/Right"):SetActive(false)
    end
end

function M:UpdateWinItem(itemTr, index)
    --数据位置index
    local dataIndex = index + (self.viewCtr.curPage - 1) * 10 + 1
	local data = self.viewCtr.winRecordList[self.viewCtr.curGameTpye][self.viewCtr.betRecentDay][dataIndex]
    if not data then return end
    itemTr.name = tostring(index + 1)
    if data.OrderId then
        local number = #tostring(data.OrderId)
        if number >= 6 then
            for i = 1, 6 do
                itemTr:FindChild("id/"..i.."/Text").text = string.sub(data.OrderId,i,i)
            end
        end
    end
    itemTr:FindChild("betNum").text = CC.uu.Chipformat2(data.BetAmount)
    itemTr:FindChild("rate").text = data.BetOdds
    itemTr:FindChild("reward").text = CC.uu.Chipformat2(data.Reward)
    local date = CC.TimeMgr.GetTimeFormat3(data.BetTime)
    local time = CC.TimeMgr.GetTimeFormat2(data.BetTime)
    itemTr:FindChild("time").text = string.format("%s\n%s", date, time)
    if data.GameType == CC.shared_enums_pb.WC_GroupGame then
        --单场投注
        if data.Country and #data.Country >= 2 then
            local icon = "square_" .. data.Country[1].CountryId
            self:SetImage(itemTr:FindChild("result/Left/icon"), icon)
            local icon2 = "square_" .. data.Country[2].CountryId
            self:SetImage(itemTr:FindChild("result/Right/icon"), icon2)
            itemTr:FindChild("result/Left").localPosition = Vector3(-95,0,0)
            itemTr:FindChild("result/Image"):SetActive(true)
            itemTr:FindChild("result/Right"):SetActive(true)
            if data.BetCountryId == data.Country[1].CountryId or data.BetCountryId == data.Country[2].CountryId then
                itemTr:FindChild("result/Left/win"):SetActive(data.BetCountryId == data.Country[1].CountryId)
                itemTr:FindChild("result/Left/mask"):SetActive(data.BetCountryId ~= data.Country[1].CountryId)
                itemTr:FindChild("result/Right/win"):SetActive(data.BetCountryId == data.Country[2].CountryId)
                itemTr:FindChild("result/Right/mask"):SetActive(data.BetCountryId ~= data.Country[2].CountryId)
                itemTr:FindChild("result/Image/Win"):SetActive(true)
                itemTr:FindChild("result/Image/Draw"):SetActive(false)
            else
                itemTr:FindChild("result/Left/win"):SetActive(false)
                itemTr:FindChild("result/Left/mask"):SetActive(false)
                itemTr:FindChild("result/Right/win"):SetActive(false)
                itemTr:FindChild("result/Right/mask"):SetActive(false)
                itemTr:FindChild("result/Image/Win"):SetActive(false)
                itemTr:FindChild("result/Image/Draw"):SetActive(true)
            end
        end
    elseif data.GameType == CC.shared_enums_pb.WC_ChampionGame then
        --冠军投注
        local icon = "square_" .. data.BetCountryId
        self:SetImage(itemTr:FindChild("result/Left/icon"), icon)
        itemTr:FindChild("result/Left").localPosition = Vector3.zero
        itemTr:FindChild("result/Left/win"):SetActive(true)
        itemTr:FindChild("result/Left/mask"):SetActive(false)
        itemTr:FindChild("result/Image"):SetActive(false)
        itemTr:FindChild("result/Right"):SetActive(false)
    end
end

function M:RefreshPage()
    self.viewCtr.totalPage = self.viewCtr:GetTotalPage(self.curRecord)
    self.pageText:SetActive(self.viewCtr.totalPage > 0)
    self.pageText.text = string.format("%s/%s", self.viewCtr.curPage, self.viewCtr.totalPage)
end

function M:RefreshEarn(totalEarn)
    self.winContent:FindChild("Bottom/Earn").text = CC.uu.Chipformat2(totalEarn)
end

function M:ActionIn()
    local topNode = self:FindChild("TopPanel");
	local x,y = topNode.x,topNode.y;
	topNode.x = -1300;
	self:RunAction(topNode, {"localMoveTo", x, y, 0.3, ease = CC.Action.EOutSine, function() end})

	local midNode = self:FindChild("MidPanel");
	local x,y = midNode.x,midNode.y;
	midNode.x = -1300;
	self:RunAction(midNode, {"localMoveTo", x, y, 0.3, ease = CC.Action.EOutSine, function() end})
end

function M:ActionOut(cb)
    local topNode = self:FindChild("TopPanel");
	self:RunAction(topNode, {"localMoveTo", -1300, topNode.y, 0.3, ease = CC.Action.EOutSine, function() end})

	local midNode = self:FindChild("MidPanel");
	self:RunAction(midNode, {"localMoveTo", -1300, midNode.y, 0.3, ease = CC.Action.EOutSine, function()
		self:Destroy();
		if cb then cb() end
	end})
end

function M:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
	end
end

return M