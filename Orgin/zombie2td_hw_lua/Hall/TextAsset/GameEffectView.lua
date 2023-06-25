
--progressPath:进度条图片挂载的子节点名
--transOffset:用来实现进度条滚动对准特效字切换
local bigWinCfg = {
	[1] = {
		name = "bigWin",
		step = {
			{duration = 6, progressPath = "progress_blue", transOffset = 0},
		}
	},
	[2] = {
		name = "megaWin",
		step = {
			{duration = 6, progressPath = "progress_blue", transOffset = -0.35},
			{duration = 9, progressPath = "progress_green", transOffset = 0.35},
		}
	},
	[3] = {
		name = "massiveWin",
		step = {
			{duration = 6, progressPath = "progress_blue", transOffset = -0.35},
			{duration = 9, progressPath = "progress_green", transOffset = -0.35},
			{duration = 15, progressPath = "progress_red", transOffset = 0.7},
		}
	},
}


local CC = require("CC")
local GameEffectView = CC.uu.ClassView("GameEffectView")

function GameEffectView:OnCreate()

	self:InitVar();

	self:InitContent();
end

function GameEffectView:InitVar()
	--缓存传入参数
	self.params = nil;
	--缓存特效配置
	self.effectCfg = nil;
	--跳转结束
	self.isTurningToFinish = false;
	--是否正在播放特效
	self.isPlayingEffect = false;
	--等待多久跳过wineffect
	self.nWaitTimeForWin = 0
	-- 是否是分享的调用
	self.isShareCall = false
	self.language = self:GetLanguage()
end

function GameEffectView:InitContent()

	self.bgMask = self:FindChild("bgMask");
	self.bgMask:SetActive(false);

	self.skipBtn = self:FindChild("SkipButton");
	self:AddClick(self.skipBtn, function()
			self:TurnToFinish();
		end)

	self.shareBtn = self:FindChild("ShareButton");
	self:AddClick(self.shareBtn, function()
		self:OnClickShareBtn(self.params);
	end)

	self.closeBtn = self:FindChild("CloseButton");
	self:AddClick(self.closeBtn, function()
		self:OnClickCloseBtn();
	end)

	self.tipText = self:FindChild("tipText")
	self.topSharePanel = self:FindChild("TopSharePanel")
	self:SetText("ShareButton/Text", self.language.share)

	--bonusWin特效节点
	self.bonusEffect = self:FindChild("bonusWinEffect");
	self.bonusEffect:SetActive(false);
	--freeSpin特效节点
	self.freeSpinsEffect = self:FindChild("freeSpinsEffect");
	self.freeSpinsEffect:SetActive(false);
	--bigWin特效节点
	self.winEffect = self:FindChild("bigWinEffect");
	self.winEffect:SetActive(false);
	--bigWin动画控制器
	self.animator = self.winEffect:GetComponent("Animator");
	--进度条
	self.progressFrame = self.winEffect:FindChild("progressFrame"):GetComponent("Image");
	--底部粒子特效
	self.bottomParticle = self:FindChild("bottomParticle");
	self.bottomParticle:SetActive(false);
	self:FadeCrossObject({parent = self.bottomParticle, textureAlpha = 0, particleAlpha = 0, duration = 0});
end

