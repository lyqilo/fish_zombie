
---------------------------------
-- region DailyTurntableViewCtr.lua    -
-- Date: 2019.7.18        -
-- Desc: 每日转盘  -
-- Author: Bin        -
---------------------------------

local CC = require("CC")
local DailyTurntableViewCtr = CC.class2("DailyTurntableViewCtr")

--转盘运动状态标记
local StateTags = {
	Normal = 1,
	First = 2,
	Last = 3,
	Finish = 4,
}

--缓动函数
local function QuadEaseOut(time)

    return -1 * time * (time - 2);
end

function DailyTurntableViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function DailyTurntableViewCtr:OnCreate()

	self:InitData();

	self:StartUpdate();

	self:RegisterEvent();

	self:OnReqTurntableInfo();

	self:OnStartReqJackpot();
end

function DailyTurntableViewCtr:InitVar(view, param)

	self.view = view;
	--转盘配置
	self.turntableCfg = {
		[1] = {
			orgDeltaAngle = -0.3,
			blockItems = {},
			orgSpeed = 0.6,
			unLockLevel = 1,
			pointerSpeed = 8;
		},
		[2] = {
			orgDeltaAngle = 0,
			blockItems = {},
			orgSpeed = 0.6,
			unLockLevel = 3,
			pointerSpeed = 8;
		},
		[3] = {
			orgDeltaAngle = -0.5,
			blockItems = {},
			orgSpeed = 0.6,
			unLockLevel = 5,
			pointerSpeed = 6;
		},
		[4] = {
			orgDeltaAngle = 3,
			blockItems = {},
			orgSpeed = 0.6,
			unLockLevel = 10,
			pointerSpeed = 6;
		}
	};
	--转盘层级数据
	self.turntableData = {};
	--转盘各层箭头
	self.arrowList = {};
	--中奖类型
	self.awardType = {
		ARROW = 0,
		AWARD = 1,
		JACKPOT = 2,
	}
	--当前转盘层级
	self.curTbLayer = 1;
	--转盘总层级
	self.totalTbLayer = 5;
	--当前中奖的层级
	self.curAwardTbLayer = 0;
	--当前转盘对象
	self.curTurntable = nil;
	--进入vip0特殊转盘处理(引导玩家充值付费)
	self.specialSpin = false;
	--是否购买了VIP礼包
	self.purchaseVIP = false;
	--随机偏移角度的系数(保证不随机到两个扇形的正中间)
	self.deltaAngleMul = 4/5;
	--每次请求的数据
	self.resultInfo = nil;
	--每次转盘获奖数据(单独保存,避免resultInfo被其他请求覆盖导致没有获奖数据)
	self.rewardInfo = nil;
	--首次打开界面刷新数据标记(用来显示vip0特殊补签)
	self.firstRefreshInfo = false;
	--指针摆动差值
	self.pointerInterpolation = 0;
	--指针摆动状态
	self.pointerShakeState = false;
	--指针经过每个扇形区域的累计角度
	self.pointerAddAngle = 0;
	--每圈初始偏移角度
	self.pointerDeltaAngle = nil;
	--标记整个大转盘是否转完一轮
	self.rollAllFinish = false;
	--转盘扇形区域配置
	self.turntableBlockCfg = CC.ConfigCenter.Inst():getConfigDataByKey("DailyTurntable");

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");

	self.propShow = {
		[CC.shared_enums_pb.EPC_GiftVoucher] = true,
		[CC.shared_enums_pb.EPC_New_GiftVoucher] = true,
		-- [CC.shared_enums_pb.EPC_TenGift_Sign_97] = true,
	}

	self.getRankData = false;
end

