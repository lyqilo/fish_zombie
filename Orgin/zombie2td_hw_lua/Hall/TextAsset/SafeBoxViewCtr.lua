
local CC = require("CC")
local SafeBoxViewCtr = CC.class2("SafeBoxViewCtr")

function SafeBoxViewCtr:ctor(view, param)
	self:InitVar(view, param);
end

function SafeBoxViewCtr:InitVar(view, param)
	self.param = param
	self.view = view
	self.canInto = true
    self.canOut = true
	self.recordData = {}
end

function SafeBoxViewCtr:OnCreate()
	self:RegisterEvent()
	CC.Request("ReqCofferData")
	CC.Request("ReqCofferReceive")
end

function SafeBoxViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnReqCofferDataResp,CC.Notifications.NW_ReqCofferData)
	CC.HallNotificationCenter.inst():register(self,self.OnReqCofferDepositResp,CC.Notifications.NW_ReqCofferDeposit)
	CC.HallNotificationCenter.inst():register(self,self.OnReqCofferWithdrawalResp,CC.Notifications.NW_ReqCofferWithdrawal)
	CC.HallNotificationCenter.inst():register(self,self.OnReqCofferReceiveResp,CC.Notifications.NW_ReqCofferReceive)
end

function SafeBoxViewCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function SafeBoxViewCtr:OnReqCofferDataResp(err,data)
	log(string.format("err: %s    %s",err,CC.uu.Dump(data, "OnReqCofferDataResp: ")))
	if err == 0 then
		self:RefreshBalance(data)
	end
end

function SafeBoxViewCtr:ReqInto(amount)
	if not self.canInto then return end

	CC.ViewManager.ShowMessageBox(self.view.language.comInto,function()
		self.canInto = false
		self.amount = amount
		CC.Request("ReqCofferDeposit",{Amount = amount})
	end)
end

function SafeBoxViewCtr:OnReqCofferDepositResp(err,data)
	log(string.format("err: %s    %s",err,CC.uu.Dump(data, "OnReqCofferDepositResp: ")))
	self.canInto = true
	if err == 0 then
		self:RefreshBalance(data,1)
		CC.ViewManager.ShowTip(self.view.language.intoSucc)
	end
end

function SafeBoxViewCtr:ReqOut(amount)
	if not self.canOut then return end
    
	local reqOut = function(err,data)
		--验证安全码错误
		if err ~= 0 then return end

		self.canOut = false
		self.amount = amount
		CC.Request("ReqCofferWithdrawal",{Amount = amount,Token = data.Token})
		
	end
	if not CC.Player.Inst():GetSafeCodeData().SafeService[5].Status then
		CC.ViewManager.Open("VerSafePassWordView",{serviceType = 5,confirmStr = self.view.language.comTip,verifySuccFun = reqOut})
	else
		reqOut(0,{Token = ""})
	end
end

function SafeBoxViewCtr:OnReqCofferWithdrawalResp(err,data)
	log(string.format("err: %s    %s",err,CC.uu.Dump(data, "OnReqCofferWithdrawalResp: ")))
	self.canOut = true
	if err == 0 then
		self:RefreshBalance(data,2)
		CC.ViewManager.ShowTip(self.view.language.outSucc)
	end
end

function SafeBoxViewCtr:RefreshBalance(data,type)
	self.view.miniAmount = CC.uu.NumberFormat(data.MiniAmount)
	self.view.insuranceAmount = data.InsuranceAmount
	self.view.availableAmount = data.AvailableAmount
	self.view.currentMoney = data.CurrentMoney
	self.view:RefreshUI(type)

	if type then
		table.insert(self.recordData,1,Json.encode({Time = data.Time,Type = type,SaveAmount = self.amount}))
	end
end

function SafeBoxViewCtr:OnReqCofferReceiveResp(err,data)
	if err == 0 then
		self.recordData = data.Data
	end
end

function SafeBoxViewCtr:Destroy()
	self:UnRegisterEvent()
end

return SafeBoxViewCtr;
