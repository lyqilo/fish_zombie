local CC = require("CC")
local VipThreeCardView = CC.uu.ClassView("VipThreeCardView")

function VipThreeCardView:ctor(param)
    self.param = param;
end

function VipThreeCardView:OnCreate()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.ThreeCardState = true
    self.WareId = "23006"
    self.giftPrice = self.wareCfg[self.WareId].Price or 999
    self:RegisterEvent()
	self:InitUI()
	self:TempFunc()
end

function VipThreeCardView:InitUI()
	self:AddClick(self:FindChild("BtnClose"), "ActionOut")
    self:AddClick(self:FindChild("Panel_UI/UI/BtnBuy"), "OnBuyGift")

    for i=1,3 do
		local tipWindow = self:FindChild("Panel_UI/UI/TipPanel/tips"..i)
        self:AddLongClick(self:FindChild("Panel_UI/UI/Btn"..i),{
            funcClick = function ()
            end,
            funcLongClick = function (  )
                tipWindow:SetActive(true)
            end,
            funcUp = function ()
                tipWindow:SetActive(false)
            end,
            time = 0.1,
        })
    end

    self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform, exchangeWareId = self.WareId})
    CC.Request("GetOrderStatus",{self.WareId})

	self:InitTextByLanguage()
end

function VipThreeCardView:InitTextByLanguage()
	local language = CC.LanguageManager.GetLanguage("L_SelectGiftCollectionView")["VipThreeCardView"];
	self:FindChild("Panel_UI/UI/BtnBuy/Text").text = self.giftPrice
	for i=1,3 do
		local tip = self:FindChild("Panel_UI/UI/TipPanel/tips"..i)
		tip:FindChild("content/context/titleText").text = language["tip"..i.."title"]
		tip:FindChild("content/context/Text").text =language["tip"..i.."text"]
	end
end

function VipThreeCardView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.VipThreeCardBuy,CC.Notifications.VipThreeCard)
    CC.HallNotificationCenter.inst():register(self,self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)
end

function VipThreeCardView:unRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOrderStatus)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.VipThreeCard)
end

function VipThreeCardView:ReqOrderStatusResq(err, data)
    if data.Items then
        for _, v in ipairs(data.Items) do
            if v.WareId == self.WareId then
                self.ThreeCardState = v.Enabled
            end
        end
    end
    log(CC.uu.Dump(data,"data",10))
end

function VipThreeCardView:OnBuyGift()
    if not self.ThreeCardState or CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= 3 then
        return
    end
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.giftPrice then
        local data={}
        data.WareId=self.WareId
        data.ExchangeWareId= self.WareId
        CC.Request("ReqBuyWithId",data)

	else
		if self.walletView then
            self.walletView:PayRecharge()
		end
	end
end

function VipThreeCardView:VipThreeCardBuy(param)
    log(CC.uu.Dump(param,"param",10))
    if param.Source == CC.shared_transfer_source_pb.TS_Vip_GoStraightTo then
        self:ActionOut()
    end
end

function VipThreeCardView:TempFunc()
	--竖屏特效不对，暂时屏蔽
	if self:IsPortraitScreen() then
		self:FindChild("Effect_guang"):SetActive(false)
		self:FindChild("Panel_UI/UI/bg/Effect_ChouMa/guang2"):SetActive(false)
		self:FindChild("Panel_UI/UI/bg/Effect_ChouMa/guang3"):SetActive(false)
		self:FindChild("Panel_UI/UI/bg/Effect_ChouMa/XX"):SetActive(false)
		self:FindChild("Panel_UI/UI/Btn1/Effect_btn"):SetActive(false)
	end
end

function VipThreeCardView:ActionIn()
    if self.param and self.param.isGiftCollection then
        self:SetCanClick(false);
        self:FindChild("mask"):SetActive(false)
		self:FindChild("BtnClose"):SetActive(false)
		self.transform.size = Vector2(125, 0)
		self.transform.localPosition = Vector3(-125 / 2, 0, 0)
		self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
	end
end
function VipThreeCardView:ActionOut()
    self:SetCanClick(false);
    CC.HallUtil.HideByTagName("Effect", false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function VipThreeCardView:OnDestroy()
    --CC.Sound.StopEffect()
    self:unRegisterEvent()
	if self.walletView then
		self.walletView:Destroy()
	end
end

return VipThreeCardView;