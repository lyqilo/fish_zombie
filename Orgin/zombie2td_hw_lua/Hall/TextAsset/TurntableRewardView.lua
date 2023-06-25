
---------------------------------
-- region TurntableRewardView.lua    -
-- Date: 2019.8.9        -
-- Desc: 奖励结算界面  -
-- Author: Bin        -
---------------------------------

local CC = require("CC")

local TurntableRewardView = CC.uu.ClassView("TurntableRewardView")

--[[
@param:
rewardInfo: 奖励信息
	ConfigId:道具Id
	Count:	数量
rewardType:  奖励类型(普通筹码, Jackpot)
]]
function TurntableRewardView:ctor(param)

	self:InitVar(param);
end

function TurntableRewardView:InitVar(param)

	self.param = param or {}

	self.numberRoller = nil;

	self.rewardType = {
		NORMAL = 1,
		JACKPOT = 2,
	}

	self.musicName = CC.Sound.GetMusicName()
	self:DelayRun(0.1, function()
		CC.Sound.PlayHallBackMusic("TurntableRewardBGM");
	end)
end

function TurntableRewardView:OnCreate()

	self:InitContent();
end

function TurntableRewardView:InitContent()

	-- self.transform:GetComponent("Canvas").sortingLayerName = "sort4"
	-- self.transform:FindChild("Bg"):GetComponent("Canvas").sortingLayerName = "sort4"

	local rewardContent;
	local shareBtn

	-- if self.param.rewardType == self.rewardType.NORMAL then
	-------普通奖励有问题，先屏蔽--------
	-- 	rewardContent = self:FindChild("NormalReward");
	-- 	local tips = CC.LanguageManager.GetLanguage("L_DailyTurntableView").explainTitle;
	-- 	rewardContent:FindChild("Top/TopText").text = tips;
		
	-- elseif self.param.rewardType == self.rewardType.JACKPOT then

		rewardContent = self:FindChild("JackpotReward");
		shareBtn = self:FindChild("JackpotReward/Button")
		shareBtn:FindChild("Text").text = CC.LanguageManager.GetLanguage("L_DailyTurntableView").shareBtn;
	-- end

	rewardContent:SetActive(true);

	local param = {
		parent = rewardContent:FindChild("Content"),
		number = self.param.rewardInfo[1].Count,
		callback = function()
			shareBtn:SetActive(true)
			self:AddClick(shareBtn,"OnClickShareBtn")
			self:AddClick(rewardContent, "ActionOut");
		end
	}
	self.numberRoller = CC.ViewCenter.NumberRoller.new();
	self.numberRoller:Create(param);

	self:RunAction(self.transform, {
			{"delay",0, function() self:FindChild("ChipsEffect"):SetActive(true) end},
			{"delay",0.1, function() CC.Sound.PlayHallEffect("congratulations"); end},
		})
end

function TurntableRewardView:OnClickShareBtn()
	self:FindChild("JackpotReward/Button"):SetActive(false)

	local param = {}
	param.isShowPlayerInfo = true
	-- param.webText = CC.LanguageManager.GetLanguage("L_CaptureScreenShareView").shareContent1
	CC.ViewManager.Open("CaptureScreenShareView", param)
end

function TurntableRewardView:OnDestroy()
	if self.param.callback then
		self.param.callback()
	end
	if self.musicName then
		CC.Sound.PlayHallBackMusic(self.musicName);
	else
		CC.Sound.StopBackMusic();
	end
	if self.numberRoller then

		self.numberRoller:Destroy();
	end
end

return TurntableRewardView;
