-----------------------------------------
-- region SignInViewCtr.lua
-- Date: 2019.7.13
-- Desc: 签到，宝箱的逻辑实现
-- Author: chris
----------------------------------------
local CC = require("CC")

local SignInViewCtr = CC.class2("SignInViewCtr")

function SignInViewCtr:ctor(view)

	self.SignData = CC.DataMgrCenter.Inst():GetDataByKey("SignData")

	self.configData = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")--获取周榜前50名的奖励金额

	self.SignDefine = CC.DefineCenter.Inst():getConfigDataByKey("SignDefine")

	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")

	--日期的格子数
	self.latticeCount = 42

	self.ItemIndex = 0

	self.NextMonItemIndex = 0

	self.PrevMonItemIndex = 0

	self.DateItemList = {}

	self.IsChooseDate = {}

	self.CurrentClickDate = 1

	self.DataKey = 1

	self.UserDataSize = 0

	self.UserName = nil

	self.RewardName = nil

	self.tranindex = 1

	self.DetailItemTab = {}

	self.QuicklyAudio = true

	self.SlowAudio = true

	self.SignEffect = false

	self.tab = {{{x=0,y=0,z=0},{x=-405,y=190,z=0},{x=-460,y=25,z=0}},
	{{x=0,y=0,z=0},{x=-143,y=117,z=0},{x=-260,y=34,z=0}},
	{{x=0,y=0,z=0},{x=221,y=194,z=0},{x=-83,y=22,z=0}},
	{{x=0,y=0,z=0},{x=-50,y=194,z=0},{x=106,y=31,z=0}}}

	self:InitVar(view)

end

local Lerp = function(a,b,t)
    return a + (b - a) * t
end

--特效抛物线移动
function SignInViewCtr:CurveMove(obj,pointList,duration,cb)
    obj.localPosition = pointList[1]
    obj.transform:SetActive(true)
    local co
    co = self.view:RunAction(obj,{
        {"to",1,100,duration,function(value)
            local t = value*0.01
            local newPointList = {}
            for i,pos in ipairs(pointList) do
                newPointList[i] = Vector3(pos.x,pos.y,pos.z)
            end
            for i = #newPointList-1,1,-1 do
                newPointList[i] = Lerp(newPointList[i],newPointList[i+1],t)
            end
            obj.localPosition = newPointList[1]
        end,
        ease=CC.Action.EInQuad,
        onEnd=function()
            self.view:StopAction(co)
            obj:SetActive(false)
            if cb then cb() end
        end,
        },
    })
end

function SignInViewCtr:itemData(item,param,i)
	local str = self.PropDataMgr.GetLanguageDesc( param.EntityId, param.value )
	local Spritename = self.configData[param.EntityId].Icon
	if i <= 2 then
		item:FindChild("DetalName"):GetComponent("Text").text = "<color=#00FF02FF>"..str.."</color>"
	else
		item:FindChild("DetalName"):GetComponent("Text").text = "<color=#FFFA01FF>"..str.."</color>"
	end
	self.view:SetImage(item:FindChild("DetalImg"), Spritename)

	item:FindChild("DetalImg"):GetComponent("Image"):SetNativeSize()
end

function SignInViewCtr:RefreshDetailObjAward(tab)
	local item
	if  #self.DetailItemTab > 0 then
		for i,v in ipairs(self.DetailItemTab) do
			item = v
			item:SetActive(true)
			self:itemData(item,tab[i],i)
		end
	else
		for i,v in ipairs(tab) do
			item = CC.uu.LoadHallPrefab("prefab", "DetailItem", self.view.DetalObjContent)
			item:SetActive(true)
			table.insert(self.DetailItemTab,item)
			self:itemData(item,tab[i],i)
		end
	end
end

function SignInViewCtr:OnCreate()
	self:RegisterEvent()
end

function SignInViewCtr:OnDestroy()
	self:unRegisterEvent()
	self.view = nil
end


function SignInViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.Resp_Sign,CC.Notifications.NW_ReqSign)
	CC.HallNotificationCenter.inst():register(self,self.Resp_AskReplenish,CC.Notifications.NW_ReqAskReplenish)
	CC.HallNotificationCenter.inst():register(self,self.Resp_Replenish,CC.Notifications.NW_ReqReplenish)
	CC.HallNotificationCenter.inst():register(self,self.Resp_AskBox, CC.Notifications.NW_ReqAskBox)
	CC.HallNotificationCenter.inst():register(self,self.Resp_OpenBoxDay, CC.Notifications.NW_ReqOpenBoxDay)
	CC.HallNotificationCenter.inst():register(self,self.Resp_OpenBoxWeek, CC.Notifications.NW_ReqOpenBoxWeek)
	CC.HallNotificationCenter.inst():register(self,self.Resp_OpenBoxHalfMonth, CC.Notifications.NW_ReqOpenBoxHalfMonth)
	CC.HallNotificationCenter.inst():register(self,self.Resp_OpenBoxMonth, CC.Notifications.NW_ReqOpenBoxMonth)
	CC.HallNotificationCenter.inst():register(self,self.Resp_AskRoll, CC.Notifications.NW_ReqAskRoll)
	CC.HallNotificationCenter.inst():register(self,self.Resp_AskRank, CC.Notifications.NW_ReqAskRank)
	CC.HallNotificationCenter.inst():register(self, self.SetAskSign, CC.Notifications.NW_ReqAskSign)
end

function SignInViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqSign)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqAskReplenish)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqReplenish)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqAskBox)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqOpenBoxDay)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqOpenBoxWeek)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqOpenBoxHalfMonth)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqOpenBoxMonth)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqAskRoll)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqAskRank)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqAskSign)
end



--随机一个总数
function SignInViewCtr:RanDomNum(tran,IsBuy,Chip,KuaiSuZhuanDon,param)
	self.Award_UserDataSize = 35--总次数
	self.SurplusNum = self.Award_UserDataSize - 8
	local temp = {}
	temp.tran = tran
	temp.IsBuy = IsBuy
	temp.Chip = Chip
	temp.KuaiSuZhuanDon = KuaiSuZhuanDon
	temp.EntityId = param.EntityId
	temp.Value = param.Value
	temp.callBack = param.callBack
	temp.Award_UserDataSize = self.Award_UserDataSize
	temp.SurplusNum = self.SurplusNum
	temp.key = 1

    local SignBandit= CC.ViewCenter.SignZhuan.new()
    SignBandit:Create(temp) --宝箱开奖  像老虎机那样转动 
end

--执行中奖广播（默认从第一条开始）
function SignInViewCtr:DataTextLoop()
	self:DataUp(1)
end

--中奖滚动报幕
function SignInViewCtr:DataUp(key)
	self.DataKey = key
	self.UserDataSize = self.SignData.GetRollLen()
	local time_s = 0.5
	if self.UserDataSize > 0 then --判断 中奖报幕的长度
		self.UserName = self.SignData.GetRollPlayerNick(self.DataKey)
		local EntityId = self.SignData.GetRollEntityId(self.DataKey)
		local Count = self.SignData.GetRollValue(self.DataKey)
		self.RewardName = self.PropDataMgr.GetLanguageDesc( EntityId, Count )
		local str = string.format(self.view.language.Luckball,"<color=#".."ffd800"..">"..self.UserName.."</color>","<color=#".."ffd800"..">"..self.RewardName.."</color>")
		local Line = nil
		Line = self.view.Str_parent:FindChild("Line"..tostring(self.tranindex))
		Line.gameObject:GetComponent('Text').text = str
		local pos = Line.transform.localPosition
		Line.transform.localPosition = Vector3(pos.x, 50, 0)
		self.DataKey = self.DataKey + 1
		self.tranindex = self.tranindex + 1
		if self.tranindex == 4 then --判断当前已经是第四条滚幕了，下一条滚幕的transform 又重置回1
			self.tranindex = 1
		end
		if self.UserDataSize < self.DataKey then
			self.DataKey = 1
		end
		self.view:RunAction(Line, {"localMoveBy", 0, -101, 5, from = 1, ease=CC.Action.ELinear})

		local kuan = Line.gameObject:GetComponent('RectTransform').sizeDelta.y
		--0.5为间隔
	 	time_s =  kuan/(101/5)
		
	end	
	self.co = self.view:DelayRun(time_s, function ()
		self:DataUp(self.DataKey)
 	end)
end


--计算指定年月日是星期几
function SignInViewCtr:GetWeekNum()
	local t 
    t = os.time({year=tostring(self.SignData.GetYeath()),month=tostring(self.SignData.GetMonth()),day=tostring(1)})
    local weekNum = os.date("*t",t).wday - 1
    if weekNum == 0 then  --星期6
        weekNum = 7
    end
	if weekNum == 7 then--星期天
		weekNum = 1
		return weekNum
	elseif weekNum >=1 and weekNum <7 then  --周一到周五
		weekNum = weekNum + 1
	  	return weekNum 
	end
end


--获得上一个月份的天数
function SignInViewCtr:GetPrevMonDay()
	local dayAmount = os.date("%d", os.time({year = tostring(self.SignData.GetYeath()), month = tostring(self.SignData.GetMonth()), day = 0}))
	return dayAmount
