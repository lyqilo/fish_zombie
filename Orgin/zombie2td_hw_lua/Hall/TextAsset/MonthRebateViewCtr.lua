local CC = require("CC")
local MonthRebateViewCtr = CC.class2("MonthRebateViewCtr")

function MonthRebateViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function MonthRebateViewCtr:InitVar(view,param)
	self.param = param
	self.view = view
    self.curType = nil
	--当前任务奖励id
	self.curTaskLevel = nil
    self.ShowPrizeList = {}
    self.TaskScale = {}
    self.statusList = {}
end

function MonthRebateViewCtr:OnCreate()
	self:RegisterEvent()
    self:ReqMonthInfo()
end

function MonthRebateViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.MonthInfoResp,CC.Notifications.NW_Req_UW_MonthData)
    CC.HallNotificationCenter.inst():register(self,self.Req_UW_MonthReceiveResp,CC.Notifications.NW_Req_UW_MonthReceive)
    CC.HallNotificationCenter.inst():register(self,self.Req_UW_UpdateStatusResp,CC.Notifications.NW_Req_UW_UpdateStatus)
end

function MonthRebateViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

--任务列表信息
function MonthRebateViewCtr:ReqMonthInfo()
	CC.Request("Req_UW_MonthData")
end

function MonthRebateViewCtr:MonthInfoResp(err, param)
	log(CC.uu.Dump(param, "Req_UW_MonthData", 10))
	if err == 0 then
        self.TaskScale = {}
        if param.TreasureList then
            --流水任务
            self.ShowPrizeList = {}
            for i, v in ipairs(param.TreasureList) do
                self.ShowPrizeList[i] = v.ShowPrize
                self.TaskScale[i] = v.Score
                self.statusList[i] = v.status
                if v.status == 2 or v.status == 1 then
                    self.view.curLevel = v.level
                end
            end
        end
        self.view:RefreshUI(param)
        self.curType = param.Type
	end
end

function MonthRebateViewCtr:ReqAcquireReward(level)
    --流水任务，领取奖励要宝箱等级
    if self.curType == 1 and level <= 0 then return end
	--同时只能有一个奖励领取
	if self.curTaskLevel or not self.curType then return end
	logError("领取".. level)
	self.curTaskLevel = level
	CC.Request("Req_UW_MonthReceive", {TreasureLevel = level, Type = self.curType})
end

function MonthRebateViewCtr:Req_UW_MonthReceiveResp(err, param)
	log(CC.uu.Dump(param, "Req_UW_MonthReceive", 10))
	if err == 0 then
		local data = {};
        if param.Prop then
            table.insert(data, {ConfigId = param.Prop.PropID, Count = param.Prop.PropNum})
        end
        if param.VipPrize and param.VipPrize > 0 then
            table.insert(data, {ConfigId = 2, Count = param.VipPrize})
        end
        if param.LoginPrize and param.LoginPrize > 0 then
            table.insert(data, {ConfigId = 2, Count = param.LoginPrize})
        end
		local Cb = function ()
			self:ReqMonthInfo()
			self.curTaskLevel = nil
		end
		CC.ViewManager.OpenRewardsView({items = data, callback = Cb})
	elseif err == 550 then
        -- body
		CC.ViewManager.ShowTip(self.view.language.RewardBad)
    else
        self.curTaskLevel = nil
	end
end

function MonthRebateViewCtr:Req_UW_UpdateStatus()
    CC.Request("Req_UW_UpdateStatus")
end

function MonthRebateViewCtr:Req_UW_UpdateStatusResp(err, param)
    if err == 0 then
        self:ReqMonthInfo()
    end
end

function MonthRebateViewCtr:Destroy()
	self:unRegisterEvent()
end

return MonthRebateViewCtr