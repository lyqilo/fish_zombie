local CC = require("CC")
local GiftTurntableView = CC.uu.ClassView("GiftTurntableView")

local btnTenDark = Color(201,201,201,255)/255
local btnTenLight = Color(255,255,255,255)/255
local btnTenTextDark = Color(117,167,140,255)/255
local btnTenTextLight = Color(162,250,203,255)/255

function GiftTurntableView:ctor(param)
	self:InitVar(param);
end

function GiftTurntableView:InitVar(param)
	self.param = param;

	self.TurntableItemAll = {}
	self.LightAll = {}
    -- 初始角度记录
	self.TurnAngleAll = {0,45,90,135,180,225,270,315}
    --当前指针角度
	self.curAngle = 0
	--转盘转圈的圈数
	self.turnRoundNum = 8
	--当前选择块
	self.curBlock = nil
	--转动偏移值
	self.turnOffset = nil
	--是否需要监听指针位置
	self.isNeedListen = false
    --旧的三角光圈索引
	self.oldLightIndex = 1
	--剩余转盘次数
	self.canTurnTime = nil
    --是否有免费转盘
	self.isHaveFree = false
	--是否初始化转盘
	self.isInitTurntable = true

	self.language = CC.LanguageManager.GetLanguage("L_GiftExchangeView");
	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
end

function GiftTurntableView:OnCreate()
	self:InitUI()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:StartUpdate()
end

function GiftTurntableView:InitUI()
	for i=1,8 do
		table.insert(self.TurntableItemAll,self:FindChild("Center/bg/rewardAll/reward"..i))
	end

	for i=1,8 do
		table.insert(self.LightAll,self:FindChild("Center/bg/LightAll/trangleLight"..i))
	end
	self.freeBtn = self:FindChild("Center/bg/freeBtn")
	self.oneBtn = self:FindChild("Center/bg/oneBtn")
	self.tenBtn = self:FindChild("Center/bg/tenBtn")
	self.Spin = self:FindChild("Center/bg/Spin")
	self.tenOpenEffect = self:FindChild("Center/Effect_yzdb_baojiang_Da")
	self.OneOpenEffect = self:FindChild("Center/Effect_yzdb_baojiang_Xiao")

	self:FindChild("Center/bg/description").text = self.language.LotteryTip
	self.freeBtn:FindChild("Text").text = self.language.FreeLottery
	self:AddClick(self:FindChild("btnClose"),"ActionOut")
	self:AddClick(self.freeBtn,"ClickFreeLottery")
	self:AddClick(self.oneBtn,"ClickOneLottery")
	self:AddClick(self.tenBtn,"ClickTenLottery")
end

function GiftTurntableView:StartUpdate()

	UpdateBeat:Add(self.Update,self);
end

function GiftTurntableView:StopUpdate()

	UpdateBeat:Remove(self.Update,self);
end

function GiftTurntableView:Update()
    if self.isNeedListen then
        for i=1,8 do
        	if i == 1 then
        		if self.Spin.localEulerAngles.z % 360 > self.TurnAngleAll[i]-22.5 and self.Spin.localEulerAngles.z % 360 < self.TurnAngleAll[i] + 22.5 or self.Spin.localEulerAngles.z % 360 > 337.5 then
                   self.LightAll[self.oldLightIndex]:SetActive(false)
                   self.oldLightIndex = i
                   self.LightAll[i]:SetActive(true)
        	    end
        	else
        	    if self.Spin.localEulerAngles.z % 360 > self.TurnAngleAll[i]-22.5 and self.Spin.localEulerAngles.z % 360 < self.TurnAngleAll[i]+ 22.5 then
                   self.LightAll[self.oldLightIndex]:SetActive(false)
                   self.oldLightIndex = i
                   self.LightAll[i]:SetActive(true)
        	    end
        	end
        end
    end
end

function GiftTurntableView:ShowFreeBtn(isShow)
	self.freeBtn:SetActive(isShow)
	self.oneBtn:SetActive(not isShow)
	self.tenBtn:SetActive(not isShow)
end

function GiftTurntableView:ClickFreeLottery()
	if self.isHaveFree == false  then
		self:ShowFreeBtn(false)
		CC.ViewManager.ShowTip(self.language.NotEnoughTimes)
		return
	end
	self:SetCanClick(false)
	self.viewCtr:ReqFreeLottery(1)
end

function GiftTurntableView:ClickOneLottery()
	if self.canTurnTime < 1 then
		CC.ViewManager.ShowTip(self.language.NotEnoughTimes)
		return
	end
	self:SetCanClick(false)
	self.viewCtr:ReqFreeLottery(2)
end

function GiftTurntableView:ClickTenLottery()
	if self.canTurnTime < 10 then
		CC.ViewManager.ShowTip(self.language.NotEnoughTimes)
		return
	end
	self:SetCanClick(false)
	self.viewCtr:ReqTenLottery(3)
end

