local CC = require("CC")

local OnlineAward = CC.uu.ClassView("OnlineAward")

local awardNum = 6

function OnlineAward:ctor()
	self.newAward_define = {
		[0] = {index = 12,award = 200,time = 0,unit = ""},
		[1] = {index = 0,award = 100,time = 5,unit = "min"},
		[2] = {index = 1,award = 200,time = 10,unit = "min"},
		[3] = {index = 3,award = 600,time = 30,unit = "min"},
		[4] = {index = 5,award = 1000,time = 45,unit = "min"},
		[5] = {index = 7,award = 1500,time = 1,unit = "hour"},
		[6] = {index = 9,award = 3000,time = 2,unit = "hour"},
		[7] = {index = 11,award = 200,time = 0,unit = ""}
	}
	self.rechargeAward_define = {
		[0] = {index = 12,award = 200,time = 0,unit = ""},
		[1] = {index = 0,award = 200,time = 5,unit = "min"},
		[2] = {index = 1,award = 200,time = 10,unit = "min"},
		[3] = {index = 3,award = 200,time = 15,unit = "min"},
		[4] = {index = 5,award = 200,time = 20,unit = "min"},
		[5] = {index = 7,award = 200,time = 30,unit = "min"},
		[6] = {index = 9,award = 200,time = 45,unit = "min"},
		[7] = {index = 11,award = 200,time = 0,unit = ""}
	}
end

function OnlineAward:OnCreate()
	self.viewCtr = self:CreateViewCtr();
	self.viewCtr:OnCreate();
	self.language = self:GetLanguage()
	self:InitVar();
	self:InitTextByLanguage()
end

function OnlineAward:InitVar()
	self.newbieWait = {}
	self.newbieClose = {}
	self.newbieOpen = {}
	self.newbieIndex = {}

	self.rechargeWait = {}
	self.rechargeClose = {}
	self.rechargeOpen = {}
	self.rechargeIndex = {}

	self.newbieSlider = self:FindChild("Layer_UI/Newbie/Slider")
	self.newbieTime = self:FindChild("Layer_UI/Newbie/Time")
	self.newbieDays = self:FindChild("Layer_UI/Newbie/Days")
	self.newbieDetail = self:FindChild("Layer_UI/Newbie/Detail")

	self.rechargeSlider = self:FindChild("Layer_UI/Recharge/Slider")
	self.rechargeTime = self:FindChild("Layer_UI/Recharge/Time")
	self.rechargeDays = self:FindChild("Layer_UI/Recharge/Days")
	self.rechargeDetail = self:FindChild("Layer_UI/Recharge/Detail")

	for i=1,awardNum do
		table.insert(self.newbieOpen,self:FindChild("Layer_UI/Newbie/Open/"..i))
		table.insert(self.newbieWait,self:FindChild("Layer_UI/Newbie/Wait/"..i))
		table.insert(self.newbieClose,self:FindChild("Layer_UI/Newbie/Close/"..i))
		table.insert(self.newbieIndex,self:FindChild("Layer_UI/Newbie/Slider/Index/"..i))

		table.insert(self.rechargeOpen,self:FindChild("Layer_UI/Recharge/Open/"..i))
		table.insert(self.rechargeWait,self:FindChild("Layer_UI/Recharge/Wait/"..i))
		table.insert(self.rechargeClose,self:FindChild("Layer_UI/Recharge/Close/"..i))
		table.insert(self.rechargeIndex,self:FindChild("Layer_UI/Recharge/Slider/Index/"..i))

		self:AddClick("Layer_UI/Newbie/Wait/"..i.."/lg",function ()
			self:TakeOnlineAward(i)
		end)
		self:AddClick("Layer_UI/Recharge/Wait/"..i.."/lg",function ()
			self:TakeOnlineAward(i)
		end)
	end

	self:AddClick("Layer_UI/Recharge/Pay",function () CC.ViewManager.Open("StoreView"); end)
end

function OnlineAward:InitTextByLanguage()
	for i=1,awardNum do
		self:FindChild("Layer_UI/Newbie/Slider/time/"..i).text = self.newAward_define[i].time..self.language[self.newAward_define[i].unit]
		self:FindChild("Layer_UI/Newbie/Slider/award/"..i).text = self.newAward_define[i].award..self.language.chip
		self:FindChild("Layer_UI/Recharge/Slider/time/"..i).text = self.rechargeAward_define[i].time..self.language[self.rechargeAward_define[i].unit]
	end
	self.newbieDetail.text = self.language.newbieDetail
	self.rechargeDetail.text = self.language.rechargeDetail
	self:FindChild("Layer_UI/Recharge/Time/Text").text = self.language.time_tip
	self:FindChild("Layer_UI/Recharge/Days/Text").text = self.language.day_tip
	self:FindChild("Layer_UI/Newbie/Time/Text").text = self.language.time_tip
	self:FindChild("Layer_UI/Newbie/Days/Text").text = self.language.day_tip
	self:FindChild("Layer_UI/Recharge/Pay/Text").text = self.language.payBtn
