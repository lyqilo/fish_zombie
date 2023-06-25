---------------------------------
-- region TreasureRecordPanel.lua		-
-- Date: 2019.11.11				-
-- Desc:  一元夺宝               -
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureRecordPanel = CC.uu.ClassView("TreasureRecordPanel")

function TreasureRecordPanel:ctor(param)
	self:InitVar(param)
end

function TreasureRecordPanel:InitVar(param)
    self.param = param

    self.PurchasedList = {}
end

function TreasureRecordPanel:OnCreate()

    self.language = CC.LanguageManager.GetLanguage("L_TreasureView");

    local viewCtrClass = require("View/TreasureView/TreasureRecordPanelCtr")

    self.viewCtr = viewCtrClass.new(self,self.param);

    self.LuckyScroller = self:FindChild("BG/LuckyScroller")
    self.PurchaseScroller = self:FindChild("BG/PurchaseScroller")

    self.ScrollerController = self:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
    xpcall(function() self.viewCtr:SetPurchaseData(tran,dataIndex,cellIndex) end,function(error) logError(error) end) end)

    self.ScrollerController:AddRycycleAction(function (tran)
		self:RecyclingPurchase(tran)
	end)

    self.LuckyScrollerController = self:FindChild("LuckyScrollerController"):GetComponent("ScrollerController")
	self.LuckyScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
    xpcall(function() self.viewCtr:SetLuckyData(tran,dataIndex,cellIndex) end,function(error) logError(error) end) end)

    self.viewCtr:OnCreate()

    self:AddClickEvent()

    self:InitTextByLanguage()
end

function TreasureRecordPanel:AddClickEvent()
    self:AddClick("BG/CloseBtn",function ()
        self:ActionOut()
    end)
    	--商品详情
	self:AddClick("BG/Title/Purchase",function ()
		self:FindChild("BG/PurchaseScroller"):SetActive(true)
		self:FindChild("BG/LuckyScroller"):SetActive(false)
	end)
	--幸运儿列表
	self:AddClick("BG/Title/Lucky",function ()
		self:FindChild("BG/PurchaseScroller"):SetActive(false)
		self:FindChild("BG/LuckyScroller"):SetActive(true)
    end)

	UIEvent.AddScrollRectOnValueChange(self.LuckyScroller,function ()
		--大于1再执行不会导致切换聊天类型的刷新
		if self.LuckyScroller:GetComponent("ScrollRect").verticalNormalizedPosition < 0 then
			if not self.isConentDown then
				self.isConentDown = true
				self.viewCtr:Req_PlayerLuckyRecord()
			end
		else
			self.isConentDown = false
		end
    end)

    UIEvent.AddScrollRectOnValueChange(self.PurchaseScroller,function ()
		--大于1再执行不会导致切换聊天类型的刷新
		if self.PurchaseScroller:GetComponent("ScrollRect").verticalNormalizedPosition < 0 then
			if not self.isConentDown then
				self.isConentDown = true
				self.viewCtr:Req_PurchaseRecord()
			end
		else
			self.isConentDown = false
		end
	end)
end

function TreasureRecordPanel:InitTextByLanguage()
    self:FindChild("BG/Title/Purchase/Label").text = self.language.record_title_PurchaseRecord
    self:FindChild("BG/Title/Lucky/Label").text = self.language.record_title_LuckyRecord

    self:FindChild("PurchaseItem/LuckyShow/Label").text = self.language.infor_Lucky
    self:FindChild("PurchaseItem/LuckyShow/Num/Label").text = self.language.top_code
    self:FindChild("PurchaseItem/Wait/Label").text = self.language.record_Wait

    self:FindChild("BG/LuckyScroller/Tips").text = self.language.record_NotPurchase
    self:FindChild("BG/PurchaseScroller/Tips").text = self.language.record_NotWin

    self:FindChild("LuckyItem/Win").text = self.language.record_WinAward
end

function TreasureRecordPanel:InItPurchaseRecord(count,bInit)
    if bInit then
        if count > 0 then
            self.ScrollerController:InitScroller(count)
        else
            self:FindChild("BG/PurchaseScroller/Tips"):SetActive(true)
        end
    else
        self.ScrollerController:RefreshScroller(count,1-self.PurchaseScroller:GetComponent("ScrollRect").verticalNormalizedPosition)
    end
end

