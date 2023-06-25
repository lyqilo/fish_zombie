--Author:AQ
--Time:2020年12月20日 15:55:03 Thursday
--Describe:

local CC = require "CC"

local M = CC.class2("SlotCommonLatternItem")

function M:ctor(go,param)
	self:Init(go,param);
	self:Reset(true);
end

function M:Init(go,param)
	self.param = param;
	self.transform = go.transform;
	self.textContent = self.transform:FindChild("TextContent");
	self.contentHeight = self.textContent.height;
	self.roadCount = 1;---弹道
	self.minYValue = self.param.minYValue or -120;--最顶部显示位置
	self.runTime = 10;--跑完时间
end

function M:Refresh(info,index)
	self.textContent.text = info.content;
	local yValue = self.minYValue - index % self.roadCount * self.contentHeight;
	self.transform.localPosition = Vector3(0,yValue,0);
	local targetX = -(Screen.width + self.textContent.width);
	self.transform.gameObject:SetActive(true);
	self.action = CC.Action.RunAction(self.transform,{"localMoveTo",targetX,yValue,self.runTime, ease=CC.Action.ELinear,function()
		self:Reset();
	end})
end

function M:Reset(initReset)
	self.transform.gameObject:SetActive(false);
	if self.action then
		self.action:Kill(false);
		self.action:Destroy();
		self.action = nil;
	end
	self.transform.localPosition = Vector3(0,0,0);
	self.textContent.text = "";
	if not initReset and self.recoveryFunc then
		self.recoveryFunc();
	end
end


return M