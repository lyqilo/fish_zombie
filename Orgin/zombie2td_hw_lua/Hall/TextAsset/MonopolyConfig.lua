local MonopolyConfig = {
    --排行榜配置
    rankCfg = {
        --气泡预览
        preview = {
            { propId = 2,     num = 30000000 },
            { propId = 2,     num = 25000000 },
            { propId = 20006, num = 1 },
            { propId = 20007, num = 1 },
            { propId = 20125, num = 1 },
            { propId = 20126, num = 1 },
        },
        --排名奖励
        rank = {
            --第一名特殊奖励LV包标志：psj_phb_sw_lv
            { min = 1,  max = 1,
                                      rewards = { { propId = 2, num = 30000000 },
                    { propId = 0, num = 1, icon = "psj_phb_sw_lv" } } },
            { min = 2,  max = 2,  rewards = { { propId = 2, num = 25000000 }, { propId = 20006, num = 1 } } },
            { min = 3,  max = 3,  rewards = { { propId = 2, num = 20000000 }, { propId = 20007, num = 1 } } },
            { min = 4,  max = 4,  rewards = { { propId = 2, num = 20000000 } } },
            { min = 5,  max = 5,  rewards = { { propId = 2, num = 15000000 } } },
            { min = 6,  max = 10, rewards = { { propId = 2, num = 10000000 } } },
            { min = 11, max = 20, rewards = { { propId = 2, num = 8000000 } } },
            { min = 21, max = 30, rewards = { { propId = 2, num = 7000000 } } },
            { min = 31, max = 40, rewards = { { propId = 2, num = 5000000 } } },
            { min = 41, max = 50, rewards = { { propId = 2, num = 3000000 } } },
        }
    },
    --地图配置
    --[[
        98(神秘奖),99(进度)
        ProgressNum进度条, UseNum消耗道具数量, Rewards奖励
        MapBg:地图背景(1-3)
        ElephantIndex:大象的spine
        Tips:气泡展示信息
    ]]
    MaxMapNum = 33,      --最大地图数，和下面地图对应数量
    [1] = {
        ProgressNum = 2, --当前地图进度条数量
        UseNum = 1,      --当前地图消耗道具数量
        MapBg = 1,       --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 1,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 100 },
            { PropId = 2,    Count = 50 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 100 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 100 },
            { PropId = 2,    Count = 50 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 200 },
            { PropId = 2,    Count = 100 },
            { PropId = 2,    Count = 0 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 500 },
            { PropId = 101,  Count = 1 },
        }
    },
    [2] = {
        ProgressNum = 3, --当前地图进度条数量
        UseNum = 2,      --当前地图消耗道具数量
        MapBg = 1,       --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 1,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 200 },
            { PropId = 2,    Count = 100 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 200 },
            { PropId = 102,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 400 },
            { PropId = 2,    Count = 200 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 200 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 100 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 1000 },
            { PropId = 101,  Count = 1 },
        }
    },
    [3] = {
        ProgressNum = 3, --当前地图进度条数量
        UseNum = 3,      --当前地图消耗道具数量
        MapBg = 1,       --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 1,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 300 },
            { PropId = 2,    Count = 300 },
            { PropId = 2,    Count = 1500 },
            { PropId = 2,    Count = 0 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 300 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 0 },
            { PropId = 1030, Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 600 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 150 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 300 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 150 },
            { PropId = 101,  Count = 1 },
        }
    },
    [4] = {
        ProgressNum = 5, --当前地图进度条数量
        UseNum = 5,      --当前地图消耗道具数量
        MapBg = 1,       --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 2,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 0 },
            { PropId = 2,    Count = 500 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 2500 },
            { PropId = 2,    Count = 500 },
            { PropId = 1016, Count = 1 },
            { PropId = 2,    Count = 250 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 250 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 500 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 1000 },
            { PropId = 2,    Count = 0 },
            { PropId = 101,  Count = 1 },
        }
    },
    [5] = {
        ProgressNum = 5, --当前地图进度条数量
        UseNum = 10,     --当前地图消耗道具数量
        MapBg = 1,       --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 2,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 98, Count = 1 },
            { PropId = 2,    Count = 1000 },
            { PropId = 2,    Count = 1000 },
            { PropId = 1006, Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 2000 },
            { PropId = 2,    Count = 1000 },
            { PropId = 2,    Count = 0 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 1000 },
            { PropId = 2,    Count = 0 },
            { PropId = 1016, Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 1016, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [6] = {
        ProgressNum = 7, --当前地图进度条数量
        UseNum = 20,     --当前地图消耗道具数量
        MapBg = 1,       --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 2,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 98, Count = 1 },
            { PropId = 2,    Count = 2000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 1000 },
            { PropId = 2,    Count = 0 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 4000 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 1000 },
            { PropId = 2,    Count = 2000 },
            { PropId = 2,    Count = 2000 },
            { PropId = 2,    Count = 2000 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 10000 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [7] = {
        ProgressNum = 7, --当前地图进度条数量
        UseNum = 30,     --当前地图消耗道具数量
        MapBg = 2,       --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 3,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 0 },
            { PropId = 2,    Count = 3000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 1500 },
            { PropId = 102,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 15000 },
            { PropId = 2,    Count = 0 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 3000 },
            { PropId = 2,    Count = 6000 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 3000 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 3000 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 1500 },
            { PropId = 101,  Count = 1 },
        }
    },
    [8] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 50,      --当前地图消耗道具数量
        MapBg = 2,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 3,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 2500 },
            { PropId = 1006, Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 10000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 2500 },
            { PropId = 2,    Count = 0 },
            { PropId = 1006, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 1006, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1006, Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 25000 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [9] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 80,      --当前地图消耗道具数量
        MapBg = 2,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 3,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 98, Count = 1 },
            { PropId = 2,    Count = 4000 },
            { PropId = 2,    Count = 8000 },
            { PropId = 2,    Count = 8000 },
            { PropId = 102,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 40000 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 16000 },
            { PropId = 2,    Count = 8000 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 4000 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 8000 },
            { PropId = 1030, Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [10] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 100,     --当前地图消耗道具数量
        MapBg = 2,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 4,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1030, Count = 1 },
            { PropId = 1006, Count = 1 },
            { PropId = 2,    Count = 20000 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 10000 },
            { PropId = 2,    Count = 5000 },
            { PropId = 103,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 10000 },
            { PropId = 2,    Count = 10000 },
            { PropId = 2,    Count = 10000 },
            { PropId = 101,  Count = 1 },
        }
    },
    [11] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 150,     --当前地图消耗道具数量
        MapBg = 2,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 4,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 15000 },
            { PropId = 2,    Count = 15000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 7500 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 30000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 75000 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 15000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 15000 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 7500 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [12] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 200,     --当前地图消耗道具数量
        MapBg = 2,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 4,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 20000 },
            { PropId = 2,    Count = 20000 },
            { PropId = 2,    Count = 100000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 40000 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 10000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1022, Count = 1 },
            { PropId = 1022, Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 10000 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [13] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 250,     --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 5,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 125000 },
            { PropId = 2,    Count = 25000 },
            { PropId = 2,    Count = 25000 },
            { PropId = 1007, Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 12500 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 25000 },
            { PropId = 2,    Count = 25000 },
            { PropId = 2,    Count = 0 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 12500 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 101,  Count = 1 },
        }
    },
    [14] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 300,     --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 5,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 30000 },
            { PropId = 2,    Count = 15000 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 15000 },
            { PropId = 102,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 30000 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 30000 },
            { PropId = 2,    Count = 30000 },
            { PropId = 2,    Count = 150000 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 60000 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [15] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 400,     --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 5,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 0 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 20000 },
            { PropId = 2,    Count = 20000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 40000 },
            { PropId = 2,    Count = 40000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 40000 },
            { PropId = 100,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 2,    Count = 80000 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 40000 },
            { PropId = 101,  Count = 1 },
        }
    },
    [16] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 500,     --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 6,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 250000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 50000 },
            { PropId = 102,  Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 100000 },
            { PropId = 100,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 25000 },
            { PropId = 2,    Count = 25000 },
            { PropId = 2,    Count = 50000 },
            { PropId = 103,  Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 101,  Count = 1 },
        }
    },
    [17] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 600,     --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 6,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 60000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 120000 },
            { PropId = 2,    Count = 60000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 60000 },
            { PropId = 2,    Count = 0 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 30000 },
            { PropId = 2,    Count = 30000 },
            { PropId = 2,    Count = 60000 },
            { PropId = 1030, Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 300000 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [18] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 700,     --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 6,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 35000 },
            { PropId = 2,   Count = 0 },
            { PropId = 2,   Count = 0 },
            { PropId = 2,   Count = 350000 },
            { PropId = 102, Count = 1 },
            { PropId = 98,  Count = 1 },
            { PropId = 2,   Count = 0 },
            { PropId = 98,  Count = 1 },
            { PropId = 2,   Count = 70000 },
            { PropId = 100, Count = 1 },
            { PropId = 2,   Count = 35000 },
            { PropId = 2,   Count = 0 },
            { PropId = 98,  Count = 1 },
            { PropId = 2,   Count = 70000 },
            { PropId = 103, Count = 1 },
            { PropId = 98,  Count = 1 },
            { PropId = 2,   Count = 70000 },
            { PropId = 2,   Count = 70000 },
            { PropId = 2,   Count = 14000 },
            { PropId = 101, Count = 1 },
        }
    },
    [19] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 800,     --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 7,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 40000 },
            { PropId = 2,    Count = 80000 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 40000 },
            { PropId = 2,    Count = 80000 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 80000 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 0 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 80000 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 160000 },
            { PropId = 2,    Count = 400000 },
            { PropId = 101,  Count = 1 },
        }
    },
    [20] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 1000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 7,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 1017, Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [21] = {
        ProgressNum = 10,         --当前地图进度条数量
        UseNum = 1000,            --当前地图消耗道具数量
        MapBg = 3,                --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 7,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 1017, Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [22] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 1000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 8,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 1017, Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [23] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 1000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 8,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 1017, Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [24] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 1000, --当前地图消耗道具数量
        MapBg = 3,    --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 8,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 1017, Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [25] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 1000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 9,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 1017, Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [26] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 1000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 9,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1007, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 1017, Count = 1 },
            { PropId = 1007, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 100,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 2,    Count = 100000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [27] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 1200,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 9,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 120000 },
            { PropId = 2,    Count = 120000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 60000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 240000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 600000 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 120000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 120000 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 60000 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [28] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 1500,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 10,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 150000 },
            { PropId = 2,    Count = 150000 },
            { PropId = 2,    Count = 750000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 300000 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 75000 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 150000 },
            { PropId = 2,    Count = 150000 },
            { PropId = 103,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 75000 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [29] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 2000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 10,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1018, Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 2,    Count = 200000 },
            { PropId = 2,    Count = 400000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 100000 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 200000 },
            { PropId = 2,    Count = 200000 },
            { PropId = 2,    Count = 0 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1023, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 101,  Count = 1 },
        }
    },
    [30] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 2500,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 10,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 250000 },
            { PropId = 2,    Count = 125000 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 125000 },
            { PropId = 102,  Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 250000 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 250000 },
            { PropId = 2,    Count = 250000 },
            { PropId = 2,    Count = 1250000 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 500000 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    },
    [31] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 3000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 10,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 0 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 150000 },
            { PropId = 2,    Count = 150000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 300000 },
            { PropId = 2,    Count = 300000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 300000 },
            { PropId = 100,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 1500000 },
            { PropId = 2,    Count = 600000 },
            { PropId = 98,   Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 300000 },
            { PropId = 101,  Count = 1 },
        }
    },
    [32] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 4000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 10,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 2, Count = 2000000 },
            { PropId = 98,   Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 2,    Count = 400000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 400000 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 0 },
            { PropId = 2,    Count = 800000 },
            { PropId = 100,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 200000 },
            { PropId = 2,    Count = 200000 },
            { PropId = 2,    Count = 400000 },
            { PropId = 103,  Count = 1 },
            { PropId = 2,    Count = 400000 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 101,  Count = 1 },
        }
    },
    [33] = {
        ProgressNum = 10, --当前地图进度条数量
        UseNum = 5000,    --当前地图消耗道具数量
        MapBg = 3,        --采用地图背景(1-3)  （1蓝色，2橙色，3紫色）
        ElephantIndex = 10,
        Tips = {
            PropList = {},
            Des = {},
        },
        Rewards = { { PropId = 1017, Count = 1 },
            { PropId = 2,    Count = 0 },
            { PropId = 1018, Count = 1 },
            { PropId = 2,    Count = 500000 },
            { PropId = 102,  Count = 1 },
            { PropId = 2,    Count = 500000 },
            { PropId = 2,    Count = 0 },
            { PropId = 1030, Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 100,  Count = 1 },
            { PropId = 2,    Count = 250000 },
            { PropId = 2,    Count = 250000 },
            { PropId = 1017, Count = 1 },
            { PropId = 1030, Count = 1 },
            { PropId = 103,  Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 2,    Count = 2500000 },
            { PropId = 98,   Count = 1 },
            { PropId = 98,   Count = 1 },
            { PropId = 101,  Count = 1 },
        }
    }
}

return MonopolyConfig
