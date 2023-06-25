
local CC = require("CC")
local FirstBuyGiftView = CC.uu.ClassView("FirstBuyGiftView")

function FirstBuyGiftView:ctor(param)

	self:InitVar(param);
end

function FirstBuyGiftView:InitVar(param)
    self.param = param
	self.WareId = "30019"
	self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
    self.isShowWinner = false
    self.WinItemTable = {}
    self.IconTab = {}
    self.isCanBuy = false
    self.isCanLottery = false
    self.isCanClick = false
end

function FirstBuyGiftView:OnCreate()
    self:InitNode()
    self:InitUI()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param);
    self.viewCtr:OnCreate();
end

function FirstBuyGiftView:InitNode(  )
    self.ExplainView = self:FindChild("View/ExplainView")
    self.ChipView = self:FindChild("View/Btn/Chip/View")
    self.XingView = self:FindChild("View/Btn/Xing/View")
    self.WinMask = self:FindChild("View/WinnerInfor/Mask")
    self.WinBtn = self:FindChild("View/WinnerInfor/Btn")
    self.WinBtnArrows = self:FindChild("View/WinnerInfor/Btn/Arrows")
    self.WinView = self:FindChild("View/WinnerInfor/View")
    self.RewardPanel = self:FindChild("View/UI/Right/RewardPanel")
    self.NormalEffect = self:FindChild("View/UI/Right/RewardPanel/RewardAnim/EffectNode/Normal")
    self.JackpotEffect = self:FindChild("View/UI/Right/RewardPanel/RewardAnim/EffectNode/Jackpot")
    self.JackPot = self:FindChild("View/UI/Right/Top/Text")
    self.WinItem = self:FindChild("View/WinnerInfor/View/Scroller/Viewport/Item")
    self.WinContent = self:FindChild("View/WinnerInfor/View/Scroller/Viewport/Content")
    self.ExplainItem = self:FindChild("View/ExplainView/ShowPanel/Scroller/Viewport/Content/Item")
    self.ExplainContent = self:FindChild("View/ExplainView/ShowPanel/Scroller/Viewport/Content")

    self.QiPaoAni = self:FindChild("View/UI/Right"):GetComponent("Animator")
    self.NiuDanSpin = self:FindChild("View/UI/Right/NiuDan"):GetComponent("SkeletonGraphic")
    self.RewardSpin = self:FindChild("View/UI/Right/RewardPanel/RewardAnim"):GetComponent("SkeletonGraphic")

    self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform,notBuyGift = true})
end

function FirstBuyGiftView:InitUI()
    self:FindChild("View/Btn/Chip/View/Di/Text").text = self.language.ChipText
    self:FindChild("View/Btn/Chip/Text").text = self.language.ChipExplain
    self:FindChild("View/Btn/Xing/View/Di/Text").text = self.language.XingText
    self:FindChild("View/Btn/Xing/Text").text = self.language.XingExplain
    self:FindChild("View/UI/Left/BottomTip").text = self.language.VipTitleTip
    self:FindChild("View/UI/Right/Top/Text").text = ""
    self:FindChild("View/Btn/Buy/GiftValue").text = self.language.GiftValue
    self:FindChild("View/Btn/Buy/Tip1/LimitTime").text = self.language.LimitTime
    self:FindChild("View/Btn/Buy/Tip1/LotteryTime").text = "0/3"
    self:FindChild("View/Btn/Buy/Price/Text").text = self.wareCfg[self.WareId].Price
    self:FindChild("View/Btn/Buy/LimitBuyExplain").text = self.language.LimitBuyExplain
    self:FindChild("View/WinnerInfor/View/Top/Name").text = self.language.UserName
    self:FindChild("View/WinnerInfor/View/Top/Infor").text = self.language.WinInfor

    self:DelayRun(0.5,function (  )
        self:InitExplainView()
    end)
end

