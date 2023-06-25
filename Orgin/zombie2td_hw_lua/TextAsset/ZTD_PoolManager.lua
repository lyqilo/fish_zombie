local GC = require("GC")
local ZTD = require("ZTD")
local M = {};
local GameParent;
local UIParent
local GameItemList = {};
local Finish;
local PreLoadIndex;
local UpdateKey;
--120s没用到就销毁
local gcTime = 120
local firstLoad = true


function M.PreLoad()
    GameParent = GameObject.Find("BattleField/GamePool").transform
    UIParent = GameObject.Find("Main/Canvas/UiPool").transform
	
    Finish = false;
    GameItemList = {};
    UpdateKey = ZTD.GlobalTimer.StartTimer(function()
        M.Loading();
    end,0.01);
	--每隔2s遍历池子，有不用的销毁
	M.poolGCTimer = ZTD.GlobalTimer.StartTimer(function ()
			M.CheckPoolGC()
		end, 2)
    PreLoadIndex = 1;

end

--内存池里面的元素2分钟不用就销毁
function M.CheckPoolGC()

	for name,v in pairs(GameItemList) do
		local lastTime = v.firstItemUsedTime
		local counts = #v
		if lastTime and counts > 1 and os.clock()-lastTime > gcTime then
			ZTD.Extend.Destroy(table.remove(v, 1).gameObject)
			v.firstItemUsedTime = os.clock()
			v.firstItem = v[1]
		end
	end

end


function M.GetNowProcess()
	return PreLoadIndex/(#ZTD.PoolConfig);
end	

function M.Loading()
	if firstLoad then
		local data = ZTD.PoolConfig[PreLoadIndex];
		GameItemList[data.name] = {};
		if not ZTD.IsLowDevice() then
			for i = 1,data.num,1 do 
				local item = ZTD.Extend.LoadPrefab(data.name,data.isUI and UIParent or GameParent);
				item.localPosition = Vector3(1000,0,0);
				item:SetActive(false)
				table.insert(GameItemList[data.name],item);
			end
		end
	end
	
	PreLoadIndex = PreLoadIndex + 1;
	if PreLoadIndex > #ZTD.PoolConfig then
		firstLoad = false
		M.PreLoadFinish()
	end
end

function M.PreLoadFinish()
   Finish = true;
   ZTD.GlobalTimer.StopTimer(UpdateKey);
end

function M.IsFinish()
    return Finish;
end


function M.GetGameItem(name,parent)
    if GameItemList[name] and #GameItemList[name] > 0 then
		
        local item = table.remove(GameItemList[name], #GameItemList[name]);
		if GameItemList[name].firstItem ~= GameItemList[name][1] and GameItemList[name][1] then
			GameItemList[name].firstItem = GameItemList[name][1]
			GameItemList[name].firstItemUsedTime = os.clock()
		end

        if item.parent ~= parent then 
            item:SetParent(parent);
        end
        if not item.activeSelf then 
            item:SetActive(true);
        end

        return item;
    else

        return ZTD.Extend.LoadPrefab(name,parent);
    end
end

function M.RemoveGameItem(name,item)
	if tostring(item) == "null" or not item then return end
	if not GameItemList[name] then
		ZTD.Extend.Destroy(item.gameObject);
	else	
		item:SetParent(GameParent);
		
		item:SetActive(false);
		item.localPosition = Vector3(1000,0,0);
		table.insert(GameItemList[name],item);
	end
	
end

function M.GetUiItem(name,parent)
	return M.GetGameItem(name, parent)
end

function M.RemoveUiItem(name,item)
	if tostring(item) == "null" or not item then return end
	if not GameItemList[name] then
		ZTD.Extend.Destroy(item.gameObject);
	else	
		item:SetParent(UIParent);
		
		item:SetActive(false);
		item.localPosition = Vector3(1000,0,0);
		table.insert(GameItemList[name],item);

	end

end


function M.Release()
	M.PreLoadFinish();
    for i,v in pairs(GameItemList) do 
        for _,item in ipairs(v) do 
            ZTD.Extend.Destroy(item.gameObject);
        end
		GameItemList[i] = {};
    end

end



return M