end

function OnlineAward:RefresState(param)

	local newbie = param.IsNewbie
	if param.err == 318 then
		-- self:FindChild("Layer_UI/Recharge"):SetActive(true)
		-- self:FindChild("Layer_UI/Newbie"):SetActive(false)
		self:FindChild("Layer_UI/Recharge"):SetActive(false)
		self:FindChild("Layer_UI/Newbie"):SetActive(true)
		return
	end
	if not newbie and param.RestTime <=0 then
		self:FindChild("Layer_UI/Recharge"):SetActive(true)
		self:FindChild("Layer_UI/Newbie"):SetActive(false)
		self:FindChild("Layer_UI/Recharge/Pay"):SetActive(true)
		self:RefreshPayState()
		return
	end
	if newbie then
		self:FindChild("Layer_UI/Newbie"):SetActive(true)
		self:FindChild("Layer_UI/Recharge"):SetActive(false)
		self:RefreshNewbieUI(param)
	else
		self:FindChild("Layer_UI/Recharge"):SetActive(true)
		self:FindChild("Layer_UI/Newbie"):SetActive(false)
		self:RefreshRechargeUI(param)
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnlineAwardState,param);
end

function OnlineAward:RefreshNewbieUI(param)

	local rewardId = param.RewardId
	self:StopTimer("NewbieResTime")
	-- local restTime = math.floor(param.RestTime/(60*60*24))
	-- if restTime >0 then
	-- 	self.newbieDays.text = restTime
	-- else
	-- 	local time = 0
	-- 	local lastTime = 0
	-- 	local deltaTime = param.RestTime
	-- 	self:StartTimer("NewbieResTime", 0, function()
    --     	time = time + Time.deltaTime
    --     	if lastTime < math.floor(time) then
    --     		lastTime = math.floor(time)
    --     	end
    --     	self.newbieDays.text = CC.uu.TicketFormat(deltaTime-lastTime)
    --     	if lastTime >= deltaTime then
	-- 			self:StopTimer("NewbieResTime")
	-- 			self.viewCtr:RefreshAwardInfo()
    --     	end
    -- 	end, -1)
	-- end
	if rewardId == 0 then rewardId = 6 end
	for i=1,awardNum do
		if i < rewardId then
			self.newbieClose[i]:SetActive(false)
			self.newbieOpen[i]:SetActive(false)
			self.newbieWait[i]:SetActive(true)
			self.newbieIndex[i]:SetActive(true)
		else
			self.newbieClose[i]:SetActive(true)
			self.newbieOpen[i]:SetActive(false)
			self.newbieWait[i]:SetActive(false)
			self.newbieIndex[i]:SetActive(false)
		end
	end
	for i=1,#param.RewardIds do
		self.newbieOpen[param.RewardIds[i]]:SetActive(true)
		self.newbieWait[param.RewardIds[i]]:SetActive(false)
	end
	self.newbieSlider:GetComponent("Slider").value = self.newAward_define[rewardId].index
	self:NewbieSetTimer(param)
end

function OnlineAward:NewbieSetTimer(param)
	local deltaTime = param.RestSeconds
	local index = param.RewardId
	if index == 6 and deltaTime <= 0 then
		self.newbieTime:SetActive(false)
		self.newbieClose[index]:SetActive(false)
		self.newbieWait[index]:SetActive(true)
		self.newbieIndex[index]:SetActive(true)
		self.newbieOpen[index]:SetActive(false)
		self.newbieSlider:GetComponent("Slider").value = self.newAward_define[index+1].index
		return
	elseif index == 0 and deltaTime <= 0 then
		self.newbieTime:SetActive(false)
		self.newbieClose[6]:SetActive(false)
		self.newbieWait[6]:SetActive(false)
		self.newbieIndex[6]:SetActive(true)
		self.newbieOpen[6]:SetActive(true)
		self.newbieSlider:GetComponent("Slider").value = self.newAward_define[index].index
		return
	end
	local time = 0
    local lastTime = 0
    self.newbieTime:SetActive(true)
    self:StartTimer("NewbieAward", 0, function()
        time = time + Time.deltaTime
        if lastTime < math.floor(time) then
        	lastTime = math.floor(time)
        end
        self.newbieTime.text = CC.uu.TicketFormat(deltaTime-lastTime)
        if lastTime >= deltaTime then
        	self:DelayRun(1,function ()
        		self.viewCtr:RefreshAwardInfo()
        	end)
			self:StopTimer("NewbieAward")
        end
    end, -1)
