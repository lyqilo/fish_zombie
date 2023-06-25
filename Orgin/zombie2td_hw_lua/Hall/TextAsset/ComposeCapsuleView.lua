local CC = require("CC")

local RightRankView = require("View/RightRankView/RightRankView")
local CapsuleView = require("View/CapsuleView/CapsuleView")
local ComposeCapsuleView = CC.uu.ClassView("ComposeCapsuleView",nil,CapsuleView)


function ComposeCapsuleView:ctor(param)
    self.param = param
end

function ComposeCapsuleView:OnCreate()
    self.language = self:GetLanguage()
    self.MarqueeList = nil
    self:InitUI()

    local viewCtrClass = require("View/CapsuleView/ComposeCapsuleViewCtr")
    self.viewCtr = viewCtrClass.new(self,self.param)
    self.viewCtr:OnCreate()
	self:InitTextByLanguage()
    self:AddClickEvent()
    
    self:RefreshSelfInfo()
end

function ComposeCapsuleView:InitUI()
    self.ChipNum = self:FindChild("Layer_UI/ChipCounter/Icon/Text")
    self.KeyNum = self:FindChild("Layer_UI/KeyCounter/Icon/Text")

    self.Bubble = self:FindChild("Layer_UI/CapsuleAnim/QP"):GetComponent("Animator")

    self.CapsuleSpin = self:FindChild("Layer_UI/CapsuleAnim"):GetComponent("SkeletonGraphic")

    self.Reward = self:FindChild("Layer_UI/OnceAnim")
    self.RewardSpin = self:FindChild("Layer_UI/OnceAnim"):GetComponent("SkeletonGraphic")
    self.RewardEffext = self:FindChild("Layer_UI/OnceAnim/BoneFollower/RewardEffect")

    self.MoreReward = self:FindChild("Layer_UI/MoreAnim")
    self.parent = self:FindChild("Layer_UI")
    
    self.TipsPanel = self:FindChild("Layer_TipsPanel")

    self.ShowOBJ = nil

    self:SpinAnim()
    self:RefrshMoreReward()

    self.rankPanel = RightRankView.new()
    local param = {}
    param.parent = self:FindChild("RightRankNode")
    param.req = function ()
        CC.Request("ReqGetCombineEggMarquee")
    end
    self.rankPanel:Create(param)
end

function ComposeCapsuleView:InitTextByLanguage()
    self:FindChild("Layer_UI/ChipBtn/Text").text = self.language.OnceBtn
    self:FindChild("Layer_UI/ChipBtn/Price").text = self.language.ChipPrice
    self:FindChild("Layer_UI/ChipExBtn/Text").text = self.language.MoreBtn
    self:FindChild("Layer_UI/ChipExBtn/Price").text = self.language.ChipPrice * 10
    self:FindChild("Layer_UI/KeyBtn/Text").text = self.language.OnceBtn
    self:FindChild("Layer_UI/KeyBtn/Price").text = self.language.KeyPrice
    self:FindChild("Layer_UI/KeyExBtn/Text").text = self.language.MoreBtn
    self:FindChild("Layer_UI/KeyExBtn/Price").text = self.language.KeyPrice * 10
    self:FindChild("Layer_UI/TipsBtn/Text").text = self.language.TimeLabel
    self:FindChild("Layer_UI/TipsBtn/Text/Time").text = self.language.Time
    self:FindChild("Layer_UI/ShareDes").text = self.language.Tips_ShareDes
    self:FindChild("Layer_TipsPanel/BG/Title/Text").text = self.language.Tips_Title
    self:FindChild("Layer_TipsPanel/BG/Des").text = self.language.Tips_Des
    self:FindChild("Layer_TipsPanel/BG/Shadow/ChipLabel").text = self.language.Tips_ChipLabel
    self:FindChild("Layer_TipsPanel/BG/Shadow/KeyLabel").text = self.language.Tips_KeyLabel
    self:FindChild("Layer_TipsPanel/BG/Shadow/KeyGift").text = self.language.Tips_KeyGift
    self:FindChild("Layer_TipsPanel/BG/Shadow/KeyDes").text = self.language.Tips_KeyDes
    self:FindChild("Layer_TipsPanel/BG/Shadow/KeyLimit").text = self.language.Tips_KeyLimit
    self:FindChild("Layer_TipsPanel/BG/Shadow/Button/Text").text = self.language.Tips_GOBtn
    for i=1,5 do
        self:FindChild("Layer_TipsPanel/BG/Shadow/ChipDes"..i).text = self.language["Tips_ChipDes"..i]
        self:FindChild("Layer_TipsPanel/BG/Shadow/ChipVip"..i).text = self.language["Tips_ChipVip"..i]
    end
