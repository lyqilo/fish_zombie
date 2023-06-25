local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftBuyu = CC.class2("DailyGiftBuyu",BaseClass)

function DailyGiftBuyu:Create()
    self:OnCreate("DailyGiftBuyu")
end

function DailyGiftBuyu:InitDailyGiftData()
    --self.WareId = "22013"
    --self.giftSource = CC.shared_transfer_source_pb.TS_CatchFish_DailyTreasure
    self.gameId = 3002
    self.WareId = "30088"
    self.giftSource = CC.shared_transfer_source_pb.TS_2Fish_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_2Fish_DailyGift_29, CC.shared_transfer_source_pb.TS_2Fish_DailyGift_50,
        CC.shared_transfer_source_pb.TS_2Fish_DailyGift_150, CC.shared_transfer_source_pb.TS_2Fish_DailyGift_500,
        CC.shared_transfer_source_pb.TS_2Fish_DailyGift_1000,}
    self.wareIdList = {"30088", "30089", "30090", "30091", "30092"}
end

function DailyGiftBuyu:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
        v:FindChild("Chip").text = self.language.buyu[index].Chip
        v:FindChild("Thb").text = self.language.buyu[index].Thb
        v:FindChild("Effect_lbhj/lbhj_sjq01/icon/Text").text = self.language.buyu[index].prop1_num
        v:FindChild("Effect_lbhj/lbhj_sjq01/icon/Des").text = self.language.buyu[index].prop1_des
        v:FindChild("Effect_lbhj/lbhj_sjq02/icon/Text").text = self.language.buyu[index].prop2_num
        v:FindChild("Effect_lbhj/lbhj_sjq02/icon/Des").text = self.language.buyu[index].prop2_des
    end
    self:FindChild("ExplainView/Frame/Text").text = self.language.buyu.Explain_des
    self:FindChild("ExplainView/Frame/Tittle/Text").text = self.language.buyu.Explain_title
    self:FindChild("ExplainView/Frame/Image1/Text").text = self.language.buyu.Explain_num_1
    self:FindChild("ExplainView/Frame/Image2/Text").text = self.language.buyu.Explain_num_2
    self:FindChild("ExplainView/Frame/Image3/Text").text = self.language.buyu.Explain_num_3
    self:FindChild("ExplainView/Frame/Image4/Text").text = self.language.buyu.Explain_num_4
    self:FindChild("ExplainView/Frame/BtnPay/Text").text = self.language.now_Buy
	self:FindChild("ExplainView/Frame/BtnSkip/Text").text = self.language.now_Skip
end

return DailyGiftBuyu