local CC = require("CC")
local HolidayDiscountsViewCtr = CC.class2("HolidayDiscountsViewCtr")

function HolidayDiscountsViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function HolidayDiscountsViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
end

function HolidayDiscountsViewCtr:OnCreate()
    self:RegisterEvent()
end

function HolidayDiscountsViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqOrderStatusResq,CC.Notifications.NW_GetOrderStatus)
    CC.HallNotificationCenter.inst():register(self,self.ReqAugGiftPayRewardRecordResp,CC.Notifications.NW_ReqAugGiftPayRecord)

    CC.HallNotificationCenter.inst():register(self,self.OnPurchaseNotifyResp,CC.Notifications.OnPurchaseNotify)
    CC.HallNotificationCenter.inst():register(self,self.DailyGiftHoliday,CC.Notifications.OnDailyGiftGameReward)
    CC.HallNotificationCenter.inst():register(self,self.OnAugGiftPayRewardRecord,CC.Notifications.OnAugGiftPayRewardRecordPush)
    CC.HallNotificationCenter.inst():register(self,self.LoadGiftStatus,CC.Notifications.OnTimeNotify)
    CC.HallNotificationCenter.inst():register(self,self.UserVipChanged,CC.Notifications.VipChanged)
end

function HolidayDiscountsViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function HolidayDiscountsViewCtr:ReqOrderStatusResq(err,data)
    log(CC.uu.Dump(data, "ReqOrderStatusResq"))
    if err == 0 and data.Items and #(data.Items) > 0 then
        for _, v in ipairs(data.Items) do
			for _, giftdata in ipairs(self.view.ShowGiftData) do
				if v.WareId == giftdata.WareId then
                    giftdata.Status = v.Enabled
                    if v.CountDown > 0 then
                        self.view.countDown = v.CountDown
                    end
					break
				end
            end
        end
    end
    self.view:RefreshUI()
end

function HolidayDiscountsViewCtr:LoadGiftStatus()
    local wareIds = self.view.GiftLevel[self.view.Level]
    log(string.format("当前vip等级为V%s，展示的是%s %s %s %s 礼包",CC.Player.Inst():GetSelfInfoByKey("EPC_Level"),wareIds[1],wareIds[2],wareIds[3],wareIds[4]))
    CC.Request.GetOrderStatus(wareIds)
end

function HolidayDiscountsViewCtr:UserVipChanged(curLevel)
    --VIP等级变化，刷新礼包档位
    self.view:SelectGiftLevel(curLevel)
end

function HolidayDiscountsViewCtr:ReqAugGiftPayRewardRecordResp(err,data)
    log(CC.uu.Dump(data, "ReqAugGiftPayRewardRecordResp",4))
    if err == 0 and data.Records and #(data.Records) > 0 then
        for i,v in ipairs(data.Records) do
            self:ShowBroadCast(v)
        end
    end
end

--购买成功
function HolidayDiscountsViewCtr:OnPurchaseNotifyResp(data)
    log(CC.uu.Dump(data, "OnPurchaseNotifyResp"))
	for i,v in ipairs(self.view.ShowGiftData) do
		if v.WareId == data.WareId then
			CC.Request.GetOrderStatus({data.WareId})
			return
		end
	end
end

function HolidayDiscountsViewCtr:DailyGiftHoliday(data)
    local isShowReward = data.Source == CC.shared_transfer_source_pb.TS_AugGiftPay1 or data.Source ==CC.shared_transfer_source_pb.TS_AugGiftPay2
                        or data.Source==CC.shared_transfer_source_pb.TS_AugGiftPay3 or data.Source==CC.shared_transfer_source_pb.TS_AugGiftPay4
                        or data.Source==CC.shared_transfer_source_pb.TS_AugGiftPay5 or data.Source==CC.shared_transfer_source_pb.TS_AugGiftPay6
    if not isShowReward then return end
    log(CC.uu.Dump(data, "DailyGiftHoliday"))

    if data.Source ~= CC.shared_transfer_source_pb.TS_AugGiftPay5 and data.Source ~= CC.shared_transfer_source_pb.TS_AugGiftPay6 then
        self:OpenSignInView()
    end

    CC.ViewManager.OpenRewardsView({items = data.Rewards})
end

function HolidayDiscountsViewCtr:OpenSignInView()
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowDailyGiftCollectionView, false);
	CC.ViewManager.Open("GiftSignInView", {closeFunc = function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowDailyGiftCollectionView, true);
	end});
end

function HolidayDiscountsViewCtr:OnAugGiftPayRewardRecord(data)
    log(CC.uu.Dump(data, "OnAugGiftPayRewardRecord"))
    local Record = data.Record
    if Record then
        self:ShowBroadCast(Record)
    end
end

function HolidayDiscountsViewCtr:ShowBroadCast(Record)
    local ConfigId = Record.Rewards.ConfigId
    local ware = self.propLanguage[ConfigId]
    local Broad = "Broad1"
    if  tonumber(ConfigId) == 2 then
        ware = Record.Rewards.Count..self.propLanguage[ConfigId]
    elseif tonumber(ConfigId) == 4 then
        ware = ""
        Broad= "Broad2"
    end
    local GiftName = ""
    for i,v in ipairs(self.view.GiftLevel[self.view.Level]) do
        if v == Record.wareId then
            GiftName = self.view.language["Gift"..i]
            break
        end
    end

    local UserName = string.gsub(Record.Name, "<", "《")
    UserName = string.gsub(UserName, ">", "》")

    if GiftName ~= "" then
        local str = string.format(self.view.language[Broad], UserName , GiftName, ware)
        if self.view.Marquee then
              self.view.Marquee:Report(str)
        end
    end
end

function HolidayDiscountsViewCtr:Destroy()

	self:UnRegisterEvent();
end

return HolidayDiscountsViewCtr;
