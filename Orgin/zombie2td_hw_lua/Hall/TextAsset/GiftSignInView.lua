local CC = require("CC")

local GiftSignInView = CC.uu.ClassView("GiftSignInView")

local hightColor = "<color=#FFD52DFF>%d</color>"
local normalColor = "<color=#DE9FFFFF>%d</color>"
function GiftSignInView:ctor(param)
    self:InitVar(param)
end

function GiftSignInView:InitVar(param)
	self.param = param
	--钻石消耗刻度
	self.diamondCfg = {500,1500,3000,5000,7500,10000}
	self.sliderCfg = {0.09,0.26,0.44,0.63,0.8,1}
	--所有进度条的文本
	self.progressAll = {}
	--所有锁定的宝箱
	self.boxLockAll = {}
	--所有可开启的宝箱
	self.boxCanOpenAll = {}
	--所有已打开的宝箱
	self.boxAlreadyOpenAll = {}
	--所有宝箱当前的信息
    self.curAllBoxInfo = {}
    --所有气泡
	self.gashaponQP = {}
	--初始化宝箱
	self.initBox = true
	--当前选择的宝盒ID
	self.selectBoxID = nil
	--当前规则界面的物体
	self.ruleItemAll = {}

	self.recordItemList = {}

	self.isInitBubbleAni = true

	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
end

function GiftSignInView:OnCreate()

	self.language = self:GetLanguage()
	self:InitContent();

	self:InitTextByLanguage()
	self.viewCtr = self:CreateViewCtr(self.param);

	self.ScrollerController = self:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self.viewCtr:SetRecordInfo(tran,dataIndex,cellIndex)
	end)

	self.ScrollerController:AddRycycleAction(function (tran)
		self:RecycleItem(tran)
	end)
    self.viewCtr:OnCreate();
    self:AddClickEvent()
	self.musicName = CC.Sound.GetMusicName()
	self:DelayRun(0.1, function()
		CC.Sound.PlayHallBackMusic("gs_bgm");
	end)
end

function GiftSignInView:InitContent()
	self.leftPanel = self:FindChild("LeftPanel")
    self.liveSlider = self:FindChild("LeftPanel/Slider"):GetComponent("Slider")
    for i=1,6 do
    	table.insert(self.boxLockAll,self.leftPanel:FindChild("Liveness_"..i.."/default"))
    	table.insert(self.boxCanOpenAll,self.leftPanel:FindChild("Liveness_"..i.."/effect"))
    	table.insert(self.boxAlreadyOpenAll,self.leftPanel:FindChild("Liveness_"..i.."/open"))
    end
    self.GashaponPanel = self:FindChild("GashaponPanel")
    --气泡
	self.Bubble = self.GashaponPanel:FindChild("QP"):GetComponent("Animator")
	for i=2,5 do
		table.insert(self.gashaponQP,self.GashaponPanel:FindChild("QP/0"..i))
	end

	self.GashaponBtn = self.GashaponPanel:FindChild("GashaponBtn")
	self.NotGashaponBtn = self.GashaponPanel:FindChild("NotGashaponBtn")
	self.GiftTipText = self.GashaponPanel:FindChild("GiftTip/Text")
    --扭蛋奖池Text
	self.GashaponJackpot = self.GashaponPanel:FindChild("CapsuleAnim/Text")
    --大奖排行榜
	self.bigAwardPanel = self:FindChild("BigAwardPanel")

	--扭蛋机
	self.CapsuleSpin = self.GashaponPanel:FindChild("CapsuleAnim"):GetComponent("SkeletonGraphic")

	--开奖
	self.RewardSpin = self.GashaponPanel:FindChild("RewardAnim"):GetComponent("SkeletonGraphic")
	--开奖背景
	self.RewardPanel = self.GashaponPanel:FindChild("RewardPanel")
	--普通扭蛋特效
	self.NormalEffect = self.GashaponPanel:FindChild("RewardAnim/EffectNode/Normal")

	--JP扭蛋特效
	self.JackpotEffect = self.GashaponPanel:FindChild("RewardAnim/EffectNode/Jackpot")

	--跑马灯文字
	self.MarqueeText = self:FindChild("Marquee/hedi/Text")

	--规则界面
	self.RulePanel = self:FindChild("RulePanel")

    --规则parent
	self.RuleParent = self.RulePanel:FindChild("ShowPanel/Scroll View/Viewport/Content")

	--规则奖励Item
	self.RuleItem = self.RulePanel:FindChild("ShowPanel/Scroll View/Viewport/Content/Item")

    --获取裁剪区域左下角和右上角的世界坐标
	local viewport = self:FindChild("RulePanel/ShowPanel/Scroll View/Viewport");
	local wordPos = viewport:GetComponent("RectTransform"):GetWorldCorners()
	local minX = wordPos[0].x;
	local minY = wordPos[0].y;
	local maxX = wordPos[2].x;
	local maxY = wordPos[2].y;

	local coms = self.RuleItem:FindChild("Effect/Glow"):GetComponent(typeof(UnityEngine.Renderer))
	coms.material:SetFloat("_MinX",minX);
	coms.material:SetFloat("_MinY",minY);
	coms.material:SetFloat("_MaxX",maxX);
	coms.material:SetFloat("_MaxY",maxY);