function DailyTurntableViewCtr:InitData()
	--转化转盘的配置
	self:FormatTbCfg();

	for i,v in ipairs(self.turntableCfg) do

		local tb = {};
		--每一层转盘索引
		tb.layer = i;
		--转动标记
		tb.canRoll = false;
		--插值累计
		tb.interpolation = 0;
		--当前转动速度
		tb.speed = 0;
		--初始转动速度
		tb.orgSpeed = v.orgSpeed;
		--衔接最后一圈的减速系数
		tb.speedDownMul = 2.5;
		--当前剩余转动圈数
		tb.rollCount = 2;
		--初始需要完成的圈数
		tb.orgRollCount = 2;
		--每一圈转多少角度
		tb.perCircleAngle = 360;
		--转盘均分的区域数量
		tb.blockCount = #v.blockItems;
		--均分的区域角度
		tb.divideBlockAngle = tb.perCircleAngle / tb.blockCount;
		--转盘原始角度
		tb.orgAngle = 0 -- -tb.divideBlockAngle / 2;

		tb.perBeginAngle = tb.orgAngle + v.orgDeltaAngle;
		--起始转动角度
		tb.tmpBeginAngle = tb.orgAngle + v.orgDeltaAngle;
		--目标转动角度
		tb.tmpEndAngle = tb.tmpBeginAngle + tb.perCircleAngle;
		--随机一个扇形区域
		tb.randomAngle = math.random(-math.floor(tb.divideBlockAngle/2 * self.deltaAngleMul), math.floor(tb.divideBlockAngle/2 * self.deltaAngleMul));
		--最后指针指向扇形区域添加一个偏移角度,让其指向扇形区域正中间
		tb.deltaAngle = tb.randomAngle;
		--当前指向的区域编号
		tb.curNum = 1;
		--最后指向的区域编号
		tb.finalNum = 1;

		tb.pointerSpeed = v.pointerSpeed;

		table.insert(self.turntableData, tb);

		--把每一层的箭头区域编号都存起来(用于抽奖后组数据)
		self.arrowList[i] = {};

		for _,item in ipairs(v.blockItems) do

			if item.type == self.awardType.ARROW then

				table.insert(self.arrowList[i], item.offset);
			end
		end
	end

	self.curTurntable = self.turntableData[self.curTbLayer];
end

function DailyTurntableViewCtr:FormatTbCfg()
	--转换成转盘使用的配置
	for _,v in ipairs(self.turntableBlockCfg) do

		if self.turntableCfg[v.Round] then

			local tbCfg = self.turntableCfg[v.Round].blockItems;

			local tb = {};
			--奖励id
			tb.Id = v.Id;
			--奖励描述
			tb.desc = v.Desc;
			--数量
			tb.count = v.Count;
			--中奖类型
			tb.type = v.Type;
			--转盘上对应的编号
			tb.offset = v.Offset;

			if self.propShow[v.PropConfigId] and self.propCfg[v.PropConfigId] then
				--奖励图标
				tb.iconImg = self.propCfg[v.PropConfigId].Icon;
			end

			table.insert(tbCfg, tb);
		end
	end
end

function DailyTurntableViewCtr:ResetTurnTableData(tb)

	local tb = tb or self.curTurntable;

	tb.canRoll = false;

	tb.interpolation = 0;

	tb.speed = 0;

	tb.rollCount = tb.orgRollCount;

	tb.orgAngle = 0;

	tb.perBeginAngle = self.view:GetTableAngle(tb.layer);

	tb.tmpBeginAngle = self.view:GetTableAngle(tb.layer);

	tb.tmpEndAngle = tb.tmpBeginAngle + tb.perCircleAngle;

	local lastRandomAngle = tb.randomAngle;

	tb.randomAngle = math.random(-math.floor(tb.divideBlockAngle/2 * self.deltaAngleMul), math.floor(tb.divideBlockAngle/2 * self.deltaAngleMul));

	tb.deltaAngle = tb.randomAngle - lastRandomAngle;

	-- logError("layer:"..self.curTbLayer.."   begin:"..tb.tmpBeginAngle.."  end:"..tb.tmpEndAngle.."  deltaAngle:"..tb.deltaAngle.. "  random:"..tb.randomAngle)

	tb.curNum = tb.finalNum;
end

