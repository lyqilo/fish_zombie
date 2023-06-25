local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local Prefab = "TD_BalloonUi"

local BalloonUi = GC.class2("ZTD_BalloonUi", ZTD.TimeMapBase)
local SUPER = ZTD.TimeMapBase

function BalloonUi:Init(MedalID, coinPos, monsterType, ratio, f_id, n_id)
	SUPER.Init(self)

	local mapPos = ZTD.MainScene.GetMapObj().position;
	local x, y, i, j = ZTD.MainScene.PanGirdData:GetFreeGrid(coinPos.x - mapPos.x, coinPos.y - mapPos.y);
	if x and y then
		coinPos = Vector3(mapPos.x + x, mapPos.y + y, coinPos.z);
		self.gridPos = {i = i, j = j}
		ZTD.MainScene.PanGirdData:WriteGridByInx(i, j, true);
	end	
	self.uiEffectParent = ZTD.BattleView.inst.coinEffect
	self.effectPos = ZTD.MainScene.SetupPos2UiPos(coinPos)
	self.ratio = ratio
	self.isRelease = false

	self.effect = ZTD.PoolManager.GetUiItem(Prefab, self.uiEffectParent)
	self.effect:SetActive(false)
	self.effect.position = Vector3(self.effectPos.x, self.effectPos.y, 0)
	self.effect.localScale = Vector3.one

	self.uiEffect = self.effect:FindChild("Effect_UI_baozha")
	self.goldCountText = self.effect:Find("txt_gold"):GetComponent("Text")
	self.goldCountText.text = ""
	self.baseS = self.goldCountText.transform.localScale.x

	self.effect:FindChild("img_r"):SetActive(false)
	self.effect:FindChild("img_s"):SetActive(false)

	--修改爆点为中心位置而不是脚部位置
    local rect = self.effect:GetComponent("RectTransform")
    rect.anchoredPosition = Vector2(rect.anchoredPosition.x + 17.5, rect.anchoredPosition.y + 65)
	
	--金币的实际值和显示值
	self.realMoney = 0
	self.showMoney = 0

	--免费子弹是否结束
	self.isMasterFinish = false

	local poxGoldData = ZTD.GoldData.Helper:new()
	self._goldData = poxGoldData
	local comboNode = ZTD.ComboShowTree.LinkCombo({atkType = ZTD.AttackData.TypePox, medalUi = self, goldData = poxGoldData}, f_id, n_id)
	self._comboNode = comboNode
	if self._comboNode == nil then
		logError("!!!!!!!!!!!!!!!!BalloonUi:Init comboNode == nil root_id, node_id:" .. f_id .. "," .. n_id)
	end
	local enemyMgr = ZTD.Flow.GetEnemyMgr()
	self.IsConnect = enemyMgr.connectList[MedalID]
end

