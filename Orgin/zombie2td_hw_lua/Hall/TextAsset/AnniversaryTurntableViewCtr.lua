local CC = require("CC")
local AnniversaryTurntableViewCtr = CC.class2("AnniversaryTurntableViewCtr")

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

function AnniversaryTurntableViewCtr:ctor(view,param)
	self:InitVar(view, param)
end

function AnniversaryTurntableViewCtr:OnCreate()
	self:InitData();

	self:StartUpdate();

	self:RegisterEvent();

	self:OnReqTaskList()

	self:OnReqGoldOwnerList()

end

function AnniversaryTurntableViewCtr:InitVar(view, param)

	self.view = view
	--转盘配置
	self.turntableCfg = {
		[1] = {
			orgDeltaAngle = 22.5,
			blockItems = {},
			orgSpeed = 1.0,
			unLockLevel = 0,
			pointerSpeed = 8;
		},
		[2] = {
			orgDeltaAngle = 0,
			blockItems = {},
			orgSpeed = 1.0,
			unLockLevel = 0,
			pointerSpeed = 6;
		},
	}
	--转盘层级数据
	self.turntableData = {};
	--转盘各层箭头
	self.arrowList = {};
	--中奖类型
	self.awardType = {
		ARROW = 0,
		AWARD = 1,
		SPECIAL = 2,
		BIGAWARD = 3,
	}
	--当前转盘层级
	self.curTbLayer = 1;
	--转盘总层级
	self.totalTbLayer = 3;
	--当前中奖的层级
	self.curAwardTbLayer = 0;
	--当前转盘对象
	self.curTurntable = nil;

	--随机偏移角度的系数(保证不随机到两个扇形的正中间)
	self.deltaAngleMul = 4/5;
	--每次请求的数据
	self.resultInfo = nil;
	--每次转盘获奖数据(单独保存,避免resultInfo被其他请求覆盖导致没有获奖数据)
	self.rewardInfo = nil;

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
	self.CsvConfig = CC.ConfigCenter.Inst():getConfigDataByKey("AnniversaryTurntable")
	self.stageConfig = {{},{}}
	--self.turntableBlockCfg = CC.ConfigCenter.Inst():getConfigDataByKey("AnniversaryTurntable");

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");

	--标记当前转动类型，1:抽1次，2:抽多次
	self.spinType = 1
	--记录当前已转次数
	self.curSpinTimes = 0
	--连抽时总共要转次数
	self.totalSpinTimes = 0
	--记录中奖信息
	self.recordInfo = {}
	self.curRecordType = 1
	--记录任务列表信息
	self.taskInfo = nil
	--活动阶段1、2阶段奖励不一样
	self.nowStage = nil
	--金牌得主列表
	self.goldOwnerList = {}
	--免费抽奖次数
	self.freeCount = 0
end

function AnniversaryTurntableViewCtr:InitData()
	--转化转盘的配置
	self:FormatTbCfg()

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
		--中间转动速度减少
		tb.middleSpeedDown = 0.3
		--衔接最后一圈的减速系数(逐渐减速)
		tb.speedDownMul = 1.5;
		--当前剩余转动圈数
		tb.rollCount = 3;
		--初始需要完成的圈数
		tb.orgRollCount = 3;
		--每一圈转多少角度
		tb.perCircleAngle = 360;
		--转盘均分的区域数量
		tb.blockCount = #v.blockItems;
		--均分的区域角度
		tb.divideBlockAngle = tb.perCircleAngle / tb.blockCount;
		--转盘原始角度
		tb.orgAngle = 0 -- -tb.divideBlockAngle / 2;

		tb.orgDeltaAngle = v.orgDeltaAngle
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

function AnniversaryTurntableViewCtr:FormatTbCfg()
	for k,v in ipairs(self.CsvConfig) do
		local index = tonumber(v.Id) - (tonumber(v.Stage)-1)*13
		self.stageConfig[v.Stage][index] = v
	end
	if not self.nowStage then
		self:GetActStage()
	end
	self.turntableBlockCfg = self.stageConfig[self.nowStage]
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

			if self.propCfg[v.PropConfigId] then
				--奖励图标
				tb.iconImg = self.propCfg[v.PropConfigId].Icon;
			end

			table.insert(tbCfg, tb);
		end
	end
end