function FirstBuyGiftView:InitClickEvent()
    self:AddClick(self:FindChild("View/Btn/ClostBtn") , function() self:CloseView() end)
    self:AddClick(self:FindChild("View/Btn/ExplainBtn") , function() self.ExplainView:SetActive(true) end)
    self:AddClick(self:FindChild("View/Btn/Buy") , function() self:OnClickBuy() end)
    self:AddClick(self:FindChild("View/WinnerInfor/Btn") , function() self:OnClickWinnerView() end)

    self:AddLongClick(self:FindChild("View/Btn/Chip"),{
        funcLongClick = function() self.ChipView:SetActive(true) end,
        funcUp = function() self.ChipView:SetActive(false) end,
        time = 0.1})
    self:AddLongClick(self:FindChild("View/Btn/Xing"),{
        funcLongClick = function() self.XingView:SetActive(true) end,
        funcUp = function() self.XingView:SetActive(false) end,
        time = 0.1})
end

function FirstBuyGiftView:OnClickBuy()
    if self.activityOver then return  end --活动关闭

    if not self.isCanClick then return --请求未返回，暂时不让点击防止多买多抽

    end
    if self.isCanLottery then
       --请求抽奖
       self.isCanClick = false
       CC.Request("ReqTenFristGiftLottery")
    else
       if not self.isCanBuy then
            --购买达到限购次数
            CC.ViewManager.ShowTip(self.language.LimitBuyTip)
       else
            local price = self.wareCfg[self.WareId].Price
            if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
                --购买礼包
                self.isCanClick = false
                CC.Request("ReqBuyWithId",{WareId = self.WareId, ExchangeWareId = self.WareId})
            else
                if self.walletView then
                    self.walletView:SetBuyExchangeWareId(self.WareId)
                    self.walletView:PayRecharge()
                end
          end
       end
    end
end

function FirstBuyGiftView:StartLotter(data)
    local Number1 = data.data.PayTimes == 3 and 2 or 1
    local Number2 = data.data.AbleTimes == 0 and Number1 or 1
    self:FindChild("View/Btn/Buy/Lottery").text = string.format(self.language.Lottery,Number2.."/"..Number1)
    self:SetCanClick(false)
    local bstate = data.Rewards[1].Count >= data.data.BigRewardValue and true or false
	CC.Sound.PlayHallEffect("gs_niudan")
    self.QiPaoAni:Play("QiPao_Close")
    self:DelayRun(0.3,function(  )
        if self.NiuDanSpin.AnimationState then
            self.NiuDanSpin.AnimationState:ClearTracks()
            self.NiuDanSpin.AnimationState:SetAnimation(0, "stand2", false)
        end
        local LotteryFun = nil
        LotteryFun = function ()
            CC.Sound.PlayHallEffect("gs_reward")
            self:PlayRewardAnim(bstate,data.Rewards,data.data)
            self.NiuDanSpin.AnimationState:ClearTracks()
            self.NiuDanSpin.AnimationState:SetAnimation(0, "stand1", true)
            self.NiuDanSpin.AnimationState.Complete =  self.NiuDanSpin.AnimationState.Complete - LotteryFun
        end
        self.NiuDanSpin.AnimationState.Complete =  self.NiuDanSpin.AnimationState.Complete + LotteryFun
    end)

end

function FirstBuyGiftView:PlayRewardAnim(bstate,Rewards,data)
    local random = bstate and math.random(1,3) or math.random(4,6)
    local ani = random == 1 and "stand" or "stand"..random

    self.RewardPanel:SetActive(true)
    self.RewardSpin:SetActive(true)
    if self.RewardSpin.AnimationState then
        self.RewardSpin.AnimationState:ClearTracks()
        self.RewardSpin.AnimationState:SetAnimation(0, ani, false)
	end
	if random > 3 then
		self.NormalEffect:SetActive(true)
	else
		self.JackpotEffect:SetActive(true)
	end
	local RewardFun = nil
    RewardFun = function ()
        self:RefreshGiftState(data.PayTimes,data.CanPayTimes,data.AbleTimes)
        self:ShowReward(bstate,Rewards)
        self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete - RewardFun
	end
    self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete + RewardFun
end

