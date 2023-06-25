-- region SignWinView.lua
-- Date: 2019.7.13
-- Desc: 30天签到中奖名单
-- Author: chris
local CC = require("CC")
local SignWinView = CC.uu.ClassView("SignWinView")


--公告
function SignWinView:ctor()
	self.language = self:GetLanguage()
	self.SignData = CC.DataMgrCenter.Inst():GetDataByKey("SignData")
	self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
	self.SignDefine = CC.DefineCenter.Inst():getConfigDataByKey("SignDefine")
	self.configData = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")--获取周榜前50名的奖励金额
	self.language = self:GetLanguage()
end

function SignWinView:OnCreate()
	self:Init()
	self:setLanguageByText()
	self:AddClickEvent()
end


function SignWinView:Init()
	self.BtnClose = self:FindChild("Layer_Mask")
	self.WinPanel = self:FindChild("Layer_UI/WinPanel")
	self.scrollController = self.WinPanel:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.Scroller = self.WinPanel:FindChild("Scroller")
	self.scrollController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		xpcall(function() self:SignWinItemData(tran,dataIndex,cellIndex) end, function(error) logError(error) end)
	end)
	self.scrollController:InitScroller(self.SignData.GetRankLen())
end

--初始化日排行榜item
function SignWinView:SignWinItemData(trans,dataIndex,cellIndex)
	local temp = trans
	local index = dataIndex + 1
	temp.transform.name = index
	temp:FindChild("ItemName"):GetComponent("Text").text = self.SignData.GetRankPlayerNick(index)
	temp:FindChild("ItemDate"):GetComponent("Text").text = CC.uu.TimeOut3(self.SignData.GetRankOpenTime(index))


	local EntityId = self.SignData.GetRankEntityId(index)
	local Count = self.SignData.GetRankValue(index)
	temp:FindChild("ItemDetail"):GetComponent("Text").text = self.PropDataMgr.GetLanguageDesc( EntityId, Count )

	self:AddClick(temp,function()
		self:RequestPersonal(self.SignData.GetRankPlayerId(index))
	end)
end

--查询玩家
function SignWinView:RequestPersonal(str)
	local param = {
		playerId = str
	}
	CC.HeadManager.OpenPersonalInfoView(param) 
end

function SignWinView:setLanguageByText()
	self.WinPanel:FindChild("Top/TopText").text =self.language.AwardStr
end

function SignWinView:AddClickEvent()
	self:AddClick(self.BtnClose,"Close")
end

--关闭
function SignWinView:Close()
	self:Destroy()
end


function SignWinView:OnDestroy()

end

return SignWinView