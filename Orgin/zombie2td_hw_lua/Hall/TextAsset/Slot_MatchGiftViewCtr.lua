local CC = require("CC")

local M = CC.class2("Slot_MatchGiftViewCtr")
local Slot_MatchUtils = require("View/SlotMatch/Slot_MatchUtils")
local SlotMatchManager = CC.SlotMatchManager
local slotMatch_message_pb = CC.slotMatch_message_pb


--缓动函数
local function QuadEaseOut(time)
    return -1 * time * (time - 2);
end

function M:ctor(view, param)
	self:InitVar(view,param)
end

function M:InitVar(view,param)
	self.param = param
	self.view = view

end

function M:OnCreate()
	self:InitData()
	self:RegisterEvent()
	self:StartUpdate();
	self:RequestGiftData();
end

function M:InitData()
	--开始转动
	self.startRoll = false
	--插值累计
	self.interpolation = 0;
	--初始转到速度
	self.initSpeed = 0.6
	--转动速度
	self.speed = self.initSpeed
	--衔接最后一圈的减速系数
	self.speedDownMul = 2.5;
	--当前剩余转动圈数
	self.rollCount = 3
	--每一圈转多少角度
	self.perCircleAngle = 360
	--起始转度
	self.tmpBeginAngle = 0
	--转盘均分的区域数量
	self.blockCount = 12
	--均分的区域角度
	self.divideBlockAngle = self.perCircleAngle / self.blockCount;
	--随机偏移角度的系数(保证不随机到两个扇形的正中间)
	self.deltaAngleMul = 0/5;
	--随机一个扇形区域
	self.randomAngle = math.random(-math.floor(self.divideBlockAngle/2 * self.deltaAngleMul), math.floor(self.divideBlockAngle/2 * self.deltaAngleMul));
	--最后指针指向扇形区域添加一个偏移角度,让其指向扇形区域正中间
	self.deltaAngle = self.randomAngle;
	--初始偏移
	self.orgDeltaAngle = 0
	--当前指向的区域编号
	self.curNum = 1;
	--最后指向的区域编号
	self.finalNum = 1;
	self.targetAngle = 360
	--指针摆动弧度
	self.pointerAngle = 45;
	--指针摆动差值
	self.pointerInterpolation = 0;
	self.pointerSpeed = 6
	--指针经过半个扇形区域的累计角度
	self.pointerHalfAddAngle = 0;
	self.pointerShakeState = false
	--指针经过一个扇形区域的累计角度
	self.pointerAddAngle = 0
	--转盘个区域倍数
	self.turntableMul = {}--{100, 1, 1.2, 1.4, 1.1, 1.3, 100, 1, 1.2, 1.4, 1.1, 1.3}

	--滚动信息，当前移动的标记
	self.curMoveIndex = 0
	--下一个间隔时间
	self.dalayTime = 0
end

function M:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnGiftData,CC.Notifications.MATCHGIFT);
	CC.HallNotificationCenter.inst():register(self,self.OnPushReadyMatchInfo,CC.Notifications.READYMATCHINFO);
    CC.HallNotificationCenter.inst():register(self,self.OnPushProcessMatchInfo,CC.Notifications.PROCESSMATCHINFO);
	CC.HallNotificationCenter.inst():register(self,self.OnPushGiftPurchase,CC.Notifications.GIFTPURCHASE);
	CC.HallNotificationCenter.inst():register(self,self.OnMatchStage,CC.Notifications.MATCHSTAGE);
    CC.HallNotificationCenter.inst():register(self,self.OnPushStageChange,CC.Notifications.STAGECHANGE);
end

function M:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

function M:RequestGiftData()
	if self.param and self.param.ReqGiftFunc() then
		self.param.ReqGiftFunc();
	end
end

function M:OnGiftData(data)
	log(CC.uu.Dump(data,"OnGiftData",10))
	self.giftData = data.arrGift;
end

function M:OnPushReadyMatchInfo(data)
    log(CC.uu.Dump(data,"OnPushReadyMatchInfo",10))
    self.view:ResetEnMatch();
    self.view:RefreshEnMatch(data.enMatch);
end

function M:OnPushProcessMatchInfo(data)
    log(CC.uu.Dump(data,"OnPushProcessMatchInfo",10))
    self.view:ResetEnMatch();
    self.view:RefreshEnMatch(data.enMatch);
end

function M:OnPushGiftPurchase(data)
	log(CC.uu.Dump(data,"OnPushGiftPurchase",10))
	if Slot_MatchUtils.Return0IfNil(data.playerId) == CC.Player.Inst():GetSelfInfoByKey("Id") then
		self.rewardData = data;
		self.view:OnSpinNowTurn(Slot_MatchUtils.Return0IfNil(data.ratio));
		self.view:RefreshEnMatch(nil);
	end
end

function M:OnMatchStage(data)
	log(CC.uu.Dump(data,"OnMatchStage",10))
	self.curStage = data.matchStage.curStage;
end

function M:OnPushStageChange(data)
	log(CC.uu.Dump(data,"OnPushStageChange",10))
	if data.matchStage.curStage == slotMatch_message_pb.En_Stage_Balance then  ----只有比赛阶段才打开显示
		SlotMatchManager.inst():CloseView(self.view.viewName);
	end
	self.curStage = data.matchStage.curStage;
end

function M:GetGiftInfo(giftId)
    for k,v in pairs(self.giftData) do
        if v.giftId == M.CidToSid(giftId) then
            return v;
        end
	end
	logError("找不到对应的礼包，礼包索引是:"..giftId);
end

function M:SetTurntableMul(allSpinRatios)
	self.turntableMul = allSpinRatios;
end

local CidToSidMap = {
    ["1"] = "30030",
    ["2"] = "30031",
    ["3"] = "30032",
    ["4"] = "30033",
}

