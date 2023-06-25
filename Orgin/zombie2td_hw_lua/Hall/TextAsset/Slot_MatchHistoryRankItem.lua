--Author:AQ
--Time:2020年08月20日 15:55:03 Thursday
--Describe:

local CC = require "CC"

local M = CC.class2("Slot_MatchHistoryRankItem")
local GameobjectPool = require("Common/GameobjectPool");
local Slot_MatchUtils = require("View/SlotMatch/Slot_MatchUtils")

function M:ctor(go)
    self:Init(go);
end

function M:Init(go)
    self.transform = go.transform;
    self.iconPos = self.transform:FindChild("iconPos");
    self.rankNum_1 = self.transform:FindChild("rankNum_1");
    self.rankNum_2 = self.transform:FindChild("rankNum_2");
    self.rankNum_3 = self.transform:FindChild("rankNum_3");
    self.rankNum_4up = self.transform:FindChild("rankNum_4up");
    self.text_rankNum = self.rankNum_4up:FindChild("text_rankNum"):GetComponent("Text");
    self.text_awardChip = self.transform:FindChild("text_awardChip"):GetComponent("Text");
    self.text_playerName = self.transform:FindChild("text_playerName"):GetComponent("Text");

    self.giftListScrollRect = self.transform:FindChild("giftList"):GetComponent("ScrollRect");
    local giftListContent = self.transform:FindChild("giftList/content");
    local giftPrefab = self.transform:FindChild("matchGift").gameObject;
    self.giftPool =  GameobjectPool.New(
        giftPrefab,
        function(obj)
            obj:SetActive(false);
            obj.transform:SetParent(giftListContent,false);
        end,
        function(obj)
            obj.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = nil;
            obj.transform:FindChild("text_giftCount").text = "";
        end,
        -1
    );
end

function M:Refresh(info)
    local portrait = info.playerInfo.szPortrait;
    if portrait == "nil" then
        portrait = "";
    end
    self.icon = CC.HeadManager.CreateHeadIcon({parent = self.iconPos,clickFunc = "unClick",unShowVip = true,portrait = portrait,playerId = info.playerInfo.playerId});
    info.rank = info.rank
    if info.rank == 1 then
        self.rankNum_1:SetActive(true);
    elseif info.rank == 2 then
        self.rankNum_2:SetActive(true);
    elseif info.rank == 3 then
        self.rankNum_3:SetActive(true);
    else
        self.rankNum_4up:SetActive(true);
        self.text_rankNum.text = tostring(info.rank);
        if info.rank > 99 then
            self.text_rankNum.fontSize = 30;
        else
            self.text_rankNum.fontSize = 36;
        end
    end
    self.text_playerName.text = info.playerInfo.szNickName;
    self.text_awardChip.text = CC.uu.ChipFormat(Slot_MatchUtils.Return0IfNil(info.lScore),true);

    local rewardCountMap = {};
    local itemCount = 0;
    for k,v in ipairs(info.props) do
        rewardCountMap[v.PropId] = rewardCountMap[v.PropId] == nil and v.Count or (rewardCountMap[v.PropId] + v.Count);
        itemCount = itemCount + 1;
    end
    for k,v in pairs(rewardCountMap) do
        local gift = self.giftPool:Get();
        local spriteName = "prop_img_"..k;
        local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName..".png"];
        gift.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = CC.uu.LoadImgSprite(spriteName,abName);
        gift.transform:FindChild("text_giftCount").text = "X"..v;
    end

    if itemCount > 1 then
        local deltaPos = 1/(itemCount - 1);
        self.giftListScrollRect.horizontalNormalizedPosition = 0;
        local tempCount = itemCount - 1;
        local loopShowFunc = nil;
        loopShowFunc = function()
            self.loopShowCor = CC.uu.DelayRun(2,function()
                if tempCount > 0 then
                    self.giftListScrollRect.horizontalNormalizedPosition = self.giftListScrollRect.horizontalNormalizedPosition + deltaPos;
                    tempCount = tempCount - 1;
                else
                    self.giftListScrollRect.horizontalNormalizedPosition = 0;
                    tempCount = itemCount - 1;
                end
                loopShowFunc();
            end);
        end
        loopShowFunc();
    end
end

function M:Reset()
    self.rankNum_1:SetActive(false);
    self.rankNum_2:SetActive(false);
    self.rankNum_3:SetActive(false);
    self.rankNum_4up:SetActive(false);
    self.text_rankNum.text = "";
    self.text_awardChip.text = "";
    self.text_playerName.text = "";
    if self.icon then
        CC.HeadManager.DestroyHeadIcon(self.icon);
		self.icon = nil;
    end
    Util.ClearChild(self.iconPos,false);
    self.giftPool:RecycleAll();
    if self.loopShowCor then
        CC.uu.CancelDelayRun(self.loopShowCor);
        self.loopShowCor = nil;
    end
end


return M