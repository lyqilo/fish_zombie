local CC = require("CC")
local CelebrationView = CC.uu.ClassView("CelebrationView")

function CelebrationView:ctor(param)
    self.param = param
    self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self:InitUI()
    self:RegisterEvent()
    self.carOwnerHeadIcon = nil
    self.createTime = os.time()+math.random()
end

function CelebrationView:InitUI()
    self.musicName = nil
    self.language = self:GetLanguage()
    --周年庆实物奖励
    self.RewardList = {}
    self.RewardIdList = {
        [1] = {20100,20101,20102,20066,20104},
        [2] = {20020,20105,20106,20070,20029},
        [3] = {20081,20026,20080,20075,20055},
        [4] = {20103,10004,10014,20099,10003},
        [5] = {10013,20098,10002,20097,10006},
        [6] = {20096,10001,20095,20094,20108},
    }
    --奖励变换次数
    self.RewardCount = 1
end

function CelebrationView:OnCreate()
    self:AddClick(self:FindChild("BackBtn"), function()
        self:CloseView()
    end)
    self:AddClick(self:FindChild("Plane/AnNiu_R/AnNiu01"), function()
        --炮台返场
        self:SetRedDotLocal("FreeChipsCollectionView")
        if self:CheckActivitySwitch("CapsuleView") then
            CC.ViewManager.Open("FreeChipsCollectionView",{currentView = "CapsuleView"})
            self:FindChild("Plane/AnNiu_R/AnNiu01/red"):SetActive(false)
        end
    end)
    self:AddClick(self:FindChild("Plane/AnNiu_R/AnNiu02"), function()
        self:SetRedDotLocal("AnniversaryTurntableView")
        if self:CheckActivitySwitch("AnniversaryTurntableView") then
            CC.ViewManager.Open("AnniversaryTurntableView")
            self:FindChild("Plane/AnNiu_R/AnNiu02/red"):SetActive(false)
        end
    end)
    self:AddClick(self:FindChild("Plane/AnNiu_R/AnNiu03"), function()
        --累充
        self:SetRedDotLocal("NewPayGiftView")
        if self:CheckActivitySwitch("NewPayGiftView") then
            local param = {}
            param.currentView = "NewPayGiftView"
            param.maskAlpha = 250
            CC.ViewManager.Open("SelectGiftCollectionView", param)
            self:FindChild("Plane/AnNiu_R/AnNiu03/red"):SetActive(false)
        end
    end)
    self:AddClick(self:FindChild("Plane/AnNiu_L/AnNiu01"), function()
        self:SetRedDotLocal("SelectGiftCollectionView")
        if self:CheckActivitySwitch("BatteryLotteryView") then
            CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "BatteryLotteryView"})
            self:FindChild("Plane/AnNiu_L/AnNiu01/red"):SetActive(false)
        end
    end)
    self:AddClick(self:FindChild("Plane/AnNiu_L/AnNiu02/BtnMonth"), function()
        --赢分榜
        self:SetRedDotLocal("RankCollectionView")
        if self:CheckActivitySwitch("MonthRankView") then
            CC.ViewManager.Open("RankCollectionView", {currentView = "MonthRankView"})
            self:FindChild("Plane/AnNiu_L/AnNiu02/red"):SetActive(false)
        end
    end)
    self:AddClick(self:FindChild("Plane/AnNiu_L/AnNiu02/BtnWater"), function()
        --流水捕获榜
        self:SetRedDotLocal("RankCollectionView")
        if self:CheckActivitySwitch("WaterCaptureRankView") then
            CC.ViewManager.Open("RankCollectionView", {currentView = "WaterCaptureRankView"})
            self:FindChild("Plane/AnNiu_L/AnNiu02/red"):SetActive(false)
        end
    end)
    self:AddClick(self:FindChild("Plane/AnNiu_L/AnNiu03"), function()
        --假日特惠
        self:SetRedDotLocal("DailyGiftCollectionView")
        if self:CheckActivitySwitch("HolidayDiscountsView") then
            CC.ViewManager.Open("DailyGiftCollectionView", {currentView = "HolidayDiscountsView"})
            self:FindChild("Plane/AnNiu_L/AnNiu03/red"):SetActive(false)
        end
    end)
    self:AddClick(self:FindChild("Plane/Che/CarOwners/Image"), function()
        CC.ViewManager.Open("AnniversaryRankView")
    end)
    self:AddClick(self:FindChild("Plane/Che"), function()
        if self.carOwnerHeadIcon then
            CC.ViewManager.Open("AnniversaryRankView")
        end
    end)
    self:AddClick(self:FindChild("Plane/DragonNum"), function()
        CC.ViewManager.Open("CelebrationTipView")
    end)
    self:AddClick(self:FindChild("Plane/StoneNum"), function()
        CC.ViewManager.Open("CelebrationTipView", {Stone = true})
    end)
    
    self.anim = self:FindChild("Plane"):GetComponent("Animator")
    for i = 1, 5 do
        self.RewardList[i] = self:FindChild(string.format("Plane/Reward/%d",i))
    end
    self:DelayRun(0.1, function()
        self.musicName = CC.Sound.GetMusicName();
        CC.Sound.PlayHallBackMusic("celebrationBg")
    end)
    -- CC.Sound.StopEffect()
    -- CC.Sound.PlayHallEffect("car_sound")
    self:LanguageSwitch()
    self:InitView()
    self:OnReqRankInfo()
