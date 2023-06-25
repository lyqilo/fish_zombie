local CC = require("CC")
local VIPBestGfitView = CC.uu.ClassView("VIPBestGfitView")

function VIPBestGfitView:ctor(param)
	self:InitVar(param);
end

function VIPBestGfitView:InitVar(param)
    self.param = param or {}
    self.wareId = self.param.wareId
    self.language = self:GetLanguage()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.BaseGifts = {
        ["30288"] = {Price = "10THB", MaxChip = 250000, source = CC.shared_transfer_source_pb.TS_RefinementV2_Google_Treasure1},
        ["30289"] = {Price = "29THB", MaxChip = 725000, source = CC.shared_transfer_source_pb.TS_RefinementV2_Google_Treasure2},
        ["30290"] = {Price = "69THB", MaxChip = 1782500, source = CC.shared_transfer_source_pb.TS_RefinementV2_Google_Treasure3},
        ["30291"] = {Price = "35THB", MaxChip = 875000, source = CC.shared_transfer_source_pb.TS_RefinementV2_Ios_Treasure1},
        ["30292"] = {Price = "69THB", MaxChip = 1782500, source = CC.shared_transfer_source_pb.TS_RefinementV2_Ios_Treasure2},
        ["30293"] = {Price = "149THB", MaxChip = 4035000, source = CC.shared_transfer_source_pb.TS_RefinementV2_Ios_Treasure3},
        ["30294"] = {Price = "10THB", MaxChip = 250000, source = CC.shared_transfer_source_pb.TS_RefinementV2_Truewallet_Treasure1},
        ["30295"] = {Price = "30THB", MaxChip = 750000, source = CC.shared_transfer_source_pb.TS_RefinementV2_Truewallet_Treasure2},
        ["30296"] = {Price = "50THB", MaxChip = 1250000, source = CC.shared_transfer_source_pb.TS_RefinementV2_Truewallet_Treasure3},
        ["30297"] = {Price = "60THB", MaxChip = 1550000, source = CC.shared_transfer_source_pb.TS_RefinementV2_Truewallet_Treasure4},
        ["30298"] = {Price = "90THB", MaxChip = 2362500, source = CC.shared_transfer_source_pb.TS_RefinementV2_Truewallet_Treasure5},
        ["30299"] = {Price = "100THB", MaxChip = 2666500, source = CC.shared_transfer_source_pb.TS_RefinementV2_Truewallet_Treasure6},
        ["30300"] = {Price = "10THB", MaxChip = 250000, source = CC.shared_transfer_source_pb.TS_RefinementV3_Google_Treasure1},
        ["30301"] = {Price = "29THB", MaxChip = 725000, source = CC.shared_transfer_source_pb.TS_RefinementV3_Google_Treasure2},
        ["30302"] = {Price = "69THB", MaxChip = 1782500, source = CC.shared_transfer_source_pb.TS_RefinementV3_Google_Treasure3},
        ["30303"] = {Price = "35THB", MaxChip = 875000, source = CC.shared_transfer_source_pb.TS_RefinementV3_Ios_Treasure1},
        ["30304"] = {Price = "69THB", MaxChip = 1782500, source = CC.shared_transfer_source_pb.TS_RefinementV3_Ios_Treasure2},
        ["30305"] = {Price = "149THB", MaxChip = 4035000, source = CC.shared_transfer_source_pb.TS_RefinementV3_Ios_Treasure3},
        ["30306"] = {Price = "10THB", MaxChip = 250000, source = CC.shared_transfer_source_pb.TS_RefinementV3_Truewallet_Treasure1},
        ["30307"] = {Price = "30THB", MaxChip = 750000, source = CC.shared_transfer_source_pb.TS_RefinementV3_Truewallet_Treasure2},
        ["30308"] = {Price = "50THB", MaxChip = 1250000, source = CC.shared_transfer_source_pb.TS_RefinementV3_Truewallet_Treasure3},
        ["30309"] = {Price = "60THB", MaxChip = 1550000, source = CC.shared_transfer_source_pb.TS_RefinementV3_Truewallet_Treasure4},
        ["30310"] = {Price = "90THB", MaxChip = 2362500, source = CC.shared_transfer_source_pb.TS_RefinementV3_Truewallet_Treasure5},
        ["30311"] = {Price = "100THB", MaxChip = 2666500, source = CC.shared_transfer_source_pb.TS_RefinementV3_Truewallet_Treasure6},
	}
end

function VIPBestGfitView:OnCreate()
    self.vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    if not self.wareId or not self.BaseGifts[self.wareId] then self:ActionOut() return end
    self:InitView()
    self:InitClickEvent()
    self:InitTextByLanguage()
    self:RegisterEvent()
end

function VIPBestGfitView:InitView()
    self:FindChild("Vip2"):SetActive(self.vipLevel == 1)
    self:FindChild("Vip3"):SetActive(self.vipLevel == 2)
    if self.BaseGifts[self.wareId] then
        self:FindChild("Reward/Num").text = CC.uu.Chipformat2(self.BaseGifts[self.wareId].MaxChip)
        self:FindChild("Thb").text = string.format(self.language.PriceThb, self.BaseGifts[self.wareId].Price)
    end
    if self.wareCfg[self.wareId] then
        self:FindChild("BuyBtn/Text").text = self.wareCfg[self.wareId].Price
    end
	self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
end

function VIPBestGfitView:InitClickEvent()
	self:AddClick(self:FindChild("BtnClose") , "CloseView")
    self:AddClick(self:FindChild("BuyBtn") , "ReqBuyGift")
end

function VIPBestGfitView:InitTextByLanguage()
	self:FindChild("Reward/Text").text = self.language.MaxGetChip
    self:FindChild("Des").text = string.format(self.language.GiftDes, self.vipLevel + 1)
end

function VIPBestGfitView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnPropChange,CC.Notifications.changeSelfInfo)
end

function VIPBestGfitView:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function VIPBestGfitView:OnPropChange(props, source)
    log(CC.uu.Dump(source, "source:"))
    if source ~= self.BaseGifts[self.wareId].source then
        return
    end
    local ChouMa = 0
    for _,v in ipairs(props) do
        if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			ChouMa = v.Delta
		end
    end
    CC.ViewManager.OpenRewardsView({items = {{ConfigId = CC.shared_enums_pb.EPC_ChouMa, Count = ChouMa}}})
    self:ActionOut()
end

function VIPBestGfitView:ReqBuyGift()
	if self.walletView then
        self.walletView:SetBuyExchangeWareId(self.wareId)
        self.walletView:PayRecharge()
    end
end

function VIPBestGfitView:CloseView()
    local cancelFunc = function ()
        self:Destroy()
    end
    local box = CC.ViewManager.ShowMessageBox(self.language.ExitTip, nil, cancelFunc)
    box:SetOkText(self.language.ExitCancel)
end

function VIPBestGfitView:ActionIn()
end

function VIPBestGfitView:ActionOut()
    self:Destroy()
end

function VIPBestGfitView:OnDestroy()
    self:unRegisterEvent()
    if self.walletView then
		self.walletView:Destroy()
	end
end

return VIPBestGfitView