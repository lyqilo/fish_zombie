local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftDummy = CC.class2("DailyGiftDummy",BaseClass)

function DailyGiftDummy:Create()
    self:OnCreate("DailyGiftDummy")
end

function DailyGiftDummy:InitDailyGiftData()
    -- self.WareId = "22011"
    -- self.giftSource = CC.shared_transfer_source_pb.TS_Dummy_DailyTreasure
    self.gameId = 2003
    self.WareId = "30103"
    self.giftSource = CC.shared_transfer_source_pb.TS_Dummy_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_Dummy_DailyGift_29, CC.shared_transfer_source_pb.TS_Dummy_DailyGift_50,
        CC.shared_transfer_source_pb.TS_Dummy_DailyGift_150, CC.shared_transfer_source_pb.TS_Dummy_DailyGift_500,
        CC.shared_transfer_source_pb.TS_Dummy_DailyGift_1000,}
    self.wareIdList = {"30103", "30104", "30105", "30106", "30107"}
end

function DailyGiftDummy:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
        v:FindChild("Effect_dummy_mihan/Text").text = self.language.dummy.Limit_Text
        v:FindChild("Effect_dummy_mihan/01/Text1").text = self.language.dummy.max_Text
        v:FindChild("Effect_dummy_mihan/01/Text").text = self.language.dummy[index].Text1
        v:FindChild("Effect_dummy_mihan/02/Text").text = self.language.dummy[index].Text2
        v:FindChild("Thb").text = self.language.dummy[index].Thb
    end
    self:FindChild("ExplainView/Frame/ScrollText/Viewport/Content/Text").text = self.language.dummy.Explain_des
    self:FindChild("ExplainView/Frame/Tittle/Text").text = self.language.dummy.Explain_title
    self:FindChild("ExplainView/Frame/BtnPay/Text").text = self.language.now_Buy
	self:FindChild("ExplainView/Frame/BtnSkip/Text").text = self.language.now_Skip
end

return DailyGiftDummy