local CC = require("CC")
local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

----------------------
local EffectPlayerHelper = GC.class2("EffectPlayerHelper")
function EffectPlayerHelper:ctor(_, cfg, root)
	self._cfg = cfg;
	self._startTime = -1;
	self._nowIndex = 1;
	self._actionList = {};
	self._root = root;
	self._nodeMark = {};
end

function EffectPlayerHelper:FindNode(nodeName)
	if nodeName == nil or nodeName == "" then
		return nil;
	end
	
	if self._nodeMark[nodeName] then
		return self._nodeMark[nodeName];
	end
	
	local retNode = self._root:FindChild(nodeName);
	self._nodeMark[nodeName] = retNode;
	return retNode;
end

function EffectPlayerHelper:DoActionData(effData, actionData)
	if self._actionList[actionData] then
		return;
	end
	
	self._actionList[actionData] = true;

	local Node_Eff = self:FindNode(effData.Node_Eff);
	local Node_Bind = self:FindNode(effData.Node_Bind);
	
	Node_Eff.transform.localPosition = Node_Eff.transform.localPosition + actionData.OffsetPos;
	Node_Eff.transform.localRotation = Quaternion.Euler(actionData.Rotation.x, actionData.Rotation.y, actionData.Rotation.z);
	Node_Eff.transform.localScale = actionData.Scale;

	if effData.TypeNode == "Effect" then
		Node_Eff:SetActive(true);
	elseif effData.TypeNode == "Animation" then
		Node_Eff:GetComponent("Animator"):SetTrigger(actionData.StrTrigger);
	end
end	

function EffectPlayerHelper:FixedUpdate(dt)
	if (self._startTime >= 0.0) then
		local dt = Time.fixedDeltaTime;
		self._startTime = self._startTime + dt;

		local isAllAct = true;
		local nowCfg = self._cfg[self._nowIndex];
		
		for _, effData in ipairs(nowCfg) do
			local Node_Eff = self:FindNode(effData.Node_Eff);
			local Node_Bind = self:FindNode(effData.Node_Bind);
			
			for _, ad in ipairs(effData.action_data) do
				if self._startTime >= ad.Time_Start then
					self:DoActionData(effData, ad);
				else
					isAllAct = false;
				end
			end
		end
		
		if isAllAct then
			self._startTime = -1;
			self._actionList = {};
		end
	end
end

function EffectPlayerHelper:PlayGroup(nix)
	local nowCfg = self._cfg[nix];
	if nowCfg == nil then
		logError("Could Not Found Group:" .. nix);
		return;
	end
	self._nowIndex = nix;
	for _, nowCfg in ipairs(self._cfg) do
		for _, effData in ipairs(nowCfg) do	
			local Node_Eff = self:FindNode(effData.Node_Eff);
			if Node_Eff then
				Node_Eff:SetActive(false);	
			else
				logError("lost effData.Node_Eff:" .. effData.Node_Eff)
			end	
		end	
	end	
	
	
	for _, effData in ipairs(nowCfg) do
		local Node_Eff = self:FindNode(effData.Node_Eff);
		Node_Eff:SetActive(effData.IsShow or false);
		local Node_Bind = self:FindNode(effData.Node_Bind);
		if Node_Bind ~= nil then
			Node_Eff.transform.parent = Node_Bind.transform;
			Node_Eff.transform.localPosition = Vector3.zero;
		end		
	end	
	
	self._startTime = 0;
	self._actionList = {};
end	


----------------------

local EP = GC.uu.ClassView("EffectPlayerView")
EP.bundleName = "prefab"
EP.viewName = "EffectPlayerView"

function EP:GlobalNode()
	return GameObject.Find("Main/Canvas/Panel").transform
end

function EP:OnCreate()
	
	self:AddClick(self:FindChild("btn_play"), "Play")
	
	local cfg = require("EffectCfgs/TD_HERO_01_eff_cfg");
	
	
	local t1 = ResMgr.LoadPrefab("prefab", "TD_HERO_01", GameObject.Find("BattleField").transform);
	t1.transform.localPosition = Vector3.zero;
	local t2 = ResMgr.LoadPrefab("prefab", "TD_HERO_01_shifa",  GameObject.Find("BattleField").transform);
	t2.transform.localPosition = Vector3.zero;
	
	local eh = EffectPlayerHelper:new(cfg, GameObject.Find("BattleField").transform);
	ZTD.FixedUpdateAdd(eh.FixedUpdate, eh)
	self._eh = eh;
end

function EP:GlobalLayer()
	return "UI"
end

function EP:Play()
	--logWarn("pppppppppppppppppppppppppp")	
	local inx = tonumber(self:FindChild("if_index/Text").text);
	self._eh:PlayGroup(inx);
end

function EP:Update(deltaTime)
end

function EP.Start()
	GC.EffectPlayerView = EP
	local view = GC.ViewManager.Open("EffectPlayerView")
	
end

return EP;