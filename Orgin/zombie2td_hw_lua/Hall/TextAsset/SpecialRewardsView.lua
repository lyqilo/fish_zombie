local CC = require("CC")
local SpecialRewardsView = CC.uu.ClassView("SpecialRewardsView")

local actionDelay = 0.2			--动画延迟
local actionDelayDelta = 0.1	--动画延迟递增时间
local actionDuration = 0.2		--动画时间


---------------------------------
--打开通用奖励弹窗请使用CC.ViewManager.OpenRewardsView(param)
--不要直接调用
---------------------------------
function SpecialRewardsView:ctor(param)
	self.data = param.items or {}
    self.callback = param.callback
    self.entryEffect = 1
    self.entryEffectList = {CC.shared_enums_pb.EPC_Avatar_Effect_11, CC.shared_enums_pb.EPC_Avatar_Effect_12, CC.shared_enums_pb.EPC_Avatar_Effect_13,
    CC.shared_enums_pb.EPC_Avatar_Effect_14, CC.shared_enums_pb.EPC_Avatar_Effect_15}

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.roleList = {}
	self.curTaskId = param.curTaskId or 1
	self.taskList = {1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3}
	self.towerLv = param.towerLv or 1
end

function SpecialRewardsView:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_RewardsView")

	self._scrollView1 = self:FindChild("Layer_UI/Scroll View")
	self.content1 = self:FindChild("Layer_UI/Scroll View/Viewport/Content")
	self.awardItem = self:FindChild("Layer_UI/AwardItem")

	--spin
	--for i = 1, 3 do
		--local index = i
		--self.roleList[index] = self:FindChild(string.format("Effect_Special/Role/%s", index)):GetComponent("SkeletonAnimation")
	--end
    --奖励有入场特效
    --for _, v in ipairs(self.data) do
        --for i = 1, #self.entryEffectList do
            --if v.ConfigId == self.entryEffectList[i] then
                --self.entryEffect = v.ConfigId
                --break
            --end
        --end
    --end
	self:FindChild("Layer_UI"):SetActive(false)
	self:FindChild("Effect_Sand"):SetActive(true)
	--self:FindChild(string.format("Effect_Special/BianPao/BP%s", self.entryEffect)):SetActive(true)
	--local curIndex = self.taskList[self.curTaskId]
	--self.roleList[curIndex]:SetActive(true)
	--self:DelayRun(1, function ()
		--CC.Sound.PlayHallEffect("sprinkle_water")
	--end)
	--self:DelayRun(2, function ()
		--local spinIndex = curIndex
		--if self.curTaskId == 3 or self.curTaskId == 9 then
			----进度3和9会改变spin
			--self.roleList[curIndex]:SetActive(false)
			--self.roleList[curIndex + 1]:SetActive(true)
			--spinIndex = curIndex + 1
		--end
		--self.Spin = self.roleList[spinIndex]
		--if self.Spin.AnimationState then
			--self.Spin.AnimationState:ClearTracks()
			--self.Spin.AnimationState:SetAnimation(0, "hit", false)
			--CC.Sound.PlayHallEffect("JPM_voice_hit")
			--self.Spin.AnimationState.Complete = self.Spin.AnimationState.Complete + function()
				--self.Spin.AnimationState:SetAnimation(0, "stand", true)
			--end
		--end
	--end)
	self:DelayRun(3,function ()
			local lv = self.towerLv <= 7 and self.towerLv or 7
			self:FindChild("Effect_Sand/Tower/"..lv):SetActive(true)
		end)
	self:DelayRun(4.5, function ()
		--if self.Spin.AnimationState then
			--self.Spin.AnimationState:ClearTracks()
		--end
		CC.Sound.StopEffect()
		CC.Sound.PlayHallEffect("congratulations")
        self:FindChild("Layer_UI"):SetActive(true)
        self:FindChild("Effect_Sand"):SetActive(false)
		self.rewardCount = #self.data
        for i, v in ipairs(self.data) do
            self:AddItem(v, i)
        end
	end)

	self:InitTextByLanguage()
end

function SpecialRewardsView:InitTextByLanguage()
	self:FindChild("Layer_UI/Tips").text = self.language.SpecialRewardsTips
	self:FindChild("Layer_UI/BtnSizeFitter/BtnShare/Text").text = self.language.BtnShare
end

function SpecialRewardsView:AddButtonEvt()
	self:AddClick("Layer_UI/BtnClose", "OnBackBtnClick")
end

function SpecialRewardsView:OnBackBtnClick()
	if self.callback then
		self.callback()
	end
	self:Destroy()
end

function SpecialRewardsView:InitQuality(propID,count)
	if propID == CC.shared_enums_pb.EPC_ChouMa then
		if count < 10000 then
			return 1
		elseif count < 999999 then
			return 2
		else
			return 3
		end
	else
		return self.propCfg[propID].Quality
	end
end

--[[
#rewardType
EPC_ChouMa: 2
]]
function SpecialRewardsView:AddItem(data, i)
	local rewardType = data.ConfigId;
	local rewardAmount = data.Count;
	local quality = self:InitQuality(rewardType,rewardAmount)

	local obj = CC.uu.newObject(self.awardItem, self.content1);
	obj:SetActive(true)

	if quality > 1 then
		obj.transform:FindChild("bg/effect"):SetActive(true)
	end

	local bg = obj.transform:FindChild("bg")
	self:SetImage(bg, "award_"..quality);
	bg:GetComponent("Image"):SetNativeSize()

    local tempStr = obj.transform:FindChild("bg/Text"):GetComponent("Text")
    tempStr.text = CC.uu.DiamondFortmat(rewardAmount)

    local node = obj.transform:FindChild("bg/Sprite")
    self:SetImage(node, self.propCfg[rewardType].Icon);
	node:GetComponent("Image"):SetNativeSize()

	CC.uu.DelayRun(0.1 *(i-1),function ()
		obj:FindChild("bg"):SetActive(true);
	end)

	local delay = actionDelay + i * actionDelayDelta
	self:DelayRun(delay, function ()
		--最后一个动画播放完后，绑定UI事件
		self:RunAction(obj, {"scaleTo", 1, 1, actionDuration, function ()
			if i == self.rewardCount then
				self:AddButtonEvt()
			end
		end})
	end)
end

function SpecialRewardsView:OnDestroy()
	self.Spin = nil
end

return SpecialRewardsView