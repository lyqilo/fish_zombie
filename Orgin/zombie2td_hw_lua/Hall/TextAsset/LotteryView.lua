local CC = require("CC")
local uu = require("Common/uu")
local LotteryView = CC.uu.ClassView("LotteryView")
local LotteryProto = require "Model/LotteryNetwork/game_message_pb"
local LotteryData = require("View/LotteryView/LotteryData")

local _InitVar
local _OnClickBack
local _StartSrollNumbers
local _UpdateNumBg
local _OnClickNum
local _OnClickKeyboard
local _BindEvent
local _FindNode
local _InitUI
local _InitSound
local _ResetSound
local _SetLanguage
local _PlayNotice
local _OpenKeyboard
local _CloseKeyboard
local _ChangeLotteryNumber
local _StopMailAnim
local _StartCoinEffect
local _StartMailAnim
local _ShowShootingStar
local _CreateShootingStar
local _InitDebugPanel
local _UpdateBetNum
local _UpdateBetPrice
local _ShowNoticeBanner
local _HideNoticeBanner


local priceList={
    {name="Price_One",num="1",coin="50,000,000"},
    {name="Price_Two",num="2",coin="5,000,000"},
    {name="Price_Three",num="97",coin="1,500,000"},
    {name="Price_Four",num="99",coin="1,500,000"},
    {name="Price_Five",num="900",coin="750,000"},
    {name="Price_Six",num="900",coin="750,000"},
    {name="Price_Seven",num="8,991",coin="150,000"},
    {name="Price_Eight",num="89,910",coin="10,000"}
}
-- prefsKey
local ReadLotteryMail = "ReadLotteryMail" 
local LotteryCoinEffect = "LotteryCoinEffect"

function LotteryView:ctor(param)
    _InitVar(self,param)
end

function LotteryView:OnCreate()
    self.language = self:GetLanguage()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
    _FindNode(self)
    _BindEvent(self)
    _InitUI(self)
    _InitSound(self)
    _InitDebugPanel(self)
    ResourceManager.LoadAssets("material", {"LotNumber"}, function(pref) self.blurMaterial = pref[0] end)
end

function LotteryView:InitContent(param)
end

function LotteryView:OnCoinChange(coins)
    if string.len(tostring(coins)) > 8 then
        self.myChipTxt.text = CC.uu.ChipFormat(coins)
    else
        self.myChipTxt.text = uu.numberToStrWithComma(coins)
    end
end

function LotteryView:LotteryLatternNtf(data)
    local getPriceDetail = function( nType,nRewardFlag )
        if nType > 0 and nType <= 2 then
            return priceList[nType].name
        elseif nType > 2 and nType <= 4  then
            local tindex = nType +( nType - 3) + nRewardFlag
            return priceList[tindex].name
        elseif  nType > 4 and nType <= 6  then
            return priceList[nType + 2].name
        end
    end
    if #data.arrLotteryLattern > 0 then
        _ShowNoticeBanner(self)
        local strs={}
        for _,v in ipairs(data.arrLotteryLattern) do  
            table.insert(strs,string.format("%s<color=#00f232>%s</color>  <color=#DCDCDC>%s</color> %s <color=#fdfc00>%s</color> %s",
            self.language.LastReward,
            v.szNickName,
            self.language[getPriceDetail(v.nType,v.nRewardFlag)],
            self.language.Reward,
            uu.numberToStrWithComma(v.lHitRewardNum),
            self.language.Chip))
        end 
        if #strs > 0 then
            _PlayNotice(self,strs)
        end
    else
        _HideNoticeBanner(self)
    end
end