end

function OnlineAward:RefreshRechargeUI(param)
	local rewardId = param.RewardId
	self:StopTimer("RechargeTime")
	local restTime = math.floor(param.RestTime/(60*60*24))
	if restTime >0 then
		self.rechargeDays.text = restTime
	else
		local time = 0
		local lastTime = 0
		local deltaTime = param.RestTime
		self:StartTimer("RechargeResTime", 0, function()
			time = time + Time.deltaTime
			if lastTime < math.floor(time) then
				lastTime = math.floor(time)
			end
			self.rechargeDays.text = CC.uu.TicketFormat(deltaTime-lastTime)
			if lastTime >= deltaTime then
				self:StopTimer("RechargeTime")
				self.viewCtr:RefreshAwardInfo()
			end
		end, -1)
	end
	if rewardId == 0 then
		for i=1,awardNum do
			self.rechargeClose[i]:SetActive(false)
			self.rechargeOpen[i]:SetActive(true)
			self.rechargeWait[i]:SetActive(false)
			self.rechargeIndex[i]:SetActive(true)
		end
		self.rechargeTime:SetActive(false)
		self.rechargeSlider:GetComponent("Slider").value = self.rechargeAward_define[rewardId].index
		return
	end
	for i=1, awardNum do
		if i < rewardId then
			self.rechargeClose[i]:SetActive(false)
			self.rechargeOpen[i]:SetActive(true)
			self.rechargeWait[i]:SetActive(false)
			self.rechargeIndex[i]:SetActive(true)
		else
			self.rechargeClose[i]:SetActive(true)
			self.rechargeOpen[i]:SetActive(false)
			self.rechargeWait[i]:SetActive(false)
			self.rechargeIndex[i]:SetActive(false)
		end
	end
	self.rechargeSlider:GetComponent("Slider").value = self.rechargeAward_define[rewardId].index
	self:SetRechargeTimer(param)
end

function OnlineAward:SetRechargeTimer(param)
	local deltaTime = param.RestSeconds
	local index = param.RewardId
	if deltaTime <= 0 then
		self.rechargeTime:SetActive(false)
		self.rechargeWait[index]:SetActive(true)
		self.rechargeClose[index]:SetActive(false)
		self.rechargeIndex[index]:SetActive(true)
		self.rechargeSlider:GetComponent("Slider").value = self.rechargeAward_define[index+1].index
		return
	end
	local time = 0
    local lastTime = 0
    self.rechargeTime:SetActive(true)
    self:StartTimer("RechargeAward", 0, function()
        time = time + Time.deltaTime
        if lastTime < math.floor(time) then
			lastTime = math.floor(time)
        end
        self.rechargeTime.text = CC.uu.TicketFormat(deltaTime-lastTime)
        if lastTime >= deltaTime then
			self.rechargeTime:SetActive(false)
			self.rechargeIndex[index]:SetActive(true)
			self.rechargeWait[index]:SetActive(true)
			self.rechargeClose[index]:SetActive(false)
			self.rechargeSlider:GetComponent("Slider").value = self.rechargeAward_define[index+1].index
			self:StopTimer("RechargeAward")
        end
    end, -1)
end

function OnlineAward:RefreshPayState()
	for i=1,awardNum do
		self.rechargeClose[i]:SetActive(true)
		self.rechargeOpen[i]:SetActive(false)
		self.rechargeWait[i]:SetActive(false)
		self.rechargeIndex[i]:SetActive(false)
	end
end

function OnlineAward:TakeOnlineAward(num)
	self.viewCtr:TakeOnlineAward(num)
end

function OnlineAward:OpenReward(award)
	local param = award.Prop
	CC.ViewManager.OpenRewardsView({items = param,title = "OnlineAward"})
	self.viewCtr:RefreshAwardInfo()
end

function OnlineAward:ActionIn()
	self:SetCanClick(false);

	self:RunAction(self:FindChild("Layer_UI/Newbie"), {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});

	self:RunAction(self:FindChild("Layer_UI/Recharge"), {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function OnlineAward:ActionOut()
	self:SetCanClick(false);
	self:OnDestroy();
	CC.HallUtil.HideByTagName("Effect", false)

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function OnlineAward:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function OnlineAward:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function OnlineAward:OnDestroy()
	self:CancelAllDelayRun()
	self:StopAllTimer()
	self:StopAllAction()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return OnlineAward