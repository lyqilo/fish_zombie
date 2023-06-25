local CC = require("CC")

local VipView = CC.uu.ClassView("VipView")

local UnlockSessionName = {		
		[1] = "primary",
		[2] = "middle",
		[3] = "advanced",
		[4] = "expert",
	}

function VipView:ctor(level)
	self.level = level
end

function VipView:OnCreate()

	self.basePayment = 5000	--救济金

	self.limitLevel = 3

	self:RegisterEvent()
	self:AddClick("bg/ExitBtn",function ()
		self:Destroy()
	end)
	self:AddClick("More/bg/ExitBtn",function ()
		self:FindChild("More"):SetActive(false)
	end)
	self:AddClick("bg/Top/topBG/RechargeBtn",function ()
		CC.ViewManager.OpenAndReplace("StoreView")
	end)
	self:AddClick("bg/Top/Exchange",function ()
		if not CC.ViewManager.IsSwitchOn("VIPPoint") then
			return;
		end
		self:FindChild("Exchange"):SetActive(true)
	end)
	self:AddClick("Exchange/bg/ExitBtn",function ()
		self:FindChild("Exchange"):SetActive(false)
	end)
	self:AddClick("Exchange/bg/AddBtn",function ()
		self:RefreshExchange(true)
	end)
	self:AddClick("Exchange/bg/LessBtn",function ()
		self:RefreshExchange(false)
	end)
	self:AddClick("Exchange/bg/SubBtn","Req")
	self.levelData = CC.ConfigCenter.Inst():getConfigDataByKey("Level")
	self.vipRight = CC.ConfigCenter.Inst():getConfigDataByKey("VIPRights")
	self.language = self:GetLanguage()
	self:RefreshSelfInfo()

	if self.level == 30 then
		self.count = 31
	else
		self.count = 30
	end

	self.ScrollerController = self:FindChild("bg/ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:ItemData(tran,dataIndex,cellIndex)
	end)

	self.ScrollerController:InitScroller(self.count)
end

function VipView:RefreshSelfInfo()
	self.level = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	self.exp = CC.Player.Inst():GetSelfInfoByKey("EPC_Experience")
	self.vipSpot = math.floor(CC.Player.Inst():GetSelfInfoByKey("EPC_VIPPoint")/20000)

	self:InitUI()
end

function VipView:ItemData(tran,dataIndex,cellIndex)
	local id = (self.level + dataIndex)%self.count
	local data = self.vipRight[id+2]
	tran.name = id
	self:InitItemText(tran)
	if id + 1 > 30 then
		tran.transform:FindChild("Normal"):SetActive(false)
		tran.transform:FindChild("Text"):SetActive(true)
	else
		if id + 1 == 30 then
			tran.transform:FindChild("Normal/Exp"):SetActive(false)
			tran.transform:FindChild("Normal/Expend"):SetActive(false)
		elseif id + 1 == 1 then
			tran.transform:FindChild("Normal/Exp"):SetActive(true)
			tran.transform:FindChild("Normal/Expend"):SetActive(false)
		else
			tran.transform:FindChild("Normal/Exp"):SetActive(true)
			tran.transform:FindChild("Normal/Expend"):SetActive(true)
		end
		local exp = 0
		for i=0,id do
			exp = exp + self.levelData[i].Experience
		end
		tran.transform:FindChild("Normal"):SetActive(true)
		tran.transform:FindChild("Text"):SetActive(false)
		tran.transform:FindChild("Normal/Vip/Text").text = data.Viplv
		tran:FindChild("Normal/Vip"):SetImage(string.format("vip%d", math.floor(data.Viplv/10)+1 > 3 and 3 or math.floor(data.Viplv/10)+1))
		tran.transform:FindChild("Normal/Level").text = data.Viplv	
		tran.transform:FindChild("Normal/RightsNode/Horn/Text").text = data.Freeprop[1].Count

		if self.limitLevel > data.Viplv then
			tran.transform:FindChild("Normal/RightsNode/MaxGiveCount"):SetActive(false);
		else
			tran.transform:FindChild("Normal/RightsNode/MaxGiveCount"):SetActive(true);
			local desText = ""
			if data.MaxGiveCount > self.vipRight[14].MaxGiveCount then
				desText = self.language.maxGiveCount
			else
				desText = CC.uu.ChipFormat(data.MaxGiveCount)
			end
			tran.transform:FindChild("Normal/RightsNode/MaxGiveCount/Text").text = desText
		end
		--增加新权益
		if data.Viplv > 19 then
			tran.transform:FindChild("Normal/RightsNode/SendLimit"):SetActive(true);
		else
			tran.transform:FindChild("Normal/RightsNode/SendLimit"):SetActive(false);
		end
		tran.transform:FindChild("Normal/RightsNode/SendLimit/Text").text = CC.uu.ChipFormat(data.MinGiveCount)
		tran.transform:FindChild("Normal/RightsNode/Chip/Text").text = data.PaymentCount + self.basePayment
		tran.transform:FindChild("Normal/Exp").text = exp/1000000 .."฿"
		tran.transform:FindChild("Normal/Expend").text = CC.uu.ChipFormat(exp)
	
		tran.transform:FindChild("Normal/MoreBtn").onClick = function ()
			self:OpenMoreDetail(data)
		end
	end