function LotteryView:OnChangeGameInfo(data)
    if self.viewCtr.GameInfo.enState ~= LotteryProto.GameState_Stage_Purchase then
        _CloseKeyboard(self)
    end
    
    local content = self:FindChild("main/content")
    local result = self:FindChild("main/result")
    local rwrap = result:FindChild("wrap")
    --准备阶段的界面
    local readyTip = self:FindChild("main/content/readyTip")
    --购买阶段的界面
    local buySection = self:FindChild("main/content/buySection")
    local isStageShow = data.enState == LotteryProto.GameState_Stage_Show
    result:SetActive(isStageShow)
    content:SetActive(not isStageShow)
    self.numbersContainer:SetParent((isStageShow and {result} or {buySection})[1])
    local isOpenReady= data.enState == LotteryProto.GameState_Stage_OpenReady
    local timeStr=(isOpenReady and {self.language.OpenTime} or {self.language.DeadLine})[1]
    readyTip:SetActive(isOpenReady)
    self:UpdateButtonStatus()

    if isStageShow then
        if math.abs(data.lCurServerTime - data.lLastOpenTime)<3 then
            _HideNoticeBanner(self) -- 隐藏已经过期的跑马灯和排行榜按钮

            _StartSrollNumbers(self)
            rwrap:SetActive(false)
            self:DelayRun(4,function() 
                _ChangeLotteryNumber(self,data.szLotteryNumber)
                self:DelayRun(0.5,function() 
                    rwrap:SetActive(true)
                    self.viewCtr:LotteryLatternReq()
                end)
            end)
        else
            _ChangeLotteryNumber(self,data.szLotteryNumber)
        end
    elseif data.enState == LotteryProto.GameState_Stage_Purchase then
        _ChangeLotteryNumber(self,"      ")
    end
    --彩票期号
    self:FindChild("main/UI_CurrentLotteryNumber/order"):GetComponent("Text").text=data.szIssue
    --截止时间  00:00:00这种格式
    local deadlineTime = data.lOpenTime - (isOpenReady and {0} or {data.lLimitInterval})[1]
    self.deadlineNode:GetComponent("Text").text=timeStr..os.date("%H:%M:%S",deadlineTime)
    

    local UpdateTxt= function()
        --当前时间
        local curTime=data.lCurServerTime + Time.realtimeSinceStartup - self.syncTime
        --开奖剩余时间
        local remainTime = math.max(data.lOpenTime - curTime,0)
        --最近一次开始售卖的时间(可能是上一次也可能是下一次))
        local nextSellTime = data.lLastOpenTime + data.lPublicShowInterval
        self.remainTimeNode.text=uu.TicketFormat(remainTime)
        --下一次预售倒计时
        self.preSellTimeNode.text=uu.TicketFormat(math.max(nextSellTime - curTime,0))
        -- 添加功能 19.3.11 为倒计时添加UI进度条 BEGIN
        -- log("进度条数据测试 开奖截止 remainTime/(data.lOpenTime-data.lLastOpenTime)" .. tostring(remainTime/(data.lOpenTime-data.lLastOpenTime)))
        self.rtProgressBar.fillAmount = 1 - remainTime/(data.lOpenTime-data.lLastOpenTime)
        if isOpenReady then
            self.dlProgressBar:SetActive(false)
        else
            self.dlProgressBar:SetActive(true)
            -- log("进度条数据测试 禁售截止 remainTime/(deadlineTime - nextSellTime)" .. tostring(remainTime/(deadlineTime - nextSellTime)))
            remainTime = math.max(deadlineTime - curTime,0)
            self.dlProgressBar:GetChild(0):GetComponent("Image").fillAmount = 
            1- remainTime/(deadlineTime - nextSellTime)
        end
        -- 19.3.11 为倒计时添加UI进度条 END

    end
    --同步的时间
    self.syncTime=Time.realtimeSinceStartup;
    --因为定时器的误差，0.9秒的间隔更新 显示效果更佳
    self:StartTimer("nextAward", 0.9, UpdateTxt, -1)
    UpdateTxt()

    self:OnPurchasedNum(data.nOwnLotteryNum)
    _UpdateBetPrice(self) -- 更新价格
    if not self:IsResultNumberScrolling() then
        self.viewCtr:LotteryLatternReq()
    end

    if not self.bFirstEnter then
        self.bFirstEnter = true
        local child = self.numbersContainer:GetChild(0)
        _OnClickNum(self,child,1)
    end
end

-- 判断是否是在做结束摇奖动画
function LotteryView:IsResultNumberScrolling(  )
    return self.isNumberScrolling and self.viewCtr.GameInfo.enState == 3
end

function LotteryView:OnDestroy()
    _ResetSound(self)
    self:StopTimer("nextAward")
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
    self.lotteryData.PurchaseNumCache = {}
    self.lotteryData.PurchaseRecordCache = {}
    self.lotteryData.PastLotteryCache = {}
end

function LotteryView:OnPurchasedNum(num,bjump)
    local node = self:FindChild("main/content/buySection/buyedTip")
    node:GetChild(1):GetComponent("Text").text=num
    node:GetComponent("Animator"):Play("lotnumjump",-1,(bjump and {0} or {0.99})[1])
