------------------------------------
-- region SignZhuan.lua
-- Date: 2019.7.24
-- Desc: 老虎机功能
-- Author: chris
------------------------------------
local CC = require("CC")
local SignZhuan = CC.uu.ClassView("SignZhuan")


--公告
function SignZhuan:ctor()

	self.configData = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")--获取周榜前50名的奖励金额

	self.SignDefine = CC.DefineCenter.Inst():getConfigDataByKey("SignDefine")

	self.CurrentSpeed = 0.45

	self.time = 0.5

	self.Award_tranindex = 1

	self.QuicklyAudio = true
end

function SignZhuan:Create(param)
	self.tran = param.tran
	self.IsBuy = param.IsBuy
	self.Chip = param.Chip
	self.KuaiSuZhuanDon = param.KuaiSuZhuanDon
	self.EntityId = param.EntityId
	self.Value = param.Value
	self.callBack = param.callBack
	self.Award_UserDataSize = param.Award_UserDataSize
	self.SurplusNum = param.SurplusNum
	self.key = param.key
	self:AwardAnimation(self.key)
end

function SignZhuan:CanClick(flag)
	self:SetCanClick(flag)
	CC.HallNotificationCenter.inst():post(CC.Notifications.FreeChipsCollectionClickState, flag)
end

-- 开奖动画（老虎机功能）
function SignZhuan:AwardAnimation(key)
	CC.Sound.SetMusicVolume(0.3,1)
	self.Award_DataKey = key
	local Ticket = nil
	Ticket = self.tran:FindChild("Parent/Ticket"..tostring(self.Award_tranindex))
	local pos = Ticket.transform.localPosition
	self.Award_DataKey = self.Award_DataKey + 1
	-- logError("Award_UserDataSize = "..self.Award_UserDataSize.."  Award_DataKey = "..self.Award_DataKey)
	self.Award_tranindex = self.Award_tranindex + 1
	if self.Award_tranindex == 4 then --滚动的item下标记
		self.Award_tranindex = 1
	end

	local time_s
	if self.SurplusNum <= self.Award_DataKey then --当前滚动对象的下标记大于等于 剩余滚动次数的时候  滚动速度变慢
		self.CurrentSpeed = 0.45
		time_s = 0.2
		self.KuaiSuZhuanDon:SetActive(false)
		CC.Sound.PlayHallEffect("Soud_Turntablesman")
	else			--速度变快
		self.CurrentSpeed = 0.15
		time_s = 0.007
		self.KuaiSuZhuanDon:SetActive(true)
		if self.QuicklyAudio == true then
			self.QuicklyAudio = false
			CC.Sound.PlayHallEffect("Soud_Turntableskuai")
		end	
	end
	self:CurrentAwardSprite(Ticket)
	if self.Award_UserDataSize == self.Award_DataKey then  --当前为最后一个滚动目标的时候 该目标到指定位置停下 开奖
		Ticket.transform.localPosition = Vector3(pos.x, -110, 0)
		self:RunAction(Ticket, {"localMoveBy", 0, 110,self.CurrentSpeed, from = 1, ease=CC.Action.ELinear})
		self.Award_DataKey = 0
		self:IsBuyAnimation()
		self.QuicklyAudio = true
		self.SlowAudio = true
		return
	end
	Ticket.transform.localPosition = Vector3(pos.x, -222, 0)
	self:RunAction(Ticket, {"localMoveBy", 0, 222,self.CurrentSpeed, from = 1, ease=CC.Action.ELinear})
 	
	self.Award_co = self:DelayRun(time_s, function ()
		if self.Award_co then
			self:CancelDelayRun(self.Award_co)
			self.Award_co = nil
		end
		self:AwardAnimation(self.Award_DataKey)
 	end)
end


--获得当前奖品的图片
function SignZhuan:CurrentAwardSprite(tran)
	if self.Award_UserDataSize <= self.Award_DataKey then
		if self.EntityId == 2 then  --筹码
			self.Chip:SetActive(true)
			self.Chip:FindChild("Text"):GetComponent("Text").text = self.Value	
		end		
		local Spritename = self.configData[self.EntityId].Icon
		self:Qiehuan(tran,Spritename)
	else --点卡
		local i = math.random(1,#self.SignDefine.SpriteTab)
		local id = self.SignDefine.SpriteTab[i]
		self:Qiehuan(tran,self.configData[id].Icon)
	end
	tran:GetComponent("Image"):SetNativeSize()
end

--已经购买动画
function SignZhuan:IsBuyAnimation()
	self.IsBuyco = self:DelayRun(0.5, function ()
		self.IsBuy:SetActive(true)
		self.IsBuy.localScale = Vector3(5.9,5.9,1)
		CC.Sound.PlayHallEffect("GetSignReward")
		CC.Sound.SetMusicVolume()
		if self.callBack then self.callBack() end
		self:RunAction(self.IsBuy, {"scaleTo", 1, 1, 0.5, ease=CC.Action.EOutBack, function()
				local temp = {}
				temp[1] = {}
				temp[1].ConfigId = self.EntityId
				temp[1].Count = self.Value
				CC.ViewManager.OpenRewardsView({items = temp,title = "BoxAward"})
			--请求宝箱状态
			CC.Request("ReqAskBox")
		end})
 	end)	
end



function SignZhuan:Qiehuan(value,path)
	self:SetImage(value, path)
end
function SignZhuan:AddClickEvent()
end

--关闭
function SignZhuan:Close()
end


function SignZhuan:OnDestroy()

end

return SignZhuan