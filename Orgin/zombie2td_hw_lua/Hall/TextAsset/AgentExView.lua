local CC = require("CC")

local AgentExView = CC.uu.ClassView("AgentExView")
--[[
param
goodsId:商品id
type:商店类型
icon:兑换物品icon
]]

function AgentExView:ctor(param)
    self:InitVar(param)
end

function AgentExView:InitVar(param)
    self.param = param or {}
    self:RegisterEvent()
end

function AgentExView:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_TreasureView");

    self:FindChild("Frame/Mask/InputField/Placeholder").text = self.language.agentEx_Input
    self:FindChild("Frame/Mask/Text").text = self.agentEx_Label
    self:FindChild("Frame/Button/Text").text = self.language.btnOk

    self:AddClick("Mask","ActionOut")
    self:AddClick("Frame/Button","ReqEx")
	
	self:RefreshUI()
end

function AgentExView:RefreshUI()
	local img = ""
	if self.param.icon then
		img = self.param.icon
	else
		if self.param == "100059" or self.param == "100064" then
			img = "prop_img_62"
		elseif self.param == "100065" then
			img = "prop_img_72"
		end
	end
	
	if img ~= "" then
		self:SetImage(self:FindChild("Frame/Mask/DZ/Icon"),img)
		self:FindChild("Frame/Mask/DZ/Icon"):GetComponent("Image"):SetNativeSize()
	end
end

function AgentExView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.GoodsBuyResp,CC.Notifications.NW_ReqGoodsBuy)
end

function AgentExView:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGoodsBuy)
end

function AgentExView:ReqEx()
	local str = self:SubGet("Frame/Mask/InputField/","InputField").text
	if string.len(str) < 10 then
		CC.ViewManager.ShowTip(self.language.phoneNumberTip);
		return;
	end
	local data = {}
	data.GoodsID = tonumber(self.param.goodsId)
	data.Type = self.param.type
	data.ToUserName = str
	CC.Request("ReqGoodsBuy",data)
end

function AgentExView:GoodsBuyResp(err)
    logError("Err:"..err)
    if err == 0 then
        CC.ViewManager.ShowTip(self.language.exSuccess)
        self:ActionOut()
    end
end

return AgentExView