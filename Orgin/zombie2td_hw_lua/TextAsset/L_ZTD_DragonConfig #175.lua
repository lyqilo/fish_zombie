local lan =
{
    helpDesc = "投入100倍底分召唤巨龙发动巨龙之怒，发出的强力龙息可以快速清扫怪群！",
    lessTip = "能量不足",
    cdTip = "巨龙之怒尚未结束",
    iconName = "巨龙之怒",
    equip = "装备",
    remove = "卸下",
    notEnoughNum = "数量不足",
    colding = "巨龙之怒冷却中",

    propContent = 
    {
        default = "<color=#929fbe>投入100倍当前底分发动巨龙之怒</color>",
        [1102] = 
        {
            multi = 50,
            content = "<color=#929fbe>免费释放一次价值为</color> <color=#ffa516><b>50*100</b></color> <color=#929fbe>的巨龙之怒</color>"
        },
        [1103] = 
        {
            multi = 200,
            content = "<color=#929fbe>免费释放一次价值为</color> <color=#ffa516><b>200*100</b></color> <color=#929fbe>的巨龙之怒</color>"
        },
        [1104] = 
        {
            multi = 1000,
            content = "<color=#929fbe>免费释放一次价值为</color> <color=#ffa516><b>1000*100</b></color> <color=#929fbe>的巨龙之怒</color>"
        },
        [1105] = 
        {
            multi = 5000,
            content = "<color=#929fbe>免费释放一次价值为</color> <color=#ffa516><b>5000*100</b></color> <color=#929fbe>的巨龙之怒</color>"
        },
        [1111] = 
        {
            multi = 20000,
            content = "<color=#929fbe>免费释放一次价值为</color> <color=#ffa516><b>20000*100</b></color> <color=#929fbe>的巨龙之怒</color>"
        },
    },
}

return lan
