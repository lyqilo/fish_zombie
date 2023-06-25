local CC = require("CC")

local AnniversaryRewardsView = CC.uu.ClassView("AnniversaryRewardsView")

-- 一行显示个数
local actionDelay = 0.2			--动画延迟
local actionDelayDelta = 0.1	--动画延迟递增时间
local actionDuration = 0.2		--动画时间
local outlineColor = {
	Color(56/255,82/255,130/255,1),
	Color(116/255,32/255,132/255,1),
	Color(151/255,23/255,46/255,1),
}

function AnniversaryRewardsView:ctor(param)
	self.param = param or {}
	self.data = param.data
	self.title = param.title or "title"
	self.callback = param.callback
	self.tips = param.tips
	self.splitState = param.splitState
	self.sound = param.sound
	self.forceSize = param.forceSize or false

	--Tips级别
	--	-1	无显示
	--	1	点卡
	--	2	背包道具
	self.tipsLevel = -1

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.backCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Backpack")
end

function AnniversaryRewardsView:OnCreate()
	if self.splitState then
		CC.Sound.PlayHallEffect(self.sound or "10Reward")
	else
		CC.Sound.PlayHallEffect(self.sound or "congratulations")
	end

	self.language = CC.LanguageManager.GetLanguage("L_AnniversaryTurntableView");

	self._scrollView1 = self:FindChild("Layer_UI/Scroll View")

	self.tipsText = self:FindChild("Layer_UI/Tips");
	self.awardItem = self:FindChild("Layer_UI/AwardItem")

	self.layout = self:FindChild("Layer_UI/Scroll View/Viewport/Content")

	--合并同类型的物品数量
	local items = nil
	if self.splitState then
		--排序
		local function _sort(a,b)
			local r
			local aLevel = self:InitQuality(a.ConfigId,a.Count)
			local bLevel = self:InitQuality(b.ConfigId,b.Count)
			r = aLevel > bLevel
			return r
		end
		table.sort(self.data,_sort)
		items = self.data
	else
		local rewards = {}
		for i, v in ipairs(self.data) do
			if v.Count > 0 then
				if rewards[v.ConfigId] then
					rewards[v.ConfigId].Count = rewards[v.ConfigId].Count + v.Count
					if v.Crit then
						rewards[v.ConfigId].Crit = v.Crit
					end
				else
					rewards[v.ConfigId] = {}
					rewards[v.ConfigId].Count = v.Count;
					rewards[v.ConfigId].Crit = v.Crit
				end
			end
		end
		items = {}
		for k, v in pairs(rewards) do
			self:InsertItemData(items, k, v)
		end
	end

	self.rewardCount = #items

	for i, v in ipairs(items) do
		self:AddItem(v, i)
	end

	self:LanguageSwitch()
end

function AnniversaryRewardsView:LanguageSwitch()
	self:FindChild("Layer_UI/Top/TopText").text = self.language[self.title] or self.title
	self.tipsText.text = self.tips or self.language.closeText
end

function AnniversaryRewardsView:AddButtonEvt()
	self:AddClick("Layer_Mask", "OnBackBtnClick")
end

function AnniversaryRewardsView:OnBackBtnClick()
	if self.callback then
		self.callback()
	end
	self:Destroy()
end

function AnniversaryRewardsView:InsertItemData(tab, itype, data)
	local amount = data.Count
	local crit = data.Crit
	local item = {}
	if self.propCfg[itype] and self.propCfg[itype].IsReward then
		item.ConfigId = itype
		item.Count = amount
		item.Crit = crit
		table.insert(tab, item)
	end
end

function AnniversaryRewardsView:InitQuality(propID,count)
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
EPC_Speaker: 7
]]
function AnniversaryRewardsView:AddItem(data, i)

	local rewardType = data.ConfigId;
	local rewardAmount = data.Count;
	local crit = data.Crit;
	local quality = self:InitQuality(rewardType,rewardAmount)
	if self.propCfg[rewardType].Physical and self.propCfg[rewardType].Delivery == 0 then
		self.tipsLevel = 1
	end

	if self.tipsLevel < 0 and self.backCfg[rewardType] then
		self.tipsLevel = 2
	end

	if rewardType == CC.shared_enums_pb.EPC_Experience then
		rewardAmount = rewardAmount / 1000000
	end

	local obj = CC.uu.newObject(self.awardItem, self.layout);
	obj:SetActive(true)

	if quality > 1 then
		obj.transform:FindChild("bg/effect"):SetActive(true)
	end

	local bg = obj.transform:FindChild("bg")
	self:SetImage(bg, "award_"..quality);
	bg:GetComponent("Image"):SetNativeSize()

	local tempStr = obj.transform:FindChild("bg/Text"):GetComponent("Text")
	local outline = obj.transform:FindChild("bg/Text"):GetComponent("Outline")
	if outlineColor[quality] then
		outline.effectColor = outlineColor[quality]
	end
	tempStr.text = CC.uu.DiamondFortmat(rewardAmount)

	local node = obj.transform:FindChild("bg/Sprite")
	self:SetImage(node, self.propCfg[rewardType].Icon);
	if not self.forceSize then
		node:GetComponent("Image"):SetNativeSize()
	end

	if crit then
		obj.transform:FindChild("bg/Crit"):SetActive(true)
	end

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

function AnniversaryRewardsView:OnDestroy()
end

return AnniversaryRewardsView