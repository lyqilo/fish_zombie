-- 塔防场配置
local TdArenaConfig = {
    ArenaLimit = 
    {
        [1] = 
        {
            multipleMin = 1,
            multipleMax = 100,
        },
        [2] = 
        {
            multipleMin = 50,
            multipleMax = 1000,
        },
        [3] = 
        {
            multipleMin = 500,
            multipleMax = 10000,
        },
        [4] = 
        {
            multipleMin = 5000,
            multipleMax = 20000,
        },
    },

    SkipGroupLimit = 
    {
        [1] = {
            time = 300,
            vip = 3,
            gold = 300000,
        }, 
        [2] = {
            time = 300,
            vip = 3,
            gold = 3000000,
        },
        [3] = {
            time = 300,
            vip = 5,
            gold = 5000000,
        },
    }

}
    return TdArenaConfig;