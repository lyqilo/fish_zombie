local CC = require("CC")
local BaseClass = CC.uu.ClassView("AchievementGiftView")

function BaseClass:ctor(param)
	self.param = param or {}
	self.delayCo = nil
end

function BaseClass:DontDestroyGlobalNode()
	return GameObject.Find("DontDestroyGNode/GCanvas/GMain").transform
end

function BaseClass:OnCreate()
	-- self:AddToDontDestroyNode()

	-- if self.param.parent then
	-- 	self.transform:SetParent(self.param.parent,false)
	-- 	local layer = self.param.parent.transform.gameObject.layer
	-- 	self.transform.gameObject.layer = layer
	-- 	local transforms = self.transform:GetComponentsInChildren(typeof(UnityEngine.Transform));
	-- 	if transforms then
	-- 		for i = 0, transforms.Length-1 do
	-- 			transforms[i].gameObject.layer = layer
	-- 		end
	-- 	end
	-- end

	self.transform:SetParent(self:DontDestroyGlobalNode(),false)

	self.iconTr = self:FindChild("Effect_XSCJ_LiBao01")
	self.guangEff = self:FindChild("Effect_XSCJ_LiBao01/guang")

	-- self.iconTr:SetActive(true)

	-- self:AddClick(self.iconTr,function ()
	-- 	self:CancelDelayRun(self.delayCo)
	-- 	CC.ViewManager.Open("AchievementGiftMainView",{isOpenGift = true})
	-- 	if self.param.closeFunc then
	-- 		self.param.closeFunc()
	-- 	end
	-- end)

	-- local target = self.param.target
	-- if target and type(target) == "table" and target.isClassObject then
	-- 	target = target.transform
	-- end
	-- if target then
	-- 	self.parentPos = target.position
	-- end

	self.targetScreenPoint = self.param.targetScreenPoint

	self.delayCo = self:DelayRun(2, function ()
		self:PlayMoveToIcon()
	end)
end

function BaseClass:PlayMoveToIcon()
	-- self:SetCanClick(false)

	if self.targetScreenPoint then
		self.guangEff:SetActive(false)
		
		-- local v1 = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:GlobalCamera(),self.parentPos)
		local v1 = self.targetScreenPoint
		local v2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:GlobalCamera(),self.iconTr.position)
		local dis = v1 - v2

		local x = self.iconTr.localPosition.x + dis.x * (1.0*self:DontDestroyGlobalNode().rect.width/Screen.width) + 1
		local y = self.iconTr.localPosition.y + dis.y * (1.0*self:DontDestroyGlobalNode().rect.height/Screen.height) + 17.4

		-- self:RunAction(self.iconTr, {"localMoveTo", x, y, 1, ease = CC.Action.EOutCubic, function ()
		-- 	if self.param.closeFunc then
		-- 		self.param.closeFunc()
		-- 	end
		-- end})

		-- scale 0.23
		self:RunAction(self.iconTr, 
			{
				"spawn", 
				{"localMoveTo", x, y , 1, ease = CC.Action.EOutCubic}, 
				{"scaleTo", 0.23, 0.23, 1, ease = CC.Action.EOutCubic,
					function ()
						if self.param.closeFunc then
							self.param.closeFunc()
						end
					end
				},
			})
	else
		if self.param.closeFunc then
			self.param.closeFunc()
		end
	end
end

return BaseClass