function DailyTurntableViewCtr:RegisterEvent()
	--每日转盘信息
	CC.HallNotificationCenter.inst():register(self,self.OnDailySpinInfoRsp,CC.Notifications.NW_ReqGetDailySpinInfo);
	--请求免费转动
	CC.HallNotificationCenter.inst():register(self,self.OnDailySpinRsp,CC.Notifications.NW_ReqDailySpin);
	--请求付费转动
	CC.HallNotificationCenter.inst():register(self,self.OnCostDailySpinRsp,CC.Notifications.NW_ReqCostDailySpin);
	--请求vip0特殊转动
	CC.HallNotificationCenter.inst():register(self,self.OnSpecialDailySpinRsp,CC.Notifications.NW_ReqSpecialDailySpin)
	--转动结果推送(所有转盘结果推送都走这里)
	-- CC.HallNotificationCenter.inst():register(self,self.OnJacpotChanged,CC.Notifications.DailySpinChanged);
	--进入VIP0特殊逻辑推送
	-- CC.HallNotificationCenter.inst():register(self,self.OnSpecialDailySpinChanged,CC.Notifications.SpecialDailySpinChanged);
	--充值成功推送
	CC.HallNotificationCenter.inst():register(self,self.OnPurchaseSuccess,CC.Notifications.OnPurchaseNotify);
	--VIP升级
	CC.HallNotificationCenter.inst():register(self,self.OnVIPLevelUp,CC.Notifications.VipChanged);

	-- CC.HallNotificationCenter.inst():register(self,self.OnPropChanged,CC.Notifications.changeSelfInfo);
	--每日转盘JP排名
	CC.HallNotificationCenter.inst():register(self,self.OnDailySpinJPRankRsp,CC.Notifications.NW_ReqDailySpinJPRank);

	CC.HallNotificationCenter.inst():register(self,self.OnDailySpinJackpotRsp,CC.Notifications.NW_ReqDailySpinJackpot);
end

function DailyTurntableViewCtr:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetDailySpinInfo);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqDailySpin);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqCostDailySpin);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqSpecialDailySpin);

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DailySpinChanged);

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.SpecialDailySpinChanged);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.VipChanged);

	-- CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo);
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqDailySpinJPRank);

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqDailySpinJackpot);
end

function DailyTurntableViewCtr:StartUpdate()

	UpdateBeat:Add(self.Update,self);
end

function DailyTurntableViewCtr:StopUpdate()

	UpdateBeat:Remove(self.Update,self);
end

function DailyTurntableViewCtr:Update()

	local curTb = self.curTurntable;

	if not curTb.canRoll then return end

	--指针偏移角度计算(用于后面触发指针摆动判断)
	if not self.pointerDeltaAngle then

		self.pointerDeltaAngle = 0;

		local modValue = curTb.tmpBeginAngle%curTb.divideBlockAngle;

		if modValue < curTb.divideBlockAngle/2 then
			self.pointerDeltaAngle = modValue + curTb.divideBlockAngle/2;
		else
			self.pointerDeltaAngle = modValue - curTb.divideBlockAngle/2;
		end
		self.pointerDeltaAngle  = self.pointerDeltaAngle + (1-self.deltaAngleMul)*curTb.divideBlockAngle / 3;
	end

	--转盘角度计算
	curTb.speed = self:GetRollSpeed();

	curTb.interpolation = Mathf.Clamp(curTb.interpolation + curTb.speed * Time.deltaTime, 0, 1);

	local t = self:CalcInterpolation(curTb.interpolation);

	local tempAngle = Mathf.Lerp(curTb.tmpBeginAngle, curTb.tmpEndAngle, t);

	self.view:RefreshTableAngle(self.curTbLayer, tempAngle);

	--指针摆动状态判断
	if tempAngle + self.pointerDeltaAngle - curTb.tmpBeginAngle - self.pointerAddAngle >= curTb.divideBlockAngle then
		-- logError("tempAngle:"..tempAngle.."   angle:"..angle.. "   beginAngle:"..curTb.tmpBeginAngle.."  endAngle"..curTb.tmpEndAngle)
		self.pointerAddAngle = self.pointerAddAngle + curTb.divideBlockAngle;

		self.pointerShakeState = true;

		if self.pointerInterpolation > 0.5 then

			self.pointerInterpolation = 1 - self.pointerInterpolation;
		end
	end
	--指针摆动处理
	if self.pointerShakeState == true then

		self.pointerInterpolation = self.pointerInterpolation + Time.deltaTime * curTb.speed * curTb.pointerSpeed;

		self.view:RefreshPointerArrowAngle(-Mathf.PingPong( Mathf.Lerp(0,30,self.pointerInterpolation), 15));

		if self.pointerInterpolation >= 1 then

			self.pointerInterpolation = 0;

			self.pointerShakeState = false;
		end
	end

	if curTb.interpolation == 1 then

		self.pointerDeltaAngle = nil;

		self.pointerAddAngle = 0;

		curTb.rollCount = curTb.rollCount - 1;

		curTb.interpolation = 0;
		--最后一圈增量角度
		local lastDeltaAngle = 0;

		if self:CheckRollState() == StateTags.First then

		elseif self:CheckRollState() == StateTags.Last then

			-- self.view:ShakePointer();

			lastDeltaAngle = self:GetRoundDelta() - curTb.orgAngle + curTb.deltaAngle;

		elseif self:CheckRollState() == StateTags.Finish then

			self:RollFisish();

			return;
		end

		curTb.tmpBeginAngle = curTb.tmpEndAngle;

		curTb.tmpEndAngle = curTb.tmpBeginAngle + curTb.perCircleAngle + lastDeltaAngle;

		-- logError("layer:"..self.curTbLayer.."   begin:"..curTb.tmpBeginAngle.."  end:"..curTb.tmpEndAngle.."  deltaAngle:"..curTb.deltaAngle)
	end
