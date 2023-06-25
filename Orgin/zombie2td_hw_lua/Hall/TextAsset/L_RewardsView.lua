local CC = require("CC")

local lan =
{
	["VIP"] = "รางวัลอัพระดับVIP",
	["VIPLogin"] = "รางวัล VIP เข้าสู่ระบบพิเศษ",
	["SevenDays"] = "แพ็คเกจของขวัญ 7วันสุดคุ้ม",
	["FristPay"] = "แลกชิปสำเร็จ",
	["BindFacebook"] = "รางวัลผูกFacebook",
	["BindLine"] = "รางวัลผูกLine",
	["BindPhone"] = "รางวัลข้อมูลครบถ้วน",
	["CommonGet"] = "ได้รับ",
	["OnlineAward"] = "รางวัลออนไลน์",
	["NoviceGift"] = "ของขวัญมือใหม่",
	["LimmitAward"] = "ล็อกอินแจกรางวัล",
	["FundDaliyAward"]="รางวัลล็อกอินกองทุน 7วัน",
	["BlessLotteryAward"] = "รางวัลพรปีใหม่",
	["Fortunebag"] = "รางวัลถุงนำโชค",
	["FestivalLoginReward"] = "รางวัลล็อกอิน",
	["FestivalRechargeReward"] = "รางวัลเติมเงิน",
	["SignAward"] = "รางวัลเซ็นชื่อ",
	["BoxAward"] = "รางวัลสมบัติ",
	["ExchangeGoods"] = "แลกสำเร็จ",
	["ChipReplenish"] = "รางวัลชิปชดเชยประจำวัน",
	["DailyTurntable"] = "วงล้อประจำวัน",
	["LimitTimeGift"] = "แพ็คจำกัดเวลา",
	["LuckyTurntable"] = "วงล้อนำโชค",
	["TreasureGift"] = "ล่าสมบัติประจำวัน",
	["Capsule"] = "ยินดีด้วยคุณได้รับรางวัล",
	["CapsuleEx"] = "รางวัลพิเศษ",
	["VipThreeCard"] = "รางวัลอัพระดับVIP3",
	["Composite"] = "การต่อสู้หลอมรวม",

	SpecialRewardsTips = "กดที่หน้าจอที่ใดก็ได้จะทำต่อ",
	MailRewardTips = "โชคดีมาแล้ว! หลังจากได้รับแล้วกรุณาไปที่ระบบจดหมายเพื่อตรวจสอบ",
	PointCard = "กรุณาไปที่ระบบจดหมายตรวจสอบรหัสบัตรเติมเงินของคุณ",
	PointCard_1 = "อย่าลืมไปเช็ครางวัลที่จดหมายนะ！",
	BackPack = "อุปกรณ์ทีได้รับเก็บอยู่ที่กระเป๋าแล้ว สามารถไปที่โปรไฟล์ส่วนตัว-กระเป๋าเพื่อตรวจสอบ",
	BtnUse = "ใช้",
	BtnShare = "แบ่งปัน",
	BtnClose = "ได้รับ",
	BtnComposite = "ไปหลอมรวม",
	BtnCapsule = "เปิดกาชาปอง",

	------------------------------------------------------------分享----------------------------------------------------------------------
	Value = "THB",
	--每日抽奖
	[CC.shared_transfer_source_pb.TS_Daily_Lottery.."ShareBG"] = "share_1_2",
	[CC.shared_transfer_source_pb.TS_Daily_Lottery.."SharePropText1"] = "รีบมาดูฉันที่เกม《Royal Casino》เข้าร่วมกิจกรรมจับรางวัลฟรี",
	[CC.shared_transfer_source_pb.TS_Daily_Lottery.."SharePropText2"] = "ได้รับรางวัล%sมูลค่า%sคุณก็รีบมาลองเล่นกันเถอะ~",
	--每日礼包签到
	[CC.shared_transfer_source_pb.TS_DailyGiftSign_Reward.."ShareBG"] = "fx_10",
	[CC.shared_transfer_source_pb.TS_DailyGiftSign_Reward.."SharePropText1"] = "รีบมาดูฉันที่เกม《Royal Casino》เข้าร่วมกิจกรรมจับรางวัลแพ็คเกจประจำวัน",
	[CC.shared_transfer_source_pb.TS_DailyGiftSign_Reward.."SharePropText2"] = "ได้รับ%sรางวัลมูลค่า%s และยังมีรางวัลใหญ่JACKPOT~รีบมาเข้าร่วมกันเถอะ~",
	--实物兑换分享
	[CC.shared_transfer_source_pb.TS_PhysicalGoods.."ShareBG"] = "fx_5",
	[CC.shared_transfer_source_pb.TS_PhysicalGoods.."SharePropText1"] = "",
	[CC.shared_transfer_source_pb.TS_PhysicalGoods.."SharePropText2"] = "",
}

return lan