end


--初始化所有日期格子
function SignInViewCtr:LatticeInit(parent)
	for i = 1,self.latticeCount do
		local item =CC.uu.LoadHallPrefab("prefab", "DayItem", parent)		
		table.insert(self.DateItemList,item)
	end
end

--刷新所有日期
function SignInViewCtr:RefreshLattice()
	for i,v in ipairs(self.DateItemList) do
		-- logError("GetWeekNum = "..self:GetWeekNum().."i = "..i)
		if self:GetWeekNum() <= i  then
			self.ItemIndex = self.ItemIndex + 1
			if self.SignData.GetDateListLen()  >= self.ItemIndex then
				v:FindChild("Text").text = tostring(self.ItemIndex)
				self:ItemChange(v,self.SignData.GetDateStatu(self.ItemIndex),self.ItemIndex)
				if self.SignData.GetDateStatu(self.ItemIndex) == 2 then
					self:ItemAddClick(v,self.ItemIndex)
				elseif self.SignData.GetDateStatu(self.ItemIndex) == 1 then
					UIEvent.BtnInteractable(v,false)
				end
			elseif self.SignData.GetDateListLen() < self.ItemIndex  then
				--下个月的开头几天
				self.NextMonItemIndex = self.NextMonItemIndex + 1
				v:FindChild("Text").text = "<color=#39040d>"..tostring(self.NextMonItemIndex).."</color>"
			end

		else
			--上个月的后面几天
			local CurDay = (self:GetPrevMonDay() - (self:GetWeekNum() - 2)) + self.PrevMonItemIndex
			self.PrevMonItemIndex = self.PrevMonItemIndex + 1
			v:FindChild("Text").text = "<color=#39040d>"..tostring(CurDay).."</color>"
		end
	end
end

--选择日期，把以前选择的日期恢复没选中状态
function SignInViewCtr:SetDateItemActive()
	if not self.IsChooseDate then
		return
	end
	for i,v in ipairs(self.IsChooseDate) do
		self.view:SetImage(v, "bq_rl_zj03")
	end
	self.IsChooseDate = {}
end

--每个item的事件注册
function SignInViewCtr:ItemAddClick(item,date)
	self.view:AddClick(item,function ()
		self:SetDateItemActive(item)	
		self.view:SetImage(item, "bq_rl_zj02")
		self.CurrentClickDate = date
		table.insert(self.IsChooseDate,item)
		self.view:SupplyBtnActive(self:GetSupplyementStatu(),self.SignData.GetExpend())
	end)
end

--修改item的bg
function SignInViewCtr:ItemChange(item,index)
	local Sign = item:FindChild("Sign")
	if index == 1 then
		self.view:SetImage(item, "bq_rl_zj03")
		Sign:SetActive(true)
		self.view:SetImage(Sign, "bq_wq_yq")
	elseif  index == 2 then
		self.view:SetImage(item, "bq_rl_zj03")
		Sign:SetActive(true)
		self.view:SetImage(Sign, "bq_wq")
	elseif index == 3 then
		Sign:SetActive(false)
	end
end

--签到按钮切换
function SignInViewCtr:SignBtnChange()
	for i = 1,4 do
		if self.SignData.GetSignState() == false and self.SignData.GetCanOpen(i) == true then
			self.view.BtnSignInGray:SetActive(true)
			self.view.BtnSignIn:SetActive(false)
			return
		end
		
	end	
	if self.SignData.GetSignState() == true  then
		self.view.BtnSignInGray:SetActive(true)
		self.view.BtnSignIn:SetActive(false)
	elseif self.SignData.GetSignState() == false  then
		self.view.BtnSignInGray:SetActive(false)
		self.view.BtnSignIn:SetActive(true)
	end
end

--如果未选中日期，返回false 否则返回true
function SignInViewCtr:GetSupplyementStatu()
	if #self.IsChooseDate > 0 then
		return true
	else
		return false
	end
end

function SignInViewCtr:InitVar(view)
	--UI对象
	self.view = view
end

--签到成功
function SignInViewCtr:Resp_Sign(err,data)
	-- logError("Resp_Sign err = "..err)
	-- CC.uu.Log(data,"Resp_Sign",3)
	if err == 0 then
		self.SignData.SetSignState(true)
		self.SignData.SetSignRewards(data)
		CC.Request("ReqAskBox")
		self.SignEffect = true
	else
		self.SignEffect = false
	end
end

