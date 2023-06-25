local CC = require("CC")
local MonthRankView = CC.uu.ClassView("MonthRankView")

--需要同时修改MonthRankRuleView
local RewardConfig = {}
RewardConfig[1] = {
    [1] = {{Image = "prop_img_20022",Des = "Oppo A92"},{Image = "prop_img_20021",Des = "10000000"}},
    [2] = {Image = "prop_img_2",Des = "50000000ชิป"},
    [3] = {Image = "prop_img_2",Des = "30000000ชิป"},
    [4] = {Image = "prop_img_2",Des = "20000000ชิป"},
    [5] = {Image = "prop_img_2",Des = "10000000ชิป"},
    [6] = {Image = "prop_img_2",Des = "5000000ชิป"},
    [7] = {Image = "prop_img_2",Des = "5000000ชิป"},
    [8] = {Image = "prop_img_2",Des = "3000000ชิป"},
    [9] = {Image = "prop_img_2",Des = "1000000ชิป"},
}
--捕获类
RewardConfig[3] = {
    --[1] = {{Image = "prop_img_20006",Des = "สร้อยทอง 1 บาท"},{Image = "prop_img_2",Des = "50000000"}},
    -- [1] = {{Image = "prop_img_20102",Des = "iPhone 14 128GB"},{Image = "prop_img_2",Des = "10,000,000"}},
    -- [2] = {{Image = "prop_img_20109",Des = "Apple Watch Series 8"},{Image = "prop_img_2",Des = "9,000,000"}},
    -- [3] = {{Image = "prop_img_20020",Des = "ipad10.2"},{Image = "prop_img_2",Des = "8,000,000"}},
    [1] = {{Image = "prop_img_2",Des = "400Mชิป"}},
    [2] = {{Image = "prop_img_2",Des = "200Mชิป"}},
    [3] = {{Image = "prop_img_2",Des = "150Mชิป"}},
    [4] = {Image = "prop_img_2",Des = "8Mชิป"},
    [5] = {Image = "prop_img_2",Des = "8Mชิป"},
    [6] = {Image = "prop_img_2",Des = "7Mชิป"},
    [7] = {Image = "prop_img_2",Des = "7Mชิป"},
    [8] = {Image = "prop_img_2",Des = "5Mชิป"},
    [9] = {Image = "prop_img_2",Des = "2Mชิป"},
}
RewardConfig[5] = {
    [1] = {{Image = "prop_img_20022",Des = "Oppo A92"},{Image = "prop_img_2",Des = "10000000"}},
    [2] = {Image = "prop_img_2",Des = "50000000ชิป"},
    [3] = {Image = "prop_img_2",Des = "30000000ชิป"},
    [4] = {Image = "prop_img_2",Des = "20000000ชิป"},
    [5] = {Image = "prop_img_2",Des = "10000000ชิป"},
    [6] = {Image = "prop_img_2",Des = "5000000ชิป"},
    [7] = {Image = "prop_img_2",Des = "5000000ชิป"},
    [8] = {Image = "prop_img_2",Des = "3000000ชิป"},
    [9] = {Image = "prop_img_2",Des = "1000000ชิป"},
}
--综合类
RewardConfig[6] = {
    --[1] = {{Image = "prop_img_20006",Des = "สร้อยทอง 1 บาท"},{Image = "prop_img_2",Des = "50000000"}},
    [1] = {{Image = "prop_img_2",Des = "400Mชิป"}},
    [2] = {{Image = "prop_img_2",Des = "200Mชิป"}},
    [3] = {{Image = "prop_img_2",Des = "150Mชิป"}},
    [4] = {Image = "prop_img_2",Des = "8Mชิป"},
    [5] = {Image = "prop_img_2",Des = "8Mชิป"},
    [6] = {Image = "prop_img_2",Des = "7Mชิป"},
    [7] = {Image = "prop_img_2",Des = "7Mชิป"},
    [8] = {Image = "prop_img_2",Des = "5Mชิป"},
    [9] = {Image = "prop_img_2",Des = "2Mชิป"},
}

function MonthRankView:ctor(param)
    self.param = param
    self.RankDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RankData")
    self.language = self:GetLanguage()
    self.PortraitTable = {}
    self.Type = nil
end

function MonthRankView:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)

    self.MyIcon = nil
	self:Init()
    self:AddClickEvent()
end