--params
--winMoney:获奖数额
--duration:特效显示时长
--callback:特效结束回调
function GameEffectView:PlayBonusEffect(params)
	if not params or not params.winMoney then
		logError("error params");
		return
	end

	if self.isPlayingEffect then
		return
	end

	self:StopAllAction();

	local duration = params.duration or 30;

	self.isPlayingEffect = true;

	self.bonusEffect:SetActive(true);
	self.bgMask:SetActive(true);
	self:FadeCrossObject({parent = self.bgMask, duration = 1, textureAlpha = 0.8, particleAlpha = 0.5})

    local animator = self.bonusEffect:GetComponent("Animator");
    animator:Update(0);

	CC.Sound.PlayHallEffect("bonus.ogg");

	local beginDelay,endDelay = 1,1;
	self:RunAction(self, {
			--等特效进入才开始滚动数字
			{"delay", beginDelay, function()
					local numberContrl = self.bonusEffect:FindChild("text"):GetComponent("NumberRoller");
					numberContrl:RollFromTo(0, params.winMoney, duration-beginDelay-endDelay);
					CC.Sound.PlayLoopEffect("rollCoin.ogg");				
				end},
			--提前停止滚动保留显示endDelay秒
			{"delay", duration-beginDelay-endDelay, function()
					CC.Sound.StopExtendEffect("rollCoin.ogg");		
				end},
			{"delay", endDelay, function()
					self:FadeCrossObject({parent = self.bonusEffect, duration = 1, textureAlpha = 0, particleAlpha = 0})
					self:FadeCrossObject({parent = self.bgMask, duration = 1, textureAlpha = 0, particleAlpha = 0})
				end},
			--特效淡出后隐藏
			{"delay", 1, function()
					self.isPlayingEffect = false;
					self.bonusEffect:SetActive(false);
					self.bgMask:SetActive(false);
					self:FadeCrossObject({parent = self.bonusEffect, textureAlpha = 1, particleAlpha = 0.5, duration = 0});
					if params.callback then
						params.callback();
					end
				end},
		})

	return {duration = duration};
end

--params
--freeTimes:免费次数
--duration:特效显示时长
--callback:特效结束回调
function GameEffectView:PlayFreeSpinsEffect(params)
	if not params or not params.freeTimes then
		logError("error params");
		return
	end

	if self.isPlayingEffect then
		return
	end

	self:StopAllAction();

	local duration = params.duration or 5;

	self.isPlayingEffect = true;

	self.freeSpinsEffect:SetActive(true);
	self.bgMask:SetActive(true);
	self:FadeCrossObject({parent = self.bgMask, duration = 1, textureAlpha = 0.8, particleAlpha = 0.5})

    local animator = self.freeSpinsEffect:GetComponent("Animator");
    animator:Update(0);

	local textComponent = self.freeSpinsEffect:FindChild("text"):GetComponent("Text");
	textComponent.text = params.freeTimes;

	CC.Sound.PlayHallEffect("free.ogg");

	self:RunAction(self, {
			{"delay", duration, function()
					self:FadeCrossObject({parent = self.freeSpinsEffect, duration = 1, textureAlpha = 0, particleAlpha = 0})
					self:FadeCrossObject({parent = self.bgMask, duration = 1, textureAlpha = 0, particleAlpha = 0})
				end},
			--特效淡出后隐藏
			{"delay", 1, function()
					self.isPlayingEffect = false;
					self.freeSpinsEffect:SetActive(false);
					self.bgMask:SetActive(false);
					self:FadeCrossObject({parent = self.freeSpinsEffect, duration = 1, textureAlpha = 1, particleAlpha = 0.5})
					if params.callback then
						params.callback();
					end
				end},
		})

	return {duration = duration};
end

function GameEffectView:GetEffectCfg(winMul)
	local index;
	if winMul < 5 then
		return;
	elseif winMul >= 5 and winMul < 15 then
		index = 1;
	elseif winMul >= 15 and winMul < 30 then
		index = 2;
	elseif winMul >= 30 then
		index = 3;
	end
	return bigWinCfg[index];
end

