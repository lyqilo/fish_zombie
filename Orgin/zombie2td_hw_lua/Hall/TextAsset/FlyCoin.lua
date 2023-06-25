local CC = require("CC")
local FlyCoin = CC.class2("FlyCoin")

-- param.prefabName 预制体名称
-- param.parent	父节点
-- param.worldPos	金币开始坐标
-- param.aimPos	动画结束坐标
-- param.coinNum	创建几个预制体
-- param.callBack	回调

function FlyCoin:Create(param)
	self:InitVar(param)
end

function FlyCoin:InitVar(param)
	self.coinList = {}

	self.prefabName = param.prefabName
	self.parent = param.parent
	self.position = param.worldPos
	self.aimPosition = param.aimPos
	self.callBack = param.callBack

	self.coinNum = param.coinNum or 3
	self.deltaAngle = 360 / self.coinNum;
	self.initAngle = math.random(0,360);
	
	self.actionKey = {}

	self.timerKey = {}
	
	for i = 1, self.coinNum do
		local coin = CC.uu.LoadHallPrefab("prefab",self.prefabName,self.parent)
		coin.localScale = Vector3.one;
        coin.position = self.position;
        table.insert(self.coinList,coin);
        self:AppearAction(coin);
	end

	local key = CC.uu.DelayRun(0.5,function()
        for i,v in ipairs(self.coinList) do 
            local key = CC.uu.DelayRun(0.1 * (i - 1),function()
                self:MoveAction(i,v);
            end)
            table.insert(self.timerKey,key);
        end   
	end)
	table.insert(self.timerKey,key);

end

function FlyCoin:AppearAction(coin)
	local rad = math.rad(1) * (self.deltaAngle * (#self.coinList - 1) + self.initAngle);
    local radius = math.random(1,4);
    local baseX = self.position.x;
    local baseY = self.position.y;
    local aimX = baseX + radius * math.cos(rad);
    local aimY = baseY + radius * math.sin(rad);
    local key = self:RunAction(coin,{"to",0,100,0.3,function(value)
    	local t = value * 0.01;
    	coin.position = Vector3(baseX + (aimX - baseX) * t,baseY + (aimY - baseY) * t,0);
    end,ease = CC.Action.EOutSine});
    table.insert(self.actionKey,key);
end

function FlyCoin:MoveAction(index,coin)
	local baseX = coin.position.x;
    local baseY = coin.position.y;

    local aimX = self.aimPosition.x;
    local aimY = self.aimPosition.y;

    local offsetX = (aimX - baseX) * 0.5;
    local offsetY = aimY > baseY and -15 or 15;

    local key = self:RunAction(coin,{"to",0,100,0.7,function(value)
        local t = value * 0.01;
        local x = aimX + offsetX * (1 - t);
        local y = aimY + offsetY * (1 - t);
        coin.position = Vector3(baseX + (x - baseX) * t,baseY + (y - baseY) * t,0);

        local scale = 1 - 0.4 * t;
        coin.localScale = Vector3(scale,scale,scale);
    end,

	onEnd = function()
		coin:SetActive(false);
		if index == 1 and self.callBack then 
            self.callBack();
        end
		if index == self.coinNum then
			self:Destroy();
        end
    end});
    table.insert(self.actionKey,key);
end

function FlyCoin:RunAction(target, action)
	return CC.Action.RunAction(target, action)
end

function FlyCoin:StopAction(action, bComplete)
	if action then
		action:Kill(bComplete or false);
	end
end

function FlyCoin:Destroy()
	for i,v in ipairs(self.actionKey) do 
		self:StopAction(v);
	end
	self.actionKey = nil;

    for i,v in ipairs(self.coinList) do 
        CC.uu.destroyObject(v);
    end   
    self.coinList = nil;

    for i,v in ipairs(self.timerKey) do 
        CC.uu.CancelDelayRun(v);
    end
    self.timerKey = nil;
end

return FlyCoin