
local CC = require("CC")

local ShakeViewCtr = CC.class2("ShakeViewCtr")

function ShakeViewCtr:ctor(view)
	self.Points = {}
	self.RangePoints = {}
	self.numberList = {}
	self.beginShowNumber = false
	self.view = view
	self.animList= {}

	self.ShakeData = CC.DataMgrCenter.Inst():GetDataByKey("ShakeData")
	self.bShakeState = false
	self.bReceiveState = false
end

function ShakeViewCtr:OnCreate()
	self:RegisterEvent()
end

function ShakeViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.Resp_Open,CC.Notifications.NW_ReqShakeOpen)
	CC.HallNotificationCenter.inst():register(self,self.Resp_Confirm,CC.Notifications.NW_ReqShakeConfirm)
	CC.HallNotificationCenter.inst():register(self,self.Resp_DailyRank,CC.Notifications.NW_ReqShakeDailyRank)
	CC.HallNotificationCenter.inst():register(self,self.Resp_WeeklyRank,CC.Notifications.NW_ReqShakeWeeklyRank)
end

function ShakeViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqShakeOpen)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqShakeConfirm)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqShakeDailyRank)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqShakeWeeklyRank)
end

local function Lerp(a,b,t)
	return a + (b - a) * t;
end 

--根据exits判断 当前是否可以摇色子
function ShakeViewCtr:BtnShakeState()
	if self.ShakeData.GetExistState() then
		self.view.Btn:SetActive(true)	
		self.view.BtnGray:SetActive(false)
		self.view.BtnClose:SetActive(false)
		self.view.csyyl_an:SetActive(true)
	else
		self.view.Btn:SetActive(false)
		self.view.BtnGray:SetActive(true)
		self.view.csyyl_an:SetActive(false)
	end
end

function ShakeViewCtr:Update()
	if self.beginShowNumber then
		local finish = true;
		for i = 1,self.curDigit,1 do
			if not self.showNumberFinish[i] then
				self.numberT[i] = self.numberT[i] + (i * 0.02 + 0.06);
				if self.numberT[i] >= 1 then
					if self.showDigitFinish[i] then
						self.curNum[i],self.aimNum[i] = self.awardNumber[i],self.awardNumber[i];
						self.showDigitFinish[i - 1] = true;
						self.numberList[i]:FindChild("Effect"):SetActive(true);
						self.showNumberFinish[i] = true;
					else
						if i == self.curDigit then
							if self.curDigit ~= self.aimDigit  then 
								self.curDigit = self.curDigit + 1;
								self:CreateNumber();
							else
								self.showDigitFinish[self.curDigit] = true;
							end
						end
					end
					self.numberT[i] = 0;		
				end

				if self.curNum[i] ~= "," then
					self.numberList[i]:SetImage("loginAwardNumber_"..math.floor(Lerp(self.curNum[i],self.aimNum[i],self.numberT[i])));
				else
					self.numberList[i]:SetImage("dh");
					self.numberList[i]:GetComponent("Image"):SetNativeSize()
				end

				finish = false;
			end
		end

		if finish then 
			 self.beginShowNumber = false;
		end
	else
		self.view:ShowConfirmBtn()
	end
end

function ShakeViewCtr:SaiziShake()
	for i=1,3 do
		self.animList[i] = {}
		local obj = self.view.Rewardpoint:FindChild(i)
		self.animList[i].dice = obj
	end	
end


function ShakeViewCtr:DicActionStart(succCb,errCb)
	self.succCb = succCb
	self.errCb = errCb
	self:SaiziShake()
	local playEffect = function()
		for i = 1, 3 do
			local dis = 70;
			self.view:RunAction(self.animList[i].dice,{
					{"delay", (i-1) * 0.1},
					{"localMoveBy", 0, dis, 0.15},
					{"localMoveBy", 0, -dis, 0.15},
					{"localMoveBy", 0, dis/2, 0.15},
					{"localMoveBy", 0, -dis/2, 0.15},
					{"localMoveBy", 0, dis/4, 0.15},
					{"localMoveBy", 0, -dis/4, 0.15},
				})		
		end
	end

	self.playEffectAction = self.view:RunAction(self.view, {
			{"delay", 0, onEnd = function() 
				playEffect();
			end},
			{"delay", 1, onEnd = function()
				if self.bShakeState then
					self.errCb()
					if self.playEffectAction then 
						self.view:StopAction(self.playEffectAction);
						self.playEffectAction = nil;
					end
				elseif self.bReceiveState then
					self.errCb(CC.shared_en_pb.AlreadyConfirm)
					if self.playEffectAction then 
						self.view:StopAction(self.playEffectAction);
						self.playEffectAction = nil;
					end
				elseif #self.Points > 0 then
					self.succCb()
					if self.playEffectAction then 
						self.view:StopAction(self.playEffectAction);
						self.playEffectAction = nil;
					end
				end
			end},
			loop = -1,
		})