end

function CelebrationView:LanguageSwitch()
    self:FindChild("Plane/AnNiu_L/AnNiu01/Text").text = self.language.left_1
    self:FindChild("Plane/AnNiu_L/AnNiu02/Text1").text = self.language.left_2_1
    self:FindChild("Plane/AnNiu_L/AnNiu02/Text2").text = self.language.left_2_2
    self:FindChild("Plane/AnNiu_L/AnNiu03/Text").text = self.language.left_3
    self:FindChild("Plane/AnNiu_R/AnNiu01/Text").text = self.language.right_1
    self:FindChild("Plane/AnNiu_R/AnNiu02/Text").text = self.language.right_2
    self:FindChild("Plane/AnNiu_R/AnNiu03/Text").text = self.language.right_3
end

--红点显示
function CelebrationView:InitView()
    self:UpdateProp()
    --排行榜
    self:FindChild("Plane/AnNiu_L/AnNiu02/red"):SetActive(self:GetRedDotLocal("RankCollectionView"))
    --假日特惠
    self:FindChild("Plane/AnNiu_L/AnNiu03/red"):SetActive(self:GetRedDotLocal("DailyGiftCollectionView"))
    --周年庆转盘
    self:FindChild("Plane/AnNiu_R/AnNiu02/red"):SetActive(self:GetRedDotLocal("AnniversaryTurntableView") or CC.Player.Inst():GetSelfInfoByKey("EPC_Props_81") > 0)
    --青龙炮台
    self:FindChild("Plane/AnNiu_L/AnNiu01/red"):SetActive(self:GetRedDotLocal("SelectGiftCollectionView"))
    --炮台返场
    self:FindChild("Plane/AnNiu_R/AnNiu01/red"):SetActive(self:GetRedDotLocal("FreeChipsCollectionView"))
    --累充
    self:FindChild("Plane/AnNiu_R/AnNiu03/red"):SetActive(self:GetRedDotLocal("NewPayGiftView"))
    self:UpdateReward()
end

--检查活动是否打开
function CelebrationView:CheckActivitySwitch(viewName)
    if not self.activityDataMgr.GetActivityInfoByKey(viewName).switchOn then
        CC.ViewManager.ShowTip(self.language.tip)
        return false
    end
    return true
end

function CelebrationView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnRankInfoRsp,CC.Notifications.NW_ReqGetLuckyRouletteRank)
    CC.HallNotificationCenter.inst():register(self,self.OnchangeSelfInfo,CC.Notifications.changeSelfInfo)
