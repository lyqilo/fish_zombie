local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local ZTD_EnemySelectView = ZTD.ClassView("ZTD_EnemySelectView")

function ZTD_EnemySelectView:OnCreate()
	ZTD.Notification.GameRegister(self, ZTD.Define.OnFunctionSwitch, self.OnFunctionSwitch)
	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_EnemySelectView");
	self.tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self:AddClick("bg_back","DoExit")
	self._setInfoList = {};
	self._ItemParent = self:FindChild("root/ItemList/Viewport/Content")
	self.balloonInfo = {}
	self:Init();
end

--收到功能开关推送
function ZTD_EnemySelectView:OnFunctionSwitch(data)
	if not data then return end
	if not data.Info then return end
	for k, v in pairs(data.Info) do
		if v.Id == 1 and self.balloonInfo.balloonObj and tostring(self.balloonInfo.balloonObj) ~= "null" then
			--气球怪开关
			self.balloonInfo.balloonObj:SetActive(v.Open)
			self.balloonInfo.Id = v.Id
			self.balloonInfo.Open = v.Open
		end
	end
end

function ZTD_EnemySelectView:DoExit()
	self:PlayAnimAndExit()
	-- 关闭窗口时发送请求
	self:_sendCfgToServer();		
	-- self:Destroy();	
end	
	
function ZTD_EnemySelectView:_initUi()
	self._setInfoList = {};
	self:InitItemList();
	self:FindChild("root/bg/txt_tips").text = self.tipLanguage.enemy_select_tip;
end	

function ZTD_EnemySelectView:Init()
	self:FindChild("root/Buttons/BTN_SEL_INVERSE/txt (2)").text = self.language.BTN_SEL_INVERSE
	self:FindChild("root/Buttons/BTN_SEL_ALL/txt (3)").text = self.language.BTN_SEL_ALL
	self:FindChild("root/Buttons/BTN_SEL_CANCEL/txt (1)").text = self.language.BTN_SEL_CANCEL
	self:FindChild("root/Buttons/BTN_SEL_COMFIRM/txt (1)").text = self.tipLanguage.txt_btn_confirm

	self:AddClick("root/Buttons/close", "DoExit");
	
	self:AddClick("root/Buttons/BTN_SEL_COMFIRM", "DoExit");
	
	self:AddClick("root/Buttons/BTN_HELP", function()
        ZTD.ViewManager.Open("ZTD_EnemySelectHelpView")
		ZTD.Request.CSButtonRecordsReq({ID = 7001, Mode = 7});
    end)

	self:AddClick("root/Buttons/BTN_SEL_INVERSE", function()
        self:inverseSelect();
    end)

	self:AddClick("root/Buttons/BTN_SEL_ALL", function()
        self:allSelect();
    end)

	self:AddClick("root/Buttons/BTN_SEL_CANCEL", function()
        self:allUnSelect();
    end)	
		
	self:_initUi();
end
	
function ZTD_EnemySelectView:_DestroyAllItem()
	local childCount = self._ItemParent.transform.childCount;
	if childCount > 0 then
		for i=0,childCount-1 do
			tools.destroyObject(self._ItemParent.transform:GetChild(i).gameObject)
		end
	end
end

function ZTD_EnemySelectView:OnDestroy()
	ZTD.Notification.GameUnregisterAll(self)
end	

function ZTD_EnemySelectView:InitItemList()
	-- local selectTable = {};
	-- local jsStr = GC.UserData.Load(ZTD.gamePath.."EnemySelect");
	-- if jsStr then
	-- 	selectTable = Json.decode(jsStr);
	-- end
	local selectTable = GC.UserData.Load(ZTD.gamePath.."EnemySelect");
	local enemyCfgs = ZTD.EnemyConfig;
	for _, v in ipairs(enemyCfgs) do
		local setInfo = {};
		local strId = tostring(v.id);
		if selectTable[strId] == nil then
			setInfo.selectVar = 0;
		elseif selectTable[strId] == true then
			setInfo.selectVar = 1;
		else
			setInfo.selectVar = 0;
		end

		setInfo.id = v.id;
		setInfo.cfg = v;

		local index = #self._setInfoList + 1
		self._setInfoList[index] = setInfo;
		self._setInfoList[index].bindItem = self:CreateItem(index, setInfo);
	end
end