end

--刷新箭头显示状态
function DailyTurntableViewCtr:CheckArrowState(allOpen)

	local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");

	local stateList = {};

	for _,v in ipairs(self.turntableCfg) do

		if allOpen then
			table.insert(stateList, false);
		else
			table.insert(stateList, (vipLevel < v.unLockLevel));
		end
	end

	self.view:RefreshArrowState(stateList);
end

function DailyTurntableViewCtr:CheckCostArrowState()

	if not self.resultInfo then return end;

	if self.resultInfo.SpinTimes + self.resultInfo.LockSpinTimes <= 0 then

		self:CheckArrowState(true);

		return;
	end

	self:CheckArrowState();
end

function DailyTurntableViewCtr:OnReqTurntableInfo()
    CC.Request("ReqGetDailySpinInfo");
end

function DailyTurntableViewCtr:OnStartReqJackpot()

	self.view:StartTimer("ReqDailySpinJackpot", 10, function()

		CC.Request("ReqDailySpinJackpot");
	end, -1)

end

function DailyTurntableViewCtr:OnDailySpinInfoRsp(err, result)

	-- CC.uu.Log(result,"----OnDailySpinInfoRsp-----")

	if err == 0 then

		self.resultInfo = result;

		self:CheckCostArrowState();

		self.view:RefreshJackpot(result.Jackpot);

		self:CheckBtnSpinTimes(result);

		self.firstRefreshInfo = true;
	else
		self:OnShowErrorTips(err);
	end
end

function DailyTurntableViewCtr:OnReqTurntableSpin()
	--测试代码
	-- local result = {
	-- 	Jackpot = 10000,
	-- 	SpinTimes = 1,
	-- 	RewardInfo = {
	-- 		Type = 2,
	-- 		Index = 28,
	-- 		Round = 5,
	-- 		Offset = 0,
	-- 		Reward = {{
	-- 			ConfigId = 2,
	-- 			Count = 40000,
	-- 		}}
	-- 	},
	-- 	CostSpinTimes = 0,
	-- 	CostCnt = 30000,
	-- 	LockSpinTimes = 0,
	-- 	PlayerId = 1035432
	-- }
	-- local result = {
	-- 	Jackpot = 53851340,
	-- 	SpinTimes = 0,
	-- 	PlayerId = 1048672,
	-- 	CostCnt = 30000,
	-- 	LockSpinTimes = 1,
	-- 	IsOpen = true,
	-- 	HitSpecial =  true,
	-- }

	-- self:OnDailySpinRsp(0,result);
	-- do return true end

	if not self.resultInfo then return end;

	--vip0特殊转盘次数
	if self.resultInfo.LockSpinTimes > 0 then

		self:OnReqTurntableSpecialSpin();
		return;
	end

	--免费转盘次数
	if self.resultInfo.SpinTimes > 0 then
		self:SetCanClick(false);
		CC.Request("ReqDailySpin")
		return;
	end

	--付费转盘次数
	if self.resultInfo.CostSpinTimes <= 0 then

		local vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level");

		if vipLevel < 3 then

			self:OnOpenSpinTimesMsgBox();
		else
			CC.ViewManager.ShowTip(self.view.language.notEnoughTimesTips);
		end
	else
		if self.resultInfo.CostCnt > CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") then

			self:OnOpenNotEnoughMoneyMsgBox();
		else
			self:SetCanClick(false);
			CC.Request("ReqCostDailySpin")
		end
	end

