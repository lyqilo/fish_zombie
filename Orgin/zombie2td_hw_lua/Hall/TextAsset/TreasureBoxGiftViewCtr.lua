local CC = require("CC")

local TreasureBoxGiftViewCtr = CC.class2("TreasureBoxGiftViewCtr")

function TreasureBoxGiftViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function TreasureBoxGiftViewCtr:InitVar(view,param)
	self.param = param
    self.view = view
end

function TreasureBoxGiftViewCtr:OnCreate()
	--宝箱wareid
	self.boxWareId = {"22007","22008","22009","22010"}
	--宝箱信息
	self.treasureInfo = {}
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.propData = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self:InitData()
	self:RegisterEvent()
	self:StartUpdate();
end

function TreasureBoxGiftViewCtr:InitData()
	--滚动信息，当前移动的标记
	self.curMoveIndex = 0
	--下一个间隔时间
	self.dalayTime = 0
	self.curShowBox = 1
	self.lastShowBox = self.curShowBox
	--宝箱位置青铜、白银、黄金、天使
	self.boxSeat = {1, 2, 3, 4}
	self.posSeat = {{x = 0, y = 0}, {x = 210, y = 25}, {x = 0, y = 25}, {x = -210, y = 25}}
	--播报规则
	self.rolllRule = {["22007"] = 400000, ["22008"] = 1000000, ["22009"] = 2000000, ["22010"] = 5500000}
end

function TreasureBoxGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnTreasureReward, CC.Notifications.TreasureReward)
	CC.HallNotificationCenter.inst():register(self,self.OrderStatus,CC.Notifications.NW_GetOrderStatus);
	CC.HallNotificationCenter.inst():register(self,self.TreasureRewardResp,CC.Notifications.NW_ReqTreasureReward);
end

function TreasureBoxGiftViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.TreasureReward);
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetOrderStatus);
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqTreasureReward);
end

--宝箱奖励
function TreasureBoxGiftViewCtr:OnTreasureReward(data)
	log(CC.uu.Dump(data, "data", 10))
	if data.PlayerId == CC.Player.Inst():GetSelfInfoByKey("Id") then
		if data.WareId then
			for k, v in ipairs(self.boxWareId) do
				if data.WareId == v then
					self.view:PlaySpineAnim(k, "stand02", data)
				end
			end
			CC.Request("GetOrderStatus",{data.WareId})
		end
	end
	if data.WareId and data.Rewards then
		for k,v in ipairs(data.Rewards) do
			if v.ConfigId == CC.shared_enums_pb.EPC_ChouMa and v.Count >= self.rolllRule[data.WareId] then
				self.view:ConstituteRollInfo(data)
			end
		end
	end
end

--宝箱状态
function TreasureBoxGiftViewCtr:ReqTreasureEnable()
	CC.Request("GetOrderStatus",{"22007", "22008", "22009", "22010"})
end

function TreasureBoxGiftViewCtr:OrderStatus(err, result)
	log(CC.uu.Dump(result,"result",10))
	local wareIds = {}
	if result.Items then
		for k,v in ipairs(result.Items) do
			self.treasureInfo[v.WareId] = v
			if not v.Enabled then
				table.insert(wareIds, v.WareId)
			end
			local countDown = v.CountDown
			if countDown then
				self.view:BoxCountDown(countDown)
			end
		end
		if #result.Items > 1 then
			self:InitTreasure()
		end
	end
	--self:ReqTreasureReward(wareIds)
	self.view:RefreshTreasure(self.curShowBox)
	self:ChangeWareId()
end

function TreasureBoxGiftViewCtr:InitTreasure()
	local setShow = false
	for	i = 1, #self.boxWareId do
		if self.treasureInfo[self.boxWareId[i]] and self.treasureInfo[self.boxWareId[i]].Enabled then
			if not setShow then
				self.curShowBox = i
				setShow = true
			end
			self.view:PlaySpineAnim(i, "stand01")
		else
			self.view:PlaySpineAnim(i, "stand03")
		end
	end
	for k = 1, #self.boxSeat do
		self.boxSeat[k] = self.boxSeat[k] + 4 - self.curShowBox
		self.boxSeat[k] = self.boxSeat[k] % 4 + 1
	end
	--self.view:RefreshTreasure(self.curShowBox)
end

function TreasureBoxGiftViewCtr:ReqTreasureReward(wareIds)
	if next(wareIds) ~= nil then
		CC.Request("ReqTreasureReward",wareIds)
	end
end

function TreasureBoxGiftViewCtr:TreasureRewardResp(err, data)
	log(CC.uu.Dump(data,"data",10))
	if data.Rewards then
		for _,v in ipairs(data.Rewards) do
			for i = 1, #self.boxWareId do
				if v.WareId == self.boxWareId[i] and v.Rewards then
					for _,vl in ipairs(v.Rewards) do
						if vl.ConfigId == CC.shared_enums_pb.EPC_ChouMa then
							self.view:SetBubbleValue(i, vl.Count)
						end
					end
				end
			end
		end
	end
