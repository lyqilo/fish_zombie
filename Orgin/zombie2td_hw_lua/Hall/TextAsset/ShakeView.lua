
local CC = require("CC")
local ShakeView = CC.uu.ClassView("ShakeView")

function ShakeView:ctor(GameId,callback)
	self.language = self:GetLanguage()
	self.callback = callback
	
	self.ShakeData = CC.DataMgrCenter.Inst():GetDataByKey("ShakeData")
	self.GameId = GameId
end

function ShakeView:OnCreate()
	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()
	self:Init()
	self:AddClickEvent()
	if self.callback then
		self.callback()
	end
end

function ShakeView:Init()
	self.LeftDeng = self:FindChild("Layer_UI/Main/LeftDeng")
	self.RightDeng = self:FindChild("Layer_UI/Main/RightDeng")
	self.BtnClose = self:FindChild("Layer_UI/Main/BtnClose")
	self.Btn = self:FindChild("Layer_UI/Main/Btn")
	self.BtnGray = self:FindChild("Layer_UI/Main/BtnGray")
	self.csyyl_an = self:FindChild("Layer_UI/Main/csyyl_an")
	self.SuperRewardTran = self:FindChild("Layer_UI/SuperRewardTran")
	self.RewardTran = self:FindChild("Layer_UI/RewardTran")
	self.RewardBtn = self.RewardTran:FindChild("Bg")
	self.SuperRewardBtn = self.SuperRewardTran:FindChild("Bg")
	self.SuperReward_NumberNode = self.SuperRewardTran:FindChild("View/Reward")
	self.Reward_NumberNode = self.RewardTran:FindChild("View/Reward")
	self.Mainobj = self:FindChild("Layer_UI/Main/obj")
	self.Rewardpoint = self:FindChild("Layer_UI/Main/Rewardpoint")
	self.ComBtn = self:FindChild("Layer_UI/RewardTran/View/Button")
	self.ComBtn:FindChild("Text").text = self.language.Get
	self.SupBtn = self:FindChild("Layer_UI/SuperRewardTran/View/Button")
	self.SupBtn:FindChild("Text").text = self.language.Get
	self.ComCloseBtn = self:FindChild("Layer_UI/RewardTran/View/BtnClose")
	self.SupCloseBtn = self:FindChild("Layer_UI/SuperRewardTran/View/BtnClose")
	self.viewCtr:ranInitNum()
	self.viewCtr:SetPoints(self.Mainobj,self.viewCtr.RangePoints)
	self.viewCtr:BtnShakeState()
	if self.ShakeData.GetExistState() == false then
		self.BtnClose:SetActive(true)
	end
	self:StartUpdate()
end

function ShakeView:AddClickEvent()
	self:AddClick(self.LeftDeng,"OpenDetal")
	self:AddClick(self.RightDeng,"OpenRank")
	self:AddClick(self.BtnClose,"ActionOut")
	self:AddClick(self.Btn,"BtnShake")
	self:AddClick(self.ComBtn,"ConfirmReward")
	self:AddClick(self.SupBtn,"ConfirmReward")
	self:AddClick(self.ComCloseBtn,"RewardFailClose")
	self:AddClick(self.SupCloseBtn,"RewardFailClose")
end

function ShakeView:StartUpdate()
	UpdateBeat:Add(self.viewCtr.Update,self.viewCtr);
end

function ShakeView:StopUpdate()
	UpdateBeat:Remove(self.viewCtr.Update,self.viewCtr);
end

--奖励界面关闭
function ShakeView:RewardClose()
	self.RewardTran:SetActive(false)
	self.SuperRewardTran:SetActive(false)	
	UIEvent.BtnInteractable(self.LeftDeng,true)
	UIEvent.BtnInteractable(self.RightDeng,true)
	self.BtnClose:SetActive(true)
	self:SetCanClick(true)
end

function ShakeView:RewardFailClose()
	self.RewardTran:SetActive(false)
	self.SuperRewardTran:SetActive(false)
	self.ComCloseBtn:SetActive(false)
	self.SupCloseBtn:SetActive(false)
end