end
function GiftSignInView:RefreshSliderProgress(num)
	--控制进度条的值
	local slideNum = num / self.diamondCfg[6]
	for k,v in pairs(self.curAllBoxInfo) do
		if v.GiftStatus == CC.client_gift_pb.gift_opened or v.GiftStatus ==CC.client_gift_pb.gift_pending then
			if slideNum < self.sliderCfg[k] then
				slideNum = self.sliderCfg[k]
			end
		end
	end
	self:FindChild("LeftPanel/totalNum").text = num
	self.liveSlider.value = slideNum
end
--刷新箱子状态
function GiftSignInView:RefreshBoxState(data)
	self.curAllBoxInfo = data
	if self.initBox == true then
		self.transform.sizeDelta = Vector2(0, 0)
		for i=1,6 do
			self:AddClick(self.boxLockAll[i],function()
				self:ShowSelectBoxReward(i)
			end)
			self:AddClick(self.boxCanOpenAll[i]:FindChild("Baoxiang"),function()
				self:ShowSelectBoxReward(i)
			end)
			self:AddClick(self.boxAlreadyOpenAll[i],function()
				self:ShowSelectBoxReward(i)
			end)
		end
		self.initBox = false
    end
    local defaultShowBoxId = 1
    for i=1,6 do
    	if self.curAllBoxInfo[i].GiftStatus == CC.client_gift_pb.gift_pending then
    	    defaultShowBoxId = i
    	end
	end
	self.selectBoxID = defaultShowBoxId
    --默认显示最贵的可开启礼盒
    self:ShowSelectBoxReward(self.selectBoxID)
    for i=1,6 do
    	if data[i].GiftStatus ==CC.client_gift_pb.gift_not_open then
            self.boxLockAll[i]:SetActive(true)
            self.boxCanOpenAll[i]:SetActive(false)
            self.boxAlreadyOpenAll[i]:SetActive(false)
            self.progressAll[i].text =string.format(normalColor,self.diamondCfg[i])
    	elseif data[i].GiftStatus ==CC.client_gift_pb.gift_pending then
    		self.boxLockAll[i]:SetActive(false)
            self.boxCanOpenAll[i]:SetActive(true)
            self.boxAlreadyOpenAll[i]:SetActive(false)
            self.progressAll[i].text =string.format(hightColor,self.diamondCfg[i])
    	elseif data[i].GiftStatus ==CC.client_gift_pb.gift_opened then
            self.boxLockAll[i]:SetActive(false)
            self.boxCanOpenAll[i]:SetActive(false)
            self.boxAlreadyOpenAll[i]:SetActive(true)
            self.progressAll[i].text =string.format(hightColor,self.diamondCfg[i])
    	end
    end
