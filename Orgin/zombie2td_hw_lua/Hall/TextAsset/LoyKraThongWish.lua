local CC = require("CC")
local ViewUIBase = require("Common/ViewUIBase")
local baseClass = CC.class2("LoyKraThongWish",ViewUIBase)

local singleWishCost1 = 20000
local singleWishCost2 = 10
local CountDownConst = 5

-- local WishTotalConst = 20

function baseClass:ctor(wishType, openListCallback, openWinCallback)
	self.language = CC.LanguageManager.GetLanguage("L_LoyKraThong")

	self.isPlayAnim = false
	self.hasNum = 0
	self.sumNum = 0
	self.wishTimes = 0
	self.wishRound = 1
	self.wishLeftRound = 0

	self.wishType = wishType
	if wishType == 1 then
		self.singleWishCost = singleWishCost1
	else
		self.singleWishCost = singleWishCost2
	end
	self.openListCallback = openListCallback
	self.openWinCallback = openWinCallback

	self.wishCount = 1
end

function baseClass:OnCreate()
	self:InitContent()
	self:InitTextByLanguage()
	self:RegisterEvent()
end

function baseClass:InitContent()
	self.flowerImage = self:SubGet("flower/Image","Image")
	self.flowerImage:SetActive(true)
	self.flowerStandImage = self:SubGet("flower/standImage","Image")
	self.flowerStandImage:SetActive(false)
	self.flowerAnim = self:SubGet("flower/anim","SkeletonGraphic")
	self.flowerAnim:SetActive(false)
	self.flowerEffect = self:FindChild("flower/Effect")
	self.flowerEffect:SetActive(false)

	self.processText = self:SubGet("processText","Text")
	self:UpdateTotalNum()

	self.readyNode = self:FindChild("ready")
	self.readyNode:SetActive(false)
	self.readyText = self:SubGet("ready/Text","Text")

	self.succNode = self:FindChild("succ")
	self.succNode:SetActive(false)

	self.timesText = self:SubGet("timesText","Text")

	-- self:AddClick("oper/subBtn",slot(self.OnSubBtnClick,self))
	-- self:AddClick("oper/addBtn",slot(self.OnAddBtnClick,self))
    self:AddLongClick("oper/subBtn",{
        funcClick = slot(self.OnSubBtnClick,self),
        funcLongClick = slot(self.OnSubBtnClick,self),
    })
    self:AddLongClick("oper/addBtn",{
        funcClick = slot(self.OnAddBtnClick,self),
        funcLongClick = slot(self.OnAddBtnClick,self),
    })

	self.totalNumText = self:SubGet("oper/Text","Text")

	self:AddClick("btn",slot(self.OnWishBtnClick,self))
	self.wishCostText = self:SubGet("btn/Text","Text")

	self:AddClick("listBtn",slot(self.OnWishListBtnClick,self))

end

function baseClass:OnSubBtnClick()
	if self.isPlayAnim then
		return
	end
	if self.wishCount>1 then
		self.wishCount = self.wishCount - 1
		self:UpdateWishCount()
	end
end

function baseClass:OnAddBtnClick()
	if self.isPlayAnim then
		return
	end
	if self.wishCount + 1 > self.sumNum - self.hasNum then
		CC.ViewManager.ShowTip(self.language.wishLimit)
		return
	end
	if self.wishCount<self.sumNum then
		self.wishCount = self.wishCount + 1
		self:UpdateWishCount()
	end
end

function baseClass:OnWishBtnClick()
	if self.isPlayAnim then
		return
	end
	if not self:CheckCanCost() then
		return
	end
    local data = {}
	data.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
    data.Times = self.wishCount
    data.WishType = self.wishType
    CC.Request("ReqWaterLampWish",data,function (errCode, data)
			log(CC.uu.Dump(data,"ReqWaterLampWishSuccess",10))
			self:OnLoyKraThongWishSucceed()
			self.wishCount = 1
			self:UpdateWishCount()
		end,
		function (err)
			if type(err) == "number" and err >= 340 and err <= 347 then
				 CC.Request("ReqGetWaterLampWishInfo")
			end
			self.wishCount = 1
			self:UpdateWishCount()
		end)
end

function baseClass:OnWishListBtnClick()
	if self.isPlayAnim then
		return
	end
	if self.openListCallback then
		self.openListCallback(self.wishType)
	end
end

