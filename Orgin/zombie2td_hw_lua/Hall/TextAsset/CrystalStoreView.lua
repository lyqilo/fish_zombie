local CC = require("CC")
local CrystalStoreView = CC.uu.ClassView("CrystalStoreView")

function CrystalStoreView:ctor(param)
	self:InitVar(param);
end

function CrystalStoreView:InitVar(param)
    self.param = param
    self.language = self:GetLanguage()
	self.physicalShopCfg = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalShop")
end

function CrystalStoreView:OnCreate()
	self:InitNode()
    self:InitView()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
end

function CrystalStoreView:InitNode()
	self.CrystalNumTxt = self:FindChild("Crystal/Num")
	self.WarePagePref = self:FindChild("WareView/Content/Group/Page")
	self.WareGroup = self:FindChild("WareView/Content/Group")
	self.LeftArrow = self:FindChild("Btn/LeftArrow")
	self.RightArrow = self:FindChild("Btn/RightArrow")
	self.ToggleGroupNode = self:FindChild("WareView/ToggleGroup")
end

function CrystalStoreView:InitView()
    self:FindChild("ReqFailTip").text = self.language.ReqGoodsListFail
    self.CrystalNumTxt.text = string.format(self.language.HavaCrystal,CC.uu.NumberFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_Crystal"))) 
end

function CrystalStoreView:InitClickEvent()
	self:AddClick(self:FindChild("Btn/Close") , function() self:Destroy() end)
	self:AddClick(self:FindChild("Btn/Explain") , function() self:OpenExplainView(self.language.explainTitle,self.language.explainContent) end)
	self:AddClick(self.LeftArrow , function() self:Switch("Left") end)
	self:AddClick(self.RightArrow , function() self:Switch("Right") end)
end

function CrystalStoreView:InitStore(wareList)
	if not table.isEmpty(wareList) and not self.isInitStore then
		local num = math.modf( table.length(wareList) / 10) 
	    self.WarePageNum = math.fmod(table.length(wareList), 10) > 0 and num + 1 or num
		local PageItem = nil 
		local WareItme = nil
		for i,v in ipairs(wareList) do
			if math.fmod(i, 10) == 1 then
				PageItem = CC.uu.newObject(self.WarePagePref,self.WareGroup)
				PageItem:SetActive(true)
				local index = math.modf(i / 10) +1
				PageItem.name ="Page"..index
				WareItme = PageItem:FindChild("Ware")
			end
            local wareInfo = self.physicalShopCfg[tostring(v.ID)]
			local wareItem = CC.uu.newObject(WareItme,PageItem)
			wareItem:SetActive(true)
			wareItem.name = wareInfo.Id
			local iconObj = wareItem:FindChild("bg1/bg2/icon")
			self:SetImage(iconObj,wareInfo.Icon) 
			iconObj:GetComponent("Image"):SetNativeSize()
			wareItem:FindChild("bg1/bg2/num").text = wareInfo.Rewards[1].Count
			wareItem:FindChild("btn/price").text = wareInfo.Price
			self:AddClick(wareItem:FindChild("btn"),function() self:OnClickExchange(v) end)
		end

		self.CurPage = 1
		if self.WarePageNum > 1 then
			self.Toggles = {}
		    local toggleItem = self.ToggleGroupNode:FindChild("Toggle")
			for i=1,self.WarePageNum do
				local toggle = CC.uu.newObject(toggleItem,self.ToggleGroupNode)
				toggle:SetActive(true)
				toggle.name = "Page"..i
				table.insert(self.Toggles,toggle)
			end
			self.Toggles[self.CurPage]:FindChild("IsOn"):SetActive(true)
		end
		self.isInitStore = true
	end
	self:FindChild("ReqFailTip"):SetActive(not self.isInitStore)
	self.LeftArrow:SetActive(not (self.CurPage == 1) and self.isInitStore)
	self.RightArrow:SetActive(not (self.CurPage ==  self.WarePageNum) and self.isInitStore)
end

function CrystalStoreView:OpenExplainView(tit, cont)
	local data = {
		title = tit,
		content = cont,
	}
	CC.ViewManager.Open("CommonExplainView",data )
end

function CrystalStoreView:Switch(direction)
	local result = nil
	if direction == "Left" then
		if self.CurPage == 1 then
			return
		end
		result = -1
	else 
		if self.CurPage == self.WarePageNum then
			return
		end
		result = 1
	end
	self.CurPage = self.CurPage + result
	self:SetCanClick(false)
	self:RunAction(self.WareGroup,{"localMoveBy", -result * 904,0, 0.3,function ()
		self:SetCanClick(true)
		self.LeftArrow:SetActive(not (self.CurPage == 1))
		self.RightArrow:SetActive(not (self.CurPage == self.WarePageNum))
		if not table.isEmpty(self.Toggles) then
			for i,v in ipairs(self.Toggles) do
				v:FindChild("IsOn"):SetActive(i == self.CurPage)
			end
		end
	end})
end

function CrystalStoreView:OnClickExchange(data)
	local Crystal = CC.Player.Inst():GetSelfInfoByKey("EPC_Crystal")
	local wareInfo = data
	if Crystal >= wareInfo.Price then
		local box = CC.ViewManager.ShowMessageBox(self.language.AffirmExchange,function()
			CC.Request("ReqGoodsBuy",{Type = CC.proto.client_shop_pb.CrystalShop,GoodsID = data.ID})
		end)
	else
		CC.ViewManager.ShowTip(self.language.CrystalNotEnough)
	end
end

function CrystalStoreView:RefreshCrystal()
    self:DelayRun(0.5,function(  )
        self.CrystalNumTxt.text = string.format(self.language.HavaCrystal,CC.uu.NumberFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_Crystal"))) 
    end)
end

function CrystalStoreView:ActionIn()
end

function CrystalStoreView:ActionOut() 
end

function CrystalStoreView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
end

return CrystalStoreView