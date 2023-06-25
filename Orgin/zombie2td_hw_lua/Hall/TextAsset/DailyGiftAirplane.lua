local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftAirplane = CC.class2("DailyGiftAirplane",BaseClass)

function DailyGiftAirplane:Create()
    self:OnCreate("DailyGiftAirplane")
end

function DailyGiftAirplane:InitDailyGiftData()
    -- self.WareId = "22015"
    -- self.giftSource = CC.shared_transfer_source_pb.TS_Plane_DailyTreasure
    self.gameId = 3007
    self.WareId = "30083"
    self.giftSource = CC.shared_transfer_source_pb.TS_Plane_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_Plane_DailyGift_29, CC.shared_transfer_source_pb.TS_Plane_DailyGift_50,
        CC.shared_transfer_source_pb.TS_Plane_DailyGift_150, CC.shared_transfer_source_pb.TS_Plane_DailyGift_500,
        CC.shared_transfer_source_pb.TS_Plane_DailyGift_1000,}
    self.wareIdList = {"30083", "30084", "30085", "30086", "30087"}
end

function DailyGiftAirplane:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
        v:FindChild("bg/Text").text = self.language.airPlane.limitBuy
        if index == 4 or index == 5 then
            v:FindChild("Icon_1/1").text = self.language.airPlane[index].icon1_name_1
            v:FindChild("Icon_1/2").text = self.language.airPlane[index].icon1_name_2
        else
            v:FindChild("Icon_1/1").text = self.language.airPlane[index].icon1_name
            v:FindChild("Icon_1/num").text = self.language.airPlane[index].icon1_num
        end
        v:FindChild("Icon_1/Text").text = self.language.airPlane[index].icon1_des
        v:FindChild("Icon_2/num").text = self.language.airPlane[index].icon2_num
        v:FindChild("Icon_2/Text").text = self.language.airPlane.icon2_des
        v:FindChild("Chip/Text").text = self.language.airPlane.chip_des
        v:FindChild("Chip/num").text = self.language.airPlane[index].chip_num
    end
    self:FindChild("ExplainView/Frame/Text").text = self.language.airPlane.Explain_des
    self:FindChild("ExplainView/Frame/Tittle/Text").text = self.language.airPlane.Explain_title
    self:FindChild("ExplainView/Frame/Image1/Text").text = self.language.airPlane.Explain_num_1
    self:FindChild("ExplainView/Frame/Image2/Text").text = self.language.airPlane.Explain_num_2
    self:FindChild("ExplainView/Frame/Image3/Text").text = self.language.airPlane.Explain_num_3
    self:FindChild("ExplainView/Frame/BtnPay/Text").text = self.language.now_Buy
    self:FindChild("ExplainView/Frame/BtnSkip/Text").text = self.language.now_Skip
end

function DailyGiftAirplane:InitSpecialView()
    for _, v in ipairs(self.panelView) do
        self:AddClick(v:FindChild("BtnRule"), function ()
            self.openExplainView = true
            self:FindChild("ExplainView"):SetActive(true)
            self:SetExplainViewBtn()
        end)
    end
	self:AddClick(self:FindChild("ExplainView/Frame/BtnPay"), "ReqBuyDailyGift")
	self:AddClick(self:FindChild("ExplainView/Frame/BtnSkip"), function ()
		self:CheckGameState()
	end)
    self:AddClick(self:FindChild("ExplainView/Frame/BtnClose"), function ()
        self.openExplainView = false
		self:FindChild("ExplainView"):SetActive(false)
    end)
end

return DailyGiftAirplane