local lan =
{
    btn_Holiday = "假日狂欢",
    btn_Buyu = "捕鱼礼包",
    btn_FourBuyu = "四人捕鱼",
    btn_Dummy = "Dummy礼包",
    btn_Pokdeng = "Pokdeng礼包",
    btn_Airplane = "飞机礼包",
    btn_Diglett = "地鼠礼包",
    btn_Zombie = "塔防礼包",
    btn_Bull = "猎牛达人",
    btn_Pharaoh = "地鼠大乱斗",
    tips_gift = "您今天已购买过了，请明天再来哦",
    now_Buy = "立即购买",
    now_Skip = "立即前往",
    tips_commodityType = "请返回活动页选择支付方式完成支付。",

    --飞机礼包
    airPlane = {
        [1] = {
            icon1_name = "青铜核弹头",
            icon1_num = "X1",
            icon1_des = "PlaneWar中\n使用后可获得<color=#E1DF5EFF>30000</color>金币奖励",
            icon2_num = "X5",
            chip_num = "500000",
        },
        [2] = {
            icon1_name = "青铜核弹头",
            icon1_num = "X2",
            icon1_des = "PlaneWar中\n使用后可获得<color=#E1DF5EFF>60000</color>金币奖励",
            icon2_num = "X10",
            chip_num = "1000000",
        },
        [3] = {
            icon1_name = "白银核弹头",
            icon1_num = "X1",
            icon1_des = "PlaneWar中\n使用后可获得<color=#E1DF5EFF>150000</color>金币奖励",
            icon2_num = "X10",
            chip_num = "3000000",
        },
        [4] = {
            icon1_name_1 = "白银核弹头 X3",
            icon1_name_2 = "青铜核弹头 X2",
            icon1_num = "X3",
            icon1_des = "PlaneWar中\n使用后可获得<color=#E1DF5EFF>510000</color>金币奖励",
            icon2_num = "X15",
            chip_num = "10000000",
        },
        [5] = {
            icon1_name_1 = "黄金核弹头 X1",
            icon1_name_2 = "白银核弹头 X1",
            icon1_num = "X1",
            icon1_des = "PlaneWar中\n使用后可获得<color=#E1DF5EFF>900000</color>金币奖励",
            icon2_num = "X20",
            chip_num = "20000000",
        },
        limitBuy = "每日限购1次",
        icon2_des = "飞机捕鱼中使用\n可召唤出飞机",
        chip_des = "最高获得:",
        Explain_title = "说明",
        Explain_des = "仅适用于飞机射击游戏。金币价值是",
        Explain_num_1 = "30000",
        Explain_num_2 = "150000",
        Explain_num_3 = "750000",
    },

    --猎牛礼包
    bull = {
        [1] = {
            Thb = "只要29THB",
            Image_Text2 = "1",
            Image1_Text1 = "500,000",
        },
        [2] = {
            Thb = "只要50THB",
            Image_Text2 = "1",
            Image1_Text1 = "1,000,000",
        },
        [3] = {
            Thb = "只要150THB",
            Image_Text2 = "2",
            Image1_Text1 = "3,000,000",
        },
        [4] = {
            Thb = "只要500THB",
            Image_Text2 = "8",
            Image1_Text1 = "10,000,000",
        },
        [5] = {
            Thb = "只要1000THB",
            Image_Text2 = "16",
            Image1_Text1 = "20,000,000",
        },
        Image_Text = "使用后，将获得",
        Image_Text1 = "免费炸弹攻击",
        Image_Text3 = "次",
        Image_Text4 = "几率获得",
        Image1_Text = "最高可获得",
        Limit_Text = "限购1次",
    },

    --捕鱼礼包
    buyu = {
        [1] = {
            Thb = "只要29THB",
            Chip = "最高获得:500000",
            prop1_num = "x6",
            prop1_des = "<color=#88FFCF>二人捕鱼使用\n最高机会获得\n</color><color=#FFDE00>750*6</color><color=#88FFCF>金币</color>",
            prop2_num = "x3",
            prop2_des = "<color=#88FFCF>二人捕鱼使用\n最高机会获得</color>\n<color=#FFDE00>7500*3</color><color=#88FFCF>金币</color>",
        },
        [2] = {
            Thb = "只要50THB",
            Chip = "最高获得:1000000",
            prop1_num = "x5",
            prop1_des = "<color=#FFACEF>二人捕鱼使用\n最高机会获得\n</color><color=#FFDE00>750*5</color><color=#FFACEF>金币</color>",
            prop2_num = "x6",
            prop2_des = "<color=#FFACEF>二人捕鱼使用\n最高机会获得</color>\n<color=#FFDE00>7500*6</color><color=#FFACEF>金币</color>",
        },
        [3] = {
            Thb = "只要150THB",
            Chip = "最高获得:3000000",
            prop1_num = "x9",
            prop1_des = "<color=#FFB0AF>二人捕鱼使用\n最高机会获得\n</color><color=#FFDE00>7500*9</color><color=#FFB0AF>金币</color>",
            prop2_num = "x1",
            prop2_des = "<color=#FFB0AF>二人捕鱼使用\n最高机会获得</color>\n<color=#FFDE00>75000*1</color><color=#FFB0AF>金币</color>",
        },
        [4] = {
            Thb = "只要500THB",
            Chip = "最高获得:10000000",
            prop1_num = "x10",
            prop1_des = "<color=#E0C1FF>二人捕鱼使用\n最高机会获得\n</color><color=#FFDE00>7500*10</color><color=#E0C1FF>金币</color>",
            prop2_num = "x6",
            prop2_des = "<color=#E0C1FF>二人捕鱼使用\n最高机会获得</color>\n<color=#FFDE00>75000*6</color><color=#E0C1FF>金币</color>",
        },
        [5] = {
            Thb = "只要1000THB",
            Chip = "最高获得:20000000",
            prop1_num = "x3",
            prop1_des = "<color=#FFACEF>二人捕鱼使用\n最高机会获得\n</color><color=#FFDE00>75000*3</color><color=#FFACEF>金币</color>",
            prop2_num = "x1",
            prop2_des = "<color=#FFACEF>二人捕鱼使用\n最高机会获得</color>\n<color=#FFDE00>750000*1</color><color=#FFACEF>金币</color>",
        },
        Explain_title = "说明",
        Explain_des = "仅适用于2人捕鱼游戏。金币价值是",
        Explain_num_1 = "750",
        Explain_num_2 = "7500",
        Explain_num_3 = "75000",
        Explain_num_4 = "750000",
    },

    --地鼠礼包
    diglett = {
        [1] = {
            prop_num = "x1",
            Tip3 = "获得最大金币\n<color=#45fafa>500,000</color>",
        },
        [2] = {
            prop_num = "x1",
            Tip3 = "获得最大金币\n<color=#45fafa>1,000,000</color>",
        },
        [3] = {
            prop_num = "x1",
            Tip3 = "获得最大金币\n<color=#45fafa>3,000,000</color>",
        },
        [4] = {
            prop_num = "x4",
            Tip3 = "获得最大金币\n<color=#45fafa>10,000,000</color>",
        },
        [5] = {
            prop_num = "x8",
            Tip3 = "获得最大金币\n<color=#45fafa>20,000,000</color>",
        },
        Limit_Text = "每日限购1次",
        Tip2 = "使用之后可获得最高<color=#45fafa>50</color>次\n最高<color=#45fafa>12000</color>倍的免费次数",
    },

    --dummy礼包
    dummy = {
        [1] = {
            Thb = "只要29THB",
            Text1 = "500000金币",
            Text2 = "特殊道具信件*4",
        },
        [2] = {
            Thb = "只要50THB",
            Text1 = "1000000金币",
            Text2 = "特殊道具信件*8",
        },
        [3] = {
            Thb = "只要150THB",
            Text1 = "3000000金币",
            Text2 = "特殊道具信件*15",
        },
        [4] = {
            Thb = "只要500THB",
            Text1 = "10000000金币",
            Text2 = "特殊道具信件*20",
        },
        [5] = {
            Thb = "只要1000THB",
            Text1 = "20000000金币",
            Text2 = "特殊道具信件*30",
        },
        Limit_Text = "每日限购1次\n在dummy游戏中打开信件获得奖励",
        max_Text = "最高获得:",
        Explain_title = "说明",
        Explain_des = "启用密函，有机会获得大量筹码奖励+高级物品。筹码奖励高达 15000\n高级物品包括虚拟锦标赛复活券-\n虚拟游戏再次用于复活锦标赛。\n虚拟游戏用于恢复VIP室赛车。\n虚拟淘汰赛门票 - 虚拟游戏用于淘汰赛\n进入虚拟扑克室即可激活~",
    },

    --四人捕鱼
    fourBuyu = {
        [1] = {
            Thb = "只要29THB",
            ChipNum = "500000",
            prop1_name = "青铜鱼雷",
            prop1_num = "x1",
            prop1_des = "<color=#F9Eb90>在4人捕鱼中使用\n最高获得</color><color=#FFAFC6>24000</color><color=#F9Eb90>金币</color>",
            prop3_num = "x5",
        },
        [2] = {
            Thb = "只要50THB",
            ChipNum = "1000000",
            prop1_name = "青铜鱼雷",
            prop1_num = "x1",
            prop1_des = "<color=#F9Eb90>在4人捕鱼中使用\n最高获得</color><color=#FFAFC6>24000</color><color=#F9Eb90>金币</color>",
            prop3_num = "x12",
        },
        [3] = {
            Thb = "只要150THB",
            ChipNum = "3000000",
            prop1_name = "白银鱼雷",
            prop1_num = "x1",
            prop1_des = "<color=#F9Eb90>在4人捕鱼中使用\n最高获得</color><color=#FFAFC6>120000</color><color=#F9Eb90>金币</color>",
            prop3_num = "x15",
        },
        [4] = {
            Thb = "只要500THB",
            ChipNum = "10000000",
            prop1_name = "白银鱼雷",
            prop1_num = "x3",
            prop1_des = "<color=#F9Eb90>在4人捕鱼中使用\n最高获得</color><color=#FFAFC6>360000</color><color=#F9Eb90>金币</color>",
            prop2_name = "青铜鱼雷",
            prop2_num = "x2",
            prop2_des = "<color=#F9Eb90>在4人捕鱼中使用\n最高获得</color><color=#FFAFC6>48000</color><color=#F9Eb90>金币</color>",
            prop3_num = "x17",
        },
        [5] = {
            Thb = "只要1000THB",
            ChipNum = "20000000",
            prop1_name = "黄金鱼雷",
            prop1_num = "x1",
            prop1_des = "<color=#F9Eb90>在4人捕鱼中使用\n最高获得</color><color=#FFAFC6>600000</color><color=#F9Eb90>金币</color>",
            prop2_name = "青铜鱼雷",
            prop2_num = "x8",
            prop2_des = "<color=#F9Eb90>在4人捕鱼中使用\n最高获得</color><color=#FFAFC6>192000</color><color=#F9Eb90>金币</color>",
            prop3_num = "x25",
        },
        Limit_Text = "每日限购\n1次",
        Chip = "最高获得",
        prop3_name = "召唤道具",
        prop3_des = "<color=#F9Eb90>使用后 在房间ะ\n将召唤</color><color=#FFAFC6> 大鱼种 </color><color=#F9Eb90>1条</color>",
        Explain_title = "说明",
        Explain_des = "仅适用于4人捕鱼游戏。金币价值是",
        Explain_num_1 = "24000",
        Explain_num_2 = "120000",
        Explain_num_3 = "600000",
    },

    --地鼠大乱斗
    pharaoh = {
        [1] = {
            Tip1 = "获得最大金币\n<color=#7df5f5>500,000</color>",
            Tip2 = "使用后将获得\n蜘蛛侠转盘<color=#7df5f5>1</color>次",
        },
        [2] = {
            Tip1 = "获得最大金币\n<color=#7df5f5>1,000,000</color>",
            Tip2 = "使用后将获得\n蜘蛛侠转盘<color=#7df5f5>1</color>次",
        },
        [3] = {
            Tip1 = "获得最大金币\n<color=#7df5f5>3,000,000</color>",
            Tip2 = "使用后将获得\n蜘蛛侠转盘<color=#7df5f5>2</color>次",
        },
        [4] = {
            Tip1 = "获得最大金币\n<color=#7df5f5>10,000,000</color>",
            Tip2 = "使用后将获得\n蜘蛛侠转盘<color=#7df5f5>7</color>次",
        },
        [5] = {
            Tip1 = "获得最大金币\n<color=#7df5f5>20,000,000</color>",
            Tip2 = "使用后将获得\n蜘蛛侠转盘<color=#7df5f5>14</color>次",
        },
        Limit_Text = "每日限购1次",
        Tip3 = "有几率获得",
    },

    --Pokdeng礼包
    pokdeng = {
        [1] = {
            Thb = "只要29THB",
            chip_num = "50K",
            prop_num = "X1",
        },
        [2] = {
            Thb = "只要50THB",
            chip_num = "1M",
            prop_num = "X2",
        },
        [3] = {
            Thb = "只要150THB",
            chip_num = "3M",
            prop_num = "X4",
        },
        [4] = {
            Thb = "只要500THB",
            chip_num = "10M",
            prop_num = "X10",
        },
        [5] = {
            Thb = "只要1000THB",
            chip_num = "20M",
            prop_num = "X17",
        },
        max_chip = "最高获得",
        prop_des = "道具最高获得",
        prop_chip = "40M",
        prop_name = "增益卡",
        record_Text = "卡增加利润，弹出纸牌游戏将随机形成一个特殊的卡。\n使用特殊卡格式赢取最多可获得 9 倍的奖励。\n（当只有一个玩家时，没有效果）",
        Explain_title = "说明",
        Explain_des = "1. 在弹出游戏中获得特殊卡格式的增益卡\n2. 特殊卡格式如下：\n波克8，9最初支付1倍。如果手柄最多可增加 2 倍\n必须/按颜色排列，最初支付 5 倍。如果手柄最多可增加 9 倍\n三个黄色/黄色，最初支付3倍。如果手柄最多可增加 6 倍\n3. 玩家将获得额外的卡格式，获胜将按捕获的费率支付。下大赌注越多，你得到的就越多。",
    },

    --僵尸礼包
    Zombie = {
        [1] = {
            Thb = "เพียง29THB",
            Chip = "ได้รับสูงสุด:500000",
            prop1_name = "คำสาปมังกร",
            prop1_num = "1",
            prop2_name = "คำสาปมังกร",
            prop2_num = "1",
            prop3_name = "มีโอกาสได้รับ",
            prop3_num = "1",
        },
        [2] = {
            Thb = "เพียง50THB",
            Chip = "ได้รับสูงสุด:1000000",
            prop1_name = "คำสาปมังกร",
            prop1_num = "2",
            prop2_name = "คำสาปมังกร",
            prop2_num = "1",
            prop3_name = "มีโอกาสได้รับ",
            prop3_num = "1",
        },
        [3] = {
            Thb = "เพียง150THB",
            Chip = "ได้รับสูงสุด:3000000",
            prop1_name = "คำสาปมังกร",
            prop1_num = "2",
            prop2_name = "คำสาปมังกร",
            prop2_num = "4",
            prop3_name = "มีโอกาสได้รับ",
            prop3_num = "1",
        },
        [4] = {
            Thb = "เพียง500THB",
            Chip = "ได้รับสูงสุด:10000000",
            prop1_name = "คำสาปมังกร",
            prop1_num = "6",
            prop2_name = "คำสาปมังกร",
            prop2_num = "6",
            prop3_name = "คำสาปมังกร",
            prop3_num = "2",
        },
        [5] = {
            Thb = "เพียง1000THB",
            Chip = "ได้รับสูงสุด:20000000",
            prop1_name = "คำสาปมังกร",
            prop1_num = "8",
            prop2_name = "คำสาปมังกร",
            prop2_num = "6",
            prop3_name = "คำสาปมังกร",
            prop3_num = "1",
        },
        Tip = "免费释放一次价值为 %s的巨龙之怒",
    },
}

return lan