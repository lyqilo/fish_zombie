local NewPayGiftConfig = {
	--活动时间
	time = "26.05.2023 - 04.06.2023",
	--奖励展示（目前5个气泡+预览列表）
	boxRewards = {
		--进入界面时默认展示
		box0 = {
			--预览页宝箱图片
			boxImg = "",
			--奖励列表 id:道具id, text:数量文本, icon:特殊icon,不填则默认展示道具id对应icon
			list = {
				{id = 20024, text = "", icon = ""},
				{id = 20091, text = "", icon = ""},
				{id = 20087, text = "", icon = ""},
				{id = 20075, text = "", icon = ""},
				{id = 10004, text = "", icon = ""},
				{id = 10003, text = "", icon = ""},
				{id = 10002, text = "", icon = ""},
				{id = 10001, text = "", icon = ""},
				{id = 71, text = "1-20", icon = ""},
			}
		},
		--宝箱1
		box1 = {
			boxImg = "lkb_bx_01",
			list = {
				{id = 10001, text = "", icon = ""},
				{id = 2, text = "1K-4K", icon = ""},
			}
		},
		--宝箱2
		box2 = {
			boxImg = "lkb_bx_01",
			list = {
				{id = 10002, text = "", icon = ""},
				{id = 2, text = "5K-20K", icon = ""},
				{id = 2, text = "", icon = "dj_jackpot"},
			}
		},
		--宝箱3
		box3 = {
			boxImg = "lkb_bx_02",
			list = {
				{id = 20075, text = "", icon = ""},
				{id = 10002, text = "", icon = ""},
				{id = 2, text = "24K-96K", icon = ""},
				{id = 2, text = "", icon = "dj_jackpot"},
			}
		},
		--宝箱4
		box4 = {
			boxImg = "lkb_bx_02",
			list = {
				{id = 20075, text = "", icon = ""},
				{id = 10002, text = "", icon = ""},
				{id = 2, text = "50K-200K", icon = ""},
				{id = 71, text = "1", icon = ""},
				{id = 2, text = "", icon = "dj_jackpot"},
			}
		},
		--宝箱5
		box5 = {
			boxImg = "lkb_bx_03",
			list = {
				{id = 20075, text = "", icon = ""},
				{id = 10003, text = "", icon = ""},
				{id = 2, text = "120K-480K", icon = ""},
				{id = 71, text = "2", icon = ""},
				{id = 2, text = "", icon = "dj_jackpot"},
			}
		},
		--宝箱6
		box6 = {
			boxImg = "lkb_bx_03",
			list = {
				{id = 20075, text = "", icon = ""},
				{id = 10003, text = "", icon = ""},
				{id = 2, text = "220K-880K", icon = ""},
				{id = 71, text = "5", icon = ""},
				{id = 2, text = "", icon = "dj_jackpot"},
			}
		},
		--宝箱7
		box7 = {
			boxImg = "lkb_bx_04",
			list = {
				{id = 20075, text = "", icon = ""},
				{id = 10004, text = "", icon = ""},
				{id = 2, text = "625K-2.5M", icon = ""},
				{id = 71, text = "10", icon = ""},
				{id = 2, text = "", icon = "dj_jackpot"},
			}

		},
		--宝箱8
		box8 = {
			boxImg = "lkb_bx_05",
			list = {
				{id = 20075, text = "", icon = ""},
				{id = 10004, text = "", icon = ""},
				{id = 2, text = "1M-4M", icon = ""},
				{id = 71, text = "20", icon = ""},
				{id = 2, text = "", icon = "dj_jackpot"},
			}
		}
	},
	
	--排行榜奖励展示
	rankRewards = {
		--第1名
		{id = 20024, text = " <size=30>x1</size>"},
		--第2名
		{id = 20091, text = " <size=30>x1</size>"},
		--第3名
		{id = 20087, text = " <size=30>x1</size>"},
		--第4-10名
		{id = 10004, text = " <size=30>x1</size>"},
		--第11-20名
		{id = 10003, text = " <size=30>x1</size>"}
	},

	--帮助说明  渠道图标格式channel_渠道名 如：channel_bay
	ChineseExplain = {
		Title = "活动说明",
		Content = "本次充值活动持续时间为: %s"
				.."\n活动规则："
				.."\n活动期间，玩家通过第三方渠道累计充值满规定数额就可以进行相应的抽奖。"
				.."\n任意抽奖有机会获得实物大奖、点卡以及巨额JackPot。"
				.."\n第三方充值渠道下的不同子渠道根据系数的不同会获得不同的积分，根据累计的积分进行排行榜排名。"
				.."\n活动期间排行榜累计积分达到前20名的玩家将会获得："
				.."\n1：%s"
				.."\n2：%s"
				.."\n3：%s"
				.."\n4-10：%s"
				.."\n11-20：%s"
				.."\n注：请各位玩家及时领取奖励，领奖界面将会在活动结束后关闭。"
				.."\n子渠道积分计算表：",
		ChannelTitle = {
			{"渠道图标", "子渠道", "系数"},
			{"channel_bay", "bay", 1},
			{"channel_bbl", "bbl", 1},
			{"channel_ktb", "ktb", 1},
			{"channel_scb", "scb", 1},
			{"channel_kbank", "kbank", 1},
			{"channel_12call", "12call", 0.5},
			{"channel_truemoney", "truemoney", 0.5},
			{"channel_molpoints", "molpoints", 0.5},
			{"channel_psms", "truemoveh", 0.2},
			{"channel_ais", "ais", 0.2},
			{"channel_truewallet", "truewallet", 1},
			{"channel_linepay", "linepay", 1},
			{"channel_dcb", "dcb", 0.2},
		},
	},
	ThaiExplain = {
		Title = "คำอธิบายกิจกรรม",
		Content = "ระยะเวลากิจกรรมเติมเงินครั้งนี้: %s"
				.."\nกติกา："
				.."\nในช่วงกิจกรรม ผู้เล่นที่เติมเงินสะสมตามจำนวนที่กำหนดและผ่านช่องทางที่กำหนด จึงจะสามารถเข้าร่วมในการจับรางวัลที่เกี่ยวข้องได้ "
				.."\nจับรางววัลใดก็ได้มีโอกาสได้รับของรางวัลสุดพิเศษ บัตรเติมเงิน รวมไปถึงรางวัล Jackpot "
				.."\nช่องทางการเติมเงินแต่ละช่องทางจะได้รับคะแนนตัวคูณแตกต่างกัน การจัดอันดับขึ้นอยู่กับคะแนนสะสม"
				.."\nการจัดอันดับขึ้นอยู่กับคะแนนสะสม"
				.."\nผู้เล่นที่ติดอันดับ 20 คนแรกในช่วงกิจกรรมจะได้รับ:"
				.."\n1：%s"
				.."\n2：%s"
				.."\n3：%s"
				.."\n4-10：%s"
				.."\n11-20：%s"
				.."\nหมายเหตุ: ผู้เล่นทุกคนต้องรับรางวัลให้ทันเวลา"
				.."\nหน้าหลักของกาารรับรางวัลจะปิดหลังจากกิจกรรมสิ้นสุดลง"
				.."\nตารางคำนวณคะแนน:",
		ChannelTitle = {
			{"ไอคอน", "ช่องทาง", "ตัวคูณ"},
			{"channel_bay", "bay", 1},
			{"channel_bbl", "bbl", 1},
			{"channel_ktb", "ktb", 1},
			{"channel_scb", "scb", 1},
			{"channel_kbank", "kbank", 1},
			{"channel_12call", "12call", 0.5},
			{"channel_truemoney", "truemoney", 0.5},
			{"channel_molpoints", "molpoints", 0.5},
			{"channel_psms", "truemoveh", 0.2},
			{"channel_ais", "ais", 0.2},
			{"channel_truewallet", "truewallet", 1},
			{"channel_linepay", "linepay", 1},
			{"channel_dcb", "dcb", 0.2},
		},
	}
}

return NewPayGiftConfig