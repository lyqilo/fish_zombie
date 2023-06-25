
local Main = {}

function Main.Init()
    
    --这段代码是提醒有全局变量声明的！
    local __g = _G
    setmetatable(__g, {
        --当_G中找不到_G['name']属性时，会调用__index查询,如果存在了，就不会走这里来
        __index = function(_, name)
            local ret = rawget(__g, name)
            if ret == nil then
                LuaFramework.Util.LogError("!!!!!!!!!!!!!空空空空空空空空\n该变量未定义(如果是大厅的调用,请从CC.lua中获取):" .. name .. "\n" .. debug.traceback())
            end
            return ret
        end,
        --__newindex用于更新table，当对table中不存在的索引赋值时，解释器就会查找__newindex元方法！
        --所以声明新的全局变量会跑这里面来！
        __newindex = function(_, key, value)
            --提醒你有全局变量声明了！应该禁止，但我还是先给你声明上···
            rawset(__g, key, value)
            LuaFramework.Util.LogError("!!!!!!!!!!!!!禁止禁止禁止禁止\n不允许声明全局变量:"..key.."\n"..debug.traceback())
        end
    });
    --

    local CC = require("CC")
    --定义全局类
    CC.Init()
    CC.HallCenter.InitBeforeLogin()
    --初始化登录前需要用到的一些数据
    -- CC.Platform.Init()
    -- CC.DebugDefine.Init()
    -- if not CC.DebugDefine.GetDebugMode() then
        -- CC.HallCenter.InitBeforeLogin()
    --     Util.hasLog = false;
    -- end
end

function Main.Start()
    --！！！Attention，不要在这个方法内初始化游戏数据，热更完成后，不会执行到这里面来
    --设置随机种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6));
    local CC = require("CC")
    -- CC.ViewManager.Replace("LoadingView")
    if not CC.DebugDefine.GetDebugMode() then
        Util.hasLog = false;
        CC.ViewManager.Replace("LoadingView")
    else
        CC.ViewManager.Replace("DebugView")
    end
end 

return Main