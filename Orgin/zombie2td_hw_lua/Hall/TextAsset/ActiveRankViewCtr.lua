
local CC = require("CC")

local ActiveRankViewCtr = CC.class2("ActiveRankViewCtr")

--@param
--playerId
function ActiveRankViewCtr:ctor(view, param)
	self:InitVar(view, param)
end

function ActiveRankViewCtr:OnCreate()
	--self:InitData();
end

function ActiveRankViewCtr:Destroy()

end

function ActiveRankViewCtr:InitVar(view, param)

	self.param = param
	--UI对象
	self.view = view

	self.configData = CC.ConfigCenter.Inst():getConfigDataByKey("ActiveRankReward")--获取周榜前50名的奖励金额

	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
end

--获取周榜奖励的长度
function ActiveRankViewCtr:GetConfigRwardCount(id)
	return self.configData[tonumber(id)].Count
end

function ActiveRankViewCtr:InitData()
end

--获取周邦
function ActiveRankViewCtr:ReqGetActiveRank()
	local url = self.WebUrlDataManager.GetActiveRankUrl()
	local www = CC.HttpMgr.Get(url,function (www)
		local table = Json.decode(www.downloadHandler.text)
		CC.ViewManager.CloseConnecting()
		self.view.ActiveRankDataMgr:SetActieveRankData(table)
		self.view:SetNewLen(self.view.WeekendLoopScrollRect)
		self.view:DownTip(self.view.Weeken_RankItem)
		self.view:HeadItem()
	end,
	function ()
		CC.ViewManager.CloseConnecting()
		CC.ViewManager.ShowTip(self.view.language.act_tip)
	end)
end
return ActiveRankViewCtr