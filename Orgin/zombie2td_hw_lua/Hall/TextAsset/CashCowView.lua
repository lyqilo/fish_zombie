local CC = require("CC")
local M = CC.uu.ClassView("CashCowView")

function M:OnCreate()
    self:Init()
    self:ActionIn()
    self:AddListener()
end

function M:Init()
    self.wareId = CC.SubGameInterface.GetGiftWareId('BY_FishMatchGiftTree')

    local param={}
    param.wareId = self.wareId
    param.parent = self.transform
    param.width = 1280
    param.height = 720
    param.succCb = function() end
    self.hallWalletView = CC.SubGameInterface.CreateWalletView(param)

    self.frame = self:FindChild("Frame")

    self.TreeSkeleton=self.frame:FindChild("Effect_Tree/spine"):GetComponent("SkeletonGraphic")

    self.TreeEffect={}
    self.TreeEffectParent= self.frame:FindChild("Effect_Tree")
    local TreeEffect= self.frame:FindChild("Effect_Tree/Effect_Tree_Hit")
    table.insert( self.TreeEffect,TreeEffect)

    local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
    local price = wareCfg[self.wareId].Price
    self:SetText("Frame/Btn_Buy/Text", price)
end

function M:AddListener()
    self:AddClick('Frame/BtnClose', 'OnClickClose')
    self:AddClick('Frame/Btn_Buy', 'OnClickBuy')
    self:AddClick("Frame/RewardPanel/black","HideRewardPanel")
    self:AddClick("Frame/Effect_Tree/BtnTree","OnCilckTree")
    CC.HallNotificationCenter.inst():register(self,self.ShowReward,CC.Notifications.changeSelfInfo)
end


function M:OnCilckTree( )

    if self.TreeTween then
        self:CancelDelayRun(self.TreeTween)
    end
    self.TreeSkeleton.AnimationState:SetAnimation(0, "hit", true)
    self.TreeTween= self:DelayRun(0.3,function (  )
        self.TreeSkeleton.AnimationState:SetAnimation(0, "stand", true)
        self.TreeTween=nil
    end)
    self:GetTreeEffect()

end

function M:OnClickBuy()
    local param = {}
    param.wareId = self.wareId
    param.walletView = self.hallWalletView
    CC.SubGameInterface.DiamondBuyGift(param)
end

function M:OnClickClose()
    CC.SubGameInterface.DestroyWalletView(self.hallWalletView)
    self:ActionOut()
end

function M:ShowReward(items,source)
    if source == CC.shared_transfer_source_pb.TS_BY_Match_Tree then
        self:ShowRewardPanel(items[1].Delta)
    end
end

function M:RemoveListener()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end


function M:GetTreeEffect()
    local localEffect
    if #self.TreeEffect==1 then
        localEffect=CC.uu.newObject(self.TreeEffect[1],self.TreeEffectParent)
    else
        localEffect=self.TreeEffect[2]
        table.remove( self.TreeEffect,2)
    end
    localEffect:SetActive(true)
    self:DelayRun(1,function ()
        localEffect:SetActive(false)
        table.insert( self.TreeEffect,localEffect)
    end)
end

function M:ActionIn()
    self:RunAction(self.frame,{"fadeTo",255,0})
    self.frame.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self.frame, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    	end})
end

function M:ActionOut()
    self:RunAction(self.frame,{"fadeTo",0,0.3})
    self:RunAction(self.frame, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
       self:Destroy()
    end})
end

function M:ShowRewardPanel( Reward )
    self.frame:FindChild("RewardPanel/pddb/Text").text=CC.uu.numberToStrWithComma(Reward)
    self.frame:FindChild("RewardPanel"):SetActive(true)
    if self.HideTween then
        self:CancelDelayRun(self.HideTween)
    end
    self.HideTween=self:DelayRun(5,function()
        self:HideRewardPanel()
    end)
end

function M:HideRewardPanel( )
    self.frame:FindChild("RewardPanel"):SetActive(false)
end

function M:OnDestroy()
    self:RemoveListener()
end

return M