end

function TreasureBoxGiftViewCtr:GetTreasureInfo(index)
	if self.treasureInfo[self.boxWareId[index]] then
		return self.treasureInfo[self.boxWareId[index]]
	end
end

--宝箱切换
function TreasureBoxGiftViewCtr:BoxSwitch(isRight, callBack)
	self.lastShowBox = self.curShowBox
	self.curShowBox = isRight and self.curShowBox + 1 or self.curShowBox - 1
	if self.curShowBox > 4 then
		self.curShowBox = 1
	elseif self.curShowBox < 1 then
		self.curShowBox = 4
	end
	for i = 1, 4 do
		self.boxSeat[i] = isRight and self.boxSeat[i] - 1 or self.boxSeat[i] + 1
		self.boxSeat[i] = (self.boxSeat[i] - 1) % 4 + 1
	end
	self.view:BoxSwitchChange(self.curShowBox, self.lastShowBox, callBack)
	self:ChangeWareId()
end

--宝箱自动切换
function TreasureBoxGiftViewCtr:BoxAutoSwitch()
	if self:BoxAllEnable() then return end
	local lastBox = self.curShowBox
	local isRight = false
	if self.curShowBox > 1 and self:FindLastBoxEnable() then
		if self.curShowBox == 4 then
			--当前是最后一个，第一个没打开，跳转第一个
			local firstBoxInfo = self:GetTreasureInfo(1)
			if firstBoxInfo and firstBoxInfo.Enabled then
				self:BoxSwitch(true)
				return
			end
		end
		lastBox = lastBox - 1
	else
		lastBox = lastBox + 1
		isRight = true
	end
	local callBack = nil
	local lastBoxInfo = self:GetTreasureInfo(lastBox)
	if lastBoxInfo and not lastBoxInfo.Enabled then
		--宝箱已打开
		callBack = function () self:BoxAutoSwitch() end
	end
	self:BoxSwitch(isRight, callBack)
end

--宝箱是否全部打开
function TreasureBoxGiftViewCtr:BoxAllEnable()
	for _, v in pairs(self.treasureInfo) do
		if v.Enabled then
			return false
		end
	end
	return true
end

--查找前面是否有没打开宝箱
function TreasureBoxGiftViewCtr:FindLastBoxEnable()
	if self.curShowBox > 1 then
		for i = self.curShowBox - 1, 1, -1 do
			local info = self:GetTreasureInfo(i)
			if info and info.Enabled then
				return true
			end
		end
	end
	return false
end

function TreasureBoxGiftViewCtr:GetMovePos(index)
	if index > 0 and index <= #self.boxSeat then
		return self.posSeat[self.boxSeat[index]]
	end
	return 0
end

function TreasureBoxGiftViewCtr:ReqBuyTreasure()
	if self.curShowBox <= 0 or self.curShowBox > #self.boxWareId then return end
	local wareId = self.boxWareId[self.curShowBox]
	local price = self.wareCfg[wareId].Price
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
		local data={}
        data.WareId=wareId
        data.ExchangeWareId= wareId
        CC.Request("ReqBuyWithId",data)
		
	else
		if self.view.walletView then
			self.view.walletView:PayRecharge()
		end
	end
end

function TreasureBoxGiftViewCtr:ChangeWareId()
	local wareId = self.boxWareId[self.curShowBox]
	self.view.walletView:ChangeExchangeWareId(wareId)
	local info = self:GetTreasureInfo(self.curShowBox)
	if info and not info.Enabled then
		self.view.walletView:PayGiftSucceed(false)
	end
end

function TreasureBoxGiftViewCtr:GetCurBoxPrice()
	if self.curShowBox > 0 and self.curShowBox <= #self.boxWareId then
		return self.wareCfg[self.boxWareId[self.curShowBox]].Price
	end
end

function TreasureBoxGiftViewCtr:StartUpdate()
	UpdateBeat:Add(self.Update,self);
end

function TreasureBoxGiftViewCtr:StopUpdate()
	UpdateBeat:Remove(self.Update,self);
end

function TreasureBoxGiftViewCtr:Update()
	--每隔6秒移动下一个
	self.dalayTime = self.dalayTime - Time.deltaTime
	if self.dalayTime <= 0 then
		self.dalayTime = 6
		self.curMoveIndex = self.curMoveIndex + 1
		self.view:MoveRoll(self.curMoveIndex)
	end
end

function TreasureBoxGiftViewCtr:Destroy()
	self:unRegisterEvent()
	self:StopUpdate();
end

return TreasureBoxGiftViewCtr