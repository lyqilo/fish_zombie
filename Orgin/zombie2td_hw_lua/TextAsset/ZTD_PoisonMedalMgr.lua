local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu
--特殊转盘，只用于毒爆
local PoisonMedal = GC.class2("ZTD_PoisonMedal", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase

--转盘的级别
local levelConfig = {
    low  = 30,--0-30
    mid  = 60,--30-45
    high = 90-->45
}

local Prefab = "TD_BombZhuanPan"
function PoisonMedal:Init(coinPos, monsterType, ratio, f_id, n_id, masterId)
	SUPER.Init(self);
	
	local mapPos = ZTD.MainScene.GetMapObj().position;
	local x, y, i, j = ZTD.MainScene.PanGirdData:GetFreeGrid(coinPos.x - mapPos.x, coinPos.y - mapPos.y);
	if x and y then
		coinPos = Vector3(mapPos.x + x, mapPos.y + y, coinPos.z);
		self.gridPos = {i = i, j = j};
		ZTD.MainScene.PanGirdData:WriteGridByInx(i, j, true);
	end	
	
    self.uiEffectParent = ZTD.BattleView.inst.coinEffect
    self.effectPos = ZTD.MainScene.SetupPos2UiPos(coinPos)
	self.masterId = masterId;
	self._masterType = monsterType;
	self.ratio = ratio;
    self.isRelease = false

    self.effect = ZTD.PoolManager.GetUiItem(Prefab, self.uiEffectParent);
    self.effect.position = Vector3(self.effectPos.x, self.effectPos.y, 0);
	self.effect:SetActive(false);
	
	self.effect:FindChild("img_r"):SetActive(false);
	self.effect:FindChild("img_s"):SetActive(false);
	self.effect:FindChild("img_ss"):SetActive(false);	
	self.effect:FindChild("node_zd"):SetActive(false);	
	
    --修改爆点为中心位置而不是脚部位置
    local rect = self.effect:GetComponent("RectTransform")
    rect.anchoredPosition = Vector2(rect.anchoredPosition.x + 17.5, rect.anchoredPosition.y + 65)

    self.effect.localScale = Vector3.one * 0.8;

    self.goldCount = self.effect:Find("Coin"):GetComponent("Text")
    self.goldCountText = self.goldCount;
    self.goldCountText.text = ""
    self.baseS = self.goldCountText.transform.localScale.x

    self.childCount  = 0
    self.finishCount = 0
    self.isMasterFinish = false
    self.stopReceive = false

    --金币的实际值和显示值
    self.realMoney = 0
    self.showMoney = 0

    --用来升级转盘
    self.multiple = 0
    --转盘的初始状态为最低级
    self.level = "low"
	
	--[[ debug code
	local fId = self.effect:Find("F_ID");
	if fId then
		local fId = fId:GetComponent("Text");
		local nId = self.effect:Find("N_ID"):GetComponent("Text")
		fId.text = f_id;
		nId.text = n_id;
		self.__nid = n_id;
	end
	--]]
	
    --ZTD.PlayMusicEffect("ZTD_zhuanpan_level_low", nil, nil, true);
    --PoisonMedal:UpdateGold(earnMoney);
	
	local poxGoldData = ZTD.GoldData.Helper:new();
	self._goldData = poxGoldData;
	local comboNode = ZTD.ComboShowTree.LinkCombo({atkType = ZTD.AttackData.TypePox, medalUi = self, goldData = poxGoldData}, f_id, n_id);
	self._comboNode = comboNode;
	if self._comboNode == nil then
		logError("!!!!!!!!!!!!!!!!PoisonMedal:Init comboNode == nil root_id, node_id:" .. f_id .. "," .. n_id);
	end
	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	self.IsConnect = enemyMgr.connectList[masterId]
end

-- fly gold 回调使用
function PoisonMedal:GetGoldPos()
	return self.effectPos;
end	

function PoisonMedal:UpdateGold(showMoney, comboNode, addRatio, GiantHitPower, balloonRatio)
	self.GiantHitPower = GiantHitPower or 0
	self.balloonRatio = balloonRatio or 0
	-- logError("UpdateGold="..tostring(showMoney))
	if self.realMoney == 0 and showMoney > 0 then
		self:SetPanelData(self.level)
		self.effect:SetActive(true);
		ZTD.PlayMusicEffect("ZTD_zhuanpan_level_low", nil, nil, true);
		
		local cfg = ZTD.ConstConfig[1];
		-- 只在第一次UpdateGold执行,一旦被判定为倍率奖牌，后面全都是倍率金币
		if addRatio and addRatio > 1 then
			self.addRatio = addRatio;
			self.effect:FindChild("img_r"):SetActive(true);
			self.effect:FindChild("img_s"):SetActive(true);
			self.effect:FindChild("node_zd"):SetActive(true);
			if addRatio > 1 and addRatio < 5 then
				self.effect:FindChild("img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. addRatio);	
			else
				self.effect:FindChild("img_r"):SetActive(false);
			end
		end			
		if GiantHitPower and GiantHitPower > 1 then
			self.effect:FindChild("img_ss"):SetActive(true);
			self.effect:FindChild("img_giant"):SetActive(true)
			self.effect:FindChild("img_giant"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. GiantHitPower);
		else
			self.effect:FindChild("img_giant"):SetActive(false)
		end
		if balloonRatio > 1 and balloonRatio < 4 then
			--logError("balloonRatio="..tostring(self.balloonRatio))
			self.effect:FindChild("node_zd/img_rzd"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. balloonRatio);
			self.effect:FindChild("node_zd/img_zd"):SetActive(true)
		else
			self.effect:FindChild("node_zd"):SetActive(false);
		end
		self.effect:FindChild("linkImg"):SetActive(self.IsConnect)
		if not self.IsConnect then
			self.effect:FindChild("giantImg"):SetActive(GiantHitPower > 0)
		else
			self.effect:FindChild("giantImg"):SetActive(false)
		end
	end
	
	self.realMoney = showMoney
	self:RollPanelCoin()
	ZTD.PlayMusicEffect("ZTD_coinRecycle", nil, nil, true);	
end

function PoisonMedal:RefreshGold(childUi)	
	if childUi and childUi.className == "ZTD_GhostFireUi" and  self.effect and self.effect.localScale.x ~= 1.2 then
		self:StartAction(self.effect, {{"scaleTo", 1.2, 1.2, 1.2, 0}});
	end
	self:UpdateGold(self._goldData.Show)
end	
-- fly gold end


function PoisonMedal:RollPanelCoin()
	if self.coinRollTimer ~= nil then
		self:StopTimer(self.coinRollTimer)
		self.coinRollTimer = nil
    end
	self.showTotalMoney = self.realMoney;
	if self.addRatio then
		self.showTotalMoney = math.floor(self.realMoney / self.addRatio);
	end	
	-- logError("showTotalMoney="..tostring(self.showTotalMoney))
    local everyChangeMoney = math.ceil((self.showTotalMoney - self.showMoney) * 0.1)
	-- logError("everyChangeMoney="..tostring(everyChangeMoney))
    self.coinRollTimer = self:StartTimer(
            function()
				self.showMoney = self.showMoney + everyChangeMoney
				-- logError("showMoney="..tostring(self.showMoney).."  showTotalMoney="..tostring(self.showTotalMoney))
                if self.showMoney >= self.showTotalMoney then
                    self.showMoney = self.showTotalMoney
					if self.coinRollTimer ~= nil then
						-- logError("!!!!!!!!!! StopTimer")
						self:StopTimer(self.coinRollTimer)
						self.coinRollTimer = nil
                        --数字滚动完后检查一下是否已经结束
                        if self:CheckIsFinish() then
							--  logError("CheckIsFinishCheckIsFinish:" )
                            self:OnAllFinish()
                        end
                    end
                end
                self:SetPanelShowText(tostring(Mathf.Round(self.showMoney)))            
            end,
            0.05,
            -1
        )
end

function PoisonMedal:CheckIsFinish()
	local recorder = 0;
	if self._comboNode ~= nil then
		recorder = self._comboNode.data.goldData.Recorder;
	else
		logError("CheckIsFinishCheckIsFinishCheckIsFinish EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")
	end	
	-- logError("isMasterFinish="..tostring(self.isMasterFinish))
	-- logError("recorder="..recorder)
	return self.isMasterFinish and recorder <= 0;
end
	
function PoisonMedal:OnAllFinish()
	if self.effect == nil then
		logError("!!!PoisonMedal OnAllFinish error:" .. debug.traceback())
		return;
	end
	
	self:StartAction(self.effect, nil)
	self._isEnd = false;
	local endFunc = function()		
		if self._isEnd then
			return;
		end		
		self._isEnd = true;
		local comboNode = self._comboNode;
		-- 刷新上层金币
		-- logError("comboNode="..tostring(comboNode))
		ZTD.ComboShowTree.ReduceComboByNode(comboNode);
		self._comboNode = nil;
		
		ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, self.realMoney / self.ratio, self.realMoney);
		
		self:Release()		
	end	
	self._EndFunc = endFunc;
	
    self:StartTimer(function()
		local spawnAction = 
			{"spawn",
				{
					{ "delay", 1},
					{ "scaleTo", 0.1, 0.1, 0.1, 0.5}
				},
				{
					--{ "moveTo", targetPos.x, targetPos.y, targetPos.z, 0.5, ZTD.MainScene.UICamObj},
					{ "delay", 1},
					{ "call"  , function()
						if self.effect then
							local targetPos = ZTD.ComboShowTree.GetParentUIGoldPos(self._comboNode)
							self:StartBezier(targetPos, self.effectPos, self.effect, nil, endFunc, 0.5);
						end	
					end	
					},
				},
		   };
		if self.effect then
			self:StartAction(self.effect, spawnAction)
		end	
    end,0.5,1)	
end	

function PoisonMedal:StopAll()
	
	SUPER.StopAll(self);
	
	-- 现在刷新房间相当于重新登录流程，不需要每个调用回调	
	--if self._EndFunc and not self._isEnd then
	--	self._EndFunc();
	--end
end

function PoisonMedal:LevelUpZhuanPan()
    if self.level == "low" then
        self.level = "mid"
        self:SetPanelData(self.level)
        ZTD.PlayMusicEffect("ZTD_zhuanpan_level_mid", nil, nil, true)
    elseif self.level == "mid" then
        self.level = "high"
        self:SetPanelData(self.level)
        ZTD.PlayMusicEffect("ZTD_zhuanpan_level_high", nil, nil, true)
    end
end

function PoisonMedal:SetPanelData(key)
    local cfg = ZTD.RatioSetConfig;
    local iconPath
    local iconName
    local showName
    local nameColor
    local outlineColor
    local playerInterval

	local masterCfg = ZTD.MainScene.GetEnemyCfg(self._masterType);

	iconName = masterCfg.icon
	
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_EnemyConfig");
    showName = language[masterCfg.id].name; 

    iconPath = cfg[key].iconPath
    nameColor = cfg[key].nameColor
    outlineColor = cfg[key].outlineColor
    playerInterval = cfg[key].playInterval
    self:ZhuanPanView(iconPath,iconName,showName,nameColor,outlineColor)
end

function PoisonMedal:ZhuanPanView(iconPath,iconName,name,nameColor,outlineColor)
    --背景图
	local childCount = self.effect:FindChild("Root/BG").childCount
    for i = 1,childCount do
        local trans = self.effect:FindChild("Root/BG"):GetChild(i - 1)
		trans.gameObject:SetActive(trans.name == iconPath)
		if trans.name == iconPath then
			local balloonEff = self.effect:FindChild("Root/BG/zhadanEffect")
            balloonEff:SetActive(self.balloonRatio > 0)
            if trans:GetComponent(typeof(Spine.Unity.SkeletonGraphic)).AnimationState ~= nil then
                trans:GetComponent(typeof(Spine.Unity.SkeletonGraphic)).AnimationState:SetAnimation(0, "stand1", false)
            end
        end
    end
    --显示icon
    local iconImage = self.effect:FindChild("Root/IconMask/MonsterIcon"):GetComponent("Image")
    local s = ResMgr.LoadAssetSprite("prefab", iconName)
    iconImage.sprite = s
    iconImage:SetNativeSize()
    iconImage.gameObject:SetActive(false)
    iconImage.gameObject:SetActive(true)

    --名字文字
    self.effect:Find("Root/MonsterName"):GetComponent("Text").text = name
    --名字文字颜色
    self.effect:Find("Root/MonsterName"):GetComponent("Text").color = nameColor
    --文字阴影
    self.effect:Find("Root/MonsterName"):GetComponent("Shadow").effectColor = outlineColor
end

function PoisonMedal:SetPanelShowText(t)
    if self.effect ~= nil then
        --文字背景大小
        local baseSizeY = self.effect:Find("TextBG"):GetComponent("RectTransform").sizeDelta.y
        local baseSizeX = 60
		local singleX = 40
		local bWidth = #tostring(t) * singleX + baseSizeX
		-- logError("bWidth="..tostring(bWidth).."  baseSizeY="..tostring(baseSizeY))
        self.effect:Find("TextBG"):GetComponent("RectTransform").sizeDelta = Vector2(bWidth, baseSizeY)
		self.goldCountText.text = tools.numberToStrWithComma(t);
		local rPos = self.effect:FindChild("img_r").localPosition;
		local sPos = self.effect:FindChild("img_s").localPosition;
		local pos = Vector3(-bWidth/3 - 40, sPos.y, sPos.z)
		local pos1 = Vector3(bWidth/4 + 30, rPos.y, rPos.z)
		local pos2 = Vector3(bWidth/4 + 85, rPos.y, rPos.z)
		local pos3 = Vector3(bWidth/4 + 135, rPos.y, rPos.z)
		if self.addRatio and self.addRatio > 1 then	
			self.effect:FindChild("img_s").localPosition = pos
			self.effect:FindChild("img_r").localPosition = pos1
			if self.GiantHitPower and self.GiantHitPower > 1 then
				self.effect:FindChild("img_ss").localPosition = pos
				self.effect:FindChild("img_giant").localPosition = pos2
				self.effect:FindChild("node_zd").localPosition = pos3
			else
				self.effect:FindChild("img_giant").localPosition = pos3
			end
		else
			if self.GiantHitPower and self.GiantHitPower > 1 then
				self.effect:FindChild("img_giant").localPosition = pos1
				self.effect:FindChild("node_zd").localPosition = pos2
			else
				self.effect:FindChild("img_giant").localPosition = pos1
			end
		end

        local scales = {}
        table.insert(scales,{"scaleTo",self.baseS *1.15,self.baseS *1.15,self.baseS *1.3,0.05 / 2})
        table.insert(scales,{"scaleTo",self.baseS *   1,self.baseS *   1,self.baseS *  1,0.05 / 2})
        ZTD.Extend.RunAction(self.goldCountText.transform,scales)

        self:CheckLevel()
    end
end

function PoisonMedal:CheckLevel()
    local multiple
    if self.multipleNumber ~= nil and self.multipleNumber > 1 then
        multiple = Mathf.Round(self.showMoney / self.ratio * self.multipleNumber)
    else
        multiple = Mathf.Round(self.showMoney / self.ratio)
    end
    if multiple >= levelConfig[self.level] then
        self:LevelUpZhuanPan()
    end
end


function PoisonMedal:Release()
    if self.isRelease == true then return end
    self.isRelease = true
    if self.coinRollTimer ~= nil then
		self:StopTimer(self.coinRollTimer)
		self.coinRollTimer = nil
    end
	self:StopAll();
	
    if self.effect ~= nil and tostring(self.effect) ~= "null" then
		ZTD.PoolManager.RemoveUiItem(Prefab, self.effect);
        self.effect = nil
		
		if self.gridPos then
			ZTD.MainScene.PanGirdData:WriteGridByInx(self.gridPos.i, self.gridPos.j, nil);
		end	
    end
end

local PoisonMedalMgr = {};
PoisonMedalMgr.Medals = {};
 
function PoisonMedalMgr.CreateMedal(masterId, coinPos, monsterType, ratio, f_id, n_id)
	local medal = PoisonMedal:new();
	medal:Init(coinPos, monsterType, ratio, f_id, n_id, masterId)
	PoisonMedalMgr.Medals[masterId] = medal;
	return medal;
end

function PoisonMedalMgr.FinshMedal(masterId)
	local medal = PoisonMedalMgr.Medals[masterId];
	if medal then
		medal.isMasterFinish = true;
		medal:RefreshGold();
	end	
	--PoisonMedalMgr.Medals[masterId] = nil;
end

function PoisonMedalMgr.ReleaseAll(masterId)
	for _, medal in pairs(PoisonMedalMgr.Medals) do
		medal:Release();
	end	
	PoisonMedalMgr.Medals = {};
end

return PoisonMedalMgr