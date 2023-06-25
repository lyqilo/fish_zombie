
local CC = require("CC")
local TotalTipsView = CC.uu.ClassView("TotalTipsView")

function TotalTipsView:ctor(param)

	self:InitVar(param);
end

function TotalTipsView:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_TotalWaterRankView")
	self.proplanguage = CC.LanguageManager.GetLanguage("L_Prop")
    self.extrarew = {{id = 2,count = "50M"},{id = 2,count = "30M"},{id = 2,count = "20M"}}

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitContent()
end

function TotalTipsView:InitVar(param)

	self.param = param;
end

function TotalTipsView:InitContent()
	self:FindChild("HelpPanel/Frame/Title/Text").text = self.language.activityRule
    
    local content = self:FindChild("HelpPanel/Frame/ScrollView/Viewport/Content")
    for i = 1,7 do
        content:FindChild("Item0"..i).text = self.language[i]
    end
    for i = 1,3 do
        content:FindChild("Title/"..i.."/Text").text = self.language["Title"..i]
    end

    local prefab = content:FindChild("Reward")
    for i,v in ipairs(self.viewCtr.RewardConfig) do
        local item = CC.uu.newObject(prefab,content)
        item:FindChild("Rank/Text").text = v.rank
        item:FindChild("1/Text").text = self:GetRewText(i,v.rew1)
        item:FindChild("2/Text").text = self:GetRewText(i,v.rew2)
        item:SetActive(true)
    end

	self:AddClick("HelpPanel/Mask",function() 
		self:ActionOut()
	end)
end

function TotalTipsView:GetRewText(index,cfg)
    local rew = ""
    if cfg.id == CC.shared_enums_pb.EPC_ChouMa then
        rew = string.format("%s %s",cfg.count,self.proplanguage[cfg.id])
    elseif cfg.id == CC.shared_enums_pb.EPC_Razer_CatEar_HeadSet_Pink then
        rew = cfg.des
    else
        rew = self.proplanguage[cfg.id]
    end
    local extra = self.extrarew[index]
    if extra then
        rew = string.format("%s\n%s %s",rew,extra.count,self.proplanguage[extra.id])
    end

    return rew
end

function TotalTipsView:InitTextByLanguage()

end

function TotalTipsView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return TotalTipsView