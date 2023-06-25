local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local DragonUi = GC.class2("ZTD_DragonUi")

function DragonUi:ctor(_, rootNode, battleView)
	self._rootNode = rootNode
	self._battleView = battleView
	--_dragonNums变量仅用于普通巨龙之怒，不用于巨龙令
	self._dragonNums = 0
	self._txt_score_var = 0
	self.totalPropsNum = 0
	self.isOpenPop = false
	self.isDragoning = false
	self.propsInfo = nil
	self.propsList = {}
	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_DragonConfig")
	self._dragonLogic = ZTD.DragonLogic:new(self)
	
	self._dragonBarEff = ZTD.EffectManager.PlayEffect("Effect_UI_JLong", self._rootNode, true)
	self._dragonBarEff:SetActive(false)
	self._dragonProgEff = ZTD.EffectManager.PlayEffect("TD_EF_UI_Ljindu", self._rootNode, true)
	self._dragonProgEff:SetActive(false)
	self._dragonProgAddEff = ZTD.EffectManager.PlayEffect("TD_EF_UI_Ljindu_1", self._rootNode, true)
	self._dragonProgAddEff.localPosition = self:FindChild("skill_prog").localPosition
	self._dragonProgAddEff:SetActive(false)
	self._dragonReadyEff = ZTD.EffectManager.PlayEffect("TD_Effect_UI_GUANG", self:FindChild("skill_prog", true))
	self._dragonReadyEff.localPosition = Vector3.zero
	self._dragonReadyEff:SetActive(false)
	self._dragonEndShowEff = ZTD.PoolManager.GetUiItem("ZTD_dragon_show", self._battleView.transform)
	self.mesh = self._dragonEndShowEff:FindChild("Effect_UI_Bosszhandou/lizi01_01")
	self._dragonEndShowEff:SetActive(false)
	
	local bgPos = self:FindChild("score_bg").position
	self._scoreBgPosSrc = Vector3(bgPos.x, bgPos.y, bgPos.z)
	self.dragonPop = battleView:FindChild("ZTD_dragonPop")
	self.content = self.dragonPop:FindChild("frame/itemNode/Viewport/Content")
	self._txt_score = self:FindChild("score_bg/txt_score")
	self._txt_score.text = 0
	
	self:InitUI()
	self:Register()
	self:AddEvent()
end

function DragonUi:FindChild(childNodeName)
	return self._rootNode:FindChild(childNodeName)
end

function DragonUi:InitUI()
	self:RequestAllPropInfo()
end

function DragonUi:AddEvent()
	self._battleView:AddClick(self:FindChild("btn_dhelp2"),function()
		self.isOpenPop = not self.isOpenPop
		self.dragonPop:SetActive(self.isOpenPop)
	end)	
	
	self._battleView:AddClick(self:FindChild("btn_dragon"),function()
		if self.isDragoning then
			ZTD.ViewManager.ShowTip(self.language.colding)
			return
		end
		self:OnClkDragon(0)
	end)
end

function DragonUi:Register()
	ZTD.Notification.NetworkRegister(self, "SCPushDragonRelease", self.OnPushDragonRelease)
	ZTD.Notification.NetworkRegister(self, "SCPushDragonEnd", self.OnPushDragonEnd)
	ZTD.Notification.NetworkRegister(self, "SCPushSelfDragonState", self.OnPushSelfDragonState)
end

--获取所有装备信息
function DragonUi:RequestAllPropInfo()
    local succCb = function(err, data)
		--  log("CSGetDragonProps Succ data = "..GC.uu.Dump(data.Info))
		 self.propsInfo = data.Info
		 self:RefreshDragonPop()
		 self:GetTotalPropsNum()
		 self:RefreshRedPoint()
     end
     local errCb = function(err, data)
         logError("CSGetDragonProps Error data = "..GC.uu.Dump(err))
     end
    ZTD.Request.CSGetDragonPropsReq(succCb, errCb)
 end

 --刷新巨龙令弹窗
