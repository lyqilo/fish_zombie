local CC = require("CC")

local MarsTaskRewardsView = CC.uu.ClassView("MarsTaskRewardsView")

-- 一行显示个数
local actionDelay = 0.2			--动画延迟
local actionDelayDelta = 0.1	--动画延迟递增时间
local actionDuration = 0.2		--动画时间

function MarsTaskRewardsView:ctor(param)
	self.param = param or {}
	self.data = param.data
	self.avatars = param.avatars or {}
	self.callback = param.callback
	self.splitState = param.splitState
	self.forceSize = param.forceSize or false

	self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self.language = CC.LanguageManager.GetLanguage("L_MarsTaskView")
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
end

function MarsTaskRewardsView:OnCreate()

	CC.Sound.PlayHallEffect("congratulations")

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
		for i, v in pairs(self.data) do
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
	local avatars = self.avatars
	
	local rewardCount = #items + #avatars

	for _, v in ipairs(items) do
		self:AddItem(v)
	end
	for _, v in ipairs(avatars) do
		self:AddHeadItem(v)
	end
	
	self:AddButtonEvt()
	self:InitTextByLanguage()
end

function MarsTaskRewardsView:InitTextByLanguage()

end


function MarsTaskRewardsView:AddButtonEvt()
	self:AddClick("Layer_Mask", "OnBackBtnClick")
end

function MarsTaskRewardsView:OnBackBtnClick()
	if self.callback then
		self.callback()
	end
	self:Destroy()
end

function MarsTaskRewardsView:InsertItemData(tab, itype, data)
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

function MarsTaskRewardsView:InitQuality(propID,count)
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
function MarsTaskRewardsView:AddItem(data)

	local rewardType = data.ConfigId;
	local rewardAmount = data.Count;
	local crit = data.Crit;
	local quality = self:InitQuality(rewardType,rewardAmount)

	if rewardType == CC.shared_enums_pb.EPC_Experience then
		rewardAmount = rewardAmount / 1000000
	end

	local obj = CC.uu.newObject(self.awardItem, self.layout);
	obj:SetActive(true)

	if quality > 1 then
		obj.transform:FindChild("bg/effect"):SetActive(true)
	end

	local bg = obj.transform:FindChild("bg")
	self:SetImage(bg, "award_4");
	bg:GetComponent("Image"):SetNativeSize()

	obj.transform:FindChild("bg/Num"):GetComponent("Text").text = CC.uu.DiamondFortmat(rewardAmount)
	obj.transform:FindChild("bg/Name"):GetComponent("Text").text = self.propLanguage[rewardType] or ""

    local node = obj.transform:FindChild("bg/Sprite")
	self:SetImage(node, self.propCfg[rewardType].Icon);
	if not self.forceSize then
		node:GetComponent("Image"):SetNativeSize()
	end

	if crit then
		obj.transform:FindChild("bg/Crit"):SetActive(true)
	end
	obj:FindChild("bg"):SetActive(true)
end

function MarsTaskRewardsView:AddHeadItem(data)
	local headId = data.HeadId;
	local amount = data.Count;

	local obj = CC.uu.newObject(self.awardItem, self.layout);
	obj:SetActive(true)

	obj.transform:FindChild("bg/Num"):GetComponent("Text").text = CC.uu.DiamondFortmat(amount)
	obj.transform:FindChild("bg/Name"):GetComponent("Text").text = ""

	local node = obj.transform:FindChild("bg/Sprite")
	self:SetImage(node, string.format("head_p_%03d",headId));
	if not self.forceSize then
		node:GetComponent("Image"):SetNativeSize()
	end
	
	obj:FindChild("bg"):SetActive(true)
end

function MarsTaskRewardsView:OnDestroy()
end

return MarsTaskRewardsView