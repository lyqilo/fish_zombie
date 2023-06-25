local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftFourBuyu = CC.class2("DailyGiftFourBuyu",BaseClass)

function DailyGiftFourBuyu:Create()
    self:OnCreate("DailyGiftFourBuyu")
end

function DailyGiftFourBuyu:InitDailyGiftData()
    -- self.WareId = "22014"
    -- self.giftSource = CC.shared_transfer_source_pb.TS_FourFish_DailyTreasure
    self.gameId = 3005
    self.WareId = "30093"
    self.giftSource = CC.shared_transfer_source_pb.TS_4Fish_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_4Fish_DailyGift_29, CC.shared_transfer_source_pb.TS_4Fish_DailyGift_50,
        CC.shared_transfer_source_pb.TS_4Fish_DailyGift_150, CC.shared_transfer_source_pb.TS_4Fish_DailyGift_500,
        CC.shared_transfer_source_pb.TS_4Fish_DailyGift_1000,}
    self.wareIdList = {"30093", "30094", "30095", "30096", "30097"}
end

function DailyGiftFourBuyu:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
        v:FindChild("Thb").text = self.language.fourBuyu[index].Thb
        v:FindChild("Image01/Text").text = self.language.fourBuyu[index].prop1_name
        v:FindChild("Image01/Num").text = self.language.fourBuyu[index].prop1_num
        v:FindChild("Image01/Des").text = self.language.fourBuyu[index].prop1_des
        if index == 4 or index == 5 then
            v:FindChild("Image02/Text").text = self.language.fourBuyu[index].prop2_name
            v:FindChild("Image02/Num").text = self.language.fourBuyu[index].prop2_num
            v:FindChild("Image02/Des").text = self.language.fourBuyu[index].prop2_des
        end
        v:FindChild("Image03/Text").text = self.language.fourBuyu.prop3_name
        v:FindChild("Image03/Num").text = self.language.fourBuyu[index].prop3_num
        v:FindChild("Image03/Des").text = self.language.fourBuyu.prop3_des

        v:FindChild("bubble").text = self.language.fourBuyu.Limit_Text
        v:FindChild("Chip").text = self.language.fourBuyu.Chip
        v:FindChild("Chip/Num").text = self.language.fourBuyu[index].ChipNum
    end
    self:FindChild("ExplainView/Frame/Text").text = self.language.fourBuyu.Explain_des
    self:FindChild("ExplainView/Frame/Tittle/Text").text = self.language.fourBuyu.Explain_title
    self:FindChild("ExplainView/Frame/Image1/Text").text = self.language.fourBuyu.Explain_num_1
    self:FindChild("ExplainView/Frame/Image2/Text").text = self.language.fourBuyu.Explain_num_2
    self:FindChild("ExplainView/Frame/Image3/Text").text = self.language.fourBuyu.Explain_num_3
    self:FindChild("ExplainView/Frame/BtnPay/Text").text = self.language.now_Buy
    self:FindChild("ExplainView/Frame/BtnSkip/Text").text = self.language.now_Skip
end

return DailyGiftFourBuyu