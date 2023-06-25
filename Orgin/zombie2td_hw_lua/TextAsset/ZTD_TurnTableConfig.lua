local TurnTableConfig = {
    --转盘旋转一圈的度数
    turnAngle = 360,
    --转盘旋转圈数
    turnTimes = 2,
    --转盘每项所占角度(已跟转盘预制体绑定，不允许修改)
    unitAngle = 45,

    --第一轮旋转时长
    turnInterval1 = 1.2,
    --第二轮旋转时长
    turnInterval2 = 1.2,
    --第一轮与第二轮旋转间隔时长
    turnInterval = 0.3,
    
    --英雄模式中显示下一组中奖间隔时长
    rewardInterval = 0.7,

    --中心头像切换速率
    turnCenterRatio = 50,
    --中心头像切换时长
    turnCenterInterval = 2.2,

    --转盘结束到展示总奖励间隔时长
    showRewardDelay = 1,

    --维克多中心展示切换速率
    weikeduoRatio = 20,
    --维克多中心展示切换时长
    weikeduoInterval = 2,

    --龙母中心展示切换速率
    longmuRatio = 20,
    --龙母中心展示切换时长
    longmuInterval = 0.8,

    --转盘飞行时长
    flyInterval = 2,
    --延迟关闭转盘时长
    closeDelay = 0,

    --转盘值配置表
    cfg = {
        [1] = {x = 1, y = 2},
        [2] = {x = 2, y = 5},
        [3] = {x = 3, y = 9},
        [4] = {x = 4, y = 12},
        [5] = {x = 5, y = 15},
        [6] = {x = 6, y = 18},
        [7] = {x = 8, y = 21},
        [8] = {x = 10, y = 26},
    }
}
return TurnTableConfig