end
function GiftSignInView:AddClickEvent()
	self:AddClick("GashaponPanel/ShareBtn","OnClickShare")
	self:AddClick("GashaponPanel/BtnExplain",function ()
		self.RulePanel:SetActive(true)
		self:RefreshRulePanel()
	end)
	self:AddClick(self.RulePanel:FindChild("ShowPanel/BtnClose"),function ()
		self.RulePanel:SetActive(false)
	end)
	self:AddClick("BtnClose","ActionOut")
	self:AddClick("BigAwardPanel/BigAwardBtn","OnBigAwardClick")
	self:AddClick("GashaponPanel/GashaponBtn","Lottery")
end

function GiftSignInView:Lottery()
	self:SetCanClick(false)
	self.viewCtr:Req_Gift_Lottery(self.selectBoxID)
end

function GiftSignInView:PlayLotteryAnim(param)
	CC.Sound.StopBackMusic()
	CC.Sound.PlayHallEffect("gs_niudan")
	local bstate = param.PrizeType == CC.client_gift_pb.Gift_Jack_Pot
	self.Bubble:StartPlayback()
    self.Bubble.speed = -1
	self.Bubble:Play("Effect_NiuDan_QiPao_Open",0,1)
	if self.CapsuleSpin.AnimationState then
        self.CapsuleSpin.AnimationState:ClearTracks()
        self.CapsuleSpin.AnimationState:SetAnimation(0, "stand2", false)
	end
	local LotteryFun = nil
	LotteryFun = function ()
		CC.Sound.PlayHallEffect("gs_reward")
        self:PlayRewardAnim(bstate,param)
        self.CapsuleSpin.AnimationState:ClearTracks()
        self.CapsuleSpin.AnimationState:SetAnimation(0, "stand1", false)
        self.CapsuleSpin.AnimationState.Complete =  self.CapsuleSpin.AnimationState.Complete - LotteryFun
    end
    self.CapsuleSpin.AnimationState.Complete =  self.CapsuleSpin.AnimationState.Complete + LotteryFun
end

function GiftSignInView:PlayRewardAnim(bstate,param)
	local random = nil
	if bstate then
		random = math.random(1,3)
	else
		random = math.random(4,6)
	end
    local ani = nil
    if random == 1 then
        ani = "stand"
    else
        ani = "stand"..random
	end
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
        self:StopRewardAnim(bstate,param)
        self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete - RewardFun
	end
    self.RewardSpin.AnimationState.Complete = self.RewardSpin.AnimationState.Complete + RewardFun
end


function GiftSignInView:StopRewardAnim(bstate,data)
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
		CC.Sound.PlayHallBackMusic("gs_bgm");
		local configId = data.ConfigId
		local count = data.Count
		local rewardData = {}
		rewardData[1] = data
		if bstate and configId == CC.shared_enums_pb.EPC_ChouMa then
			--self.viewCtr:ReqLoadDailyGiftSignJP()
			local isJackpot = true;
			local param = {};
			param.rewardInfo = {{ConfigId = configId, Count = count}}
			param.rewardType = isJackpot and 2 or 1;
			CC.ViewManager.Open("TurntableRewardView", param);
		elseif bstate then
			CC.ViewManager.OpenRewardsView({items = rewardData,source = CC.shared_transfer_source_pb.TS_DailyGiftSign_Reward})
		else
			CC.ViewManager.OpenRewardsView({items = rewardData});
		end
		--刷新礼盒数据
		self.viewCtr:Req_Gift_Data()
		--刷新中奖列表
		self.viewCtr:Req_Gift_Prizes()
    end)
end

function GiftSignInView:OnBigAwardClick()
	if self.bigAwardPanel:FindChild("BigAwardBtn/Dir").localScale.x >= 1 then
		self.bigAwardPanel:FindChild("bg"):SetActive(true)
		self.bigAwardPanel:FindChild("BigAwardBtn").localPosition = Vector3(147,10,0)
		self.bigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(-1,1,1)
		self.bigAwardPanel:FindChild("RankPanel").localPosition = Vector3(452,0,0)
	else
		self.bigAwardPanel:FindChild("bg"):SetActive(false)
		self.bigAwardPanel:FindChild("BigAwardBtn").localPosition = Vector3(608,10,0)
		self.bigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(1,1,1)
		self.bigAwardPanel:FindChild("RankPanel").localPosition = Vector3(916,0,0)
	end
