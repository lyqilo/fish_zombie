
local CC = require("CC")
local MonopolyGiftView = CC.uu.ClassView("MonopolyGiftView")

function MonopolyGiftView:ctor(param)

	self:InitVar(param);
	self.isBuyGift = false
end

function MonopolyGiftView:CreateViewCtr(...)
	local viewCtrClass = require("View/MonopolyView/"..self.viewName.."Ctr")
	return viewCtrClass.new(self, ...)
end

function MonopolyGiftView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
	self.language = CC.LanguageManager.GetLanguage("L_MonopolyView")
	self:InitTextByLanguage()
	self:ClickEvent()
	if self.param.AutoClose then
		--自动关闭
		self:DelayRun(10, function ()
			self:ActionOut()
		end)
	end
end

function MonopolyGiftView:InitVar(param)
	self.param = param or {}
	if not self.param.wareId then
		--wareid不存在给一个默认值
		self.param.wareId = "30370"
	end
	self.wareIdList = {"30370","30371","30372","30373","30374"}
	self.minCmList = {34000,153000,340000,1000000,4850000}
	self.maxCmList = {150000,750000,1000000,5000000,8000000}
	self.expList = {"1","1","1","1","1"}
	self.propNumList = {200,1000,1500,3000,6000}
	self.priceList = {}
end

function MonopolyGiftView:InitContent()

end

function MonopolyGiftView:InitTextByLanguage()
	if self.param.wareId then
		for i, v in ipairs(self.wareIdList) do
			if v == self.param.wareId then
				self:FindChild("Gift/BaseImg/Icon1/Image/Text").text = string.format(self.language.giftIcon1, CC.uu.NumberFormat(self.minCmList[i]), CC.uu.NumberFormat(self.maxCmList[i]))
				self:FindChild("Gift/BaseImg/Icon2/Image/Text").text = string.format(self.language.giftIcon2, self.expList[i])
				self:FindChild("Gift/BaseImg/Icon3/Image/Text").text = string.format(self.language.giftIcon3,  CC.uu.NumberFormat(self.propNumList[i]))
			end
		end
	end
	local price = self.wareCfg[self.param.wareId].Price
	self:FindChild("Gift/BaseImg/BuyBtn/Text").text = price
end

function MonopolyGiftView:ClickEvent()
	self:AddClick("Gift/CloseBtn",function ()
		self:ActionOut()
	end)
	self:AddClick("Gift/BaseImg/BuyBtn",function ()
		--购买请求
		self.viewCtr:OnPay(self.param.wareId)
	end)
end

function MonopolyGiftView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
	if self.param.callback then
		self.param.callback(self.isBuyGift)
	end
	if self.walletView then
		self.walletView:Destroy()
	end
end

return MonopolyGiftView