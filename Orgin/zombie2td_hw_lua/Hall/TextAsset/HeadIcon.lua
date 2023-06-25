local CC = require("CC")
local HeadIcon = CC.class2("HeadIcon")

--@param
--parent:挂载的父节点
--playerId:玩家id
--portrait:头像图片索引路径
--showChat:显示聊天按钮
--chatCallback:点击聊天按钮回调
--clickFunc:头像点击方法
--vipLevel:vip等级
--nick:昵称
--unShowVip:不显示vip等级
--headFrame:头像框id
--showFrameEffect:展示头像框特效
--isShowDefault:是否只显示默认白底
--unChangeHeadFrame:是否监听头像框变化

function HeadIcon:Create(param)
	self:InitVar(param)
	self:InitContent()
	self:RegisterEvent()
end

function HeadIcon:InitVar(param)
	self.param = table.copy(param)

	self.personalInfoDefine = CC.DefineCenter.Inst():getConfigDataByKey("PersonalInfoDefine")

	self.headPortraitCfg = CC.ConfigCenter.Inst():getConfigDataByKey("HeadPortrait")

	self.cacheHeadTexture = nil
	if not param.playerId or param.playerId == CC.Player.Inst():GetSelfInfoByKey("Id") then
		--没传玩家id表示自己
		self:GetSelfInfoData()
		self.infoType = self.personalInfoDefine.PersonalInfoMode.Self
	elseif param.playerId == "" then
		self.infoType = self.personalInfoDefine.PersonalInfoMode.Friend
	else
		self.infoType = self.personalInfoDefine.PersonalInfoMode.Stranger
	end

	--是否处于放大状态
	self.scaleIng = false
end

function HeadIcon:GetSelfInfoData()
	if self.param.isShowDefault then
		return
	end
	self.param.vipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	self.param.portrait = CC.Player.Inst():GetSelfInfoByKey("Portrait")
	self.param.playerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	self.param.headFrame = self.param.headFrame or CC.Player.Inst():GetSelfInfoByKey("Background")

	--月卡限时头像框，月卡失效头像框也不能用
	local card1 = CC.Player.Inst():GetSelfInfoByKey("EPC_Super") or 0
	if self.param.headFrame == 3034 and card1 <= 0 then
		self.param.headFrame = 0
		--防止月卡到期玩家还在使用这个头像框，这里直接给设置成默认的
		self:ReqChangeHeadFrame(self.param.headFrame)
	end
end

function HeadIcon:ReqChangeHeadFrame(id)
	CC.Request(
		"ReqSavePlayer",
		{Background = tostring(id)},
		function()
			--本地保存一下头像id
			local selfInfo = CC.Player.Inst():GetSelfInfo()
			selfInfo.Data.Player.Background = id
			--发消息通知头像换icon
			CC.HallNotificationCenter.inst():post(CC.Notifications.ChangeHeadIcon, {headFrame = id})
		end
	)
end

function HeadIcon:InitContent()
	self.transform = CC.uu.LoadHallPrefab("prefab", "HeadIcon", self.param.parent)

	if self.infoType == self.personalInfoDefine.PersonalInfoMode.Self then
		self:RefreshSelfUI()
	else
		self:RefreshOtherUI()
	end
end

function HeadIcon:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnChangeHeadIcon, CC.Notifications.ChangeHeadIcon)

	CC.HallNotificationCenter.inst():register(self, self.OnVipChanged, CC.Notifications.VipChanged)
end

function HeadIcon:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.ChangeHeadIcon)

	CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.VipChanged)
end

function HeadIcon:OnVipChanged(level)
	if self.infoType ~= self.personalInfoDefine.PersonalInfoMode.Self then
		--其他玩家不需要监听道具更改消息
		return
	end
	--刷新vip等级显示
	self.param.vipLevel = level
	self:SetVipLevel(self.param.vipLevel)
end

function HeadIcon:OnChangeHeadIcon(param)
	if self.infoType ~= self.personalInfoDefine.PersonalInfoMode.Self then
		return
	end
	--刷新头像显示
	if param.portrait then
		self.param.portrait = param.portrait
		self:SetHeadImage(self.param.portrait)
	end

	if self.param.unChangeHeadFrame then
		return
	end
	if param.headFrame then
		self.param.headFrame = param.headFrame
		self:SetHeadFrame(self.param.headFrame)
	end
end

function HeadIcon:RefreshSelfUI(param)
	self:Refresh(param)
	--设置头像
	self:SetHeadImage(self.param.portrait)
	--设置头像框
	self:SetHeadFrame(self.param.headFrame)
	--设置vip信息
	self:SetVipLevel(self.param.vipLevel)
	--设置头像点击方法
	self:SetIconClick(self.param.clickFunc)
end