function GiftTurntableView:RefreshTurntableItem(data,param)
	if self.isInitTurntable then
		for i=1,8 do
			self:SetImage(self.TurntableItemAll[i], self.propCfg[data.items[i].rewardId].Icon)
			if data.items[i].rewardId == CC.shared_enums_pb.EPC_ChouMa then
				self.TurntableItemAll[i]:FindChild("Text").text =data.items[i].rewardCount
			elseif data.items[i].rewardCount == 1 then
				self.TurntableItemAll[i]:FindChild("Text").text =""
			else
				self.TurntableItemAll[i]:FindChild("Text").text ="x"..data.items[i].rewardCount
			end
			self.TurntableItemAll[i]:GetComponent("Image"):SetNativeSize()
	    end
	    self.tenBtn:FindChild("Text").text = self.language.TenLottery
	    self.isInitTurntable = false
    end
	self.canTurnTime = param.Times
	if param.FreeTimes ~=0 then
		self:ShowFreeBtn(true)
		self.isHaveFree = true
		--self.tenBtn:FindChild("Text"):GetComponent("Text").color = btnTenTextDark
		--self.tenBtn:GetComponent("Image").color = btnTenDark
		--self.tenBtn:GetComponent("Button"):SetBtnEnable(false)
	else
		self:ShowFreeBtn(false)
		self.isHaveFree = false
		self.oneBtn:FindChild("Text").text = string.format(self.language.OneLottery,self.canTurnTime)
		--self.tenBtn:FindChild("Text"):GetComponent("Text").color = btnTenTextLight
		--self.tenBtn:GetComponent("Image").color = btnTenLight
		--self.tenBtn:GetComponent("Button"):SetBtnEnable(true)
	end

end

function GiftTurntableView:FreeLotteryEvent(data)
	CC.Sound.PlayHallEffect("turntable_roll")
	self.isNeedListen = true
	local curAngle = self.curAngle
	self.curBlock = data.block
	self:RunAction(self.Spin,{"rotateTo",self:GetTargetAngle(curAngle),6,ease = CC.Action.EOutQuad,function()
		self:NormalizeAngle()
		CC.Sound.StopEffect()
		local reward = {}
		reward.ConfigId = data.rewardId
		reward.Count = data.rewardCount
		local rewardData = {}
        rewardData[1] = reward
        CC.uu.DelayRun(1,function()
        	self.OneOpenEffect:SetActive(true)
        end)
        CC.uu.DelayRun(2,function()
        	self:SetCanClick(true)
        	self.OneOpenEffect:SetActive(false)
        	CC.ViewManager.OpenRewardsView({items = rewardData})
		    self.viewCtr:ReqLotteryInfo()
        end)

	end})
end

function GiftTurntableView:GetTargetAngle(curAngle)
   self.turnOffset = math.random(-18,18)
   local targetAngle = self.turnRoundNum*360 + self.TurnAngleAll[self.curBlock] + self.turnOffset
   self.curAngle = targetAngle
   return -targetAngle
end

function GiftTurntableView:NormalizeAngle()
	self.curAngle = self.TurnAngleAll[self.curBlock] + self.turnOffset
	self:RunAction(self.Spin,{"rotateTo",-self.curAngle,0})
	CC.uu.DelayRun(0.4,function ()
		self.isNeedListen = false
		--选中光圈闪烁
        self:RunAction(self.LightAll[self.oldLightIndex],
        	{{"fadeToAll", 0, 0.1},
        	{"fadeToAll", 255, 0.1},
        	{"fadeToAll", 0, 0.1},
        	{"fadeToAll", 255, 0.1},
        	{"fadeToAll", 0, 0.1},
			{"fadeToAll", 255, 0.1}

        })
	end)

end
--十次抽奖
function GiftTurntableView:TenLotteryEvent(data)

	CC.Sound.PlayHallEffect("turntable_roll")
	self.isNeedListen = true
	local curAngle = self.curAngle
	self.curBlock = data[#data].block
	self:RunAction(self.Spin,{"rotateTo",self:GetTargetAngle(curAngle),6,ease = CC.Action.EOutQuad,function()
		self:NormalizeAngle()
		CC.Sound.StopEffect()
		local rewardData = {}
		for i=1,#data do
			local reward = {}
		    reward.ConfigId = data[i].rewardId
		    reward.Count = data[i].rewardCount
		    rewardData[i] = reward
		end
		CC.uu.DelayRun(1,function()
        	self.tenOpenEffect:SetActive(true)
        end)
		CC.uu.DelayRun(2,function()
			self:SetCanClick(true)
			self.tenOpenEffect:SetActive(false)
        	CC.ViewManager.OpenRewardsView({items = rewardData})
		    self.viewCtr:ReqLotteryInfo()
        end)
	end})
end

function GiftTurntableView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function GiftTurntableView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function GiftTurntableView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
	self:StopUpdate();
end

return GiftTurntableView