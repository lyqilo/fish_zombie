local CC = require("CC")
local TotalWaterRankView = CC.uu.ClassView("TotalWaterRankView")

function TotalWaterRankView:ctor(param)
    self.param = param
    self.proplanguage = CC.LanguageManager.GetLanguage("L_Prop")
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.language = self:GetLanguage()
    self.PortraitTable = {}
    --前几名额外的筹码奖励
    self.extrarew = {{id = 2,count = "50M"},{id = 2,count = "30M"},{id = 2,count = "20M"}}
end

function TotalWaterRankView:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()

	self:Init()
end

function TotalWaterRankView:Init()
    self.noData = self:FindChild("UI_Layout/NoData")

    self.ToggleGroup = {}
	self.ToggleGroup[1] = self:FindChild("UI_Layout/Toggle/Capture")
	self.ToggleGroup[2] = self:FindChild("UI_Layout/Toggle/Synthesize")

    self:FindChild("Item/Prop/Extra/Add").text = "+"
    self:FindChild("UI_Layout/Toggle/Capture/Label").text = self.language.Title2
    self:FindChild("UI_Layout/Toggle/Synthesize/Label").text = self.language.Title3 
    self:FindChild("UI_Layout/Time").text = self.language.timeDes
    self:FindChild("UI_Layout/NoData/Text").text = self.language.noData
    -- self:InitHelpPanel()
    
    self.ScroRect = self:FindChild("UI_Layout/UI_Scroller"):GetComponent("ScrollRect")
    self.ScrollerController = self:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
        self:RefreshItem(tran,dataIndex)
	end)
	self.ScrollerController:AddRycycleAction(function(tran)
		self:RecycleItem(tran)
    end)
    
    for i,v in ipairs(self.ToggleGroup) do
        local index = i
        UIEvent.AddToggleValueChange(v,function(select)
            if select and self.viewCtr.waterTab ~= index then 
                self:FindChild("UI_Layout/NoData"):SetActive(true)
                self:FindChild("UI_Layout/UI_Scroller"):SetActive(false)
                self.viewCtr:SwitchTab(index) 
            end
        end)
        v:GetComponent("Toggle").isOn = false
    end
    self.ToggleGroup[1]:GetComponent("Toggle").isOn = true

    self:AddClick("UI_Layout/TipsBtn",function() 
        -- self:ShowPanel(self:FindChild("HelpPanel")) 
        CC.ViewManager.Open("TotalTipsView")
    end)
    -- self:AddClick("HelpPanel/Mask",function() self:HidePanel(self:FindChild("HelpPanel")) end)

    self.MyIcon =  CC.HeadManager.CreateHeadIcon({parent = self:FindChild("UI_Layout/SelfRank/Node"),clickFunc = "unClick"})
end

-- function TotalWaterRankView:InitHelpPanel()
--     self:FindChild("HelpPanel/Frame/Title/Text").text = self.language.activityRule
    
--     local content = self:FindChild("HelpPanel/Frame/ScrollView/Viewport/Content")
--     for i = 1,7 do
--         content:FindChild("Item0"..i).text = self.language[i]
--     end
--     for i = 1,3 do
--         content:FindChild("Title/"..i.."/Text").text = self.language["Title"..i]
--     end

--     local prefab = content:FindChild("Reward")
--     for i,v in ipairs(self.viewCtr.RewardConfig) do
--         local item = CC.uu.newObject(prefab,content)
--         item:FindChild("Rank/Text").text = v.rank
--         item:FindChild("1/Text").text = self:GetRewText(i,v.rew1)
--         item:FindChild("2/Text").text = self:GetRewText(i,v.rew2)
--         item:SetActive(true)
--     end
-- end

-- function TotalWaterRankView:GetRewText(index,cfg)
--     local rew = ""
--     if cfg.id == CC.shared_enums_pb.EPC_ChouMa then
--         rew = string.format("%s %s",cfg.count,self.proplanguage[cfg.id])
--     elseif cfg.id == CC.shared_enums_pb.EPC_Razer_CatEar_HeadSet_Pink then
--         rew = cfg.des
--     else
--         rew = self.proplanguage[cfg.id]
--     end
--     local extra = self.extrarew[index]
--     if extra then
--         rew = string.format("%s\n%s %s",rew,extra.count,self.proplanguage[extra.id])
--     end

