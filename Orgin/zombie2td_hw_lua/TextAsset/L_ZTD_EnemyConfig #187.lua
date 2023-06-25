local lan =
{
	[10009] = 
	{
		desc = "โจมตีใช้จ่ายสองเท่า หลังสู้ชนะจะสุ่มได้รับไข่มุกหมี3ลูก อัตราคูณของไข่มุกหมีจะคูณเป็นอัตราจ่ายรางวัลสุดท้าย";
		name = "หมีระเบิด",
		desc_r = "สูงสุด1600เท่า",
	},
	[10008] = 
	{
		desc = "หลังฆ่ายักษ์จะอัญเชิญวิญญาณบรรพบุรุษ จะสร้างความเสียหาย2~3รอบสูงสุด6เท่า";
		name = "ยักษ์สงคราม",
		desc_r = "สุ่ม",
	},
	[10007] = 
	{
		desc = "หลังสัตว์ประหลาดออกมามีโอกาสติดเอฟเฟคก์[เชื่อมสัมพันธ์] ทั้งหมดที่[เชื่อมสัมพันธ์]จะมีชีวิตร่วมกัน โจมตีถอยกลับไปเพียงตัวเดียว สัตว์ประหลาดตัวอื่นๆก็จะถอนทั้งหมด";
		name = "เชื่อมสัมพันธ์",
		desc_r = "สุ่ม",
	},
	[10006] = 
	{
		desc = "ทุกครั้งโจมตีใช้คะแนน2เท่า ต่อเนื่อง3ที:ต่อเนื่องได้รางวัล3ครั้ง;รางวัลเพิ่มเท่า:รางวัลปัจจุบันเพิ่ม2~4เท่า;รางวัลลุ้นซ้ำ:สุ่มรางวัล3ครั้ง;ลองใหม่อีกครั้ง:สุ่มรางวัลอีก1ครั้ง",
		name = "ซัคคิวบัส",
		desc_r = "สูงสุด1040เท่า",
	},
	[10005] = 
	{
		desc = "ปีศาจลูกบอลหลังถูกโจมตีพ่ายแพ้ จะระเบิดตัวในบริเวณรอบๆสามที สุ่มโจมตีปีศาจที่อยู่ในบริเวณ เมื่อระเบิดสังหารปีศาจตนอื่นได้จะได้รับรางวัล1-3เท่า",
		name = "ปีศาจลูกบอล",
		desc_r = "100",
	},
	[10004] = 
	{
		desc = "ราชาแห่งความมืด หากถูกโจมตีขับไล่จะอัญเชิญ\nเจ้ามังกรที่มีจิตปีศาจออกมา มันจะพ่น\nเปลวไฟเกล็ดน้ำแข็งทำลายทุกสรรพสิ่ง \nเจ้ามังกรโจมตีในสนามรบสูงสุดได้300ครั้ง",
		name = "ราชาแห่งความมืด",
		desc_r = "สูงสุด300เท่า",
	},
	[10003] = 
	{
		desc = "เหมายันฤดูหนาวให้กำเนิดดินแดนแห่งเปลวไฟ\nทหารปีศาจได้รับผลกระทบดินแดนแห่งเปลวไฟ\nทำให้ร่างกายแข็งแกร่งขึ้นมหาศาล ทุกครั้งโจมตี\nจะใช้แต้มพื้นฐาน2เท่า หากสู้ชนะปีศาจนักรบ\nปลวไฟจะได้รับรางวัลมหาศาล สูงสุดถึง480เท่า",
		name = "ปีศาจนักรบเปลวไฟ",
		desc_r = "สูงสุด480",
	},
	[10002] = 
	{
		desc = "ปีศาจอันมีพลังแข็งแกร่งที่อยู่ในดินแดนน้ำแข็ง \nทั้งกายหุ้มด้วยน้ำแข็งทำให้การเข้าโจมตียากมาก \nทุกครั้งโจมตีจะใช้แต้มพื้นฐาน1เท่า \nหากโจมตีขับไล่จะได้รับรางวัลสูงสุด38เท่า",
		name = "ปีศาจน้ำแข็ง",
		desc_r = "สูงสุด38",
	},
	[10001] = 
	{
        desc = "สู้ชนะจะปลดปล่อย“ลูกระเบิด”หลังลูกระเบิดระเบิด\nแล้วจะได้รางวัลคืนจำนวนมาก และมีโอกาสขับไล่\nมอนสเตอร์จำนวนหนึ่งในระยะ ทุกครั้งที่ปลดปล่อย\nระเบิด มีโอกาสดูดกลืนเป้าหมายที่อยู่ใกล้เคียง \nดูดกลืนเป้าหมายจะปลดปล่อยลูกระเบิดที่รางวัล\nเดียวเหมือนกับปีศาจระเบิด ดูดกลืนระเบิด\nรางวัลพื้นฐานสูงสุด160เท่า ถ้าได้รับจากการโจมตีฟรี \nยังสามารถได้อัตราคูณที่มากกว่าขีดจำกัด!",
		name = "ปีศาจระเบิด",
		desc_r = "16~160",
	},
	[4000] = 
	{
		desc = "ทหารภายใต้ของราชาแห่งความมืด \nชำนาญการใช้หอก มีพละกำลังมาก \nทุกครั้งโจมตีจะใช้แต้มพื้นฐาน1เท่า \nโจมตีขับไล่ปีศาจชั่วร้ายจะได้รับรางวัลสุ่ม\n18-22เท่า",
		name = "ปีศาจชั่วร้าย",
		desc_r = "18~22",
	},
	[4001] = 
	{
		desc = "รางกายดูอ่อนแอ แต่เพราะมีไหวพริบ\nมากกว่าปีศาจทั่วไปจึงถูกให้ความสำคัญ \nทุกครั้งโจมตีจะใช้แต้มพื้นฐาน1เท่า \nสู้ชนะปีศาจวิญญาณจะได้รับรางวัลสุ่ม12-16เท่า",
		name = "ปีศาจวิญญาณ",
		desc_r = "12~16",
	},
    [4002] = 
	{
		desc = "เป็นทหารรับใช้ของราชาแห่งความมืด \nดาบเล่มใหญ่ในมือของมันมีความอันตรายมาก \nทุกครั้งโจมตีจะใช้แต้มพื้นฐาน1เท่า \nหากโจมตีขับไล่จะได้รับรางวัลสุ่ม6-10เท่า",
		name = "ปีศาจทหาร",
		desc_r = "6~10",
	},
    [4004] = 
	{
		desc = "รูปร่างปราดเปรียว ถนัดการใช้ปีกบิน \nชอบซ่อนเร้นกาย ค้นหาเจอได้ยากมาก \nหากโจมตีขับไล่จะได้รับรางวัล3-5เท่า",
		name = "แมลงปีศาจ",
		desc_r = "3~5",
    },
    [4003] = 
    {
		desc = "ความรู้สึกไวต่อกลิ่น ตื่นตัวตลอดเวลา \nมีการเคลื่อนไหวที่ไร้เสียง เป็นผู้รับใช้\nเฝ้าปราสาทราชาแห่งความมืด \nหากโจมตีขับไล่จะได้รับรางวัล2-3เท่า",
		name = "หมาปีศาจ",
		desc_r = "2~3",
    },

}

return lan
