local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TextEffect = GC.class2()
local textPrefab = "TD_TextEffect"
function TextEffect:OnCreate( config )
    self.parent = config.goldTextParent
    self.currentPos = config.currentPos
	self.callBack = config.callBack
    self.earnMoney = config.earnMoney
    self.isGray = config.isGray
	self.addRatio = config.addRatio
	self.GiantHitPower = config.GiantHitPower
	self.balloonRatio = config.balloonRatio or 0
	self.IsConnect = config.IsConnect
end

function TextEffect:CreateNormalText()
    local re_Times = 0.5
    local add_Times = 3
	
	if self.isGray then
		self._textPrefab = "TD_TextEffect1";
	else
		self._textPrefab = "TD_TextEffect";
	end
	
    local textObj, textObjID = ZTD.EffectManager.PlayEffect(self._textPrefab, self.parent, true);
	
    textObj.position = Vector3(self.currentPos.x, self.currentPos.y + 1, self.currentPos.z)
    textObj.localScale = Vector3.one*re_Times
	
	local money = self.earnMoney
	
	if self.addRatio > 1 then
		money = money / self.addRatio;
	end	
	if self.GiantHitPower > 1 then
		money = money / self.GiantHitPower
	end	
	if self.balloonRatio > 1 then
		money = money / self.balloonRatio
	end	
	local moneyStr = "+"..tools.numberToStrWithComma(money);

    textObj:GetComponentInChildren(typeof(UnityEngine.UI.Text)).text = moneyStr;

	local fontSize = 50;
	local pic_lenth = string.len(moneyStr) * re_Times * fontSize;
	if textObj.localPosition.x + pic_lenth/2 > ZTD.MainScene.MapWidth/2 then
		textObj.localPosition =  Vector3(ZTD.MainScene.MapWidth/2 - pic_lenth/2, textObj.localPosition.y, textObj.localPosition.z);
	elseif textObj.localPosition.x - pic_lenth/2 < -ZTD.MainScene.MapWidth/2 then
		textObj.localPosition = Vector3(-ZTD.MainScene.MapWidth/2 + pic_lenth/2, textObj.localPosition.y, textObj.localPosition.z);
	end	
	
	--[[
	local scale = 0.6;
	local key = ZTD.Extend.RunAction(textObj,{
			{"scaleTo",scale + 0.5, scale + 0.5, scale + 0.5, 0.1},
			{"scaleTo",scale - 0.15, scale - 0.15, scale - 0.15, 0.12},
			{"scaleTo",scale + 0.1, scale + 0.1, scale + 0.1, 0.12},
			{"scaleTo",scale - 0.05, scale - 0.05, scale - 0.05, 0.04},
			{"scaleTo",scale, scale, scale, 0.04},
			{"delay",0.3},
			{"scaleTo",0,0,0,0.4,ease = ZTD.Action.EInBack,delay = 0.2},
			onEnd = function()
				ZTD.PoolManager.RemoveUiItem(self._textPrefab, textObj)
			end 
		})
	--]]
	
	textObj:SetActive(false)
	textObj:SetActive(true)
	
	self._runKey = ZTD.Extend.RunAction(textObj,{
		{"delay",5,
		onEnd = function()
			if self._textObj and self._textObjID then
				self._textObj:SetActive(false)
				ZTD.EffectManager.RemoveEffectByID(self._textObjID)
				self._textObj = nil
				self._textObjID = nil
				ZTD.GoldPlay.RemoveGoldPlayByLua(self)
			end
			
		end}
	})	
	
	self._textObj = textObj
	self._textObjID = textObjID
	
	if not self.isGray then
		textObj:FindChild("ZI/img_r"):SetActive(self.addRatio > 1)
		textObj:FindChild("ZI/img_s"):SetActive(self.addRatio > 1)
		textObj:FindChild("ZI/img_ss"):SetActive(self.GiantHitPower > 1)
		textObj:FindChild("ZI/img_giant"):SetActive(self.GiantHitPower > 1)
		textObj:FindChild("ZI/node_zd"):SetActive(self.balloonRatio > 1)
		
		local fontWidth = string.len(moneyStr) * (46)
		if fontWidth < 120 then
			fontWidth = 120
		end	
		fontWidth = 460 + fontWidth
		textObj:FindChild("ZI/img_s").transform.width = fontWidth
		local cfg = ZTD.ConstConfig[1];
		local sPosX = textObj:FindChild("ZI/img_s").localPosition.x
		local setPos = textObj:FindChild("ZI/img_r").localPosition
		local pos1 = Vector3(sPosX + fontWidth - 87, setPos.y, setPos.z)
		local pos2 = Vector3(sPosX + fontWidth + 43, setPos.y, setPos.z)
		local pos3 = Vector3(sPosX + fontWidth + 163, setPos.y, setPos.z)
		if self.addRatio > 1 and self.addRatio < 5 then
			textObj:FindChild("ZI/img_r"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.addRatio)
			textObj:FindChild("ZI/img_s"):GetComponent("RectTransform"):ForceUpdateRectTransforms()
			textObj:FindChild("ZI/img_r").localPosition = pos1
			if self.GiantHitPower and self.GiantHitPower > 1 then
				textObj:FindChild("ZI/img_giant").localPosition = pos2
				textObj:FindChild("ZI/node_zd").localPosition = pos3
			else
				textObj:FindChild("ZI/node_zd").localPosition = pos2
			end
		else
			textObj:FindChild("ZI/img_r"):SetActive(false)
			if self.GiantHitPower and self.GiantHitPower > 1 then
				textObj:FindChild("ZI/img_giant").localPosition = pos1
				textObj:FindChild("ZI/node_zd").localPosition = pos2
			else
				textObj:FindChild("ZI/node_zd").localPosition = pos1
			end
		end
		if self.GiantHitPower and self.GiantHitPower > 1 then
			textObj:FindChild("ZI/img_giant"):SetActive(true)
			textObj:FindChild("ZI/img_giant"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.GiantHitPower);
		else
			textObj:FindChild("ZI/img_giant"):SetActive(false)
		end
		if self.balloonRatio > 1 and self.balloonRatio < 4 then
			textObj:FindChild("ZI/node_zd/img_rzd"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite(cfg.ResPath, "jb_bj_s" .. self.balloonRatio);
			textObj:FindChild("ZI/node_zd/img_zd"):SetActive(true)
		else
			textObj:FindChild("ZI/node_zd"):SetActive(false)
		end
		textObj:FindChild("ZI/linkImg"):SetActive(self.IsConnect)
	end
end

function TextEffect:CreateSlamText()
    self._textPrefab = "TD_ImageTextEffect";
    local textObj = ZTD.PoolManager.GetUiItem(self._textPrefab, self.parent);
    textObj.localPosition = self.currentPos
    textObj.localScale = Vector3.one*0.01
	local texture = ResMgr.LoadAssetSprite("images", "tubiao-miss_0001")
    textObj:FindChild("image"):GetComponent("Image").sprite = texture
    textObj:FindChild("text"):GetComponent("Text").text = "+" .. tools.numberToStrWithComma(self.earnMoney)
    self._runKey = ZTD.Extend.RunAction(textObj,{--[[{"delay",1},--]]
		{"scaleTo",0.75,0.75,0.75,0.15},
		{"scaleTo",0.4,0.4,0.4,0.08},
       {"delay",1},
       {"spawn",
           {"localMoveBy",40,35,0,0.1},
           {"scaleTo",0.01,0.01,0.01,0.1},
       },

        {        
            function()
				if self.callBack then
					self.callBack()
				end
                ZTD.PoolManager.RemoveUiItem(self._textPrefab, textObj)
				ZTD.GoldPlay.RemoveGoldPlayByLua(self);
            end 
        }
    })
end

function TextEffect:Release()
	ZTD.Extend.StopAction(self._runKey);
	if not self._textObj then
		ZTD.PoolManager.RemoveUiItem(self._textPrefab, self._textObj)
	end
	
end

return TextEffect
