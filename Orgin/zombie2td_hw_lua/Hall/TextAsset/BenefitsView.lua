
local CC = require("CC")
local BenefitsView = CC.uu.ClassView("BenefitsView")

--[[
@param
Type:			救济金类型
UnderAmount: 	领取限制的金额
Amount:			金额
LeftTimes:		剩余次数
Callback: 		关闭回调
]]

local BenefitsType = {
	Normal = 1,
	VIP = 2,	
}

function BenefitsView:ctor(param)
	CC.uu.Log(param,"BenefitsView",1)
	self.param = param;
	self.language = self:GetLanguage();
	self.errTimes = 0
end

function BenefitsView:OnCreate()
	self:InitContent()
	self:CheckMonthCard()
end

function BenefitsView:InitContent()

	if not self.param then
		return
	end

	self.btnClose = self:FindChild("Frame/BtnClose")
	self:FindChild("Frame/Top/Title").text = self.language["title"..self.param.Type]

	local tips = self:FindChild("Frame/Tips/Text2");
	tips.text= self.language.tips2;
	local times = self:FindChild("Frame/Remain/Text");
	times.text = self.language.tips3;
	local btnDetermine = self:FindChild("Frame/BtnOk/Text");
	btnDetermine.text = self.language.determine;

	if self.param.UnderAmount then
		local tips = self:FindChild("Frame/Tips/Text1");
		tips.text = string.format("%s<color=#f1e414>%s</color>,", self.language.tips1, CC.uu.numberToStrWithComma(self.param.UnderAmount));
	end
	
	local chipCount = self:FindChild("Frame/Award/ChipCount");
	if self.param.Amount then
		chipCount.text = CC.uu.numberToStrWithComma(self.param.Amount);
	else
		chipCount.text = "0";
	end
	
	local remainTimes = self:FindChild("Frame/Remain/Times");
	if self.param.LeftTimes then
		remainTimes.text = self.param.LeftTimes;
	else
		remainTimes.text = "1"
	end

	self:AddClick("Frame/BtnOk", "OnClickOk");
	self:AddClick("Frame/BtnClose", "ActionOut");

	self:ActionIn();
end

--检查月卡是否过期，没有过期的话需要展示月卡相关的权益
function BenefitsView:CheckMonthCard()
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Super") > 0 or CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") > 0 then
		local data = {
			propIds = {CC.shared_enums_pb.EPC_Super,CC.shared_enums_pb.EPC_Supreme},
			succCb = function()
				local card1 = CC.Player.Inst():GetSelfInfoByKey("EPC_Super") or 0 --小月卡
				local card2 = CC.Player.Inst():GetSelfInfoByKey("EPC_Supreme") or 0 --大月卡
				self:FindChild("Frame/Award/Card1"):SetActive(card1 > 0)
				self:FindChild("Frame/Award/Card2"):SetActive(card2 > 0)
				self:FindChild("Frame/Award/Card12"):SetActive(card1 > 0 and card2 > 0)

				--这里是为了让玩家知道是因为拥有月卡所以享受多加 2000 筹码的权益
				if card2 > 0 and self.param.Amount then
					local tex = string.format("%s %s",CC.uu.numberToStrWithComma(self.param.Amount-2000),"<color=#44C810FF><size=50>+2000</size></color>")
					self:FindChild("Frame/Award/ChipCount").text = tex
				end
			end
		}
		CC.HallUtil.ReqPlayerPropByIds(data)
	end
end

function BenefitsView:OnClickOk()
	--确定领取
	CC.Request("TakeRelief",nil,function(err,data)
		CC.Player.Inst():SetLeftTimes(CC.Player.Inst():GetLeftTimes()-1);
		CC.ViewManager.ShowTip(self.language.success);
		self:ActionOut();
	end, function()
		CC.ViewManager.ShowTip(self.language.failed);
		self.errTimes = self.errTimes + 1
		if self.errTimes >= 3 then
			self.btnClose:SetActive(true)
		end
	end)
end

function BenefitsView:OnDestroy()
	if self.param.Callback then 
		self.param.Callback();
	end
end

return BenefitsView