function baseClass:CheckCanCost()
	local cost = self.singleWishCost*self.wishCount
	if self.wishType == 1 then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < cost then
			if CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
                CC.ViewManager.Open("SelectGiftCollectionView")
            else
                CC.ViewManager.Open("StoreView")
            end
            return false
	    end
	else
		if CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher") < cost then
			CC.ViewManager.ShowTip(self.language.wishMoneyNotEnough)
			return false
		end
	end
	return true
end

function baseClass:InitTextByLanguage()
	-- body
end

function baseClass:OnShow()
	self:UpdateWishCount()
	self:UpdateTotalNum()
	self:UpdateWishTimes()
end

-- 刷新想要许愿次数
function baseClass:UpdateWishCount()
	self.totalNumText.text = tostring(self.wishCount)
	self.wishCostText.text = CC.uu.NumberFormat(self.singleWishCost*self.wishCount)
end

-- 刷新许愿进度
function baseClass:UpdateTotalNum()
	self.processText.text = self.hasNum.."/"..self.sumNum
end

-- 刷新已经许愿次数
function baseClass:UpdateWishTimes()
	if self.wishType == 2 and self.wishTimes == 0 and self.wishLeftRound then
		self.timesText.text = string.format(self.language.timesLeftText,self.wishLeftRound)
	else
		self.timesText.text = string.format(self.language.timesText,self.wishTimes)
	end
end

function baseClass:RegisterEvent()
	-- CC.HallNotificationCenter.inst():register(self,self.OnUpdateWishProcess,CC.Notifications.OnUpdateWishProcess)
	-- CC.HallNotificationCenter.inst():register(self,self.OnUpdateSelfWishTimes,CC.Notifications.OnUpdateSelfWishTimes)
	-- CC.HallNotificationCenter.inst():register(self,self.OnLoyKraThongWishShow,CC.Notifications.OnLoyKraThongWishShow)
	-- CC.HallNotificationCenter.inst():register(self,self.OnLoyKraThongWishSucceed,CC.Notifications.OnLoyKraThongWishSucceed)
end

function baseClass:UnRegisterEvent()
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnUpdateWishProcess)
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnUpdateSelfWishTimes)
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnLoyKraThongWishShow)
	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnLoyKraThongWishSucceed)
end

function baseClass:SetWishData( data )
	if data == nil then
		logError("SetWishData error")
		return
	end
	if self.isPlayAnim then
		log("isPlayAnim")
		if data.WishStatus and data.WishStatus == 1 then
			self.isNextStart = true
		end
		return
	end
	--[[
	//水灯节信息
	message WaterLampWishItem{
		required bool Open = 1;
		required int64 Round = 2;
		required int64 Rest = 3;
		required int64 Total = 4;
		required PlayerWish Wish = 5;
		required int32 WishStatus = 6;// -1 - 异常状态 0 - 发奖，倒计时30秒 1 - 正常泼水状态
		optional int64 CountDown = 7;// 上述状态为0，开奖时，7,8项才有用
		repeated RewardPlayer RewardInfo = 8;
		required int64 TotalCost = 9;//奖池总筹码
		optional int32 CostPropId = 10;
		optional int64 CostCount = 11;
	}
	//个人信息
	message PlayerWish {
		required int64 PlayerId = 1;
		required int64 Rest = 2;
		required int64 Total = 3;
	}
	]]

	local costCount = data.CostCount
	self.singleWishCost = (costCount and costCount~=0) and costCount or (self.wishType == 1 and singleWishCost1 or singleWishCost2)

	if data.Total and data.Rest then
		self:OnUpdateWishProcess(data.Total-data.Rest,data.Total)
	end

	if data.Round then
		self.wishRound = data.Round
	end

	if data.RestRewardTimes then
		self.wishLeftRound = data.RestRewardTimes
	end

	local PlayerWish = data.Wish
	if PlayerWish and PlayerWish.PlayerId and PlayerWish.PlayerId == CC.Player.Inst():GetLoginInfo().PlayerId then
		self:OnUpdateSelfWishTimes(PlayerWish.Total-PlayerWish.Rest)
	end

	if data.WishStatus and data.WishStatus == 0 then
		self.isNextStart = false
		self.rewardInfo = data.RewardInfo
		self:OnLoyKraThongWishShow(data.CountDown)
	end
end