end

function LotteryView:OnRandSelection(data)
    _ChangeLotteryNumber(self,data.szLotteryNumber)
end

function LotteryView:OnPoolDataChange(lShowMoney,lDelta)
    local totalValue = lShowMoney + lDelta
    local amountStr = uu.numberToStrWithComma(totalValue)
    local newLotterNum = 0
    if lDelta then
        newLotterNum = uu.numberToStrWithComma(lDelta)
    end
    self.amountNode.text = amountStr
    

    local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    if vipLevel ~= nil then
        local newLotter = string.format("<color=#1DE71D>%s </color>",newLotterNum)
        self.premiumsNode.text = "VIP"..vipLevel .. " " .. self.language.VipPremiums .. " " ..newLotter
    end
    
    -- 更新左侧奖励列表头奖的数据
    local jocketPricedeNode =  self.pricedesContainer:GetChild(0)
    local nodeName = jocketPricedeNode:GetChild(0)
    local nodeImage = jocketPricedeNode:GetChild(1)
    local nodeNum = jocketPricedeNode:GetChild(2)
    nodeNum:GetComponent("Text").text = amountStr
    self:DelayRun(0.1,function(  )
        local childWith = nodeName.sizeDelta.x + nodeImage.sizeDelta.x +  nodeNum.sizeDelta.x 
        if childWith > self.pricedesContainer.sizeDelta.x then
            self.pricedesContainer.sizeDelta = Vector3(childWith + 15,self.pricedesContainer.sizeDelta.y,0)
        end
    end)
end

function LotteryView:OnBuyLottery(data)
    CC.ViewManager.ShowTip(self.language.Purchase_Success)
    _CreateShootingStar(self,data.lotteryInfo.nPurchaseNum)
end


function LotteryView:UpdateRewardAnim( )
    local data  = self.viewCtr.rAnimData
    if data then
        if self:IsResultNumberScrolling() then
            self.waitShowRewardAnim = true
            return
        end
        local emailRead = Util.GetFromPlayerPrefs(ReadLotteryMail)
        if emailRead and emailRead == data.szIssue then
            _StopMailAnim(self)
        else
            _StartMailAnim(self)
        end
        local coinPrefs = Util.GetFromPlayerPrefs(LotteryCoinEffect)
        if coinPrefs and coinPrefs == data.szIssue then
            
        else
            _StartCoinEffect(self,data.nIsHitReward)
        end
    end
end

function LotteryView:onLotteryRecord()
    -- 打开往期中奖界面
    CC.ViewManager.Open("PastLotteryView",{ mainView = self})
end

function LotteryView:onBuyedRecord()
    -- 打开往期购买界面
    CC.ViewManager.Open("PurchaseRecordView",{ mainView = self})
end

function LotteryView:onBuyedRecordDetail()
    -- 打开当期详细购买数据界面
    CC.ViewManager.Open("MyPurchaseNumView",{ mainView = self,szIssue = self.viewCtr.GameInfo.szIssue, fromMainView = true})

end

function LotteryView:onRule()
    -- 打开规则界面
    CC.ViewManager.Open("LotteryRuleView",{ mainView = self})
end

function LotteryView:onMail(  )
    _StopMailAnim(self)
    CC.ViewManager.Open("MailView")
end

function LotteryView:onRankView(  )
    CC.ViewManager.Open("LotteryRankView",{ mainView = self})
end

function LotteryView:UpdateButtonStatus(force)
    local canR = self.viewCtr.GameInfo.enState == LotteryProto.GameState_Stage_Purchase  -- 校验状态
    and not self.isNumberScrolling -- 是否在转动

    local canBuy 
    if self.banBuy then
        canBuy = not self.banBuy
    elseif force ~= nil then
        canBuy = force
    else
        canBuy = #self.viewCtr.InputNumber == 6 and canR and self.viewCtr:CheckCoinEnough(true) -- 是否金币足够
    end
    UIEvent.BtnInteractable(self.buyBtn,canBuy)
    UIEvent.BtnInteractable(self.buyBtn:FindChild("chip"),canBuy)
    UIEvent.BtnInteractable(self.selBtn,canR)
end

function LotteryView:ActionIn()
    
end

function LotteryView:SetBuyBtnState(flag)
    UIEvent.BtnInteractable(self.buyBtn,flag)
end