--查询补签信息返回
function SignInViewCtr:Resp_AskReplenish(err,data)
	if err == 0 then
		self.ItemIndex = 0
		self.NextMonItemIndex = 0
		self.PrevMonItemIndex = 0
		self.SignData.SetAskReplenish(data)
		self.view.ThreetySign:SetActive(true)
		self:RefreshLattice()
		self:SetDateItemActive()
		local param = {}
		param.Yeath = self.SignData.GetYeath()
		param.Month = self.SignData.GetMonth()
		param.Date = self.SignData.GetCurrenDate()
		param.Expend = self.SignData.GetExpend()
		param.b = self:GetSupplyementStatu()
		self.view:RefreshSupplementary(param)
	end
end


function SignInViewCtr:UpdateEntityIdAndValue(i,id,value)
	-- logError("i = "..i.." id = "..id.." value = "..value)
	self.SignData.SetEntityId(i,id)
	self.SignData.SetEntityIdValue(i,value)
	self.SignData.SetAskBoxCanOpen(i,false)
	self.SignData.SetAskBoxIsOpen(i,true)
end
--补签返回
function SignInViewCtr:Resp_Replenish(err,data)
	if err == 0 then
		CC.Request("ReqAskReplenish")
		CC.Request("ReqAskBox")
		self.view:CloseTipPanel()
	else
		logError("Replenisherr = "..err)
	end
end

--返回是否可以开启签到宝箱
function SignInViewCtr:Resp_AskBox(err,data)
	-- logError("Resp_AskBox err = "..err)
	-- CC.uu.Log(data,"Resp_AskBox",3)
	if err == 0 then
		self.SignData.SetAskBox(data)
		self.view:Refresh_Treasure()
		self.view:TreasurechestClick()		
		self:SignBtnChange()
	end
end


--返回开启次日宝箱
function SignInViewCtr:Resp_OpenBoxDay(err,data)
	-- logError("Resp_OpenBoxDay err = "..err)
	-- CC.uu.Log(data,"Resp_OpenBoxDay",3)	
	if err == 0 then
		self.SignData.SetDailyContent(data)
		self.view:OpenBoxCallBack(1)
		self:UpdateEntityIdAndValue(1,self.SignData.GetBoxType(1),self.SignData.GetBoxValue(1))
	end
end

--返回开启七日宝箱
function SignInViewCtr:Resp_OpenBoxWeek(err,data)
	-- logError("Resp_OpenBoxWeek err = "..err)
	-- CC.uu.Log(data,"Req_OpenBoxWeek",3)	
	if err == 0 then
		self.SignData.SetWeekContent(data)
		self.view:OpenBoxCallBack(2)
		self:UpdateEntityIdAndValue(2,self.SignData.GetBoxType(2),self.SignData.GetBoxValue(2))
	end
end

--开启15日宝箱
function SignInViewCtr:Resp_OpenBoxHalfMonth(err,data)
	-- logError("Resp_OpenBoxHalfMonth err = "..err)
	-- CC.uu.Log(data,"Resp_OpenBoxHalfMonth",3)	
	if err == 0 then
		self.SignData.SetBoxHalfMonthContent(data)
		self.view:OpenBoxCallBack(3)
		self:UpdateEntityIdAndValue(3,self.SignData.GetBoxType(3),self.SignData.GetBoxValue(3))
	end
end 

--开启30日宝箱
function SignInViewCtr:Resp_OpenBoxMonth(err,data)
	-- logError("Resp_OpenBoxMonth err = "..err)
	-- CC.uu.Log(data,"Resp_OpenBoxMonth",3)	
	if err == 0 then
		self.SignData.SetBoxMonthContent(data)
		self.view:OpenBoxCallBack(4)
		self:UpdateEntityIdAndValue(4,self.SignData.GetBoxType(4),self.SignData.GetBoxValue(4))
	end
end


--返回是否可以签到
function SignInViewCtr:SetAskSign(err,data)	
	-- logError("SetAskSign err = "..err)
	-- CC.uu.Log(data,"SetAskSign",3)
	if err == 0 then
		CC.DataMgrCenter.Inst():GetDataByKey("SignData").SetSignState(data.IsSign)
		self:SignBtnChange()
	end
end

--滚幕
function SignInViewCtr:Resp_AskRoll(err,data)
	-- logError("Resp_AskRoll err = "..err)
	-- logError(CC.uu.Dump(data,"Resp_AskRoll",100))
	if err == 0 then
		self.SignData.SetRollData(data)
		self:DataTextLoop()
	end
end

--中奖名单
function SignInViewCtr:Resp_AskRank(err,data)
	-- logError("Resp_AskRank err = "..err)
	-- CC.uu.Log(data,"Resp_AskRank",3)	
	if err == 0 then
		self.SignData.SetRankData(data)
		CC.ViewManager.Open("SignWinView")	
	end
end

return SignInViewCtr