function HeadIcon:RefreshOtherUI(param)
	self:Refresh(param)
	--设置头像
	self:SetHeadImage(self.param.portrait)
	--设置头像框
	self:SetHeadFrame(self.param.headFrame)
	--设置聊天按钮
	self:ShowChat(self.param.showChat)
	--设置vip信息
	self:SetVipLevel(self.param.vipLevel)
	--设置头像点击方法
	self:SetIconClick(self.param.clickFunc)
end

function HeadIcon:Refresh(param)
	if param then
		for k, v in pairs(param) do
			self.param[k] = v
		end
	end
end

function HeadIcon:SetHeadImage(portrait)
	--如果没传portrait字段直接设置默认头像
	if not portrait then
		log("SetHeadImage portrait was null")
		if not self.param.isShowDefault then
			--isShowDefault是否设置默认头像，false默认设置，true不设置显示白底
			self:SetHeadOrgImage()
		end
		return
	else
		log("SetHeadImage portrait = " .. portrait)
	end

	local headIcon = self.transform:FindChild("Mask/Image")
	portrait = portrait == "" and 1 or portrait
	local iconPath = self:GetHeadIconPathById(portrait)
	--本地配置里有就用本地的
	if iconPath then
		self:SetImage(headIcon, iconPath)
		return
	end

	--由于FB返回的头像链接hash值一直变化，所以自己的头像运行时缓存，不存在本地
	if self.infoType == self.personalInfoDefine.PersonalInfoMode.Self then
		local texture = CC.Player.Inst():GetPortraitTexture()
		if texture then
			headIcon:SetImage(texture)
			return
		end
	end

	local code = Util.Md5(tostring(portrait))
	--portrait.GetHashCode()  Util.DeleteDirectory()
	local filepath = Util.userPath .. "Res/HeadTexture/" .. tostring(code) .. ".txt"
	local hasFile = Util.HasFile(filepath)
	local url = nil
	if CC.Platform.isWin32 and (not Application.isEditor) then
		url = hasFile and filepath or portrait
	else
		url = hasFile and "file:///" .. filepath or portrait
	end
	self.downloadReq =
		CC.HttpMgr.GetTexture(
		url,
		function(www)
			--如果头像已被释放就不继续往下执行
			if CC.uu.IsNil(headIcon) then
				return
			end
			self.cacheHeadTexture = www.downloadHandler.texture
			headIcon:SetImage(www.downloadHandler.texture)
			--保存自己的头像数据
			if self.infoType == self.personalInfoDefine.PersonalInfoMode.Self then
				CC.Player.Inst():SetPortraitTexture(www.downloadHandler.texture)
				return
			end
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
		end,
		function()
			--请求超时或其他网络错误就设置默认头像
			self:SetHeadOrgImage()
		end,
		function()
			self.downloadReq = nil
		end,
		5
	)
end

function HeadIcon:SetHeadOrgImage()
	if CC.uu.IsNil(self.transform) then
		return
	end
	local headIcon = self.transform:FindChild("Mask/Image")
	local iconPath = self:GetHeadIconPathById(1)
	self:SetImage(headIcon, iconPath)
end

function HeadIcon:ShowChat(isShow)
	if CC.ChannelMgr.GetTrailStatus() then
		return
	end
	if isShow then
		local btnChat = self.transform:FindChild("ChatIcon")
		if not CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChatPanel") then
			btnChat:SetActive(false)
		else
			btnChat:SetActive(true)
		end
		self:AddClick(btnChat, "OnOpenChatView")
	end
end

function HeadIcon:SetVipLevel(level)
	if not CC.ChannelMgr.GetSwitchByKey("bHasVip") then
		return
	end
	if self.param.unShowVip then
		return
	end
	if not level then
		return
	end
	local level = tonumber(level)
	local vip = self.transform:FindChild("Vip")
	if level > 0 then
		vip:SetActive(true)
		local vipLevel = self.transform:FindChild("Vip/Text")
		vipLevel.text = level
	else
		vip:SetActive(false)
	end
end

function HeadIcon:SetHeadFrame(id)
	local id = id or 0
	if self.param.showFrameEffect then
		if self.headFrameEffect then
			CC.uu.destroyObject(self.headFrameEffect)
			self.headFrameEffect = nil
		end
		if self:CheckHFEffectById(id) then
			self.headFrameEffect = CC.HeadManager.CreateHeadFrame(id, self.transform:FindChild("Frame"))
			self.transform:FindChild("Frame"):GetComponent("Image").enabled = false
			return
		end
	end
	self.transform:FindChild("Frame"):GetComponent("Image").enabled = true
	local headFrame = self.transform:FindChild("Frame")
	local iconPath = self:GetHeadFramePathById(id)
	self:SetImage(headFrame, iconPath)
end

