local CC = require("CC")
local uu = CC.uu
local baseClass = uu.ClassView("OnlineLottery")

--修改时记得修改BroadcastTipsItem脚本中时间
local timestamp_1 = 1606492800 --11.28号0点
local timestamp_2 = 1604160000 --11.1号0点
local startTime = ""
local endTime = ""
local eachTime = 10
local vipText = {"VIP10+","VIP3-9","VIP1-2","VIP0"}

function baseClass:ctor(param)
	self.awardInfo = {};
	self.language = CC.LanguageManager.GetLanguage("L_OnlineLottery");
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
	self.onlineWelfareDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("OnlineWelfareDataMgr")
end

function baseClass:OnCreate()
	CC.Request("ReqOnlineWelfare")

	self:InitContent();
	self:InitTextByLanguage();
	self:RegisterEvent();
	self:OnRefreshUI()
end

function baseClass:InitTextByLanguage()
	local titleText = self:SubGet("UILayout/window/titleText","Text")
	local awardTipsText = self:SubGet("UILayout/window/awardTipsText","Text")
	local tipText1 = self:SubGet("UILayout/window/tipText1","Text")
	local tipText2 = self:SubGet("UILayout/window/tipText2","Text")
	local tipText3 = self:SubGet("UILayout/window/tipText3","Text")

	titleText.text = self.language.awardcontent
	awardTipsText.text = self.language.awardtips
	tipText1.text = string.format(self.language.context1,startTime,endTime,eachTime)
	tipText2.text = self.language.context2
	tipText3.text = self.language.context3
end

function baseClass:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnGetOnlineWelfareRsp,CC.Notifications.PushOnlineWelfare);
end

function baseClass:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.PushOnlineWelfare)
end

function baseClass:InitContent()
	-- local curTime = os.time()
	-- if curTime < timestamp_1 then
	-- 	startTime = "21:00"
	-- 	endTime = "22:10"
	-- elseif curTime < timestamp_2 then
	-- 	startTime = "21:00"
	-- 	endTime = "22:10"
	-- else
	-- 	startTime = "21:00"
	-- 	endTime = "22:10"
	-- end
	startTime = "21:20"
	endTime = "22:30"

	self.itemList = {}
	local hGridPath = "UILayout/window/list/VGrid/HGrid"
	for i=1,4 do
		local grid = {}
		local vGridPath = hGridPath..i.."/item"
		for j=1,7 do
			local item = self:FindChild(vGridPath..j)
			table.insert(grid,item)
		end
		grid[7]:FindChild("sign/Text").text = vipText[i]
		table.insert(self.itemList,grid)
	end

	self.timeText = self:SubGet("UILayout/window/timeText","Text")
	self.timeText.text = ""

	self:AddClick("UILayout/window/ShareBtn",function ()
		local param = {}
		param.imgName = "share_1_1"
		param.content = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView").shareContent1
		CC.ViewManager.Open("ImageShareView",param)
	end)
end

function baseClass:OnRefreshUI()
	-- 奖品初始化
	local shared_enums_pb = CC.shared_enums_pb
	local list = self.onlineWelfareDataMgr.GetRewardDataList()
	if list == nil then
		return
	end
	local shiwuStr = "x1"
	for i=1,4 do
		for j=1,7 do
			local item = self.itemList[i][j]
			local data = list[5-i] and list[5-i][j]
			if data then
				local childNode = item:FindChild("icon")
				self:SetImage(childNode, data.SpriteName)
				local text = item:FindChild("textBg/Text"):GetComponent("Text")
				if data.ConfigId == shared_enums_pb.EPC_ChouMa or data.ConfigId == shared_enums_pb.EPC_New_GiftVoucher then
					text.text = tostring(data.Count or 0)
				else
					text.text = shiwuStr
					childNode.localPosition = Vector3(2, 10, 0)
				end
			end
		end
	end
end

function baseClass:OnGetOnlineWelfareRsp(result)
	self.activityDataMgr.SetActivityInfoByKey("OnlineLottery", {redDot=false});
	local Open = result.Open
	local StartCD = result.StartCD
	local NextRewardCD = result.NextRewardCD
	--如果两个CD时间都为0则活动结束，不再请求获取在线福利信息
	if StartCD == 0 and NextRewardCD == 0 then return end
	local cd = Open and NextRewardCD or StartCD
	self:OnRefreshCountDown(Open,cd)
end

function baseClass:OnRefreshCountDown(isBegin,cd)
	self:StartCountDown(isBegin,cd or 0)
end

function baseClass:StartCountDown(isBegin,cd)
	local deltaTime = cd
	local formatStr = isBegin and self.language.activitysend or self.language.activitybegin
	local time = 0
	self:StartTimer("UpdateCountDown", 0, function()
        time = time + Time.deltaTime
        local leftTime = deltaTime-math.floor(time)
        if leftTime < 0 then
        	leftTime = 0
        end
        local timeStr = uu.TicketFormat3(leftTime)
        local str
        if leftTime >= 86400 then
        	local dayStr = uu.TicketFormatDay(leftTime,true)
        	str = string.format("%s%s%s",dayStr,self.language.day,timeStr)
        else
        	str = timeStr
        end
        if time >= deltaTime then
			self.timeText.text = string.format(formatStr,"00:00:00")
			self:StopTimer("UpdateCountDown")
			self:DelayRun(1,function ()
				CC.Request("ReqOnlineWelfare")
			end)
		else
			self.timeText.text = string.format(formatStr,str)
        end
    end, -1)
end

function baseClass:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function baseClass:ActionOut()
	self:ActionHide()
	self:OnDestroy();
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function baseClass:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function baseClass:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function baseClass:OnDestroy()
	self:UnRegisterEvent();
end

return baseClass