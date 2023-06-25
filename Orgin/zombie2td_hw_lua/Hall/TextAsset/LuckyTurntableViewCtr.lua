local CC = require("CC")

local LuckyTurntableViewCtr = CC.class2("LuckyTurntableViewCtr")

--缓动函数
local function QuadEaseOut(time)
    return -1 * time * (time - 2);
end

function LuckyTurntableViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function LuckyTurntableViewCtr:InitVar(view,param)
	self.param = param
	self.view = view

end

function LuckyTurntableViewCtr:OnCreate()
	self:InitData()
	self:RegisterEvent()
	self:StartUpdate();
end

function LuckyTurntableViewCtr:InitData()
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
	self.turntableMul = {100, 1, 1.2, 1.4, 1.1, 1.3, 100, 1, 1.2, 1.4, 1.1, 1.3}

	--滚动信息，当前移动的标记
	self.curMoveIndex = 0
	--下一个间隔时间
	self.dalayTime = 0
	--中奖数量
	self.awardNum = 0

	self.getRankData = false
end

function LuckyTurntableViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnRefreshPropChange,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self,self.LuckySpinRecord,CC.Notifications.LuckySpinRecord)
	CC.HallNotificationCenter.inst():register(self,self.LuckySpinRewardMsg,CC.Notifications.LuckySpinRewardMsg)
	CC.HallNotificationCenter.inst():register(self,self.ReqLuckyRecordResp,CC.Notifications.NW_ReqLuckySpinRecord)
	CC.HallNotificationCenter.inst():register(self,self.ReqLuckySpinResp,CC.Notifications.NW_ReqLuckySpin)
	CC.HallNotificationCenter.inst():register(self,self.ReqLuckySpinInfoResp,CC.Notifications.NW_ReqLuckySpinInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)
end

function LuckyTurntableViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LuckySpinRecord)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.LuckySpinRewardMsg)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLuckySpinRecord);
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLuckySpin);
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqLuckySpinInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOrderStatus)
end

function LuckyTurntableViewCtr:OnRefreshPropChange(props, source)
	local ChouMa = 0
	local isNeedRefresh = false;
	for _,v in ipairs(props) do
		if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			ChouMa = v.Delta
		end
		if v.ConfigId == CC.shared_enums_pb.EPC_ZuanShi then
			isNeedRefresh = true;
		end
	end
	if source == CC.shared_transfer_source_pb.TS_LevelUp then
		self.view:SetVipUpChouMa(ChouMa)
	end
	if isNeedRefresh then
		self.view:ShowChipAddBtn()
	end
end

--钻石购买礼包推送
function LuckyTurntableViewCtr:LuckySpinRecord(data)
	log(CC.uu.Dump(data,"LuckySpinRecord",10))
	if data.Multi and data.PlayerId == CC.Player.Inst():GetSelfInfoByKey("Id") then
		self.view:OnSpinNowTurn(data.Multi)
	end
end

function LuckyTurntableViewCtr:LuckySpinRewardMsg(data)
	log(CC.uu.Dump(data,"LuckySpinRewardMsg",10))
	--self.view:AddItemData(data.Msg)
end

--开始转动
function LuckyTurntableViewCtr:StartRoll(targetMul)
	self.startRoll = true
	self.rollCount = 3
	self.tmpBeginAngle = self.view:GetTableAngle()
	self.targetAngle = self.tmpBeginAngle + self.perCircleAngle
	self.interpolation = 0
	self.pointerSpeed = 6
	self.pointerInterpolation = 0
	self.pointerAngle = 45
	self.awardNum = 0
	self.curNum = self.finalNum
	self:RondomSelectArea(targetMul)
end

--2个相同倍数随机选择区域
function LuckyTurntableViewCtr:RondomSelectArea(targetMul)
	local tempTab = {}
	--丢失精度处理
	targetMul = math.floor(targetMul * 10 + 0.5) / 10
	for i = 1, #self.turntableMul do
		if targetMul == self.turntableMul[i] then
			table.insert(tempTab, i)
		end
	end
	if #tempTab > 1 then
		local idx = math.random(1, #tempTab)
		self.finalNum = tempTab[idx]
	end
	self.awardNum = self.turntableMul[self.finalNum] * 300000
end

function LuckyTurntableViewCtr:RollFisish()
	self.startRoll = false
	self.orgDeltaAngle = self.deltaAngle
	self.view:SetReceiveResult(self.finalNum)
end


function LuckyTurntableViewCtr:StartUpdate()

	UpdateBeat:Add(self.Update,self);
end

function LuckyTurntableViewCtr:StopUpdate()

	UpdateBeat:Remove(self.Update,self);
end

function LuckyTurntableViewCtr:Update()
	--每隔6秒移动下一个
	self.dalayTime = self.dalayTime - Time.deltaTime
	if self.dalayTime <= 0 then
		self.dalayTime = 6
		self.curMoveIndex = self.curMoveIndex + 1
		self.view:MoveRoll(self.curMoveIndex)
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

function LuckyTurntableViewCtr:GetRoundDelta()
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

function LuckyTurntableViewCtr:ReqLuckyInfo()
	CC.Request("ReqLuckySpinInfo")
end

function LuckyTurntableViewCtr:ReqLuckySpinInfoResp(err,result)
	log("err = ".. err.."  "..CC.uu.Dump(result,"ReqLuckySpinInfo",10))
	if err == 0 then
		if result.IsOpen then
			self.view:LuckyCountDown(result.Countdown)
		end
	end
end

function LuckyTurntableViewCtr:ReqLuckyRecord()
	if self.getRankData then return end
	CC.Request("ReqLuckySpinRecord")
end

function LuckyTurntableViewCtr:ReqLuckyRecordResp(err,result)
	log("err = ".. err.."  "..CC.uu.Dump(result,"ReqLuckySpinRecord",10))
	if err == 0 then
		self.getRankData = true
		self.view:InitInfo(result.Records)
	end
end

function LuckyTurntableViewCtr:ReqLuckySpin()
	CC.Request("ReqLuckySpin")
end

function LuckyTurntableViewCtr:ReqLuckySpinResp(err,result)
	log("err = ".. err.."  "..CC.uu.Dump(result,"ReqLuckySpin",10))
	if err == 0 then
		self.view:OnSpinNowTurn(result.Multi)
		CC.HallNotificationCenter.inst():post(CC.Notifications.LuckyCountDown, 0)
	end
end

function LuckyTurntableViewCtr:ReqOrderStatusResq(err, data)
	log(CC.uu.Dump(data,"result",10))
	if err == 0 then
		if not data.Items[1].Enabled then
			--已经购买过礼包
			self.view.bought = true
			self.view:ShowTip()
		end
	end
end

function LuckyTurntableViewCtr:Destroy()
	self:unRegisterEvent()
	self:StopUpdate();
end

return LuckyTurntableViewCtr