_StartSrollNumbers = function(self,param)
    self.isNumberScrolling = true
    self:FindChild("main/lotbg/wrap"):SetActive(false)

    for i=1,self.numbersContainer.childCount do
        local child=self.numbersContainer:GetChild(i-1)
        local txt1=child:GetChild(0):GetComponent("Text")
        local txt2=child:GetChild(1):GetComponent("Text")
        local anitor=child:GetComponent("Animator")
        
        txt1.material = self.blurMaterial
        txt1.material:SetFloat("_Iteration",0.003)
        txt2.material = txt1.material

        anitor:Play("lotnumscroll",-1,0)
        local component = child:GetComponent("Elf_AnimatorEventHandle")
        component:SetHandleEventFun(function(eventName) 
            if eventName == "shownumber" and self.isNumberScrolling then
                txt1.text=math.random(0,9)
            elseif self.isNumberScrolling then
                txt2.text=math.random(0,9)
            end
            if not self.isNumberScrolling and eventName == "shownumber" then
                txt1.material = nil
                txt2.material = nil
                self:FindChild("main/lotbg/wrap"):SetActive(true)
                anitor:SetTrigger("slow")
            end
        end)
    end
end

_InitVar = function(self,param)
    self.lotteryData = LotteryData
    self.param = param
    self.focusTxt = nil
    self.focusFrame = nil
    self.keyboardAnimator = nil
    self.SStarDelay = {}
    self.betNumLongClick = nil
    self.quaternion = Quaternion()
end

-- 更新浮标对应数字的背景
_UpdateNumBg = function(self,index)
    for i=1,6 do
        local inputFiled=self.numbersContainer:GetChild(i-1):GetChild(0):GetComponent("Text")
        if inputFiled.text ~= "" then
            self.numbgChilds[i]:SetActive(false)
        end
    end
    if index then
        self.numbgChilds[index]:SetActive(true)
    end
end

_OnClickNum = function(self,child,i)
    if not self.isNumberScrolling and self.viewCtr.GameInfo.enState == LotteryProto.GameState_Stage_Purchase then
        _OpenKeyboard(self)
        self.focusTxt = child
        self.focusFrame:SetParent(self.focusTxt,false)

        _UpdateNumBg(self,i)
    end
end

_OnClickKeyboard = function(self,child)
    if child.name == "del" then
        _ChangeLotteryNumber(self,"      ")
        self.focusTxt = self.numbersContainer:GetChild(0)
        self.focusFrame:SetParent(self.focusTxt,false)
    elseif child.name == "ok" then
        _CloseKeyboard(self)
    else
        local txt=self.focusTxt:GetChild(0):GetComponent("Text")
        txt.text = child.name
        local num=""
        for j=1,self.numbersContainer.childCount do
            local str=self.numbersContainer:GetChild(j-1):GetChild(0):GetComponent("Text").text
            num=num..(str=="" and {" "} or {str})[1]
        end
        _ChangeLotteryNumber(self,num)
        --跳到下一个 数字框
        if self.focusTxt.name+1 < 6 then
            self.focusTxt = self.numbersContainer:GetChild(self.focusTxt.name+1)
            self.focusFrame:SetParent(self.focusTxt,false)
            _UpdateNumBg(self,self.focusTxt.name+1)
        end
    end
end

