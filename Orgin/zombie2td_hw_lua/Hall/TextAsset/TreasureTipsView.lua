
local CC = require("CC")
--筹码锁定Tips
local TreasureTipsView = CC.uu.ClassView("TreasureTipsView")

function TreasureTipsView:ctor(param)
	self.param = {}
	self.Currency = param
end

function TreasureTipsView:OnCreate()
    self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")
    self:InitData()
end

function TreasureTipsView:InitData()
    if self.realDataMgr.GetTradeInfo() then
        self.param = self.realDataMgr.GetTradeInfo()
        self:InitContent();
    else
    	CC.Request("ReqTradeInfo",nil,function(err,data)
            if err == 0 then
                self.param.Locked = data.Locked
                self.param.payments = data.arrLockList
                self.param.payNum = #self.param.payments
                self:InitContent();
            end
        end,
        function(err,data)
            self:Destroy()
        end)
       
    end
end

function TreasureTipsView:InitContent()

	self:AddClick("Frame/BtnClose", "ActionOut");

	self:InitTextByLanguage();
end

function TreasureTipsView:InitTextByLanguage()
	local language = CC.LanguageManager.GetLanguage("L_SendChipsTipsView");

	local title = self:FindChild("Frame/Title");
	local leftText = self:FindChild("Frame/ScrollText/Viewport/Content/leftText")
	local payTips = self:FindChild("Frame/ScrollText/Viewport/Content/payTips")
	local tips = self:FindChild("Frame/ScrollText/Viewport/Content/tips")
    if self.Currency == CC.shared_enums_pb.EPC_PointCard_Fragment then
        title.text = language.treasure_cfTitle;
        local cardFragmentNum = CC.Player.Inst():GetSelfInfoByKey("EPC_PointCard_Fragment")
        if cardFragmentNum > 0 then
            leftText.text = string.format(language.treasure_cfLeftText,tostring(cardFragmentNum)) -- 剩余
        else
            leftText.text = string.format(language.treasure_cfLeftText,tostring(0))
        end
        payTips.text = ""
        tips.text = ""
        local tips_contentSizeFitter = self:SubGet( "Frame/ScrollText/Viewport/Content/tips", "ContentSizeFitter" )
	    tips_contentSizeFitter.enabled = true

	    local content_contentSizeFitter = self:SubGet( "Frame/ScrollText/Viewport/Content", "ContentSizeFitter" )
	    self:DelayRun(0.01,function ()
		    content_contentSizeFitter.enabled = true
	    end)
        return
    else
	    title.text = language.treasure_title;
	    local chip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") - self.param.Locked
        if chip > 0 then
            leftText.text = string.format(language.treasure_leftText,tostring(chip)) -- 剩余
        else
            leftText.text = string.format(language.treasure_leftText,tostring(0))
        end
	end
      	
	payTips.text = string.format(language.payTips,self.param.payNum or 0) -- 交易数	
	local str = ""
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
				str = str..string.format(language.androidTips,v.LockMoney,v.DiamondNum,leftTime,v.LeftUnlockMoney) -- Google交易订单
			elseif v.OsType == CC.shared_enums_pb.Ios then
				str = str..string.format(language.iosTips,v.LockMoney,v.DiamondNum,leftTime,v.LeftUnlockMoney) -- ios交易订单
			elseif v.OsType == CC.shared_enums_pb.Mol then
				str = str..string.format(language.MolTips,v.LockMoney,v.DiamondNum,leftTime,v.LeftUnlockMoney) -- Mol交易订单
			elseif v.OsType == CC.shared_enums_pb.OPPO then
				str = str..string.format(language.OPPOTips,v.LockMoney,v.DiamondNum,leftTime,v.LeftUnlockMoney) -- OPPO交易订单
			elseif v.OsType == CC.shared_enums_pb.Vivo then
				str = str..string.format(language.VivoTips,v.LockMoney,v.DiamondNum,leftTime,v.LeftUnlockMoney) -- Vivo交易订单
			else
				str = str..string.format(language.OtherTips,v.LockMoney,v.DiamondNum,leftTime,v.LeftUnlockMoney) -- 其他交易订单
            end
			str = str.."\n"
		end
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

return TreasureTipsView
