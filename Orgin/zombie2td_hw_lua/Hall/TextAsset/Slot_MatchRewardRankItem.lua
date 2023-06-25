--Author:AQ
--Time:2020年08月20日 15:55:03 Thursday
--Describe:

local CC = require "CC"
local GameobjectPool = require("Common/GameobjectPool");
local M = CC.class2("Slot_MatchRewardRankItem")
local SlotMatchManager = CC.SlotMatchManager

function M:ctor(go)
    self:Init(go);
end

function M:Init(go)
    self.transform = go.transform;
    self.text_awardChip = self.transform:FindChild("text_awardChip");
    self.text_rank = self.transform:FindChild("text_rank");
    self.add = self.transform:FindChild("text_add").gameObject;
    self.add.transform:GetComponent("Text").text = "+";
    self.text_giftValue = self.transform:FindChild("text_giftValue");
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

function M:Refresh(info,rank)
    local rewardCountMap = {};
    local rewardValueMap = {};
    for k,v in ipairs(info.props) do
        rewardCountMap[v.PropId] = rewardCountMap[v.PropId] == nil and v.Count or (rewardCountMap[v.PropId] + v.Count);
    end
    local hasGift = false;
    local itemCount = 0;
    for k,v in pairs(rewardCountMap) do
        if k == CC.shared_enums_pb.EPC_ChouMa then
            self.text_awardChip.text = CC.uu.ChipFormat(v,true);
        else
            local gift = self.giftPool:Get();
            local spriteName = "prop_img_"..k;
            local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[spriteName..".png"];
            gift.transform:FindChild("image_giftIcon"):GetComponent("Image").sprite = CC.uu.LoadImgSprite(spriteName,abName);
            gift.transform:FindChild("text_giftCount").text = "X"..v;
            hasGift = true;
            itemCount = itemCount + 1;
            local faceValue = SlotMatchManager.inst():GetContextInfoByKey("PropValue")[k];
            faceValue = faceValue == nil and "" or faceValue..CC.CurrencyDefine.CurrencyCode;
            rewardValueMap[itemCount] = faceValue .."X"..v;
        end
    end
    local tempCount = 1;
    if itemCount > 0 then
        self.giftListScrollRect.horizontalNormalizedPosition = 0;
        self.text_giftValue.text = rewardValueMap[tempCount];
    end
    if itemCount > 1 then
        local deltaPos = 1/(itemCount - 1);
        local loopShowFunc = nil;
        loopShowFunc = function()
            self.loopShowCor = CC.uu.DelayRun(2,function()
                tempCount = tempCount + 1;
                if tempCount <= itemCount then
                    self.giftListScrollRect.horizontalNormalizedPosition = self.giftListScrollRect.horizontalNormalizedPosition + deltaPos;
                    self.text_giftValue.text = rewardValueMap[tempCount];
                else
                    tempCount = 1;
                    self.giftListScrollRect.horizontalNormalizedPosition = 0;
                    self.text_giftValue.text = rewardValueMap[tempCount];
                end
                loopShowFunc();
            end);
        end
        loopShowFunc();
    end

    self.text_rank.text = "No."..rank;
    self.text_rank.gameObject:SetActive(not hasGift);
    self.add:SetActive(hasGift);
end

function M:Reset()
    self.text_awardChip.text = "";
    self.text_rank.text = "";
    self.text_giftValue.text = "";
    self.text_rank.gameObject:SetActive(false);
    self.add:SetActive(false);
    self.giftPool:RecycleAll();
    if self.loopShowCor then
        CC.uu.CancelDelayRun(self.loopShowCor);
        self.loopShowCor = nil;
    end
end


return M