end

function VipView:OpenMoreDetail(data)
	self:FindChild("More/bg/Scroll View/Viewport/Content/LoginRewards/Text/Value").text = CC.uu.ChipFormat(data.MinGiveCount)
	self:FindChild("More/bg/Scroll View/Viewport/Content/Freeprop/Text/Value").text = data.Freeprop[1].Count..self.language.chip
	self:FindChild("More/bg/Scroll View/Viewport/Content/Payment/Text/Value").text = (data.PaymentCount + self.basePayment)..self.language.chip
	if self.limitLevel > data.Viplv then
		self:FindChild("More/bg/Scroll View/Viewport/Content/MaxGiveCount"):SetActive(false);
		self:FindChild("More/bg/Scroll View/Viewport/Content/GiveRemaining"):SetActive(false);
		self:FindChild("More/bg/Scroll View/Viewport/Content/GivingTax"):SetActive(false)
		self:FindChild("More/bg/Scroll View/Viewport/Content/GiveBuy"):SetActive(false)
		self:FindChild("More/bg/Scroll View/Viewport/Content/LoginRewards"):SetActive(false)
	else	
		self:FindChild("More/bg/Scroll View/Viewport/Content/MaxGiveCount"):SetActive(true);
		self:FindChild("More/bg/Scroll View/Viewport/Content/LoginRewards"):SetActive(true)
		local desText = ""
		if data.MaxGiveCount > self.vipRight[14].MaxGiveCount then
			desText = self.language.maxGiveCount
		else
			desText = CC.uu.ChipFormat(data.MaxGiveCount)
		end
		self:FindChild("More/bg/Scroll View/Viewport/Content/MaxGiveCount/Text/Value").text = desText..self.language.day
		self:FindChild("More/bg/Scroll View/Viewport/Content/GiveRemaining"):SetActive(true);
		self:FindChild("More/bg/Scroll View/Viewport/Content/GiveRemaining/Text/Value").text = data.GiveRemaining..self.language.chip

		self:FindChild("More/bg/Scroll View/Viewport/Content/GivingTax"):SetActive(true)
		self:FindChild("More/bg/Scroll View/Viewport/Content/GivingTax/Text/Value").text = data.GivingTax * 100 .."%"--..data.GiveCaps
		self:FindChild("More/bg/Scroll View/Viewport/Content/GiveBuy"):SetActive(true)
		self:FindChild("More/bg/Scroll View/Viewport/Content/GiveBuy/Text/Value").text = data.GiveBuy..self.language.day
	end

	-- self:FindChild("More/bg/Scroll View/Viewport/Content/BuyCD/Text/Value").text = data.BuyCD.."Min"
	self:FindChild("More/bg/Scroll View/Viewport/Content/VipPointExchange/Text/Value").text = data.VipPointExchange..self.language.power
	self:FindChild("More/bg/Scroll View/Viewport/Content/VipLottery/Text/Value").text = data.VipLottery.."%"
	self:FindChild("More"):SetActive(true)
end

function VipView:InitUI()
	if self.vipSpot > 10000 then
		self.num = 1
	else
		self.num = 0
	end
	self:RefreshExchange(false)

	self.slider = self:FindChild("bg/Top/topBG/ExSlider")
	local exp = 0
	for i=0,self.level do
		exp = exp + self.levelData[i].Experience
		if i <= self.level - 1 then
			self.exp = self.exp + self.levelData[i].Experience
		end
	end
	self.slider:GetComponent("Slider").value = self.exp/exp
	self:FindChild("bg/Top/topBG/ExSlider/now").text = CC.uu.ChipFormat(self.exp/1000000)
	self:FindChild("bg/Top/topBG/ExSlider/next").text = CC.uu.ChipFormat(exp/1000000)
	self:FindChild("bg/Top/topBG/Recharge").text = string.format(self.language.label_Recharge,CC.uu.ChipFormat((exp - self.exp)/1000000))
	if self.level == 30 then
		self.slider:GetComponent("Slider").value = 1
		self:FindChild("bg/Top/topBG/ExSlider/now"):SetActive(false)
		self:FindChild("bg/Top/topBG/ExSlider/next"):SetActive(false)
		self:FindChild("bg/Top/topBG/Recharge"):SetActive(false)
	end
	self:FindChild("bg/Top/VIPSpot").text = self.vipSpot
	self:FindChild("bg/Top/topBG/Vip/Text").text = self.level
	self:FindChild("bg/Top/topBG/Vip"):SetImage(string.format("vip%d", math.floor(self.level/10)+1 > 3 and 3 or math.floor(self.level/10)+1))
	self:FindChild("Exchange/bg/Title/Text").text = self.language.Exchange
	self:FindChild("Exchange/bg/SPLabel/VIPSpot").text = self.vipSpot
	self:FindChild("Exchange/bg/SPLabel").text = self.language.VIPSpot
	self:FindChild("Exchange/bg/VIPLevel").text = string.format(self.language.VIPSpotRatio_exchange,self.vipRight[self.level+1].VipPointExchange)
	self:FindChild("Exchange/bg/SubBtn/Text").text = self.language.btn_Exchange

	self:InitTextByLanguage()
