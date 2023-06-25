local NewPayGiftConfig = {
	--炮台排行榜所有炮台
    --3002（二人）,3005（四人）,3007（飞机）
	batteryInfo = {
        {
            id = 1140,
            prefab = "Battery_1140",
            colour = "Green",
            GameType = {3007},
            Score = 1,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่มรกต",
            Des = "绿色战机"
        },
        {
            id = 1141,
            prefab = "Battery_1141",
            colour = "Green",
            GameType = {3007},
            Score = 1,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่นภา",
            Des = "蓝色战机"
        },
        {
            id = 1142,
            prefab = "Battery_1142",
            colour = "Green",
            GameType = {3002,3005},
            Score = 1,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่ระดับ1",
            Des = "1级炮台"
        },
        {
            id = 1143,
            prefab = "Battery_1143",
            colour = "Green",
            GameType = {3002,3005},
            Score = 3,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่ระดับ2",
            Des = "2级炮台"
        },
        {
            id = 1144,
            prefab = "Battery_1144",
            colour = "Green",
            GameType = {3002,3005},
            Score = 5,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่ระดับ3",
            Des = "3级炮台"
        },
        {
            id = 1145,
            prefab = "Battery_1145",
            colour = "Green",
            GameType = {3002,3005},
            Score = 5,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่ระดับ4",
            Des = "4级炮台"
        },
        {
            id = 1146,
            prefab = "Battery_1146",
            colour = "Green",
            GameType = {3002,3005},
            Score = 5,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่ระดับ5",
            Des = "5级炮台"
        },
        {
            id = 1139,
            prefab = "Battery_1139",
            colour = "Blue",
            GameType = {3007},
            Score = 10,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่ทองคำ",
            Des = "金色战机"
        },
        {
            id = 1147,
            prefab = "Battery_1147",
            colour = "Blue",
            GameType = {3002,3005},
            Score = 5,
            Animator = true,
            Spine = false,
            Name = "เกราะสีทอง",
            Des = "黄金甲炮台"
        },
        {
            id = 1148,
            prefab = "Battery_1148",
            colour = "Blue",
            GameType = {3002,3005},
            Score = 15,
            Animator = true,
            Spine = false,
            Name = "พาลาดิน",
            Des = "圣骑炮台"
        },
        {
            id = 1149,
            prefab = "Battery_1149",
            colour = "Blue",
            GameType = {3002,3005},
            Score = 50,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่แพนด้า",
            Des = "五福熊猫炮台"
        },
        {
            id = 1110,
            prefab = "Battery_1110",
            colour = "Purple",
            GameType = {3002,3005,3007},
            Score = 60,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่แมวกวัก",
            Des = "招财猫炮台"
        },
		{
            id = 1011,
            prefab = "Battery_1011",
            colour = "Purple",
            GameType = {3005},
            Score = 60,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่ช้างไทย",
            Des = "大象炮台"
        },
        {
            id = 1123,
            prefab = "Battery_1123",
            colour = "Purple",
            GameType = {3002,3005},
            Score = 60,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่อัคคี",
            Des = "炽焰炮台"
        },
        {
            id = 1129,
            prefab = "Battery_1129",
            colour = "Purple",
            GameType = {3002,3005,3007},
            Score = 60,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่กระต่ายจัทรา",
            Des = "玉兔炮台"
        },
        {
            id = 1136,
            prefab = "Battery_1136",
            colour = "Purple",
            GameType = {3005},
            Score = 60,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่เค้ก",
            Des = "蛋糕炮台"
        },
        {
            id = 1138,
            prefab = "Battery_1138",
            colour = "Purple",
            GameType = {3002,3005,3007},
            Score = 60,
            Animator = true,
            Spine = false,
            Name = "ปืนใหญ่ปืนฉีดน้ำ",
            Des = "水枪炮台"
        },
        {
            id = 1125,
            prefab = "Battery_1125",
            colour = "Orange",
            GameType = {3002,3005},
            Score = 100,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่หงส์ไฟ",
            Des = "朱雀炮台"
        },
        {
            id = 1127,
            prefab = "Battery_1127",
            colour = "Orange",
            GameType = {3002,3005},
            Score = 100,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่พยัคฆ์ขาว",
            Des = "白虎炮台"
        },
        {
            id = 1151,
            prefab = "Battery_1151",
            colour = "Orange",
            GameType = {3002,3005,3007},
            Score = 100,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่มังกรฟ้า",
            Des = "青龙炮台"
        },
        {
            id = 4023,
            prefab = "Battery_4023",
            colour = "Orange",
            GameType = {3002,3005},
            Score = 100,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่เต่าดำ",
            Des = "玄武炮台"
        },
        {
            id = 9094,
            prefab = "Battery_9094",
            colour = "Orange",
            GameType = {3002,3005,3007},
            Score = 100,
            Animator = true,
            Spine = true,
            Name = "ปืนใหญ่ปาร์ตี้ฟุตบอล",
            Des = "足球炮台"
        },
		{
			id = 1154,
			prefab = "Battery_1154",
			colour = "Orange",
			GameType = {3002,3005},
			Score = 100,
			Animator = true,
			Spine = true,
			Name = "ปืนใหญ่ดนตรี",
			Des = "电音炮台"
		},
	},
}

return NewPayGiftConfig