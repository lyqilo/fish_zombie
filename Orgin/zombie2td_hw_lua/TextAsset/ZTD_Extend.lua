local GC = require("GC")
local uu = require("Common/uu")
local ZTD = require("ZTD")
local M = {};

local Object = UnityEngine.Object;

local actionMap = {};
local actionKey = 0;

function M.LoadPrefab(prefabName,parent,nodeName)
    return ResMgr.LoadPrefab("prefab",prefabName, parent,nodeName or prefabName, nil);
end

function M.LoadSprite(bundleName,assetName)
    return ResMgr.LoadAssetSprite(bundleName,assetName);
end

function M.RunAction(target, action)
    actionKey = actionKey + 1
	local ac = {action,{"call",function (key)
		actionMap[key] = nil
	end,actionKey}}
    actionMap[actionKey] = ZTD.Action.Run(target.transform or target, ac)
    return actionKey	
end

function M.StopAction(actionKey,complete)
    local action = actionMap[actionKey];
    if action then
	   action:Kill(complete or false);
	   actionMap[actionKey] = nil;
    end
end

function M.StopAllAction(complete)
	for _,v in pairs(actionMap) do 
		v:Kill(complete or false);
	end
	actionKey = 0;
	actionMap = {};
end

local timerMap = {};
local timerKey = 0;

function M.StartTimer(func,interval,times)
    timerKey = timerKey + 1;
	local timer = Timer.New(func, interval or 0, times or -1);
    timer:Start();
    timerMap[timerKey] = timer;
    return timerKey;
end

function M.StopTimer( timerKey )
    if not timerKey then return end
	local timer = timerMap[timerKey];
    if timer then
       timer:Stop();
       timerMap[timerKey] = nil;
    end
end

function M.StopAllTimer()
	for _,timer in pairs(timerMap) do 
        timer:Stop();
	end
	timerMap = {};
	timerKey = 0;
end

function M.DelayRun(interval,func)
	return M.StartTimer(func,interval,1);
end

function M.MakeBezierAction(targetPos, oriPos, runObj, checkFunc, durationTo, ctrlPos)
	local ctrlPos = ctrlPos or ((oriPos + targetPos)*0.5 + Vector3(math.random(15,-15),math.random(5,-5),0))
	local to = 	{"to",1,100,durationTo,function(value)
											-- 这里是二阶贝塞尔曲线的实现
											local t = value*0.01
											local u = 1-t
											local tt = t*t
											local uu = u*u

											local p = Vector3(uu*oriPos.x,uu*oriPos.y,uu*oriPos.z)
											p = p + Vector3(2*u*t*ctrlPos.x,2*u*t*ctrlPos.y,2*u*t*ctrlPos.z)
											p = p + Vector3(tt*targetPos.x,tt*targetPos.y,tt*targetPos.z)

											if checkFunc then
												checkFunc(value, p);
											end
											
											runObj.transform.position = p
										end,ease=ZTD.Action.EInCubic};
		
	return to;
end

function M.RunBezier(targetPos, oriPos, runObj, checkFunc, endFunc, duration, ctrlPos)
	local durationTo = duration or 0.8 --去到目标点的总时间
	
	local to = M.MakeBezierAction(targetPos, oriPos, runObj, checkFunc, durationTo, ctrlPos);

	local actKey = ZTD.Extend.RunAction(runObj,{
		to,
		onEnd=function()
		   if endFunc then
				endFunc();
		   end
		end
	})
	return actKey;
end	

function M.DestroyAllChildren(transform,immediately)
    Util.ClearChild(transform,immediately);
end

function M.IsString(value)
    return type(value) == "string"
end

function M.IsTable(value)
    return type(value) == "table"
end

function M.IsNumber(value)
    return type(value) == "number"
end

function M.Release()
    M.StopAllAction();
    M.StopAllTimer();
end

function M.FadeAllIn(node,time)
    local children = node.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Graphic));
    for i = 0 ,children.Length - 1 do 
        children[i]:CrossFadeAlpha(0,0,true);
        children[i]:CrossFadeAlpha(1,time,true);
    end
end

function M.FadeAllOut(node,time)
    local children = node.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Graphic));
    for i = 0 ,children.Length - 1 do 
        children[i]:CrossFadeAlpha(0,time,true);
    end
