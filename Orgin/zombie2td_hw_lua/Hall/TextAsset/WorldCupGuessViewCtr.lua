local CC = require("CC")

local WorldGuessViewCtr = CC.class2("WorldGuessViewCtr")
local M = WorldGuessViewCtr

function M:ctor(view, param)
	self:InitVar(view,param)
end

function M:InitVar(view, param)
	self.param = param
	self.view = view

	self.countryList = {}
	-- 0,全部 1=亚洲  2=欧洲 3=南美洲  4=非洲  5=中北美洲
	self.dropDownList = {0,1,2,3,4,5}
	--阶段
	self.GameId = 0
end

function M:OnCreate()
	self:RegisterEvent();

	self:ReqWorldCupGuessInfo()
	self:ReqGetWorldCupBetInfo()
end

function M:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.ReqWorldCupGuessInfoResp,CC.Notifications.NW_ReqWorldCupGuessInfo)
	CC.HallNotificationCenter.inst():register(self,self.ReqGetWorldCupBetInfoResp,CC.Notifications.NW_ReqGetWorldCupBetInfo)
	CC.HallNotificationCenter.inst():register(self,self.OnPlayerBetRsp, CC.Notifications.NW_ReqPlayerBet)
end

function M:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self);
end

--冠军竞猜页面信息
function M:ReqWorldCupGuessInfo()
	CC.Request("ReqWorldCupGuessInfo")
end

function M:ReqWorldCupGuessInfoResp(err, param)
	log(CC.uu.Dump(param, "ReqWorldCupGuessInfo:"))
	if err == 0 then
		if param.Country then
			for _, v in ipairs(param.Country) do
				if not self.countryList[v.CountryId] then
					self.countryList[v.CountryId] = {}
				end
				self.countryList[v.CountryId].CountryId = v.CountryId
				self.countryList[v.CountryId].RegionId = v.RegionId
			end
		end
		self.GameId = param.GameId
		self.view:RefreshInfo(param)
	end
end

--投注信息(赔率，最大下注)
function M:ReqGetWorldCupBetInfo()
	local param = {}
	param.GameId = 0
	param.GameType = CC.shared_enums_pb.WC_ChampionGame
	CC.Request("ReqGetWorldCupBetInfo",param)
end

function M:ReqGetWorldCupBetInfoResp(err, param)
	log(CC.uu.Dump(param, "ReqGetWorldCupBetInfo:"))
	if err == 0 then
		if param.AreaBetInfo then
			for _, v in ipairs(param.AreaBetInfo) do
				if not self.countryList[v.CountryId] then
					self.countryList[v.CountryId] = {}
				end
				self.countryList[v.CountryId].BetMax = v.BetMax
				self.countryList[v.CountryId].Odds = v.Odds
				self.view:RefreshOdds(v.CountryId, v.Odds)
			end
		end
		self.view:RefreshInfo(param)
	end
end

--投注，(国家id，数量，赔率)
function M:ReqPlayerBet(countryId, count, odds)
	local param = {}
	param.GameId = self.GameId
	param.AreaId = countryId
	param.Count = count
	param.Odds = odds
	if self.view.useCard then
		param.BetType = CC.shared_enums_pb.WC_PropCard
	else
		param.BetType = CC.shared_enums_pb.WC_ChouMa
	end
	param.GameType = CC.shared_enums_pb.WC_ChampionGame
	CC.Request("ReqPlayerBet",param)
end

function M:OnPlayerBetRsp(err,param)
	log(CC.uu.Dump(param, "OnPlayerBetRsp:"))
	if err == 0 then
		self:ReqGetWorldCupBetInfo()
		local data = {}
		data.Index = 3
		data.TicketNum = param.OrderId
		data.SureBtnCb = function()
		end
		CC.ViewManager.OpenEx("WorldCupTipsView",data)
	end
	self.view:InitGuessState()
end

function M:Destroy()
	self:UnRegisterEvent()
end

return M