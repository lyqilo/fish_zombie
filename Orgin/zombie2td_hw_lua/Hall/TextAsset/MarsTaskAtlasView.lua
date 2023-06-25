local CC = require("CC")
local MarsTaskAtlasView = CC.uu.ClassView("MarsTaskAtlasView")
local M = MarsTaskAtlasView

--[[
param
curLevel:当前等级
maxLevel:当前可达到的最高等级
OpenBox:自动打开宝箱 1/2/3
]]
function M:ctor(param)
	self:InitVar(param)
end

function M:InitVar(param)
	self.param = param or {}
    self.language = CC.LanguageManager.GetLanguage("L_MarsTaskView")
	self.curStage = math.ceil(param.maxLevel/10) or 1
	self.marsTaskCfg = CC.ConfigCenter.Inst():getConfigDataByKey("MarsTaskConfig")
	self.headPortraitCfg = CC.ConfigCenter.Inst():getConfigDataByKey("HeadPortrait");
	self.toggleList = {}
end

function M:OnCreate()
    self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()

    self:InitContent()
	self:InitTextByLanguage()
	self:RefreshCardState()
	self.viewCtr:StartRequest()
end

function M:InitContent()
	
	self.rewardItem = self:FindChild("RewardItem")
	self.cardEffect = self:FindChild("Effect_hxrw_fanpai")
	self.boxAnimation = self:FindChild("BoxAnimation")
	
	self.selectPanel = self:FindChild("SelectPanel")
	self.selectGroup = self.selectPanel:FindChild("Scroll View/Viewport/Content")
	self.toggleItem = self.selectPanel:FindChild("ToggleItem")
	self.btnGet = self:FindChild("SelectPanel/BtnGet")
	self.btnGray = self:FindChild("SelectPanel/BtnGray")
	
	self:AddClick(self.btnGet,"OnClickBtnGet")
	self:AddClick(self:FindChild("Close/BtnClose"),"ActionOut")
	self:AddClick(self:FindChild("SelectPanel/Close"),function ()
			CC.Sound.PlayHallEffect("MarsCloseView")
			self.selectPanel:SetActive(false)
		end)
	
	for i=1,3 do
		self:AddClick(self:FindChild(string.format("Frame/Group%d/Final",i)),function ()
			self:OnClickBox(i)
		end)
	end

end

function M:InitTextByLanguage()
	self:FindChild("Bg/Title").text = self.language.atlasTitle
	self:FindChild("Bg/Time").text = string.format(self.language.timeText,self.language.actTime)
	self.btnGet:FindChild("Text").text = self.language.btnGet
	self.btnGray:FindChild("Text").text = self.language.btnGet
	self.selectPanel:FindChild("Bg/Title").text = self.language.selectText
	for i=1,3 do
		self:FindChild(string.format("Frame/Group%d/Final/Bubble/Title/Text",i)).text = self.language.bubbleText
	end
end

function M:RefreshCardState()
	if not self.param.curLevel then self.param.curLevel = 1 end
	if not self.param.maxLevel then self.param.maxLevel = 1 end
	local stage = math.ceil(self.param.curLevel/10)
	local stageMax = Mathf.Clamp(stage*10,0,self.param.maxLevel)
	for i=1,stageMax do
		local group = math.ceil(i/10)
		local index = self:GetIndexByLevel(i)
		local item = self:FindChild(string.format("Frame/Group%d/%d",group,index))
		self:SetImage(item:FindChild("Front/Body"),string.format(self.marsTaskCfg[group].atlasIcon,index))
		item:FindChild("Front/Body"):GetComponent("Image"):SetNativeSize()
		self:DelayRun(0.1*(i-1),function ()
				if i < self.param.curLevel then
					item:GetComponent("Animator"):Play("MarsTaskCardLight")
				else
					item:GetComponent("Animator"):Play("MarsTaskCardMask")
				end
				if i == self.param.maxLevel and self.param.curLevel > 1 then
					self:DelayRun(0.6,function ()
							CC.Sound.PlayHallEffect("MarsHit")
							local groupIdx = math.ceil((self.param.curLevel-1)/10)
							CC.uu.newObject(self.cardEffect, self:FindChild(string.format("Frame/Group%d/%d",groupIdx,self:GetIndexByLevel(self.param.curLevel-1))):FindChild("Front/Effect"))
						end)
				end
			end)
	end
end