end

function DailyTurntableViewCtr:OnDailySpinRsp(err, result)

	if err == CC.shared_en_pb.DailySpinMustSpecial then
		--补签特殊转盘(充值成功后掉线等网络异常情况导致客户端没发特殊转盘请求)
		self:OnReqTurntableSpecialSpin();
	elseif err ~= 0 then
		self:OnShowErrorTips(err);
		return
	end

	if result.HitSpecial then
		--进入VIP0特殊逻辑处理
		self:OnSpecialDailySpinChanged(result);
		return;
	end

	self:OnDailySpinChanged(result);
end

function DailyTurntableViewCtr:OnJacpotChanged(result)

	self.view:RefreshJackpot(result.Jackpot, 15);
end

function DailyTurntableViewCtr:OnDailySpinChanged(result)

	CC.uu.Log(result, "----OnDailySpinChanged----")

	self.view:RefreshJackpot(result.Jackpot, 15);

	if result.PlayerId ~= CC.Player.Inst():GetSelfInfoByKey("Id") then return end;

	self.resultInfo = result;

	-- self:CheckBtnSpinTimes(result);
	--红点数据设置
	self.activityDataMgr.SetActivityInfoByKey("DailyTurntableView", {redDot = (result.SpinTimes + result.CostSpinTimes + result.LockSpinTimes) > 0});

	if not result.RewardInfo then return end

	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") > 0 then

		self:ResetBtnSignIn();
	else
		self:CheckBtnSpinTimes(result);
	end

	self.rewardInfo = result.RewardInfo;

	self:ShowJackpotEffect(false);

	self:ShowBlockEffect(false);

	if self.specialSpin then
		--VIP0特殊处理(充值成功:继续转第二圈 充值失败:重新转第一圈)
		self.curTbLayer = result.RewardInfo.Round;

		self.curTurntable = self.turntableData[self.curTbLayer];

		self.view:RefreshPointerPos(self.curTbLayer);

		self.specialSpin = false;
	else
		self.view:RefreshPointerPos(1);
	end

	self.curAwardTbLayer = result.RewardInfo.Round;
	--server只返回最终中奖的类型、层级和扇形区域编号,客户端需要把指向内圈的箭头补齐
	local finalNums = {};
	--第五层为jacpot大奖,所以实际只需要确定前四层指向的区域编号
	local round = result.RewardInfo.Round < self.totalTbLayer and result.RewardInfo.Round or (self.totalTbLayer-1);

	for i = 1, round do

		local num;

		if i == result.RewardInfo.Round then

			num = result.RewardInfo.Offset;
		else
			local randomIndex = math.random(1, #self.arrowList[i]);

			num = self.arrowList[i][randomIndex];
		end
		table.insert(finalNums, num);
	end

	self:SetFinalNums(finalNums);
end

function DailyTurntableViewCtr:OnReqTurntableSpecialSpin()
	--测试代码
	-- local result = {
	-- 	Jackpot = 10000,
	-- 	SpinTimes = 0,
	-- 	RewardInfo = {
	-- 		Type = 1,
	-- 		Index = 9,
	-- 		Round = 1,
	-- 		Offset = 9,
	-- 		Reward = {{
	-- 			ConfigId = 22,
	-- 			Count = 6}
	-- 		},
	-- 	},
	-- 	PlayerId = 1048672,
	-- 	CostCnt= 30000,
	-- 	CostSpinTimes = 0,
	-- 	LockSpinTimes = 0
	-- }
	-- self:OnDailySpinChanged(result);
	-- do return true end
	self:SetCanClick(false);
	CC.Request("ReqSpecialDailySpin")
end

function DailyTurntableViewCtr:OnCostDailySpinRsp(err, result)

	if err == CC.shared_en_pb.DailySpinMustSpecial then
		--补签特殊转盘(充值成功后掉线等网络异常情况导致客户端没发特殊转盘请求)
		self:OnReqTurntableSpecialSpin();
	elseif err ~= 0 then
		self:OnShowErrorTips(err);
		return
	end

	self:OnDailySpinChanged(result);
end

function DailyTurntableViewCtr:OnSpecialDailySpinRsp(err, result)

	if err ~= 0 then
		self:OnShowErrorTips(err);
		return
	end

	self:OnDailySpinChanged(result);
end

--收到该推送则表明进入vip0特殊逻辑处理
function DailyTurntableViewCtr:OnSpecialDailySpinChanged(result)

	CC.uu.Log(result, "----OnSpecialDailySpinChanged----")

	if result.PlayerId ~= CC.Player.Inst():GetSelfInfoByKey("Id") then return end;

	self.resultInfo = result;

	self.specialSpin = true;

	self:CheckBtnSpinTimes(result);

	self:ShowBlockEffect(false);

	self.curAwardTbLayer = 1;

	local finalNums = {};

	local randomIndex = math.random(1, #self.arrowList[self.curAwardTbLayer]);

	local num = self.arrowList[self.curAwardTbLayer][randomIndex];

	table.insert(finalNums, num);

	self:SetFinalNums(finalNums);
end

function DailyTurntableViewCtr:OnPurchaseSuccess(result)

	if CC.PaymentManager.GetActiveWareIdByKey("vip") ~= result.WareId then return end;

	if not self.specialSpin then return end;

	self.purchaseVIP = true;
end

function DailyTurntableViewCtr:OnVIPLevelUp(data)

	--vip升级刷新界面显示信息
	self:OnReqTurntableInfo();
end

function DailyTurntableViewCtr:ResetBtnSignIn()

	self.view:RefreshSignInTimes(self.view.language.showResult);

	self.view:ResetBtnSignInClick("showResult");
end

--刷新转盘抽奖按钮文本显示
function DailyTurntableViewCtr:CheckBtnSpinTimes(result)

	if result.LockSpinTimes > 0 and not self.firstRefreshInfo then

		self.view:RefreshSignInTimes(self.view.language.btnSignTips);
		return;
	end

	if result.SpinTimes > 0 then

		self.view:RefreshSignInTimes(string.format("%s(%s)", self.view.language.btnSign, result.SpinTimes));
	else
		self.view:RefreshSignInTimes(string.format("%s(%s)", CC.uu.ChipFormat(result.CostCnt), result.CostSpinTimes), true);
	end
end

function DailyTurntableViewCtr:SetFinalNums(finalNums)
	--设置每个层级箭头指向的扇形区域编号
	for i,v in ipairs(finalNums) do

		self.turntableData[i].finalNum = v;
	end

	self:StartRoll();
end

function DailyTurntableViewCtr:StartRoll()

	self.rollAllFinish = false;

	self.pointerInterpolation = 0;

	self.pointerAddAngle = 0;

	self.pointerDeltaAngle = nil;

	self.pointerShakeState = false;

	local curTb = self.curTurntable;

	curTb.canRoll = true;

	self.view:ShowRollEffect(self.curTbLayer);

	self.view:ShowPointerSparkEffect(true);

	CC.Sound.PlayHallEffect("turntable_roll");
end

function DailyTurntableViewCtr:RollFisish()

	-- self:ResetTurnTableData();

	if self.specialSpin then

		self:OnOpenRechargeView();

		self:ResetTurnTableData();

		return;
	end

	--第五层没有转盘,需要排除掉
	local layer = self.curAwardTbLayer < self.totalTbLayer and self.curAwardTbLayer or self.totalTbLayer - 1;

	if self.curTbLayer == layer then

		self:RollAllFinish();
	else
		self:RollToNextTbLayer();
	end;
end

function DailyTurntableViewCtr:RollAllFinish()

	for i = 1, self.curTbLayer do

		local tb = self.turntableData[i];

		self:ResetTurnTableData(tb);
	end

	self:ShowBlockEffect(true);

	self.view:ShowRewardEffect(true);

	self.view:ShowPointerSparkEffect(false);

	if self.curAwardTbLayer == self.totalTbLayer then

		self.view:MovePointer(self.curAwardTbLayer, function() self:ShowJackpotEffect(true); end);
	else
		self:ShowJackpotEffect(true);
	end
	self.curTbLayer = 1;

	self.curTurntable = self.turntableData[self.curTbLayer];

	self.view:DelayRun(1.5, function()

			self:ShowRewardView();

			self:SetCanClick(true);

			self:CheckCostArrowState();

			self:CheckBtnSpinTimes(self.resultInfo);

			self.view:ResetBtnSignInClick("signIn");
		end)

	self.rollAllFinish = true;
end

function DailyTurntableViewCtr:RollToNextTbLayer()

	self:ShowBlockEffect(true);

	self.view:ShowRewardEffect(true);

	self.view:ShowPointerSparkEffect(false);

	self.curTbLayer = self.curTbLayer + 1;

	self.curTurntable = self.turntableData[self.curTbLayer];

	self.view:MovePointer(self.curTbLayer, function() self:StartRoll() end, 1);
end

function DailyTurntableViewCtr:GetRollSpeed()

	local curTb = self.curTurntable;

	if self:CheckRollState() == StateTags.Last then

		return curTb.orgSpeed / curTb.speedDownMul;
	else
		return curTb.orgSpeed;
	end
end

function DailyTurntableViewCtr:CalcInterpolation(interpolation)

	if self:CheckRollState() == StateTags.Last then

		return QuadEaseOut(interpolation);
	else
		return interpolation;
	end
end

function DailyTurntableViewCtr:GetRoundDelta(tb)

	local curTb = tb or self.curTurntable;

	local delta = 0;

	if curTb.curNum > curTb.finalNum then

		delta = (curTb.blockCount - curTb.curNum + curTb.finalNum) * curTb.divideBlockAngle;
	else

		delta = (curTb.finalNum - curTb.curNum) * curTb.divideBlockAngle;
	end
	--控制偏移角度在(-180~180之间)
	delta = delta > 180 and (delta - curTb.perCircleAngle) or delta;

	return delta;
end

function DailyTurntableViewCtr:CheckRollState()

	local curTb = self.curTurntable;

	if curTb.rollCount == curTb.orgRollCount then
		return StateTags.First;

	elseif curTb.rollCount == 1 then
		return StateTags.Last;

	elseif curTb.rollCount == 0 then
		return StateTags.Finish;

	else
		return StateTags.Normal;
	end
end

function DailyTurntableViewCtr:ShowJackpotEffect(flag)

	if flag then

		if self.rewardInfo and self.rewardInfo.Type ~= self.awardType.JACKPOT then
			return;
		end
	end
	self.view:ShowJackpotRewardEffect(flag);
end

function DailyTurntableViewCtr:ShowBlockEffect(flag)

	if flag then

		self.view:ShowBlockEffect(true, self.curTbLayer, self.curTurntable.finalNum);
	else
		for i,v in ipairs(self.turntableData) do

			self.view:ShowBlockEffect(false, i);
		end
	end
end

function DailyTurntableViewCtr:ShowRewardView()

	if not self.rewardInfo then return end;

	if self.rewardInfo.Type == self.awardType.JACKPOT then
		local isJackpot = true;
		local param = {};
		param.rewardInfo = self.rewardInfo.Reward;
		param.rewardType = isJackpot and 2 or 1;
		CC.ViewManager.Open("TurntableRewardView", param);
		return;
	end

	local data = self.rewardInfo.Reward[1];
	CC.ViewManager.OpenRewardsView({items = {data},title = "DailyTurntable"});
end

function DailyTurntableViewCtr:ShowFinishImmediately()

	if self.rollAllFinish then return end

	self.view:CancelAllDelayRun();

	self.view:StopAllAction();

	CC.Sound.StopEffect();

	local aimLayer = self.rewardInfo.Round < self.totalTbLayer and self.rewardInfo.Round or (self.totalTbLayer-1);

	for i = 1, aimLayer do

		local tb = self.turntableData[i];

		tb.canRoll = false;

		local lastAngle = tb.perBeginAngle + self:GetRoundDelta(tb) - tb.orgAngle + tb.deltaAngle;

		self.view:RefreshTableAngle(i, lastAngle);

		self.view:ShowBlockEffect(true, i, tb.finalNum, true);

		self:ResetTurnTableData(tb);
	end

	self.view:ShowRewardEffect(true);

	self:ShowJackpotEffect(true);

	self.view:ShowPointerSparkEffect(false);

	if self.curAwardTbLayer == self.totalTbLayer then

		self.view:MovePointer(self.curAwardTbLayer, function()  end);
	else
		self.view:MovePointer(aimLayer, function()  end);
	end

	self.view:RefreshPointerArrowAngle(0);

	self.curTbLayer = 1;

	self.curTurntable = self.turntableData[self.curTbLayer];

	self.view:DelayRun(0.5, function()

			self:ShowRewardView();

			self:SetCanClick(true);

			self:CheckCostArrowState();
		end)

	self:CheckBtnSpinTimes(self.resultInfo);

	self.view:ResetBtnSignInClick("signIn");
end

function DailyTurntableViewCtr:OnOpenExplainView()

	local language = self.view.language;
	CC.ViewManager.Open("CommonExplainView",{title = language.explainTitle, content = language.explainContent});
end

function DailyTurntableViewCtr:OnOpenStoreView()

	local switchOn = self.activityDataMgr.GetActivityInfoByKey("NoviceGiftView").switchOn;

	if switchOn and CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false);

		CC.ViewManager.Open("SelectGiftCollectionView", {currentView = "NoviceGiftView", closeFunc = function() CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true); end});
	else
		local isOpen = false
		if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < 3 then
			isOpen = CC.SubGameInterface.OpenVipBestGiftView({needLevel = 3})
		end
		if not isOpen then
			CC.ViewManager.Open("StoreView");
		end
	end
