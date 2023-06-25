local CC = require("CC")

local HallViewCtr = require("View/HallView/HallViewCtr")
local TrailIOSHallViewCtr = CC.class2("TrailIOSHallViewCtr",HallViewCtr)


function TrailIOSHallViewCtr:InitData()

	self:CheckActiveSwitch()

	if CC.Player.Inst():GetLoginState() then

		self.view:DelayRun(1,function ()
			self.view:FindChild("Mask"):SetActive(false)
		    if CC.ChannelMgr.GetAndroidTrailStatus() then
		        return false;
			end
			local funcList = {
				self.CheckDynamicLinkInstallData,
				self.CheckDynamicLinkWakeupData,
				self.CheckFacebookDeepLinkData,
				self.CheckGuide,
				self.CheckBehindView
			}
			for _,func in ipairs(funcList) do
				if func(self) then
					break;
				end
			end
		end)

		CC.Player.Inst():SetLoginState(false)

		-- self:ReConnectGame()
		-- --请求历史聊天记录
		-- self:LoadHisChatData();
		-- --拉取私聊信息
		-- self:LoadPrivate()
		--请求邮件数据
		self:LoadMailData();
		--请求好友数据
		self:LoadFriendData();	
		-- 活动统一开关
		self.activityDataMgr.ReqInfo()
    	CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift").ResetReq()
		CC.DataMgrCenter.Inst():GetDataByKey("AchievementGift").CheckGiftExist()
		--查询是否拥有未完成的googleplay订单
		if CC.Platform.isAndroid then
		 	CC.GooglePlayIABPlugin.QueryInventory()
		elseif CC.Platform.isIOS then
			CC.ApplePayPlugin.QueryInventory()
		end
	else
		-- self:LoadPlayerWithPropType()
		
		self.view:DelayRun(1,function ()
			self.view:FindChild("Mask"):SetActive(false)
		    if CC.ChannelMgr.GetAndroidTrailStatus() then
		        return false;
		    end
			self:NoviceEndTime()
		end)
	end

	--红点刷新
	self:RefreshFriendRedPoint()
	self:RefreshMailRedPoint()
end

function TrailIOSHallViewCtr:ChipChange()

end

function TrailIOSHallViewCtr:CheckDynamicLinkInstallData()

end

function TrailIOSHallViewCtr:CheckDynamicLinkWakeupData()

end

function TrailIOSHallViewCtr:CheckFacebookDeepLinkData()

end

function TrailIOSHallViewCtr:CheckGuide()

end

function TrailIOSHallViewCtr:CheckActiveSwitch()

end

function TrailIOSHallViewCtr:CheckInvited()

	do return false end
end

--检查后续弹窗
function TrailIOSHallViewCtr:CheckBehindView()

end

function TrailIOSHallViewCtr:CheckOpenPopView()

end

--还未购买新手礼包的玩家弹出新手礼包
function TrailIOSHallViewCtr:NoviceEndTime()
	
end

function TrailIOSHallViewCtr:SetResourceVersionInfo(err,data)

end

function TrailIOSHallViewCtr:CheckFroceUpdateVersion(data)

end

function TrailIOSHallViewCtr:TurnRedPointState(param)

end

function TrailIOSHallViewCtr:OnRefreshSwitchOn(key,switchOn)
	
end

function TrailIOSHallViewCtr:GameBackHallTip()

end

return TrailIOSHallViewCtr