function FirstBuyGiftView:ShowReward(bstate,Rewards)
	if self.RewardSpin.AnimationState then
        self.RewardSpin.AnimationState:ClearTracks()
        self.RewardSpin.AnimationState:SetAnimation(0, "stand", false)
    end
    self:DelayRun(0.016,function ()
        self:SetCanClick(true)
		self.RewardSpin:SetActive(false)
		self.NormalEffect:SetActive(false)
		self.JackpotEffect:SetActive(false)
        self.RewardPanel:SetActive(false)
        self.QiPaoAni:Play("QiPao_Idle")
		local configId = Rewards[1].ConfigId
		local count = Rewards[1].Count
		if bstate and configId == CC.shared_enums_pb.EPC_ChouMa then
			local param = {};
			param.rewardInfo = {{ConfigId = configId, Count = count}}
			param.rewardType =2;
			CC.ViewManager.Open("TurntableRewardView", param);
		else
			CC.ViewManager.OpenRewardsView({items = Rewards})
		end
    end)
end

function FirstBuyGiftView:OnClickWinnerView()
    self.WinMask:SetActive(not self.isShowWinner)
    if not self.isShowWinner then
        self.WinBtn.localPosition = Vector3(-494,0,0)
        self.WinBtnArrows.localScale = Vector3(-1,1,1)
        self.WinView.localPosition = Vector3(-205,-19,0)
    else
        self.WinBtn.localPosition = Vector3(18,0,0)
        self.WinBtnArrows.localScale = Vector3(1,1,1)
        self.WinView.localPosition = Vector3(344,-19,0)
    end
    self.isShowWinner = not self.isShowWinner

end

function FirstBuyGiftView:ShowWinner(DataList)

    for i,v in ipairs(self.WinItemTable) do
		v.transform:SetActive(false)
    end

    local isShowBg = true
    for i,v in ipairs(DataList) do
        isShowBg = not isShowBg
        local item = self.WinItemTable[i]
        if not item then
            item = CC.uu.newObject(self.WinItem,self.WinContent)
            self.WinItemTable[i] = item.transform
        end
        self.WinItemTable[i] = item.transform
        item:SetActive(true)
        local headNode = item.transform:FindChild("ItemHead")
	    self:DeleteHeadIconByKey(headNode)
	    Util.ClearChild(headNode,false)
	    local param = {}
	    param.parent = headNode
	    param.portrait = v.Portrait
	    param.playerId = v.PlayerId
        param.vipLevel = v.Vip
        param.headFrame = v.Background
	    param.clickFunc = "unClick"
	    self:SetHeadIcon(param,i)
	    if item then
            item.transform:FindChild("Nick"):GetComponent("Text").text = v.Name
            local Tex = ""
            if v.Rewards[1].ConfigId == 2 then
                Tex = "JACKPOT*"..v.Rewards[1].Count
            else
                local propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
                Tex = propLanguage[v.Rewards[1].ConfigId]
            end
            item.transform:FindChild("Num"):GetComponent("Text").text = Tex
            item.transform:FindChild("Time"):GetComponent("Text").text = os.date("%H:%M:%S %d/%m",v.TimeStamp)
            item.transform:FindChild("bg"):SetActive(isShowBg)
            --item.transform:SetAsFirstSibling()
	    end

    end

end

--删除头像对象
function FirstBuyGiftView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

--设置头像
function  FirstBuyGiftView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function FirstBuyGiftView:RefreshJackPot(Num)
    Num = CC.uu.numberToStrWithComma(Num)
    self.JackPot.text = Num
end

function FirstBuyGiftView:RefreshGiftState(PayTimes,CanPayTimes,AbleTimes)
    if not PayTimes or not CanPayTimes or not AbleTimes then return end

    log(string.format("已购买次数：%s    限购次数：%s     剩余抽奖次数：%s",PayTimes,CanPayTimes,AbleTimes))
   
    self.isCanBuy = PayTimes < CanPayTimes
    self.isCanLottery = AbleTimes > 0
    
    local Number1 = PayTimes == CanPayTimes and 2 or 1
    local Number2 = Number1 - AbleTimes
    self:FindChild("View/Btn/Buy/Lottery").text = string.format(self.language.Lottery,Number2.."/"..Number1)
    self:FindChild("View/Btn/Buy/Tip1/LotteryTime").text = PayTimes.."/3"
    self:FindChild("View/Btn/Buy/Price"):SetActive(not self.isCanLottery)
    self:FindChild("View/Btn/Buy/Lottery"):SetActive(self.isCanLottery)

    if PayTimes > CanPayTimes then
		self.isCanLottery = false
        self:FindChild("View/Btn/Buy/Price"):SetActive(true)
        self:FindChild("View/Btn/Buy/Lottery"):SetActive(false)
    end
