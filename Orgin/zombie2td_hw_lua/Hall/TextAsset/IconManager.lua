local CC = require("CC")
local IconManager = {}

--Elephant 大象入口按钮
IconManager.CreateIcon = function (iconType, param)
    local icon = nil
    if iconType == "Elephant" then
        icon = CC.ViewCenter.ElephantIcon.new()
	elseif iconType == "WaterIcon" then
		if CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("PhysicalLock") then
			icon = CC.ViewCenter.WaterIcon.new()
		end
    end
	if icon then
        icon:Create(param)
    end
	return icon
end

--入场特效
local effectList = {[3011] = false, [3012] = false, [3013] = false, [3014] = false, [3015] = false,
	                [3018] = false, [3019] = false, [3020] = false, [3021] = false, [3022] = false,
				    [3025] = false, [3026] = false, [3027] = false, [3028] = false, [3029] = false,
					[3054] = true,	[3055] = true,	[3056] = true,	[3059] = true,	[3060] = true,
					[3061] = true,	[4020] = true,	[4021] = true, 	[4022] = true,	}

IconManager.CreateEntryEffect = function(effectId, parent, content)
	if not effectId or effectId == 0 or not effectList[effectId] then return end

    local node = CC.uu.LoadHallPrefab("prefab", "EntryEffect"..effectId, parent);
	if not node then return end
	if content then
		node:FindChild(string.format("%s/Text", effectId)).text = content
	end
	parent.transform:SetAsLastSibling()
    -- local spine = node:FindChild("SkeletonGraphic"):GetComponent("SkeletonGraphic");
    -- if spine then
    --     spine.AnimationState.Complete = spine.AnimationState.Complete + function() spine.AnimationState:ClearTracks()  end
    -- end
	-- --获取上层挂载的canvas组件,得到sortLayer和orderLayer
	-- local canvas = CC.uu.GetCanvas(node);
	-- --设置整个预制体层级与canvas层级一致
	-- local transforms = node:GetComponentsInChildren(typeof(UnityEngine.Transform));
	-- if transforms  then
	-- 	for i = 0, transforms.Length-1 do
	-- 		transforms[i].gameObject.layer = canvas.transform.gameObject.layer;
	-- 	end
	-- end
	-- --获取子节点下的粒子组件并设置orderLayer
	-- local particleComps = node:GetComponentsInChildren(typeof(UnityEngine.ParticleSystemRenderer));
	-- if particleComps then
	-- 	for i = 0, particleComps.Length-1 do
	-- 		particleComps[i].sortingLayerName = canvas.sortingLayerName;
	-- 		particleComps[i].sortingOrder = canvas.sortingOrder + 1;
	-- 	end
	-- end
    return node;
end

IconManager.DestroyIcon = function (icon)
	icon:Destroy()
end

IconManager.CreateMarsTaskIcon = function (param)
	local icon = CC.ViewCenter.MarsTaskIcon.new()
	icon:Init("MarsTaskIcon", param.parent, param)
	return icon
end

return IconManager