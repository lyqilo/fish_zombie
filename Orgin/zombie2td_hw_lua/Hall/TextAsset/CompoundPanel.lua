
local CC = require("CC")
local CompoundPanel = CC.uu.ClassView("CompoundPanel")

local batteryCfg = {
	[CC.shared_enums_pb.EPC_WhiteTiger_Battery] = {gameBtn = {"CatchFishFour", "CatchFishTwo"}, efNode = "BHPT"},
    [CC.shared_enums_pb.EPC_ZhuQue_Battery] = {gameBtn = {"CatchFishFour", "CatchFishTwo"}, efNode = "ZQPT"},
	[CC.shared_enums_pb.EPC_Cake_Battery] = {gameBtn = {"CatchFishFour"}, efNode = "DGPT"},
	[CC.shared_enums_pb.EPC_WaterGun_Battery] = {gameBtn = {"CatchFishFour","CatchFishTwo","PlaneCatchFish"}, efNode = "SQPT"},
    [CC.shared_enums_pb.EPC_JadeHare_Battery] = {gameBtn = {"CatchFishFour","CatchFishTwo","PlaneCatchFish"}, efNode = "YTPT"},
    [CC.shared_enums_pb.Epc_QingLong_1151] = {gameBtn = {"CatchFishFour","CatchFishTwo","PlaneCatchFish"}, efNode = "QLPT"},
    [CC.shared_enums_pb.EPC_Fish_Basalt] = {gameBtn = {"CatchFishFour","CatchFishTwo"}, efNode = "XWPT"},
    [CC.shared_enums_pb.EPC_FootBall_Fort_9094] = {gameBtn = {"CatchFishFour","CatchFishTwo","PlaneCatchFish"}, efNode = "SJBPT"},
    [CC.shared_enums_pb.EPC_ElectronicMusic_Battery] = {gameBtn = {"CatchFishFour","CatchFishTwo"}, efNode = "DYPT"},
}

function CompoundPanel:ctor(param)

	self:InitVar(param);
end

function CompoundPanel:OnCreate()

	self.language = CC.LanguageManager.GetLanguage("L_BatteryLotteryView");

	self:InitContent();
end

function CompoundPanel:InitVar(param)

	self.param = param;

	local batteryType = self.param.batteryType or CC.shared_enums_pb.EPC_WhiteTiger_Battery;
	self.batteryCfg = batteryCfg[batteryType];
end

function CompoundPanel:InitContent()

    self.musicName = CC.Sound.GetMusicName()
    CC.Sound.StopBackMusic();
    CC.Sound.PlayHallEffect("CompoundBattery")

	local isHall = CC.ViewManager.IsHallScene()
    self:FindChild("Hall"):SetActive(isHall)
    self:FindChild("Game"):SetActive(not isHall)

	if isHall then
		for _,v in pairs(self.batteryCfg.gameBtn) do
			self:FindChild("Hall/BtnNode/"..v):SetActive(true);
		end
        self:AddClick(self:FindChild("Hall/BtnNode/CatchFishFour") , function() self:EnterGame(3005) end)
        self:AddClick(self:FindChild("Hall/BtnNode/CatchFishTwo") , function() self:EnterGame(3002) end)
		self:AddClick(self:FindChild("Hall/BtnNode/PlaneCatchFish") , function() self:EnterGame(3007) end)
	end

	self.btnShare = self:FindChild("Share")
	self:AddClick(self.btnShare, function() self:OnClickShare(true) end)
	self:AddClick(self:FindChild("Hall/Close"), function() self:Destroy() end)
	self:AddClick(self:FindChild("Game/OK"), function() self:Destroy() end)
	self:InitTextByLanguage()
end

function CompoundPanel:InitTextByLanguage()

	self:FindChild("Hall/BtnNode/CatchFishFour/Text").text = self.language.PlayCatchFish_4
	self:FindChild("Hall/BtnNode/CatchFishTwo/Text").text = self.language.PlayCatchFish_2
	self:FindChild("Hall/BtnNode/PlaneCatchFish/Text").text = self.language.PlayCatchAir
	self:FindChild("Game/OK/Text").text = self.language.OK
	self:FindChild("Share/Text").text = self.language.CompoundShare
end

function CompoundPanel:ActionIn()
	self:SetCanClick(false);

	local efNode = self.batteryCfg.efNode;
	local efNormal = self:FindChild("Bg/"..efNode.."/Effect_BY_Normal");
	local efCompound = self:FindChild("Bg/"..efNode.."/Effect_BY_Compound");
    efCompound:SetActive(true);
    self:DelayRun(3.2,function()
        self:RunAction(efCompound, {
			{"fadeToAll", 0, 0.5, function()
                efCompound:SetActive(false)
                self:RunAction(efNormal, {
                    {"fadeToAll", 0, 0, function() efNormal:SetActive(true) end},
                    {"fadeToAll", 255, 0.5}
                });
            end},
        });
        self:SetCanClick(true);
    end)
end

function CompoundPanel:ActionOut()

end

function CompoundPanel:EnterGame(GameId)
    CC.HallUtil.CheckAndEnter(GameId, nil, function()
        CC.ViewManager.CloseAllOpenView()
    end)
end

function CompoundPanel:OnClickShare(isCompound)
    local param = {}
    param.isShowPlayerInfo = true
    param.beforeCB = function()
        self.btnShare:SetActive(false)
    end
    param.afterCB = function()
        self.btnShare:SetActive(true)
    end
    if not isCompound then
        param.shareCallBack = function()
            CC.Request("ReqCommonBatteryShare")
        end
    end
    CC.ViewManager.Open("CaptureScreenShareView", param)
end


function CompoundPanel:OnDestroy()

	CC.HallNotificationCenter.inst():post(CC.Notifications.OnRefreshBatterySkin);

    if self.musicName then
        CC.Sound.PlayHallBackMusic(self.musicName);
    end
end

return CompoundPanel