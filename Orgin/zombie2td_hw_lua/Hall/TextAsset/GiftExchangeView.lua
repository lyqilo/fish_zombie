
local CC = require("CC")
local GiftExchangeView = CC.uu.ClassView("GiftExchangeView")

function GiftExchangeView:ctor(param)

	self:InitVar(param);
end

function GiftExchangeView:InitVar(param)

	self.param = param;
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.WareId = {LeftWareId = "22021", RightWareId = "22022"}
	self.language = self:GetLanguage()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.BuyTime = {StopTime = {hour = 21,min = 59},StartTime = {hour = 22,min = 00}}
	self.createTime = os.time()+math.random()
end

function GiftExchangeView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
	self:InitUI()
	self:ShowGiftTurntableView()
end

function GiftExchangeView:InitUI()
	self:FindChild("View/Bg/Tip1/Text").text = self.language.Tip1Text
	self:FindChild("View/Bg/Tip2").text = self.language.Tip2
	--self:FindChild("View/Bg/Tip2/Text").text = self.language.Tip2Text
	self:FindChild("View/Bg/Time").text = self.language.Time
	self:FindChild("View/Bg/Time/Text").text = self.language.TimeText
	self:FindChild("View/ExchangeBtn/LeftBtn/Text").text = self.language.LeftBtnText
	self:FindChild("View/ExchangeBtn/LeftBtn/Price").text = self.wareCfg[self.WareId.LeftWareId].Price
	self:FindChild("View/ExchangeBtn/RightBtn/Text").text = self.language.RightBtnText
	self:FindChild("View/ExchangeBtn/RightBtn/Price").text = self.wareCfg[self.WareId.RightWareId].Price
	self:FindChild("View/ExchangeBtn/RightBtn/Tip/Text").text = self.language.RightBtnTipText

	self:AddClick(self:FindChild("View/ExplainBtn/Btn"),function()
		local data = {
			title = self.language.title,
			content = self.language.content,
		}
		CC.ViewManager.Open("CommonExplainView", data)
	end)
	self:AddClick(self:FindChild("View/ExchangeBtn/LeftBtn"),function()
		self:ExchangeBtnClick(self.WareId.LeftWareId)
	end)
	self:AddClick(self:FindChild("View/ExchangeBtn/RightBtn"),function()
		self:ExchangeBtnClick(self.WareId.RightWareId)
	end)
	--幸运转盘
	self:AddClick(self:FindChild("View/TurntableBtn"),function()
		local GiftTViewPanel = CC.ViewManager.Open("GiftTurntableView")
		GiftTViewPanel:ActionIn()
	end)
	self.walletView = CC.uu.CreateHallView("WalletView",{})
    self.walletView.transform:SetParent(self.transform, false)

    --跑马灯文字
	self.MarqueeText = self:FindChild("View/Marquee/hedi/Text")
	self:SetTip()
end

function GiftExchangeView:SetTip()
	local tip = self:FindChild("View/ExchangeBtn/RightBtn/Tip")
	local value = 255
	local countDown = 1
	self:StartTimer("GiftcountDown"..self.createTime, 1, function ()
		countDown = countDown - 1
		if countDown < 0 then
			countDown = 1
			value = value >= 255 and 0 or 255
			self:RunAction(tip, {
				{"fadeToAll", value, 0.5},
			})
		end
	end,-1)
end

function GiftExchangeView:ExchangeBtnClick(WareId)
	if not self:CheckTime() then
		CC.ViewManager.ShowTip(self.language.StopExchange)
		return
	end
	local price =  self.wareCfg[WareId].Price
    if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= price then
        CC.Request("ReqBuyWithId",{WareId = WareId, ExchangeWareId = WareId},function()
			local GiftTViewPanel = CC.ViewManager.Open("GiftTurntableView")
			GiftTViewPanel:ActionIn()
        end);

	else
        if self.walletView then
            self.walletView:SetBuyExchangeWareId(WareId)
            self.walletView:PayRecharge()
        end
    end
end

function GiftExchangeView:CheckTime()
	local NowTime = os.date("*t")
	local StopTime = os.time({year = NowTime.year,month = NowTime.month,day = NowTime.day,hour = self.BuyTime.StopTime.hour,min = self.BuyTime.StopTime.min})
	local StartTime = os.time({year = NowTime.year,month = NowTime.month,day = NowTime.day,hour = self.BuyTime.StartTime.hour,min = self.BuyTime.StartTime.min})
	NowTime = os.time()

	if NowTime >= StopTime and NowTime <= StartTime then
		return false
	end
	return true
end

function GiftExchangeView:InitRecordPanel(count)
	if count > 0 then
		self:FindChild("View/Marquee"):SetActive(true)
		self:StartMarquee()
	end
end
--跑马灯播报
function GiftExchangeView:StartMarquee()
	self:StartTimer("Marquee",1,function ()
		if self.isMarqueeMoving then
			return
		else
			self.isMarqueeMoving = true
			self.MarqueeText.text = self:DealWithString(string.format(self.language.MarqueeText,self.viewCtr:GetMarqueeText()))
			self.MarqueeText.localPosition = Vector3(2000,2000,0)
			if self.isMarqueeMoving then
			    self:DelayRun(0.1,function()
				    local textW = self.MarqueeText:GetComponent('RectTransform').rect.width
				    local half = textW/2
				    self.MarqueeText.localPosition = Vector3(half + 450, 20, 0)
				    self.action = self:RunAction(self.MarqueeText, {"localMoveTo", -half - 450, 20, 0.65 * math.max(16,textW/40), function()
					    self.action = nil
					    self.isMarqueeMoving = false
				end})
			    end)
		    end
		end
	end,-1)
end

function GiftExchangeView:DealWithString(text)
	local str = string.gsub(CC.uu.ReplaceFace(text,23,true),'%s+',' ')
	return str
end

function GiftExchangeView:StopMarquee()
	self.isMarqueeMoving = false
	self:StopTimer("Marquee")
	self:FindChild("View/Marquee"):SetActive(false)
end

function GiftExchangeView:ShowGiftTurntableView()
	if CC.LocalGameData.GetLocalDataToKey("GiftTurntableView", CC.Player.Inst():GetSelfInfoByKey("Id")) then
		CC.LocalGameData.SetLocalDataToKey("GiftTurntableView", CC.Player.Inst():GetSelfInfoByKey("Id"))
		CC.ViewManager.Open("GiftTurntableView")
	end
end

function GiftExchangeView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function GiftExchangeView:ActionOut()
	self:SetCanClick(false);
	self:FindChild("View/Bg/Title_Effect_cjdb"):SetActive(false)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function GiftExchangeView:OnDestroy()
	self:StopTimer("GiftcountDown"..self.createTime)
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
	if self.walletView then
		self.walletView:Destroy()
	end
end

return GiftExchangeView