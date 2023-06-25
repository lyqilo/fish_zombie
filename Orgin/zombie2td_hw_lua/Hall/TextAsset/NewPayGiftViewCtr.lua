
local CC = require("CC")
local NewPayGiftViewCtr = CC.class2("NewPayGiftViewCtr")

function NewPayGiftViewCtr:ctor(view, param)

	self:InitVar(view, param);
end

function NewPayGiftViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
end

function NewPayGiftViewCtr:OnCreate()
	self:RegisterEvent()
	CC.Request("ReqRechargeInfo")
	CC.Request("ReqRechargeLotteryList")
	CC.Request("ReqRechargeRank")

	CC.Request("ReqRechargeJP")
	self.view:StartTimer("ReqRechargeJP",3,function() CC.Request("ReqRechargeJP") end,-1)

    self:RefreshJackPot(0)
end

function NewPayGiftViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqRechargeInfoResp,CC.Notifications.NW_ReqRechargeInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqRechargeLotteryListResp,CC.Notifications.NW_ReqRechargeLotteryList)
	CC.HallNotificationCenter.inst():register(self,self.ReqRechargeRankResp,CC.Notifications.NW_ReqRechargeRank)
	CC.HallNotificationCenter.inst():register(self,self.ReqRechargeJPResp,CC.Notifications.NW_ReqRechargeJP)
	CC.HallNotificationCenter.inst():register(self,self.ReqRechargeOpenBoxResp,CC.Notifications.NW_ReqRechargeOpenBox)
end

function NewPayGiftViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function NewPayGiftViewCtr:ReqRechargeInfoResp(err,data)
	log(CC.uu.Dump(data, "ReqRechargeInfoResp"))
	if err == 0 then
		self.view:RefreshView(data)
	end
end

function NewPayGiftViewCtr:ReqRechargeLotteryListResp(err,data)
	log(CC.uu.Dump(data, "ReqRechargeLotteryListResp"))
	if err == 0 then
		self:ShowWinRank(data.LotteryList)
	end
end

function NewPayGiftViewCtr:ReqRechargeRankResp(err,data)
	log(CC.uu.Dump(data, "ReqRechargeRankResp"))
    self.view:ShowPayRank(data)
end

function NewPayGiftViewCtr:ReqRechargeJPResp(err,data)
	if err == 0 then
		self:RefreshJackPot(data.JackPoint)
	end
end

function NewPayGiftViewCtr:ReqRechargeOpenBoxResp(err,data)
	log(CC.uu.Dump(data, "ReqRechargeOpenBoxResp"))
	if err == 0 then
		local Reward = {{ConfigId = data.AwardID,Count = data.AwardNum}}
        if data.OtherAwardList and #(data.OtherAwardList) > 0 then
            for i,v in ipairs(data.OtherAwardList) do
                table.insert(Reward,{ConfigId = v.AwardID,Count = v.AwardNum})
            end
        end
		self.view:StartLottery(Reward,data.JPType)
    elseif err == 538 or err == 539 then
        CC.Request("ReqRechargeInfo")
	end
end

function NewPayGiftViewCtr:ShowWinRank(LotteryList)
    if LotteryList == nil or #LotteryList <= 0 then return end
    --local ErJi, ShouJi, JackPot, DianKa = {},{},{},{}
    --for i,v in ipairs(LotteryList) do
        --if self:CheckReward(self.view.ErJi,v.PropID) then
            --table.insert(ErJi,v)
        --elseif self:CheckReward(self.view.ShowJi,v.PropID) then
            --table.insert(ShouJi,v)
        --elseif self:CheckReward(self.view.DianKa,v.PropID) then
            --table.insert(DianKa,v)
        --elseif v.PropID == CC.shared_enums_pb.EPC_ChouMa then
            --table.insert(JackPot,v)
        --end
    --end

    --if #ShouJi > 1 then table.sort(ShouJi,function(a,b) return self:PhysicalSort(a,b) end) end
    --if #ErJi > 1 then table.sort(ErJi,function(a,b) return self:PhysicalSort(a,b) end) end
    --if #DianKa > 1 then table.sort(DianKa,function(a,b) return self:PhysicalSort(a,b) end) end
    --if #JackPot > 1 then table.sort(JackPot,function(a,b) return self:JackPotSort(a,b) end) end
    --local list = {ErJi,ShouJi,JackPot,DianKa}
	
	local JackPot, Other = {},{}
	for i,v in ipairs(LotteryList) do
		if v.PropID == CC.shared_enums_pb.EPC_ChouMa then
			table.insert(JackPot,v)
		else
			table.insert(Other,v)
		end
	end
	if #JackPot > 1 then table.sort(JackPot,function(a,b) return self:JackPotSort(a,b) end) end
	if #Other > 1 then table.sort(Other,function(a,b) return self:PhysicalSort(a,b) end) end
	local list = {Other,JackPot}
    local index = 1
    if not self.WinnerList then self.WinnerList = {} end

    self.initLotList = coroutine.start(function()
        for i,part in ipairs(list) do
            for j,v in ipairs(part) do
                local Item = self.WinnerList[index]
                index = index + 1
                if not Item then
                    Item = CC.uu.newObject(self.view.WinItem,self.view.WinRankParent)
                    table.insert(self.WinnerList,Item)
                end
				Item:FindChild("Bg"):SetActive(i%2==0)
                self.view:ShowWinnerItem(Item,v)
                coroutine.step(1)
            end
        end
	end)
end

function NewPayGiftViewCtr:CheckReward(cfg,id)
    if not cfg or #(cfg) <= 0 then return false end

    for i,v in ipairs(cfg) do
        if v == id then return true end
    end
    return false
end

function NewPayGiftViewCtr:PhysicalSort(a,b)
    if a.PropID == b.PropID then
        return a.TimeStamp > b.TimeStamp
    else
        return self.propCfg[a.PropID].Value > self.propCfg[b.PropID].Value
    end
end

function NewPayGiftViewCtr:JackPotSort(a,b)
    if a.PropNum == b.PropNum then
        return a.TimeStamp > b.TimeStamp 
    else
        return a.PropNum > b.PropNum
    end
end


function NewPayGiftViewCtr:RefreshJackPot(Value)
	if not Value or Value <= 0 then Value = 0 end
	if self.JackPoint == Value then return end
	self.JackPoint = Value
	self.view:RefreshJackPot(Value)

end

function NewPayGiftViewCtr:Destroy()
	self:UnRegisterEvent()
    if self.initLotList then
		coroutine.stop(self.initLotList)
		self.initLotList = nil
	end
   
end

return NewPayGiftViewCtr;
