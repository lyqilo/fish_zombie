-------------------------------
--倍率对应牌子等级
local RatioLevelSet = 
{
    low = {
        --低于这个值显示
        multiple = 15,
        --展示多久之后上飞
        playInterval = 1.5,
        iconPath = "SkeletonGraphicLow",
        --文字颜色
        nameColor = Color(182/255,134/255,91/255,1),
        --阴影颜色
        outlineColor = Color(40/255,35/255,53/255,1)
    },
    mid = {
        --高于low且低于这个值显示
        multiple = 25,
        --展示多久之后上飞
        playInterval = 1.5,
        iconPath = "SkeletonGraphicMid",
        --文字颜色
        nameColor = Color(133/255,169/255,233/255,1),
        --阴影颜色
        outlineColor = Color(41/255,51/255,69/255,1)
    },
    high = {
        --这个值没有意义，高于mid的都为high
        multiple = 60,
        --展示多久之后上飞
        playInterval = 1.5,
        iconPath = "SkeletonGraphicHigh",
        --怪物背景图偏差值
        monsterIconOffset = Vector2(0,-0.56),
        --文字颜色
        nameColor = Color(237/255,182/255,51/255,1),
        --阴影颜色
        outlineColor = Color(64/255,37/255,6/255,1)
    }
}

return RatioLevelSet;
-------------------------------