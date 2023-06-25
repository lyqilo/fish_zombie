
local CC = require("CC")
local WorldCupGiftView = CC.uu.ClassView("WorldCupGiftView")

function WorldCupGiftView:ctor(param)

	self:InitVar(param);
end

function WorldCupGiftView:CreateViewCtr(...)
	local viewCtrClass = require("View/WorldCupView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function WorldCupGiftView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitContent()
	self:InitTextByLanguage()
	self:AddClickEvent()
end

function WorldCupGiftView:InitVar(param)
	self.language = CC.LanguageManager.GetLanguage("L_WorldCupView")

	self.param = param or {};
	self.paramList = {
		[1] = {Text = self.language.Gift_Coin, Icon = "WorldCup_Gift_1", Des = "",Di = true},
		[2] = {Text = self.language.Gift_UnlockCard, Icon = "WorldCup_Gift_2", Des = self.language.Gift_Guess_Des,Di = true},
		[3] = {Text = "บัตรเควสเดิมพัน\nรางวัลสองเท่า", Icon = "sjb_rw_rk_icon", Des = "ปัจจุบันรางวัลเดิมพันสองเท่า\nหมดอายุ 23：59：59",Di = false},
		[4] = {Text = self.language.Gift_Guess, Icon = "prop_img_9089", Des = "",Di = true},
		[5] = {Text = self.language.Gift_Head, Icon = "prop_img_9088", Des = "",Di = false},
	}
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.WareId = "30329"
end

function WorldCupGiftView:InitContent()
	self.LoadingSlider = self:SubGet("Bg/UpsidePanel/Right/ProgressImage/Slider","Slider")
	self.index = 0.34
	self.mainScrollList = {}
	self.CapsuleCfg = CC.ConfigCenter.Inst():getConfigDataByKey("CapsuleConfig")
	self:FindChild("Bg/PaketImage/BuyBtn/Text").text = self.wareCfg[self.WareId].Price

	if #self.param <1 then
		self.viewCtr:RequestInfo()
	else
		self:SetParam(self.param)
	end

	local buyStatus = CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetGiftStatus(self.WareId)
	self:FindChild("Bg/PaketImage/GrayBtn"):SetActive(not buyStatus)
	self:FindChild("Bg/PaketImage/BuyBtn"):SetActive(buyStatus)

	self.walletView = CC.uu.CreateHallView("WalletView")
end

function WorldCupGiftView:SetParam(data)
	self.param = data
	self.LoadingSlider.value = self.index *self.param.CurrentPurchaseCount
	if self.param.CurrentPurchaseCount >=3 then
		table.remove(self.paramList,5)
		self:FindChild("Bg/UpsidePanel/Right/ProgressImage"):SetActive(false)
		self:FindChild("Bg/PaketImage/Image"):SetActive(false)
	end
	self:FindChild("Bg/UpsidePanel/Right/ProgressImage/Bottom/Text").text = self.param.CurrentPurchaseCount.."/"..self.param.FinalPurchaseCount

	self:InitRewardsList()
end

function WorldCupGiftView:InitRewardsList()

	local parent = self:FindChild("Bg/PaketImage/AutoScList")
	self.autoScroll = CC.ViewCenter.AutoScroll.new()
	table.insert(self.mainScrollList,self.autoScroll)
	local param = {}
	param.parent = parent
	param.list = self.paramList
	param.type = 3
	self.autoScroll:Create(param)
	self.autoScroll:SetTrundleState(true)
end

function WorldCupGiftView:RefreshSlider()
	self:FindChild("Bg/PaketImage/GrayBtn"):SetActive(true)
	self:FindChild("Bg/PaketImage/BuyBtn"):SetActive(false)
	if self.param.CurrentPurchaseCount then
		self.param.CurrentPurchaseCount = self.param.CurrentPurchaseCount +1
		self.LoadingSlider.value = self.index *(self.param.CurrentPurchaseCount)
		self:FindChild("Bg/UpsidePanel/Right/ProgressImage/Bottom/Text").text = self.param.CurrentPurchaseCount.."/"..self.param.FinalPurchaseCount
	end
	CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData").ChangeWorldCupGiftStatus(2)
end

function WorldCupGiftView:InitTextByLanguage()
	self:FindChild("Bg/UpsidePanel/Left/Text1").text = self.language.Gift_Tip_Title
	self:FindChild("Bg/UpsidePanel/Left/Content/1/Text").text = self.language.Gift_Tip_Content_1
	self:FindChild("Bg/UpsidePanel/Left/Content/2/Text").text = self.language.Gift_Tip_Content_2
	self:FindChild("Bg/UpsidePanel/Left/Content/3/Text").text = self.language.Gift_Tip_Content_3
	self:FindChild("Bg/PaketImage/Image/Des").text = self.language.Gift_Tips
end

function WorldCupGiftView:AddClickEvent()

	self:AddClick(self:FindChild("Bg/PaketImage/BuyBtn"),function ()
		self.viewCtr:RequestBuy()
	end)
	self:AddClick(self:FindChild("Bg/PaketImage/GrayBtn"),function ()
		self.viewCtr:RequestBuy()
	end)
	self:AddClick(self:FindChild("Bg/CloseBtn"),function ()
		self:ActionOut()
	end)
end

function WorldCupGiftView:ActionOut()
	self:PlayMoveToIcon()
end

function WorldCupGiftView:PlayMoveToIcon()
	local v1 = CC.DataMgrCenter.Inst():GetDataByKey("WorldCupData").GetGiftBtnV2()
	local v2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:GlobalCamera(),self.transform.position)
	local dis = v1 - v2
	local x = self.transform.localPosition.x + dis.x - 50
	local y = self.transform.localPosition.y + dis.y

	self:RunAction(self.transform, {"spawn",
		{"localMoveTo", x, y, 0.3},
		{"fadeToAll", 0, 0.6},
		{"scaleTo", 0,0, 0.3,function ()
				self:Destroy()
			end}
		})
end

function WorldCupGiftView:OnDestroy()
	if self.autoScroll then
		self.autoScroll:Destroy()
	end

	if self.walletView then
		self.walletView:Destroy()
	end

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return WorldCupGiftView