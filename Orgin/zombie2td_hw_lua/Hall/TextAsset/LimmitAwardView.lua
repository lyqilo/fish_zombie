local CC = require("CC")

local LimmitAwardView = CC.uu.ClassView("LimmitAwardView")

function LimmitAwardView:ctor(param)

end

function LimmitAwardView:OnCreate()

	self:InitVar();
	self:InitContent();
	self:InitTextByLanguage();
	self:RegisterEvent();
	self:RequestData();
end

function LimmitAwardView:InitVar()
	--缓存请求的数据
	self.awardInfo = {};

	self.language = CC.LanguageManager.GetLanguage("L_OnlineAward");

	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
end

function LimmitAwardView:InitTextByLanguage()

	self:SetText(self:FindChild("UILayout/BtnGet/Select/Text"), self.language.get_tip);

	self:SetText(self:FindChild("UILayout/BtnGet/UnSelect/Text"), self.language.get_tip);

	self:SetText(self:FindChild("UILayout/BtnVIP/Select/Text"), self.language.vip_tip);
end

function LimmitAwardView:RegisterEvent()

	CC.HallNotificationCenter.inst():register(self,self.OnVipChanged,CC.Notifications.VipChanged);

	CC.HallNotificationCenter.inst():register(self,self.OnTakeLoginRewardRsp,CC.Notifications.NW_TakeLoginReward);

	CC.HallNotificationCenter.inst():register(self,self.OnGetLoginRewardInfoRsp,CC.Notifications.NW_GetLoginRewardInfo);
end

function LimmitAwardView:UnRegisterEvent()

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.VipChanged)

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_TakeLoginReward)

	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_GetLoginRewardInfo)
end

function LimmitAwardView:InitContent()

	self:RefreshUIData();

	self:AddClick("UILayout/BtnVIP/Select", "OnClickBtnVIP");

	self:AddClick("UILayout/BtnGet/Select", "OnClickGetAward");

	-- self:AddClick("UILayout/BtnClose", "ActionOut");
end

function LimmitAwardView:ShowBtnState(isVIP)

	local btnVIP = self:FindChild("UILayout/BtnVIP");
	btnVIP:SetActive(not isVIP);
	local btnGet = self:FindChild("UILayout/BtnGet")
	btnGet:SetActive(isVIP);
end

function LimmitAwardView:SetBtnGetState(flag)

	local btnSelect = self:FindChild("UILayout/BtnGet/Select");
	btnSelect:SetActive(flag);
	local btnUnSelect = self:FindChild("UILayout/BtnGet/UnSelect");
	btnUnSelect:SetActive(not flag);
end

function LimmitAwardView:OnClickBtnVIP()

	local switchOn = self.activityDataMgr.GetActivityInfoByKey("NoviceGiftView").switchOn;

	if switchOn and CC.SelectGiftManager.CheckNoviceGiftCanBuy() then
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, false);

		CC.ViewManager.Open("SelectGiftCollectionView", {closeFunc = function() CC.HallNotificationCenter.inst():post(CC.Notifications.OnShowFreeChipsCollectionView, true); end});
	else
		CC.ViewManager.Open("StoreView");
	end
end

function LimmitAwardView:OnClickGetAward()
    CC.Request("TakeLoginReward");
end

function LimmitAwardView:OnTakeLoginRewardRsp(err, result)
	log(string.format("err: %s    OnTakeLoginRewardRsp: %s ",err,result))
	if err == 0 then
		self.awardInfo.canGetReward = false;
		self:RefreshUIData();
		CC.ViewManager.OpenRewardsView({items = result.Prop})

		local data = {};
		data.redDot = false;
		self.activityDataMgr.SetActivityInfoByKey("LimmitAwardView", data);
	end
end

function LimmitAwardView:RequestData()

	CC.Request("GetLoginRewardInfo");
end

function LimmitAwardView:OnGetLoginRewardInfoRsp(err, result)
	if err == 0 then
		self.awardInfo.canGetReward = result.CanGetReward;
		self:RefreshUIData();
	end
end

function LimmitAwardView:OnVipChanged(level)

	self:RefreshUIData(level);
end

function LimmitAwardView:RefreshUIData(level)

	local data = {};
	data.isVIP = (level and level > 0) or (CC.Player.Inst():GetSelfInfoByKey("EPC_Level") > 0);
	data.isShowGet = self.awardInfo.canGetReward;
	self:OnRefreshUI(data);
end

function LimmitAwardView:OnRefreshUI(param)

	if param.isVIP ~= nil then
		self:ShowBtnState(param.isVIP);
	end

	if param.isShowGet ~= nil then
		self:SetBtnGetState(param.isShowGet);
	end
end

function LimmitAwardView:ActionIn()

	self:SetCanClick(false);

	self:RunAction(self.transform, {

			{"fadeToAll", 0, 0},

			{"fadeToAll", 255, 0.5, function()

					self:SetCanClick(true);
				end}
		});
end

function LimmitAwardView:ActionOut()

	self:SetCanClick(false);

	self:OnDestroy();

	self:RunAction(self.transform, {

			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function LimmitAwardView:ActionShow()

	self:DelayRun(0.5, function() self:SetCanClick(true); end)

	self.transform:SetActive(true);
end

function LimmitAwardView:ActionHide()

	self:SetCanClick(false);

	self.transform:SetActive(false);
end

function LimmitAwardView:OnDestroy()

	self:UnRegisterEvent();
end

return LimmitAwardView