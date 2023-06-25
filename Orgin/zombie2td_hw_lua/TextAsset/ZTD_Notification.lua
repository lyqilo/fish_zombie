local M = {};

----------------游戏内部消息传递---------------
local GameList = {};

function M.GameRegister(obj,name,func)
	GameList[name] = GameList[name] or {};
	GameList[name][obj] = func;
end

function M.GameUnregister(obj, name)
	if not GameList[name] then
		logError("GameUnregister消息 name:"..name.."的监听从未建立过");
		return
	end
	GameList[name][obj] = nil;
end

function M.GameUnregisterAll(obj)
	for name,list in pairs(GameList) do 
		for _obj,_ in pairs(list) do 
			if _obj == obj then
				GameList[name][_obj] = nil;
			end
		end
	end
end

function M.GamePost(name,...)
	if not GameList[name] then
--		logError("GamePost消息 name:"..name.."的监听从未建立过");
		return
	end
	for obj,func in pairs(GameList[name]) do
		func(obj,...);
	end
end
----------------游戏内部消息传递---------------

----------------网络回包消息分发---------------
local NetworkList = {};
--name填写请求的名字
function M.NetworkRegister(obj,name,func)
	NetworkList[name] = NetworkList[name] or {};
	NetworkList[name][obj] = func;
end

function M.NetworkUnregister(obj,name)
	if not NetworkList[name] then
		logError("NetworkUnregister消息 name:"..name.."的监听从未建立过");
		return
	end
	NetworkList[name][obj] = nil;
	-- if obj.transform then
	-- 	logError(obj.transform.name.."解除监听"..name);
	-- else
	-- 	logError("解除监听"..name.."\n"..debug.traceback())
	-- end
end

function M.NetworkUnregisterAll(obj)
	for name,list in pairs(NetworkList) do 
		for _obj,_ in pairs(list) do 
			if _obj == obj then
				NetworkList[name][_obj] = nil;
				-- if obj.transform then
				-- 	logError(obj.transform.name.."解除监听"..name);
				-- else
				-- 	logError("解除监听"..name.."\n"..debug.traceback())
				-- end
			end
		end
	end
end

function M.NetworkPost(name,...)
	if not NetworkList[name] then
		logError("NetworkPost消息 name:"..name.."的监听从未建立过");
		return
	end
	for obj,func in pairs(NetworkList[name]) do
		func(obj,...);
	end
end

----------------网络回包消息分发---------------
function M.UnregisterAll(obj)
	M.GameUnregisterAll(obj);
	M.NetworkUnregisterAll(obj);
end

return M