function AnniversaryTurntableViewCtr:GetActStage()
	
	if self:CheckActStage() then
		self.nowStage = 2
	else
		self.nowStage = 1
		self.view:StartTimer("stageTimer",1,function ()
			if self:CheckActStage() then
				self.nowStage = 2
				self.view:StopTimer("stageTimer")
				self:InitData()
			end
		end,-1)
	end
	
end

--检测是否活动第二阶段，第二阶段返回true
function AnniversaryTurntableViewCtr:CheckActStage()
	local date = CC.TimeMgr.GetTimeInfo()
	if date then
		if (date.month >= 10 and date.day >= 7) or date.month >= 11 then
			return true
		end
	end
	return false
end

function AnniversaryTurntableViewCtr:ResetTurnTableData(tb)

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

function AnniversaryTurntableViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnTaskListRsp,CC.Notifications.NW_ReqGetLuckyRouletteTaskInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnSpinRsp,CC.Notifications.NW_ReqGetLuckyRouletteResult)
	CC.HallNotificationCenter.inst():register(self, self.OnChangeSelfInfo, CC.Notifications.changeSelfInfo)
	CC.HallNotificationCenter.inst():register(self, self.OnPushLuckyRoulette, CC.Notifications.OnPushLuckyRoulette)
	CC.HallNotificationCenter.inst():register(self,self.OnRewardRecordRsp,CC.Notifications.NW_ReqGetLuckyRouletteRewardRecord)
	CC.HallNotificationCenter.inst():register(self,self.OnTaskRewardRsp,CC.Notifications.NW_ReqGetLuckyRouletteTaskReward)
	CC.HallNotificationCenter.inst():register(self,self.OnGoldOwnerListRsp,CC.Notifications.NW_ReqGetGoldOwnerList)
	
end

function AnniversaryTurntableViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function AnniversaryTurntableViewCtr:StartUpdate()

	UpdateBeat:Add(self.Update,self);
end

function AnniversaryTurntableViewCtr:StopUpdate()

	UpdateBeat:Remove(self.Update,self);
end

function AnniversaryTurntableViewCtr:Update()

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
	curTb.speed = self:GetRollSpeed()
	curTb.interpolation = Mathf.Clamp(curTb.interpolation + curTb.speed * Time.deltaTime, 0, 1)
	local t = self:CalcInterpolation(curTb.interpolation);
	local tempAngle = Mathf.Lerp(curTb.tmpBeginAngle, curTb.tmpEndAngle, t);
	self.view:RefreshTableAngle(self.curTbLayer, tempAngle);
	
	--指针摆动状态判断
	local tempValue = tempAngle + self.pointerDeltaAngle - curTb.tmpBeginAngle - self.pointerAddAngle + curTb.orgDeltaAngle
	if tempValue >= curTb.divideBlockAngle then
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

			self:RollFinish();

			return;
		end

		curTb.tmpBeginAngle = curTb.tmpEndAngle;

		curTb.tmpEndAngle = curTb.tmpBeginAngle + curTb.perCircleAngle + lastDeltaAngle;

		-- logError("layer:"..self.curTbLayer.."   begin:"..curTb.tmpBeginAngle.."  end:"..curTb.tmpEndAngle.."  deltaAngle:"..curTb.deltaAngle)
	end
end

function AnniversaryTurntableViewCtr:OnChangeSelfInfo(props,source)
	-- if source ~= CC.shared_transfer_source_pb.TS_Anniversary_Turntable then return end
	for _,v in ipairs(props) do
		local count = v.Count
		if v.ConfigId == CC.shared_enums_pb.EPC_Props_81 then
			self.view:UpdateRaffleTickets(count)
		--elseif v.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
			--self.view:UpdateChip(count)
		--elseif v.ConfigId == CC.shared_enums_pb.EPC_New_GiftVoucher then
			--self.view:UpdateGiftVoucher(count)
		end
	end
end