end

function DailyTurntableViewCtr:OnShowArrowTips(index)

	local cfg = self.turntableCfg[index];

	CC.ViewManager.ShowTip(string.format(self.view.language.pointerLockTips, cfg.unLockLevel));
end

function DailyTurntableViewCtr:OnOpenRechargeView()

	local cancelCb = function()
		--不充值就重新请求转盘一次
		self:OnReqTurntableSpecialSpin();
	end

	if not CC.SelectGiftManager.CheckNoviceGiftCanBuy() then

		CC.ViewManager.Open("StoreView", {extraData = "DailySpinBuy", callback = cancelCb});

		return;
	end

	CC.ViewManager.Open("TurntableRechargeView", {cancelCallback = cancelCb});
end

function DailyTurntableViewCtr:OnOpenSpinTimesMsgBox()
	--付费转盘次数不足提示
	local sureCb = function()
		CC.SubGameInterface.OpenVipBestGiftView({needLevel = 3})
	end
	local box = CC.ViewManager.ShowMessageBox(self.view.language.spinTimesTips, sureCb);

	box:SetOkText(self.view.language.levelVip);
end

function DailyTurntableViewCtr:OnOpenNotEnoughMoneyMsgBox()
	--筹码不足提示
	local sureCb = function()
		CC.ViewManager.Open("StoreView");
	end
	local box = CC.ViewManager.ShowMessageBox(self.view.language.noMoneyTips, sureCb);

	box:SetOkText(self.view.language.gotoShopTips);