--params
--baseMoney:底注
--winMoney:获奖数额
--callback:特效结束回调
function GameEffectView:PlayWinEffect(params)

	if not params or not params.winMoney or not params.baseMoney then
		logError("error params");
		return
	end

	if self.isPlayingEffect then
		log("effect is playing")
		return
	end

	local cfg = self:GetEffectCfg(params.winMoney/params.baseMoney);
	if not cfg then
		log("winMul is less than 10");
		return
	end

	if params.shareParam and not CC.ChannelMgr.GetTrailStatus() then
		self.isShareCall = true
		self.nWaitTimeForWin = 4
	else
		self.isShareCall = false
		self.nWaitTimeForWin = 1
	end

	--显示调过按钮
	self.skipBtn:SetActive(true);

	self:StopAllAction();

	self.isPlayingEffect = true;

	self.params = params;

	self.effectCfg = cfg;
	--显示bigwin特效节点
	self.winEffect:SetActive(true);
	--显示底部特效
	self.bottomParticle:SetActive(true);
	self.bgMask:SetActive(true);
	self:FadeCrossObject({parent = self.bgMask, duration = 1, textureAlpha = 0.8, particleAlpha = 0.5})
	--切换动画播放状态
	self.animator:SetTrigger(cfg.name.."Start");
	--当前耗时
	local curTime = 0;
	--每管进度条显示的时间
	local perProgressSecond = 1;
	--创建进度条动作队列
	local actionQueue = {};
	for i,v in ipairs(cfg.step) do

		curTime = curTime + v.duration;

		--进度条切换颜色
		table.insert(actionQueue,{"delay", 0 , function()
				self:SetProgressFrame(v.progressPath, 0);
			end})
		--进度条滚动
		local progressCount = v.duration/perProgressSecond;
		for i = 1, progressCount do
			table.insert(actionQueue, {"to", 0, 100, perProgressSecond, function(var)
					self.progressFrame.fillAmount = var/100; 
				end})
		end
		
		--每个小特效中间段到下一段的切换处理
		self:DelayRun(curTime+v.transOffset, function()

				self.animator:SetInteger("progress", i);

				if i == #cfg.step then
					--延迟1秒后让动画继续播放
					self:StayFinish(self.nWaitTimeForWin);
				else
					--每个特效的过度显示闪电特效
					self:ShowLightningEffect();
				end
			end)
	end
	--执行动作队列(延迟一帧执行，减少当前帧消耗)
	self:DelayRun(0, function()
			self:RunAction(self, actionQueue);
		end)
				
	--数字滚动处理
	local numberContrl = self.winEffect:FindChild("text"):GetComponent("NumberRoller");
	numberContrl:RollFromTo(0, params.winMoney, curTime);

	self:DelayRun(curTime, function()
			CC.Sound.StopExtendEffect("rollCoin.ogg");
		end)
	--底部粒子淡入
	self:DelayRun(1, function()
			self:FadeCrossObject({parent = self.bottomParticle, textureAlpha = 1, particleAlpha = 0.5, duration = 1});
		end)
	
	--播放循环音效
	CC.Sound.PlayLoopEffect("rollCoin.ogg");

	--返回子游戏需要的数据
	return {duration = curTime, effectName = self.effectCfg.name}
end

function GameEffectView:SetProgressFrame(progressPath, fillAmount)
	local image = self.winEffect:FindChild(progressPath):GetComponent("Image");
	local sprite = Sprite.Create(image.mainTexture, image.sprite.rect, image.sprite.pivot);
	self.progressFrame.sprite = sprite;
	self.progressFrame.fillAmount = fillAmount;
end

function GameEffectView:ShowLightningEffect()
	--闪电特效播放
	local lightning = self.winEffect:FindChild("lightningEffect");
	self:RunAction(self, {
			{"delay", 0.5, function() lightning:SetActive(true); end},
			{"delay", 2, function() lightning:SetActive(false); end},
		})
end