end
--刷新气泡内容
function GiftSignInView:ShowSelectBoxReward(id)
    if self.isInitBubbleAni == false then
    	self:SetCanClick(false);
	    self.Bubble:StartPlayback()
        self.Bubble.speed = -1
	    self.Bubble:Play("Effect_NiuDan_QiPao_Open",0,1)

        CC.uu.DelayRun(0.5,function ()
            self.Bubble:StartPlayback()
            self.Bubble.speed = 1
            self.Bubble:Play("Effect_NiuDan_QiPao_DaiJi",0,1)
            CC.uu.DelayRun(0.4,function ()
            	self:SetCanClick(true)
            end)
        end)
    end
	self.selectBoxID = id
    self.NotGashaponBtn:SetActive(self.curAllBoxInfo[id].GiftStatus ~= CC.client_gift_pb.gift_pending)
    self.GiftTipText.text = string.format(self.language.BoxDes,self.diamondCfg[id])
    local gashaponIndex = 0
    for k,v in ipairs(self.curAllBoxInfo[id].PrizeLists) do
    	if v.PrizeType == CC.client_gift_pb.Gift_Jack_Pot then
    		self.GashaponJackpot.text =  v.PrizeValue
    	end
    	if v.PrizeType ~= CC.client_gift_pb.Gift_Jack_Pot then
    		gashaponIndex = gashaponIndex + 1
		    local image = self.gashaponQP[gashaponIndex]:FindChild("Image")
		    local icon = self.PropDataMgr.GetIcon(v.PropID)
		    local des = v.PrizeValue
		    if v.PrizeType == CC.client_gift_pb.Point_Card then
		    	 des = v.PrizeValue..self.language.pointCardDes
		    end
		    if gashaponIndex == 4 then
                if v.PrizeType == CC.client_gift_pb.Point_Card and v.PrizeValue == 1000 then
		    	    self.gashaponQP[4]:FindChild("extraCount").text = "x2"
		        else
		        	self.gashaponQP[4]:FindChild("extraCount").text = ""
		        end
		    end
		    self:SetImage(image,icon)
		    image:GetComponent("Image"):SetNativeSize()
		    self.gashaponQP[gashaponIndex]:FindChild("Text").text = des
	    end
	end
	self.isInitBubbleAni = false
end
function GiftSignInView:RefreshRulePanel()
	--初始化规则界面奖励
	local jackpotList =self.curAllBoxInfo[self.selectBoxID].PrizeLists
	for i,v in ipairs(jackpotList) do
		if v.PrizeType ~= CC.client_gift_pb.Gift_Jack_Pot then
    		local icon = self.PropDataMgr.GetIcon(v.PropID)
    		local des = ""
    		if v.PrizeType == CC.client_gift_pb.Point_Card then
    			if v.PrizeValue == 1000 then
    				des = self.PropDataMgr.GetLanguageDesc(v.PropID).." x2"
    			else
                    des = self.PropDataMgr.GetLanguageDesc(v.PropID)
    			end
		    else
		        des = self.PropDataMgr.GetLanguageDesc(v.PropID,v.PrizeValue)
		    end
		    local item = nil
		    if self.ruleItemAll[i] then
		    	item = self.ruleItemAll[i]
		    else
		    	item = CC.uu.newObject(self.RuleItem,self.RuleParent)
		    	table.insert(self.ruleItemAll,item)
		    end
		    self:SetImage(item:FindChild("Prop"),icon)
		    item:FindChild("Text").text = des
	    end
	end
end

-- 点击分享
function GiftSignInView:OnClickShare()
	local data = {}
	data.imgName = "share_1_4_20201130"
	data.content = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView").shareContent1
	CC.ViewManager.Open("ImageShareView",data)
end

