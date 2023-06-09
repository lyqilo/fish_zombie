local lan =
{
	btn_NewInvitation = "ผู้เล่นใหม่มีรายได้",
	btn_Invitation = "เงินสนับสนุนหมื่นล้าน",
	btn_Revenue = "ผลกำไรของฉัน",
	btn_Share = "โค้ดโปรโมทของฉัน",
	btn_Grades = "ระดับของฉัน",
	btn_Rank = "อันดับรายได้โปรโมท",
	e0 = "ผลกำไรรวม",
	e1 = "ผลกำไรเกม",
	e2 = "ผลกำไรโปรโมท",
	e3 = "ผลกำไรส่งชิป",

	btnFB = "FaceBook",
	btnLine = "Line",
	btnOther = "Other",
	codelabel = "โค้ดโปรโมทของฉัน :",
	shareTips = "กรอกโค้ดนี้ รับทันที100000ชิปฟรี",

	sharetitle = "แชร์",
	sharecopylink = "คัดลอกลิงค์",
	sharecopysucc = "คัดลอกสำเร็จ",

	ruletitle = "คำอธิบาย",
	rulemaintext = "ยินดีด้วยคุณได้เป็นผู้โปรโมท! รีบไปทําภารกิจโปรโมทกันเถอะ!",
	rulecontent1 = "ทุกครั้งที่โปรโมทให้เพื่อนคุณเข้าเล่นเกม คุณจะได้รับผลกำไรจากเกม เล่นยิ่งมากผลกำไรก็ยิ่งเยอะ!",
	rulecontent2 = "ทุกครั้งโปรโมทเพื่อนเมื่อถึงเงื่อนไขตามยอดระดับการแอคทีฟของเกม คุณก็จะได้รับผลกำไรการโปรโมท โปรโมทชวนเพื่อนยิ่งมากผลกำไรก็ยิ่งเยอะขึ้น!",
	rulecontent3 = "ทุกครั้งเมื่อโปรโมทเพื่อนอาศัยฟังก์ชั่นส่งชิปและได้รับชิป คุณก็จะได้รับผลกำไรจากการส่งชิป ส่งชิปยิ่งมากผลกำไรส่งชิปก็ยิ่งเยอะ!",

	earningstitle = "ค้นหาผลกำไร",
	earningstotal0 = "ยอดกำไรได้รับสะสมรวม:",
	earningstotal1 = "ยอดกำไรเล่นเกมได้รับสะสมรวม:",
	earningstotal2 = "ยอดกำไรที่โปรโมทสะสมรวม:",
	earningstotal3 = "ยอดกำไรที่ส่งชิปสะสมรวม:",
	earningstime = "เวลาที่ได้รับ",
	earningsnum = "จำนวนได้รับ",
	earningstype = "ประเภทผลกำไร",

	generalizetitle = "ประวัติการโปรโมท",
	generalizetotal = "จำนวนคนโปรโมทสะสมทั้งหมด:",
	generalizeyear = "ปี%d",
	generalizemonth = {"ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.", "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."},
	generalizenum = "จำนวนคนโปรโมท:",

	juniortitle = "ข้อมูลระดับล่าง",
	juniornum = "จำนวนคนระดับล่าง:",

	juniorname = "ชื่อ",
	juniortime = "time",

	agentbtntips1 = "ผลกำไรส่งชิป",
	agentbtntips2 = "ผลกำไรเกม",
	agentbtntips3 = "ผลกำไรโปรโมท",
	agentbtntips9 = "โปรโมทชวนเพื่อน",
	timeout = "คำขอเกินเวลา กรุณาลองใหม่",

	receiveTip = "คุณมีรางวัลที่ยังไม่ได้รับ",
	taskTitle = "ภารกิจโปรโมท",
	taskName = "รายชื่อภารกิจ",
	taskReward = "รางวัล",
	taskCompletion = "ความสำเร็จของเพื่อน",
	taskEarn = "ผลกำไร",
	taskUndone = "ขณะนี้ยังไม่มีเพื่อนทำสำเร็จ",
	taskLook = "<u>ดูเพิ่มเติม</u>",
	taskGet = "รับ",
	taskShare = "แจ้งกับเพื่อนให้ทำภารกิจสำเร็จ",
	totalEarn = "รอรับผลกำไรทั้งหมด:",
	btnAll = "รับทั้งหมด",
	taskTip = "ผลกำไรจากภารกิจโปรโมท ถ้าภายใน48ชั่วโมง\nไม่ได้กดรับด้วยตนเอง ระบบจะส่งให้อัตโนมัติ\nภารกิจโปรโมทจำเป็นต้องสำเร็จภายใน72ชั่วโมง",
	taskTipText = "มีเพียงแค่ระดับล่างที่ผูกบัญชีแล้วถึงจะสำเร็จภารกิจได้",
	agentTask = {
		[1] = "ลงเดิมพันถึง30000",
		[2] = "เติมเงินสะสมถึง29",
		[3] = "เติมเงินสะสมถึง300",
		-- [1] = "เพื่อนที่สมัครบัญชีใหม่\n(ไม่ใช่นักท่องเที่ยว)",
		-- [2] = "ผูกเบอร์โทรศัพท์OTP\n(จะต้องสำเร็จภารกิจนี้ก่อน)",
		-- [3] = "เพื่อนเข้าร่วมเล่นเกม\n(จะต้องสำเร็จภารกิจนี้ก่อน)",
		-- [4] = "สะสมเติมเงิน29THB",
	},

	UnderlingTitle = {
        [1] = "เพื่อนที่สมัครบัญชีใหม่",
		[2] = "ผูกเบอร์โทรศัพท์OTP",
		[3] = "เพื่อนเข้าร่วมเล่นเกม",
		[4] = "สะสมเติมเงิน29THB",
		[5] = "ลงเดิมพันถึง30000",
		[6] = "เติมเงินสะสมถึง29",
		[7] = "เติมเงินสะสมถึง300",
    },
	UnderlingNone = "ปัจจุบันยังไม่มีบันทึก",
	UnderlingSave = "บันทึกจะเก็บรักษาไว้เพียง7วัน",
	UnderlingShow = "แต่ละหน้าจะแสดง100รายการ",
	UnderlingTotalNum = "ทั้งหมด%sคนทำเสร็จ",
	UnderlingId = "บัญชี",
	UnderlingVip= "ระดับVIP",
	UnderlingEarn = "ผลกำไร",
	UnderlingState = "สถานะการรับ",
	UnderlingTime = "เวลาที่สำเร็จ",
	UnderlingTick = "ยังไมได้รับ",

	Placeholder = "กรอกข้อความ",
	vip = "VIP",

	earnViewDes = "บัญชีนักท่องเที่ยวจะไม่คำนวณรางวัลส่วนแบ่งให้ มีเพียงผูกบัญชีสำเร็จหรือเบอร์โทรศัพท์ถึงจะคำนวณรางวัลส่วนแบ่งให้",
	proxyTitle = "โค้ดโปรโมท",
	proxyDesText = "กรอกใส่โค้ดโปรโมทของเพื่อน ได้รับทันที<color=#FFF900>100,000</color>ชิป!",
	proxyBtnText = "ส่ง",
	proxyTipText = "รางวัลโปรโมทจะส่งไปที่จดหมาย โปรดตรวจสอบ",
	proxyBlindText = "คุณถูกโปรโมทแล้ว",
	notice_proxy_fail = "การผูกล้มเหลว ระบบตรวจพบอุปกรณ์ผิดปกติ",
	timeout_tip = "คำขอเกินเวลา กรุณาลองใหม่",
	guestBlindTip = "ปัจจุบันบัญชีนักท่องเที่ยวไม่สามารถได้รับรางวัล100000ชิป ผูกบัญชีหรือเบอร์โทรศัพท์จะได้รับ",
	invitationPlay = "เชิญTAช่วยเหลือ",
	invitationTip = "จำนวนเพื่อนที่ช่วยเหลือสำเร็จ: %sคน",
	invitationAward = "การช่วยเหลือจากเพื่อนสำเร็จ จะได้รับฟรี <size=28><color=#BDF8FF>100,000</color></size> รางวัลชิป",
	invitationBtnGuide = "รับรางวัล",
	invitationGuideText1 = "ยินดีด้วยคุณชวนเพื่อน7คนมาช่วยเหลือแล้ว",
	invitationGuideText2 = "ตอนนี้ไปที่【ผลกำไรของฉัน】รับรางวัลบัตรของขวัญ\nสะสมบัตรของขวัญครบ14000ใบไปที่【ร้านแลกรางวัล】\nแลกบัตรเติมเงิน50THBได้นะ!",
	invitationGuideBtn = "รับทันที",
	InvitationText = "เชิญเพื่อน%sคนได้",

	Marquee_1 = "<color=#FFFFFFFF>ยินดีด้วย <color=#13FF00FF>%s</color> ผ่านการเชิญเพื่อนได้รับบัตรของขวัญ<color=#00FFFFFF>%s</color>ใบ <color=#FBFF00FF>%s</color>ชิป</color>",
	Marquee_2 = "<color=#FFFFFFFF>ยินดีด้วย <color=#13FF00FF>%s</color> ผ่านการเชิญเพื่อนได้รับบัตรของขวัญ<color=#FBFF00FF>%s</color>ชิป</color>",
	Marquee_3 = "<color=#FFFFFFFF>ยินดีด้วย <color=#13FF00FF>%s</color> ผ่านการเชิญเพื่อนได้รับบัตรของขวัญ<color=#00FFFFFF>%s</color>ใบ</color>",
	Marquee_4 = "<color=#FFFFFFFF>Oh My God ยินดีด้วย <color=#13FF00FF>%s</color> ผ่านการเชิญเพื่อนได้รับบัตรของขวัญ<color=#00FFFFFF>%s</color>ใบ <color=#FBFF00FF>%s</color>ชิปฟรี!</color>",
	Marquee_5 = "<color=#FFFFFFFF>Oh My God ยินดีด้วย <color=#13FF00FF>%s</color> ผ่านการเชิญเพื่อนได้รับบัตรของขวัญ<color=#FBFF00FF>%s</color>ชิปฟรี!</color>",
	Marquee_6 = "<color=#FFFFFFFF>Oh My God ยินดีด้วย <color=#13FF00FF>%s</color> ผ่านการเชิญเพื่อนได้รับบัตรของขวัญ<color=#00FFFFFF>%s</color>ใบ!</color>",
	freeGet = "ชวนเพื่อน",
	totalEran = "ผลกำไรรวมสะสม",
	Invite = "เชิญแล้ว:",
	InviteSucced = "เมื่อวานระดับล่างที่แอคทีฟ:",
	noneEarn = "ปัจจุบันไม่มีรางวัลที่ได้รับชั่วคราว รีบไปชวนเพื่อนจะได้รับรางวัล!",
	TradeEarn = "รายได้การส่ง",
	ShareEarn = "ผลกำไรเกม",
	NewerEarn = "รายได้ค่าหัว",
	ShareEarnTip = "ผู้เล่นระดับล่างของคุณใช้ชิปเล่นเกม\nระบบจะนำรางวัลชิปส่วนหนึ่งให้คุณคุณ",
	TradeEarnTip = "เมื่อผู้เล่นระดับล่างของคุณส่งชิป\nระบบจะนำรางวัลชิปส่วนหนึ่งให้กับคุณ",

	ranking = "อันดับ",
	rankName = "ข้อมูลผู้เล่น",
	rankPeople = "จำนวนคนโปรโมทรายสัปดาห์",
	rankAward = "รางวัลอันดับ",
	rankPeopleTip = "นับเพียงผู้เล่นที่สำเร็จภารกิจเดิมพันในภารกิจโปรโมท\nไม่สะสมรวมผู้เล่นแอคทีฟที่ระดับล่างช่วยโปรโมท",
	rankEmpty = "ไม่มีบันทึก",
	rankMy = "อันดับของฉัน:",
	rankRequire = "สําเร็จขั้นตํ่า50คนมีสิทธิ์รับรางวัล",
	rankExplain = "ทุกวันจันทร์ 00:00น. รีเฟรชอันดับใหม่\nข้อมูลอันดับทุก5นาทีอัพเดท1ครั้ง",
	rankFreeTaxTip = "เปิดใช้อัตโนมัติ หลังเปิดใช้ฟรีค่าธรรมเนียมส่ง1สัปดาห์",
	rankLast = "อันดับสัปดาห์ก่อน",
	rankCur = "อับดับสัปดาห์นี้",

	myGradesTip = "ภารกิจประจำวันสัปดาห์ถ้าไม่สำเร็จจะถูกลด1ระดับ!",
	myGradesBtnGet = "แชร์ทันที",
	myGradesReward = "รางวัล",
	myGradesNeedPeople = "สัปดาห์นี้โปรโมท %sคน",
	myGradesPeopleTip = "นับเพียงผู้เล่นที่สำเร็จภารกิจเดิมพันในภารกิจโปรโมท\nสะสมรวมผู้เล่นแอคทีฟที่ระดับล่างช่วยโปรโมท",
	myGradesCountDown = "ภารกิจประจำวันสัปดาห์:",
	myGradesTime = "คงเหลือ:%sวัน%sชั่วโมง",
	myGradesCurLevel = "ระดับปัจจุบัน:",
	myGradesNextLevel = "ระดับถัดไป:",
	myGradesSend = "สิทธิ์ผลกำไรการส่ง %s",
	myGradesDivide = "อัตราส่วนแบ่งค่าลงเดิมพัน %s",
	myGradesTable = "อัตราส่วนแบ่งค่าภาษีโต๊ะ %s",
	myGradesAnimTip = "นับตามจำนวนคนโปรโมทของคุณปัจจุบัน มากำหนดอันดับ ยศของคุณคือ%s! รีบไปตรวจสอบสิทธิประโยชน์จากระดับยศ",
	myGradesAnimUpgrade = "ยินดีด้วยคุณทำภารกิจประจำสัปดาห์%sสำเร็จ อัพระดับถึงยศ%s ได้รับรางวัลสมบัติ%s โปรดไปที่จดหมายตรวจสอบ",
	myGradesAnimDegrade = "คุณสัปดาห์นี้ทำภารกิจประจำสัปดาห์%sไม่สำเร็จ ลดลงถึงยศ%s",
	myGradesBtn = "ตกลง",
	myGradesList = {[1] = "แร่เหล็ก", [2] = "Bronze", [3] = "Silver", [4] = "Gold", [5] = "Diamond", [6] = "King"},
	myGradesRule1 = "1.เมื่อทำภารกิจประจำสัปดาห์สำเร็จ จะได้รับรางวัลสิทธิพิเศษตามระดับดังกล่าวในสัปดาห์ถัดไป รางวัลภารกิจสัปดาห์อิงตามระดับสูงสุดที่ทำสำเร็จเท่านั้น ไม่ใช่การแจกรางวัลแบบสะสม",
	myGradesRule2 =	"2.จำนวนคนที่มีผลจะนับแค่ที่ผูกกับบัญชีFacebookหรือLINEเท่านั้นและผู้เล่นระดับล่างยังต้องเล่นเดิมพันครบ30000(สำเร็จภายใน3วัน)",
	myGradesRule3 =	"3.ห้ามพฤติกรรมการทุจริตต่างๆ หากตรวจสอบพบเจอ จะระงับบัญชีทันที",
	myGradesRuleLevel = "ระดับ",
	myGradesRuleSend = "ส่วนแบ่งการส่ง",
	myGradesRuleDivide = "ส่วนแบ่งค่าลงเดิมพัน",
	myGradesRuleTable = "ส่งแบ่งค่าโต๊ะ",
	myGradesLock = "ปลดล็อคผลกำไร",

	shareGuide = "หลังจากที่แชร์ จะแลกวอลเล็ทได้ทันที 20THB",
	auditTip = "บัญชีของคุณอยู่ในสถานะระหว่างตรวจสอบ โปรดรอผลการตรวจสอบก่อน",
	auditPeriod = "บัญชีของคุณอยู่ในสถานะระหว่างตรวจสอบ",
	auditTime = "เวลาปลดล็อคผลกำไรที่จะได้รับ ：%s",
	auditRankAward = "หากบัญชีของคุณอยู่ในระหว่างตรวจสอบ\nจะไม่สามารถรับรางวัลอันดับประจำสัปดาห์ได้\nผู้ที่ได้รับรางวัลหลังจากผลการตรวจสอบผ่านแล้ว\nโปรดรีบติดต่อฝ่ายบริการเพื่อขอรับรางวัลอันดับ",
	limit_topText = "เหลือเวลา: ",
	limit_LTitle = "เชิญเพื่อน2คน",
	limit_RTitle = "20THB",
	tips_Text = "ได้รับสะสมทั้งหมด:%s THB",
	guide_Text = "อัพเป็นVIP1จะได้รับรางวัลอั่งเปาทันที！",
}

return lan