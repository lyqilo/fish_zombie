local CC = require("CC")

local SongkranRankView = CC.uu.ClassView("SongkranRankView")

local RankConfig = {
    [1] = {Image = "yfb_pm_lhj"},
    [2] = {Image = "yfb_pm_qpl"},
    [3] = {Image = "yfb_pm_xxl"}
}

local RewardConfig = {
    [1] = {Image = "yfb_jp_01",Des = "OPPO A5\n2020"},
    [2] = {Image = "yfb_jp_02",Des = "JBL Tune\n120TWS"},
    [3] = {Image = "yfb_jp_03",Des = "1000THB"},
    [4] = {Image = "rewardIcon_2",Des = "3000Kชิป"},
    [5] = {Image = "rewardIcon_2",Des = "1000Kชิป"},
}

local ChipConfig = {
    [1] = {Image = "rewardIcon_2",Des = "10000Kชิป"},
    [2] = {Image = "rewardIcon_2",Des = "5000Kชิป"},
    [3] = {Image = "rewardIcon_2",Des = "3000Kชิป"},
    [4] = {Image = "rewardIcon_2",Des = "1000Kชิป"},
    [5] = {Image = "rewardIcon_2",Des = "500Kชิป"},
    [6] = {Image = "rewardIcon_2",Des = "200Kชิป"},
}

function SongkranRankView:ctor(param)
    self.param = param

    self.RankDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RankData")

    self.MyIcon = nil

    self.rankShow = {}
    self.rankHeadIcon = {}

    self.RankNum = 0
    self.IconTab = {}

    self.RankTogGroup = {}
    self.currentType = nil
end

function SongkranRankView:OnCreate()
    self.language = self:GetLanguage()
    
    self:InitUI()

    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
	self:InitTextByLanguage()

	self:AddClickEvent()
end

function SongkranRankView:InitUI()
    --主界面
    self.timeLimit = self:FindChild("Layer_UI/Time")
    --排行榜显示

    for i = 1,3 do
        table.insert(self.rankShow,self:FindChild("Layer_UI/Rank_"..i))
        table.insert(self.RankTogGroup,{Btn = self:FindChild("Layer_Rank/Ranking/paihanban/tu0"..i),Text = self:FindChild("Layer_Rank/Ranking/paihanban/tu0"..i.."/Image")})
        self.rankShow[i]:FindChild("Button/Text").text = self.language.moreBtn
    end

    ----大排行榜
	self.ranking = self:FindChild("Layer_Rank/Ranking")
	self.LoopScrollRect = self:FindChild("Layer_Rank/Ranking/VerticalScroll"):GetComponent("LoopScrollRect")
    self.VerticalLayoutGroup = self.LoopScrollRect.transform:FindChild("Content"):GetComponent("VerticalLayoutGroup")

    self.myRank = self:FindChild("Layer_Rank/Ranking/Down/Rank")
    self.myScore = self:FindChild("Layer_Rank/Ranking/Down/Score/Text")
    
    self.LoopScrollRect:AddChangeItemListener(function(tran,index) 	
		self:ItemData(tran,index)
    end)
    
    self.LoopScrollRect:ToPoolItemListenner(function(tran,index) 	
		self:ReturnToPool(tran,index)
    end)

    local param = {}
	param.parent = self:FindChild("Layer_Rank/Ranking/Down/Node")
	param.clickFunc = "unClick"
    self.MyIcon =  CC.HeadManager.CreateHeadIcon(param)
end

function SongkranRankView:ItemData(tran,index)
    local rankId = index + 1
    local icon = nil
    local des = nil
	self.RankNum = self.RankNum + 1
	tran.name = tostring(rankId)
	local itemData =  self.RankDataMgr.GetSongkranRankInfo(self.currentType,rankId)
	if not itemData then return end
	tran.transform:FindChild("ItemImg/ItemText"):GetComponent("Text").text = tostring(rankId)
	tran.transform:FindChild("ItemName"):GetComponent("Text").text = itemData.Name
    tran.transform:FindChild("ItemMoneyImg/ItemMoneyText"):GetComponent("Text").text = CC.uu.ChipFormat(itemData.Score)
    icon,des = self:SetAwardInfo(rankId)
	self:SpriteInfo(rankId,tran,icon,des)
	local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	local param = {}
	param.parent = headNode
	param.playerId = itemData.PlayerId
    param.portrait = itemData.Portrait
    param.headFrame = itemData.Background
	param.vipLevel = itemData.Vip
	self:SetHeadIcon(headNode,param,self.RankNum)
	self:TranLocalMoveTo(self.VerticalLayoutGroup,tran,index,rankId,self.LoopScrollRect,self.RankDataMgr.GetSongkranRankCount(self.currentType)-1)
end