end

function VipView:InitTextByLanguage()
	self:FindChild("bg/Top/VIPSpot/Text").text = self.language.VIPSpot
	self:FindChild("bg/Top/topBG/RechargeBtn/Text").text = self.language.btn_Recharge

	self:FindChild("bg/Top/Exchange/Text").text = self.language.Exchange
	self:FindChild("More/bg/Title/Text").text = self.language.btn_More
	self:FindChild("More/bg/Scroll View/Viewport/Content/LoginRewards/Text").text = self.language.loginAward
	self:FindChild("More/bg/Scroll View/Viewport/Content/Freeprop/Text").text = self.language.horn
	self:FindChild("More/bg/Scroll View/Viewport/Content/Payment/Text").text = self.language.subsidy
	self:FindChild("More/bg/Scroll View/Viewport/Content/MaxGiveCount/Text").text = self.language.sendLimit
	self:FindChild("More/bg/Scroll View/Viewport/Content/GivingTax/Text").text = self.language.sendTax
	self:FindChild("More/bg/Scroll View/Viewport/Content/GiveRemaining/Text").text = self.language.sendSurplus
	self:FindChild("More/bg/Scroll View/Viewport/Content/GiveBuy/Text").text = self.language.sendTimeLock
	-- self:FindChild("More/bg/Scroll View/Viewport/Content/BuyCD/Text").text = self.language.buyCD
	self:FindChild("More/bg/Scroll View/Viewport/Content/VipPointExchange/Text").text = self.language.VIPSpotRatio
	self:FindChild("More/bg/Scroll View/Viewport/Content/VipLottery/Text").text = self.language.VipLottery
end

function VipView:RefreshExchange(isAdd)
	self:FindChild("Exchange/bg/VipBG/Text").text = self.level
	if isAdd then
		self.num = self.num + 1
	else
		self.num = self.num - 1
	end
	if self.num * 10000 > self.vipSpot then self.num = self.num -1 end
	if self.num > 50 then 
		self.num = 50
		CC.ViewManager.ShowTip(self.language.tip_vipSpotMax)
	end 
	if self.num < 0 then 
		self.num = 0
	end
	if self.num == 0 then
		self:FindChild("Exchange/bg/SubBtn"):GetComponent("Button"):SetBtnEnable(false)
	else
		self:FindChild("Exchange/bg/SubBtn"):GetComponent("Button"):SetBtnEnable(true)
	end
	self:FindChild("Exchange/bg/TextBG/Text").text = self.num
	self:FindChild("Exchange/bg/BG/Spot").text = self.num * 10000
	self:FindChild("Exchange/bg/BG/Chip").text = self.num * 15000 * self.vipRight[self.level+1].VipPointExchange
end

function VipView:InitItemText(tran)
	tran.transform:FindChild("Text").text = self.language.label_VIPfull
	tran.transform:FindChild("Normal/Level/Text").text = self.language.nextVIP_Level
	tran.transform:FindChild("Normal/Exp/Text").text = self.language.accumulatedValue
	tran.transform:FindChild("Normal/Expend/Text").text = self.language.accumulatedChips
	tran.transform:FindChild("Normal/RightsNode/Horn/label").text = self.language.horn
	tran.transform:FindChild("Normal/RightsNode/MaxGiveCount/label").text = self.language.sendLimit
	tran.transform:FindChild("Normal/RightsNode/SendLimit/label").text = self.language.loginAward
	tran.transform:FindChild("Normal/RightsNode/Chip/label").text = self.language.subsidy
	tran.transform:FindChild("Normal/MoreBtn/Text").text = self.language.btn_More
end

function VipView:ActionIn()
	-- body
end

function VipView:Req()
	local copies = self.num
	CC.Request("VipPointChange",{Copies=copies},function (err,data)
		local param = {}
		param[1] = 
		{
			ConfigId = 2,
			Count = copies * 15000 * self.vipRight[self.level+1].VipPointExchange
		}
		CC.ViewManager.OpenRewardsView({items = param})
		self:FindChild("Exchange"):SetActive(false)
	end,
	function (err,data)
		logError(err)
	end)
	
end

function VipView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RefreshSelfInfo,CC.Notifications.changeSelfInfo)
end

function VipView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.changeSelfInfo)
end

function VipView:OnDestroy()

	self:unRegisterEvent()
end

return VipView