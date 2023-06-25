local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local GoldPillar = GC.class2("ZTD_GoldPillar")

-- 显示的最大倍率
local MaxRatio = 80;
-- 宽度间隔
local WidthGap = -45;
-- 单个金币高度
local GoldHigh = 6;
-- 金币代表的倍率
local GoldRate = 2;
-- 金币柱增长速度（秒）
local GoldUpTime = 0.2;

function GoldPillar:ctor(_)
    self._pillars = {};
    self._readyList = {};
end

function GoldPillar:_cleanPillar(newPillar)
    local v = newPillar:FindChild("Content");
    local childCount = v.transform.childCount;
    if childCount > 0 then
        local removeList = {};
        for i = 0,childCount - 1 do
            local childV = v.transform:GetChild(i);
            table.insert(removeList, childV);
        end

        for _, removeObj in ipairs(removeList) do            
            ZTD.PoolManager.RemoveGameItem("ZTD_GoldPillar_Gold", removeObj);
        end    
    end    
end

function GoldPillar:Init(patchNode, battleView)
    self._patchNode = patchNode;
    for _, v in ipairs(self._pillars) do
        self:_cleanPillar(v.node);
		ZTD.Extend.StopAction(v.actionKey);
        ZTD.PoolManager.RemoveGameItem("ZTD_GoldPillar", v.node);
    end
    self._pillars = {};
    self._readyList = {};
	self._battleView = battleView;
end

function GoldPillar:PopTop()
	if self._pillars[1] then
		local oldp = self._pillars[1].node;
		local oldt = self._pillars[1].actionKey;
		table.remove(self._pillars, 1);		
		local spawn = {"spawn",
			{"localMoveBy", - WidthGap, 0, 0, 0.5},
			{"fadeToAll", 0, 0.5, onEnd = function ()		
				if tostring(oldp) ~= "null" then
					--ZTD.Extend.RunAction(oldp,{"fadeToAll", 255, 0});
					self:_cleanPillar(oldp);
					ZTD.PoolManager.RemoveGameItem("ZTD_GoldPillar", oldp);
					oldp = nil;
				end
			end}
		}
		ZTD.Extend.RunAction(oldp,{spawn});
		
		ZTD.Extend.StopAction(oldt);
		
		for _, v in ipairs(self._pillars) do
            --v.localPosition = Vector3(v.localPosition.x - WidthGap, v.localPosition.y, 0);
			ZTD.Extend.RunAction(v.node,{"localMoveBy", -WidthGap, 0, 0, 0.5});
        end 
	end
end

function GoldPillar:AddPillar(getRatio, money)
	if self._isRelease then
		return;
	end
	
    money = GC.uu.NumberFormat(money);
    local newPillar = ZTD.PoolManager.GetGameItem("ZTD_GoldPillar", self._patchNode);
	newPillar:SetActive(false);
	newPillar:SetActive(true);
	
    self:_cleanPillar(newPillar);
	ZTD.Extend.RunAction(newPillar,{"fadeToAll", 255, 0});

	local ratio = math.ceil(getRatio / GoldRate );
	
    if ratio > MaxRatio then
        ratio = MaxRatio;
	elseif ratio < 1 then
		ratio = 1;
    end
	
	-- 金币柱实际数值
    newPillar:FindChild("txt_gold").text = money;
	
	-- 设置背景宽度
	newPillar:FindChild("bg_txt").transform.width = 12 * string.len(money);
	
	local content = newPillar:FindChild("Content")
	local pdata = {};
	pdata.goldNum = 1;
	local function _plusOneGold()	
        local gold = ZTD.PoolManager.GetGameItem("ZTD_GoldPillar_Gold", content);
		gold.localPosition = Vector3(0, pdata.goldNum * -GoldHigh, 0);
		gold.localScale = Vector3.one
		newPillar.localPosition = Vector3(newPillar.localPosition.x, pdata.goldNum * GoldHigh, 0);
		pdata.goldNum = pdata.goldNum + 1;
    end
	

	
	local runX = #self._pillars * WidthGap;
	local runY = ratio * GoldHigh;
	
    newPillar.localPosition = Vector3(runX, 0, 0);
	
	local insertStuff = {"delay", GoldUpTime/ratio, onEnd = function ()
		_plusOneGold();
	end};

	local spawn = {}
	
	for i = 1, ratio do
		table.insert(spawn, insertStuff);
	end	
	
	local actionKey = ZTD.Extend.RunAction(newPillar, {spawn});
	
	newPillar.localScale = Vector3.one;
	
	
	pdata.node = newPillar;
	pdata.actionKey = actionKey;

    self._pillars[#self._pillars + 1] = pdata;
	
	if not self._co_timer then
		self._co_timer = ZTD.GameTimer.StartTimer( function()
			self:PopTop();
		end, 3, -1)		
		-- log("--------------------StartTimer gp:" .. self._co_timer)
	end	

    if #self._pillars > 4 then
		self:PopTop();   
    end    
end

function GoldPillar:Release()
	self._isRelease = true;
	if self._co_timer then
		ZTD.GameTimer.StopTimer(self._co_timer);
		-- log("--------------------StopTimer gp:" .. self._co_timer)
		self._co_timer = nil;
	end
	
	for _, v in ipairs(self._pillars) do
		ZTD.Extend.StopAction(v.actionKey);
	end 	
	self._pillars = {};
end	

function GoldPillar:AddReadyPillar(key, addMoney, ratio)
    if not self._readyList[key] then
        self._readyList[key] = {};
        self._readyList[key].ratio = ratio;
        self._readyList[key].money = addMoney;
    else
        self._readyList[key].money = self._readyList[key].money + addMoney;
    end    
end

function GoldPillar:FinshReadyPillar(key)
    if self._readyList[key] then
        self:AddPillar(self._readyList[key].ratio, self._readyList[key].money);
        self._readyList[key] = nil;
    end    
end    

return GoldPillar;