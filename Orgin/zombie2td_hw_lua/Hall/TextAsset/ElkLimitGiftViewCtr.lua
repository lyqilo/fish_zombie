local CC = require("CC")
local ElkLimitGiftViewCtr = CC.class2("ElkLimitGiftViewCtr")

function ElkLimitGiftViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function ElkLimitGiftViewCtr:InitVar(view, param)
	self.param = param;
    self.view = view;
    self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
    self.MessageList = {}
end

function ElkLimitGiftViewCtr:OnCreate()
    self:RegisterEvent()
    CC.Request("ReqRecordGet",{packType = CC.proto.client_pack_pb.ChristmasAllPack})
    CC.Request("ReqTimesbuy",{PackIDs = {"30118","30119","30120","30121","30122","30123"}})
    CC.Request("ReqRemainTime",{packType = CC.proto.client_pack_pb.ChristmasAllPack})
end

function ElkLimitGiftViewCtr:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.ElkLimitGiftReward,CC.Notifications.OnDailyGiftGameReward)
    --CC.HallNotificationCenter.inst():register(self,self.ReqStatusBuy,CC.Notifications.NW_ReqStatusBuy)
    CC.HallNotificationCenter.inst():register(self,self.ReqRecordGet,CC.Notifications.NW_ReqRecordGet)
    CC.HallNotificationCenter.inst():register(self,self.ReqTimesbuy,CC.Notifications.NW_ReqTimesbuy)
    CC.HallNotificationCenter.inst():register(self,self.ReqStockPackGet,CC.Notifications.NW_ReqStockPackGet)
    CC.HallNotificationCenter.inst():register(self,self.ReqRemainTime,CC.Notifications.NW_ReqRemainTime)
    CC.HallNotificationCenter.inst():register(self,self.ElkGiftTimeNotify,CC.Notifications.OnTimeNotify)
end

function ElkLimitGiftViewCtr:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnDailyGiftGameReward)
    --CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqStatusBuy)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqRecordGet)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqTimesbuy)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqStockPackGet)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqRemainTime)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnTimeNotify)
end

function ElkLimitGiftViewCtr:ReqStock()
    CC.Request("ReqStockPackGet",{PackIDs = self.view.ElkGift})
    --定时请求礼包库存
    self.view:StartTimer("ReqStockPackGet",3,function()
        CC.Request("ReqStockPackGet",{PackIDs = self.view.ElkGift})
    end,-1)
end

function ElkLimitGiftViewCtr:ElkLimitGiftReward(data)
    local result, index, isStock = self:CheckSourceid(data.Source)
    if not result then return end
    CC.ViewManager.OpenRewardsView({items = data.Rewards})
    
    local gift = self.view.Gifts[index]
    gift.buyTime = gift.buyTime +1
    CC.Request("ReqTimesbuy",{PackIDs = {gift.wareId}})
    if isStock then
        gift.stock = gift.stock -1
        self.view:RefreshView({refreshStock = true})
        return
    end
    self.view:RefreshView({})
end

function ElkLimitGiftViewCtr:CheckSourceid(id)
	for i=1,3 do
		if id == CC.shared_transfer_source_pb["Ts_Christmas_All_Gift_"..i] then
			return true,i,true
        end
        if id == CC.shared_transfer_source_pb["Ts_Christmas_Person_Gift_"..i] then
			return true ,i+3,false
		end
    end
	return false
end

function ElkLimitGiftViewCtr:ReqRecordGet(err,data)
    log(CC.uu.Dump(data, "ReqRecordGet"))
    if err == 0 and data.RecordList and table.length(data.RecordList) > 0 then
        for i,info in ipairs(data.RecordList) do
            local reward = self.propLanguage[info.PropID]
            if info.PropID == CC.shared_enums_pb.EPC_PointCard_Fragment  then
                reward = reward.."*"..info.PropNum
            end
           
            if reward then
                self:AddMessage(string.format(self.view.language.BroadCast,info.PlayerName,reward))
            end
        end
    end
