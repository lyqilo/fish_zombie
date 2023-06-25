local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TrusteeshipView = ZTD.ClassView("ZTD_TrusteeshipView")

function TrusteeshipView:ctor(respData)
	local info = respData.Info;
	--玩家设置选择   bool
	self._HighSetOpen = info.HighSetOpen;
	self._LowSetOpen = info.LowSetOpen;
	self._TimeSetOpen = info.TimeSetOpen;	
	--玩家value选择  int
	self._HighSetValue = info.HighSetValue;
	self._LowSetValue = info.LowSetValue;
	self._TimeSetValue = info.TimeSetValue;
	--是否是挂机状态  bool
	self._IsTrusteeship = info.IsTrusteeship;
	
	self._LeftTime = respData.LeftTime;
	self._VIPDays = respData.VIPDays;

	self._gold = ZTD.GoldData.Gold.Sync;

	self.vipLevel = respData.VIPLevel;

	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_TrusteeshipView");
	self.tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
end	

function TrusteeshipView:ScMoneyChange(data)
	--TrusteeshipView.inst:UpdateGoldUi(data.Money);
end

function TrusteeshipView:OnCreate()
	self:PlayAnimAndEnter();
    self:Init();
	TrusteeshipView.inst = self;	
	ZTD.Notification.GameRegister(self, ZTD.Define.OnPushTrusteeshipBtn, self.RefreshBtnByVip)
	ZTD.Notification.NetworkRegister(self, "SCSyncMoney", self.ScMoneyChange);
end

function TrusteeshipView:OnDestroy()
	TrusteeshipView.inst = nil;	
	ZTD.Notification.NetworkUnregister(self, "SCSyncMoney");
	ZTD.Notification.GameUnregisterAll(self)
end	

function TrusteeshipView:PlayAnimAndExitT()
	self:PlayAnimAndExit();
end

--刷新按钮
function TrusteeshipView:RefreshBtnByVip(vipLevel)
	self.vipLevel = vipLevel
	local confirmText = nil
	if self.vipLevel < 2 then
		confirmText = "VIP>=2"
	else
		confirmText = self.language.btn_confirm
	end
	self:FindChild("Buttons/btn_confirm/txt").text = confirmText
end

