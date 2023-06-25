
local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftPharaoh = CC.class2("DailyGiftPharaoh",BaseClass)

function DailyGiftPharaoh:Create()
    self:OnCreate("DailyGiftPharaoh")
end

function DailyGiftPharaoh:InitDailyGiftData()
    self.WareId = "30129"
    self.giftSource = CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_29, CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_50,
        CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_150, CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_500,
        CC.shared_transfer_source_pb.TS_RatLuan_DailyGift_1000,}
    self.wareIdList = {"30129", "30130", "30131", "30132", "30133"}
end

function DailyGiftPharaoh:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
        v:FindChild("Tip/Text").text = self.language.pharaoh.Limit_Text
        v:FindChild("Tip1").text = self.language.pharaoh[index].Tip1
        v:FindChild("Tip2").text = self.language.pharaoh[index].Tip2
        v:FindChild("Tip3").text = self.language.pharaoh.Tip3
    end
end

function DailyGiftPharaoh:InitSpecialView()
end
function DailyGiftPharaoh:SetExplainViewBtn()
end

return DailyGiftPharaoh