function DragonUi:RefreshDragonPop()
	if not self.propsInfo then return end
	for k, v in ipairs(self.propsInfo) do
		local item = ResMgr.LoadPrefab("prefab", "ZTD_PropItem", self.content)
		item.name = v.PropsID
		item:FindChild("propNum"):GetComponent("Text").text = v.ProgressBarCount
		item:FindChild("multipleNum"):GetComponent("Text").text = self.language.propContent[v.PropsID].multi
		item:FindChild("icon"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", "jll_icon_l"..v.PropsID)
		self.propsList[v.PropsID] = {item = item, num = v.ProgressBarCount}
		item.onClick = function()
			if self.propsList[v.PropsID].num <= 0 then
				ZTD.ViewManager.ShowTip(self.language.notEnoughNum)
				return
			end
			if self.isDragoning then
				ZTD.ViewManager.ShowTip(self.language.colding)
				return
			end
			self:OnClkDragon(v.PropsID)
		end
	end
end

--刷新巨龙令数量
function DragonUi:RefreshPropsNum(data)
	for k, v in ipairs(data.Info) do
		self.propsList[v.PropsID].num = v.ProgressBarCount
		self.propsList[v.PropsID].item:FindChild("propNum"):GetComponent("Text").text = v.ProgressBarCount
	end
end

--刷新红点(根据策划需求，将红点显示改为总数显示)
function DragonUi:RefreshRedPoint()
	-- logError("totalPropsNum="..tostring(self.totalPropsNum))
	if self.totalPropsNum >= 0 then
		self:FindChild("image/text"):GetComponent("Text").text = self.totalPropsNum
		-- self:FindChild("image/redPoint"):SetActive(true)
	else
		self:FindChild("image/text"):GetComponent("Text").text = ""
		-- self:FindChild("image/redPoint"):SetActive(false)
	end
end

--获取巨龙令总数量
function DragonUi:GetTotalPropsNum()
	if not self.propsList then return end
	local num = 0
	for k, v in pairs(self.propsList) do
		if v and v.num then
			num = num + v.num
		end
	end
	self.totalPropsNum = num
	return num
end

function DragonUi:GetGoldPos()
	return self:FindChild("node_gold_target").position
end

function DragonUi:RefreshGold()
	local goldData = ZTD.GoldData.DragonGold
	self:UpdateGold(goldData.Show)
end

function DragonUi:UpdateGold(dmoney)
	if dmoney ~= 0 and ZTD.GoldData.DragonGold.Sync ~= 0 then --and dmoney > self._txt_score_var then
		self._txt_score_var = dmoney
		self._txt_score.text = tools.numberToStrWithComma(dmoney)
	end	
end

--释放巨龙之怒推送
function DragonUi:OnPushDragonRelease(Data)
	-- log(os.date("%Y-%m-%d %H:%M:%S:") .. "OnPushDragonReleaseOnPushDragonReleaseOnPushDragonRelease:" .. GC.uu.Dump(Data))
	local cfg = ZTD.ConstConfig[1]
	local isSelf = (Data.PlayerId == ZTD.PlayerData.GetPlayerId())
	self._dragonLogic:ActiveRoad(isSelf, Data.AttackInfo)
	self._dragonLogic:Skip2Pos(Data.StartTime / cfg.SecondRate)
end

--巨龙之怒释放结束推送
function DragonUi:OnPushDragonEnd(Data)
	if Data.PlayerId == ZTD.PlayerData.GetPlayerId() then
		-- log(os.date("%Y-%m-%d %H:%M:%S:") .. "OnPushDragonEndOnPushDragonEnd:"..GC.uu.Dump(Data))
		self._endComboNode = self._dragonLogic._comboNode;
		self._dragonLogic:SetComboNode()
		if self._checkEndFunc then
			ZTD.Flow.RemoveUpdateList(self._checkEndFunc)
			self._checkEndFunc = nil
		end
		
		local checkEndFunc;
		checkEndFunc = function (dt)
			local dragonGold = ZTD.GoldData.DragonGold
			if dragonGold.Recorder <= 0 and self._dragonLogic:IsTimeOut() then
				ZTD.Flow.RemoveUpdateList(self._checkEndFunc)
				self._checkEndFunc = nil
				self:PlayEndAnim(Data)
			end	
		end
		self._checkEndFunc = checkEndFunc;
		ZTD.Flow.AddUpdateList(self._checkEndFunc)
	end
	--log("self._dragonNums="..self._dragonNums)
	self:FindChild("dragon_disable_tip"):SetActive(false)
	if self._dragonNums > 0 then
		self:FindChild("dragon_release_tip"):SetActive(true)
	end
end

-- 巨龙之怒状态推送
function DragonUi:OnPushSelfDragonState(Data)
	-- log("OnPushSelfDragonState data="..GC.uu.Dump(Data))
	local PropsID = Data.PropsID or 0
	local PropsNum = Data.ProgressBarCount or 0
	local barCount = Data.ProgressBarCount
	local progressBar = Data.ProgressBar
	-- 龙的最大次数
	local maxBar = 1
	local sk_p = self:FindChild("skill_prog")
	if not sk_p then
		return
	end
	local prog_img = sk_p:GetComponent("Image")
	if barCount >= maxBar then
		if PropsID <= 0 then
			prog_img.fillAmount = 1
		end
		local act = self:FindChild("dragon_disable_tip").transform.activeSelf
		-- log("act="..tostring(act))
		if not act and PropsID <= 0 then
			self:FindChild("dragon_release_tip"):SetActive(true)
		end
	else
		local p = progressBar / 100
		prog_img.fillAmount = p
		self:FindChild("dragon_release_tip"):SetActive(false)
	end
	if barCount <= 0 then
		self._dragonReadyEff:SetActive(false)
	else
		if PropsID <= 0 then
			self._dragonProgAddEff:SetActive(false)
			self._dragonProgAddEff:SetActive(true)
		end

		self._dragonReadyEff:SetActive(true)
	end
	if self._dragonProgEff then
		if barCount == 0 and progressBar == 0 then
			self._dragonProgEff:SetActive(false)
		else
			self._dragonProgEff:SetActive(true)
			local ex = 421 + (544 - 421) * prog_img.fillAmount
			self._dragonProgEff.localPosition = Vector3(ex, 304, 0)
		end
	end
	if PropsID <= 0 then
		self._dragonNums = barCount
	end
end

--收到推送后巨龙令刷新:比如宝箱开箱获得巨龙令
function DragonUi:OnDragonProps(data)
	self:RefreshPropsNum(data)
	self:GetTotalPropsNum()
	self:RefreshRedPoint()
end

--点击释放巨龙之怒
function DragonUi:OnClkDragon(PropsID)
	if self._dragonNums > 0 or PropsID > 0 then
		local function sussCb()
			if PropsID > 0 then
				self.propsList[PropsID].num = self.propsList[PropsID].num - 1
				self.propsList[PropsID].item:FindChild("propNum"):GetComponent("Text").text = self.propsList[PropsID].num
				self:GetTotalPropsNum()
				self:RefreshRedPoint()
			end
			local dragonGold = ZTD.GoldData.DragonGold
			dragonGold:Set(0)
			dragonGold.Recorder = 0
			if self._dragonNums > 0 then
				self:FindChild("dragon_disable_tip"):SetActive(true)
			end
			self:FindChild("dragon_release_tip"):SetActive(false)
			self._dragonReadyEff:SetActive(false)
			self:ResetScoreBg()
			self._scoreBgAct = ZTD.Extend.RunAction(self:FindChild("score_bg"),
								{"localMoveBy",0, -100, 0, 0.5})	
			self.isDragoning = true	
		end
		self._dragonLogic:ReqRoad(PropsID, sussCb)
	else
		ZTD.ViewManager.ShowTip(self.language.lessTip)
	end	
end

function DragonUi:PlayEndAnim(Data)
	ZTD.PlayMusicEffect("ZTD_dragon_prize", nil, nil, true)
	self._dragonEndShowEff:SetActive(false)
	self._dragonEndShowEff:SetActive(true)
	self:ResetEndSpine()
	local node_show = self._battleView:FindChild("ZTD_dragon_show")
	if ZTD.isSaveMode then
		--log("isSaveMode")
		self.mesh:SetActive(false)
	end
	node_show:SetActive(true)
	local spine = node_show:FindChild("Spine")
	local txt_score = node_show:FindChild("txt_score")
	local skAnim = spine:GetComponent(typeof(Spine.Unity.SkeletonGraphic))
	if skAnim.AnimationState then
		skAnim.AnimationState:SetAnimation(0, "stand", false)
	end
	local moneyEarnData = ZTD.GoldData.DragonGold
	txt_score.text = tools.numberToStrWithComma(moneyEarnData.Sync);
	ZTD.Extend.RunAction(txt_score,{{"scaleTo", 0, 0, 0, 0}, {"delay", 1.5}, {"scaleTo", 0.35, 0.35, 0.35, 0.3, ease = ZTD.Action.EInBack}})
	self._endShowAct = ZTD.GameTimer.DelayRun(4.5, function ()
		node_show:SetActive(false);
		ZTD.GameTimer.StopTimer(self._endShowAct);
		self._endShowAct = nil;
		self.isDragoning = false
	end)
	self._endShowAct2 = ZTD.GameTimer.DelayRun(2.5, function ()
		ZTD.Extend.RunAction(self:FindChild("score_bg"), {"localMoveBy", 0, 100, 0, 0.5})
		-- 金币柱表现
		ZTD.Notification.GamePost(ZTD.Define.MsgGoldPillar, moneyEarnData.Sync / self._dragonLogic:GetRatio(), moneyEarnData.Sync)
		self._endShowAct2 = nil
		-- 刷新底部+-金币		
		local comboNode = self._endComboNode;
		if comboNode then
			ZTD.ComboShowTree.ReduceComboByNode(comboNode)
		end
		self._endComboNode = nil
		if self._dragonNums > 0 then
			self._dragonReadyEff:SetActive(true)
		end
	end)
	local fixGold = moneyEarnData.Sync
	self._txt_score_var = fixGold
	self._txt_score.text = tools.numberToStrWithComma(fixGold)
end

function DragonUi:Reset()
	self:OnPushSelfDragonState({ProgressBarCount = 0, ProgressBar = 0})
	self._dragonLogic:Release()
	self:ResetScoreBg()
	self:ResetEndSpine()
	self:FindChild("dragon_disable_tip"):SetActive(false)
	self:FindChild("dragon_release_tip"):SetActive(false)
	self._dragonReadyEff:SetActive(false)

	-- 重置金币表现数据
	local dragonGold = ZTD.GoldData.DragonGold
	dragonGold:Set(0)
	dragonGold.Recorder = 0
	
	self._dragonLogic:SetComboNode(nil)

	if self._checkEndFunc then
		ZTD.Flow.RemoveUpdateList(self._checkEndFunc)
		self._checkEndFunc = nil
	end	
end

function DragonUi:OnPause()
	self._dragonLogic:OnPause()	
end

function DragonUi:OnResume()
end

function DragonUi:ResetScoreBg()
	if self._scoreBgAct then
		ZTD.Extend.StopAction(self._scoreBgAct)
		self._scoreBgAct = nil
	end
	self:FindChild("score_bg").position = self._scoreBgPosSrc
	self._txt_score.text = 0
	self._txt_score_var = 0
end

function DragonUi:ResetEndSpine()
	if self._endShowAct then
		ZTD.GameTimer.StopTimer(self._endShowAct)
		self._endShowAct = nil
	end	
	
	if self._endShowAct2 then
		ZTD.GameTimer.StopTimer(self._endShowAct2)
		--[-[
		local comboNode = self._endComboNode;
		ZTD.ComboShowTree.ReduceComboByNode(comboNode)
		self._endComboNode = nil
		--]]
		self._endShowAct2 = nil
	end
	local node_show = self._battleView:FindChild("ZTD_dragon_show")
	self.mesh:SetActive(true)
	node_show:SetActive(false)
end


function DragonUi:Release()
	ZTD.Notification.NetworkUnregisterAll(self)
	ZTD.Notification.GameUnregisterAll(self)
	self._dragonLogic:Release()
end

return DragonUi