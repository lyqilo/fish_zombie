local CC = require("CC")
local LoginAwardView = CC.uu.ClassView("LoginAwardView")

function LoginAwardView:OnCreate()

	local DailyReward = CC.Player.Inst():GetDailyReward()
	local sign = CC.ConfigCenter.Inst():getConfigDataByKey("Sign")
	local data = {}
	data.awardList = {}
	self.quaternion = Quaternion()
	for i=1,12 do
		if i > 6 then
			data.awardList[i] = sign[i-6].Rewards[1].Count
		else
			data.awardList[i] = sign[i].Rewards[1].Count
		end
	end

	data.awardIndex = DailyReward.RandId

	self:Init(data)

	self:StartUpdate();

	self:BeginRoll();

	CC.LocalGameData.SetPopupState(false)
	CC.LocalGameData.SetNoticeState(false)	
	CC.LocalGameData.SetSignState(false)	
end

local function Lerp(a,b,t)
	return a + (b - a) * t;
end 

local function QuadEaseOut(time) 
    return -1 * time * (time - 2);
end

local function Linear(time)
	return time * 2 ;
end

local function QuadEaseIn(time) 
    return time * time;
end

function LoginAwardView:Update()
	if self.beginRoll then 
		local t;
		self.turntableT = self.turntableT + self.speed;
		if self.turntableT > 1 then 
			self.turntableT = 0;
			if self.rollState == 1 then 
				self.rollState = 2;
				self.easeFunc = Linear;
				self.aimRotation = -360;
				self.speedSlope = nil;
			elseif self.rollState == 2 then 
				self.rollState = 3;
				self.easeFunc = QuadEaseOut;
				self.aimRotation = -360 + (self.awardIndex - 1) * 30;
				self.speedSlope = nil;
			elseif self.rollState == 3 then
				self:EndRoll();
			end
		else
			t = self.easeFunc(self.turntableT);
			self.turntable.localRotation = self.quaternion:SetEuler(0,0,Lerp(0,self.aimRotation,t));

			if not self.speedSlope then
				self.speedSlope = t;
			else
				self.rollerSpeedMul = t - self.speedSlope;
				self.speedSlope = t;
			end

			self.rollerT = self.rollerT + self.rollerSpeed * self.rollerSpeedMul;
			self.roller.localRotation = self.quaternion:SetEuler(0,0,Lerp(self.aimRollerRotation1,self.aimRollerRotation2,self.rollerT));
			if self.rollerT > 1 then 
				self.rollerT = 0;
			end
		end
	elseif self.beginRoller then 
		self.rollerT = self.rollerT - self.rollerSpeed * 0.001;
		self.roller.localRotation = self.quaternion:SetEuler(0,0,Lerp(self.aimRollerRotation1,self.aimRollerRotation2,self.rollerT));
		if self.rollerT < 0 then 
			self.beginRoller = false;
			self.roller.localRotation = self.quaternion:SetEuler(0,0,0);
		end
	end

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
				self.numberList[i]:SetImage("loginAwardNumber_"..math.floor(Lerp(self.curNum[i],self.aimNum[i],self.numberT[i])));

				finish = false;
			end
		end

		if finish then 
			 self.beginShowNumber = false;
			 self:ShowNumberFinish();
		end
	end
end

function LoginAwardView:StartUpdate()
	UpdateBeat:Add(self.Update,self);
end

function LoginAwardView:StopUpdate()
	UpdateBeat:Remove(self.Update,self);
end

function LoginAwardView:Init(data)
	self.beginRoll = false;
	self.beginRoller = false;
	self.beginShowNumber = false;

	self.awardIndex = data.awardIndex;
	self.awardNumber = tostring(data.awardList[self.awardIndex]);

	self.turntableNode = self.transform:FindChild("TurntableNode");
	self.rollAnimator = self.turntableNode:GetComponent("Animator");
	self.rollAnimator.enabled = false;

	self.turntable = self.turntableNode:FindChild("Turntable");
	self.sparkEffect = self.turntableNode:FindChild("Spark");
	self.roller = self.turntableNode:FindChild("Roller");

	for i,v in ipairs(data.awardList) do
		self.turntableNode:FindChild("Turntable/Num"..i):GetComponent("NumberRoller").text = v;
	end

	-- self:AddClick(self.turntableNode:FindChild("BtnSpin"),function()
	-- 	self:BeginRoll();
	-- end)

	self.numberNode = self.transform:FindChild("NumberNode");
	self.numberNode:SetActive(false);

	self.numberFrame = self.numberNode:FindChild("Frame");

	local t = getmetatable("");
	self.strIndexFunc = t.__index;
	t.__index = function(t,i)
		return string.sub(t,i,i);
	end
end

function LoginAwardView:CreateNumber()
	local num = CC.uu.LoadHallPrefab("prefab", "LoginAwardViewNumber", self.numberNode);
	num.localPosition = Vector3(50 * #self.numberList,0,0);

	for i,v in ipairs(self.numberList) do 
		local pos = v.localPosition;
		pos.x = pos.x - 50;
		v.localPosition = pos;
	end
	table.insert(self.numberList,num);

	self.numberList[#self.numberList]:SetImage("loginAwardNumber_"..0);

	table.insert(self.numberT,0);

	table.insert(self.curNum,0);

	table.insert(self.aimNum,9);
end


function LoginAwardView:ShowNumber()
	CC.Sound.PlayLoopEffect("login_num.ogg");
	self.numberList = {};
	self.numberT = {};
	self.curNum = {};
	self.aimNum = {};

	self.numberNode:SetActive(true);
	self.numberFrame.localScale = Vector3(0,0,0);
	self:RunAction(self.numberFrame, {"scaleTo", 1, 1, 0.3, ease = CC.Action.EOutBack,function()
		self.beginShowNumber = true;

		self.curDigit = 1;
		self:CreateNumber();
	end})

	self.showNumberFinish = {};
	self.showDigitFinish = {};
	self.aimDigit = string.len(self.awardNumber);
end

function LoginAwardView:BeginRoll()
	CC.uu.DelayRun(1.3,function ()
		CC.Sound.PlayHallEffect("login_turn.ogg");
	end)
	if self.beginRoll then return end
	self.beginRoll = true;
	self.rollState = 1;					
	self.speed = 0.01;
	self.sparkEffect:SetActive(true);

	self.turntableT = 0;

	self.easeFunc = QuadEaseIn;
	self.aimRotation = -360;

	self.beginRoller = true;
	self.speedSlope = nil;

	self.rollerSpeed = 10;
	self.rollerSpeedMul = 0; 

	self.rollerT = 0;

	self.aimRollerRotation1 = 0; 
	self.aimRollerRotation2 = 15;
end

function LoginAwardView:EndRoll()
	self.beginRoll = false;
	self.sparkEffect:SetActive(false);

	self:ShowNumber();
end

function LoginAwardView:ShowNumberFinish()
	CC.Sound.StopExtendEffect("login_num.ogg")
	CC.Player.Inst():SetDailyReward(nil)
	CC.uu.DelayRun(1,function()
        CC.ViewManager.Replace("HallView")
    end)
end

function LoginAwardView:OnDestroy()
	self:StopUpdate();
	local t = getmetatable("");
	t.__index = self.strIndexFunc;
end

return LoginAwardView