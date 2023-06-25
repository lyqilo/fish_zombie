
local CC = require("CC")
local PayGiftViewCtr = CC.class2("PayGiftViewCtr")

function PayGiftViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function PayGiftViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
	self.proplanguage = CC.LanguageManager.GetLanguage("L_Prop")
	self.MessageList = {}
	
end

function PayGiftViewCtr:OnCreate()
	self:RegisterEvent()
	CC.Request("ReqGetRechargeActivityInfo")
	CC.Request("ReqGetRechargeActivityRank")
	CC.Request("ReqGetRechargeActivityRecords")
end

function PayGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqGetRechargeActivityInfo,CC.Notifications.NW_ReqGetRechargeActivityInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqGetRechargeActivityRank,CC.Notifications.NW_ReqGetRechargeActivityRank)
	CC.HallNotificationCenter.inst():register(self,self.ReqGetRechargeActivityRecords,CC.Notifications.NW_ReqGetRechargeActivityRecords)
	CC.HallNotificationCenter.inst():register(self,self.ReqGetRechargeActivityReward,CC.Notifications.NW_ReqGetRechargeActivityReward)
	CC.HallNotificationCenter.inst():register(self,self.PushPayGiftBigReward,CC.Notifications.PushPayGiftBigReward)
end

function PayGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetRechargeActivityInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetRechargeActivityRank)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetRechargeActivityRecords)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetRechargeActivityReward)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.PushPayGiftBigReward)
end

function PayGiftViewCtr:ReqGetRechargeActivityInfo(err,data)
	log(CC.uu.Dump(data, "ReqGetRechargeActivityInfo"))
	if err == 0 and data and not table.isEmpty(data) then
		self.view:RefreshView(data)
	end
end

function PayGiftViewCtr:ReqGetRechargeActivityRank(err,data)
	log(CC.uu.Dump(data, "ReqGetRechargeActivityRank"))
	if err == 0 and data and not table.isEmpty(data) then
		self.view:ShowRankPanel(data.Datas)
	end
end

function PayGiftViewCtr:ReqGetRechargeActivityRecords(err,data)
	log(CC.uu.Dump(data, "ReqGetRechargeActivityRecords",5))
	if err == 0 and data and not table.isEmpty(data) then
		for i,v in ipairs(data.Records) do
			local propid = v.Rewards[1].ConfigId
			self:AddMessage(string.format(self.view.language.BroadCast,v.Name,self.proplanguage[propid]))
		end
	end
end

function PayGiftViewCtr:ReqGetRechargeActivityReward(err,data)
	log(CC.uu.Dump(data, "ReqGetRechargeActivityReward"))
	if err == 0 and data and not table.isEmpty(data) then
		CC.ViewManager.CloseConnecting()
		self.view:StartLottery(data.Props)
	end
end

function PayGiftViewCtr:PushPayGiftBigReward(data)
	local propid = data.Rewards[1].ConfigId
	self:AddMessage(string.format(self.view.language.BroadCast,data.Name,self.proplanguage[propid]),true)
end

function PayGiftViewCtr:AddMessage(Message,isPriority)
	if isPriority then
		table.insert(self.MessageList ,1, Message)
	else
		table.insert(self.MessageList , Message)
	end
    self:StartBroadCast()
end

function PayGiftViewCtr:StartBroadCast()
	if self.isBroadCast then return end
	self.isBroadCast = true

	self.view:StartTimer("BroadCast",0.5,function()
		if self.isTipMoving then 
			return
		else
			self.view:StopAction(self.action)
			self.action = nil
        end
        
		if table.length(self.MessageList) <= 0 then
			self.view.tipText:GetComponent('Text').text = ""	
			self.view.BroadCast.transform.gameObject:SetActive(false)
			self.view:StopTimer("BroadCast")
            self.isBroadCast = false
			CC.Request("ReqGetRechargeActivityRecords")
		else
			self.isTipMoving = true
	        local text = self.MessageList[1]
			table.remove(self.MessageList,1)
			self.view.tipText.localPosition = Vector3(1000,0,0)
			self.view.tipText:GetComponent('Text').text = string.gsub(CC.uu.ReplaceFace(text,23),"\n"," ")
			self.view.BroadCast.transform.gameObject:SetActive(true)
			self.view:DelayRun(0.1,function()
				local textW = self.view.tipText:GetComponent('RectTransform').rect.width
				local half = textW/2
				self.view.tipText.localPosition = Vector3(half + self.view.BroadCast_Lenth, 0, 0)
				self.action = self.view:RunAction(self.view.tipText, {"localMoveTo", -half - self.view.BroadCast_Lenth, -1.5, 0.5*math.max(16,textW/40), function()
					self.action = nil
					self.isTipMoving = false
				end})
			end)
		end
	end,-1)
end

function PayGiftViewCtr:Destroy()
	self:UnRegisterEvent()
end

return PayGiftViewCtr;