function GameEffectView:TurnToFinish()
	if self.isTurningToFinish or not self.effectCfg then
		return 
	end
	self.skipBtn:SetActive(false);
	self.isTurningToFinish = true;

	self:StopAllAction();
	self:CancelAllDelayRun();
	--让动画控制器切换到退出时显示的动画
	self.animator:SetTrigger(self.effectCfg.name.."Stop");
	--显示数字最终结果
	local numberContrl = self.winEffect:FindChild("text"):GetComponent("NumberRoller");
	numberContrl:RollFromTo(self.params.winMoney, self.params.winMoney, 0);
	CC.Sound.StopExtendEffect("rollCoin.ogg");
	--显示最终进度条
	local stepCfg = self.effectCfg.step[#self.effectCfg.step];
	self:SetProgressFrame(stepCfg.progressPath, 1);
	--延迟1秒后让动画继续播放
	self:StayFinish(self.nWaitTimeForWin);
end

function GameEffectView:StayFinish(duration)
	self.animator.speed = 0;
	self:DelayRun(duration, function()
			self.animator.speed = 1;
			self:EffectFinish();
		end)
	self.skipBtn:SetActive(false);

	if self.isShareCall then
		self.shareBtn:SetActive(true)
		self.closeBtn:SetActive(true)
		self.tipText:SetActive(true)
		local n = duration
		self.tipText:SetText(string.format(self.language.tip1, n))
		self:StartTimer("closeCountDown", 1, function() 
			n = n-1
			self.tipText:SetText(string.format(self.language.tip1, n))
		end, n)
	end
end

function GameEffectView:EffectFinish()
	self.tipText:SetActive(false)
	self.closeBtn:SetActive(false)
	self.shareBtn:SetActive(false)

	self.isTurningToFinish = true;
	self:FadeCrossObject({parent = self.bottomParticle, textureAlpha = 0, particleAlpha = 0, duration = 1});
	self:FadeCrossObject({parent = self.bgMask, duration = 1, textureAlpha = 0, particleAlpha = 0})
	local callback = self.params.callback;
	self:RunAction(self, {
			{"delay", 1, function()
					self:InitVar();
					--重置动画播放速度
					self.animator.speed = 1;
					--重置动画控制器状态值
					self.animator:SetInteger("progress", 0);
					
					self.bottomParticle:SetActive(false);
					self.bgMask:SetActive(false);
					local lightning = self.winEffect:FindChild("lightningEffect");
					lightning:SetActive(false);

					callback()
				end},
			{"delay", 0.5, function()
					self.winEffect:SetActive(false);
				end},
		})
end

function GameEffectView:FadeCrossObject(params)
	local parent = params.parent;
	local textureAlpha = params.textureAlpha;
	local particleAlpha = params.particleAlpha;
	local duration = params.duration;
	for i = 1, parent.childCount do
		local child = parent:GetChild(i-1);
		self:FadeObject({obj = child, particleAlpha = particleAlpha, textureAlpha = textureAlpha, duration = duration});
	end
	self:FadeObject({obj = parent, particleAlpha = particleAlpha, textureAlpha = textureAlpha, duration = duration});
end

function GameEffectView:FadeObject(params)
	local obj = params.obj;
	local textureAlpha = params.textureAlpha;
	local particleAlpha = params.particleAlpha;
	local duration = params.duration;
	if obj:GetComponent("ParticleSystem") then
		self:RunAction(obj, {"FadeParticleColor", 128, 128, 128, 256*particleAlpha, duration});
	else
		self:RunAction(obj, {"fadeToAll", 256*textureAlpha, duration});
	end
end

function GameEffectView:OnClickShareBtn(params)
	self.tipText:SetActive(false)
	self.closeBtn:SetActive(false)
	self.shareBtn:SetActive(false)

	local t = {}
	t.gameId = CC.ViewManager.GetCurGameId()
	t.extraData = params.shareParam.extraData or {}
	t.isShowPlayerInfo = false
	-- t.content = params.shareParam.content or (self.language.sharecontent .. " ")
	t.webText = params.shareParam.content or self.language.sharecontent
	local headIcon
	t.beforeCB = function()
		headIcon = CC.HeadManager.CreateHeadIcon({parent = self.topSharePanel:FindChild("headNode")})
		self.topSharePanel:FindChild("nameText"):SetText(CC.Player.Inst():GetSelfInfoByKey("Nick"))
		self.topSharePanel:FindChild("tipText"):SetText(string.format(self.language.tip2,params.winMoney/params.baseMoney*5,CC.uu.Chipformat2(params.winMoney)))
		self.topSharePanel:SetActive(true)
	end
	t.afterCB = function()
		CC.HeadManager.DestroyHeadIcon(headIcon)
		self.topSharePanel:SetActive(false)
		self:OnClickCloseBtn()
	end
	CC.ViewManager.Open("CaptureScreenShareView", t)
end

function GameEffectView:OnClickCloseBtn()
	self:CancelAllDelayRun();
	self:StopAllAction();
	self:StopAllTimer();
	self.animator.speed = 1;
	self:EffectFinish();
end

function GameEffectView:OnDestroy()
	self:CancelAllDelayRun();
	self:StopAllAction();
	self:StopAllTimer();
end

return GameEffectView