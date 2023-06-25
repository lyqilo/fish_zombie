local lan =
{
	[2] = "ชิป", -- EPC_ChouMa
	[7] = "โทรโข่ง", -- EPC_Speaker
	[22] = "บัตรของขวัญ", -- EPC_GiftVoucher
	[23] = "ห้อง",
	[26] = "ดอกลีลาวดี",
	[28] = "บัตรเปลี่ยนชื่อ",
	[29] = "ชิ้นส่วนบัตรเติมเงิน",
	[35] = "ฟักทอง",
	[37] = "อุปกรณ์หมวกคริสต์มาส",
	[38] = "โคมไฟจีน",
	[46] = "บัตรของขวัญ",
	[1006] = "ตอร์ปิโดเงิน(ส่งให้)",
	[1007] = "ตอร์ปิโดทองคำ(ส่งให้)",
	[1012] = "มิสไซล์ทองแดง",
	[1013] = "มิสไซล์เงิน",
	[1014] = "มิสไซล์ทองคำ",
	[1015] = "มิสไซล์แพลทินัม",
	[1016] = "ตอร์ปิโดทองแดง(ส่งให้)",
	[1017] = "ตอร์ปิโดสวรรค์(ส่งให้)",
	[1022] = "มิสไซล์ทองแดง",
	[1030] = "อุปกรณ์อัญเชิญ",
	[1031] = "นิวเคลียร์ทองแดง",
	[1032] = "นิวเคลียร์ซิลเวอร์",
	[1033] = "นิวเคลียร์ทองคำ",
	[1034] = "นิวเคลียร์แพลตตินั่ม",
	[1035] = "นิวเคลียร์ทองแดง(ส่งให้)",
	[1036] = "นิวเคลียร์ซิลเวอร์(ส่งให้)",
	[1037] = "นิวเคลียร์ทองคำ(ส่งให้)",
	[1038] = "นิวเคลียร์แพลตตินั่ม(ส่งให้)",
	[1043] = "อุปกรณ์อัญเชิญเครื่องบิน",
	[1044] = "ชิ้นส่วนอาวุธวงล้อระดับต้น",
	[1045] = "ชิ้นส่วนอาวุธวงล้อระดับกลาง",
	[1046] = "ชิ้นส่วนอาวุธวงล้อระดับสูง",
	[1047] = "ชิ้นส่วนอาวุธวงล้อมืออาชีพ",
	[1048] = "อาวุธวงล้อระดับต้น",
	[1049] = "อาวุธวงล้อระดับกลาง",
	[1050] = "อาวุธวงล้อระดับสูง",
	[1051] = "อาวุธวงล้อมืออาชีพ",
	[1101] = "คราดเก้าซี่",
	[1102] = "ประกาศิตทองแดงมหาศึกชิงบัลลังก์",
	[1103] = "ประกาศิตซิลเวอร์มหาศึกชิงบัลลังก์",
	[1104] = "ประกาศิตทองคำมหาศึกชิงบัลลังก์",
	[1105] = "ประกาศิตเพชรมหาศึกชิงบัลลังก์",
	[1106] = "การ์ดสิทธิ์พิเศษมหาศึกชิงบัลลังก์",
	[1107] = "รองเท้าแตะ",
	[2006] = "50บัตรเติมเงิน",
	[2007] = "150บัตรเติมเงิน",
	[2008] = "300บัตรเติมเงิน",
	[2009] = "500บัตรเติมเงิน",
	[2010] = "1000บัตรเติมเงิน",
	[2011] = "90บัตรเติมเงิน",
	[3001] = "กรอบดอกลีลาวดี",
	[3002] = "กรอบดอกลั่นทม",
	[3003] = "โปรไฟล์เซ็นชื่อมือใหม่",
	[3004] = "กรอบฮาโลวีน",
	[3005] = "กรอบฮาโลวีน",
	[3016] = "กรอบคริสต์มาสทั่วไป",
	[3017] = "กรอบคริสต์มาสระดับสูง",
	[3023] = "กรอบโปรไฟล์วันตรุษจีนทั่วไป",
	[3024] = "กรอบโปรไฟล์วันตรุษจีนระดับสูง",
	[4001] = "ตั๋วแข่งดัมมี่ทัวร์นาเม้นท์",
	[4002] = "คูปองคืนชีพแข่งดัมมี่ทัวร์นาเม้นท์",
	[4003] = "ตั๋วแข่งดัมมี่ชิงรางวัล",
	[4004] = "คูปองคืนชีพแข่งดัมมี่ชิงรางวัล",
	[4005] = "ตั๋วแข่งดัมมี่ห้องVIP",
	[4006] = "คูปองคืนชีพแข่งดัมมี่ห้องVIP",
	[4007] = "ตั๋วแข่งดัมมี่คัดออก",
	[7011] = "จดหมายลับสเปโต",
	[8001] = "การ์ดเพิ่มกำไร",
	[9005] = "Slot500การ์ดฟรีเกม",
	[9006] = "Slot1000การ์ดฟรีเกม",
	[9007] = "Slot10000การ์ดฟรีเกม",
	[10001] = "50บัตรเติมเงิน", -- EPC_50Card
	[10002] = "150บัตรเติมเงิน", -- EPC_150Card
	[10003] = "300บัตรเติมเงิน", -- EPC_300Card
	[10004] = "500บัตรเติมเงิน", -- EPC_500Card
	[10005] = "1000บัตรเติมเงิน", -- EPC_1000Card
	[10006] = "90บัตรเติมเงิน",
	[20001] = "Oppo A3s",
	[20002] = "Vivo Y17",
	[20003] = "ทองแผ่นเล็ก",
	[20004] = "iPhone XR",
	[20005] = "Samsung A80",
	[20006] = "สร้อยทอง1สลึง-1THB",
	[20007] = "สร้อยทอง1สลึง-0.5THB",
	[20008] = "Samsung A30",
	[20009] = "Vivo S1",
	[20010] = "Oppo A9 2020",
	[20011] = "Oppo A5 2020",
	[20012] = "iPhone11 64GB",
	[20013] = "iPhone11 Pro",
	[20014] = "Samsung S10+",
	[20015] = "Galaxy Note10+",
	[20016] = "Huiwei Y7",
	[20017] = "Vivo Y11",
	[20018] = "Samsung A10s",
	[20019] = "Oppo A31 2020",
	[20020] = "ipad10.2",
	[20021] = "iPhoneSE 2020",
	[20022] = "Oppo A92 2020",
	[20023] = "vivo Y50",
	[20024] = "สร้อยทอง1สลึง-0.25THB",
	[20025] = "iPad Gen8",

	--道具描述
	des2 = "ในเล่นในแต่ละเกม",
	des7 = "สามารถใช้ประกาศได้ที่ช่องแชท",
	des22 = "นำไปใช้ได้ที่ร้านแลกโดยจะแลกรางวัลหรือใช้ชิงรางวัลก็ได้",
	des23 = "ที่เกมดัมมี่ ใช้สำหรับเปิดห้องเล่นด้วยกันกับเพื่อน",
	des26 = "ใช้ในช่วงกิจกรรมวันสงกรานต์แลกกรอบโปรไฟล์พิเศษ",
	des28 = "สามารถใช้เปลี่ยนชื่อเล่นได้",
	des29 = "ช่องทางที่ได้รับ:\nเซ็นชื่อมือใหม่ ภารกิจมือใหม่ \nเข้าร่วมแข่งขัน ซื้อแพ็คเกจ",
	des35 = "สามารถเข้าร่วมเซ็นชื่อ7วันหรือได้รับจากกิจกรรมกาชา",
	des37 = "หลังสะสมครบจะแลกกรอบโปรไฟล์คริสต์มาสพิเศษได้",
	des38 = "หลังสะสมครบใช้แลกกรอบโปรไฟล์พิเศษลิมิเต็ดวันตรุษจีนได้",
	des1006 = "ที่เกมยิงปลา2คน หลังใช้งานจะได้รับรางวัลมากสุด750ชิป",
	des1007 = "ที่เกมยิงปลา2คน หลังใช้งานจะได้รับรางวัลมากสุด7500ชิป",
	des1012 = "ที่เกมยิงปลา4คน หลังใช้งานจะได้รับรางวัลมากสุด24000ชิป",
	des1013 = "ที่เกมยิงปลา4คน หลังใช้งานจะได้รับรางวัลมากสุด120000ชิป",
	des1014 = "ที่เกมยิงปลา4คน หลังใช้งานจะได้รับรางวัลมากสุด600000ชิป",
	des1015 = "ที่เกมยิงปลา4คน หลังใช้งานจะได้รับรางวัลมากสุด3000000ชิป",
	des1016 = "ที่เกมยิงปลา2คน หลังใช้งานจะได้รับรางวัลมากสุด75000ชิป",
	des1017 = "ที่เกมยิงปลา2คน หลังใช้งานจะได้รับรางวัลมากสุด750000ชิป",
	des1022 = "ที่เกมยิงปลา4คน หลังใช้งานจะได้รับรางวัลมากสุด24000ชิป",
	des1030 = "หลังใช้งาน ในห้องที่เล่น จะอัญเชิญปลาชนิดใหญ่1ตัว",
	des1031 = "ที่เกมยิงเครื่องบิน หลังใช้จะได้รับชิปพอสมควร",
	des1032 = "ที่เกมยิงเครื่องบิน หลังใช้จะได้รับชิปพอสมควร",
	des1033 = "ที่เกมยิงเครื่องบิน หลังใช้จะได้รับชิปจำนวนมาก",
	des1034 = "ที่เกมยิงเครื่องบิน หลังใช้จะได้รับชิปจำนวนมหาศาล",
	des1035 = "ที่เกมยิงเครื่องบิน หลังใช้จะได้รับชิปพอสมควร",
	des1036 = "ที่เกมยิงเครื่องบิน หลังใช้จะได้รับชิปพอสมควร",
	des1037 = "ที่เกมยิงเครื่องบิน หลังใช้จะได้รับชิปจำนวนมาก",
	des1038 = "ที่เกมยิงเครื่องบิน หลังใช้จะได้รับชิปจำนวนมหาศาล",
	des1043 = "ที่เกมยิงเครื่องบินใช้เรียกเครื่องบินออกมาได้",
	des1044 = "ใช้ได้ที่เกมยิงเครื่องบินรบห้องระดับต้น อัญเชิญอาวุธวงล้อออกมา",
	des1045 = "ใช้ได้ที่เกมยิงเครื่องบินรบห้องระดับกลาง อัญเชิญอาวุธวงล้อออกมา",
	des1046 = "ใช้ได้ที่เกมยิงเครื่องบินรบห้องระดับสูง อัญเชิญอาวุธวงล้อออกมา",
	des1047 = "ใช้ได้ที่เกมยิงเครื่องบินรบห้องมืออาชีพ อัญเชิญอาวุธวงล้อออกมา",
	des1048 = "ใช้ได้ที่เกมยิงเครื่องบินรบห้องระดับต้น โดยใช้เพชรอัญเชิญอาวุธวงล้อ",
	des1049 = "ใช้ได้ที่เกมยิงเครื่องบินรบห้องระดับกลาง โดยใช้เพชรอัญเชิญอาวุธวงล้อ",
	des1050 = "ใช้ได้ที่เกมยิงเครื่องบินรบห้องระดับสูง โดยใช้เพชรอัญเชิญอาวุธวงล้อ",
	des1051 = "ใช้ได้ที่เกมยิงเครื่องบินรบห้องมืออาชีพ โดยใช้เพชรอัญเชิญอาวุธวงล้อ",
	des1101 = "หลังใช้งานจะได้รับสูงสุด50ครั้ง ฟรีเกมสูงสุด12000เท่า",
	des1102 = "ที่เกมมหาศึกชิงบัลลังก์ ปล่อยพลังความโกรธของเจ้ามังกร1ครั้งมูลค่าคือ 50*100",
	des1103 = "ที่เกมมหาศึกชิงบัลลังก์ ปล่อยพลังความโกรธของเจ้ามังกร1ครั้งมูลค่าคือ 200*100",
	des1104 = "ที่เกมมหาศึกชิงบัลลังก์ ปล่อยพลังความโกรธของเจ้ามังกร1ครั้งมูลค่าคือ 1000*100",
	des1105 = "ที่เกมมหาศึกชิงบัลลังก์ ปล่อยพลังความโกรธของเจ้ามังกร1ครั้งมูลค่าคือ 5000*100",
	des1106 = "ที่เกมมหาศึกชิงบัลลังก์ เพลิดเพลินการใช้พลังงาน-1 ปุ่มฟังก์ชั่นจัดทัพรวดเดียวและฮีโร่พิเศษ อีกทั้งสิทธิ์พิเศษอื่นๆ",
	des1107 = "อาวุธรองเท้าแตะลิมิเต็ด",
	des2006 = "",
	des2007 = "",
	des2008 = "",
	des2009 = "",
	des2010 = "",
	des2011 = "นำไปใช้ได้ที่ร้านแลกโดยจะแลกรางวัลหรือใช้ชิงรางวัลก็ได้",
	des3001 = "สงกรานต์ปี2020กรอบโปรไฟล์ใหม่ขอให้คุณมีความสุข",
	des3002 = "สงกรานต์ปี2020กรอบโปรไฟล์ใหม่ขอให้สุขภาพแข็งแรง",
	des3003 = "สามารถได้รับจากกิจกรรมเซ็นชื่อมือใหม่",
	des3004 = "ได้รับจากการนำฟักทองฮาโลวีนไปแลก",
	des3005 = "ได้รับจากการนำฟักทองฮาโลวีนไปแลก",
	des3016 = "กรอบโปรไฟล์พิเศษคริสต์มาสกิจกรรมเซ็นชื่อ",
	des3017 = "กรอบโปรไฟล์พิเศษคริสต์มาสกิจกรรมเซ็นชื่อ",
	des3023 = "กรอบโปรไฟล์พิเศษกิจกรรมวันตรุษจีน",
	des3024 = "กรอบโปรไฟล์พิเศษกิจกรรมวันตรุษจีน",
	des4001 = "ที่เกมดัมมี่ ใช้สำหรับเข้าแข่งทัวร์นาเม้นท์",
	des4002 = "ที่เกมดัมมี่ ใช้สำหรับคืนชีพแข่งทัวร์นาเม้นท์อีกครั้ง",
	des4003 = "ที่เกมดัมมี่ ใช้สำหรับเข้าแข่งชิงรางวัล",
	des4004 = "ที่เกมดัมมี่ ใช้สำหรับคืนชีพแข่งชิงรางวัลอีกครั้ง",
	des4005 = "ที่เกมดัมมี่ ใช้สำหรับเข้าแข่งห้องVIP",
	des4006 = "ที่เกมดัมมี่ ใช้สำหรับคืนชีพแข่งห้องVIP",
	des4007 = "ที่เกมดัมมี่ ใช้สำหรับเข้าแข่งคัดออก",
	des7011 = "จดหมายลับจะปลดล็อคได้\nที่เกมดัมมี่ต้องเกิดไพ่\nพิเศษหรือฝาก ♣2หรือ♠Q",
	des8001 = "การ์ดเพิ่มกำไรใช้ที่เกมป๊อกเด้งลุ้นรับรูปแบบไพ่พิเศษ เกมนี้ได้รับสูงสุด40M",
	des9005 = "ได้เข้าโหมดฟรีเกมโดยใช้ค่าลงเดิมพัน500",
	des9006 = "ได้เข้าโหมดฟรีเกมโดยใช้ค่าลงเดิมพัน1000",
	des9007 = "ได้เข้าโหมดฟรีเกมโดยใช้ค่าลงเดิมพัน10000",
	des10001 = "",
	des10002 = "",
	des10003 = "",
	des10004 = "",
	des10005 = "",
	des20011 = "",
	des20012 = "",
	des20013 = "",
	des20014 = "",
	des20015 = "",
}

return lan