--     return rew
-- end

function TotalWaterRankView:RefreshRankInfo(tab)
    local selfrank = tab == self.viewCtr.Type.Capture and self.viewCtr.CaptureRank or self.viewCtr.SynthesizeRank
    self:FindChild("UI_Layout/SelfRank/Rank/Text").text = selfrank > 0 and selfrank or self.language.noRank
    local selfScore = tab == self.viewCtr.Type.Capture and self.viewCtr.CaptureScore or self.viewCtr.SynthesizeScore
    self:FindChild("UI_Layout/SelfRank/Chip/Text").text = CC.uu.ChipFormat(selfScore)

    local count = #(self.viewCtr.CurRankData)
    self:FindChild("UI_Layout/NoData"):SetActive(count <= 0)
    self:FindChild("UI_Layout/UI_Scroller"):SetActive(count > 0)

    if not self.initScr then
        self.ScrollerController:InitScroller(count)
        self.initScr = true
    else
        self.ScrollerController:RefreshScroller(count,1-self.ScroRect.verticalNormalizedPosition)
    end
end

function TotalWaterRankView:RefreshItem(tran,dataIndex)
    local rankInfo = self.viewCtr.CurRankData[dataIndex + 1]
    if rankInfo == nil then return end

    tran.name = rankInfo.PlayerId

    local Rank = rankInfo.RankID
    tran:FindChild("Effect"):SetActive(Rank <= 3)
    tran:FindChild("Rank"):SetActive(Rank > 3)
    if Rank <= 3 then
        for i = 1,3 do
            tran:FindChild("Effect/"..i):SetActive(i == Rank)
        end
    else
        tran:FindChild("Rank/Text").text = Rank
    end
    
    tran:FindChild("Nick").text = rankInfo.Name
    tran:FindChild("Score").text = CC.uu.ChipFormat(rankInfo.Score)
    
    self:SetHeadIcon({parent = tran:FindChild("Node"),playerId = rankInfo.PlayerId,portrait = rankInfo.Portrait,vipLevel = rankInfo.Vip},tostring(rankInfo.PlayerId))
    
    self:SetImage(tran:FindChild("Prop/Reward"),self.propCfg[rankInfo.propID].Icon,true)
    local des = self.proplanguage[rankInfo.propID]
    des = rankInfo.propID == CC.shared_enums_pb.EPC_ChouMa and string.format("%s %s",CC.uu.NumberFormat(rankInfo.propNum),des) or des
    tran:FindChild("Prop/Des").text = (Rank <= 3) and "" or des
    local extr = self.extrarew[Rank]
    if extr then
        self:SetImage(tran:FindChild("Prop/Extra/Reward"),self.propCfg[extr.id].Icon,true)
        tran:FindChild("Prop/Extra/Des").text = string.format("%s %s",extr.count,self.proplanguage[2])
        tran:FindChild("Prop/Extra"):SetActive(true)
    else
        tran:FindChild("Prop/Extra"):SetActive(false)
    end
end

function TotalWaterRankView:SetHeadIcon(param,index)
    local headIcon = CC.HeadManager.CreateHeadIcon(param)
    self.PortraitTable[index] = headIcon
end

function TotalWaterRankView:RecycleItem(tran)
    local index = tran.name
	if self.PortraitTable[index] then
		self.PortraitTable[index]:Destroy(true)
	end
end

function TotalWaterRankView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function TotalWaterRankView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function TotalWaterRankView:OnDestroy()
   
    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
    if self.MyIcon then
        self.MyIcon:Destroy()
        self.MyIcon = nil
    end
    for _,v in pairs(self.PortraitTable) do
        if v then
            v:Destroy()
            v = nil
        end
    end
    self.ScrollerController = nil
    self.ScroRect = nil
end


return TotalWaterRankView