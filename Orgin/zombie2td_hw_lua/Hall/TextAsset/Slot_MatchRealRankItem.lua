--Author:AQ
--Time:2020年08月20日 15:55:03 Thursday
--Describe:

local CC = require "CC"

local M = CC.class2("Slot_MatchRealRankItem")

function M:ctor(go)
    self:Init(go);
end

function M:Init(go)
    self.transform = go.transform;
    self.text_score = self.transform:FindChild("text_score"):GetComponent("Text");
    self.text_name = self.transform:FindChild("text_name"):GetComponent("Text");
    self.iconPos = self.transform:FindChild("iconPos");
    self.rank1 = self.transform:FindChild("rank1");
    self.rank2 = self.transform:FindChild("rank2");
    self.rank3 = self.transform:FindChild("rank3");
end

function M:Refresh(info)
    local portrait = info.playerInfo.szPortrait;
    if portrait == "nil" then
        portrait = "";
    end
    self.icon = CC.HeadManager.CreateHeadIcon({parent = self.iconPos,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = info.playerInfo.playerId});
    self.text_score.text = CC.uu.numberToStrWithComma(info.lScore);
    self.text_name.text = info.playerInfo.szNickName;
    if info.rank == 1 then
        self.rank1:SetActive(true);
    elseif info.rank == 2 then
        self.rank2:SetActive(true);
    elseif info.rank == 3 then
        self.rank3:SetActive(true);
    end
end

function M:Reset()
    self.text_score.text = "";
    self.rank1:SetActive(false);
    self.rank2:SetActive(false);
    self.rank3:SetActive(false);
    if self.icon then
        CC.HeadManager.DestroyHeadIcon(self.icon);
		self.icon = nil;
    end
    Util.ClearChild(self.iconPos,false);
end


return M