_BindEvent = function(self)
    self:AddClick("main/Close", "Destroy")
    self.prizesAni=self:FindChild("leftPro/left/pricedes"):GetComponent("Animator")
    self.prizesAni:SetFloat("speed",-1)
    self.prizesAni:Play("pricelist",-1,0.01)
    local toggle = self:FindChild("leftPro/left");
	UIEvent.AddToggleValueChange(toggle, function(selected)
        self.prizesAni:SetFloat("speed",(selected and {-1} or {1})[1])
        self.prizesAni:Play("pricelist",-1,(selected and {1} or {0})[1])
    end)
            
    self:AddClick("main/content/buySection/selBt", function() 
        _CloseKeyboard(self)
        if self.viewCtr:CheckCoinEnough() then
            self:UpdateButtonStatus()
            self.viewCtr:RandSelection()
            _StartSrollNumbers(self)
        end
    end)
    self:AddClick("main/content/buySection/buyBt",function()  
        _CloseKeyboard(self)
        self:SetBuyBtnState(false)
        self.viewCtr:BuyLottery() 
    end) 
    self:AddClick("main/bg",function() _CloseKeyboard(self) end)
    self:AddClick("main/recordBt", "onLotteryRecord")
    self:AddClick(self.buyedBt, "onBuyedRecord")
    self:AddClick("main/ruleBt", "onRule")
    self:AddClick("main/mailBt", "onMail")
    self:AddClick("main/result/wrap/tip","onMail")
    self:AddClick("main/content/buySection/buyedTip", "onBuyedRecordDetail")
    --打开排行榜界面
    self:AddClick(self.rankBt,"onRankView")
    self:AddClick("main/ChipCounter/BtnAdd", function() CC.ViewManager.Open("StoreView") end)

    local numberkeys=self:FindChild("numberkeys")
    self.focusFrame = self:FindChild("main/content/buySection/focus")
    self.keyboardAnimator=numberkeys:GetComponent("Animator")
    self.numbersContainer=self:FindChild("main/content/buySection/inputContainer")
    for i=1,self.numbersContainer.childCount do
        local child=self.numbersContainer:GetChild(i-1)
        self:AddClick(child, function() _OnClickNum(self,child,i) end,"lotteryXuanHao")
    end

    for i=1,numberkeys.childCount do
        local child=numberkeys:GetChild(i-1)
        self:AddClick(child, function() _OnClickKeyboard(self,child) end,"lotteryXuanHao")
    end
    
    -- 筹码加减
    self:AddLongClick(self.betNumAdd,{
        funcClick =function (  )
            _UpdateBetNum(self,1)
        end,
        funcLongClick = function (  )
            _UpdateBetNum(self,1,nil,true)
        end,
        funcUp = function (  )
            self:CancelDelayRun(self.betNumLongClick)
        end,
    })
    self:AddLongClick(self.betNumAdd5,{
        funcClick =function (  )
            _UpdateBetNum(self,5)
        end,
        funcLongClick = function (  )
            _UpdateBetNum(self,5,nil,true)
        end,
        funcUp = function (  )
            self:CancelDelayRun(self.betNumLongClick)
        end,
    })
    self:AddLongClick(self.betNumCut,{
        funcClick =function (  )
            _UpdateBetNum(self,-1)
        end,
        funcLongClick = function (  )
            _UpdateBetNum(self,-1,nil,true)
        end,
        funcUp = function (  )
            self:CancelDelayRun(self.betNumLongClick)
        end,
    })

    self:AddClick(self.betNum,function (  )
        log("TODO: open keyboard with bet num")
    end)
end

_FindNode = function(self)
    local numbg = self:FindChild("main/lotbg/wrap")
    self.numbgChilds = {}
    for i=1,6 do
        self.numbgChilds[i] = numbg:GetChild(i-1)
    end
    self.amountNode = self:FindChild("main/jackpot/amount")
    self.premiumsNode = self:FindChild("main/jackpot/vipPremiums")
    self.pricedesContainer=self:FindChild("leftPro/left/pricedes")
    self.noticePanel = self:FindChild("banner")
    self.noticeNode = self:FindChild("banner/Mask/Anim")
    self.mailNode = self:FindChild("main/mailBt/Anim")
    self.mailAnim = self:SubGet("main/mailBt/Anim","Animator")
    self.effectPanel = self:FindChild("effect")
    self.winEffect = self:FindChild("effect/putongjiang")
    self.maxWinEffect = self:FindChild("effect/toujiang")
    self.luojinbiEffect = self:FindChild("effect/luojinbi")
    self.lizituoweiEffect = self:FindChild("effect/lizituowei1")
    -- 筹码加减
    self.betSetNode = self:FindChild("main/content/buySection/betSet")
    -- self.betNumTxt = self.betSetNode:SubGet("input/Text","Text")
    self.betNum = self.betSetNode:FindChild("input/Text")
    self.betNumAdd = self.betSetNode:FindChild("add")
    self.betNumAdd5 = self.betSetNode:FindChild("add5")
    self.betNumCut = self.betSetNode:FindChild("cut")
    self.buyedBt = self:FindChild("main/buyedBt")
    --倒计时
    self.preSellTimeNode=self:FindChild("main/result/wrap/UI_NextTime/time"):GetComponent("Text")
    self.remainTimeNode=self:FindChild("main/content/UI_LotteryCountdown/time"):GetComponent("Text")
    self.rtProgressBar=self:FindChild("main/content/UI_LotteryCountdown/progressBar/djstiao"):GetComponent("Image")
    self.deadlineNode = self:FindChild("main/content/deadline/time")
    self.dlProgressBar = self:FindChild("main/content/deadline/progressBar")
    -- 排行榜
    self.rankBt = self:FindChild("main/rankBt")
    self.rankBt:SetActive(false)
    -- 购买按钮
    self.priceTxt = self:SubGet("main/content/buySection/buyBt/chipNum","Text")
    self.buyBtn = self:FindChild("main/content/buySection/buyBt")
    -- 随机按钮
    self.selBtn = self:FindChild("main/content/buySection/selBt")
    -- 玩家筹码
    self.myChipTxt =   self:SubGet("main/ChipCounter/Icon/Text","Text")

