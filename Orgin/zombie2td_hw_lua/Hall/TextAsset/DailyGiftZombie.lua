
local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftZombie = CC.class2("DailyGiftZombie",BaseClass)

function DailyGiftZombie:Create()
    self:OnCreate("DailyGiftZombie")
end

function DailyGiftZombie:InitDailyGiftData()
    -- self.WareId = "30015"
    -- self.giftSource = CC.shared_transfer_source_pb.TS_TD_DailyTreasure
    self.gameId = 3009
    self.WareId = "30113"
    self.giftSource = CC.shared_transfer_source_pb.TS_TD_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_TD_DailyGift_29, CC.shared_transfer_source_pb.TS_TD_DailyGift_50,
        CC.shared_transfer_source_pb.TS_TD_DailyGift_150, CC.shared_transfer_source_pb.TS_TD_DailyGift_500,
        CC.shared_transfer_source_pb.TS_TD_DailyGift_1000,}
    self.wareIdList = {"30113", "30114", "30115", "30116", "30117"}
end

function DailyGiftZombie:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
        v:FindChild("Image/Thb").text = self.language.Zombie[index].Thb
        v:FindChild("Image/Chip").text = self.language.Zombie[index].Chip
        v:FindChild("Icon1/Text").text = self.language.Zombie[index].prop1_name
        v:FindChild("Icon1/Num").text = self.language.Zombie[index].prop1_num
        v:FindChild("Icon2/Text").text = self.language.Zombie[index].prop2_name
        v:FindChild("Icon2/Num").text = self.language.Zombie[index].prop2_num
        v:FindChild("Icon3/Text").text = self.language.Zombie[index].prop3_name
        v:FindChild("Icon3/Num").text = self.language.Zombie[index].prop3_num
    end
end

function DailyGiftZombie:InitSpecialView()
    self:AddClick(self:FindChild("Mask"),function() self:HideTip() end)
    self.tip = {"50*100", "200*100", "1000*100", "5000*100"}
    for i = 1, 4 do
        local index = i
        self:AddClick(self:FindChild("Btn"..index),function()  self:ShowTip(index) end)
    end
end
function DailyGiftZombie:SetExplainViewBtn()
end

function DailyGiftZombie:SwitchChange()
    self:FindChild("Btn3"):SetActive(self.WareId ~= "30117")
    self:FindChild("Btn4"):SetActive(self.WareId == "30117")
end

function DailyGiftZombie:ShowTip(index)
    self:FindChild("Tip/Text").text = string.format(self.language.Zombie.Tip, self.tip[index])
    self:FindChild("Tip"):SetActive(true)
    self:FindChild("Mask"):SetActive(true)
end

function DailyGiftZombie:HideTip()
    self:FindChild("Tip"):SetActive(false)
    self:FindChild("Mask"):SetActive(false)
end

return DailyGiftZombie