function M:RefreshBoxState(data)
	for _,v in ipairs(data) do
		local item = self:FindChild(string.format("Frame/Group%d/Final",v.level))
		item:FindChild("Box"):SetActive(v.status==0)
		item:FindChild("BoxOpen"):SetActive(v.status==1)
		item:FindChild("BoxGet"):SetActive(v.status==2)
		self:RefreshBoxReward(item:FindChild("Bubble"),v.RewardsList,v.AvatarIDs)
	end
end

function M:RefreshBoxReward(parent,props,avatar)
	for i = parent.childCount - 1,0,-1 do
		local name = parent:GetChild(i).transform.name
		if name ~= "Title" then
			GameObject.Destroy(parent:GetChild(i).gameObject)
		end
	end
	for _,v in ipairs(props) do
		local item = CC.uu.newObject(self.rewardItem, parent)
		if self:CheckHFEffectById(v.PropID) then
			CC.HeadManager.CreateHeadFrame(v.PropID, item:FindChild("Icon"));
			item:FindChild("Icon"):GetComponent("Image").enabled = false
		else
			self:SetImage(item:FindChild("Icon"),"prop_img_"..v.PropID)
			item:FindChild("Icon"):GetComponent("Image"):SetNativeSize()
		end
		item:SetActive(true)
	end
	for _,v in ipairs(avatar) do
		local item = CC.uu.newObject(self.rewardItem, parent)
		self:SetImage(item:FindChild("Icon"),"head_p_"..v)
		item:FindChild("Icon"):GetComponent("Image"):SetNativeSize()
		item:SetActive(true)
	end
end

function M:OnClickBox(index)
	if index > self.curStage then return end
	if self.viewCtr.boxData[index] then
		local data = self.viewCtr.boxData[index]
		if data.status == 0 then
			local bubble = self:FindChild(string.format("Frame/Group%d/Final/Bubble",index))
			bubble:SetActive(not bubble.activeSelf)
		elseif data.status == 2 then
			self:ShowAvatarSelectPanel(index)
		end
	end
end

function M:OnClickBtnGet()
	local level = self.selectLevel
	local avatarId = self.selectedId
	self.viewCtr:ReqReceiveLevelAward(level,avatarId)
end

function M:OnToggleChange()
	local selected = false
	for _,v in ipairs(self.toggleList) do
		local isOn = v:GetComponent("Toggle").isOn
		selected = selected or isOn
	end
	self.btnGet:SetActive(selected)
	self.btnGray:SetActive(not selected)
end

function M:ShowAvatarSelectPanel(level)
	self.selectLevel = level
	
	for i = self.selectGroup.childCount - 1,0,-1 do
		GameObject.Destroy(self.selectGroup:GetChild(i).gameObject)
	end
	self.toggleList = {}
	local avatars = self.viewCtr.boxData[level].AvatarIDs
	for _,v in ipairs(avatars) do
		if not self.viewCtr.hasAvatar[v] then
			local toggle = CC.uu.newObject(self.toggleItem, self.selectGroup)
			self:SetImage(toggle:FindChild("Icon"),"head_p_"..v)
			toggle:FindChild("Icon"):GetComponent("Image"):SetNativeSize()
			toggle:SetActive(true)
			table.insert(self.toggleList,toggle)
			UIEvent.AddToggleValueChange(toggle,function (selected)
					self:OnToggleChange()
					if selected then
						self.selectedId = v
					end
				end)
		end
	end
	self:OnToggleChange()
	CC.Sound.PlayHallEffect("MarsOpenView")
	self.selectPanel:SetActive(true)
end

function M:ShowBoxAnimation()
	self.boxAnimation:SetActive(false)
	self.boxAnimation:SetActive(true)
	CC.Sound.PlayHallEffect("MarsBoxOpen")
end

function M:CheckHFEffectById(id)
	local id = tonumber(id);
	for _,v in pairs(self.headPortraitCfg.HeadFrame) do
		if v.HeadId == id then
			return v.HasEffect;
		end
	end
end

function M:GetIndexByLevel(level)
	return level%10~= 0 and level%10 or 10
end

function M:ActionIn()
	CC.Sound.PlayHallEffect("MarsOpenView")
	self:SetCanClick(false);
	self:RunAction(self.transform, {"spawn",
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.2},
			{"scaleTo",1,0,0},
			{"scaleTo",1,1,0.2, function() self:SetCanClick(true) end}
		});
end

function M:ActionOut()
	CC.Sound.PlayHallEffect("MarsCloseView")
	self:SetCanClick(false);
	self:RunAction(self.transform, {"spawn",
			{"fadeToAll", 0, 0.2},
			{"scaleTo",1,0,0.2, function() self:Destroy() end}
		});

end

function M:OnDestroy()
	
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end

end

return MarsTaskAtlasView