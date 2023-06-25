
local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftDiglett = CC.class2("DailyGiftDiglett",BaseClass)

function DailyGiftDiglett:Create()
    self:OnCreate("DailyGiftDiglett")
end

function DailyGiftDiglett:InitDailyGiftData()
    -- self.WareId = "22016"
    -- self.giftSource = CC.shared_transfer_source_pb.TS_DDS_DailyTreasure
    self.WareId = "30108"
    self.giftSource = CC.shared_transfer_source_pb.TS_Rat_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_Rat_DailyGift_29, CC.shared_transfer_source_pb.TS_Rat_DailyGift_50,
        CC.shared_transfer_source_pb.TS_Rat_DailyGift_150, CC.shared_transfer_source_pb.TS_Rat_DailyGift_500,
        CC.shared_transfer_source_pb.TS_Rat_DailyGift_1000,}
    self.wareIdList = {"30108", "30109", "30110", "30111", "30112"}
end

function DailyGiftDiglett:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
        v:FindChild("Tip1/Text").text = self.language.diglett.Limit_Text
        v:FindChild("Tip2").text = self.language.diglett.Tip2
        v:FindChild("Tip2").text = self.language.diglett[index].Tip3
        v:FindChild("PaoPao/Num").text = self.language.diglett[index].prop1_num
    end
end

function DailyGiftDiglett:InitSpecialView()
end
function DailyGiftDiglett:SetExplainViewBtn()
end

return DailyGiftDiglett