function SongkranRankView:SetAwardInfo(rank)
    local icon = ChipConfig[1].Image
    local des = ChipConfig[1].Des
    if self.currentType == 0 then
        if rank == 1 then
            des = ChipConfig[1].Des
        elseif rank == 2 then
            des = ChipConfig[2].Des
        elseif rank == 3 then
            des = ChipConfig[3].Des
        elseif rank <= 10 then
            des = ChipConfig[4].Des
        elseif rank <= 30 then
            des = ChipConfig[5].Des
        else
            des = ChipConfig[6].Des
        end
    else
        if rank == 1 then
            icon = RewardConfig[1].Image
            des = RewardConfig[1].Des
        elseif rank == 2 then
            icon = RewardConfig[2].Image
            des = RewardConfig[2].Des
        elseif rank == 3 then
            icon = RewardConfig[3].Image
            des = RewardConfig[3].Des
        elseif rank <= 10 then
            icon = RewardConfig[4].Image
            des = RewardConfig[4].Des
        else
            icon = RewardConfig[5].Image
            des = RewardConfig[5].Des
        end
    end
    return icon,des
end

function SongkranRankView:SpriteInfo(rankId,tran,icon,des)
    if rankId <= 3 then
		if rankId == 1 then
			tran:FindChild("EffectObj/"..tostring(1)):SetActive(true)
			tran:FindChild("EffectObj/"..tostring(2)):SetActive(false)
            tran:FindChild("EffectObj/"..tostring(3)):SetActive(false)

		elseif rankId == 2 then
			tran:FindChild("EffectObj/"..tostring(1)):SetActive(false)
			tran:FindChild("EffectObj/"..tostring(2)):SetActive(true)
            tran:FindChild("EffectObj/"..tostring(3)):SetActive(false)
		elseif rankId == 3 then
			tran:FindChild("EffectObj/"..tostring(1)):SetActive(false)
			tran:FindChild("EffectObj/"..tostring(2)):SetActive(false)
            tran:FindChild("EffectObj/"..tostring(3)):SetActive(true)
        end
        tran:FindChild("EffectObj"):SetActive(true)
        tran:FindChild("ItemImg"):SetActive(false)
    else
		tran:FindChild("EffectObj"):SetActive(false)
        tran:FindChild("ItemImg"):SetActive(true)
    end
    self:SetImage(tran:FindChild("ItemAwardImg"),icon)
    tran:FindChild("ItemAwardDes").text = des
    tran:FindChild("ItemAwardImg"):GetComponent("Image"):SetNativeSize()
end


--执行dotween
function SongkranRankView:TranLocalMoveTo(VerticalLayoutGroup,tran,index,rankId,LoopScrollRect,len)
    if VerticalLayoutGroup.enabled == false then
		tran.transform.localPosition = Vector3(630,-50 + (index * -108.3),0)
        self:RunAction(tran, {"localMoveTo", 0, -50 + (index * -108.3),0.1 * rankId, function()
			local count = 0
			if len <= 4 then
				count = len
			elseif len >= 6 then
				count = 6
            end
            if rankId >= count then
	  			VerticalLayoutGroup.enabled = true
	  			self:RankListCount(LoopScrollRect,len)
	  			return
	  		end
		end})
	end	
end

function SongkranRankView:ReturnToPool(tran,index)
	local headNode = tran.transform:FindChild("ItemHeadMask/Node")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
end

function SongkranRankView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end	
end

