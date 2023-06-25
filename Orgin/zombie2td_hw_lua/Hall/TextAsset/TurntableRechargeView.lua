
---------------------------------
-- region TurntableRechargeView.lua    -
-- Date: 2019.8.15        -
-- Desc: 充值VIP礼包界面  -
-- Author: Bin        -
---------------------------------

local CC = require("CC")

local TurntableRechargeView = CC.uu.ClassView("TurntableRechargeView")

--[[
@param
cancelCallback: 取消点击回调
]]

function TurntableRechargeView:ctor(param)

	self:InitVar(param);
end

function TurntableRechargeView:InitVar(param)

	self.param = param;

	self.configData = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").VIPGiftCfg;

	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware");
end

function TurntableRechargeView:OnCreate()

	self:InitContent();

	self:InitTextByLanguage();

	self:RegisterEvent();
end

function TurntableRechargeView:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.ActionOut,CC.Notifications.NoviceReward);
end

function TurntableRechargeView:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NoviceReward);
end

function TurntableRechargeView:InitContent()

	-- local image = CC.Platform.isIOS and "VIPGiftBoxIOS" or "VIPGiftBox";

	-- self:SetImage(self:FindChild("Panel/Image"), image);

	for _,v in ipairs(self.configData) do

		self:InitItem(v);
	end

	local node = self:FindChild("Panel/DetalObj");

	self:AddClick(node, function()

			node:SetActive(false);
		end);

	self:AddClick("Panel/BtnCancel", "OnClickCancel");

	self:AddClick("Panel/BtnBuy", "OnClickBuy");
end

function TurntableRechargeView:InitTextByLanguage()

	local language = CC.LanguageManager.GetLanguage("L_DailyTurntableView");

	self:FindChild("Panel/BtnCancel/Text").text = language.btnCancel;

	self:FindChild("Panel/BtnBuy/Text").text = language.btnOk;
end

function TurntableRechargeView:InitItem(data)

	local node = self:FindChild("Panel/ItemParent/"..data.Id);

	self:SetImage(node:FindChild("img"), data.img);

	local showCount = data.count > 0;

	if showCount then
		node:FindChild("Text"):SetActive(showCount);
		node:FindChild("x"):SetActive(showCount);
		node:FindChild("Text").text = data.count;
		node:FindChild("x").text = "X";
	end

	self:AddClick(node, function()

			self:ShowDeltaObj(data);
		end);
end

function TurntableRechargeView:ShowDeltaObj(data)

	local node = self:FindChild("Panel/DetalObj");
	node:SetActive(true);

	self:SetImage(node:FindChild("DetalImg"), data.img);

	local language = CC.LanguageManager.GetLanguage("L_NoviceGiftView");
	node:FindChild("DetalText").text = language[data.Detal];
	node:FindChild("DetalName").text = language[data.Name];
end

function TurntableRechargeView:OnClickCancel()

	if self.param.cancelCallback then
		self.param.cancelCallback();
	end

	self:ActionOut();
end

function TurntableRechargeView:OnClickBuy()

	local wareId = CC.PaymentManager.GetActiveWareIdByKey("vip")
	local wareCfg = self.wareCfg[wareId]
	local param = {}
	param.wareId = wareCfg.Id
	param.subChannel = wareCfg.SubChannel
	param.price = wareCfg.Price
	param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.extraData = "DailySpinBuy"

	CC.PaymentManager.RequestPay(param)
end


function TurntableRechargeView:OnDestroy()

	self:UnRegisterEvent();
end

return TurntableRechargeView;
