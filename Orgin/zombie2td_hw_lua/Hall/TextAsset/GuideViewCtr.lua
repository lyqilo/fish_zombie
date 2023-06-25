local CC = require("CC")
local GuideViewCtr = CC.class2("GuideViewCtr")

function GuideViewCtr:ctor(view, param)
	self:InitVar(view,param)
end

function GuideViewCtr:InitVar(view,param)
	self.param = param
	self.view = view

	--游戏下载成功
	self.gameProcess = 0
	self.breakDownload = false
	self.startDownLoad = false
	self.isDownload = false
	self.saveFlag = nil
	self.rewardFlag = nil
end

function GuideViewCtr:OnCreate()
	self:RegisterEvent()
end

function GuideViewCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.DownloadProcess,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():register(self,self.SaveThreeFlag,CC.Notifications.OnNotifyGuide)
	CC.HallNotificationCenter.inst():register(self,self.ReqSaveNewPlayerFlagResp,CC.Notifications.NW_ReqSaveNewPlayerFlag)
	CC.HallNotificationCenter.inst():register(self,self.ReqNewPlayerRewardPropResp,CC.Notifications.NW_ReqNewPlayerRewardProp);
	--material高亮信息
	CC.HallNotificationCenter.inst():register(self,self.SetHighlight,CC.Notifications.OnHighlightInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnNewSignResp,CC.Notifications.NW_ReqNewPlayerSign);
end

function GuideViewCtr:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadGame)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnNotifyGuide)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqNewPlayerRewardProp)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqSaveNewPlayerFlag)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnHighlightInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqNewPlayerSign);
end

function GuideViewCtr:DownloadProcess(data)
	if self.breakDownload then return end
	local guideData = self.view.gameDataMgr.GetGuide()
    if guideData.state and guideData.Flag >= 3 then
		--已完成下载游戏引导
		self.breakDownload = true
        return
    end
	self.gameProcess = data.process
	log(CC.uu.Dump(self.gameProcess))
	if self.gameProcess < 1 then
		CC.ViewManager.Open("DownloadView", {GameId = data.gameID})
	end
	self:SaveThreeFlag()
end

function GuideViewCtr:SaveThreeFlag()
	self:ReqSaveNewPlayerFlag(3)
	self.view:GuideFlag(3)
end

function GuideViewCtr:EnterGame(gameId)
	CC.HallUtil.CheckAndEnter(gameId, nil, function()
		CC.ViewManager.CloseAllOpenView()
	end)
end

function GuideViewCtr:RequestGiftSaveFlag()
	self:ReqSaveNewPlayerFlag(7)
end

function GuideViewCtr:ReqNewPlayerRewardPropResp(err, param)
	log("err = ".. err.."  "..CC.uu.Dump(param, "ReqNewPlayerRewardProp",10))
	if err == 0 then
		local data = {};
		for k, v in ipairs(param.Rewards) do
			data[k] = {}
			data[k].ConfigId = v.ConfigId
            data[k].Count = v.Count
		end
		local Cb = function ()
			if self.rewardFlag then
				self.view:GuideFlag(self.rewardFlag)
				self.rewardFlag = nil
			end
		end
		self.view.stepTranTab[self.rewardFlag]:SetActive(false)
		self.view:OnNotifyHallFirst()
		CC.ViewManager.OpenRewardsView({items = data, title = "ยินดีด้วยได้รับ", callback = Cb})
	elseif err == 378 then
		--已领取过奖
		self.view:GuideFlag(self.rewardFlag)
	elseif err == -1 then
		self:BackLogin()
	end
end

function GuideViewCtr:ReqSigninPlayerFlag()
	self:ReqSaveNewPlayerFlag(11)
	local param = {}
	param.PlayerId = CC.Player.Inst():GetSelfInfoByKey("Id")
	param.GameId = CC.ViewManager.GetCurGameId() or 1
	param.GroupId = CC.ViewManager.GetCurGroupId() or 0
	CC.Request("ReqNewPlayerSign",param)
end

function GuideViewCtr:OnNewSignResp(err, data)
	if err == 0 then
		self.view:GuideFlag(11)
	end
end

function GuideViewCtr:ReqTreasureBuyFlag()
	self:ReqSaveNewPlayerFlag(21)
	local data = {}
	data.GoodsID = 120029
	data.Type = 2
	CC.Request("ReqGoodsBuy",data)
end

--电子钱包
function GuideViewCtr:ReqTreasureAgentExFlag()
	if not CC.ViewManager.IsHallScene() then return end
	self:ReqSaveNewPlayerFlag(20)
	--检查是否绑定手机和是否设置安全码
	if not self:CheckIsCanPurchase() then
		return
	end
	--验证安全码
	local nextFun = function(err,result)
		if err ~= 0 then return end
		---验证成功之后下次 兑换、夺宝、超级夺宝 都不用再验证
		CC.Player.Inst():GetSafeCodeData().SafeService[1].Status = true
		CC.Player.Inst():GetSafeCodeData().SafeService[2].Status = true
		CC.Player.Inst():GetSafeCodeData().SafeService[3].Status = true
		CC.ViewManager.Open("AgentShareView", {value = 20,closeBtn = true, tipsType = 2, guide = true})
	end
	if not CC.Player.Inst():GetSafeCodeData().SafeService[1].Status then
		CC.ViewManager.Open("VerSafePassWordView",{serviceType = 1,verifySuccFun = nextFun})
	else
		nextFun(0,{Token = ""})
	end
end

function GuideViewCtr:CheckIsCanPurchase()
	if not CC.HallUtil.CheckTelBinded() then
		if CC.HallUtil.CheckSafetyFactor() then
			return false
		end
	end
	if not CC.HallUtil.CheckSafePassWord() then
		return false
	end
	return true
end

function GuideViewCtr:ReqSaveNewPlayerFlag(flag)
	self.saveFlag = flag
	if flag == 1 or flag == 7 then
		local RewardId = flag == 1 and 1 or 2
		self.rewardFlag = flag
		CC.Request("ReqNewPlayerRewardProp", {NewPlayerRewardType = RewardId})
	end
	CC.Request("ReqSaveNewPlayerFlag",{Flag = flag, PlayerType = self.view.PlayerType})
end

function GuideViewCtr:ReqSaveNewPlayerFlagResp(err, data)
	if err == 0 and self.saveFlag then
		if self.saveFlag ~= 1 and self.saveFlag ~= 7 and self.saveFlag and 11 then
			self.view:GuideFlag(self.saveFlag)
		end
	end
	self.saveFlag = nil
end

function GuideViewCtr:ReqSaveSingleNewPlayerFlag(flag)
	CC.Request("ReqSaveNewPlayerFlag",{Flag = flag, IsSingle = true})
    self.view.gameDataMgr.SetGuide(flag, true)
    self.view:CloseView()
end

function GuideViewCtr:SetHighlight(param)
	self.view:SetHighlight(param)
end

function GuideViewCtr:BackLogin()
	local loginDefine = CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine");
	if CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Facebook then
		CC.FacebookPlugin.Logout();
	elseif CC.Player.Inst().GetCurLoginWay() == loginDefine.LoginWay.Line then
		CC.LinePlugin.Logout();
	end
	CC.Player.Inst().SetCurLoginWay();
	CC.ViewManager.BackToLogin(loginDefine.LoginType.Logout);
end

function GuideViewCtr:Destroy()
	self:unRegisterEvent()
end

return GuideViewCtr