local CC = require("CC")

local HeadManager = {}

HeadManager.CreateHeadIcon = function(param)
	local headIcon = CC.ViewCenter.HeadIcon.new()
	headIcon:Create(param)
	return headIcon
end

HeadManager.DestroyHeadIcon = function(headIcon, isDestroyObj)
	headIcon:Destroy(isDestroyObj)
end

HeadManager.OpenPersonalInfoView = function(param)
	if param and param.playerId and param.playerId ~= CC.Player.Inst():GetSelfInfoByKey("Id") then
		CC.uu.Log(param, "HeadManager.OpenPersonalInfoView param = ")
		return CC.ViewManager.Open("OtherPlayerInfoView", param)
	end
	return CC.ViewManager.Open("PersonalInfoView", param)
end

HeadManager.CreateChipCounter = function(param)
	local chipCounter = CC.ViewCenter.ChipCounter.new()
	chipCounter:Create(param)
	return chipCounter
end

HeadManager.DestroyChipCounter = function(chipCounter)
	chipCounter:Destroy()
end

HeadManager.CreateDiamondCounter = function(param)
	local diamondCounter = CC.ViewCenter.DiamondCounter.new()
	diamondCounter:Create(param)
	return diamondCounter
end

HeadManager.DestroyDiamondCounter = function(diamondCounter)
	diamondCounter:Destroy()
end

HeadManager.CreateVIPCounter = function(param)
	local VIPCounter = CC.ViewCenter.VIPCounter.new()
	VIPCounter:Create(param)
	return VIPCounter
end

HeadManager.DestroyVIPCounter = function(VIPCounter)
	VIPCounter:Destroy()
end

HeadManager.CreateIntegralCounter = function(param)
	local integralCounter = CC.ViewCenter.IntegralCounter.new()
	integralCounter:Create(param)
	return integralCounter
end

HeadManager.DestroyIntegralCounter = function(integralCounter)
	integralCounter:Destroy()
end

HeadManager.CreateRoomcardCounter = function(param)
	local roomcardCounter = CC.ViewCenter.RoomcardCounter.new()
	roomcardCounter:Create(param)
	return roomcardCounter
end

HeadManager.DestroyRoomcardCounter = function(roomcardCounter)
	roomcardCounter:Destroy()
end

HeadManager.GetHeadIconPathById = function(id)
	local configData = CC.ConfigCenter.Inst():getConfigDataByKey("HeadPortrait")
	if configData.HeadIcon[tonumber(id)] then
		return configData.HeadIcon[tonumber(id)].Headportrait
	end
end

--@param
--protrait:头像id
--headIcon:头像节点
--playerId:玩家id
HeadManager.SetHeadIcon = function(portrait, headIcon, playerId)
	local isSelf = CC.Player.Inst():GetSelfInfoByKey("Id") == playerId

	if not portrait or portrait == "" then
		portrait = 1
	end
	local iconPath = HeadManager.GetHeadIconPathById(portrait)

	--本地配置里有就用本地的
	if iconPath then
		-- headIcon:SetImage(iconPath);
		CC.uu.SetHallImage(headIcon, iconPath)
		return
	end

	if isSelf then
		local texture = CC.Player.Inst():GetPortraitTexture()
		if texture then
			headIcon:SetImage(texture)
			return
		end
	end

	local code = Util.Md5(tostring(portrait))
	--portrait.GetHashCode()
	local filepath = Util.userPath .. "Res/HeadTexture/" .. tostring(code) .. ".txt"
	local hasFile = Util.HasFile(filepath)
	local url = nil
	if CC.Platform.isWin32 and (not Application.isEditor) then
		url = hasFile and filepath or portrait
	else
		url = hasFile and "file:///" .. filepath or portrait
	end
	local request, co =
		CC.HttpMgr.GetTexture(
		url,
		function(www)
			if not CC.uu.IsNil(headIcon) then
				headIcon:SetImage(www.downloadHandler.texture)
				if hasFile then
					CC.LocalGameData.SaveHeadTextureday(filepath)
				else
					CC.uu.SafeCallFunc(
						function()
							Util.WriteBytes(filepath, www.downloadHandler.data)
							CC.LocalGameData.SaveHeadTexture(filepath)
						end
					)
				end
			end
		end,
		function()
			if not CC.uu.IsNil(headIcon) then
				CC.uu.SetHallImage(headIcon, HeadManager.GetHeadIconPathById(1))
			end
		end,
		nil,
		10
	)
	return request, co
end

HeadManager.SetHeadVipLevel = function(vipLevel, vipNode)
	if not vipNode then
		logError("SetHeadVipLevel, param->vipNode was nil")
		return
	end
	vipLevel = vipLevel or 0
	if vipLevel == 0 then
		vipNode:SetActive(false)
	else
		vipNode:SetActive(true)
		local textNode = vipNode:FindChild("Text")
		textNode.text = vipLevel
	end
end

HeadManager.CreateHeadFrame = function(id, parent)
	if not id or id == 0 then
		return
	end

	local node = CC.uu.LoadHallPrefab("prefab", "HeadFrame" .. id, parent)
	local spine = node:GetComponent("SkeletonGraphic")
	if spine then
		spine.AnimationState.Complete = spine.AnimationState.Complete + function()
				spine.AnimationState:SetAnimation(0, "stand2", true)
			end
	end
	return node
end

return HeadManager