function MonthRankView:Init()
    self.topPanel = self:FindChild("UI_Layout/ToggleBG")
    self.noData = self:FindChild("UI_Layout/NoData")
    self.selfRank = self:FindChild("UI_Layout/SelfRank/Rank/Text")
    self.selfScore = self:FindChild("UI_Layout/SelfRank/Chip/Text")

    self.ToggleGroup = {}
	self.ToggleGroup[1] = self.topPanel:FindChild("LeisureBtn")
	self.ToggleGroup[2] = self.topPanel:FindChild("SlotBtn")
    self.ToggleGroup[3] = self.topPanel:FindChild("SingleBtn")
    self.ToggleGroup[4] = self.topPanel:FindChild("PokerBtn")
    self.ToggleGroup[5] = self.topPanel:FindChild("OtherBtn")

    --根据活动要求屏蔽按钮
    self.ToggleGroup[2]:SetActive(false)
    self.ToggleGroup[3]:SetActive(false)
    self.ToggleGroup[4]:SetActive(false)
    ---------------------------------------------------------------------------

    self.topPanel:FindChild("LeisureBtn/Label").text = self.language.LeisureBtn
    self.topPanel:FindChild("SlotBtn/Label").text = self.language.SlotBtn
    self.topPanel:FindChild("SingleBtn/Label").text = self.language.SingleBtn
    self.topPanel:FindChild("PokerBtn/Label").text = self.language.PokerBtn
    self.topPanel:FindChild("OtherBtn/Label").text = self.language.OtherBtn
    --活动时间位置偏移
    self.ActiveTime = self:FindChild("UI_Layout/Time")
    self.ActiveTime.text = self.language.timeDes
    self.ActiveTime.localPosition = self.ActiveTime.localPosition + Vector3(-22,0,0)

    self:FindChild("UI_Layout/NoData/Text").text = self.language.noData

    self.ScrollerController = self:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self.viewCtr:InitRankInfo(tran,dataIndex,cellIndex)
	end)
	self.ScrollerController:AddRycycleAction(function (tran)
		self:RecycleItem(tran)
    end)
    self.viewCtr:OnCreate()

    if self.param and self.param.id then
        self:FindChild("Mask"):SetActive(true)
        self:FindChild("UI_Layout/CloseBtn"):SetActive(true)
        self.topPanel:SetActive(false)
    else
        self:FindChild("Mask"):SetActive(false)
        self:FindChild("UI_Layout/CloseBtn"):SetActive(false)
        self.topPanel:SetActive(true)
    end

    local param = {}
	param.parent = self:FindChild("UI_Layout/SelfRank/Node")
	param.clickFunc = "unClick"
    self.MyIcon =  CC.HeadManager.CreateHeadIcon(param)
end

function MonthRankView:AddClickEvent()
    --4个按钮切换按钮
    for i = 1,5 do
        self:AddClick(self.ToggleGroup[i],function(obj) self:ClickTabBtn(obj) end)
    end

    self:AddClick("UI_Layout/TipsBtn",function ()
        self.viewCtr:OpenRuleView()
    end)
    self:AddClick("UI_Layout/CloseBtn","ActionOut")
end

function MonthRankView:ClickTabBtn(obj)
    local _btnName = obj.gameObject.name
	if _btnName == self.hisTabClick then return end
	if _btnName == "LeisureBtn" then
        --老虎机排行榜
        self.viewCtr:SwitchType(CC.shared_enums_pb.GST_Catch)
    elseif _btnName == "OtherBtn" then
        --综合榜
        self.viewCtr:SwitchType(CC.shared_enums_pb.GST_NotCatch)
	elseif _btnName == "SlotBtn" then
		--休闲排行榜
        self.viewCtr:SwitchType(CC.shared_enums_pb.GST_Slot)
    elseif _btnName == "SingleBtn" then
		--单人游戏
        self.viewCtr:SwitchType(CC.shared_enums_pb.GST_PokerPBHYX)
	else
		--多人棋牌游戏
        self.viewCtr:SwitchType(CC.shared_enums_pb.GST_PokerDKT)
	end
	--上次点击tabBtn
	self.hisTabClick = _btnName
end

function MonthRankView:RefreshRank(Type)
    self.Type = Type
    local rankData = self.RankDataMgr.GetMonthRankData(Type) or {}
    local count = #rankData - 1
    if count < 0 then
        count = 0
        self.noData:SetActive(true)
        self:RefreshSelfInfo({{Rank = -1,Score = 0}})
    else
        self.noData:SetActive(false)
        self:RefreshSelfInfo(rankData)
    end
    self.ScrollerController:InitScroller(count)
end