function TreasureRecordPanel:InItPlayerLuckyRecord(count,bInit)
    if bInit then
        if count > 0 then
            self.LuckyScrollerController:InitScroller(count)
        else
            self:FindChild("BG/LuckyScroller/Tips"):SetActive(true)
        end
        self:FindChild("BG/LuckyScroller"):SetActive(false)
    else
        self.LuckyScrollerController:RefreshScroller(count,1-self.LuckyScroller:GetComponent("ScrollRect").verticalNormalizedPosition)
    end
end

function TreasureRecordPanel:SetPurchaseItem(tran,param)
    local index = param.PrizeId.."_"..param.Issue
    if self.PurchasedList[index] == nil then
        self.PurchasedList[index] = {}
        self.PurchasedList[index].tran = tran
    else
        self.PurchasedList[index].tran = tran
    end
    tran.name = index
    tran:FindChild("Name").text = param.Name
    tran:FindChild("Name/Issue").text = string.format(self.language.label_Issue,param.Issue)
    self:SetImage(tran:FindChild("Icon"), param.Icon)
    tran:FindChild("Time").text = param.Time
    tran:FindChild("Frequency").text = string.format(self.language.label_NumberPurchased,param.PurchasedTimes)
    tran:FindChild("Underline/Text").text = string.format(self.language.myCode,param.PurchasedTimes)
    if param.Remain then
        tran:FindChild("Remain"):SetActive(true)
    elseif param.proceed then
        tran:FindChild("Wait"):SetActive(true)
        tran:FindChild("Frequency").text = string.format(self.language.infor_purchasedQuota,param.SoldQuota,param.OpenNeedQuota)
    else
        if param.Lucky then
            tran:FindChild("Winning"):SetActive(true)
        else
            tran:FindChild("NotWon"):SetActive(true)
        end
        local PlayerId = param.LuckyPlayer.PlayerId
        local NickName = param.LuckyPlayer.NickName
        local Portrait = param.LuckyPlayer.Portrait
        local WinninerNumber = param.LuckyPlayer.WinninerNumber
        local vip = param.LuckyPlayer.Vip
        self.PurchasedList[index].portrait = self:SetHeadIcon(tran:FindChild("LuckyShow/Node"),PlayerId,Portrait,vip,"unClick")
        tran:FindChild("LuckyShow/Nick").text = NickName
        self:SetWinNum(tran:FindChild("LuckyShow/Num"),WinninerNumber)
        tran:FindChild("LuckyShow"):SetActive(true)
        tran:FindChild("Time"):SetActive(true)
    end
    self:AddClick(tran:FindChild("Underline"), function()
        local data = {}
		data.CodeList = nil
		data.PrizeId = param.PrizeId
		data.Issue = param.Issue
		CC.ViewManager.Open("TreasureCodePanel",param)
    end)
end

function TreasureRecordPanel:RecyclingPurchase(tran)
    local index = tran.name
    tran:FindChild("Time"):SetActive(false)
    tran:FindChild("Winning"):SetActive(false)
    tran:FindChild("NotWon"):SetActive(false)
    tran:FindChild("Wait"):SetActive(false)
    tran:FindChild("Remain"):SetActive(false)
    tran:FindChild("LuckyShow"):SetActive(false)
    if self.PurchasedList[index].portrait then
		self.PurchasedList[index].portrait:Destroy(true)
	end
end

function TreasureRecordPanel:SetLuckyItem(tran,param)
    tran:FindChild("Name").text = param.Name
    tran:FindChild("Name/Issue").text = string.format(self.language.label_Issue,param.Issue)
    self:SetImage(tran:FindChild("Icon"), param.Icon)
    tran:FindChild("Time").text = param.Time
    tran:FindChild("Frequency").text = string.format(self.language.label_NumberPurchased,param.PurchasedTimes)
    self:SetWinNum(tran:FindChild("Num"),param.WinninerNumber)
end

--设置头像
function TreasureRecordPanel:SetHeadIcon(node,id,portrait,level,fun)
	local param = {}
	param.parent = node
	param.playerId = id
	param.portrait = portrait
	param.vipLevel = level
	param.clickFunc = fun
	return CC.HeadManager.CreateHeadIcon(param)
end

function TreasureRecordPanel:SetWinNum(tran,num)
	local sWin = tostring(string.format("1%07d",num))
	local index = 1
	for i = 1, 8 do
		tran:FindChild(i.."/Text").text = string.sub(sWin,index,index)
		index = index + 1
	end
end

function TreasureRecordPanel:OnDestroy()
    for k, v in pairs(self.PurchasedList) do
		if v.portrait then
			v.portrait:Destroy(true)
		end
    end
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return TreasureRecordPanel