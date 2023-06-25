local CC = require("CC")

local RewardsView = CC.uu.ClassView("RewardsView")

-- 一行显示个数
local actionDelay = 0.2			--动画延迟
local actionDelayDelta = 0.1	--动画延迟递增时间
local actionDuration = 0.2		--动画时间


---------------------------------
--打开通用奖励弹窗请使用CC.ViewManager.OpenRewardsView(param)
--不要直接调用
---------------------------------
function RewardsView:ctor(param)
	self.param = param or {}
	self.data = param.data
	self.title = param.title or "CommonGet"
	self.callback = param.callback
	self.tips = param.tips
	self.splitState = param.splitState
	self.source = param.source
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

function RewardsView:OnCreate()
	if self.splitState then
		CC.Sound.PlayHallEffect(self.sound or "10Reward")
	else
		CC.Sound.PlayHallEffect(self.sound or "congratulations")
	end

	self.language = self:GetLanguage()

	self._scrollView1 = self:FindChild("Layer_UI/Scroll View")

	self.tipsText = self:FindChild("Layer_UI/Tips");
	self.awardItem = self:FindChild("Layer_UI/AwardItem")
	if self.param.isSpecial then
		self.awardItem = self:FindChild("Layer_UI/SpecialItem")
		self:FindChild("Layer_UI/BG"):SetActive(false)
		self:FindChild("Layer_UI/Top"):SetActive(false)
		self:FindChild("Layer_UI/Effect"):SetActive(false)
		self:FindChild("Layer_UI/SpecialTop"):SetActive(true)
	end

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

	self.rewardCount = #items

	for i, v in ipairs(items) do
		self:AddItem(v, i)
	end

	self:RefreshTips()
	self:LanguageSwitch()
	self:InitViewShow()
	if self.param.AutoTime and type(self.param.AutoTime) == "number" then
		--自动时间关闭奖励界面
		self:DelayRun(self.param.AutoTime, function ()
			self:OnBackBtnClick()
		end)
	end
end

function RewardsView:LanguageSwitch()
	self:FindChild("Layer_UI/Top/TopText").text = self.language[self.title] or self.title
	self:FindChild("Layer_UI/BtnSizeFitter/BtnClose/Text").text = self.language.BtnClose
	self:FindChild("Layer_UI/BtnSizeFitter/BtnComposite/Text").text = self.language.BtnComposite
	self:FindChild("Layer_UI/BtnSizeFitter/BtnCapsule/Text").text = self.language.BtnCapsule
	self:FindChild("Layer_UI/BtnSizeFitter/BtnShare/Text").text = self.language.BtnShare
end

function RewardsView:InitViewShow()
	if self.param.btnText then
		self:FindChild("Layer_UI/BtnSizeFitter/BtnClose/Text").text = self.param.btnText
	end
	if self.param.gameTips then
		self:FindChild("Layer_UI/GameTips").text = self.param.gameTips;
		self:FindChild("Layer_UI/GameTips"):SetActive(true)
	end

	if self.source then
		self:FindChild("Layer_UI/BtnSizeFitter/BtnShare"):SetActive(true)
		self:FindChild("Layer_UI/BtnSizeFitter/BtnShare/Text").text = self.language.BtnShare
	end
	if self.param.composite then
		self:FindChild("Layer_UI/BtnSizeFitter/BtnComposite"):SetActive(true)
		self:FindChild("Layer_UI/BtnSizeFitter/BtnCapsule"):SetActive(true)
	end
end

function RewardsView:AddButtonEvt()
	self:AddClick("Layer_UI/BtnSizeFitter/BtnClose", "OnBackBtnClick")
	self:AddClick("Layer_UI/BtnSizeFitter/BtnShare", "OnShareBtnClick")
	self:AddClick("Layer_UI/BtnSizeFitter/BtnComposite", "OnCompositeBtnClick")
	self:AddClick("Layer_UI/BtnSizeFitter/BtnCapsule", "OnCapsuleBtnClick")
end

function RewardsView:OnBackBtnClick()
	if self.callback then
		self.callback()
	end
	self:Destroy()
