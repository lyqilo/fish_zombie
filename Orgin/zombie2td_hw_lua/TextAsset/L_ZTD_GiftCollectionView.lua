local lan =
{
    txt_weeksCard = "周卡礼包",
    txt_dragonTreasure = "藏宝阁",

    txt_panel_dragonTreasure_shopPop = "<color=#FFEE7BFF>当前碎片不足，需花费</color><color=#FF8400FF>%d</color><color=#FFEE7BFF>钻石购买</color><color=#FF8400FF>%d</color><color=#FFEE7BFF>个</color><color=#FF8400FF>%s</color><color=#FFEE7BFF>，是否购买？</color>",
    txt_panel_dragonTreasure_chip1 = "低级碎片",
    txt_panel_dragonTreasure_chip2 = "中级碎片",
    txt_panel_dragonTreasure_chip3 = "高级碎片",
    txt_panel_dragonTreasure_chip4 = "特级碎片",
    txt_panel_dragonTreasure_tip = "1、使用赔率越高，战斗中掉落碎片的等级和概率越高\n2、打开宝箱可以获得金币、巨龙令以及特权卡\n3、选择消耗筹码翻倍，将有概率使宝箱开启奖励*2",

    txt_panel_weeksCard_item1 = "免费释放一次价值为 50*100 的巨龙之怒",
    txt_panel_weeksCard_item2 = "免费释放一次价值为 200*100 的巨龙之怒",
    txt_panel_weeksCard_item3 = "免费释放一次价值为 5000*100 的巨龙之怒",

    txt_panel_weeksCard_item3_1 = "解锁\n[龙母]",
    txt_panel_weeksCard_item3_2 = "解锁\n[一键部署]",
    txt_panel_weeksCard_item3_3 = "所有行动点\n消耗-1",
    
    txt_chipShopRet_title = "购买成功",

    txt_dragonTreasureRet_tip = "[翻倍]消耗筹码，将有概率使奖励数量*2",
    txt_dragonTreasureRet_doubleBtn = "翻倍",
    txt_dragonTreasureRet_confirmBtn = "确定",
    txt_dragonTreasureRet_title = "恭喜获得",
    txt_dragonTreasureRet_succtitle = "翻倍成功",
    txt_dragonTreasureRet_failtitle = "翻倍失败",

    dragonTreasure = 
    {
        [1] = {
            typeID = 1000,
            ID = 1001,
            ChipNum = 20,
            Name = "普通宝箱",
            BgIcon = "cbg__0003_4",
            chipBgIcon = "cbgsp_di1",
            BoxIcon = "cbg_icon_2_0000_1",
            ChipIcon = "cbg_icon__0000_1",
            ShopChipIcon = "tf_bs1",
            Tip = "开启获得金币或者巨龙令（青铜），并有概率额外获得特权卡*1天" ,
        },
        [2] = {
            typeID = 2000,
            ID = 1002,
            ChipNum = 20,
            Name = "精致宝箱",
            BgIcon = "cbg__0002_3",
            chipBgIcon = "cbgsp_di2",
            BoxIcon = "cbg_icon_2_0001_2",
            ChipIcon = "cbg_icon__0001_2",
            ShopChipIcon = "tf_bs2",
            Tip = "开启获得金币或者巨龙令（白银），并有概率额外获得特权卡*1天" ,
        },
        [3] = {
            typeID = 3000,
            ID = 1003,
            ChipNum = 15,
            Name = "豪华宝箱",
            BgIcon = "cbg__0001_2",
            chipBgIcon = "cbgsp_di3",
            BoxIcon = "cbg_icon_2_0002_3",
            ChipIcon = "cbg_icon__0002_3",
            ShopChipIcon = "tf_bs3",
            Tip = "开启获得金币或者巨龙令（黄金），并有概率额外获得特权卡*1天" ,
        },
        [4] = {
            typeID = 4000,
            ID = 1004,
            ChipNum = 15,
            Name = "传承宝箱",
            BgIcon = "cbg__0000_1",
            chipBgIcon = "cbgsp_di4",
            BoxIcon = "cbg_icon_2_0003_4",
            ChipIcon = "cbg_icon__0003_4",
            ShopChipIcon = "tf_bs4",
            Tip = "开启获得金币或者巨龙令（钻石），并有概率额外获得特权卡*1天" ,
        },
    }
}

return lan