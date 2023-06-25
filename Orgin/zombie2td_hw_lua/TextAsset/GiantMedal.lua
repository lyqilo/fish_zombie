local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

-- 巨人牌子基类
local GiantMedal = GC.class2("GiantMedal", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase

-- 重新激活动画
function GiantMedal:WakeUpEffect()
	self.effect:SetActive(false)
	self.effect:SetActive(true)
    self.effect.position = Vector3(self.dropPos.x, self.dropPos.y + 3, 0)
    self.effect.localScale = Vector3.one
end

function GiantMedal:Init(config)
	SUPER.Init(self)
	for vname, vvalue in pairs(config) do
		self[vname] = vvalue
	end
    self.isRelease = false
    self.effect = ZTD.PoolManager.GetUiItem(self.prefabName, ZTD.GoldPlay.EffectParent);   
	self.goldCountText = self.effect:Find("txt_gold"):GetComponent("Text")
    self.showEarnMoney = self.earnMoney
	if self.addRatio and self.addRatio > 1 then
		self.showEarnMoney = self.earnMoney / self.addRatio
    end
    self.goldCountText.text = tools.numberToStrWithComma(self.showEarnMoney)
    local cfg = ZTD.ConstConfig[1]
	if self.addRatio and self.addRatio > 1 then
        self.effect:FindChild("longmuRat"):SetActive(true)
        self.effect:FindChild("longmuRat/img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.addRatio)
	else
        self.effect:FindChild("longmuRat"):SetActive(false)
    end	
	self:WakeUpEffect()
    self:CreateEffect()
    self:SetPanelUi()
end

function GiantMedal:SetPanelUi()
    local baseSizeX = 35
    local singleX = 35
	local bWidth = #tostring(self.showEarnMoney) * singleX + baseSizeX
    local rPos = self.effect:FindChild("longmuRat/img_r").localPosition
	local sPos = self.effect:FindChild("longmuRat/img_s").localPosition
    local pos = Vector3(-bWidth/3 - 150, sPos.y, sPos.z)
    local pos1 = Vector3(bWidth/4 + 100, rPos.y, rPos.z)
    if self.addRatio and self.addRatio > 1 then
		self.effect:FindChild("longmuRat/img_s").localPosition = pos
        self.effect:FindChild("longmuRat/img_r").localPosition = pos1
    end
end

------------------------------------自身向记分板发射金币--------------------------------------------------
function GiantMedal:CreateEffect()
	local launchNum = self.rollTimes
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

function GiantMedal:Release()
    self.isRelease = true
    self:StopAll()
    ZTD.PoolManager.RemoveUiItem(self.prefabName, self.effect)
	self.effect = nil
	if self.gridPos then
		ZTD.MainScene.PanGirdData:WriteGridByInx(self.gridPos.i, self.gridPos.j, nil)
	end
end

return GiantMedal