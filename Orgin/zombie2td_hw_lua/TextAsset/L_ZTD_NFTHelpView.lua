
local HelpConfig = { }

HelpConfig = {

}

HelpConfig.dayPool = {   
	[1] = [[<color=#929fbeff><size=22>（1）เวลาแจกรางวัลพ็อตประจำวัน:หลังทุกวันเที่ยงคืน0:00น</size></color>]],
	[2] = [[<color=#929fbeff><size=22>（2）หลังฤดูกาลแข่งขันเริ่มต้น ใช้ชิปโจมตีมอนสเตอร์ มีโอกาสดรอป"ภาพการ์ดพลังคำนวณ"  ห้องระดับสูง มีโอกาสดรอปการ์ดพลังคำนวณระดับสูง</size></color>]],
	[3] = [[<color=#929fbeff><size=22>（3）หลังผู้เล่นใส่ภาพการ์ดพลังคำนวณแล้ว จะได้เข้าร่วมการปันผลพ็อตรางวัลเซิร์เวอร์ที่แจกทุกวัน</size></color>]],
	[4] = [[<color=#929fbeff><size=22>（4）ตามพลังการคำนวณของการ์ดทั้ง3ใบที่ผู้เล่นติดตั้งอยู่ แบ่งชิปและรางวัลFRTจากพ็อตประจำวันตามสัดส่วนพลังคำนวณทั้งหมดของเซิร์ฟเวอร์ พลังคำนวณยิ่งสูง รางวัลที่ได้แบ่งจะยิ่งมาก</size></color>]],
	[5] = [[<color=#929fbeff><size=22>（5）โดยนับที่พลังคำนวณภาพการ์ด3ใบของผู้เล่นที่ใส่ทั้งหมด คิดตามอัตราส่วนพลังคำนวณจากทั้งเซิร์ฟเวอร์แบ่งพ็อตรางวัลชิป พลังคำนวณยิ่งสูง ก็จะได้แบ่งอัตราพ็อตรางวัลยิ่งมากขึ้น</size></color>]],
	[6] = [[<color=#929fbeff><size=22>（6）หลังจากแจกรางวัลพ็อตประจำวันแล้ว โปรดกดที่ปุ่มสมบัติด้านขวาล่างที่หน้าพ็อตรางวัลเพื่อรับ สามารถกดรับรางวัลชิปสะสมหลายวันในครั้งเดียว</size></color>]],
}

HelpConfig.seasonPool = {   
	pool1 = {
		[[<color=#929fbeff><size=22>（1）เวลาแจกรางวัลพ็อตฤดูกาลแข่งขัน:ฤดูกาลแข่งขันหลังเที่ยงคืน00:00น.วันสุดท้าย</size></color>]],
		[[<color=#929fbeff><size=22>（2）หลังฤดูกาลแข่งขันเริ่มต้น ใช้ชิปโจมตีมอนสเตอร์ จะมีโอกาสดรอป"ภาพการ์ดพลังคำนวณ" ห้องระดับสูง มีโอกาสดรอปการ์ดพลังคำนวณระดับสูง</size></color>]],
		[[<color=#929fbeff><size=22>（3）เมื่อฤดูกาลแข่งขันสิ้นสุด จะโดยนับที่พลังคำนวณภาพการ์ด3ใบของผู้เล่นที่ใส่ทั้งหมดในฤดูการแข่งขันนี้ นำมาจัดอันดับ อันดับยิ่งสูงรางวัลที่ได้รับยิ่งมาก</size></color>]]
--กติกราปันผลพ็อตรางวัลแข่งขันประจำฤดูกาล：</size></color>]]
	},
	poolItem1 = [[<color=#929fbeff><size=22>อันดับที่%d:พ็อตรางวัลฤดูกาล%.1f%%</size></color>]],
	poolItem2 = [[<color=#929fbeff><size=22>อันดับที่%d~%d:พ็อตรางวัลฤดูกาล%.1f%%</size></color>]],
	pool2 = {
		[[<color=#929fbeff><size=22>（4）โดยนับที่พลังคำนวณภาพการ์ด3ใบของผู้เล่นที่ใส่ทั้งหมด คิดตามอัตราส่วนพลังคำนวณจากทั้งเซิร์ฟเวอร์แบ่งพ็อตรางวัลชิป พลังคำนวณยิ่งสูง ก็จะได้แบ่งอัตราพ็อตรางวัลยิ่งมากขึ้น</size></color>]],
		[[<color=#929fbeff><size=22>（5）นอกจากปันผลพ็อตชิป หีบสมบัติ NFT จะออกตามพลังคำนวณทั้งหมดของผู้เล่นด้วย ในนั้นพลังคำนวณ1แต้มจะได้รับสมบัติทองแดง1กล่อง 100แต้มจะได้รับสมบัติซิลเวอร์1กล่อง 10000แต้มจะได้รับสมบัติทองคำ1กล่อง</size></color>]],
		[[<color=#929fbeff><size=22>（6）สมบัติNFTสามารถเปิดได้เหรียญFRTหรือการ์ดNFTถาวร การ์ดNFTสามารถใช้ได้กับโหมด“พ็อตขุดFRT”</size></color>]],
		[[<color=#929fbeff><size=22>（7）หลังจากแจกรางวัลพ็อตประจำฤดูกาลแล้ว โปรดกดที่ปุ่มสมบัติด้านขวาล่างที่หน้าพ็อตรางวัลเพื่อรับ สามารถกดรับรางวัลชิปสะสมหลายฤดูกาลในครั้งเดียว</size></color>]],
		[[<color=#929fbeff><size=22>（8）หลังจบฤดูกาล จะเรียกคืน"ภาพการ์ดพลังคำนวณ"ทั้งหมดที่ดรอปไปในฤดูกาลนี้ และหลังเริ่มฤดูกาลแข่งขันถัดไป จะปล่อยภาพการ์ดออกมาใหม่</size></color>]],
	}

}

HelpConfig.pack = {   
	[1] = [[<color=#929fbeff><size=22>（1）ลิสต์รายการด้านขวา จะแสดงรายการภาพการ์ดคุณสมบัติประเภทต่างๆ ในปัจจุบันทั้งหมดของคุณ</size></color>]],
	[2] = [[<color=#929fbeff><size=22>（2）จะอาศัยการลากหรือกดคลิกภาพการ์ด สวมใส่อุปกรณ์ไปยังแถบด้านซ้ายที่ว่าง3ตำแหน่ง เวลานี้พลังคำนวณของการ์ดจะมีผลเป็นทางการ คุณสามารถใส่ได้สูงสุด3ใบ</size></color>]],
	[3] = [[<color=#929fbeff><size=22>（3）คุณสามารถกดคลิกที่ภาพการ์ดของหน้าต่างด้านบน เปิดหน้าคุณสมบัติของการ์ด เพื่อดำเนินการ "ปรับแต่ง"หรือสวมใส่/ถอดออก</size></color>]],
	[4] = [[<color=#929fbeff><size=22>（4）ปรับแต่งการ์ด จะต้องใช้เหรียญFRTตามกำหนด หลังปรับแต่งสำเร็จ การคำนวณพลังการ์ดจะเพิ่มขึ้นเล็กน้อย</size></color>]],
	[5] = [[<color=#929fbeff><size=22>（5）อาศัยการลากหรือกดคลิกปุ่มวางเข้าจำนวนมาก จะใช้การ์ด5ใบที่เหมือนกันวางเข้าแถบหลอมรวมที่มุมซ้ายล่าง และใช้เหรียญFRTที่กำหนด เพื่อดำเนินการหลอมรวม</size></color>]],
	[6] = [[<color=#929fbeff><size=22>（6）หลังสำเร็จการหลอมรวมการ์ด จะได้รับการ์ดที่ดาวที่มีคุณสมบัติสูงอีกขั้น1ใบ และคุณสมบัติเพิ่มสูงขึ้น</size></color>]],
	[7] = [[<color=#929fbeff><size=22>（7）หากมีการ์ดที่ไม่ต้องการ สามารถไปที่หน้าทำ"การตลาด" เพื่อขายออก และที่ทำธุรกรรมFRTสามารถซื้อการ์ดจากผูกอื่นได้</size></color>]],
}


return HelpConfig