function GiftSignInView:InitTextByLanguage()
    for i=1,6 do
    	table.insert(self.progressAll,self.leftPanel:FindChild("Liveness_"..i.."/num"))
    	self.progressAll[i].text = self.diamondCfg[i]
    end
	self.GashaponPanel:FindChild("Item/Text").text = self.language.Prize1Des
	self.GashaponPanel:FindChild("QP/01/Text").text = self.language.QP01Des
    self.GashaponPanel:FindChild("ShareDecorate").text = self.language.shareDes
    self:FindChild("RulePanel/ShowPanel/Decorate/Tips/Text").text = self.language.GirlTips
    self:FindChild("RulePanel/ShowPanel/Title").text = self.language.RuleTitle
    self:FindChild("RulePanel/ShowPanel/Text").text = self.language.RuleDes
    self:FindChild("BigAwardPanel/RankPanel/Title/Name").text = self.language.Nick
	self:FindChild("BigAwardPanel/RankPanel/Title/Info").text = self.language.RewardDes
	self.GashaponBtn:FindChild("Text").text = self.language.Buy
	self.NotGashaponBtn:FindChild("Text").text = self.language.Buy
	self:FindChild("RulePanel/ShowPanel/Scroll View/Viewport/Content/Item/Text").text = self.language.Prize1Des
end

function GiftSignInView:InitRecordPanel(count)
	self.ScrollerController:InitScroller(count)
	if count > 0 then
		self:FindChild("Marquee"):SetActive(true)
		self:StartMarquee()
	end
end

function GiftSignInView:SetRecordItem(tran,param,index)
	tran.transform.name = index
	local headNode = tran:FindChild("ItemHead")
	local id = param.id
	local portrait = param.portrait
	local vip = param.vip
	self.recordItemList[index] = self:SetHeadIcon(headNode,id,portrait,vip)
	tran:FindChild("Nick").text = param.nick
	tran:FindChild("Des").text = param.des
	tran:FindChild("Time").text = param.time
end

function GiftSignInView:SetHeadIcon(node,id,portrait,level)
	local param = {}
	param.parent = node
	param.playerId = id
	param.portrait = portrait
	param.vipLevel = level
	return CC.HeadManager.CreateHeadIcon(param)
end

function GiftSignInView:RecycleItem(tran)
	local index = tonumber(tran.transform.name)
	if self.recordItemList[index] then
		self.recordItemList[index]:Destroy(true)
	end
end
--------------------------------------------奖励播报------------------------------------------------------
function GiftSignInView:StartMarquee()
	self:StartTimer("Marquee",1,function ()
		if self.isMarqueeMoving then
			return
		else
			self.isMarqueeMoving = true
			self.MarqueeText.text = self:DealWithString(string.format(self.language.MarqueeText,self.viewCtr:GetMarqueeText()))
			self.MarqueeText.localPosition = Vector3(2000,2000,0)
			if self.isMarqueeMoving then
			    self:DelayRun(0.1,function()
				    local textW = self.MarqueeText:GetComponent('RectTransform').rect.width
				    local half = textW/2
				    self.MarqueeText.localPosition = Vector3(half + 450, 15, 0)
				    self.action = self:RunAction(self.MarqueeText, {"localMoveTo", -half - 450, 15, 0.65 * math.max(16,textW/40), function()
					    self.action = nil
					    self.isMarqueeMoving = false
				end})
			    end)
		    end
		end
	end,-1)
end
function GiftSignInView:StopMarquee()
	self.isMarqueeMoving = false
	self:StopTimer("Marquee")
	self:FindChild("Marquee"):SetActive(false)
end

function GiftSignInView:DealWithString(text)
	local str = string.gsub(CC.uu.ReplaceFace(text,23,true),'%s+',' ')
	return str
end

function GiftSignInView:ActionOut()

	self:SetCanClick(false);

	self:Destroy()
end
function GiftSignInView:OnDestroy()

	if self.param.closeFunc then
		self.param.closeFunc();
	end

	for _,v in pairs(self.recordItemList) do
		if v then
			v:Destroy(true)
		end
	end
	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return GiftSignInView