function ShakeView:RewardFail(err)
	if err and err == CC.shared_en_pb.AlreadyConfirm then
		self.ShakeData.SetExistState(false)--已领取奖励
		self.RewardTran:SetActive(false)
		self.SuperRewardTran:SetActive(false)
	else
		self.ShakeData.SetExistState(true)--领奖失败，重置暗补状态
		self.ComCloseBtn:SetActive(true)
		self.SupCloseBtn:SetActive(true)
	end
	self.viewCtr:BtnShakeState()
	UIEvent.BtnInteractable(self.LeftDeng,true)
	UIEvent.BtnInteractable(self.RightDeng,true)
	self.BtnClose:SetActive(true)
	self:SetCanClick(true)
end

--摇色子
function ShakeView:BtnShake()
	self.viewCtr:Req_Open()
	
	self.ShakeData.SetExistState(false)--设置暗补领取状态

	self.viewCtr:BtnShakeState()

	self.Mainobj:SetActive(false)

	self.Rewardpoint:SetActive(true)

	UIEvent.BtnInteractable(self.LeftDeng,false)

	UIEvent.BtnInteractable(self.RightDeng,false)
	
	local function succCb()
		self.viewCtr:SetPoints(self.Mainobj,self.viewCtr.Points)
		self.Mainobj:SetActive(true)
		self.Rewardpoint:SetActive(false)
		self:DelayRun(1,function ()  --延迟1秒
			if self.viewCtr:IsLeopard() then  --判断是否为豹子
				Util.ClearChild(self.SuperReward_NumberNode)
				self.RewardTran:SetActive(false)
				self.SuperRewardTran:SetActive(true)
				self.viewCtr:ActionIn(self.SuperRewardTran)
				local tran = self.SuperRewardTran:FindChild("View/obj")
				self.viewCtr:SetPoints(tran,self.viewCtr.Points)
				self.viewCtr:ShowNum(self.SuperReward_NumberNode)
				self.SupBtn:SetActive(false)
			else
				Util.ClearChild(self.Reward_NumberNode)
				self.RewardTran:SetActive(true)
				self.viewCtr:ActionIn(self.RewardTran)
				self.SuperRewardTran:SetActive(false)
				local tran = self.RewardTran:FindChild("View/obj")
				self.viewCtr:SetPoints(tran,self.viewCtr.Points)
				self.viewCtr:ShowNum(self.Reward_NumberNode)
				self.ComBtn:SetActive(false)
				self.RewardTran:FindChild("View/DetalText"):GetComponent("Text").text = string.format(self.language.xishu,self.ShakeData.PointsSum(),self.ShakeData.GetNum()) 
			end		
		end)
	end

	local function errCb(err)
		if err and err == CC.shared_en_pb.AlreadyConfirm then
			--请求失败，已领取暗补奖励
			self.ShakeData.SetExistState(false)
		else
			--请求失败，重置暗补标记，复原所有按钮，打开关闭按钮，玩家可关闭暗补界面也可重新扔骰子
			self.ShakeData.SetExistState(true)
		end
		self.viewCtr:BtnShakeState()
		self.viewCtr:SetPoints(self.Mainobj,self.viewCtr.Points)
		self.Mainobj:SetActive(true)
		self.Rewardpoint:SetActive(false)
		UIEvent.BtnInteractable(self.LeftDeng,true)
		UIEvent.BtnInteractable(self.RightDeng,true)
		self.BtnClose:SetActive(true)
	end 

	self.viewCtr:DicActionStart(succCb,errCb)
end

function ShakeView:ConfirmReward()
	self:SetCanClick(false)
	self.viewCtr:Req_Confirm()
end

function ShakeView:ShowConfirmBtn()
	self.ComBtn:SetActive(true)
	self.SupBtn:SetActive(true)
end


--打开说明界面
function ShakeView:OpenDetal()
	CC.ViewManager.Open("ShakeExplainView")
end

--打开排行榜
function ShakeView:OpenRank()
	self.viewCtr:Req_DailyRank()
	self.viewCtr:Req_WeeklyRank()
end

function ShakeView:ActionOut()
	self:SetCanClick(false)
    self:RunAction(self, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
		self:Destroy()
	end})
end

function ShakeView:OnDestroy()
    CC.HallNotificationCenter.inst():post(CC.Notifications.OnpushShakeClose)		
	self:StopUpdate()
	self.viewCtr:OnDestroy()
end

return ShakeView