end

--将数字转换成list
function ShakeViewCtr:NumToArray()
	local num = CC.uu.numberToStrWithComma(self.ShakeData.GetScore())
	local list = CC.uu.StrSplin(num)
	return list
end

--展示数字
function ShakeViewCtr:ShowNum(parent)
	self.beginShowNumber = true
	self.numberList = {}
	self.curDigit = 1
	self.showNumberFinish = {}
	self.numberT = {}
	self.showDigitFinish = {}
	self.curNum = {}
	self.aimNum = {}
	self.parent = parent
	self:CreateNumber()
	self.aimDigit = #self.awardNumber
end

--创建数字obj
function ShakeViewCtr:CreateNumber()
	local num = CC.uu.LoadHallPrefab("prefab", "ShakeViewNumber", self.parent)

	table.insert(self.numberList,num)
	self.numberList[#self.numberList]:SetImage("loginAwardNumber_"..1)

	table.insert(self.numberT,0)

	table.insert(self.curNum,0)

	table.insert(self.aimNum,9)
end

--设置色子点数
function ShakeViewCtr:ranInitNum(tran)
	for i=1,3 do
		local num = math.random(1,6)
		table.insert(self.RangePoints,num)
	end
end

--设置色子点数
function ShakeViewCtr:SetPoints(tran,tab)
	for i,v in ipairs(tab) do
		local value = tran:FindChild(i)
		self:Qiehuan(value,"cdx_tz_"..v)
	end
end

--判断是否为豹子
function ShakeViewCtr:IsLeopard()
	if self.Points[1] == self.Points[2] and self.Points[2] == self.Points[3] then
		return true
	else
		return false
	end
end

--图片切换
function ShakeViewCtr:Qiehuan(value,path)
	self.view:SetImage(value.gameObject, path);
end

function ShakeViewCtr:Req_Open()
	self.Points = {}
	self.bShakeState = false
	self.bReceiveState = false
	local playerId = CC.Player.Inst():GetLoginInfo().PlayerId
    local Id = tonumber(playerId)
	CC.Request("ReqShakeOpen",{PlayerId=Id})
end

function ShakeViewCtr:Req_Confirm()
	local data={}
	local PlayerId = CC.Player.Inst():GetLoginInfo().PlayerId
	data.PlayerId = tonumber(PlayerId)
	data.GameId = tonumber(self.view.GameId)
	CC.Request("ReqShakeConfirm",data)
end

function ShakeViewCtr:Req_DailyRank()
	CC.Request("ReqShakeDailyRank")
end

function ShakeViewCtr:Req_WeeklyRank()
	CC.Request("ReqShakeWeeklyRank")
end

function ShakeViewCtr:Resp_Open(err,data)
	if err == 0 then
		--获取暗补点数成功
	 	self.ShakeData.SetShakeOpen(data)
		self.awardNumber = self:NumToArray()
		self.Points = self.ShakeData.GetPoints()
	elseif err == CC.shared_en_pb.AlreadyConfirm then
		--已经领取过暗补奖励
		self.Points = self.RangePoints
		self.bReceiveState = true
	else
		--摇骰子失败或超时
		self.Points = self.RangePoints
		self.bShakeState = true
	end
end

function ShakeViewCtr:Resp_Confirm(err,data)
	if err == 0 then
		--领取摇摇乐奖励成功
		self.view:RewardClose();
	elseif err == CC.shared_en_pb.AlreadyConfirm then
		--已领取奖励
		self.view:RewardFail(CC.shared_en_pb.AlreadyConfirm)
	else
		--领取摇摇乐奖励失败
		self.view:RewardFail();
 	end
end

function ShakeViewCtr:Resp_DailyRank(err,data)
	 if err == 0 then
 		self.ShakeData.SetRankData(1,data)
		CC.ViewManager.Open("ShakeRankView")
	end
end

function ShakeViewCtr:Resp_WeeklyRank(err,data)
	if err == 0 then	
 		self.ShakeData.SetRankData(2,data)
 	end
end

function ShakeViewCtr:SetCanClick(flag)
	self._canClick = flag;
end

function ShakeViewCtr:ActionIn(tran)
	self:SetCanClick(false)
    tran.size = Vector2(3000, 3000)
    tran.localScale = Vector3(0.5,0.5,1)
    self.view:RunAction(tran, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true)
    	end})
end

function ShakeViewCtr:OnDestroy()
	self:unRegisterEvent()
	self.view = nil
end

return ShakeViewCtr