end
    
function M.RendererFadeIn(node,time,callback)
    node:GetComponent("Renderer").material:SetColor("_Color",Color(1,1,1,0));
    M.RunAction(node,{"to",0,100,time,function(value)
        local t = value / 100;
        node:GetComponent("Renderer").material:SetColor("_Color",Color(1,1,1,t));
    end,    
    onEnd = function()
        if callback then 
            callback();
        end
    end});
end

function M.RendererFadeOut(node,time,callback)
    node:GetComponent("Renderer").material:SetColor("_Color",Color(1,1,1,1));
    M.RunAction(node,{"to",0,100,time,function(value)
        local t = 1 - value / 100;
        node:GetComponent("Renderer").material:SetColor("_Color",Color(1,1,1,t));
    end,    
    onEnd = function()
        if callback then 
            callback();
        end
    end});
end

function M.Destroy(node)
	--logError("ddddddddddddddddddddddddddddddddDestroy:" .. node.name)
    Object.Destroy(node);
end

--数值格式化
--位数补齐
--maxPoint最多显示小数点后几位
function M.FormatSpecNum(number, maxPoint)

    maxPoint = maxPoint or 0
	local count = maxPoint-string.len(tostring(math.floor(number)))+1
	count = count > 0 and count or 0
	local show = string.format("%."..count.."f", number)

	for i=string.len(show),1,-1 do
		local cha = string.sub(show, i)
		if cha == "0" then
			show = string.sub(show, 1, i-1)
		elseif cha == "." then
			show = string.sub(show, 1, i-1)
			break
		end
	end

	
	return show
end

--数值格式化
function M.FormatNumber(number)
    number = number or 0
    number = math.floor(number)
    local numberStr = ""
    if number >= 1000000000 then
        numberStr = string.format("%s", math.floor(number/100000000)).."y"
    elseif number >= 100000 then
        numberStr = string.format("%s", math.floor(number/10000)).."w"
    else
        numberStr = number
    end
    return numberStr
end

function M.FormatNumber2(number)
    number = number or 0
    number = math.floor(number)
    local numberStr = ""
    if number >= 100000000 then
		numberStr = "" .. tonumber(string.format("%.2f", number/100000000)).."y";
    elseif number >= 10000 then
		if number < 1000000 then
			numberStr = "" .. tonumber(string.format("%.2f", number/10000)).."w"
		elseif number < 10000000 then
			numberStr = "" .. tonumber(string.format("%.1f", number/10000)).."w"
		else	
			numberStr = string.format("%s", math.floor(number/10000)).."w"
		end
    else
        numberStr = number
    end
    return numberStr
end

--字符串拆分转换为数字(截取字符串中的所有数字)
function M.StrToNum(str)
    local numstr = ""
    for s in string.gmatch(str, "%d+") do
        numstr = numstr..s
    end
    --logError("numstr="..numstr)
    return tonumber(numstr)
end

--按分隔符分割字符串 例:str = "2017-11-20"  reps = "-"   返回{2017, 11, 20}
function M.SplitMask(str, reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end
--url组装
function M.UrlMapping(url, query)
    if string.find(url, '?') then
        return M.QueryInsert(url, query)
    else
        return M.QueryJoin(url, query)
    end
end

function M.QueryInsert(url, query)
	if not url or not query then
		return
	end
	
	for k, v in pairs(query) do
		local kv = '&' .. k .. '=' .. v
		url = url .. kv
	end
	return url
end

function M.QueryJoin(url, query)
	if not url or not query then
		return
	end
	
	local i = 1
	for k, v in pairs(query) do
		local kv = ""
		if i == 1 then
			kv = '?' .. k .. '=' .. v
		else
			kv = '&' .. k .. '=' .. v
		end
		i = i + 1
		url = url .. kv
	end
	return url
end


function M.TrailRendererClear(trans)
    trans.gameObject:SetActive(false)
   local ts = trans:GetComponentsInChildren(typeof(UnityEngine.TrailRenderer))
	for i = 0, ts.Length - 1 do
        local t = ts[i]
        if t then
			t:Clear()
		end
    end
    trans.gameObject:SetActive(true)
end


return M