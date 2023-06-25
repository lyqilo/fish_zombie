
local CC = require("CC")
local GetTicketView = CC.uu.ClassView("GetTicketView")

function GetTicketView:ctor(param)
	self:InitVar(param);
end

function GetTicketView:InitVar(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    self.isCallBack = true
    self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
    self.switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    self.noviceDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr")
    self.TicketCfg = {{icon = "mianfeijinbi_1",size = Vector2(60,52),describe = self.language.Tex1,count = 2000,onClick = function()
                           local param = {}
                           if self.noviceDataMgr.GetNoviceDataByKey("NewbieTaskView").open then
                               param.currentView = "NewbieTaskView"
                           end
                           CC.ViewManager.Open("FreeChipsCollectionView", param)
                           self:Destroy()
                       end},
                       {icon = "dt_hdtb_sclb_1",size = Vector2(71,53),describe = self.language.Tex2,count = 10000,onClick = function()
                           if CC.Player.Inst():GetFirstGiftState() then
			                   CC.ViewManager.Open("FirstBuyGiftView")
                           else
                               CC.ViewManager.Open("SelectGiftCollectionView")
                           end
                           self:Destroy()
                       end},
                       {icon = "dt_bt_dlxt _1",size = Vector2(51,54),describe = self.language.Tex3,count = 99999,onClick = function()
                            if CC.ViewManager.IsViewOpen("AgentNewView") then
                                self.isCallBack = false
                                self:Destroy()
                                return
                            end
                            if self.switchDataMgr.GetSwitchStateByKey("AgentUnlock") and not self.agentDataMgr.GetForbiddenAgentSatus()
                            and (self.agentDataMgr.GetAgentSatus() or self.switchDataMgr.GetSwitchStateByKey("EPC_LockLevel")) then
                                CC.ViewManager.Open("AgentNewView")
                                self:Destroy()
                            else
                                CC.ViewManager.ShowTip(self.language.Tex8)
                            end
                       end},
                       {icon = "img_yxrk_2003",size = Vector2(60,62),describe = self.language.Tex4,count = 3000,onClick = function() self:GoToGame(2003) end},
                       {icon = "img_yxrk_2005",size = Vector2(60,62),describe = self.language.Tex5,count = 3000,onClick = function() self:GoToGame(2005) end},
                       {icon = "img_yxrk_2011",size = Vector2(60,62),describe = self.language.Tex6,count = 3000,onClick = function() self:GoToGame(2011) end},
                       {icon = "img_yxrk_3002",size = Vector2(60,62),describe = self.language.Tex7,count = 3000,onClick = function() self:GoToGame(3002) end},
                    }
end

function GetTicketView:OnCreate()
    self:InitClickEvent()
    self:InitView()
end

function GetTicketView:GoToGame(gameId)
	local gameInfo = self.gameDataMgr.GetInfoByID(gameId)
	if gameInfo.IsCommingSoon == 1 then
		CC.ViewManager.ShowTip(self.language.Tex15)
	else
		CC.HallUtil.CheckAndEnter(gameId)
	end
end

function GetTicketView:InitClickEvent()
    self:AddClick("Bg/Panel1/Close","ActionOut")
    self:AddClick("Bg/Panel1/Ticket/Btn","OpenRealStore")
    self:AddClick("Bg/Panel1/Explain",function() self:OpenExplain(true) end)
    self:AddClick("Bg/Panel2/Button",function() self:OpenExplain(false) end)
end

function GetTicketView:OpenRealStore()
    if not CC.ChannelMgr.GetSwitchByKey("bHasRealStore") or CC.ChannelMgr.GetTrailStatus() or not self.switchDataMgr.GetSwitchStateByKey("TreasureView") then
        CC.ViewManager.ShowTip(self.view.language.Tex8)
        return
    end
    CC.ViewManager.Open("TreasureView")
    self:Destroy()
end

function GetTicketView:OpenExplain(flag)
    self:FindChild("Bg/Panel2"):SetActive(flag)
    self:FindChild("Bg/Panel1"):SetActive(not flag)
end

function GetTicketView:InitView()
	self:FindChild("Bg/Panel1/Ticket/Num").text = CC.uu.DiamondFortmat(CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher"))
    self:FindChild("Bg/Panel1/Text (1)").text = self.language.Tex13
    self:FindChild("Bg/Panel2/Text1").text = self.language.Tex9
    self:FindChild("Bg/Panel2/Text2").text = self.language.Tex10
    self:FindChild("Bg/Panel2/Text3").text = self.language.Tex11
    self:FindChild("Bg/Panel2/Button/Text").text = self.language.Tex12

    local element = self:FindChild("Bg/Panel1/Scroll View/Viewport/element")
    local parent = self:FindChild("Bg/Panel1/Scroll View/Viewport/Content")
    for i,v in ipairs(self.TicketCfg) do
        local item = CC.uu.newObject(element,parent)
        local iconImage = item:FindChild("Icon")
        self:SetImage(iconImage,v.icon)
        iconImage.sizeDelta = v.size
        item:FindChild("Text").text = v.describe
        item:FindChild("Image/Text").text = "UP TO\n"..v.count
        item:FindChild("Btn/Text").text = self.language.Tex14

        self:AddClick(item:FindChild("Btn"),function() v.onClick() end)

        item:SetActive(true)
    end
end

function GetTicketView:ActionIn()
	self:SetCanClick(false);
    local bg = self:FindChild("Bg")
    bg.localScale = Vector3(0.5,0.5,1)
    self:RunAction(bg, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
    CC.Sound.PlayHallEffect("click_boardopen");
end

function GetTicketView:ActionOut()
	self:SetCanClick(false);
    self:RunAction(self:FindChild("Bg"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})
end

function GetTicketView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil;
    end
    if self.param.callback and self.isCallBack then
        self.param.callback()
    end
end

return GetTicketView