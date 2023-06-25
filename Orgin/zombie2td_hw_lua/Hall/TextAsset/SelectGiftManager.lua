local CC = require("CC")

local SelectGiftManager = {}

SelectGiftManager.CreateIcon = function (param)
	local icon = CC.ViewCenter.SelectGiftIcon.new()
	icon:Init("SelectGiftIcon", param.parent, param)
	return icon
end

SelectGiftManager.CreateSlotIcon = function (param)
	local icon = CC.ViewCenter.SlotSelectGiftIcon.new()
	icon:Init("SlotSelectGiftIcon", param.parent, param)
	return icon
end

SelectGiftManager.CreateIconWithoutDailyGift = function (param)
	local icon = CC.ViewCenter.SelectGiftIconWithoutDailyGift.new()
	icon:Init("SelectGiftIcon", param.parent, param)
	return icon
end

SelectGiftManager.CreateDialyIcon = function (param)
	local icon = CC.ViewCenter.DailyGiftIcon.new()
	icon:Init("DailyGiftIcon", param.parent, param)
	return icon
end

SelectGiftManager.CreateSlotBrokeGiftIcon = function (param)
	local icon = CC.ViewCenter.SlotBrokeGiftIcon.new()
	icon:Init("SlotBrokeGiftIcon", param.parent, param)
	return icon
end

SelectGiftManager.DestroyIcon = function (icon)
	icon:Destroy()
end

SelectGiftManager.CheckNoviceGiftCanBuy = function()
	if not CC.ChannelMgr.GetSwitchByKey("bHasGift") then
		return false;
	end
	local EPC_VIPGiftPackage = CC.Player.Inst():GetSelfInfoByKey("EPC_VIPGiftPackage");
	local activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	if EPC_VIPGiftPackage == 0 and activityDataMgr.GetActivityInfoByKey("NoviceGiftView").switchOn then
		return true;
	end
	return false;
end

SelectGiftManager.CheckMonthCard = function()
	--更新月卡红点状态
	local card1 = CC.Player.Inst():GetSelfInfoByKey("EPC_Super") or 0
	local card2 = CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") or 0
	if card1 > 0 or card2 > 0 then
		CC.Request("ReqGetMothCardUseInfo",nil,function(err,data)
			local monthCardRed = (card1 > 0 and not data.Super.IsDailyLogin) or (card2 > 0 and not data.Supreme.IsDailyLogin)
			CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetActivityInfoByKey("MonthCardView", {redDot = monthCardRed})
		end)
	end
end

return SelectGiftManager