function ZTD_EnemySelectView:_initItemUi(item, info)
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_EnemyConfig");
	item:SetActive(true)
    item:FindChild("img_icon"):GetComponent("Image").sprite = ResMgr.LoadAssetSprite("prefab", info.cfg.icon)
	item:FindChild("img_icon"):SetActive(true);
    item:FindChild("img_icon"):GetComponent("Image"):SetNativeSize()
	--logError("info="..GC.uu.Dump(info))
	item:FindChild("txt_desc_r").text = language[info.id].desc_r;
	
	if info.id == 10005 then
		self.balloonInfo.balloonObj = item
		self:OnFunctionSwitch(ZTD.Flow.SwithData)
	end
	
	item:FindChild("img_select"):SetActive(false);
	item:FindChild("img_mask"):SetActive(false);
	-- 1 被选择
	if (info.selectVar == 1) then
		item:FindChild("img_select"):SetActive(true);
	-- 0 没被选
	elseif (info.selectVar == 0) then
		item:FindChild("img_select"):SetActive(false);
	-- -1 锁定	
	elseif (info.selectVar == -1) then
		item:FindChild("img_mask"):SetActive(true);
		local txt_lock = item:FindChild("img_mask/txt_lock");
		
		local lType = info.cfg.lockCondition[1];
		local lVar = info.cfg.lockCondition[2];
	
		if(lType == 1) then
			txt_lock.text = string.format("%s关解锁", lVar);
		end	
	elseif (info.selectVar == -2) then
		item:FindChild("img_mask"):SetActive(true);
		local txt_lock = item:FindChild("img_mask/txt_lock");
		txt_lock.text = string.format("敬请期待", lVar);	
	end
	
	local btn = item:FindChild("btnSelect");
	self:AddClick(btn, function()
		-- 1 被选择
		if (info.selectVar == 1) then
			item:FindChild("img_select"):SetActive(false);
			info.selectVar = 0;
			
			-- 检测是否全没选
			local isAllUnSelect = true;
			for _, v in ipairs(self._setInfoList) do
				if(v.selectVar == 1) then
					isAllUnSelect = false;
					break;
				end	
			end
		-- 0 没被选
		elseif (info.selectVar == 0) then
			item:FindChild("img_select"):SetActive(true);
			info.selectVar = 1;
		-- -1 锁定	
		elseif (info.selectVar == -1) then
			logWarn(string.format("-------EnemyType:%d is lock!!!", info.TypeEnemy));
		-- -2 锁定	
		elseif (info.selectVar == -2) then
			logWarn(string.format("-------EnemyType:%d is lock!!!", info.TypeEnemy));			
		end
    end)	
end

function ZTD_EnemySelectView:CreateItem(index, info)
    --local item = ResMgr.LoadPrefab("prefab","HighModeSelectItem",self._ItemParent,nil,nil)
	local item = self:FindChild("root/ItemList/Viewport/Content/HighModeSelectItem" .. (index - 1))
	self:_initItemUi(item, info);
	return item;
end

function ZTD_EnemySelectView:allSelect()
	for _, v in ipairs(self._setInfoList) do
		if(v.selectVar >= 0) then
			v.selectVar = 1;
			self:_initItemUi(v.bindItem, v);
		end
	end
end

function ZTD_EnemySelectView:allUnSelect()
	for _, v in ipairs(self._setInfoList) do
		if(v.selectVar >= 0) then
			v.selectVar = 0;
			self:_initItemUi(v.bindItem, v);
		end
	end	
end	

function ZTD_EnemySelectView:inverseSelect()
	for _, v in ipairs(self._setInfoList) do
		if(v.selectVar >= 0) then
			if(v.selectVar == 0) then
				v.selectVar = 1;
			elseif(v.selectVar == 1) then
				v.selectVar = 0;
			end
			self:_initItemUi(v.bindItem, v);
		end
	end
end	

function ZTD_EnemySelectView:_sendCfgToServer()
	local selectTable = {};
	for _, v in ipairs(self._setInfoList) do		
		if(v.selectVar >= 0) then
			local isSelect = (v.selectVar == 1);
			selectTable[tostring(v.id)] = isSelect;
			if isSelect then
				ZTD.Request.CSButtonRecordsReq({ID = v.id, Mode = 7});
			end
		end
	end	
	GC.UserData.Save(ZTD.gamePath.."EnemySelect", selectTable);
	
	ZTD.MainScene.ReadNowTargets();
	
	ZTD.Notification.GamePost(ZTD.Define.MsgCleanHeroLock);
end

return ZTD_EnemySelectView