--刷新金币值
function BalloonUi:UpdateGold(showMoney, comboNode, addRatio)
	--logError("UpdateGold"..tostring(showMoney).."  comboNode="..GC.uu.Dump(comboNode))
	--logError("realMoney="..tostring(self.realMoney))
	if self.realMoney == 0 and showMoney > 0 then
		ZTD.GameTimer.DelayRun(0.01, function ()
			self.effect:SetActive(true)
		end)
		-- 只在第一次UpdateGold执行,一旦被判定为倍率奖牌，后面全都是倍率金币
		if addRatio and addRatio > 1 then
			self.addRatio = addRatio
			self.effect:FindChild("img_r"):SetActive(true)
			self.effect:FindChild("img_s"):SetActive(true)
			if addRatio > 1 and addRatio < 5 then
				local cfg = ZTD.ConstConfig[1]
				self.effect:FindChild("img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. addRatio)
			else
				self.effect:FindChild("img_r"):SetActive(false)
			end
		end	
		self.effect:FindChild("linkImg"):SetActive(self.IsConnect)
	end
	self.realMoney = showMoney
	self:RollPanelCoin()
	ZTD.PlayMusicEffect("ZTD_coinRecycle", nil, nil, true)
end

--刷新金币
function BalloonUi:RefreshGold(childUi)	
	-- if childUi and childUi.className == "ZTD_GhostFireUi" and  self.effect and self.effect.localScale.x ~= 1.2 then
	-- 	self:StartAction(self.effect, {{"scaleTo", 1.2, 1.2, 1.2, 0}})
	-- end
	self:UpdateGold(self._goldData.Show)
end	

--母体位置
function BalloonUi:GetGoldPos()
	return self.effectPos
end	

function BalloonUi:RollPanelCoin()
    if self.coinRollTimer ~= nil then
		self:StopTimer(self.coinRollTimer)
		self.coinRollTimer = nil
    end
	self.showTotalMoney = self.realMoney
	if self.addRatio then
		self.showTotalMoney = math.floor(self.realMoney / self.addRatio)
	end	
    local everyChangeMoney = math.ceil((self.showTotalMoney - self.showMoney) * 0.1)
    self.coinRollTimer = self:StartTimer(
            function()
                self.showMoney = self.showMoney + everyChangeMoney
                if self.showMoney >= self.showTotalMoney then
                    self.showMoney = self.showTotalMoney
                    if self.coinRollTimer ~= nil then
						self:StopTimer(self.coinRollTimer)
						self.coinRollTimer = nil
                        --数字滚动完后检查一下是否已经结束
                        if self:CheckIsFinish() then
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

function BalloonUi:SetPanelShowText(t)
    if self.effect ~= nil then
        local baseSizeX = 60
		local singleX = 25
		local bWidth = #tostring(t) * singleX + baseSizeX
        self.goldCountText.text = tools.numberToStrWithComma(tonumber(t) > 0 and t or "")
		if self.addRatio and self.addRatio > 1 then	
			local rPos = self.effect:FindChild("img_r").localPosition
			local sPos = self.effect:FindChild("img_s").localPosition
			self.effect:FindChild("img_s").localPosition = Vector3(-bWidth/2 - 103, sPos.y, sPos.z)
			self.effect:FindChild("img_r").localPosition = Vector3(bWidth/2, rPos.y, rPos.z)
		end		

        local scales = {}
        table.insert(scales,{"scaleTo",self.baseS *1.15,self.baseS *1.15,self.baseS *1.3,0.05 / 2})
        table.insert(scales,{"scaleTo",self.baseS *   1,self.baseS *   1,self.baseS *  1,0.05 / 2})
        ZTD.Extend.RunAction(self.goldCountText.transform,scales)
    end
end

function BalloonUi:CheckIsFinish()
	local recorder = 0
	-- logError("self._comboNode="..tostring(self._comboNode))
	if self._comboNode ~= nil then
		recorder = self._comboNode.data.goldData.Recorder
		-- logError("self.comboNode.data.goldData="..GC.uu.Dump(self._comboNode.data.goldData.Recorder))
	else
		logError("! ! ! _comboNode = nil")
	end	
	-- logError("recorder="..tostring(recorder))
	-- logError("isMasterFinish="..tostring(tostring(self.isMasterFinish)))
	return self.isMasterFinish and recorder <= 0
end

function BalloonUi:OnAllFinish()
	if self.effect == nil then
		logError("! ! ! self.effect = nil")
		return
	end
	self:StartAction(self.effect, nil)
	self._isEnd = false
	local endFunc = function()		
		if self._isEnd then
			return
		end		
		self._isEnd = true
		local comboNode = self._comboNode
		-- logError("comboNode="..GC.uu.Dump(comboNode))
		-- 刷新上层金币
		ZTD.ComboShowTree.ReduceComboByNode(comboNode)
		self._comboNode = nil
		if not self.realMoney then
			ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, self.realMoney / self.ratio, self.realMoney)
		end
		self:Release()		
	end
	self:StartTimer(function()
		local spawnAction = 
			{"spawn",
				{
					{ "delay", 1},
					{ "scaleTo", 0.1, 0.1, 0.1, 0.5}
				},
				{
					{ "delay", 1},
					{ "call"  , function()
						if self.effect then
							local targetPos = ZTD.ComboShowTree.GetParentUIGoldPos(self._comboNode)
							self:StartBezier(targetPos, self.effectPos, self.effect, nil, endFunc, 0.5)
						end	
					end	
					},
				},
		   }
		if self.effect then
			self:StartAction(self.effect, spawnAction)
		end	
    end,0.5,1)	
end

function BalloonUi:Release()
	if self.isRelease == true then return end
	self.isRelease = true
    if self.coinRollTimer ~= nil then
		self:StopTimer(self.coinRollTimer)
		self.coinRollTimer = nil
    end
	self:StopAll()
	
    if self.effect ~= nil and tostring(self.effect) ~= "null" then
		ZTD.PoolManager.RemoveUiItem(Prefab, self.effect)
        self.effect = nil
		if self.gridPos then
			ZTD.MainScene.PanGirdData:WriteGridByInx(self.gridPos.i, self.gridPos.j, nil)
		end	
    end
end

return BalloonUi