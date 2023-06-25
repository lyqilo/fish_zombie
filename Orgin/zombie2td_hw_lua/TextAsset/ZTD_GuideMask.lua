local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local GuideMask = GC.class2("GuideMask")

function GuideMask:Init(guideId, bindView, bindNode, isReqStep, onFinsh)
	-- 防止重复
	if ZTD.GuideData.GetNowGuide(guideId) then
		return false;
	end	
	
	self._node = ZTD.PoolManager.GetUiItem("ZTD_NodeGuideMask", bindNode);
	
	local guideCfg = ZTD.GuideConfig[guideId];
	
	ZTD.GuideData.SetNowGuide(guideId, true);
	
	self._guideCfg = guideCfg;
	self._isReqStep = isReqStep;
	self._guideId = guideId;
	self._onFinshCb = onFinsh;
	self._txt_guide = self._node:FindChild("GuideMaskView/border/text");
	local tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self._node:FindChild("GuideMaskView/border/text").text = tipLanguage.txt_guide_border

	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_GuideConfig");
	self._txt_guide.text = language[guideId].gText;
	
	local finshCondition = guideCfg.finshCondition;
	if type(finshCondition) == "string" then
		if finshCondition == "Click" then
			self._finshCondition = 1;
			-- todo
		elseif finshCondition == "Show" then
			self._finshCondition = 0;
			self:_reqFinsh();
		else
			self._finshCondition = 1;
			ZTD.Notification.GameRegister(self, finshCondition, self.GuideFinsh);
		end	
	end
		
	self._eff_halo = self._node:FindChild("GuideMaskView/Effect_UI_xsyd_guangquan");
	
	local scale = guideCfg.haloScale or 1.0;
	self._eff_halo.localScale = Vector3(scale, scale, 1);
	self._eff_halo:SetActive(false);
	self._eff_halo:SetActive(true);
	
	self._btn_guide = self._node:FindChild("GuideMaskView/Effect_UI_xsyd_guangquan/ButtonGuide");
	local setPos = guideCfg.pos;
	
	if type(setPos) == "string" then
		local uiPos;
		if setPos == "HeroPos" then
			local heroPos = bindView:FindFreeHeroPos();
			uiPos = ZTD.MainScene.SetupPos2UiPos(heroPos._node_summon.position);
		else
			uiPos = bindView:FindChild(setPos).position;
		end
		
		local guideRender = self._node:FindChild("GuideMaskView"):GetComponent("Image");
		local inputPos = Vector4.New(uiPos.x, uiPos.y, 0, 0);
		guideRender.material:SetVector("Center", inputPos);	
		self._eff_halo.position = uiPos;
		self._btn_guide.position = uiPos;		
		
 		local arrow = self._node:FindChild("GuideMaskView/Arrow");
		local border = self._node:FindChild("GuideMaskView/border");

		arrow:SetActive(not (language[guideId].gText == nil));
		border:SetActive(not (language[guideId].gText == nil));
		
		local arrowDir;
		if guideCfg.arrowDir then
			arrowDir = guideCfg.arrowDir;
		elseif self._eff_halo.localPosition.y < -70 then
			arrowDir = 0;
		elseif self._eff_halo.localPosition.x < 0 then
			arrowDir = 3;
		elseif self._eff_halo.localPosition.x > 0 then
			arrowDir = 2;
		end	
		
		
		if arrowDir == 0 then
			arrow.localRotation = Quaternion.Euler(0, 0, 90);
			-- 光圈半径是140，距离定位40
			arrow.localPosition = Vector3(self._eff_halo.localPosition.x + 10,
											self._eff_halo.localPosition.y + 140 * scale + 40, 0);

			
			border.localPosition = Vector3(arrow.localPosition.x,
											arrow.localPosition.y + 78, 0);
		elseif arrowDir == 3 then
			arrow.localRotation = Quaternion.Euler(0, 0, 0);
			-- 光圈半径是140，距离定位40
			arrow.localPosition = Vector3(self._eff_halo.localPosition.x + 140 * scale + 30,
											self._eff_halo.localPosition.y - 11, 0);

			
			border.localPosition = Vector3(arrow.localPosition.x + 137,
											arrow.localPosition.y + 8, 0);	
		elseif arrowDir == 2 then
			arrow.localRotation = Quaternion.Euler(0, 0, 180);
			-- 光圈半径是140，距离定位40
			arrow.localPosition = Vector3(self._eff_halo.localPosition.x - 140 * scale - 30,
											self._eff_halo.localPosition.y + 11, 0);

			
			border.localPosition = Vector3(arrow.localPosition.x - 130,
											arrow.localPosition.y - 11, 0);			
		end
	end	
	
	local addClick = guideCfg.addClick;
    bindView:AddClick(self._btn_guide, function()
		ZTD.Notification.GameUnregisterAll(self);
		
		self:GuideFinsh();
		
		--self._robotClkCb = function()
			if type(addClick) == "string" then
				if addClick == "HeroPos" then
					local heroPos = bindView:FindFreeHeroPos();
					heroPos:DoClick();
				else
					bindView:DoClickByNode(addClick);
				end
			end		
		--end
	
		
    end)
	
	return true;
end

function GuideMask:_reqFinsh()
	if self._isReqStep then
		local function succCb(err,data)
			ZTD.GuideData.FinshGuide(self._guideCfg.step);
		end
		
		local errCb = function(err,data)
			logError("_______CSSetTowerStepReq Error:"..err)
		end
		
		ZTD.Request.CSSetTowerStepReq({GuideStep = self._guideCfg.step, IsFinsh = true}, succCb, errCb);
	end
end	

function GuideMask:GuideFinsh()
	ZTD.GuideData.SetNowGuide(self._guideId, nil);
	
	self._onFinshCb();
		
	if self._finshCondition == 1 then
		self:_reqFinsh();
	end
	
	ZTD.Notification.GameUnregisterAll(self);
	ZTD.PoolManager.RemoveUiItem("ZTD_NodeGuideMask", self._node);
end

return GuideMask