-- 许愿进度变化
function baseClass:OnUpdateWishProcess(hasNum, sumNum)
	if hasNum and sumNum then
		self.hasNum = hasNum
		self.sumNum = sumNum
		self:UpdateTotalNum()
		local leftNum = sumNum - hasNum
		if self.wishCount > leftNum then
			self.wishCount = leftNum
			self:UpdateWishCount()
		elseif self.wishCount <= 0 then
			self.wishCount = 1
			self:UpdateWishCount()
		end

	end
end

-- 已经许愿次数变化
function baseClass:OnUpdateSelfWishTimes(times)
	if times then
		self.wishTimes = times
		self:UpdateWishTimes()
	end
end

-- 许愿达成
function baseClass:OnLoyKraThongWishShow(countDown)
	self.isPlayAnim = true
	self.succNode:SetActive(false)
	self.flowerImage:SetActive(false)
	self.flowerStandImage:SetActive(true)
	self:StopTimer("anim")
	local countDownTime = (countDown and countDown < CountDownConst) and countDown or CountDownConst -- countDown or CountDownConst
	local min = countDownTime
	local update = function ()
		CC.Sound.PlayHallEffect("LoyKraThongWishCountDown.ogg")
		self.readyText.text = CC.uu.TicketFormat(min,true)
		min = min - 1
		if min < 0 then
			self:StopTimer("anim")
			self.readyNode:SetActive(false)
			-- 播放动画
			self:PlayFlowerAnim()
		end
	end
	self.readyNode:SetActive(true)
	self.readyText.text = CC.uu.TicketFormat(min,true)
	self:StartTimer("anim",1,update,-1)
end

-- 许愿成功
function baseClass:OnLoyKraThongWishSucceed()
	if self.isPlayAnim then
		return
	end
	-- self.succ_co = coroutine.start(function ()
	-- 	self.succNode:SetActive(true)
	-- 	coroutine.wait(3)
	-- 	self.succNode:SetActive(false)
	-- end)
	CC.Sound.PlayHallEffect("LoyKraThongWishSucc.ogg")
	self.succNode:SetActive(true)
	self:DelayRun(3,function ()
		self.succNode:SetActive(false)
	end)
end

function baseClass:PlayFlowerAnim()
	-- if self.flowerAnim.AnimationState then
	-- 	self.flowerAnim.AnimationState:ClearTracks()
	-- 	self.flowerAnim.AnimationState:SetAnimation(0, "stand", false)
	-- end

	-- self:DelayRun(1.5,function ()
	-- 	-- 播放结束
	-- 	self.flowerImage:SetActive(true)
	-- 	self.flowerAnim:SetActive(false)
	-- 	self.flowerEffect:SetActive(true)
	-- 	self.isPlayAnim = false
	-- end)

	self.anim_co = coroutine.start(function ()
		CC.Sound.PlayHallEffect("LoyKraThongWishAnim.ogg")
		self.flowerStandImage:SetActive(false)
		self.flowerAnim:SetActive(true)
		self.flowerAnim.AnimationState.Complete =  self.flowerAnim.AnimationState.Complete + function ()
			self.flowerAnim.AnimationState:ClearTracks()
	        self.flowerAnim.AnimationState:SetAnimation(0, "stand", true)
		end
		self.flowerEffect:SetActive(false)

		coroutine.wait(1) -- 特效显示时机

		self.flowerEffect:SetActive(true)

		coroutine.wait(0.4) -- 动画剩余时长

		self.flowerImage:SetActive(true)
		self.flowerAnim:SetActive(false)

		coroutine.wait(0.5) -- 等待一下

		self.isPlayAnim = false

		-- 展示本期中奖
		if self.openWinCallback then
			CC.Sound.PlayHallEffect("LoyKraThongWishList.ogg")
			self.openWinCallback(self.wishType,self.rewardInfo)
		end

		-- self:DelayRun(1,function ()
		if self.isNextStart then
			 CC.Request("ReqGetWaterLampWishInfo")
		end
		-- end)

	end)
end

function baseClass:OnHide()
	-- body
end

function baseClass:OnDestroy()
	-- if self.succ_co then
	-- 	coroutine.stop(self.succ_co)
	-- 	self.succ_co = nil
	-- end
	if self.anim_co then
		coroutine.stop(self.anim_co)
		self.anim_co = nil
	end
	self:UnRegisterEvent()
end

return baseClass