end

function ComposeCapsuleView:AddClickEvent()
    self:AddClick("Layer_UI/ChipBtn",function ()
        self.viewCtr:ReqLottery(1,1)
    end)
    self:AddClick("Layer_UI/ChipExBtn",function ()
        self.viewCtr:ReqLottery(1,10)
    end)
    self:AddClick("Layer_UI/KeyBtn",function ()
        self.viewCtr:ReqLottery(4,1)
    end)
    self:AddClick("Layer_UI/KeyExBtn",function ()
        self.viewCtr:ReqLottery(4,10)
    end)
    self:AddClick("Layer_UI/ChipCounter",function ()
        if CC.ViewManager.IsHallScene() then
            CC.ViewManager.Open("StoreView", {channelTab = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType.Chip});
        end
    end)
    self:AddClick("Layer_UI/KeyCounter",function ()
        if CC.ViewManager.IsHallScene() then
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "CompositeGiftView")
        end
    end)
    self:AddClick("Layer_UI/TipsBtn",function ()
        self.TipsPanel:SetActive(true)
        self:SetCanClick(false);
        self.TipsPanel.localScale = Vector3(0.5,0.5,1)
        self:RunAction(self.TipsPanel, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
    end)
    self:AddClick("Layer_TipsPanel/BG/CloseBtn",function ()
        self:RunAction(self.TipsPanel, {"scaleTo", 0, 0, 0.2, ease=CC.Action.EOutQuad, function()
    		self.TipsPanel:SetActive(false)
    	end})
    end)
    self:AddClick("Layer_TipsPanel/BG/Shadow/Button",function ()
        self:RunAction(self.TipsPanel, {"scaleTo", 0, 0, 0.1, ease=CC.Action.EOutQuad, function()
            self.TipsPanel:SetActive(false)
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "CompositeGiftView")
    	end})
    end)

    self:AddClick("Layer_UI/ShareDes/ShareBtn",function ()
        local param = {}
        param.isShowPlayerInfo = true
        param.webText = self.language.Tips_ShareDes
        CC.ViewManager.Open("CaptureScreenShareView",param)
    end)
end


function ComposeCapsuleView:RefreshSelfInfo()
    self.ChipNum.text = CC.uu.ChipFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
    self.KeyNum.text = CC.uu.ChipFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_CombineEgg_Key"))
end

function ComposeCapsuleView:ShowMarquee()
    self.MarqueeList = self.viewCtr.realDataMgr.GetCombineEggMarquee()
    self.rankPanel:RefreshScroller(self.MarqueeList)
end

function ComposeCapsuleView:OnResume()
end

function ComposeCapsuleView:ActionIn()
end


function ComposeCapsuleView:ActionOut()
	self:Destroy()
end

function ComposeCapsuleView:SetCanClick(flag)
    self._canClick = flag;
    self:FindChild("Mask"):SetActive(not flag)
end


function ComposeCapsuleView:OnDestroy()
    self:StopAllAction()
    self:StopAllTimer()
    self:CancelAllDelayRun()
    if self.rankPanel then
        self.rankPanel:Destroy()
    end
    if self.viewCtr then
        self.viewCtr:Destroy()
        self.viewCtr = nil
    end
end


return ComposeCapsuleView