function TrusteeshipView:Init()
	self:RefreshBtnByVip(self.vipLevel)
	self:FindChild("Buttons/btn_cancel/txt").text = self.language.btn_cancel
	self:FindChild("ITEM_MAX/toggle/Background/Label (1)").text = self.language.txt1
	self:FindChild("ITEM_MAX/toggle/Background/Checkmark/Label").text = self.language.txt1
	self:FindChild("ITEM_MAX/top_desc/Label (2)").text = self.language.txt2
	self:FindChild("ITEM_MAX/top_desc/Label (1)").text = self.language.txt3
	self:FindChild("ITEM_MIN/top_desc/Label (2)").text = self.language.txt5
	self:FindChild("ITEM_MIN/top_desc/Label (1)").text = self.language.txt3
	self:FindChild("ITEM_MIN/toggle/Background/Label (1)").text = self.language.txt4
	self:FindChild("ITEM_MIN/toggle/Background/Checkmark/Label").text = self.language.txt4
	self:FindChild("ITEM_TIME/top_desc/Label (2)").text = self.language.txt7
	self:FindChild("ITEM_TIME/top_desc/Label (1)").text = self.language.txt3
	self:FindChild("ITEM_TIME/toggle/Background/Label (1)").text = self.language.txt6
	self:FindChild("ITEM_TIME/toggle/Background/Checkmark/Label").text = self.language.txt6
	self:FindChild("top/img_vip/text_desc").text = self.language.text_desc

	self:AddClick("Buttons/close","PlayAnimAndExitT")
	self:AddClick("back_mask","PlayAnimAndExitT")
	
	local txt_vip = self:FindChild("top/img_vip/text");
	txt_vip.text = self._VIPDays;
    
	local btn_confirm = self:FindChild("Buttons/btn_confirm");
	self:AddClick(btn_confirm, function()
		if self.vipLevel < 2 then
			local sortingOrder = self.transform:GetComponent("Canvas").sortingOrder + 2
			ZTD.LockPop.OpenLockPopView(self.tipLanguage.txt_v2Pop, function()
				local param = {}
				param.currentView = "VipThreeCardView"
				GC.SubGameInterface.OpenGiftSelectionView(param)
			end, sortingOrder)
		else
			self:OnConfirm();
		end
    end )
	btn_confirm:SetActive(not self._IsTrusteeship);
	
	local btn_cancel = self:FindChild("Buttons/btn_cancel");
    self:AddClick(btn_cancel, function()
        self:OnCancel();
    end )
	btn_cancel:SetActive(self._IsTrusteeship);
	
	self:AddClick("top/img_vip/btn_add",function()
		local playerId = ZTD.PlayerData.GetPlayerId();
		local param = {
			ChouMa = ZTD.TableData.GetData(playerId, "Money"),
			Integral = GC.SubGameInterface.GetHallIntegral(),
		}
		GC.SubGameInterface.ExOpenShop(param)
		ZTD.Request.CSButtonRecordsReq({ID = 6001, Mode = 6});
    end)		
	
	local cfg = ZTD.TrusteeshipConfig[1];

	local function calcTime(txtDesc, slValue)
		txtDesc.text = string.format(self.tipLanguage.view_trust_tip1, slValue);
	end	
	local function floorTime(value)
		local intV = math.floor(value);
		if value - intV >= 0.5 then
			return intV + 0.5;
		else
			return intV;
		end
	end		
	self:_initItem("ITEM_TIME", cfg.timeMaxRate, cfg.timeMinRate, self.tipLanguage.view_trust_tip1, 0.5, "_TimeSetValue", "_TimeSetOpen", calcTime, floorTime);
	-- self:_initItem("ITEM_TIME", cfg.timeMaxRate, cfg.timeMinRate, "%s%%", 0.5, "_TimeSetValue", "_TimeSetOpen", calcTime, floorTime);
	
	
	self:AddClick("Buttons/btn_help", function()
		local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TrusteeshipConfig");
        ZTD.ViewManager.Open("ZTD_TrusteeshipHelpView", language.helpDesc);
    end)
	
	self:UpdateGoldUi();
end
--                                 节点key    高低倍率         字符显示标准     用来修复floor前后的间值大小         set，On             
function TrusteeshipView:_initItem(itemNode, maxRate, minRate, strFormat,            fixGap,                    setValue, onValue, calcValueFunc, floorFunc)
	if self[setValue] < minRate then
		self[setValue] = minRate;
	end
	
	if self[setValue] > maxRate then
		self[setValue] = maxRate;
	end		

	local slider = self:SubGet(itemNode .. "/slider", "Slider");
	local txtRate = self:SubGet(itemNode .. "/txt_rate", "Text");
	UIEvent.AddSliderOnValueChange(slider.transform, function (v)
		ZTD.PlayMusicEffect("ZTD_rate_touch")
		--to do self._sliderTime.value;	
		self[setValue] = minRate + slider.value * (maxRate - minRate);
		

		local fixValue = floorFunc(self[setValue]);
		
		if(self[setValue] - fixValue >= fixGap * 0.5)then
			self[setValue] = fixValue + fixGap;
		else
			self[setValue] = fixValue;
		end
			
		txtRate.text = string.format(strFormat, self[setValue]);
		
		local txt_limit = self:FindChild(itemNode .. "/top_desc/txt_limit");
		calcValueFunc(txt_limit, self[setValue]);
	end)
	slider.value = (self[setValue] - minRate)/(maxRate - minRate)
	txtRate.text = string.format(strFormat, self[setValue]);

	local txt_limit = self:FindChild(itemNode .. "/top_desc/txt_limit");
	calcValueFunc(txt_limit, self[setValue]);
	
	local toggle = self:SubGet(itemNode .. "/toggle", "Toggle")
	UIEvent.AddToggleValueChange(toggle.transform, function(v)
		-- todo self._toggleTime.isOn
		self[onValue] = toggle.isOn;
		local checkmark = self:FindChild(itemNode .. "/toggle/Background/Checkmark");
		checkmark:SetActive(toggle.isOn);
		if v == true then
			ZTD.PlayMusicEffect("ZTD_trustOn")
		end
	end)	
	toggle.isOn = self[onValue];	

	local btnLeft = self:FindChild(itemNode .. "/btn_left");	
	self:AddClick(btnLeft, function()
		local checkGap = fixGap/(maxRate - minRate)

		if slider.value - checkGap <= 0 then
			slider.value = 0;
		else
			slider.value = slider.value - checkGap;
		end			
	end)

	local btnRight = self:FindChild(itemNode .. "/btn_right");	
	self:AddClick(btnRight, function()
		local checkGap = fixGap/(maxRate - minRate)
		if slider.value + checkGap >= 1 then
			slider.value = 1;
		else
			slider.value = slider.value + checkGap;
		end
	end)
	
	local btnMask = self:FindChild(itemNode .. "/btn_mask");
	self:AddClick(btnMask, function()
		 ZTD.ViewManager.ShowTip(self.tipLanguage.trusteeMask)
	end)		

	btnMask:SetActive(self._IsTrusteeship);