function SongkranRankView:SetHeadIcon(headNode,param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function SongkranRankView:InitRank()
    for i = 1,3 do
        for rank = 1,3 do
            self:InitRankShow(self.rankShow[i],i,rank)
        end
    end
end

function SongkranRankView:InitRankShow(obj,Type,rank)
    local data = self.RankDataMgr.GetSongkranRankInfo(Type,rank)
    if data and data.Rank == rank - 1  then
        obj:FindChild(rank.."/Name").text = data.Name
        local node = obj:FindChild(rank.."/Node")
        local param = {}
        param.parent = node
        param.playerId = data.PlayerId
        param.vipLevel = data.Vip
        param.portrait = data.Portrait
        param.headFrame = data.Background
        local icon = CC.HeadManager.CreateHeadIcon(param)
        table.insert(self.rankHeadIcon,icon)
    end
end

function SongkranRankView:InitTextByLanguage()
    self:FindChild("Layer_Rank/Ranking/Down/Label").text = self.language.myrankings
    self:FindChild("Layer_UI/Time").text = self.language.Time
end

function SongkranRankView:AddClickEvent()
    --打开活动提示
    self:AddClick("Layer_UI/BtnTips",function () 
        CC.ViewManager.Open("CommonExplainView",{title = self.language.explainTitle, content = self.language.explainContent});
    end)

    for i = 1 , 3 do
        self:AddClick("Layer_UI/Rank_"..i.."/Button",function()
            self:OpenRankPanel(i)
            self:FindChild("Layer_UI/BtnWeek"):SetActive(false)
        end)
        self:AddClick(self.RankTogGroup[i].Btn,function ()
            self:SwitchRank(i)
        end)
    end


    self:AddClick("Layer_UI/BtnWeek",function ()
        self:OpenRankPanel(0)
        self:FindChild("Layer_UI/BtnWeek"):SetActive(false)
    end)

    self:AddClick("Layer_Rank/BtnClose",function ()
        self:FindChild("Layer_UI/BtnWeek"):SetActive(true)
        self:FindChild("Layer_Rank"):SetActive(false)
        self.LoopScrollRect:ClearCells()
    end)
end

function SongkranRankView:OpenRankPanel(Type)
    self.currentType = Type
    if Type == 0 then
        --打开总榜
        self:ShowTotalRankBtn(true)
    else
        --打开各个小榜
        self:ShowTotalRankBtn(false)
        self:SetBtnHighlight(Type)
    end
    self:InitIntactRank(Type)
end

function SongkranRankView:SwitchRank(Type)
    if self.currentType == Type then 
        return 
    else
        self.currentType = Type
        self:SetBtnHighlight(Type)
        self:StopAllAction()
        self.LoopScrollRect:ClearCells()
        self:SetNewLen(self.LoopScrollRect)
        self.LoopScrollRect:RefillCells(0)
        self:RefreshMyselfInfo(Type)
    end
end

function SongkranRankView:RefreshMyselfInfo(Type)
    local index = self.RankDataMgr.GetSongkranRankCount(Type)
    local data = self.RankDataMgr.GetSongkranRankInfo(Type,index)
    local rank = self.language.norankin
    if data.Rank >= 0 then
        rank = data.Rank + 1 
    end
    self.myRank.text = tostring(rank)
    self.myScore.text = CC.uu.ChipFormat(data.Score)
end

function SongkranRankView:ShowTotalRankBtn(state)
    self:FindChild("Layer_Rank/Ranking/paihanban/tu01"):SetActive(not state)
    self:FindChild("Layer_Rank/Ranking/paihanban/tu02"):SetActive(not state)
    self:FindChild("Layer_Rank/Ranking/paihanban/tu03"):SetActive(not state)
    self:FindChild("Layer_Rank/Ranking/paihanban/tu04"):SetActive(state)
end

function  SongkranRankView:SetBtnHighlight(Type)
    for i = 1,3 do
        if Type == i then
            self:SetImage(self.RankTogGroup[i].Btn, "yfb_pman02");
            self:SetImage(self.RankTogGroup[i].Text, RankConfig[i].Image);
            self.RankTogGroup[i].Text:GetComponent("Image"):SetNativeSize()
        else
            self:SetImage(self.RankTogGroup[i].Btn, "yfb_pman01");
            self:SetImage(self.RankTogGroup[i].Text, RankConfig[i].Image.."_h");
            self.RankTogGroup[i].Text:GetComponent("Image"):SetNativeSize()
        end
    end
end

function SongkranRankView:InitIntactRank(Type)
    --延迟0.3秒执行显示排行榜
    self:RefreshMyselfInfo(Type)
    self:FindChild("Layer_Rank"):SetActive(true)
    self.co = CC.uu.DelayRun(0.30,function()
		CC.uu.CancelDelayRun(self.co)
		self:SetNewLen(self.LoopScrollRect)       
    end)
end

--确定初始化的长度
function SongkranRankView:SetNewLen(LoopScrollRect)
    self.VerticalLayoutGroup.enabled = false
    local initCount = self.RankDataMgr.GetSongkranRankCount(self.currentType) - 1
	if initCount < 5 then
		self:RankListCount(LoopScrollRect,initCount)
	else
		self:RankListCount(LoopScrollRect,6)
	end
end

--设置循环列表长度
function SongkranRankView:RankListCount(loopscrollrect,len)
	local count = len
	if count  == 0 then
		loopscrollrect:ClearCells()
	else 
		loopscrollrect.totalCount = len
	end
end

function SongkranRankView:ActionIn()
end


function SongkranRankView:ActionOut()
	self:Destroy()
end

function SongkranRankView:OnDestroy()
    CC.uu.CancelDelayRun(self.co)
    if self.viewCtr then 
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
    if self.MyIcon then
        self.MyIcon:Destroy()
        self.MyIcon = nil
    end
    --销毁主界面展示头像
    for i,v in pairs(self.rankHeadIcon) do
        if v then
          v:Destroy()
          v = nil
        end
    end
    self.LoopScrollRect:DelectPool()
    self.LoopScrollRect = nil
    self.VerticalLayoutGroup = nil
end


return SongkranRankView