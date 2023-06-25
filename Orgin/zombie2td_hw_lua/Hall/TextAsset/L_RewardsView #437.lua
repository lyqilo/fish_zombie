local CC = require("CC")

local lan =
{
	["VIP"] = "VIP升级奖励",
	["VIPLogin"] = "VIP额外登录奖励",
	["SevenDays"] = "七天贵族礼包",
	["FristPay"] = "首充奖励",
	["BindFacebook"] = "Facebook绑定奖励",
	["BindLine"] = "Line绑定奖励",
	["BindPhone"] = "信息完善奖励",
	["CommonGet"] = "获得",
	["OnlineAward"] = "在线奖励",
	["NoviceGift"] = "新手礼包",
	["LimmitAward"] = "登录有礼",
	["FundDaliyAward"]="七日基金登陆奖励",
	["BlessLotteryAward"] = "新年祝福奖励",
	["Fortunebag"] = "福袋奖励",
	["FestivalLoginReward"] = "登陆奖励",
	["FestivalRechargeReward"] = "充值奖励",
	["SignAward"] = "签到奖励",
	["BoxAward"] = "宝箱奖励",
	["ExchangeGoods"] = "兑换成功",
	["ChipReplenish"] = "每日筹码补齐奖励",
	["DailyTurntable"] = "每日转盘",
	["LimitTimeGift"] = "限时礼包",
	["LuckyTurntable"] = "幸运转盘",
	["TreasureGift"] = "每日寻宝",
	["Capsule"] = "恭喜获得奖励",
	["CapsuleEx"] = "额外奖励",
	["VipThreeCard"] = "Vip3晋级奖励",
	["Composite"] = "合成大作战",

	SpecialRewardsTips = "กดที่หน้าจอที่ใดก็ได้จะทำต่อ",
	MailRewardTips = "幸运降临！领取后请前往邮箱查看详情。",
	PointCard = "请前往邮箱查看您的卡密信息哦!",
	PointCard_1 = "请前往邮箱查看您的实物奖励信息哦！",
	BackPack = "获取的道具已存放至背包，可前往个人信息-背包查看",
	BtnUse = "使用",
	BtnShare = "分享",
	BtnClose = "确定",
	BtnComposite = "去合成",
	BtnCapsule = "去扭蛋",

	------------------------------------------------------------分享----------------------------------------------------------------------
	Value = "THB",
	--每日抽奖
	[CC.shared_transfer_source_pb.TS_Daily_Lottery.."ShareBG"] = "share_1_2",
	[CC.shared_transfer_source_pb.TS_Daily_Lottery.."SharePropText1"] = "快来看下我在《Royal Casino》参与了每日抽奖活动",
	[CC.shared_transfer_source_pb.TS_Daily_Lottery.."SharePropText2"] = "获得了%s奖励价值%s，你也快来试试吧~",
	--每日礼包签到
	[CC.shared_transfer_source_pb.TS_DailyGiftSign_Reward.."ShareBG"] = "fx_10",
	[CC.shared_transfer_source_pb.TS_DailyGiftSign_Reward.."SharePropText1"] = "快来看下我在《Royal Casino》参与了每日礼包抽奖活动",
	[CC.shared_transfer_source_pb.TS_DailyGiftSign_Reward.."SharePropText2"] = "获得了%s奖励价值%s，还有更大JACKPOT大奖~快来一起参与吧~",
	--实物兑换分享
	[CC.shared_transfer_source_pb.TS_PhysicalGoods.."ShareBG"] = "fx_5",
	[CC.shared_transfer_source_pb.TS_PhysicalGoods.."SharePropText1"] = "",
	[CC.shared_transfer_source_pb.TS_PhysicalGoods.."SharePropText2"] = "",
}

return lan