function M.CidToSid(cid)
    return CidToSidMap[cid];
end

--开始转动
function M:StartRoll(targetMul)
	self.startRoll = true
	self.rollCount = 3
	self.tmpBeginAngle = self.view:GetTableAngle()
	self.targetAngle = self.tmpBeginAngle + self.perCircleAngle
	self.interpolation = 0
	self.pointerSpeed = 6
	self.pointerInterpolation = 0
	self.pointerAngle = 45
	self.curNum = self.finalNum
	self:RondomSelectArea(targetMul)
end

--2个相同倍数随机选择区域
function M:RondomSelectArea(targetMul)
	local tempTab = {}
	--丢失精度处理
	targetMul = math.floor(targetMul * 10 + 0.5) / 10
	for i = 1, #self.turntableMul do
		if ""..targetMul == self.turntableMul[i] then
			table.insert(tempTab, i)
		end
	end
	if #tempTab > 1 then
		local idx = math.random(1, #tempTab)
		self.finalNum = tempTab[idx]
	elseif #tempTab == 1 then
		self.finalNum = tempTab[1]
	end
end

function M:RollFisish()
	self.startRoll = false
	self.orgDeltaAngle = self.deltaAngle
	self.view:SetReceiveResult(self.rewardData);
end


function M:StartUpdate()

	UpdateBeat:Add(self.Update,self);
end

function M:StopUpdate()

	UpdateBeat:Remove(self.Update,self);
end

function M:Update()
	--每隔6秒移动下一个
	self.dalayTime = self.dalayTime - Time.deltaTime
	if self.dalayTime <= 0 then
		self.dalayTime = 6
		self.curMoveIndex = self.curMoveIndex + 1
	end

	if not self.startRoll then return end
	self.speed = self.rollCount <= 1 and self.initSpeed / self.speedDownMul or self.initSpeed

	self.interpolation = Mathf.Clamp(self.interpolation + self.speed * Time.deltaTime, 0, 1);
	local t = self.interpolation
	if self.rollCount == 1 then
		t = QuadEaseOut(self.interpolation)
	end
	local tempAngle = Mathf.Lerp(self.tmpBeginAngle, self.targetAngle, t);
	self.view:RefreshTableAngle(tempAngle);
	--指针摆动状态判断
	if tempAngle  + 15 - self.pointerHalfAddAngle >= self.divideBlockAngle then
		--转到卡槽
		self.pointerHalfAddAngle = self.pointerHalfAddAngle + self.divideBlockAngle
		self.pointerShakeState = true
	end
	if tempAngle - self.pointerAddAngle >= self.divideBlockAngle then
		--转到正中
		self.pointerAddAngle = self.pointerAddAngle + self.divideBlockAngle
		self.pointerShakeState = false
	end
	if self.rollCount > 1 then
		self.pointerInterpolation = self.pointerInterpolation + Time.deltaTime * self.speed * self.pointerSpeed
		if self.pointerInterpolation > 0.5 then
			self.pointerInterpolation = 1 - self.pointerInterpolation
		elseif self.pointerInterpolation < 0.4 then
			self.pointerInterpolation = 0.4
		end
	elseif self.rollCount <= 1 then
		local finallyAngle = self.targetAngle - tempAngle
		if finallyAngle <= 8 then
			--最后8度，摆针减小
			self.pointerSpeed = 2
			self.pointerShakeState = false
		end
		if self.pointerShakeState then
			self.pointerInterpolation = self.pointerInterpolation + Time.deltaTime * self.speed * self.pointerSpeed
		else
			self.pointerInterpolation = self.pointerInterpolation - Time.deltaTime * self.speed * self.pointerSpeed
			if self.pointerInterpolation < 0 then
				self.pointerInterpolation = 0
			end
		end
		if self.pointerInterpolation > 0.5 then
			self.pointerInterpolation = 1 - self.pointerInterpolation
		end
	end
	local zAngle = -Mathf.PingPong( Mathf.Lerp(0, self.pointerAngle * 2,self.pointerInterpolation), self.pointerAngle)
	--CC.uu.Log("zAngle:" .. zAngle .. "  pointerInterpolation:" .. self.pointerInterpolation)
	self.view:RefreshPointerArrowAngle(zAngle);
	if self.pointerInterpolation >= 1 then
		self.pointerInterpolation = 0;
	end
	if self.interpolation == 1 then
		self.rollCount = self.rollCount - 1;
		self.interpolation = 0;
		--最后一圈增量角度
		local lastDeltaAngle = 0;
		if self.rollCount == 1 then
			lastDeltaAngle = self:GetRoundDelta() -self.orgDeltaAngle + self.deltaAngle;
		elseif self.rollCount <= 0 then
			self.view:RefreshPointerArrowAngle(0)
			self:RollFisish()
			return;
		end
		self.tmpBeginAngle = self.targetAngle;
		self.targetAngle = self.tmpBeginAngle + self.perCircleAngle + lastDeltaAngle;
	end
end

function M:GetRoundDelta()
	local delta = 0;
	if self.curNum > self.finalNum then
		delta = (self.blockCount - self.curNum + self.finalNum) * self.divideBlockAngle;
	else
		delta = (self.finalNum - self.curNum) * self.divideBlockAngle;
	end
	--控制偏移角度在(-180~180之间)
	delta = delta > 180 and (delta - self.perCircleAngle) or delta;
	return delta;
end

function M:Destroy()
	self:unRegisterEvent()
	self:StopUpdate();
end

function M:ClearRewardData()
	if self.rewardData and self.param.GetSlotMatchGiftRewardFunc then
		self.param.GetSlotMatchGiftRewardFunc();
	end
	self.rewardData = nil;
end

return M