end
	

function TrusteeshipView:UpdateGoldUi(gold)
	self._gold = gold or ZTD.GoldData.Gold.Sync;
	
	local txt_gold = self:FindChild("top/img_gold/text");
	txt_gold.text = self._gold;
	
	local cfg = ZTD.TrusteeshipConfig[1];
	
	-- 如果在挂机中，锁定上一次的挂机金钱
	local setGold = self._gold;
	if self._IsTrusteeship and TrusteeshipView.LastGold then
		setGold = TrusteeshipView.LastGold;
	end
	
	local function calcMax(txtDesc, slValue)
		local scmoney = math.floor(setGold * (slValue/100));
		txtDesc.text = tools.NumberFormat(scmoney);
	end
	local function floorMax(value)
		return math.floor(value);
	end
	self:_initItem("ITEM_MAX", cfg.highMaxRate, cfg.highMinRate, "%s%%", 1, "_HighSetValue", "_HighSetOpen", calcMax, floorMax);
	
	local function calcMin(txtDesc, slValue)
		local scmoney = math.floor(setGold * (slValue/100));
		txtDesc.text = tools.NumberFormat(scmoney);
	end	
	local function floorMin(value)
		return math.floor(value);
	end	
	self:_initItem("ITEM_MIN", cfg.lowMaxRate, cfg.lowMinRate, "%s%%", 1, "_LowSetValue", "_LowSetOpen", calcMin, floorMin);	
end

function TrusteeshipView:OnConfirm()
	local playerId = ZTD.PlayerData.GetPlayerId();
	local heroinfo = ZTD.TableData.GetData(playerId, "heroInfo");
	if next(heroinfo) == nil then
		ZTD.ViewManager.ShowTip(self.tipLanguage.trusteeProtectTip2);
	elseif self._HighSetOpen or self._LowSetOpen or self._TimeSetOpen then
		local maxStr = self:FindChild("ITEM_MAX/top_desc/txt_limit").text;
		local minStr = self:FindChild("ITEM_MIN/top_desc/txt_limit").text;
		local timeStr = self:FindChild("ITEM_TIME/top_desc/txt_limit").text;
		ZTD.ViewManager.Open("ZTD_TrusteeshipConfirmView", self, maxStr, minStr, timeStr)
		
		TrusteeshipView.LastGold = self._gold;
	else
		ZTD.ViewManager.ShowTip(self.tipLanguage.trusteeProtectTip)
	end
end

function TrusteeshipView:OnCancel()
	local succCb = function(err,data)
		ZTD.Flow.IsTrusteeship = false;
		self:Destroy();
	end

	local errCb = function(err,data)
		succCb();
		logError("_______EndTrusteeship Error:"..err)
	end
	
	ZTD.Request.CSEndTrusteeshipReq({Notify = true}, succCb, errCb);
end

return TrusteeshipView