end

function DailyTurntableViewCtr:OnShowErrorTips(err)

	if err == 0 then return end;

	-- --除了318错误码,其他错误码返回都让界面可点击
	-- if err ~= CC.shared_en_pb.OpsLocked then

		self:SetCanClick(true);
	-- end

	if err == -1 then

		local tips = CC.LanguageManager.GetLanguage("L_Common").tip9;

		CC.ViewManager.ShowTip(tips);
	end
end

function DailyTurntableViewCtr:SetCanClick(flag)

	self.view:SetCanClick(flag);

	CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, flag);
end

function DailyTurntableViewCtr:OnFocusIn()

	--充值vip礼包成功后关闭奖励弹窗再转动转盘
	if not self.specialSpin or not self.purchaseVIP then return end;

	self:OnReqTurntableSpecialSpin();
end

function DailyTurntableViewCtr:ReqRankRecord()
	if self.getRankData then return end
	CC.Request("ReqDailySpinJPRank")
end

function DailyTurntableViewCtr:OnDailySpinJPRankRsp(err, result)
	-- log("err = ".. err.."  "..CC.uu.Dump(result,"ReqDailySpinJPRank",10))
	if err == 0 then
		self.getRankData = true
		self.view:InitInfo(result.Ranks)
	end
end

function DailyTurntableViewCtr:OnDailySpinJackpotRsp(err, result)

	if err == 0 then
		self.view:RefreshJackpot(result.Jackpot, 15);
	end
end

function DailyTurntableViewCtr:OnDestroy()

	self:StopUpdate();

	self:UnRegisterEvent();
end

return DailyTurntableViewCtr