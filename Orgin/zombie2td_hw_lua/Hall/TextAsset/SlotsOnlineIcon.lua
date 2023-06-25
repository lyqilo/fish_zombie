local CC = require("CC")
local OnlineIcon = require("View/OnlineIcon/OnlineIcon")
local M = CC.class2("SlotsOnlineIcon",OnlineIcon)


function M:RefresState(param)
	self:StopTimer("OnlineAward")
	local Open = param.Open
	local RestSeconds = param.RestSeconds
	local HasReward = param.HasReward
	local time = 0
	local lastTime = 0
	if not Open or #param.RewardIds == 6 then
		--在线奖励关闭或所有奖励领取完毕
		self.transform:SetActive(false)
	else
		self.transform:SetActive(true)
	end
	
	if HasReward then
		self.redDot:SetActive(true)
		-- self.effect:SetActive(true)
		self.countDownTimer:SetActive(false)
	else
		if RestSeconds > 0 then
			self.countDownTimer:SetActive(true)
			self.redDot:SetActive(false)
			-- self.effect:SetActive(false)
		end
		self:StartTimer("OnlineAward", 0, function()
			time = time + Time.deltaTime
			if lastTime < math.floor(time) then
				lastTime = math.floor(time)
			end
			self.countDownTimer.text = CC.uu.TicketFormat(RestSeconds-lastTime)
			if lastTime >= RestSeconds then
				self.redDot:SetActive(true)
				-- self.effect:SetActive(true)
				self.countDownTimer:SetActive(false)
				self:StopTimer("OnlineAward")
			end
		end, -1)
	end
end

return M