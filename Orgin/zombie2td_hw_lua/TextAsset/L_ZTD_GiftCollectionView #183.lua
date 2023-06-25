local lan =
{
    txt_weeksCard = "แพ็ครายสัปดาห์",
    txt_dragonTreasure = "หอสมบัติ",

    txt_panel_dragonTreasure_shopPop = "<color=#FFEE7BFF>ปัจจุบันชิ้นส่วนไม่พอ จะต้องใช้</color><color=#FF8400FF>%d</color><color=#FFEE7BFF>เพชรซื้อ</color><color=#FF8400FF>%d</color><color=#FFEE7BFF>อันxxชิ้นส่วน？</color>",
    txt_panel_dragonTreasure_chip1 = "ชิ้นส่วนทั่วไป",
    txt_panel_dragonTreasure_chip2 = "ชิ้นส่วนประณีต",
    txt_panel_dragonTreasure_chip3 = "ชิ้นส่วนขั้นสูง",
    txt_panel_dragonTreasure_chip4 = "ชิ้นส่วนพิเศษ",
    txt_panel_dragonTreasure_tip = "1.ใช้งานอัตรายิ่งสูง ระดับและโอกาสการดรอปชิ้นส่วนในขณะต่อสู้ยิ่งสูงขึ้น\n2.เปิดสมบัติจะได้รับชิป คำสาปมังกรและการ์ดพิเศษ\n3.[เพิ่มเท่า]มีโอกาสทำให้ได้รับจำนวนไอเท็ม*2",

    txt_panel_weeksCard_item1 = "ปล่อยฟรี1ครั้งมูลค่าเท่ากับ ความโกรธเจ้ามังกร 50*100",
    txt_panel_weeksCard_item2 = "ปล่อยฟรี1ครั้งมูลค่าเท่ากับ ความโกรธเจ้ามังกร 200*100",
    txt_panel_weeksCard_item3 = "ปล่อยฟรี1ครั้งมูลค่าเท่ากับ ความโกรธเจ้ามังกร 5000*100",

    txt_panel_weeksCard_item3_1 = "ปลดล็อค\n[พญามังกร]",
    txt_panel_weeksCard_item3_2 = "ปลดล็อค\n[กดปุ่มวางทีเดียว]",
    txt_panel_weeksCard_item3_3 = "ค่าพลังทั้งหมดใช้\n-1",

    txt_chipShopRet_title = "ซื้อสำเร็จ",

    txt_dragonTreasureRet_tip = "[เพิ่มเท่า]ใช้จ่ายชิป จะมีโอกาสได้จำนวนรางวัล*2",
    txt_dragonTreasureRet_doubleBtn = "เพิ่มเท่า",
    txt_dragonTreasureRet_confirmBtn = "ตกลง",
    txt_dragonTreasureRet_title = "ยินดีด้วยแลกสำเร็จ",
    txt_dragonTreasureRet_succtitle = "เพิ่มเท่าสำเร็จ",
    txt_dragonTreasureRet_failtitle = "เพิ่มเท่าล้มเหลว",

    dragonTreasure = 
    {
        [1] = {
            typeID = 1000,
            ID = 1001,
            ChipNum = 20,
            Name = "หีบสมบัติทั่วไป",
            BgIcon = "cbg__0003_4",
            chipBgIcon = "cbgsp_di1",
            BoxIcon = "cbg_icon_2_0000_1",
            ChipIcon = "cbg_icon__0000_1",
            ShopChipIcon = "tf_bs1",
            Tip = "เปิดใช้ได้รับชิปหรือคำสาปมังกร(ทองแดง) และมีโอกาสได้รับการ์ดพิเศษ*1วัน",
        },
        [2] = {
            typeID = 2000,
            ID = 1002,
            ChipNum = 20,
            Name = "หีบสมบัติประณีต",
            BgIcon = "cbg__0002_3",
            chipBgIcon = "cbgsp_di2",
            BoxIcon = "cbg_icon_2_0001_2",
            ChipIcon = "cbg_icon__0001_2",
            ShopChipIcon = "tf_bs2",
            Tip = "เปิดใช้ได้รับชิปหรือคำสาปมังกร(ซิลเวอร์) และมีโอกาสได้รับการ์ดพิเศษ*1วัน",
        },
        [3] = {
            typeID = 3000,
            ID = 1003,
            ChipNum = 15,
            Name = "หีบสมบัติหรูหรา",
            BgIcon = "cbg__0001_2",
            chipBgIcon = "cbgsp_di3",
            BoxIcon = "cbg_icon_2_0002_3",
            ChipIcon = "cbg_icon__0002_3",
            ShopChipIcon = "tf_bs3",
            Tip = "เปิดใช้ได้รับชิปหรือคำสาปมังกร(ทองคำ) และมีโอกาสได้รับการ์ดพิเศษ*1วัน",
        },
        [4] = {
            typeID = 4000,
            ID = 1004,
            ChipNum = 15,
            Name = "หีบสมบัติมรดก",
            BgIcon = "cbg__0000_1",
            chipBgIcon = "cbgsp_di4",
            BoxIcon = "cbg_icon_2_0003_4",
            ChipIcon = "cbg_icon__0003_4",
            ShopChipIcon = "tf_bs4",
            Tip = "เปิดใช้ได้รับชิปหรือคำสาปมังกร(เพชร) และมีโอกาสได้รับการ์ดพิเศษ*1วัน",
        },
    }
}

return lan