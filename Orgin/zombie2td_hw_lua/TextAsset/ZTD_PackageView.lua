local CC = require("CC")
local GC = require("GC")
local ZTD = require("ZTD")

--封包配置，根据proto的填写，当前封包工具仅支持一层的符合结构
local PackageConfig = {
	{
		name = "CSLogoutGame",
		comment = "退出包",
	},
	{
		name = "CSRequestAttack",
		comment = "攻击包",
		normalParam = {
			[1] = {
				name = "Ratio",
				comment = "倍率",
				type = "int",
				value = 1,
			},
			[2] = {
				name = "Mode",
				comment = "模式",
				type = "int",
				value = 2,
			},
			[3] = {
				name = "MonsterId",
				comment = "怪物配置id",
				type = "int",
				value = 0,
			},
			[4] = {
				name = "PositionId",
				comment = "怪物位置id",
				type = "int",
				value = 0,
			},		
		},
	},

	{
		name = "CSTowerUpdateHero",
		comment = "更新英雄位置",
		compositeParam = {
			[1] = {
				name = "Info",
				comment = "英雄的信息：\n英雄的配置id\n英雄的位置id\n是否开启自动攻击 ",
				type = "TowerHeroInfo",
				param = {
					[1] = {
						name = "HeroId",
						type = "int",
						value = 0,
					},
					[2] = {
						name = "PositionId",
						type = "int",
						value = 0,
					},
					[3] = {
						name = "IsAtk",
						type = "bool",
						value = false,
					},
				}
			},
		},
		
		normalParam = {
			[1] = {
				name = "Leave",
				comment = "true:下阵  false:上阵",
				type = "bool",
				value = true,
			},		
		},
	},
	

	{
		name = "CSChangeBackground",
		comment = "切后台包",
		normalParam = {
			[1] = {
				name = "IsBack",
				comment = "true切后台,false切前台",
				type = "bool",
				value = false,
			},
		},	
	},
	
	{
		name = "CSTowerMonsterExit",
		comment = "怪物退场",
		normalParam = {
			[1] = {
				name = "PositionId",
				comment = "走出屏幕的怪物位置id",
				type = "int",
				value = 0,
			},
		},	
	},	
	
	{
		name = "CSTowerExchangeHero",
		comment = "英雄上场",
		normalParam = {
			[1] = {
				name = "NewPositionId",
				comment = "新的英雄的位置 ",
				type = "int",
				value = 0,
			},
			[2] = {
				name = "OldPositionId",
				comment = "旧的英雄的位置 ",
				type = "int",
				value = 0,
			},			
		},	
	},	

	{
		name = "CSDragonRelease",
		comment = "请求巨龙",
		normalParam = {
			[1] = {
				name = "Ratio",
				comment = "点击释放巨龙之怒时的倍率",
				type = "int",
				value = 0,
			},
		},	
	},

	{
		name = "CSGetDragonProps",
		comment = "获取巨龙道具",
	},

	{
		name = "CSEquipDragonProps",
		comment = "装备巨龙道具",
		normalParam = {
			[1] = {
				name = "PropsID",
				comment = "道具id",
				type = "int",
				value = 0,
			},
		},	
	},

	{
		name = "CSOneKeyUpdateHero",
		comment = "请求一键部署（选择的英雄已从英雄列表中自动获取）",
	},	
}

local View  = ZTD.ClassView("ZTD_PackageView")

function View:OnCreate()
	-- self.dropDown = self:FindChild("Dropdown"):GetComponent("Dropdown");

	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_PackageView");
	self:FindChild("Title").text = self.language.Title
	self:FindChild("SendBtn/Text").text = self.language.SendBtn
	self:FindChild("Dropdown/Label").text = self.language.Dropdown
	self:FindChild("Data/ParamType1").text = self.language.ParamType1
	self:FindChild("Data/ParamType2").text = self.language.ParamType2
	self:FindChild("ShowEnemyUid/Label").text = self.language.ShowEnemyUid
	self:FindChild("GameSpeed/T").text = self.language.GameSpeed
	self:FindChild("BtnClose/Text").text = self.language.BtnClose

	self.isShow = true;
	self:InitPackageIndex();
	self.curIndex = nil;
	self:Choose(self.curIndex);

	self:AddClick(self:FindChild("SendBtn"),function()
		self:SendPackage();
	end)

	self:AddClick(self:FindChild("BtnClose"),function()
		self:Destroy();
	end)	
	

	self.showEnemyUid = true;
	self.enemyUidLayer = self:FindChild("EnemyUidLayer")
	self.uidList = {};
	UIEvent.AddToggleValueChange(self:FindChild("ShowEnemyUid"),function (v)
		self.showEnemyUid = v;
	end)

	self._co_timer = ZTD.GlobalTimer.StartTimer( function()
		self:Update();
	end, 0, -1)			

	self:FindChild("GameSpeed"):GetComponent("Slider").value = Time.timeScale;
	UIEvent.AddSliderOnValueChange(self:FindChild("GameSpeed"), function (v)
        Time.timeScale = v;
    end)
end

