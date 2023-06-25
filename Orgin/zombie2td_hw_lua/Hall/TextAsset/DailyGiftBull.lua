local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftBull = CC.class2("DailyGiftBull",BaseClass)

function DailyGiftBull:Create()
    self:OnCreate("DailyGiftBull")
end

function DailyGiftBull:InitDailyGiftData()
    self.gameId = 3010
    self.WareId = "30124"
    self.giftSource = CC.shared_transfer_source_pb.TS_Cow_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_Cow_DailyGift_29, CC.shared_transfer_source_pb.TS_Cow_DailyGift_50,
        CC.shared_transfer_source_pb.TS_Cow_DailyGift_150, CC.shared_transfer_source_pb.TS_Cow_DailyGift_500,
        CC.shared_transfer_source_pb.TS_Cow_DailyGift_1000,}
    self.wareIdList = {"30124", "30125", "30126", "30127", "30128"}
end

function DailyGiftBull:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
        v:FindChild("Thb").text = self.language.bull[index].Thb
        v:FindChild("Text").text = self.language.bull.Limit_Text
        if index == 1 or index == 2 then
            v:FindChild("Image/Text4").text = self.language.bull.Image_Text4
        end
        v:FindChild("Image/Text").text = self.language.bull.Image_Text
        v:FindChild("Image/Text1").text = self.language.bull.Image_Tex1
        v:FindChild("Image/Text2").text = self.language.bull[index].Image_Text2
        v:FindChild("Image/Text3").text = self.language.bull.Image_Text3
        v:FindChild("Image1/Text").text = self.language.bull.Image1_Text
        v:FindChild("Image1/Text1").text = self.language.bull[index].Image1_Text1
    end
end

function DailyGiftBull:InitSpecialView()
end
function DailyGiftBull:SetExplainViewBtn()
end

return DailyGiftBull