function HeadIcon:SetIconClick(clickFunc)
	local headIcon = self.transform:FindChild("Mask/Image")

	if CC.ChannelMgr.GetTrailStatus() then
		clickFunc = "unClick"
	end

	if not clickFunc then
		self:AddClick(headIcon, "OnOpenInfoView")
		return
	end

	if type(clickFunc) == "string" then
		if clickFunc == "ScaleEffect" then
			self:AddClick(headIcon, "OnScaleEffect")
		elseif clickFunc == "unClick" then
			self:AddClick(
				headIcon,
				function()
				end
			)
		end
	elseif type(clickFunc) == "function" then
		self:AddClick(headIcon, clickFunc)
	end
end

function HeadIcon:SetMaterial(material)
	--self.transform.material = material;
	local headIcon = self.transform:FindChild("Mask/Image")
	headIcon.material = material
end

function HeadIcon:GetHeadIconPathById(id)
	if id == "999" then
		return "tx_system"
	end
	local id = tonumber(id)
	if self.headPortraitCfg.HeadIcon[id] then
		return self.headPortraitCfg.HeadIcon[id].Headportrait
	end
end

function HeadIcon:GetHeadFramePathById(id)
	local id = tonumber(id)
	for _, v in pairs(self.headPortraitCfg.HeadFrame) do
		if v.HeadId == id then
			return v.Image
		end
	end
end

function HeadIcon:CheckHFEffectById(id)
	local id = tonumber(id)
	for _, v in pairs(self.headPortraitCfg.HeadFrame) do
		if v.HeadId == id then
			return v.HasEffect
		end
	end
end

function HeadIcon:OnOpenInfoView()
	local param = {
		playerId = self.param.playerId
	}
	CC.HeadManager.OpenPersonalInfoView(param)
end

function HeadIcon:OnOpenChatView()
	local data = {}
	data.PlayerId = self.param.playerId
	data.Portrait = self.param.portrait
	data.HeadFrame = self.param.headFrame
	data.Nick = self.param.nick
	data.Level = self.param.vipLevel
	CC.ViewManager.ShowChatPanel(data)
	if self.param.chatCallback then
		self.param.chatCallback()
	end
end

function HeadIcon:OnScaleEffect()
	if self.scaleIng then
		self:ResetHeadScale()
		return
	end

	self.scaleIng = true

	self.scaleAction =
		self:RunAction(
		self.transform,
		{
			{"scaleTo", 2, 2, 0.1},
			{
				"delay",
				5,
				function()
					self:ResetHeadScale()
				end
			}
		}
	)
end

function HeadIcon:ResetHeadScale()
	if not self.scaleIng then
		return
	end

	self:StopAction(self.scaleAction)
	self.transform.localScale = Vector3.one
	self.scaleIng = false
	self.scaleAction = nil
end

function HeadIcon:SetImage(childNode, path)
	if CC.uu.isString(childNode) then
		childNode = self.transform:FindChild(childNode)
	end
	CC.uu.SetHallImage(childNode, path)
end

function HeadIcon:Func(funcName)
	return function(...)
		local func = self[funcName]
		if func then
			func(self, ...)
		else
			logError("no func " .. self.viewName .. ":" .. funcName)
		end
	end
end

function HeadIcon:AddClick(node, func, clickSound)
	clickSound = clickSound or "click"

	if CC.uu.isString(func) then
		func = self:Func(func)
	end
	if not node then
		logError("按钮节点不存在")
		return
	end
	--在按下时就播放音效，解决音效延迟问题
	node.onDown = function(obj, eventData)
		CC.Sound.PlayHallEffect(clickSound)
	end

	if node == self.transform then
		node.onClick = function(obj, eventData)
			if eventData.rawPointerPress == eventData.pointerPress then
				func(obj, eventData)
			end
		end
	else
		node.onClick = function(obj, eventData)
			func(obj, eventData)
		end
	end
end

function HeadIcon:RunAction(target, action)
	return CC.Action.RunAction(target, action)
end

function HeadIcon:StopAction(action, bComplete)
	if action then
		action:Kill(bComplete or false)
	end
end

function HeadIcon:Destroy(isDestroyObj)
	self:UnRegisterEvent()

	if self.scaleAction then
		self:StopAction(self.scaleAction)
		self.scaleAction = nil
	end

	if isDestroyObj then
		if self.transform then
			CC.uu.destroyObject(self.transform)
			self.transform = nil
		end
	end

	if self.downloadReq then
		CC.HttpMgr.DisposeByKey(self.downloadReq)
		self.downloadReq = nil
	end

	if self.cacheHeadTexture then
		if self.infoType ~= self.personalInfoDefine.PersonalInfoMode.Self then
			GameObject.Destroy(self.cacheHeadTexture)
			self.cacheHeadTexture = nil
		end
	end
end

return HeadIcon