function View:Update()
	if self.showEnemyUid then
		local enemyMgr = ZTD.Flow.GetEnemyMgr();
		local enemyList = enemyMgr._ctrlList; 
		for i,v in pairs(enemyList) do 
			if not self.uidList[i] then
				self.uidList[i] = ZTD.Extend.LoadPrefab("ZTD_PackageUid",self.enemyUidLayer);
				self.uidList[i]:SetText(i);
			end
			
			local wPos = v:GetObjPos();
			if wPos then
				self.uidList[i].position = ZTD.MainScene.SetupPos2UiPos(wPos);
			end	
		end

		for i,v in pairs(self.uidList) do 
			if not enemyList[i] then
				ZTD.Extend.Destroy(v.gameObject);
				self.uidList[i] = nil;
			end
		end
	else
		for i,v in pairs(self.uidList) do
			ZTD.Extend.Destroy(v.gameObject);
		end
		self.uidList = {};
	end
end

function View:InitPackageIndex()
	self.packageIndexContent = self:FindChild("Dropdown/Items/Viewport/Content");
	for i,v in ipairs(PackageConfig) do 
		local item =  ZTD.Extend.LoadPrefab("ZTD_PackageItem1",self.packageIndexContent,i);
		item:FindChild("Tick"):SetActive(false);
		item:FindChild("Text"):SetText(v.comment.."\n"..v.name);
		self:AddClick(item,function()
			self:Choose(i);
		end)
	end
end

function View:Choose(index)
	local noram = self:FindChild("Data/Normal/Viewport/Content");
	local composite = self:FindChild("Data/Composite/Viewport/Content");
	noram:SetActive(false);
	composite:SetActive(false);
	if not index then 
		return
	end

	if self.curIndex and self.curIndex ~= index then 
		self.packageIndexContent:FindChild(self.curIndex):FindChild("Tick"):SetActive(false);
	end
	
	self.curIndex = index;
	self.packageIndexContent:FindChild(self.curIndex):FindChild("Tick"):SetActive(true);

	ZTD.Extend.DestroyAllChildren(noram);
	local config = PackageConfig[self.curIndex];
	if config.normalParam and #config.normalParam > 0 then 
		noram:SetActive(true);
		for i,v in ipairs(config.normalParam) do
			local item = ZTD.Extend.LoadPrefab("ZTD_PackageItem2",noram,i);
			item:SetActive(true);
			item:FindChild("Name"):SetText("名字:"..v.name);
			item:FindChild("Comment"):SetText("注释:"..v.comment);
			item:FindChild("Type"):SetText("类型:"..v.type);
			item:FindChild("InputField").text = tostring(v.value);
			UIEvent.AddInputFieldOnValueChange(item:FindChild("InputField"), function(value)
				if v.type == "int" then 
					v.value = tonumber(value);
				elseif v.type == "bool" then 
					v.value = value == "true" and true or false;
				else
					v.value = value;
				end	
			end)
		end
	end

	ZTD.Extend.DestroyAllChildren(composite);
	if config.compositeParam and #config.compositeParam > 0 then 
		composite:SetActive(true);
		for i,v in ipairs(config.compositeParam) do
			local item = ZTD.Extend.LoadPrefab("ZTD_PackageItem3",composite,i);
			item:SetActive(true);
			item:FindChild("Name"):SetText("名字:"..v.name);
			item:FindChild("Comment"):SetText("注释:"..v.comment);
			item:FindChild("Type"):SetText("类型:"..v.type);

			local paramList = item:FindChild("ParamList/Viewport/Content");
			for k = 1,10,1 do 
				local item = paramList:FindChild(k);
				local param = config.compositeParam[i].param[k];
				if param then 
					item:SetActive(true);
					item:FindChild("Name"):SetText(param.name);
					item:FindChild("InputField").text = tostring(param.value);
					UIEvent.AddInputFieldOnValueChange(item:FindChild("InputField"), function( value )
						if param.type == "int" then 
							param.value = tonumber(value);
						elseif param.type == "bool" then 
							param.value = value == "true" and true or false;
						else
							param.value = value;	
						end	
					end)
				else
					item:SetActive(false);
				end
			end
		end
	end
end

function View:SendPackage()
	if not self.curIndex then return end
	local config = PackageConfig[self.curIndex];

	local req = ZTD.NetworkHelper.MakeMessage(config.name)
	if config.normalParam then 
		for _,v in ipairs(config.normalParam) do 	
			req[v.name] = v.value;
		end
	end

	if config.compositeParam then 
		for _,v in ipairs(config.compositeParam) do 
			for _,k in ipairs(v.param) do 
				req[v.name][k.name] = k.value;
			end
		end
	end
	logError("发包数据测试"..config.name)
	
    
	local function reqCb(err, data)
		logError("回包数据测试"..config.name..":"..tostring(data) .. ",err:" .. err);
	end
	ZTD.NetworkManager.Request(config.name, req, reqCb, reqCb);
end

function View:ChangeShowState()
	self.isShow = not self.isShow;
	self:SetActive(self.isShow);
	if not self.isShow then 
		ZTD.Notification.UnregisterAll(self);
	end
end

function View:OnDestroy()
	ZTD.Notification.UnregisterAll(self);
	ZTD.GlobalTimer.StopTimer(self._co_timer);	
end

return View;