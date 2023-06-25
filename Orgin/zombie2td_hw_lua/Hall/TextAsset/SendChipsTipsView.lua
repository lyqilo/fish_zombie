
local CC = require("CC")

local SendChipsTipsView = CC.uu.ClassView("SendChipsTipsView")

function SendChipsTipsView:ctor(param)
	self.param = param
end

function SendChipsTipsView:OnCreate()

	self:InitContent();
end

function SendChipsTipsView:InitContent()

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:InitTextByLanguage();
end

function SendChipsTipsView:InitTextByLanguage()

	local language = self:GetLanguage();

	local title = self:FindChild("Frame/Title");
	title.text = language.title;

	local vipText = self:FindChild("Frame/ScrollText/Viewport/Content/vipText/Text")
	vipText.text = language.vipText;

	local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local vipNumText = self:FindChild("Frame/ScrollText/Viewport/Content/vipText/VipIcon/Text")
	vipNumText.text = vip

	local vipleftText = self:FindChild("Frame/ScrollText/Viewport/Content/vipleftText")
	--保底暂时隐藏
	vipleftText:SetActive(false)
	vipleftText.text = string.format(language.vipleftText,self.param.reserved or "0") -- 保底

	local limitText = self:FindChild("Frame/ScrollText/Viewport/Content/limitText")
	local leftText = self:FindChild("Frame/ScrollText/Viewport/Content/leftText")
	if vip >= 14 then
		limitText.text = string.format(language.limitText,language.noneText) -- 上限
		leftText.text = string.format(language.leftText,language.noneText) -- 剩余
	else
		if vip < 3 then
			limitText.text = string.format(language.lifeLimitText,tostring(self.param.limit or 0)) -- 上限
		    leftText.text = string.format(language.lifeLeftText,tostring(self.param.left or 0)) -- 剩余
		else
			limitText.text = string.format(language.limitText,tostring(self.param.limit or 0)) -- 上限
		    leftText.text = string.format(language.leftText,tostring(self.param.left or 0)) -- 剩余
	    end		
	end

	local payTips = self:FindChild("Frame/ScrollText/Viewport/Content/payTips")
	payTips.text = string.format(language.payTips,self.param.payNum or 0) -- 交易数

	local tips = self:FindChild("Frame/ScrollText/Viewport/Content/tips")

	local str = ""
	local thirdParty = {}
	for i,v in ipairs(self.param.payments or {}) do
		--[[
			// 锁定金币相信信息
			message LockMoneyDetail
			{
				required int64 DiamondNum = 1;		 // 钻石数量
				required int64 LockMoney = 2;		 // 被锁金币
				required int64 LeftTime = 3;		 // 剩余时间
				required int64 LeftUnlockMoney = 4;  // 剩余解锁流水
				required int32 OsType = 5;	// 0 表示无效 1 表示Ios 2 表示Mol 3 表示Google 4 表示 ChouMa  5 表示 OPPO 6 表示 Spay 7 表示 Diamond 8 表示 Vivo  
			}
		]]
		local leftTime
		if v.LeftTime and v.LeftTime > 0 then
			leftTime = CC.uu.TicketFormat2(v.LeftTime or 0)
		else
			leftTime = "0"
		end
		if v.OsType then
			if v.OsType == CC.shared_enums_pb.Google then
				str = str..string.format(language.androidTips,v.LockMoney,v.DiamondNum,leftTime).."\n" -- Google交易订单
			elseif v.OsType == CC.shared_enums_pb.Ios then
				str = str..string.format(language.iosTips,v.LockMoney,v.DiamondNum,leftTime).."\n" -- ios交易订单
			elseif v.OsType == CC.shared_enums_pb.Mol 
				or v.OsType == CC.shared_enums_pb.OPPO 
				or v.OsType == CC.shared_enums_pb.Vivo then
				if not thirdParty[v.OsType] then
					thirdParty[v.OsType] = {}
					thirdParty[v.OsType].LockMoney = v.LockMoney
					thirdParty[v.OsType].DiamondNum = v.DiamondNum
					thirdParty[v.OsType].LeftUnlockMoney = v.LeftUnlockMoney
				else
					thirdParty[v.OsType].LockMoney = thirdParty[v.OsType].LockMoney + v.LockMoney
					thirdParty[v.OsType].DiamondNum = thirdParty[v.OsType].DiamondNum + v.DiamondNum
					thirdParty[v.OsType].LeftUnlockMoney = thirdParty[v.OsType].LeftUnlockMoney + v.LeftUnlockMoney
				end
			else
				str = str..string.format(language.OtherTips,v.LockMoney,v.DiamondNum,leftTime,v.LeftUnlockMoney).."\n" -- 其他交易订单
            end
		end
	end
	for k,v in pairs(thirdParty) do
		if k == CC.shared_enums_pb.Mol then
			str = str..string.format(language.MolTips,v.LockMoney,v.DiamondNum,v.LeftUnlockMoney) -- Mol交易订单
		elseif k == CC.shared_enums_pb.OPPO then
			str = str..string.format(language.OPPOTips,v.LockMoney,v.DiamondNum,v.LeftUnlockMoney) -- OPPO交易订单
		elseif k == CC.shared_enums_pb.Vivo then
			str = str..string.format(language.VivoTips,v.LockMoney,v.DiamondNum,v.LeftUnlockMoney) -- Vivo交易订单
		end
		str = str.."\n"
	end
	tips.text = str
	-- tips.text = string.format(language.androidTips,self.param.payNum or 3) -- 交易订单

	local tips_contentSizeFitter = self:SubGet( "Frame/ScrollText/Viewport/Content/tips", "ContentSizeFitter" )
	tips_contentSizeFitter.enabled = true

	local content_contentSizeFitter = self:SubGet( "Frame/ScrollText/Viewport/Content", "ContentSizeFitter" )
	self:DelayRun(0.01,function ()
		content_contentSizeFitter.enabled = true
	end)
	
end

return SendChipsTipsView
