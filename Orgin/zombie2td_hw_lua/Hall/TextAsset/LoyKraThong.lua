local CC = require("CC")
local uu = CC.uu
local LoyKraThongWish = require("View/LoyKraThong/LoyKraThongWish")
local LoyKraThongHelp = require("View/LoyKraThong/LoyKraThongHelp")
local LoyKraThongRank = require("View/LoyKraThong/LoyKraThongRank")
local LoyKraThongWishesList = require("View/LoyKraThong/LoyKraThongWishesList")
local LoyKraThongWinnersList = require("View/LoyKraThong/LoyKraThongWinnersList")
local baseClass = uu.ClassView("LoyKraThong")

local ActiviyTime = "30/10/2020 - 01/11/2020"

function baseClass:ctor(param)
	self.language = CC.LanguageManager.GetLanguage("L_LoyKraThong");
	-- self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
	-- self.onlineWelfareDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("OnlineWelfareDataMgr")

	self.DataInfo = {}
end

function baseClass:OnCreate()
	self:ReqWaterLampWishInfo()
	self:InitContent();
	self:InitTextByLanguage();
	self:RegisterEvent();
end

function baseClass:ReqWaterLampWishInfo()
	CC.Request("ReqGetWaterLampWishInfo")
	self:StartTimer("ReqGetWaterLampWishInfo", 2, function() CC.Request("ReqGetWaterLampWishInfo") end,-1)
end

function baseClass:InitContent()
	self.totalNumText = self:SubGet("UILayout/window/totalNumText","Text")
	self.totalNumText.text = "0" -- CC.uu.ChipFormat(Count)

	self:AddClick("UILayout/window/rankBtn",function ()
		self.rankView:SetActive(true)
	end)
	self:AddClick("UILayout/window/helpBtn",function ()
		self.helpView:SetActive(true)
	end)

	local openWish = function (wishType)
		self.wishesListView:InitList(wishType)
		self.wishesListView:SetActive(true)
	end

	local openWin = function (wishType,RewardInfo)
		-- local RewardInfo = RewardInfo
		-- if RewardInfo == nil and self.DataInfo and self.DataInfo[wishType] then
		-- 	RewardInfo = self.DataInfo[wishType].RewardInfo
		-- end
		local RewardInfo = self.DataInfo[wishType]~=nil and self.DataInfo[wishType].RewardInfo
		if RewardInfo and #RewardInfo~=0 then
			self.winnersListView:InitList(wishType,RewardInfo)
			self.winnersListView:SetActive(true)
		else
			CC.ViewManager.ShowTip(self.language.wishListWait)
		end
	end

	self.firstWish = LoyKraThongWish.new(1,openWish,openWin)
	self.firstWish:Init(self:FindChild("UILayout/window/frist"))

	self.secondWish = LoyKraThongWish.new(2,openWish,openWin)
	self.secondWish:Init(self:FindChild("UILayout/window/second"))

	self.helpView = LoyKraThongHelp.new()
	self.helpView:Init(self:FindChild("UILayout/help"))
	self.helpView:SetActive(false)

	self.rankView = LoyKraThongRank.new()
	self.rankView:Init(self:FindChild("UILayout/rank"))
	self.rankView:SetActive(false)

	self.wishesListView = LoyKraThongWishesList.new(openWin)
	self.wishesListView:Init(self:FindChild("UILayout/wishes"))
	self.wishesListView:SetActive(false)

	self.winnersListView = LoyKraThongWinnersList.new()
	self.winnersListView:Init(self:FindChild("UILayout/winners"))
	self.winnersListView:SetActive(false)

end

function baseClass:InitTextByLanguage()
	local dateText = self:SubGet("UILayout/window/dateText","Text")
	dateText.text = ActiviyTime

	local totalText = self:SubGet("UILayout/window/totalText","Text")
	totalText.text = self.language.totalText
end

function baseClass:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnGetWaterLampWishInfoRsp,CC.Notifications.NW_ReqGetWaterLampWishInfo);
	CC.HallNotificationCenter.inst():register(self,self.OnUpdateDataInfo,CC.Notifications.OnUpdateWaterLampWishDataInfo)
end

function baseClass:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_ReqGetWaterLampWishInfo)
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnUpdateWaterLampWishDataInfo)
end

function baseClass:OnGetWaterLampWishInfoRsp(errCode, data)
	-- self.activityDataMgr.SetActivityInfoByKey("LoyKraThong", {redDot=false});
	if errCode == 0 then
		log(CC.uu.Dump(data,"OnGetWaterLampWishInfoRsp",10))
		self:OnUpdateDataInfo(data)
	else
		logError(errCode)
		--[[
			WaterLampWishFailed = 340;
			WaterLampWishTimesLessThanZero = 341;
			WaterLampWishRankFailed = 342;
			WaterLampWishTimesOver = 343;
			WaterLampWishStatusError = 344;
			WaterLampWishTimesNotEnough = 345;
			WaterLampWishMoneyNotEnough = 346;
			WaterLampWishTypeError = 347;
		]]
	end
end

function baseClass:OnUpdateDataInfo( data )
	if data == nil then
		logError("OnUpdateDataInfo data")
		return
	end
	local Info = data.Info
	if Info == nil then
		logError("OnUpdateDataInfo Info")
		return
	end

	local firstItem = nil
	local secondItem = nil

	for _,v in ipairs(Info.Items or {}) do
		if v.Type and v.Type == 1 then
			firstItem = v
		elseif v.Type and v.Type == 2 then
			secondItem = v
		end
	end
	if firstItem then
		self.DataInfo[1] = firstItem
		self.firstWish:SetWishData(firstItem)
		self.totalNumText.text = CC.uu.ChipFormat(firstItem.TotalCost or 0)
		self.rankView:SetJackpot(firstItem.TotalCost)
	end
	if secondItem then
		self.DataInfo[2] = secondItem
		self.secondWish:SetWishData(secondItem)
	end
end

function baseClass:OnRefreshUI()

end

function baseClass:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function baseClass:ActionOut()
	self:SetCanClick(false);
	self:SetActiveEff()
	self:OnDestroy();
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function baseClass:SetActiveEff()
	self:FindChild("UILayout/window/Effect_ui_yanhua"):SetActive(false)
	self:FindChild("UILayout/window/Effect_ui_shuibo002"):SetActive(false)
	self:FindChild("UILayout/window/frist/flower/Effect_ui_shuibo001"):SetActive(false)
	self:FindChild("UILayout/window/second/flower/Effect_ui_shuibo001"):SetActive(false)
end

function baseClass:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function baseClass:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function baseClass:OnDestroy(destroyOnLoad)
	self.firstWish:Destroy(destroyOnLoad)
	self.secondWish:Destroy(destroyOnLoad)
	self.helpView:Destroy(destroyOnLoad)
	self.rankView:Destroy(destroyOnLoad)
	self.wishesListView:Destroy(destroyOnLoad)
	self.winnersListView:Destroy(destroyOnLoad)

	self:UnRegisterEvent();
end

return baseClass