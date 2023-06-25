local CC = require("CC")
local PirateTreasureGiftView = CC.uu.ClassView("PirateTreasureGiftView")

function PirateTreasureGiftView:ctor(param)
    self.param = param;
	self.language = self:GetLanguage()
	self.createTime = os.time()+math.random()
    self.PrefabInfo = {}
    self.IconTab = {}
    self.RankNum = 0
    self.openBigAward = false
end

function PirateTreasureGiftView:OnCreate()
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self.propLanguage = CC.LanguageManager.GetLanguage("L_Prop")
    self.viewCtr = self:CreateViewCtr(self.param);
    self.pirateWareId = "23004"
	self.giftPrice = self.wareCfg[self.pirateWareId].Price or 143
	self.viewCtr:OnCreate();
	self:InitUI()
end

function PirateTreasureGiftView:InitUI()
	--大奖名单
	self.BigAwardPanel = self:FindChild("BigAwardPanel")
    self:AddClick(self.BigAwardPanel:FindChild("BigAwardBtn"), function ()
        self:OnBigAwardClick()
	end)
	self.Info_Content = self.BigAwardPanel:FindChild("InfoView/Scroller/Viewport/Content")
	self.Info_Item = self.BigAwardPanel:FindChild("InfoView/Scroller/Viewport/Item")

	self:AddClick(self:FindChild("BtnClose"), "ActionOut")
    self:AddClick(self:FindChild("BuyBtn"), "OnBuyGift")
	self:FindChild("BuyBtn/Text").text = self.giftPrice
    --self:SetCountDown(120)
    self:LanguageSwitch()
	self:InitUIData()
	CC.Request("GetOrderStatus",{self.pirateWareId})
	self.viewCtr:ReqRecord()
end

--语言切换
function PirateTreasureGiftView:LanguageSwitch()
	self:FindChild("price/Text"):GetComponent("Text").text = self.language.price
	self:FindChild("tip/Text"):GetComponent("Text").text = self.language.rewardTip
	self:FindChild("Chip"):GetComponent("Text").text = self.language.maxChip
	self.BigAwardPanel:FindChild("InfoView/Image/Name").text = self.language.roleName
	self.BigAwardPanel:FindChild("InfoView/Image/Info").text = self.language.winInfo
end

function PirateTreasureGiftView:InitUIData()
	self.walletView = CC.uu.CreateHallView("WalletView", {parent = self.transform, exchangeWareId = self.pirateWareId})
end

function PirateTreasureGiftView:OnBuyGift()
	if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.giftPrice then
		local data={}
        data.WareId=self.pirateWareId
        data.ExchangeWareId= self.pirateWareId
        CC.Request("ReqBuyWithId",data)

	else
		if self.walletView then
			self.walletView:PayRecharge()
		end
	end
end

--中大奖名单
function PirateTreasureGiftView:OnBigAwardClick()
	if self.openBigAward then
        self.BigAwardPanel:FindChild("bg"):SetActive(false)
        self.BigAwardPanel.localPosition = Vector3(self.BigAwardPanel.localPosition.x + 374, 0, 0)
		self.BigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(1,1,1)
	else
        self.BigAwardPanel:FindChild("bg"):SetActive(true)
        self.BigAwardPanel.localPosition = Vector3(self.BigAwardPanel.localPosition.x - 374, 0, 0)
		self.BigAwardPanel:FindChild("BigAwardBtn/Dir").localScale = Vector3(-1,1,1)
    end
    self.openBigAward = not self.openBigAward
end

--初始化大奖列表
function  PirateTreasureGiftView:InitInfo(data)
	local list = data
	for _,v in pairs(self.PrefabInfo) do
		v.transform:SetActive(false)
	end
	for i = 1,#list do
		self:InfoItemData(i,list[i])
	end
end

--大奖玩家信息
function PirateTreasureGiftView:InfoItemData(index,InfoData)
	local tran = nil
	local item = nil
	if self.PrefabInfo[index] == nil then
        tran = self.Info_Item
        item = CC.uu.newObject(tran)
        item.transform.name = tostring(index)
        self.PrefabInfo[index] = item.transform
    else
        item = self.PrefabInfo[index]
    end
	item:SetActive(true)
	local headNode = item.transform:FindChild("ItemHead")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
	self.RankNum = self.RankNum + 1
	local param = {}
	param.parent = headNode
	param.portrait = InfoData.Portrait
	param.playerId = InfoData.PlayerId
	param.vipLevel = InfoData.Level
	param.clickFunc = "unClick"
	self:SetHeadIcon(param,self.RankNum)

	if item then
		item.transform:SetParent(self.Info_Content, false)
		item.transform:FindChild("Nick"):GetComponent("Text").text = InfoData.Name
		for _,v in ipairs(InfoData.Rewards) do
			if v.ConfigId >= 10001 or v.ConfigId <= 10006 then
				item.transform:FindChild("Num"):GetComponent("Text").text = self.propLanguage[v.ConfigId]
				break
			end
		end
        item.transform:FindChild("Time"):GetComponent("Text").text = os.date("%H:%M:%S %d/%m",InfoData.TimeStamp)
        item.transform:FindChild("bg"):SetActive(index % 2 == 0)
	end
end

-- 设置定时器
function PirateTreasureGiftView:SetCountDown(Seconds)
    self.remianTime = Seconds
    self:SetTimer(CC.uu.TicketFormat(self.remianTime))
	self:StartTimer("CountDown"..self.createTime, 1, function()
        local timeStr = CC.uu.TicketFormat(self.remianTime)
        if self.remianTime <= 0 then
			self:SetTimer("00:00:00")
            self:StopTimer("CountDown"..self.createTime)
            self:SetCountDown(120)
		else
			self:SetTimer(timeStr)
		end
		self.remianTime = self.remianTime - 1
    end, -1)
end

--设置时间
function PirateTreasureGiftView:SetTimer(remainTime)
    self:FindChild("BuyBtn/Time"):GetComponent("Text").text = remainTime
end

--删除头像对象
function PirateTreasureGiftView:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran and self.IconTab[tonumber(headtran.transform.name)] ~= nil then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

--设置头像
function  PirateTreasureGiftView:SetHeadIcon(param,i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function PirateTreasureGiftView:ActionIn()
end
function PirateTreasureGiftView:ActionOut()
    self:Destroy()
end

function PirateTreasureGiftView:OnDestroy()
	--CC.Sound.StopEffect()
	self:StopTimer("CountDown"..self.createTime)
	self:CancelAllDelayRun()
	if self.param and self.param.callBack then
		self.param.callBack(true)
	end
    for i,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
    end
	if self.walletView then
		self.walletView:Destroy()
	end
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
end

return PirateTreasureGiftView;