function MonthRankView:RefreshSelfInfo(data)
    local selfInfo = data[#data]
    local rank = self.language.noRank
    if selfInfo.Rank >= 0 then
        rank = selfInfo.Rank + 1
    end
    self.selfRank.text = tostring(rank)
    self.selfScore.text = CC.uu.ChipFormat(selfInfo.Score)
end

function MonthRankView:RefreshItem(tran,rankInfo)
    local PlayerId = rankInfo.PlayerId
    local Rank = rankInfo.Rank + 1
    local Score = rankInfo.Score
    local Vip = rankInfo.Vip
    local Name = rankInfo.Name
    local Portrait = rankInfo.Portrait
    local Background = rankInfo.Background

    tran.name = PlayerId

    if Rank <= 3 then
        tran:FindChild("Rank"):SetActive(false)
        tran:FindChild("Effect"):SetActive(true)
        for i=1,3 do
            if i == Rank then
                tran:FindChild("Effect/"..i):SetActive(true)
            else
                tran:FindChild("Effect/"..i):SetActive(false)
            end
        end
    else
        tran:FindChild("Effect"):SetActive(false)
        tran:FindChild("Rank"):SetActive(true)
        tran:FindChild("Rank/Text").text = Rank
    end
    tran:FindChild("Nick").text = Name
    tran:FindChild("Score").text = CC.uu.ChipFormat(Score)
    local headNode = tran:FindChild("Node")
	local param = {}
	param.parent = headNode
	param.playerId = PlayerId
	param.portrait = Portrait
	param.vipLevel = Vip
	param.headFrame = Background
    self:SetHeadIcon(param,tostring(PlayerId))
    -- if Rank <= 3 then
    --     tran:FindChild("More"):SetActive(true)
    --     tran:FindChild("Single"):SetActive(false)
    --     local icon,des = self:SetAwardInfo(Rank)
    --     self:SetImage(tran:FindChild("More/1"),icon)
    --     tran:FindChild("More/1/1Des").text = des
    --     tran:FindChild("More/1"):GetComponent("Image"):SetNativeSize()
    --     tran:FindChild("More/2/2Des").text = RewardConfig[self.Type][Rank][2].Des
    -- else
        tran:FindChild("More"):SetActive(false)
        tran:FindChild("Single"):SetActive(true)
        local icon,des = self:SetAwardInfo(Rank)
        self:SetImage(tran:FindChild("Single/Reward"),icon)
        tran:FindChild("Single/Des").text = des
        tran:FindChild("Single/Reward"):GetComponent("Image"):SetNativeSize()
    -- end
end

function MonthRankView:SetAwardInfo(rank)
    local icon,des
    if rank == 1 then
        icon = RewardConfig[self.Type][1][1].Image
        des = RewardConfig[self.Type][1][1].Des
    elseif rank == 2 then
        icon = RewardConfig[self.Type][2][1].Image
        des = RewardConfig[self.Type][2][1].Des
    elseif rank == 3 then
        icon = RewardConfig[self.Type][3][1].Image
        des = RewardConfig[self.Type][3][1].Des
    elseif rank == 4 then
        icon = RewardConfig[self.Type][4].Image
        des = RewardConfig[self.Type][4].Des
    elseif rank == 5 then
        icon = RewardConfig[self.Type][5].Image
        des = RewardConfig[self.Type][5].Des
    elseif rank == 6 then
        icon = RewardConfig[self.Type][6].Image
        des = RewardConfig[self.Type][6].Des
    elseif rank <= 10 then
        icon = RewardConfig[self.Type][7].Image
        des = RewardConfig[self.Type][7].Des
    elseif rank <= 20 then
        icon = RewardConfig[self.Type][8].Image
        des = RewardConfig[self.Type][8].Des
    else
        icon = RewardConfig[self.Type][9].Image
        des = RewardConfig[self.Type][9].Des
    end
    return icon,des
end

function MonthRankView:SetHeadIcon(param,index)
    self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
    self.PortraitTable[index] = self.HeadIcon
end

function MonthRankView:RecycleItem(tran)
    --对象回收，清空头像数据
    local index = tran.name
	if self.PortraitTable[index] then
		self.PortraitTable[index]:Destroy(true)
	end
end

function MonthRankView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function MonthRankView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function MonthRankView:OnDestroy()
    if self.param and self.param.id then
        CC.DataMgrCenter.Inst():GetDataByKey("RankData").ClearData()
    end
    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
    if self.MyIcon then
        self.MyIcon:Destroy()
        self.MyIcon = nil
    end
    --销毁主界面展示头像
    for _,v in pairs(self.PortraitTable) do
        if v then
            v:Destroy()
            v = nil
        end
    end
    self.ScrollerController = nil
end


return MonthRankView