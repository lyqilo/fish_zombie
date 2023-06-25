local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TrusteeshipConfirmView = ZTD.ClassView("ZTD_TrusteeshipConfirmView")

function TrusteeshipConfirmView:ctor(parentView, maxStr, minStr, timeStr)
	self._parentView = parentView;
	self._maxStr = maxStr;
	self._minStr = minStr; 
	self._timeStr = timeStr;
end

function TrusteeshipConfirmView:OnCreate()
	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_TrusteeshipConfirmView");
	self:PlayAnimAndEnter();
    self:Init();
end

function TrusteeshipConfirmView:Init()
	local tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self:FindChild("root/Buttons/btn_confirm/txt").text = tipLanguage.txt_btn_confirm
	self:FindChild("root/Buttons/btn_cancel/txt").text = tipLanguage.txt_btn_cancle
	
	self:FindChild("root/item_max/item_on/txt_").text = self.language.txt1
	self:FindChild("root/item_max/item_on/txt_2").text = self.language.txt2
	self:FindChild("root/item_max/item_off/txt").text = self.language.txt3
	self:FindChild("root/item_min/item_on/txt_").text = self.language.txt4
	self:FindChild("root/item_min/item_on/txt_2").text = self.language.txt2
	self:FindChild("root/item_min/item_off/txt").text = self.language.txt5
	self:FindChild("root/item_time/item_on/txt_").text = self.language.txt6
	self:FindChild("root/item_time/item_on/txt_2").text = self.language.txt2
	self:FindChild("root/item_time/item_off/txt").text = self.language.txt5
	self:FindChild("root/txt_gold_ret").text = self.language.txt_gold_ret

	self:AddClick("root/Buttons/btn_cancel","PlayAnimAndExit")
	local btn_confirm = self:FindChild("root/Buttons/btn_confirm");
	self:AddClick(btn_confirm, function()
        self:OnConfirm();
    end)
	
	local function _initItem(item, onValue, txtValueStr, txtOffStr)
		local itemOn = self:FindChild(item .. "/item_on");
		local itemOff = self:FindChild(item .. "/item_off");
		local txtValue = self:FindChild(item .. "/item_on/txt_value");
		if self._parentView[onValue] then
			itemOn:SetActive(true);
			itemOff:SetActive(false);
			txtValue.text = txtValueStr;
		else
			itemOn:SetActive(false);
			itemOff:SetActive(true);
			local txtOffValue = self:FindChild(item .. "/item_off/txt");
			
			--local lp = txtOffValue.transform.localPosition;
			txtOffValue.transform.localPosition = Vector3(-17, 0, 0);
			txtOffValue.transform.width = 222;
			txtOffValue.text = txtOffStr;
		end
	end
	local tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	_initItem("root/item_max", "_HighSetOpen", self._maxStr, tipLanguage.txt_trust_tip1);
	_initItem("root/item_min", "_LowSetOpen", self._minStr, tipLanguage.txt_trust_tip2);
	_initItem("root/item_time", "_TimeSetOpen", self._timeStr, tipLanguage.txt_trust_tip3);
end

function TrusteeshipConfirmView:OnConfirm()
	local param = {};
	
    local succCb = function(err,data)
		-- todo
		--ZTD.ZombieFlow.AutoBattle = true;
		ZTD.Flow.IsTrusteeship = true;
		
		if param.HighSetOpen then
			ZTD.Flow.TrusteeLimitHighSet = tonumber(self._maxStr);
		else
			ZTD.Flow.TrusteeLimitHighSet = nil;
		end	
		
		if param.LowSetOpen then
			ZTD.Flow.TrusteeLimitLowSet = tonumber(self._minStr);
		else
			ZTD.Flow.TrusteeLimitLowSet = nil;
		end

		
		if (param.TimeSetOpen) then
			ZTD.Flow.TrusteeLeftTime = param.TimeSetValue * 60 * 60;
		else
			ZTD.Flow.TrusteeLeftTime = nil;
		end
		
		
		ZTD.Notification.GamePost(ZTD.Define.MsgTrustOn);
		
		local pv = self._parentView;
		self:PlayAnimAndExit();
		pv:PlayAnimAndExit();
    end

    local errCb = function(err,data)
        logError("_______CSSetTrusteeshipReq Error:"..err)
    end
	
	param.IsTrusteeship = true;
	param.HighSetValue = self._parentView._HighSetValue;
	param.HighSetOpen = self._parentView._HighSetOpen;
	param.LowSetValue = self._parentView._LowSetValue;
	param.LowSetOpen = self._parentView._LowSetOpen;
	param.TimeSetValue = self._parentView._TimeSetValue;
	param.TimeSetOpen = self._parentView._TimeSetOpen;
	-- log("param.HighSetValue:"..param.HighSetValue)
	-- log("param.LowSetValue:"..param.LowSetValue)
	-- log("param.TimeSetValue:"..param.TimeSetValue)

	if param.HighSetOpen then
		ZTD.Request.CSButtonRecordsReq({ID = 6004, Mode = 6});
	end
	if param.LowSetOpen then	
		ZTD.Request.CSButtonRecordsReq({ID = 6003, Mode = 6});
	end	
	if param.TimeSetOpen then
		ZTD.Request.CSButtonRecordsReq({ID = 6002, Mode = 6});
	end
	local tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	local playerId = ZTD.PlayerData.GetPlayerId();
	local heroinfo = ZTD.TableData.GetData(playerId, "heroInfo");
	if next(heroinfo) == nil then
		ZTD.ViewManager.ShowTip(tipLanguage.trusteeProtectTip2);
	else
		ZTD.Request.CSSetTrusteeshipReq(param, succCb, errCb);
	end	
end

return TrusteeshipConfirmView