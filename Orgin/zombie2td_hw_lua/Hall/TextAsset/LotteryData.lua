--***************************************************
--文件描述: 彩票记录缓存
--关联主体: LotteryView.lua
--注意事项:无
--作者:flz
--时间:
--***************************************************
local LotteryData = {
    LotteryConfig  = {
        PastLottery = {
            StartIndex = 0, -- 起始index
            Capacity = 20, -- 页面容量
            EndIndex = 19 -- (StartIndex + Capacity - 1) -- 结束index
        },
        PurchaseRecord = {
            StartIndex = 0, -- 起始index
            Capacity = 20, -- 页面容量
            EndIndex = 19 -- (StartIndex + Capacity - 1) -- 结束index
        },
        PurchaseNum = {
            StartIndex = 0, -- 起始index
            Capacity = 20, -- 页面容量
            EndIndex = 19, -- (StartIndex + Capacity - 1) -- 结束index
        },
        BetDetail = {
            StartIndex = 0, -- 起始index
            Capacity = 20, -- 页面容量
            EndIndex = 19, -- (StartIndex + Capacity - 1) -- 结束index
        },
        RankList = {
            StartIndex = 0, -- 起始index
            Capacity = 10, -- 页面容量
            EndIndex = 9, -- (StartIndex + Capacity - 1) -- 结束index
        },
    },
    
    PurchaseNumCache = {

    },
    PurchaseRecordCache ={

    },
    PastLotteryCache = {

    },
    BetDetailCache = {

    },
    RankListCache = {

    },
    -- 根据VIP的额外奖励
    VipPremiums = {
        [0	]=0,
        [1	]=1,
        [2	]=2,
        [3	]=3,
        [4	]=4,
        [5	]=6,
        [6	]=8,
        [7	]=10,
        [8	]=15,
        [9	]=20,
        [10	]=25,
        [11	]=30,
        [12	]=35,
        [13	]=40,
        [14	]=45,
        [15	]=50,
        [16	]=60,
        [17	]=70,
        [18	]=80,
        [19	]=90,
        [20	]=100,
        [21	]=100,
        [22	]=100,
        [23	]=100,
        [24	]=100,
        [25	]=100,
        [26	]=100,
        [27	]=100,
        [28	]=100,
        [29	]=100,
        [30	]=100,
    },
    AnimTime = 4, -- 开奖时数字滚动时间

}

return LotteryData