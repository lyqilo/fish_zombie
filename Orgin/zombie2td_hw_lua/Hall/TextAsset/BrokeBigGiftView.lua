local CC = require("CC")
local BaseClass = require("View/BrokeGiftView/BrokeGiftView")
local BrokeBigGiftView = CC.class2("BrokeBigGiftView",BaseClass)

function BrokeBigGiftView:Create()
	
	if self:IsPortraitScreen() then
		local portraitView = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine").PortraitSupport[self.viewName]
		if portraitView then
			self._isPortraitView = true
		end
	end

    self.transform = CC.uu.LoadHallPrefab("prefab",
        "BrokeBigGiftView",
		self:GlobalNode(),
		"BrokeBigGiftView",
		self:GlobalLayer())
    self:OnCreate()
end

function BrokeBigGiftView:OnCreate()
    self.viewName = "BrokeBigGiftView"
    self.WareIds = {"30080", "30081", "30082"}
    self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    local viewCtr = require("View/BrokeGiftView/BrokeBigGiftViewCtr")
    self.viewCtr = viewCtr.new(self, self.param)
    self.viewCtr:OnCreate()
    self:InitUI()
	--大额破产第3档特殊处理
	self:FindChild("Grade3/MaxNum/MaxNum").text =  CC.uu.ChipFormat(self.viewCtr.giftInfo[self.WareIds[3]].max, true)
end

function BrokeBigGiftView:SetCountDown(timer)
	local countDown = timer
	self:StartTimer("CountDown"..self.createTime, 1, function()
        local timeStr = CC.uu.TicketFormat(countDown)
        if countDown <= 0 then
			self.timeText.text = "00:00:00"
			self:StopTimer("CountDown"..self.createTime)
			self:DelayRun(1, function ( )
				self.activityDataMgr.SetActivityInfoByKey("BrokeBigGiftView", {switchOn = false})
				self:CloseView()
			end)
		else
			self.timeText.text = timeStr
		end
		countDown = countDown - 1
    end, -1)
end

function BrokeBigGiftView:BrokeGiftStatus()
	local brokeGiftData = self.activityDataMgr.GetBrokeBigGiftData()
	if brokeGiftData.nStatus == 1 then
		if brokeGiftData.arrBrokenGift then
			for _, v in ipairs(brokeGiftData.arrBrokenGift) do
				if v.bStatus then
					--有档位没有购买
					return
				end
			end
			--档位都购买了
			self.activityDataMgr.SetActivityInfoByKey("BrokeBigGiftView", {switchOn = false})
		end
	end
end

return BrokeBigGiftView