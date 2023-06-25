
---------------------------------
-- region NumberRoller.lua    -
-- Date: 2019.8.9        -
-- Desc: 通用数字滚动特效  -
-- Author: Bin        -
---------------------------------

local CC = require("CC")

local NumberRoller = CC.class2("NumberRoller")

function NumberRoller:Create(param)

	self:InitVar(param);
	self:InitContent();
	self:StartUpdate();
end

function NumberRoller:InitVar(param)

	self.param = param;

	self._actions = {};

	self.numberList = {};

	self.numberLength = 0;

	self.awardNumList = {};

	self.allFinish = false;
end

function NumberRoller:InitContent()

	local num = CC.uu.numberToStrWithComma(self.param.number);
	self.awardNumList = CC.uu.StrSplin(num);

	self.numberLength = #self.awardNumList;

	self.transform = CC.uu.LoadHallPrefab("prefab", "NumberRoller", self.param.parent.transform);

	local actionQue = {};
	local timeDelta = 0.3;

	for i, awardNum in ipairs(self.awardNumList) do
		local action = {"delay", timeDelta, function() self:CreateNumber(i, awardNum) end};
		table.insert(actionQue, action);
	end

	self:RunAction(self.transform, actionQue);
end

function NumberRoller:CreateNumber(index, awardNum)

	local t = {};

	t.number = CC.uu.LoadHallPrefab("prefab", "RollNumberImg", self.transform);

	t.effect = t.number:FindChild("Effect");

	t.deltaT = 0;

	t.curNum = 0;

	t.aimNum = 9;

	t.curIndex = 0;

	t.awardNum = awardNum;

	t.finish = false;

	t.roundCount = self.numberLength - index;

	table.insert(self.numberList, t);
end

function NumberRoller:StartUpdate()

	FixedUpdateBeat:Add(self.Update,self);
end

function NumberRoller:StopUpdate()

	FixedUpdateBeat:Remove(self.Update,self);
end

function NumberRoller:Update()

	if #self.numberList == 0 then return end

	if self.allFinish then return end;

	local finish = true;

	for i,v in ipairs(self.numberList) do

		if not v.finish then

			if v.deltaT < 1 then

				v.deltaT = v.deltaT + 2.4 * Time.deltaTime;

				local index = math.floor(Mathf.Lerp(v.curNum, v.aimNum, v.deltaT));

				if v.curIndex ~= index then
					v.curIndex = index;
					v.number:SetImage("loginAwardNumber_"..index);
				end
			else
				if v.roundCount == 0 then

					v.finish = true;

					if v.awardNum == "," then
						v.number:SetImage("dh");
						v.number:GetComponent("Image"):SetNativeSize();
					else
						v.number:SetImage("loginAwardNumber_"..v.awardNum);
					end

					v.effect:SetActive(true);
					CC.Sound.PlayHallEffect("number_roll");
				end

				v.deltaT = 0;
				v.roundCount = v.roundCount - 1;
			end

			finish = false;
		end
	end

	self.allFinish = finish;

	if self.allFinish and self.param.callback then
		CC.uu.DelayRun(0.6,function ()
			self.param.callback();
		end)
	end
end

function NumberRoller:RunAction(target, action)

	local tween = CC.Action.RunAction(target, action)
	table.insert(self._actions,tween)
	return tween
end

function NumberRoller:StopAction(tween, beComplete)

	for key, action in pairs(self._actions) do
		if tween == action then
			action:Kill(beComplete or false)
			self._actions[key] = nil
			break
		end
	end
end

function NumberRoller:StopAllAction(beComplete)

	for _, action in pairs(self._actions) do
        action:Kill(beComplete or false)
    end
    self._actions = {}
end

function NumberRoller:Destroy()

	self:StopAllAction();

	self:StopUpdate();

	CC.uu.destroyObject(self);
end

return NumberRoller