end

function ElkLimitGiftViewCtr:ReqTimesbuy(err,data)
    log(CC.uu.Dump(data, "ReqTimesbuy"))	
    if err == 0 and data.TimesBuy and table.length(data.TimesBuy) > 0 then
        for i,info in ipairs(data.TimesBuy) do
            for i,gift in ipairs(self.view.Gifts) do
                if info.PackID == gift.wareId then
                    if not gift.isFinished then
                        gift.buyTime = info.DayTimes
						gift.limitBuy = info.RemainDayTimes + info.DayTimes
                    end
                    break
                end
            end
        end
         self.view:RefreshView({})
    end
end

function ElkLimitGiftViewCtr:ReqStockPackGet(err,data)
    if not self.isLog then
        log(CC.uu.Dump(data, "ReqStockPackGet"))
        self.isLog = true
    end
    
    if err == 0 and data.PackStock and table.length(data.PackStock) > 0 then
       for i,info in ipairs(data.PackStock) do
            for i,gift in ipairs(self.view.Gifts) do
                if info.PackID == gift.wareId then
                    gift.stock = info.StockNum
                    break
                end
            end
       end
       if self.pauseRefreshStock then return end
       self.view:RefreshView({refreshStock = true})
    end
end

function ElkLimitGiftViewCtr:ReqRemainTime(err,data)
    log(CC.uu.Dump(data, "ReqRemainTime"))
    if err == 0  then
        if data:HasField("IsFinished") and data.IsFinished then
            self.pauseRefreshStock = true
            self.view:StopTimer("ReqStockPackGet")
            self.view.countDown = 0
            self.view.isNotBuy = false
            for i=1,3 do
                self.view.Gifts[i].stock = 0
                self.view.Gifts[i].buyTime = self.view.Gifts[i].limitBuy
                self.view.Gifts[i].isFinished = true
            end
        else
            if data:HasField("ToOpenTime") and data:HasField("ToEndTime") then
                self.view.countDown = data.ToOpenTime > 0 and data.ToOpenTime or data.ToEndTime
                self.view.isNotBuy = data.ToOpenTime > 0 and true or false
            end
            if data:HasField("OpenTimes") then
                if data.ToOpenTime > 0 then
                    self.pauseRefreshStock = true
                    self.view:StopTimer("ReqStockPackGet")
                    local cfg = self.view.GiftStockCfg[data.OpenTimes]
                    if cfg then
                        for i=1,3 do
                            self.view.Gifts[i].stock = cfg[i]
                        end
                    end
                else
                    self.pauseRefreshStock = false
                    self:ReqStock()
                end
            end
        end
        self.view:RefreshView({refreshTime = true,refreshStock = true})
    end
end

function ElkLimitGiftViewCtr:ElkGiftTimeNotify(data)
    log("秒杀礼包零点刷新")
    CC.Request("ReqTimesbuy",{PackIDs = {"30118","30119","30120","30121","30122","30123"}})
end

function ElkLimitGiftViewCtr:AddMessage(Message,isPriority)
	if isPriority then
		table.insert(self.MessageList,1,Message)
	else
		table.insert(self.MessageList,Message)
	end
    self:StartBroadCast()
end

function ElkLimitGiftViewCtr:StartBroadCast()
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
				self.view.tipText.localPosition = Vector3(half + self.view.tipTextBgLength, 0, 0)
				self.action = self.view:RunAction(self.view.tipText, {"localMoveTo", -half - self.view.tipTextBgLength, 0, 0.5 * math.max(16,textW/40), function()
					self.action = nil
					self.isTipMoving = false
				end})
			end)
		end
	end,-1)
end

function ElkLimitGiftViewCtr:Destroy()
	self:UnRegisterEvent()
end

return ElkLimitGiftViewCtr