end

_InitUI = function(self )
    _SetLanguage(self)
    _StopMailAnim(self,true)
    self:OnCoinChange(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
    _UpdateBetNum(self,nil,1)
end

--设置语言，节点名字和键名一样，需包括UI前缀 搜索替换对应文本
_SetLanguage = function(self)
    local all=self.transform:GetComponentsInChildren(typeof(UnityEngine.Transform),true)
    for i=1,all.Length do
        local name = all[i-1].name
        if string.find(name,"UI") and self.language[name] then
            all[i-1]:GetComponent("Text").text=self.language[name]
        end
    end


    for k, v in ipairs(priceList) do
        local child=self.pricedesContainer:GetChild(k-1)
        child:GetChild(0):GetComponent("Text").text = "  "..self.language[v.name].." "
        child:GetChild(2):GetComponent("Text").text =v.coin
    end

    self:FindChild("main/content/deadline").text = self.language.Purchase_Success
    --debug
    self:FindChild("main/debugPanel/btn_start/Text").text = "START"
    self:FindChild("main/debugPanel/From").text = "<b>From</b>"
    self:FindChild("main/debugPanel/To").text = "<b>To</b>"
    self:FindChild("main/debugPanel/Num").text = "<b>Num</b>"
    self:FindChild("main/debugPanel/Interval").text = "<b>Interval</b>"

    for i=0,9 do
        self:FindChild("numberkeys/"..i.."/Text").text = i
    end
    self:FindChild("numberkeys/del/Text").text = self.language.BtnClear
    self:FindChild("numberkeys/ok/Text").text = self.language.BtnOK
end

_PlayNotice = function(self,notices)
    self.curNoticeIndex = 1
    local frist = true
    local play = function (  )
       self:CancelDelayRun(self.delayNotice)
       self.delayNotice  = self:DelayRun(2.1,function (  )
        self.noticeNode:GetComponent("Animator"):Play("lotterypmd",-1,0)
    end) 
    end
    local setText = function (  )
        self.noticeNode:GetChild(0):GetComponent("Text").text = notices[self.curNoticeIndex]
        self.curNoticeIndex = math.fmod(self.curNoticeIndex,#notices) +1
        self.noticeNode:GetChild(1):GetComponent("Text").text = notices[self.curNoticeIndex]
    end
    local handleEvent = function (eventName  )
        if frist then
            frist = false
        else
            setText(self.curNoticeIndex)
        end
        play()
    end
    self.noticeNode:GetComponent("Elf_AnimatorEventHandle"):SetHandleEventFun(handleEvent)
    setText()
    play()
end

_OpenKeyboard = function(self)
    if not self.focusFrame.activeSelf then
        self.focusFrame:SetActive(true)
        self.keyboardAnimator:SetFloat("speed",7)
        self.keyboardAnimator:Play("numberkeys",-1,0)
    end
end

_CloseKeyboard = function(self)
    if self.focusFrame.activeSelf then
        self.focusFrame:SetActive(false)
        self.keyboardAnimator:SetFloat("speed",-7)
        self.keyboardAnimator:Play("numberkeys",-1,1)
        _UpdateNumBg(self)
    end
end

_ChangeLotteryNumber = function(self,szLotteryNumber)
    self.isNumberScrolling = false
    for i=1,self.numbersContainer.childCount do
        local inputFiled=self.numbersContainer:GetChild(i-1):GetChild(0):GetComponent("Text")
        inputFiled.text =  string.gsub(string.sub(szLotteryNumber,i,i), " ", "")
        self.numbgChilds[i]:SetActive(inputFiled.text == "")
    end
    self.viewCtr:SetInputNumber(string.gsub(szLotteryNumber, " ", ""))
    self:UpdateButtonStatus()
    if self.waitShowRewardAnim then
        self.waitShowRewardAnim = false
        self:UpdateRewardAnim()
    end
end

_StopMailAnim = function(self ,notSave )
    if self.mailAnim.enabled then
        if not notSave and self.viewCtr.rAnimData then
            Util.SaveToPlayerPrefs(ReadLotteryMail,self.viewCtr.rAnimData.szIssue)
        end
        self.mailAnim.enabled = false
        self.mailNode.localRotation = self.quaternion:SetEuler(0, 0, 0);
    end
end

_StartMailAnim = function(self  )
    local mailCount = CC.DataMgrCenter.Inst():GetDataByKey("Mail").GetUnOpenMailCount()
    if mailCount > 0 then
        self.mailAnim.enabled = true
    end
end

_StartCoinEffect = function(self ,hitReward )
    if self.viewCtr.rAnimData then
        Util.SaveToPlayerPrefs(LotteryCoinEffect,self.viewCtr.rAnimData.szIssue)
    end
    CC.Sound.PlayHallEffect("lotteryZhongJiang.ogg")
    if hitReward == 1 then --普通奖
        self.winEffect:SetActive(true)
        self:DelayRun(2,function (  )
            self.winEffect:SetActive(false)
        end)
    elseif hitReward == 2 then-- 头奖
        self.maxWinEffect:SetActive(true)
        self.luojinbiEffect:SetActive(true)
        self:DelayRun(2,function (  )
            self.maxWinEffect:SetActive(false)
            self.luojinbiEffect:SetActive(false)
        end)
    end
end

--流星特效
--pos为世界坐标
_ShowShootingStar= function ( self ,shootingStar,pos_end,pos_begin,index, callback )
    self:CancelDelayRun(self.SStarDelay[index])
    local starImg = shootingStar:GetChild(0)
    shootingStar:SetActive(true)
    starImg:SetActive(true)
    shootingStar.transform.position = pos_end
    local locPos_end = shootingStar.transform.localPosition
    shootingStar.transform.position = pos_begin
    local pos_by = locPos_end -  shootingStar.transform.localPosition
    --曲线实现，由两个或以上的直线移动合并

    self:RunAction(shootingStar,{"spawn",
        {"localMoveBy",pos_by.x,0,1,ease=CC.Action.EInCubic},-- X轴
        {"localMoveBy",0, pos_by.y,1,function() --Y轴
            starImg:SetActive(false)
            starImg.localScale = Vector3.one -- 恢复大小

            self.SStarDelay[index] = self:DelayRun(0.8,function (  ) -- 到达终点时给拖尾留足够的时间自然消失
                shootingStar:SetActive(false)
            end)
            if callback then
                callback()
            end
        end,ease=CC.Action.EInExpo}
    })
    --效果校正
    -- 距离调整
    local dis_y = math.random(50,105)
    self:RunAction(shootingStar, {"localMoveBy",0, dis_y,0.5,loop={2,CC.Action.LTYoyo},ease=CC.Action.EOutQuad})
    -- 缩放
    self:RunAction(starImg, {"scaleTo", 0.5, 0.5, 0.8,ease=CC.Action.EInExpo})
end

_CreateShootingStar = function (self, pBetNum )
    log("_CreateShootingStar")
    local tBetNum = pBetNum < 10 and pBetNum or 10
    --[[Vector3 世界坐标
    左上 x10010 y10010 z100
    右上 x10025 y10010 z100
    右下 x10025 y10000 z100
    左下 x10010 y10000 z100
    ]]
    for i=1,tBetNum do
        local tpreName = "lizituowei" .. i
        local tprefab = self.effectPanel:FindChild(tpreName)
        if not tprefab then
            tprefab = self:AddPrefab(self.lizituoweiEffect,self.effectPanel,tpreName)
        end
        local callback
        local pos_beginX = math.random(10010,10025)
        local pos_beginY = math.random(10000,10010)
        if i == 1 then
            pos_beginX =10018
            pos_beginY =10005
            -- 刷新购买按钮
            self:UpdateButtonStatus(false)
            self.banBuy = true
            callback = function (  )
                self.banBuy = false
                self:UpdateButtonStatus() 
            end
        end
        local pos_beginZ = 100
        local pos_begin = Vector3(pos_beginX,pos_beginY,pos_beginZ)
        local pos_end = self.buyedBt.position
        _ShowShootingStar(self,tprefab,pos_end,pos_begin,i,callback)
    end
end

_InitDebugPanel = function(self )
    if CC.Platform.isWin32 then
        self:FindChild("main/debugPanel"):SetActive(true)
        self:SubGet("main/debugPanel/InputFrom","InputField").text = 0
        self:SubGet("main/debugPanel/InputTo","InputField").text = 0
        self:SubGet("main/debugPanel/InputNum","InputField").text = 200
        self:SubGet("main/debugPanel/InputInterval","InputField").text = 1.5
        self:AddClick("main/debugPanel/btn_start", function() 
            local from = tonumber(self:SubGet("main/debugPanel/InputFrom","InputField").text)
            local to = tonumber(self:SubGet("main/debugPanel/InputTo","InputField").text)
            local num = tonumber(self:SubGet("main/debugPanel/InputNum","InputField").text)
            local interval = tonumber(self:SubGet("main/debugPanel/InputInterval","InputField").text)
            self.viewCtr:BuyLotteryMore(from,to,num,interval)
            -- _CreateShootingStar(self,interval)
        end)    
    else
        self:FindChild("main/debugPanel"):SetActive(false)
    end
end

_UpdateBetNum = function(self,offset,betNum ,isLoop )
    local tBetNum =  self.viewCtr:GetBetNumber()
    if offset then
        tBetNum = tBetNum + offset
    elseif betNum then
        tBetNum = betNum
    end
    if tBetNum <= 1 then
        tBetNum = 1
        isLoop = nil
    end
    if tBetNum >= 99 then
        tBetNum = 99
        isLoop = nil
    end
    self.viewCtr:SetBetNumber(tBetNum)
    self.betNum:GetComponent("Text").text = tBetNum
    _UpdateBetPrice(self)
    if isLoop then
        CC.Sound.PlayHallEffect("click")
        self.betNumLongClick = self:DelayRun(0.1,function (  )
           _UpdateBetNum(self,offset,betNum ,isLoop)
        end)
    end
end

_UpdateBetPrice = function (self  )
    local tPrice = self.viewCtr:GetPrice()
    self.priceTxt.text=uu.numberToStrWithComma(tPrice)
    self:UpdateButtonStatus()
    
end

_InitSound = function (self)
    CC.Sound.StopBackMusic()
    CC.Sound.PlayHallBackMusic("lotteryBGM")
    --每次播放结束,两秒后再播放
    -- self:DelayRun(30,function()
    --     CC.Sound.StopBackMusic()
    --     self:DelayRun(2,function(  )
    --         _InitSound(self)
    --     end)
    -- end)
end

_ResetSound = function ( self )
    CC.Sound.StopBackMusic()
    CC.Sound.PlayHallBackMusic("BGM_Hall")

end

_ShowNoticeBanner = function (self)
    -- self.rankBt:SetActive(true)
    self.noticePanel:SetActive(true)
end

_HideNoticeBanner = function (self)
    -- self.rankBt:SetActive(false)
    self.noticePanel:SetActive(false)
end

--@region 重写大厅长按方法
function LotteryView:AddLongClick(node, param)
	local funcClick = param.funcClick;
	local funcLongClick = param.funcLongClick;
	local funcDown = param.funcDown;
	local funcUp = param.funcUp;
	local time = param.time or 1;
	local clickSound = param.clickSound or "click";
	local longClickSound = param.longClickSound;

	self.__longClickCount = self.__longClickCount and self.__longClickCount + 1 or 0;
	local curCount = self.__longClickCount

	node.onDown = function(obj, eventData)
		CC.Sound.PlayHallEffect(clickSound)
		self.__longClickFlag = false;
		self:StartTimer("CheckLongClick"..curCount,time,function()
			if eventData.pointerCurrentRaycast.gameObject == node.gameObject then 
				self.__longClickFlag = true;
                funcLongClick(obj, eventData);
                CC.Sound.StopExtendEffect(longClickSound);
			end
		end)
		if funcDown then 
			funcDown(obj,eventData);
        end
        if longClickSound then
		    CC.Sound.PlayLoopEffect(longClickSound);
        end
    end

	node.onUp = function(obj,eventData)
		if funcUp then 
			funcUp(obj,eventData);
		end
		self:StopTimer("CheckLongClick"..curCount);
		CC.Sound.StopExtendEffect(longClickSound);
	end

	node.onClick = function(obj, eventData)
		
		if not self.__longClickFlag then	
			funcClick(obj, eventData);
		end
	end
end
--@endregion

return LotteryView