end

function CelebrationView:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function CelebrationView:OnReqRankInfo()
	local data = {}
	data.From = 0
	data.To = 0
	CC.Request("ReqGetLuckyRouletteRank",data)
end

function CelebrationView:OnRankInfoRsp(err,result)
    log("err = ".. err.."  "..CC.uu.Dump(result, "ReqGetLuckyRouletteRank",10))
	if err == 0 then
        if self.carOwnerHeadIcon then return end
        local rankList = result.RankList
        if rankList and #rankList < 1 then return end
        local IconData = {}
        IconData.parent = self:FindChild("Plane/Che/CarOwners/head")
        IconData.playerId = rankList[1].PlayerId
        IconData.portrait = rankList[1].Portrait
        IconData.headFrame = 3057
        IconData.showFrameEffect = true
        self.carOwnerHeadIcon = CC.HeadManager.CreateHeadIcon(IconData);
        self:FindChild("Plane/Che/CarOwners/Name").text = rankList[1].Nickname
        self:FindChild("Plane/Che/CarOwners"):SetActive(true)
	end
end

function CelebrationView:OnchangeSelfInfo(Items, Source)
	for _,v in ipairs(Items) do
		if v.ConfigId == CC.shared_enums_pb.EPC_Props_81 or v.ConfigId == CC.shared_enums_pb.EPC_Props_80 then
			self:UpdateProp()
		end
	end
end

function CelebrationView:UpdateProp()
    self:FindChild("Plane/DragonNum/Num").text = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_80")
    self:FindChild("Plane/StoneNum/Num").text = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_81")
end

--周年庆本地记录
function CelebrationView:SetRedDotLocal(key)
    CC.LocalGameData.SetLocalDataToKey("CelebrationView", key)
end

--当天有没有记录过
function CelebrationView:GetRedDotLocal(key)
    return CC.LocalGameData.GetLocalDataToKey("CelebrationView", key)
end

function CelebrationView:UpdateReward()
--每3秒变换一次奖励
	local initTime = 3
    local countDown = initTime
	self:StartTimer("countDown"..self.createTime, 1, function ()
		countDown = countDown - 1
		if countDown <= 0 then
			countDown = initTime
            self:ChangeReward()
		end
	end,-1)
end

--变换实物奖励
function CelebrationView:ChangeReward()
    self.RewardCount = self.RewardCount + 1 <= 6 and self.RewardCount + 1 or 1
    for i = 1, #self.RewardList do
        local id = self.RewardIdList[self.RewardCount][i]
        if not self.propCfg[id] or self.propCfg[id].Icon == '' then
            CC.uu.Log("prop表没有该道具配置或者该道具没配置Icon路径..");
            return;
        end
        local path = self.propCfg[id].Icon;
        self:SetImage(self.RewardList[i]:FindChild("Icon"), path)
        self.RewardList[i]:FindChild("Icon"):GetComponent("Image"):SetNativeSize();
        self.RewardList[i]:FindChild("effect"):SetActive(false)
        self.RewardList[i]:FindChild("effect"):SetActive(true)
    end
end

function CelebrationView:ActionIn()
end
function CelebrationView:ActionOut()
end

function CelebrationView:CloseView()
    self:SetCanClick(false)
    self:FindChild("Plane/Che/CarOwners"):SetActive(false)
    self.anim:Play("Effect_ZNQ_HuoDongYingDao_close")
    self:DelayRun(0.5, function ( )
        self:Destroy()
    end)
end

function CelebrationView:OnDestroy()
    self:StopTimer("countDown"..self.createTime)
    self:UnRegisterEvent()
    self:CancelAllDelayRun()
    CC.Sound.StopEffect()
    if self.carOwnerHeadIcon then
		--销毁车主头像
		self.carOwnerHeadIcon:Destroy(true)
		self.carOwnerHeadIcon = nil
	end
    if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end
end

return CelebrationView