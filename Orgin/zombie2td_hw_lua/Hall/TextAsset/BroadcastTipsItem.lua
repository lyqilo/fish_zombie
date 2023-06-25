local CC = require("CC")
local ItemBaseClass = require("View/RewardNoticeView/ItemBaseClass")
local baseClass = CC.class2("BroadcastTipsItem",ItemBaseClass)

local openTime = 300 -- 后台发奖前5分钟推送
local timestamp_1 = 1604073600 --10.31号0点
local timestamp_2 = 1604160000 --11.1号0点
local activityTime = "" -- 活动发奖时间

function baseClass:ctor(view,obj,closeCallback)
	self.type = 1
	self.callback = nil
	self.createTime = os.time()+math.random()
	self.bgRTr = self:SubGet("","RectTransform")
	self.bgImage = self:SubGet("","Image")
	self.btn = self:SubGet("btn","Image")
	self.iconSprite = self:SubGet("icon/Image","Image")
	self.timeText = self:SubGet("timeText","Text")
	self.tipsText = self:SubGet("tipsText","Text")
	self.nameText = self:SubGet("nameText","Text")
	self.getText = self:SubGet("getText","Text")
	self:SetClick()
end

function baseClass:GetOffset(offset)
	return 57 + offset
end

function baseClass:UpdateView( data )
	if data.Props == nil then
		logError("!!!!!!!!!!!!!!!! 未传奖励信息")
		return
	end
	local ConfigId = data.Props.ConfigId or 1
	local Count = data.Props.Count or 0
	local name = data.name or ""

	local desc = self.view.PropDataMgr.GetLanguageDesc(ConfigId,Count)

	if data.type == 0 then
		self:StartCountDown(data.time)
		self.tipsText.text = string.format(self.view.language.awardhigh,desc)
		self.nameText.text = self.view.language.awardsent
		self.getText.text = self.view.language.awardonline
		-- self.view:SetImage(self.bgImage, "fl_xttc")
	elseif data.type == 1 then
		-- local curTime = os.time()
		-- if curTime < timestamp_1 then
		-- 	activityTime = "21 : 30 - 22 : 40"
		-- elseif curTime < timestamp_2 then
		-- 	activityTime = "20 : 50 - 22 : 00"
		-- else
		-- 	activityTime = "20 : 50 - 22 : 00"
		-- end
		activityTime = "21 : 00 - 22 : 10"
		self.timeText.text = activityTime
		self.tipsText.text = string.format(self.view.language.bigAwardGet,desc)
		self.nameText.text = string.format(self.view.language.bigAwardName,name)
		self.getText.text = self.view.language.bigAwardTips
		-- self.view:SetImage(self.bgImage, "fl_xttc")
	end

	local ImageName = self.view.PropDataMgr.GetIcon( ConfigId, Count )
	if ImageName then
		self.view:SetImage(self.iconSprite, ImageName);
	else
		logError(ConfigId)
	end
end

-- 在线福利定时器
function baseClass:StartCountDown(Seconds)
	local deltaTime = Seconds or openTime
	local time = 0
	self.view:StartTimer("UpdateCountDown"..self.createTime, 0, function()
        time = time + Time.deltaTime
        local leftTime = deltaTime-math.floor(time)
        local timeStr = CC.uu.TicketFormat(leftTime)
        if time >= deltaTime then
        	self.timeText.text = "00:00:00"
			self.view:StopTimer("UpdateCountDown"..self.createTime)
		else
			self.timeText.text = timeStr
        end
    end, -1)
end



return baseClass