function AnniversaryTurntableViewCtr:ChangePropInfo()
	self.view:UpdateChip(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
	self.view:UpdateGiftVoucher(CC.Player.Inst():GetSelfInfoByKey("EPC_New_GiftVoucher"))
end

function AnniversaryTurntableViewCtr:OnPushLuckyRoulette(data)
	if data.BigReward == 1 then
		--中金牌大奖的时候，刷新一次记录
		self:OnReqGoldOwnerList()
		if self.curRecordType == 1 then
			self:OnReqRewardRecord(1)
		end
	end
	self.view:ShowMarquee(data)
end

function AnniversaryTurntableViewCtr:OnReqTaskList()
	CC.Request("ReqGetLuckyRouletteTaskInfo");
end

function AnniversaryTurntableViewCtr:OnTaskListRsp(err,result)
	if err ~= 0 then
		logError("ReqTaskList error:"..err)
		self:OnShowErrorTips(err)
		return
	end
	CC.uu.Log(result,"OnTaskListRsp:",1)

	self.freeCount = result.FreeCount
	if result.FreeCount > 0 then
		self.view:SetBtnFreeState()
	end

	self.taskInfo = {}
	for k,v in ipairs(result.TaskList) do
		if not self.taskInfo[v.TaskType] then
			self.taskInfo[v.TaskType] = v
		else
			--流水任务完成一个阶段后显示下一个阶段
			if v.TaskType == 1 then
				if self.taskInfo[v.TaskType].Status == 2 then
					self.taskInfo[v.TaskType] = v
				end
			end
		end
	end
	self.view:RefreshTaskList(self.taskInfo)
end

function AnniversaryTurntableViewCtr:OnReqGoldOwnerList()
	CC.Request("ReqGetGoldOwnerList")
end

function AnniversaryTurntableViewCtr:OnGoldOwnerListRsp(err,result)
	if err ~= 0 then
		logError("OnReqGoldOwnerList error:"..err)
		self:OnShowErrorTips(err)
		return
	end
	--CC.uu.Log(result,"GoldOwnerList",1)
	self.goldOwnerList = {}
	for k,v in ipairs(result.PlayerBaseList) do
		table.insert(self.goldOwnerList,v)
	end
	self.view:RefreshGoldOwnerList(result)
end

function AnniversaryTurntableViewCtr:OnReqTaskReward(index)
	local data = {}
	data.TaskType = index
	data.TaskAmount = self.taskInfo[index].TaskAmount
	CC.Request("ReqGetLuckyRouletteTaskReward",data)
end

function AnniversaryTurntableViewCtr:OnTaskRewardRsp(err,result)
	if err ~= 0 then
		logError("OnReqTaskReward error:"..err)
		self:OnShowErrorTips(err)
		return
	end
	log(CC.uu.Dump(result, "OnTaskRewardRsp:"))
	if result.Status == 0 then
		CC.ViewManager.ShowTip(self.view.language.taskNotFinish)
	elseif result.Status == 1 then
		self.view:OpenRewardsView({items = result.Rewards, title = self.view.language.title, splitState = true});
	elseif result.Status == 2 then
		CC.ViewManager.ShowTip(self.view.language.canNotGet)
	end
	self:OnReqTaskList()

end

function AnniversaryTurntableViewCtr:OnReqRewardRecord(type)
	self.curRecordType = type
	local data = {}
	data.PlayerId = type == 1 and 0 or tonumber(CC.Player.Inst():GetSelfInfoByKey("Id"))
	data.From = 0
	data.To = 29
	CC.Request("ReqGetLuckyRouletteRewardRecord",data);
end

function AnniversaryTurntableViewCtr:OnRewardRecordRsp(err,result)
	if err ~= 0 then
		logError("ReqRewardRecord error:"..err)
		self:OnShowErrorTips(err)
		return
	end
	CC.uu.Log(result,"RewardRecordResp"..self.curRecordType..":",1)
	self.recordInfo[self.curRecordType] = result
	self.view:RefreshRewardRecord(self.curRecordType,result)
end

--0,免费，numType，次数
function AnniversaryTurntableViewCtr:OnReqTurntableSpin(numType)
	--免费抽奖次数
	if numType == 0 then
		if self.freeCount <= 0 then
			self.view:SetBtnFreeState()
			return
		end
	else
		--检查龙鳞石
		if CC.Player.Inst():GetSelfInfoByKey("EPC_Props_81") < numType then
			CC.ViewManager.ShowTip(self.view.language.notEnough)
			CC.ViewManager.Open("CelebrationTipView", {Stone = true})
			return
		end
	end
	local count = numType
	if numType == 1 then
		self.spinType = 1
	elseif numType > 1 then
		self.spinType = 2
	else
		count = 1
		self.spinType = 3
	end
	self:SetCanClick(false)
	self.view.moreSpinPanel:SetActive(false)
	local data = {}
	data.Count = count
	data.IsFree = numType == 0
	CC.Request("ReqGetLuckyRouletteResult",data)
end

function AnniversaryTurntableViewCtr:OnSpinRsp(err,result)
	if err ~= 0 then
		self:OnShowErrorTips(err)
		return
	end
	CC.uu.Log(result, "----OnSpinRsp----",1)
	
	if not result.Results or #result.Results < 1 then self:SetCanClick(true) return end
	if self.spinType == 3 then
		self.freeCount = self.freeCount - 1
	end

	local rewardList = {}
	for k,v in ipairs(result.Results) do
		local data = {}
		data.Type = self.turntableBlockCfg[v.Index+1].Type
		data.Index = v.Index + 1
		data.Round = v.Level
		data.Offset = self.turntableBlockCfg[v.Index+1].Offset
		data.Reward = {{
				ConfigId = v.RewardId,
				Count = v.RewardNum,
			}}
		table.insert(rewardList,data)
	end
	self.resultInfo = rewardList
	self.view:ResetBtnClick(self.spinType)
	self:OnSpinChanged(rewardList)
end


function AnniversaryTurntableViewCtr:OnSpinChanged(rewardList)
	self.curSpinTimes = self.curSpinTimes + 1
	if self.spinType == 2 then
		self.view:SetBtnTenSkipText()
	end
	self.rewardInfo = rewardList

	local rewardInfo = rewardList[self.curSpinTimes]

	self:ShowJackpotEffect(false)
	self:ShowBlockEffect(false)
	self.view:RefreshPointerPos(1)
	self.curAwardTbLayer = rewardInfo.Round

	local finalNums = {}
	local round = rewardInfo.Round < self.totalTbLayer and rewardInfo.Round or (self.totalTbLayer-1)

	for i = 1,round do
		local num;
		if i  == rewardInfo.Round then
			num = rewardInfo.Offset
		else
			local randomIndex = math.random(1,#self.arrowList[i])
			num = self.arrowList[i][randomIndex]
		end
		table.insert(finalNums,num)
	end
	self:SetFinalNums(finalNums)
end

function AnniversaryTurntableViewCtr:SetFinalNums(finalNums)
	--设置每个层级箭头指向的扇形区域编号
	for i,v in ipairs(finalNums) do

		self.turntableData[i].finalNum = v;
	end

	self:StartRoll();
end

function AnniversaryTurntableViewCtr:StartRoll()

	self.rollAllFinish = false;

	self.pointerInterpolation = 0;

	self.pointerAddAngle = 0;

	self.pointerDeltaAngle = nil;

	self.pointerShakeState = false;

	local curTb = self.curTurntable;

	curTb.canRoll = true;

	self.view:ShowRollEffect(self.curTbLayer);

	self.view:ShowPointerSparkEffect(true);
	self.view:SpinHideOther(true)
	CC.Sound.PlayHallEffect("anniversaryTurntable")
end

function AnniversaryTurntableViewCtr:RollFinish()
	--第五层没有转盘,需要排除掉
	local layer = self.curAwardTbLayer < self.totalTbLayer and self.curAwardTbLayer or self.totalTbLayer - 1;
	if self.curTbLayer == layer then
		self:RollAllFinish()
	else
		self:RollToNextTbLayer()
	end
end

function AnniversaryTurntableViewCtr:RollAllFinish()
	for i = 1, self.curTbLayer do

		local tb = self.turntableData[i];

		self:ResetTurnTableData(tb);
	end

	self:ShowBlockEffect(true);
	self.view:ShowRewardEffect(true);
	self.view:ShowPointerSparkEffect(false);

	if self.curAwardTbLayer == self.totalTbLayer then
		self.view:MovePointer(self.curAwardTbLayer,function () self:ShowJackpotEffect(true) end)
	else
		self:ShowJackpotEffect(true)
	end
	self.curTbLayer = 1
	self.curTurntable = self.turntableData[self.curTbLayer]
	if self.spinType == 2 and self.curSpinTimes < self.totalSpinTimes then
		self.view:DelayRun(2,function()
				self:OnSpinChanged(self.rewardInfo)
			end)
	else
		self.rollAllFinish = true
		self.curSpinTimes = 0
		self.view:DelayRun(1.5,function()
				self:ShowRewardView()
				self:SetCanClick(true)
				self:ResetSpinBtn()
			end)
	end
end

function AnniversaryTurntableViewCtr:RollToNextTbLayer()
	self:ShowBlockEffect(true)
	self.view:ShowRewardEffect(true)
	self.view:ShowPointerSparkEffect(false)
	self.curTbLayer = self.curTbLayer + 1
	self.curTurntable = self.turntableData[self.curTbLayer]
	self.view:MovePointer(self.curTbLayer,function ()
		self:StartRoll()
	end,1)
end

function AnniversaryTurntableViewCtr:GetRollSpeed()

	local curTb = self.curTurntable;

	if self:CheckRollState() == StateTags.First then
		return curTb.orgSpeed;
	elseif self:CheckRollState() == StateTags.Last then
		return Mathf.Clamp(curTb.speed / curTb.speedDownMul, 0.2, curTb.orgSpeed)
	else
		return Mathf.Clamp(curTb.speed - 0.05, curTb.orgSpeed - curTb.middleSpeedDown, curTb.orgSpeed)
	end
end

function AnniversaryTurntableViewCtr:CalcInterpolation(interpolation)

	if self:CheckRollState() == StateTags.Last then

		return QuadEaseOut(interpolation);
	else
		return interpolation;
	end
end

function AnniversaryTurntableViewCtr:GetRoundDelta(tb)

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
function AnniversaryTurntableViewCtr:CheckRollState()

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

function AnniversaryTurntableViewCtr:ShowJackpotEffect(flag)

	if flag then
		local isShow = false
		if self.rewardInfo then
			for _,v in ipairs(self.rewardInfo) do
				if v.Type == self.awardType.BIGAWARD then
					isShow = true
					break
				end
			end
		end
		if not isShow then return end
	end
	self.view:ShowJackpotRewardEffect(flag);
end

function AnniversaryTurntableViewCtr:ShowBlockEffect(flag)

	if flag then

		self.view:ShowBlockEffect(true, self.curTbLayer, self.curTurntable.finalNum);
	else
		for i,v in ipairs(self.turntableData) do

			self.view:ShowBlockEffect(false, i);
		end
	end
end

function AnniversaryTurntableViewCtr:ShowRewardView()

	if not self.rewardInfo then return end;

	if self.curRecordType == 2 then
		self:OnReqRewardRecord(2)
	end
	self:ChangePropInfo()
	local data = {}
	for _,v in ipairs(self.rewardInfo) do
		table.insert(data,v.Reward[1])
	end
	self.view:OpenRewardsView({items = data,title = self.view.language.title,splitState = self.totalSpinTimes <= 10});
	self.view:SpinHideOther(false)
end

function AnniversaryTurntableViewCtr:ShowFinishImmediately()
	
	if self.rollAllFinish or self.curSpinTimes <= 0 then return end
	
	self.view:CancelAllDelayRun()
	self.view:StopAllAction()
	CC.Sound.StopEffect()
	local aimLayer = self.rewardInfo[self.curSpinTimes].Round < self.totalTbLayer and self.rewardInfo[self.curSpinTimes].Round or (self.totalTbLayer-1)
	for i = 1, aimLayer do
		local tb = self.turntableData[i]
		tb.canRoll = false
		local lastAngle = tb.perBeginAngle + self:GetRoundDelta(tb) - tb.orgAngle + tb.deltaAngle
		self.view:RefreshTableAngle(i, lastAngle);
		self.view:ShowBlockEffect(true,i,tb.finalNum,true)
		self:ResetTurnTableData(tb)
	end
	
	self.view:ShowRewardEffect(true)
	self:ShowJackpotEffect(true)
	self.view:ShowPointerSparkEffect(false)
	
	if self.curAwardTbLayer == self.totalTbLayer then
		self.view:MovePointer(self.curAwardTbLayer, function()  end);
	else
		self.view:MovePointer(aimLayer, function()  end);
	end
	
	self.view:RefreshPointerArrowAngle(0)
	self.curTbLayer = 1
	self.curSpinTimes = 0
	self.curTurntable = self.turntableData[self.curTbLayer]
	self.view:DelayRun(0.5,function ()
			self:ShowRewardView()
			self:SetCanClick(true)
		end)
	self:ResetSpinBtn()
end

function AnniversaryTurntableViewCtr:OnShowErrorTips(err)
	if err == 0 then return end
	self:SetCanClick(true)
	if err == -1 then
		local tips = CC.LanguageManager.GetLanguage("L_Common").tip9
		CC.ViewManager.ShowTip(tips)
	end
end

function AnniversaryTurntableViewCtr:ResetSpinBtn()
	--恢复抽奖按钮
	self.view:ResetBtnClick()
end

function AnniversaryTurntableViewCtr:SetCanClick(flag)
	self.view:SetCanClick(flag)
end

function AnniversaryTurntableViewCtr:OnDestroy()

	self:StopUpdate();

	self:UnRegisterEvent();
end

return AnniversaryTurntableViewCtr