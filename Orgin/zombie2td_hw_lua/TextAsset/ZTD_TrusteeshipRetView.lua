local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TrusteeshipRetView = ZTD.ClassView("ZTD_TrusteeshipRetView")

function TrusteeshipRetView:GlobalNode()
	return GameObject.Find("Main/Canvas/TopUIPanal").transform
end

function TrusteeshipRetView:ctor(pushData, closeCb)
	self._TotalMoney = pushData.TotalMoney;
	self._TotalTime = pushData.TotalTime;
	self._closeCb = closeCb;
	self._Info = {};
	local pushInfo = pushData.Info;
	for _, pinfo in ipairs(pushInfo) do
		self._Info[pinfo.MonsterType] = pinfo.Money;
	end
end

function TrusteeshipRetView:OnCreate()
	self:PlayAnimAndEnter();
	ZTD.Flow.IsTrusteeship = false;
	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_TrusteeshipRetView");
	self._ItemParent = self:FindChild("root/ItemList/Viewport/Content")
    self:Init();
end

function TrusteeshipRetView:EndReqAndClose()

	local succCb = function(err,data)
		ZTD.Flow.IsTrusteeship = false;
		self:PlayAnimAndExit();
		ZTD.Flow.IsOpenTrusteeshipRetView = nil;
		
		if self._closeCb then
			self._closeCb();
		end	
		self:Destroy()
	end

	local errCb = function(err,data)
		--logError("_______TrusteeshipRetView EndTrusteeship Error:"..err)
		succCb();
	end
	
	ZTD.Request.CSEndTrusteeshipReq({Notify = false}, succCb, errCb);	
end

function TrusteeshipRetView:Init()
	local tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self:FindChild("root/Buttons/btn_confirm/txt").text = tipLanguage.txt_btn_confirm

	self:FindChild("root/txt_").text = self.language.txt1
	self:FindChild("root/txt_ (1)").text = self.language.txt2

	self:AddClick("root/Buttons/btn_confirm","EndReqAndClose")
	
	local txt_time = self:SubGet("root/txt_time", "Text");
	txt_time.text = tools.TicketFormat(self._TotalTime);
	
	--如果没有挂机时间，则表示没有勾选时间，隐藏时间表示
	if ZTD.Flow.TrusteeLeftTime == nil then
		-- “总时长”的描述
		local txt_desc = self:SubGet("root/txt_", "Text");
		txt_desc:SetActive(false);
		txt_time:SetActive(false);
	end	
	
	local txt_gold_ret = self:SubGet("root/txt_gold_ret", "Text");
	txt_gold_ret.text = self._TotalMoney;	
	
	if self._TotalMoney < 0 then
		txt_gold_ret.color = Color(74/255, 163/255, 89/255, 255/255)
		self:FindChild("root/img_gold"):SetActive(false);
	else
		txt_gold_ret.text = "+" .. txt_gold_ret.text;
	end	
	

	for etype, emoeny in pairs(self._Info) do
		self:CreateItem(etype, emoeny);
	end
end

function TrusteeshipRetView:CreateItem(etype, emoeny)
    local item = ResMgr.LoadPrefab("prefab","ZTD_TrusteeshipRetItem",self._ItemParent,nil,nil)
    item.name = "TrusteeshipRetItem"..etype;	

	local txt_title = item:FindChild("txt_title");
	local txt_get = item:FindChild("txt_get");

	local cfg = ZTD.MainScene.GetEnemyTypeCfg(etype);
	
	if cfg and cfg.icon then
		item:FindChild("image_type"):GetComponent("Image").sprite = ResMgr.LoadAssetSprite("prefab", cfg.icon);
	else
		-- 不是怪物头像，则从额外索取
		item:FindChild("image_type"):GetComponent("Image").sprite = ResMgr.LoadAssetSprite("prefab", "ZTD_ext_icon_" .. etype);
	end	
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	if(emoeny < 0) then
		txt_get.text = "- " .. -emoeny;
		txt_get.color = Color(74/255, 163/255, 89/255, 255/255)
		txt_title.color = Color(74/255, 163/255, 89/255, 255/255)		
		txt_title.text = language.trusteeLose;
		item:FindChild("img_gold"):SetActive(false);
	else
		txt_get.text = "+ " .. emoeny;
		txt_get.color = Color(255/255, 126/255, 22/255, 255/255)
		txt_title.color = Color(255/255, 126/255, 22/255, 255/255)
		txt_title.text = language.trusteeWin;
	end
end

return TrusteeshipRetView