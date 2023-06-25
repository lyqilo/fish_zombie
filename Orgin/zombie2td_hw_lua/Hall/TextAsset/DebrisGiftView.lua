
local CC = require("CC")
local DebrisGiftView = CC.uu.ClassView("DebrisGiftView")

function DebrisGiftView:ctor(param)

	self:InitVar(param);
end

function DebrisGiftView:InitVar(param)
    self.param = param;
    self.WareId = {LeftWareId="30020",RightWareId="30021"}
    self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
end

function DebrisGiftView:OnCreate()
    self:InitNode()
    self:InitUI()
    self:InitClickEvent()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function DebrisGiftView:InitNode(  )
    self.ContentNode = self:FindChild("View/ExplainView/Frame/ScrollText/Viewport/Content")
    self.LeftBtn = self:FindChild("View/ExplainView/LeftBtn")
    self.RightBtn = self:FindChild("View/ExplainView/RightBtn")
    self.FragmentTxt = self:FindChild("View/UI/Tex2/Tex2-1")
end

function DebrisGiftView:InitUI()
    self:FindChild("View/UI/Left/Top").text = self.language.ZuiGao
    self:FindChild("View/UI/Left/Top/Text").text = 300000
    self:FindChild("View/UI/Left/1/Text").text = self.language.SuiPian..1
    self:FindChild("View/UI/Left/2/Text").text = self.language.SuiPian..2
    self:FindChild("View/UI/Left/3/Text").text = self.language.SuiPian..3

    self:FindChild("View/UI/Right/Top").text = self.language.ZuiGao
    self:FindChild("View/UI/Right/Top/Text").text = 1000000
    self:FindChild("View/UI/Right/1/Text").text = self.language.SuiPian..4
    self:FindChild("View/UI/Right/2/Text").text = self.language.SuiPian..6
    self:FindChild("View/UI/Right/3/Text").text = self.language.SuiPian..10

    self:FindChild("View/UI/Tex1").text = self.language.GMJD
    self:FindChild("View/UI/Tex2").text = self.language.SPHDK
    self.FragmentTxt.text = string.format(self.language.SPNum,CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment"))

    self:FindChild("View/Btn/Left/Price").text = self.wareCfg[self.WareId.LeftWareId].Price
    self:FindChild("View/Btn/Right/Price").text = self.wareCfg[self.WareId.RightWareId].Price

    self:FindChild("View/ExplainView/Frame/Tittle/Text").text = self.language.Title
    self.ContentNode.transform:FindChild("Item1/Text").text = self.language.SPSYTJ
    self.ContentNode.transform:FindChild("Item1/Use").text = self.language.YT1
    self.ContentNode.transform:FindChild("Item2/Use").text = self.language.YT2
  
    self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
    self.walletView.transform:SetParent(self.transform, false)
end

function DebrisGiftView:InitClickEvent(  )
    self:AddClick(self:FindChild("View/Btn/Close"),function()
        self:ActionOut()
    end)
    self:AddClick(self:FindChild("View/Btn/Explain"),function()
        --打开说明页
        self:CheckArrow()
        self:FindChild("View/ExplainView"):SetActive(true)
    end)
    self:AddClick(self:FindChild("View/ExplainView/Frame/BtnClose"),function()
        --关闭说明页
        self:FindChild("View/ExplainView"):SetActive(false)
    end)
    self:AddClick(self:FindChild("View/Btn/Left"),function()
        self:OnClickBuyBtn(self.WareId.LeftWareId)
    end)
    self:AddClick(self:FindChild("View/Btn/Right"),function()
        self:OnClickBuyBtn(self.WareId.RightWareId)
    end)
    self:AddClick(self:FindChild("View/Btn/Shop"),function()
        --打开实物商店
        local case1 = CC.ChannelMgr.GetTrailStatus()
        local case2 = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("TreasureView")
        local isCanOpen = false
        if not case1 and case2 then
            isCanOpen = true
        end
        if isCanOpen then
            if not CC.ViewManager.IsViewOpen("TreasureView") then
                CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false)
                local param = {}
                local fun = function()
                    CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true)
                    CC.ViewManager.Open("DebrisGiftView")
                end
                param.callback = fun
                param.OpenViewId = 2
                CC.ViewManager.Open("TreasureView",param)
            end
            self:ActionOut()
        end
    end)
    self:AddClick(self.LeftBtn,function()
        self:SwitchExplainView("Left")
    end)
    self:AddClick(self.RightBtn,function()
        self:SwitchExplainView("Right")
    end)
end

function DebrisGiftView:OnClickBuyBtn(WareId)
    local price = self.wareCfg[WareId].Price
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
        --购买礼包
        CC.Request("ReqBuyWithId",{WareId = WareId, ExchangeWareId = WareId});
    else
        if self.walletView then
              self.walletView:SetBuyExchangeWareId(WareId)
              self.walletView:PayRecharge()
        end
  end
end

function DebrisGiftView:SwitchExplainView(Direction)

    local pos = self.ContentNode.localPosition
    local count = self.ContentNode.childCount - 1
    local posX = math.abs(pos.x)
    local t1,t2 = math.modf(posX/885)
    posX = ""
    if Direction == "Left" and pos.x < 0 then
       if t1 >= 0 and t2 > 0 then
          posX = t1
       elseif t1 > 0 and t2 == 0 then
          posX = t1 -1
       end
    elseif  Direction == "Right" and pos.x > -count*885 then
         posX = t1 + 1
    end
    if posX ~="" then
        self.ContentNode.localPosition = Vector3(-posX*885, pos.y, pos.z)
    end
    self:CheckArrow()
end

function DebrisGiftView:CheckArrow()
    local pos = self.ContentNode.localPosition
    local count = self.ContentNode.childCount - 1
    local result = nil 
    if pos.x >-1 then
        result = false
    elseif pos.x >= -count*885 then
        result = true
    end
    self.LeftBtn:SetActive(result) 
    self.RightBtn:SetActive(not result)
end

function DebrisGiftView:RefreshDebris()
    self.FragmentTxt.text = string.format(self.language.SPNum,CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment"))
end

function DebrisGiftView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function DebrisGiftView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function DebrisGiftView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    if  self.walletView then
        self.walletView:Destroy()
    end
end

return DebrisGiftView