end

function FirstBuyGiftView:InitExplainView()
    local Rewards = {{ConfigId = 2 , Txt = "JACKPOT 50%"},{ConfigId = 10001 , Txt = self.language.DianKa},
                    {ConfigId = 46 ,Txt = self.language.liPiao},{ConfigId = 2 , Txt = self.language.Chip6K},{ConfigId = 2 , Txt = self.language.Chip3K},
                    }
    self:OpenEffect()
    for i,v in ipairs(Rewards) do
        local item = CC.uu.newObject(self.ExplainItem,self.ExplainContent)
        local icon = self.PropDataMgr.GetIcon(v.ConfigId)
        self:SetImage(item:FindChild("Prop"),icon)
        item:FindChild("Prop"):GetComponent("Image"):SetNativeSize()
        item:FindChild("Text").text = v.Txt
        item:SetActive(true)
    end
    self:FindChild("View/ExplainView/ShowPanel/Decorate/Tips/Text").text = self.language.ExplainTip
    self:FindChild("View/ExplainView/ShowPanel/Title").text = self.language.Title
    self:FindChild("View/ExplainView/ShowPanel/Content").text = self.language.Content
    self:AddClick(self:FindChild("View/ExplainView/ShowPanel/BtnClose") , function() self.ExplainView:SetActive(false) end)
end

function FirstBuyGiftView:OpenEffect()
    local viewport = self:FindChild("View/ExplainView/ShowPanel/Scroller/Viewport");
	local wordPos = viewport:GetComponent("RectTransform"):GetWorldCorners()
	local minX = wordPos[0].x;
	local minY = wordPos[0].y;
	local maxX = wordPos[2].x;
	local maxY = wordPos[2].y;
    local coms = self.ExplainItem:FindChild("Effect/Glow"):GetComponent(typeof(UnityEngine.Renderer))
	coms.material:SetFloat("_MinX",minX);
	coms.material:SetFloat("_MinY",minY);
	coms.material:SetFloat("_MaxX",maxX);
	coms.material:SetFloat("_MaxY",maxY);
end

function FirstBuyGiftView:CloseView()
    local playerData = CC.Player.Inst():GetSelfInfo().Data.Player
    local IsFirClose = Util.GetFromPlayerPrefs("isFirCloseFirstBuyGift"..tostring(playerData.Id))
    self:SetCanClick(false);
    if IsFirClose == "false" then
        self:Destroy()
    else
        --第一次关闭页面
        local hallview = CC.ViewManager.GetReplaceView()
        if CC.ViewManager.IsHallScene() and hallview then
            Util.SaveToPlayerPrefs("isFirCloseFirstBuyGift"..tostring(playerData.Id), "false")

            hallview:OnFocusIn()
            local tarPosObj = self:FindChild("View/TargetPos").transform
            tarPosObj.position = hallview.FirstGiftBtn.transform.position
            local toPos = tarPosObj.localPosition

            if self.walletView then
                self.walletView.transform:SetActive(false)
            end

            local ViewAnimator = self:FindChild("View"):GetComponent("Animator")
            ViewAnimator:Play("View_Close")
            
            self:RunAction(self:FindChild("View"), {"spawn",{"localMoveTo", toPos.x-20,toPos.y, 0.6}, {"scaleTo", 0,0, 0.6,function ()
                self:Destroy()
                end}})
        else
            self:Destroy()
        end
    end

    if self.param and self.param.closeFunc then
        self.param.closeFunc()
    end
    if CC.ViewManager.GetExitToGuideId() then
        CC.ViewManager.Open("GuideToGameView")
    end
end

function FirstBuyGiftView:ActionIn()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function FirstBuyGiftView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function FirstBuyGiftView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil;
    end
    if self.walletView then
        self.walletView:Destroy()
    end
end

return FirstBuyGiftView