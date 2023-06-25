local ObjectPool = require("Common/ObjectPool")
local BroadcastTipsItem = require("View/RewardNoticeView/BroadcastTipsItem")
local AwardTipsItem = require("View/RewardNoticeView/AwardTipsItem")
local ArenaTipsItem = require("View/RewardNoticeView/ArenaTipsItem")
local TreasureTipsItem = require("View/RewardNoticeView/TreasureTipsItem")
local BigRewardTipsItem = require("View/RewardNoticeView/BigRewardTipsItem")
local CC = require("CC")
local baseClass = CC.uu.ClassView("RewardNoticeView")

function baseClass:GlobalNode()
	return GameObject.Find("DontDestroyGNode/GaussCanvas/GExtend").transform
end

function baseClass:OnCreate( ... )
	self:AddToDontDestroyNode()
	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	self.language = CC.LanguageManager.GetLanguage("L_OnlineLottery");
	self.unShowList = {}
	self.showCount = 0
	self.screenWidth = self:GetComponent("RectTransform").rect.width
	self:InitPool()
end

--[[
	data = {
		type = 0, -- 0 活动提示，1 大奖提示，2 获奖提示, 3 竞技场 , 4 比赛赢家
		Props = {ConfigId,Count},
		name = "吴彦祖",
		time = 300,
		callback = function, -- 回调
		showTime = 3, -- 显示时间
		showInterval = 3, -- 显示间隔
	}
]]
function baseClass:Show( data, isLeft, offset, immediately)
	if data.Props == nil then
		logError(CC.uu.Dump(data,"RewardNoticeView:Show",10))
		return
	end
	if self.showCount == 0 or immediately then
		self:PlayAnim( data, isLeft, offset )
	else
		table.insert(self.unShowList,{ data, isLeft, offset })
	end
end

function baseClass:PlayAnim( data, isLeft, offset )
	local item
	-- type 2， 使用另外一个界面
	if data.type == 3 or data.type == 4 then
		item = self.arenaTipsPool:Get()
	elseif data.type == 2 then
		item = self.awardTipsPool:Get()
	elseif data.type == 5 then
		item = self.treasurePool:Get()
	elseif data.type == 6 then
		item = self.bigRewardPool:Get()
	else
		item = self.broadcastTipsPool:Get()
	end

	item:InitData(data, isLeft, offset)
	item:UpdateView(data)
	self.showCount = self.showCount + 1
	item:PlayAnim()
end

function baseClass:CheckUnShowList()
	if table.getn(self.unShowList) > 0 and self.showCount == 0 then
		self:PlayAnim(unpack(table.remove(self.unShowList,1)))
	end
end

function baseClass:OnDestroy()
	self.arenaTipsPool:Clear()
	self.awardTipsPool:Clear()
	self.broadcastTipsPool:Clear()
	self.treasurePool:Clear()
	self.bigRewardPool:Clear()
end

function baseClass:InitPool()
	local closeCallback = function (item)
		if item.type == 3 or item.type == 4 then
			self.arenaTipsPool:Release(item)
		elseif item.type == 2 then
			self.awardTipsPool:Release(item)
		elseif item.type == 5 then
			self.treasurePool:Release(item)
		elseif item.type == 6 then
			self.bigRewardPool:Release(item)
		else
			self.broadcastTipsPool:Release(item)
		end
		self.showCount = self.showCount - 1
		self:StartTimer("CheckNext",item.showInterval,function()
			self:CheckUnShowList()
		end)
	end

	local broadcastTipsGo = self:FindChild("broadcastTips")
	broadcastTipsGo:SetActive(false)
	local awardTipsGo = self:FindChild("awardTips")
	awardTipsGo:SetActive(false)
	local arenaTipsGo = self:FindChild("arenaTips")
	arenaTipsGo:SetActive(false)
	local treasureTipsGo = self:FindChild("treasureTips")
	treasureTipsGo:SetActive(false)
	local bigRewardTipsGo = self:FindChild("BigRewardTips")
	bigRewardTipsGo:SetActive(false)

	local c_flag = true
	local c_createFunc = function ()
		local obj
		if c_flag then
			obj = arenaTipsGo
			c_flag = false
		else
			obj = CC.uu.newObject(arenaTipsGo, self.transform)
		end
		local item = ArenaTipsItem.new(self,obj,closeCallback)
		return item
	end

	local b_flag = true
	local b_createFunc = function ()
		local obj
		if b_flag then
			obj = broadcastTipsGo
			b_flag = false
		else
			obj = CC.uu.newObject(broadcastTipsGo, self.transform)
		end
		local item = BroadcastTipsItem.new(self,obj,closeCallback)
		return item
	end

	local a_flag = true
	local a_createFunc = function ()
		local obj
		if a_flag then
			obj = awardTipsGo
			a_flag = false
		else
			obj = CC.uu.newObject(awardTipsGo, self.transform)
		end
		local item = AwardTipsItem.new(self,obj,closeCallback)
		return item
	end

	local d_flag = true
	local d_createFunc = function ()
		local obj
		if d_flag then
			obj = treasureTipsGo
			d_flag = false
		else
			obj = CC.uu.newObject(treasureTipsGo, self.transform)
		end
		local item = TreasureTipsItem.new(self,obj,closeCallback)
		return item
	end
	
	local e_flag = true
	local e_createFunc = function ()
		local obj
		if e_flag then
			obj = bigRewardTipsGo
			e_flag = false
		else
			obj = CC.uu.newObject(bigRewardTipsGo, self.transform)
		end
		local item = BigRewardTipsItem.new(self,obj,closeCallback)
		return item
	end
	
	self.broadcastTipsPool = ObjectPool.New(b_createFunc)
	self.awardTipsPool = ObjectPool.New(a_createFunc)
	self.arenaTipsPool = ObjectPool.New(c_createFunc)
	self.treasurePool = ObjectPool.New(d_createFunc)
	self.bigRewardPool = ObjectPool.New(e_createFunc)
end

return baseClass