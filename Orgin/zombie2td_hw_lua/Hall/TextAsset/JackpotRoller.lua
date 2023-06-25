local CC = require("CC")
local JackpotRoller = CC.class2("JackpotRoller")
local M = JackpotRoller

--[[
jp滚动数字
@param
num:初始数值
textNode:文本组件节点

可选参数：
state:是否开始滚动，默认开始
rollSecond:奖池滚动间隔

创建：
self.jpRoller = CC.ViewCenter.JackpotRoller.new()
self.jpRoller:Create(param)

数值更新函数:
self.jpRoller:UpdateGoldPool(num)

更换文本组件节点：
self.jpRoller:ChangeTextNode(node)
]]

function M:Create(param)
	
	self.param = param or {}
	--奖池滚动间隔
	self.rollSecond = param.rollSecond or (600 * 5)
	--文本组件节点
	self.numText = self.param.textNode
	--多个不同奖池
	self.JpData = param.JpData or {}
	--起始滚动百分比
	self.orgPercent = 0.95
	
	local state = true
	if param.state ~= nil then
		state = param.state
	end
	self:InitGameJackpots(param.num or 0, state, param.id or 1)
end

function M:InitGameJackpots(num,bState,id)
	self:UpdateGoldPool(num,id)
	if bState then
		self:RollGoldPool(id)
	end
end

function M:UpdateGoldPool(num,id)

	local param = self:GetJackpotParam(id)
	
	if num == 0 then
		if self.numText then
			self.numText.text = 0
		end
		param.loadingOver = false
		if self.timer then
			self.timer:Stop();
		end
	else
		if not param.curNum then
			param.curNum = math.ceil(num * self.orgPercent)
		end
		param.loadingOver = true
		param.goldValue =  math.ceil(param.curNum)
		param._dstGoldValue =  math.ceil(num)
		param._delayGoldvalue = math.ceil((param._dstGoldValue -  param.goldValue)/self.rollSecond)
		self:RollGoldPool(id)
	end
end

function M:RollGoldPool(id)
	local param = self:GetJackpotParam(id)
	
	if self.timer then
		self.timer:Stop();
	end
	self.timer = Timer.New(function ()
		if param.loadingOver then
			param.curNum = param.curNum + param._delayGoldvalue
			if param.curNum > param._dstGoldValue then
				param.curNum = param._dstGoldValue
			end
			if self.numText then
				self.numText.text = CC.uu.numberToStrWithComma(param.curNum)
			end
		end
	end, 0.1, self.rollSecond);
	self.timer:Start();
end

function M:ChangeTextNode(node,id)

	local param = self:GetJackpotParam(id)
	self.numText = node
	self.numText.text = CC.uu.numberToStrWithComma(param.curNum or 0)
end

function M:GetJackpotParam(id)
	local groupId = id or 1
	if not self.JpData[groupId] then
		self.JpData[groupId] = {}
	end
	return self.JpData[groupId]
end

function M:GetJackpotData()
	return self.JpData
end

function M:StopRoller()
	if self.timer then
		self.timer:Stop();
	end
end

function M:Destroy()
	self.numText = nil
	if self.timer then
		self.timer:Stop();
		self.timer = nil;
	end
end

return JackpotRoller