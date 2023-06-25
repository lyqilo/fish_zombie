

local CC = require("CC")
local NoviceGiftView = CC.uu.ClassView("NoviceGiftView")

function NoviceGiftView:ctor(content)
	self.language = self:GetLanguage()
	--self.transform = tran
	self.content = content
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity")
end

function NoviceGiftView:OnCreate()
	self.activityDataMgr.SetActivityInfoByKey("NoviceGiftView", {redDot = false})
	self.transform:SetParent(self.content.transform, false)

	self.viewCtr = self:CreateViewCtr()
	self.viewCtr:OnCreate()
	self:Init()

end

function NoviceGiftView:Init()
	self.DetalObj = self:FindChild("DetalObj")
	self.DetalObjBG = self.DetalObj:FindChild("BG")
	self.BtnBuy= self:FindChild("BtnBuy")
	self.BtnBuyGray= self:FindChild("BtnBuyGray")
	self.BtnBuyText= self:FindChild("BtnBuy/Text")
	-- local image = CC.Platform.isIOS and "xinshoulibaoIOS" or "xinshoulibaoAndroid"
	-- self:SetImage(self:FindChild("Image"), image)
	self:AddClickEvnt()
	self:ItemData()
	self:SetLanguage()
end

--语言设置
function NoviceGiftView:SetLanguage()
	self.BtnBuyText:GetComponent("Text").text = self.language.OnBuy
	self:FindChild("BtnBuyGray/Text").text = self.language.OnBuy
end

--礼包赠送的item信息
function NoviceGiftView:ItemData()
	if CC.ChannelMgr.GetTrailStatus() then
		return
	end
	for i=1,#self.viewCtr.configData do
		if self.viewCtr.configData[i].count ~= 0 then
			self:FindChild("ItemParent/"..tostring(i).."/Text"):SetActive(true)
			self:FindChild("ItemParent/"..tostring(i).."/x"):SetActive(true)
			self:FindChild("ItemParent/"..tostring(i).."/Text").text = tostring(self.viewCtr.configData[i].count)
			self:FindChild("ItemParent/"..tostring(i).."/x").text = "X"
		end
		-- 赠送的奖品的详细信息
		local function DetalData()
			self.DetalObj:SetActive(true)
			self.DetalObj:FindChild("DetalName").text = self.language[self.viewCtr.configData[i].Name]
			self.DetalObj:FindChild("DetalText").text = self.language[self.viewCtr.configData[i].Detal]
			self:SetImage(self.DetalObj:FindChild("DetalImg"), self.viewCtr.configData[i].img..".png");
			self.DetalObj:FindChild("DetalImg").sizeDelta = Vector2(106, 96)
		end

		self:AddClick(self:FindChild("ItemParent/"..tostring(i)),DetalData)
	end
end

function NoviceGiftView:AddClickEvnt()
	self:AddClick(self.DetalObjBG,"DetalObjSetActive")
	self:AddClick(self.BtnBuy,"OnBuy")
end

function NoviceGiftView:OnBuy()
	self.viewCtr:OnPay()
	self.BtnBuy:SetActive(false)
	self.BtnBuyGray:SetActive(true)
end

function NoviceGiftView:DetalObjSetActive()
	self.DetalObj:SetActive(false)
end

function NoviceGiftView:OnDestroy()
	if self.viewCtr ~= nil then
		self.viewCtr:Destroy()
	end
end

function NoviceGiftView:ActionOut()
	self:SetCanClick(false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function NoviceGiftView:ActionIn()
	self:SetCanClick(false);

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

return NoviceGiftView
