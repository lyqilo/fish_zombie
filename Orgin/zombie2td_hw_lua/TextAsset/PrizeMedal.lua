local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

-- 转盘基类
local PrizeMedal = GC.class2("PrizeMedal", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase

-- 重新激活动画
function PrizeMedal:WakeUpEffect()
	self.effect:SetActive(false);
	self.effect:SetActive(true);
    self.effect.position = Vector3(self.dropPos.x, self.dropPos.y + 1.5, 0)
    self.effect.localScale = Vector3.one * 0.8
end

function PrizeMedal:Init(config)
	SUPER.Init(self);
	
	for vname, vvalue in pairs(config) do
		self[vname] = vvalue;
	end
    self.isRelease = false
    self.GiantHitPower = self.GiantHitPower or 0

    self.balloonRatio = self.balloonRatio or 0
	
    self.effect = ZTD.PoolManager.GetUiItem(self.prefabName, ZTD.GoldPlay.EffectParent);    
	self.goldCountText = self.effect:Find("Coin"):GetComponent("Text");
	
	self.showEarnMoney = self.earnMoney;
	if self.addRatio > 1 then
		self.showEarnMoney = self.earnMoney / self.addRatio;
    end	
    if self.GiantHitPower > 1 then
		self.showEarnMoney = self.showEarnMoney / self.GiantHitPower;
	end	
    if self.balloonRatio > 1 then
		self.showEarnMoney = self.showEarnMoney / self.balloonRatio;
	end	
		
    self.goldCountText.text = tools.numberToStrWithComma(self.showEarnMoney);
	
	self.effect:FindChild("img_r"):SetActive(self.addRatio > 1);
    self.effect:FindChild("img_s"):SetActive(self.addRatio > 1);
    self.effect:FindChild("img_ss"):SetActive(self.GiantHitPower > 1);
    self.effect:FindChild("img_giant"):SetActive(self.GiantHitPower > 1);
    self.effect:FindChild("node_zd"):SetActive(self.balloonRatio > 1);
    local cfg = ZTD.ConstConfig[1];
	if self.addRatio > 1 and self.addRatio < 5 then
        self.effect:FindChild("img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.addRatio);
	else
        self.effect:FindChild("img_r"):SetActive(false);
    end	
    if self.GiantHitPower and self.GiantHitPower > 1 then
        self.effect:FindChild("img_giant"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.GiantHitPower);
        self.effect:FindChild("img_giant"):SetActive(true)
    else
        self.effect:FindChild("img_giant"):SetActive(false);
    end
    if self.balloonRatio > 1 and self.balloonRatio < 4 then
        self.effect:FindChild("node_zd/img_rzd"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.balloonRatio);
        self.effect:FindChild("node_zd/img_zd"):SetActive(true)
    else
        self.effect:FindChild("node_zd"):SetActive(false);
    end
    self.effect:FindChild("linkImg"):SetActive(self.IsConnect)
    if not self.IsConnect then
        self.effect:FindChild("giantImg"):SetActive(self.GiantHitPower > 0)
    else
        self.effect:FindChild("giantImg"):SetActive(false)
    end
	
	self:WakeUpEffect();
	
    self:CreateEffect()

    self:InitMonsterPanel(self.prizeLevel, self.iconName, self.iconPic)
end

function PrizeMedal:InitMonsterPanel(prizeLevel, iconName, iconPic)
	local cfg = ZTD.RatioSetConfig;
	local key = "low";
    if prizeLevel == 2 then
        key = "low"
    elseif prizeLevel == 3 then
        key = "mid"
    elseif prizeLevel == 4 then
        key = "high"
    end
    local iconPath = cfg[key].iconPath
    local nameColor = cfg[key].nameColor
    local outlineColor = cfg[key].outlineColor
    local playInterval = cfg[key].playInterval
	
	local soundName = "ZTD_zhuanpan_level_" .. key;	
	
    self:SetPanelUi(iconPath,iconPic,iconName,nameColor,outlineColor,playInterval,soundName)
end

function PrizeMedal:SetPanelUi(iconPath,iconName,name,nameColor,outlineColor,playInterval,soundName)
	ZTD.PlayMusicEffect(soundName, nil, nil, true);
    --背景图
	local root = self.effect:FindChild("Root")
    local childCount = root:FindChild("BG").childCount
    for i = 1,childCount do
        local trans = root:FindChild("BG"):GetChild(i - 1)
        trans.gameObject:SetActive(trans.name == iconPath)
        if trans.name == iconPath then
            local balloonEff = self.effect:FindChild("Root/BG/zhadanEffect")
            balloonEff:SetActive(self.balloonRatio > 0)
			local skAnim = trans:GetComponent(typeof(Spine.Unity.SkeletonGraphic));
			if skAnim.AnimationState then
				skAnim.AnimationState:SetAnimation(0, "stand1", false)
			end	
        end
    end
    --显示icon
    local iconImage = root:FindChild("IconMask/MonsterIcon"):GetComponent("Image")
    local s = ResMgr.LoadAssetSprite("prefab", iconName)
    iconImage.sprite = s
    iconImage:SetNativeSize()
    --名字文字
    root:Find("MonsterName"):GetComponent("Text").text = name
    --名字文字颜色
    root:Find("MonsterName"):GetComponent("Text").color = nameColor
    --文字阴影
    root:Find("MonsterName"):GetComponent("Shadow").effectColor = outlineColor
    --文字背景大小
    local baseSizeY = self.effect:Find("TextBG"):GetComponent("RectTransform").sizeDelta.y
    local baseSizeX = 60
    local singleX = 25
	local bWidth = #tostring(self.showEarnMoney) * singleX + baseSizeX;
    self.effect:Find("TextBG"):GetComponent("RectTransform").sizeDelta = Vector2(bWidth, baseSizeY)
    local rPos = self.effect:FindChild("img_r").localPosition;
	local sPos = self.effect:FindChild("img_s").localPosition;
    local pos = Vector3(-bWidth/3 - 60, sPos.y, sPos.z)
    local pos1 = Vector3(bWidth/4 + 30, rPos.y, rPos.z)
    local pos2 = Vector3(bWidth/4 + 85, rPos.y, rPos.z)
    local pos3 = Vector3(bWidth/4 + 140, rPos.y, rPos.z)
    self.effect:FindChild("img_s").localPosition = pos
    self.effect:FindChild("img_ss").localPosition = pos
    self.effect:FindChild("img_r").localPosition = pos1
    if self.addRatio > 1 then
        if self.GiantHitPower and self.GiantHitPower > 1 then
            self.effect:FindChild("img_giant").localPosition = pos2
            self.effect:FindChild("node_zd").localPosition = pos3
        else
            self.effect:FindChild("node_zd").localPosition = pos2
        end
    else
        if self.GiantHitPower and self.GiantHitPower > 1 then
            self.effect:FindChild("img_giant").localPosition = pos1
            self.effect:FindChild("node_zd").localPosition = pos2
        else
            self.effect:FindChild("node_zd").localPosition = pos1
        end
    end
end

------------------------------------自身向记分板发射金币--------------------------------------------------
function PrizeMedal:CreateEffect()
	
	local launchNum = self.rollTimes;

    --整体的展示过程，由起始时间 + 发射速率 * 发射个数 + 结束时间
    local startShowTime = 0
    local endShowTime = 0.95

    local launchRate = 0.1
    local durationTo = 0.8
    self.playInterval = startShowTime + launchRate * launchNum + endShowTime

    --递增
    local roll = launchNum - 1
    self.goldCountText.text = ""

    local function CoinRollView()
        self:StartTimer(
            function()
                local n = self.showEarnMoney - math.ceil(roll * self.showEarnMoney / launchNum)
                roll = roll - 1
                if n < 0 then
                    n = self.showEarnMoney
                end
                self.goldCountText.text = tools.numberToStrWithComma(n)
            end,
            launchRate,
            launchNum
        )
    end

    self:StartTimer(function()
        if self.isRelease then return end
        --这里延时是为了让自身动画和金币飞行看起来更加的契合
        self:StartTimer(function()
            CoinRollView()
        end,0,1)        
    end,startShowTime,1)    

    self:StartTimer(function()
        if self.isRelease then return end
		
		local function onEndFunc()
			ZTD.GoldPlay.RemoveGoldPlayByLua(self);
			if self.callBack then
				self.callBack();
			end
		end
		local effect = self.effect;
		local targetPos = self.targetPos;
		self:StartBezier(targetPos, effect.position, effect, nil, onEndFunc, 0.6);	
		self:StartAction(effect, {"scaleTo", 0.2, 0.2, 0.2, 0.5});
       
    end, self.playInterval * 0.7, 1)    
end

function PrizeMedal:Release()
    self.isRelease = true
    self:StopAll()
    ZTD.PoolManager.RemoveUiItem(self.prefabName, self.effect);
	self.effect = nil;
	if self.gridPos then
		ZTD.MainScene.PanGirdData:WriteGridByInx(self.gridPos.i, self.gridPos.j, nil);
	end
end

return PrizeMedal;