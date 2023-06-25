
local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

-- 熊基类
local BearMedal = GC.class2("BearMedal", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase

-- 重新激活动画
function BearMedal:WakeUpEffect()
	self.effect:SetActive(false);
	self.effect:SetActive(true);
    self.effect.position = Vector3(self.dropPos.x, self.dropPos.y, 0)
    self.effect.localPosition = self:GetEffectUiPosition(self.effect)
    self.effect.localScale = Vector3.one * 0.8
end

function BearMedal:Init(config)
    SUPER.Init(self);
	for vname, vvalue in pairs(config) do
		self[vname] = vvalue;
	end
    self:ThreeBallEffectInit(config)
end

--奖牌前特效部分
function BearMedal:ThreeBallEffectInit(config)
    self.effXzhu = ZTD.PoolManager.GetUiItem("Effect_TD_Xzhu01", ZTD.GoldPlay.EffectParent);
    self.hongEffect22 = ZTD.PoolManager.GetUiItem("Effect_GH_hong_22", ZTD.GoldPlay.EffectParent);
    self.hongEffect = self.effXzhu:FindChild("Effect_GH_hong_21")
    self.bao0101 = self.effXzhu:FindChild("bao0101")
    self.mulTextEff = self.hongEffect:FindChild("txtMul")
    self.hongEffect22:SetActive(false)
    self.hongEffect:SetActive(false)
    self.bao0101:SetActive(false)
    self.mulTextEff:SetActive(false)
    self.effXzhu.position = Vector3(self.dropPos.x, self.dropPos.y, 0)
    self.effXzhu.localPosition = self:GetEffectUiPosition(self.effXzhu)
    self.hongEffect22.position = Vector3(self.dropPos.x, self.dropPos.y, 0)
    self.hongEffect22.localPosition = self:GetEffectUiPosition(self.hongEffect22)
    self.BearMultiplelist = string.split(config.BearMultiple,"-")

    ZTD.GameTimer.DelayRun(1, function()
        self.hongEffect22:SetActive(true)
    end)

    ZTD.GameTimer.DelayRun(2, function()
        self.hongEffect:SetActive(true)
        ZTD.PoolManager.RemoveUiItem("Effect_GH_hong_22", self.hongEffect22);
        ZTD.PlayMusicEffect("bearEffectRoll", nil, true)
        self:MulRandomTween("Coin01",self.BearMultiplelist[1], 0.3)
        self:MulRandomTween("Coin02",self.BearMultiplelist[2], 0.8)
        self:MulRandomTween("Coin03",self.BearMultiplelist[3], 1.3)
    end)

    ZTD.GameTimer.DelayRun(1 + 1 + 1.6, function ()
        ZTD.StopMusicEffect("bearEffectRoll")
    end)

    ZTD.GameTimer.DelayRun(2.4 + 1 + 0.8, function()
        ZTD.PlayMusicEffect("bearEffectChangeBig",nil,nil,true)
        self:MulRandomRecycleTween()
    end)

    ZTD.GameTimer.DelayRun(3.7 + 1 + 0.5, function()
        self.mulTextEff:SetActive(false)
        ZTD.PlayMusicEffect("bearEffectXiong",nil,nil,true)
        local hongEffectAnim = self.hongEffect:GetComponent(typeof(UnityEngine.Animator))
        hongEffectAnim.enabled = true
        self.bao0101:SetActive(true)
    end)
    ZTD.GameTimer.DelayRun(4.3 + 1 + 0.3 + 0.6, function()

        self.effect = ZTD.PoolManager.GetUiItem(self.prefabName, ZTD.GoldPlay.EffectParent);
        self:InitBearConfig()

        ZTD.GameTimer.DelayRun(1.5, function()
            ZTD.PoolManager.RemoveUiItem("Effect_TD_Xzhu01", self.effXzhu);
        end)
    end)
    
    self.battleLg = self.battleLg or ZTD.LanguageManager.GetLanguage("L_ZTD_BattleView");
end

--数字回收动画
function BearMedal:MulRandomRecycleTween()
    local txtMul1 = self.hongEffect:FindChild("Coin01")
    local txtMul2 = self.hongEffect:FindChild("Coin02")
    local txtMul3 = self.hongEffect:FindChild("Coin03")

    local txtPos = self.mulTextEff.transform.localPosition
    local spawnAction = {
        {"spawn",
            {"localMoveTo", txtPos.x, txtPos.y, txtPos.z, 0.2},
             {"scaleTo", 0, 0, 0, 0.2}
        }
    }
    ZTD.Extend.RunAction(txtMul1, spawnAction)
    ZTD.Extend.RunAction(txtMul2, spawnAction)
    ZTD.Extend.RunAction(txtMul3, spawnAction)

    ZTD.GameTimer.DelayRun(0.3, function()
        if self.BearMultiplelist and table.getn(self.BearMultiplelist) == 3 then
            local sumMul = tonumber(self.BearMultiplelist[1]) * tonumber(self.BearMultiplelist[2]) * tonumber(self.BearMultiplelist[3])
            self.mulTextEff:FindChild("text"):GetComponent("Text").text = tostring(sumMul) .." ".. self.battleLg.txt_Mul;
        else
            logError("没有------->   " .. self.BearMultiple)
            self.mulTextEff:FindChild("text"):GetComponent("Text").text = "50 ".. self.battleLg.txt_Mul;
        end

        self.mulTextEff.transform.localScale = Vector3.zero
        txtMul1:SetActive(false)
        txtMul2:SetActive(false)
        txtMul3:SetActive(false)
        self.mulTextEff:SetActive(true)
        ZTD.Extend.RunAction(self.mulTextEff,{{"scaleTo",1.5,1.5,1.5,0.1}, {"scaleTo",1,1,1,0.1}})
        ZTD.PlayMusicEffect("bearEffectMul",nil,nil,true)

    end)
end

--数字滚动动画
function BearMedal:MulRandomTween(name, mulText, delayTime)
    local txtMul = self.hongEffect:FindChild(name)
    local bearMulCfgs = ZTD.BearConfig.Cfg
    local cfgLen = table.getn(bearMulCfgs)

    local to = {"to", bearMulCfgs[1], bearMulCfgs[cfgLen] * 2, delayTime, function(value)
        local index = math.random(bearMulCfgs[1],bearMulCfgs[cfgLen])
        txtMul:GetComponent("Text").text = "x".. tostring(index)
    end}
    local tweenAction = {
        {"delay", 0},
            to,
            onEnd = function()
                txtMul:GetComponent("Text").text = "x".. mulText
		        ZTD.Extend.RunAction(txtMul,{{"scaleTo",2.5,2.5,2.5,0.1},{"scaleTo",1,1,1,0.1}})
            end
        }
    ZTD.Extend.RunAction(self.hongEffect,tweenAction)
end

function BearMedal:GetEffectUiPosition(node)
    local maxScreenWidth =  ZTD.BattleView.inst.tempPosNode.localPosition.x
    local maxScreenHeigh =  ZTD.BattleView.inst.tempPosNode.localPosition.y
    local pos = node.localPosition
    if pos.x > maxScreenWidth - 60 then
		pos.x = maxScreenWidth - 110
	elseif 	 pos.x < - maxScreenWidth + 60 then
		pos.x = - maxScreenWidth + 110
	end

	if pos.y > maxScreenHeigh then
		pos.y = maxScreenHeigh - 30
	elseif 	 pos.y < - maxScreenHeigh then
		pos.y = - maxScreenHeigh + 100
	end

    return pos
end

function BearMedal:InitBearConfig()
    self.isRelease = false
    self.GiantHitPower = self.GiantHitPower or 0
    self.balloonRatio = self.balloonRatio or 0
	self.goldCountText = self.effect:Find("PAIZI2/Coin"):GetComponent("Text");
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

    local isSelfRatio = self.addRatio > 1 and self.GiantHitPower == 0 and self.balloonRatio == 0

	self.effect:FindChild("Extra/img_r"):SetActive(isSelfRatio);
    self.effect:FindChild("Extra/img_s"):SetActive(isSelfRatio);
    self.effect:FindChild("Extra/img_ss"):SetActive(self.GiantHitPower > 1);
    self.effect:FindChild("Extra/img_giant"):SetActive(self.GiantHitPower > 1);
    self.effect:FindChild("Extra/node_zd"):SetActive(self.balloonRatio > 1);
    local cfg = ZTD.ConstConfig[1];

	if self.addRatio > 1 and self.addRatio < 5 then
        self.effect:FindChild("Extra/img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.addRatio);
	else
        self.effect:FindChild("Extra/img_r"):SetActive(false);
    end
    if self.GiantHitPower and self.GiantHitPower > 1 then
        self.effect:FindChild("Extra/img_giant"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.GiantHitPower);
        self.effect:FindChild("Extra/img_giant"):SetActive(true)
    else
        self.effect:FindChild("Extra/img_giant"):SetActive(false);
    end
    if self.balloonRatio > 1 and self.balloonRatio < 4 then
        self.effect:FindChild("Extra/node_zd/img_rzd"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.balloonRatio);
        self.effect:FindChild("Extra/node_zd/img_zd"):SetActive(true)
    else
        self.effect:FindChild("Extra/node_zd"):SetActive(false);
    end
    self.effect:FindChild("Extra/linkImg"):SetActive(self.IsConnect)
    if not self.IsConnect then
        self.effect:FindChild("Extra/giantImg"):SetActive(self.GiantHitPower > 0)
    else
        self.effect:FindChild("Extra/giantImg"):SetActive(false)
    end

	self:WakeUpEffect()
    self:CreateEffect()
    self:SetPanelUi()
end

function BearMedal:SetPanelUi()
    local baseSizeX = 56
    local singleX = 56
	local bWidth = #tostring(self.showEarnMoney) * singleX + baseSizeX
    local rPos = self.effect:FindChild("Extra/img_r").localPosition;
	local sPos = self.effect:FindChild("Extra/img_s").localPosition;
    local pos = Vector3(-bWidth/3 - 40, sPos.y, sPos.z)
    local pos1 = Vector3(bWidth/4 + 30, rPos.y, rPos.z)
    local pos2 = Vector3(bWidth/4 + 85 + 30, rPos.y, rPos.z)
    local pos3 = Vector3(bWidth/4 + 140 + 40, rPos.y, rPos.z)
    if self.addRatio > 1 and self.effect:FindChild("Extra/img_r").activeSelf then
		self.effect:FindChild("Extra/img_s").localPosition = pos
        self.effect:FindChild("Extra/img_ss").localPosition = pos
        self.effect:FindChild("Extra/img_r").localPosition = pos1
        if self.GiantHitPower and self.GiantHitPower > 1 then
            self.effect:FindChild("Extra/img_giant").localPosition = pos2
            self.effect:FindChild("Extra/node_zd").localPosition = pos3
        else
            self.effect:FindChild("Extra/node_zd").localPosition = pos2
        end
    else
        if self.GiantHitPower and self.GiantHitPower > 1 then
            self.effect:FindChild("Extra/img_giant").localPosition = pos1
            self.effect:FindChild("Extra/node_zd").localPosition = pos2
        else
            self.effect:FindChild("Extra/node_zd").localPosition = pos1
        end
    end
end

------------------------------------自身向记分板发射金币--------------------------------------------------
function BearMedal:CreateEffect()
	local launchNum = self.rollTimes
    --整体的展示过程，由起始时间 + 发射速率 * 发射个数 + 结束时间
    local startShowTime = 0
    local endShowTime = 2.9
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
    -- logError("self.playInterval="..tostring(self.playInterval))
    self:StartAction(self.effect,
        {
            {"delay", self.playInterval*0.5},
            {"call", function()
                if self.coinFlyFunc then
                    self.coinFlyFunc()
                end
            end}})
    self:StartTimer(function()
        if self.isRelease then return end
		local function onEndFunc()
			ZTD.GoldPlay.RemoveGoldPlayByLua(self)
			if self.callBack then
				self.callBack()
			end
		end
		local effect = self.effect
		local targetPos = self.targetPos
		self:StartBezier(targetPos, effect.position, effect, nil, onEndFunc, 0.6)
		self:StartAction(effect, {"scaleTo", 0.2, 0.2, 0.2, 0.5})
    end, self.playInterval * 0.7, 1)
end

function BearMedal:Release()
    self.isRelease = true;
    ZTD.StopMusicEffect("bearEffectRoll");
    self:StopAll()
    self:StopAllAction();
    ZTD.PoolManager.RemoveUiItem(self.prefabName, self.effect)
	self.effect = nil
	if self.gridPos then
		ZTD.MainScene.PanGirdData:WriteGridByInx(self.gridPos.i, self.gridPos.j, nil)
	end
end

return BearMedal;