end
-- <res=Image:Assets/_GameCenter/_Resources/image/PropIcon/prop_img_10004.png>
function RewardsView:OnShareBtnClick()
	--目前只支持单个奖励分享文本
	local propId = self.data[1].ConfigId;
	local imgPath = self.propCfg[propId].Icon;
	local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image[imgPath] or "image";
	local dirPath = abName ~= "image" and abName.."/".."image" or abName;
	local assetPath = string.format("<res=%s:Assets/_GameCenter/_Resources/%s/PropIcon/%s y=-40>",abName,dirPath,imgPath);
	local shareText2 = string.format(self.language[self.source.."SharePropText2"], assetPath, self.propCfg[propId].Value..self.language.Value);
	local data = {};
	data.bg = self.language[self.source.."ShareBG"]
	data.descTop = self.language[self.source.."SharePropText1"]
	data.descBottom = shareText2;
	data.content = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView").shareContent1
	CC.ViewManager.Open("DailyLotteryShareView",data);
end

function RewardsView:OnCompositeBtnClick()
	--跳转合成界面
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "CompositeView")
	self:Destroy()
end

function RewardsView:OnCapsuleBtnClick()
	--扭蛋
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "ComposeCapsuleView")
	self:Destroy()
end

function RewardsView:InsertItemData(tab, itype, data)
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

function RewardsView:InitQuality(propID,count)
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
function RewardsView:AddItem(data, i)

	local rewardType = data.ConfigId;
	local rewardAmount = data.Count;
	local crit = data.Crit;
	local quality = self:InitQuality(rewardType,rewardAmount)
	if self.propCfg[rewardType].Physical and self.propCfg[rewardType].Delivery == 0 and self.propCfg[rewardType].Type ~= CC.shared_enums_pb.EPT_EWallet then
		self.tipsLevel = 1
	end

	if self.tipsLevel < 0 and self.backCfg[rewardType] then
		self.tipsLevel = 2
	end

	if self.propCfg[rewardType].Physical and self.propCfg[rewardType].Delivery == 0 and self.propCfg[rewardType].Type == 10 then
		self.tipsLevel = 3
	end

	if rewardType == CC.shared_enums_pb.EPC_Experience then
		rewardAmount = rewardAmount / 1000000
	end

	local obj = CC.uu.newObject(self.awardItem, self.layout);
	obj:SetActive(true)

	if quality > 1 then
		--竖屏特效不对，暂时屏蔽
		obj.transform:FindChild("bg/effect"):SetActive(true and not self:IsPortraitScreen())
	end

	local bg = obj.transform:FindChild("bg")
	self:SetImage(bg, "award_"..quality);
	bg:GetComponent("Image"):SetNativeSize()

	local isHcoin = rewardType == CC.shared_enums_pb.EPC_HCoin
    local tempStr = isHcoin and self:FindChild("Layer_UI/HcoinTip/NumTip") or obj.transform:FindChild("bg/Text"):GetComponent("Text")
    tempStr.text = isHcoin and self:HCionNumDeal(rewardAmount) or CC.uu.DiamondFortmat(rewardAmount)
	if rewardType == CC.shared_enums_pb.EPC_No_Award then
		--未中奖道具,不展示数值
		tempStr.text = ""
	end

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

function RewardsView:RefreshTips()
	CC.uu.Log(self.param,"RefreshTips self.param:")
	if self.tipsLevel > 0 then
		if self.tipsLevel == 1 then
			--道具为实物且不需要邮寄(点卡显示底部tips提醒玩家去邮箱查看点卡奖励)
			self.tipsText.text = self.language.PointCard
		elseif self.tipsLevel == 2 then
			self.tipsText.text = self.language.BackPack
		elseif self.tipsLevel == 3 then
			self.tipsText.text = self.language.PointCard_1
		end
		self.tipsText:SetActive(true)
	else
		if self.tips then
			self.tipsText.text = self.tips
		end
	end

	local hoinTip = self:FindChild("Layer_UI/HcoinTip")
	if self.param.timeTip then
		hoinTip:FindChild("TimeTip").text = self.param.timeTip
	end
	if self.param.getTip then
		hoinTip:FindChild("GetTip").text = self.param.getTip
	end
end

function RewardsView:HCionNumDeal(hCoin)
    if hCoin <= 0 then return 0  end
    if hCoin < 100 then
        if hCoin % 10 ~= 0  then
            hCoin = CC.uu.keepDecimal(hCoin/1000000,6,true)
        else
            hCoin = CC.uu.keepDecimal(hCoin/1000000,5,true)
        end
    else
        hCoin = hCoin / 1000000
    end
    local tb = tostring(hCoin):split(".")
    if tb[1] and tb[2] then
        hCoin = CC.uu.numberToStrWithComma(tonumber(tb[1])).."."..tb[2]
    end
    return "x"..hCoin
end

function RewardsView:OnDestroy()
end

return RewardsView