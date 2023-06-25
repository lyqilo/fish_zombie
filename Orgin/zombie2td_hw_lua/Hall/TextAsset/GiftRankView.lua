
local CC = require("CC")

local GiftRankView = CC.uu.ClassView("GiftRankView")

function GiftRankView:ctor(param)
	self.param = param or {}
	self.language = self:GetLanguage()
	self.GiftDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("GiftData")
	self.IconTab = {}
	self.headIndex = 0
end

function GiftRankView:OnCreate()
	self:InitUI()
end

function GiftRankView:ActionIn()

end

function GiftRankView:InitUI()
	self.Parent = self:FindChild("Layer_UI/Parent")
	self.Content = self.Parent:FindChild("FrameBg/Scroll View/Viewport/Content")
	self.GiftRankItem = self.Content:FindChild("GiftRankItem")

	self:AddClick(self.Parent:FindChild("Left/BtnActive"),"CloseView")
	self:AddClick(self:FindChild("Layer_Mask"),"CloseView")

	self:HeadItem()
	self:RankItem()

	self.Parent.localPosition = Vector3(0,0,0)
	self:RunAction(self.Parent, {"to", 0, -635,0.5, function(value)
		self.Parent.transform.anchoredPosition = Vector3(value,0,0)
	end})

	self.Parent:FindChild("Left/leftText").text = self.language.Weeklygrantlist
end

function GiftRankView:RankItem()
	local mySelfId = CC.Player.Inst():GetSelfInfoByKey("Id")
	for i = 1,self.GiftDataMgr:GetTradeRankLen() do
		local data = self.GiftDataMgr:GetTradeRankItemData(i)
		local tran = CC.uu.newObject(self.GiftRankItem,self.Content)
		tran:FindChild("ItemText").text = tostring(i)
		tran:FindChild("ItemName").text = data.Player.Nick
		tran:FindChild("ItemMoneyImg/ItemMoneyText").text =  CC.uu.ChipFormat(data.Score)

		local headNode = tran:FindChild("ItemHeadMask/Node")
		self:SetHeadIcon({parent = headNode,playerId = data.Player.Id,portrait = data.Player.Portrait,vipLevel = data.Level})
		tran:SetActive(true)
		
		local BtnChat = tran:FindChild("BtnChat")
		BtnChat:SetActive(tonumber(mySelfId) ~= tonumber(data.Player.Id) and CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr").GetSwitchStateByKey("ChatPanel"))
		self:AddClick(BtnChat,function()
			CC.ViewManager.ShowChatPanel({PlayerId =  data.Player.Id,Portrait = data.Player.Portrait,Nick = data.Player.Nick,Level = data.Player.Level})
			self:CloseView()
		end)
	end
end

function GiftRankView:HeadItem()
	local len = self.GiftDataMgr:GetTradeRankLen() < 3 and self.GiftDataMgr:GetTradeRankLen() or 3
	
	for i = 1,len do
		local data = self.GiftDataMgr:GetTradeRankItemData(i)
		local tran = self.Parent:FindChild("FrameBg/Head"..i)
		tran:FindChild("Name/ItemName").text = data.Player.Nick

		local headNode = tran:FindChild("ItemHeadMask/Node")
		self:SetHeadIcon({parent = headNode,playerId = data.Player.Id,portrait = data.Player.Portrait,vipLevel = data.Level})
	end
end

function  GiftRankView:SetHeadIcon(param)
	self.headIndex = self.headIndex + 1
	local headIcon = CC.HeadManager.CreateHeadIcon(param)
	headIcon.transform.name = tostring(self.headIndex)
	self.IconTab[self.headIndex] = headIcon
end

function  GiftRankView:CloseView()
	self:RunAction(self.Parent, {"to", -635, 0,0.5, function(value)
			self.Parent.transform.anchoredPosition = Vector3(value,0,0)
			if value == 0 then self:Destroy() end
	end})
end

function GiftRankView:OnDestroy()
	if self.param.callback then
		self.param.callback()
	end

	for i,v in pairs(self.IconTab) do
	  	if v then
		   v:Destroy()
		   v = nil
		end
	end
end

return GiftRankView