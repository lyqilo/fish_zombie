local CC = require("CC")
local PopupView = CC.uu.ClassView("PopupView")

function PopupView:ctor(index)
	self.index = index 
end

function PopupView:OnCreate()
	
	self.language = self:GetLanguage()
	self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
	self.NoticeData = CC.DataMgrCenter.Inst():GetDataByKey("NoticeData")
	self.popupList = CC.MessageManager.GetPopupList()

	self.liftScroller = self:FindChild("UILayout/LiftScroller/ScrollerController"):GetComponent("ScrollerController")
	self.liftScroller.myScroller.padding.top = self:GetTopDis()
	self.liftScroller:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:InitLiftTexture(tran,dataIndex,cellIndex) 
	end)
	self.liftScroller:AddRycycleAction(function(tran)
		self:RycycleItem(tran)
	end)
	self.liftScroller:InitScroller(#(self.popupList))
	self.liftScroller:JumpToDataIndex(self.index-1,0,0,true)

	self.rightScrollRect = self:FindChild("UILayout/RightScroller/Scroller")
	self.rightScroller = self:FindChild("UILayout/RightScroller/ScrollerController"):GetComponent("ScrollerController")
	self.rightScroller:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:InitRightTexture(tran,dataIndex,cellIndex) 
	end)
	self.rightScroller:InitScroller(#(self.popupList))
	self.rightScroller:JumpToDataIndex(self.index-1,0,0,true)

	self:SetReadPopup(self.index)
	self:InitContent(#(self.popupList))
	self:AddClickEvent()
	self:RegisterEvent()
	self:StartUpdate()
end

function PopupView:GetTopDis()
	local dis = 230 - (#(self.popupList) -1)*(58.8+5) +20 --230是只有一张广告时调试的基准数值，58.8是小图广告的高度117.6/2得到,5是Scroller设置的spacing10/2得到，20是经调试得到的最佳偏移值
	if #(self.popupList) >= 5 then dis = 10 end --5取决于广告的高度，目前小图广告的高度是117.6，测试下来广告数量超过5（含）设置为10看起来是最舒服的  ps:我也太照顾后面维护的同学了吧，hahahha……
	return dis
end

function PopupView:StartUpdate()
	UpdateBeat:Add(self.Update,self);
end

function PopupView:StopUpdate()
	UpdateBeat:Remove(self.Update,self);
end

function PopupView:Update()
	if self.isMove then
		self.moveTime = self.moveTime + Time.deltaTime
		if self.moveTime >= 5 then
			local curPos = self.rightScrollRect:FindChild("Container").localPosition
			self.moveTime = 0
			self:SetCanClick(false)
			self:RunAction(self.rightScrollRect:FindChild("Container"), {"localMoveTo",curPos.x - 940,curPos.y, 1,function() --940是广告的宽度，下同
				self:SetCanClick(true)
			end});
		end
	end
end

function PopupView:InitContent(count)
	if count > 1 then
		self.rightScrollRect.onBeginDrag = function ()
			self.isMove = false
		end
		self.rightScrollRect.onEndDrag = function ()
			local endPos = self.rightScrollRect:FindChild("Container").localPosition
			local tolDis = endPos.x / -940
			local part = math.floor(tolDis / 0.5)
			if part % 2 == 0 then
				part = part - 1
			end
			local min = part * 0.5
			local max = min + 1
			local targetPos = nil
			if tolDis - min > max - tolDis then
				targetPos = -940 * max
			else
				targetPos = -940 * min
			end
			self:SetCanClick(false)
			self:RunAction(self.rightScrollRect:FindChild("Container"), {"localMoveTo",targetPos,endPos.y, 0.3,function ()
				self.moveTime = 0
				self.isMove = true
				self:SetCanClick(true)
			end});
		end
	
		self.moveTime = 0
		self.isMove = true
	else
		self.isMove = false
		self.rightScroller:ToggleLoop()
	end
end

function PopupView:InitLiftTexture(tran,dataIndex,cellIndex)
	tran.name = dataIndex +1
	local id = self.popupList[dataIndex +1]
	self:LoadTexture(id,tran)

	--广告红点
	tran:FindChild("Redot"):SetActive(not (CC.MessageManager.IsReadByIndex(dataIndex +1)))
    --选中打开界面的第一张广告
	if self.index == dataIndex +1 and not self.init then
		self.init = true
		tran:FindChild("Redot"):SetActive(false)
		tran:FindChild("OnSelect"):SetActive(true)
		self.lastOnSelect = tran:FindChild("OnSelect")
	end

	if self.rycyleOnSelect and self.rycyleOnSelect == tostring(dataIndex +1) then
		tran:FindChild("OnSelect"):SetActive(true)
		self.lastOnSelect = tran:FindChild("OnSelect")
		self.rycyleOnSelect = nil
	end

	self:AddClick(tran:FindChild("Image"),function()
		if tran:FindChild("Redot").activeSelf then
			tran:FindChild("Redot"):SetActive(false)
		end
		if self.rycyleOnSelect then self.rycyleOnSelect = nil end
		
		if self.lastOnSelect and self.lastOnSelect.activeSelf then
			self.lastOnSelect:SetActive(false)
		end
		tran:FindChild("OnSelect"):SetActive(true)
		self.lastOnSelect = tran:FindChild("OnSelect")

		--设置广告已读
		self:SetReadPopup(dataIndex +1)
        --点击小图之后两秒后轮播，防止点击之后计时立马到5秒，立刻广告又切换了
		self.moveTime = 3
		--主显示区展示相应大图
		self.rightScroller:JumpToDataIndex(dataIndex,0,0,true)
	end)
end

function PopupView:RycycleItem(tran)
	if tran:FindChild("OnSelect").activeSelf then
		tran:FindChild("OnSelect"):SetActive(false)
		self.rycyleOnSelect = tran.name
	end
end

function PopupView:InitRightTexture(tran,dataIndex,cellIndex)
	tran.name = dataIndex +1
	local id = self.popupList[dataIndex +1]
	self:LoadTexture(id,tran)

	local data = CC.MessageManager.GetADInfoWithID(id)
	self:AddClick(tran:FindChild("Image"),function()
		--设置广告已读
		self:SetReadPopup(dataIndex +1)
		
		self:InitClickEvent(data) 
	end)
end

function PopupView:LoadTexture(id,tran)
	if CC.MessageManager.GetIconWithID(id) then
		tran:FindChild("Image"):GetComponent("RawImage").texture = CC.MessageManager.GetIconWithID(id)
		tran:FindChild("Image"):SetActive(true)
	else
		local param = {}
		param.id = id
		param.callback = function ()
			tran:FindChild("Image"):GetComponent("RawImage").texture = CC.MessageManager.GetIconWithID(id)
		    tran:FindChild("Image"):SetActive(true)
		end
		CC.MessageManager.ReadLocalAsset(param)
	end
end

function PopupView:SetReadPopup(index)
	local str = CC.LocalGameData.GetPopupState():split(":") or {}
	local b = true
	for i,v in ipairs(str) do
		if v == tostring(index) then b = false end
	end
	if b then
		--存储已读广告的index，用 ：连接成一个字符串
		CC.LocalGameData.SetPopupState(string.format("%s%s%s",CC.LocalGameData.GetPopupState(),index,":"))
	end
end

function PopupView:InitClickEvent(data)
	--执行广告操作
	CC.HallUtil.ClickADEvent(data)
	--看看操作需不需要退出当前广告
	local key = tonumber(data.MessageUseType)
	local switch = {
		[0] = function ()
			--无任何操作
		end,
		[1] = function ()
			--无任何操作
		end,
		[4] = function()
			--无任何操作
		end,  
		[8] = function()  
			--无任何操作
		end
	}
	local fSwitch = switch[key]
	if fSwitch then
		fSwitch()
	else
		self:ActionOut()
	end
end

function PopupView:AddClickEvent()
	self:AddClick("UILayout/CloseBtn",function() self:ActionOut() end)
end

function PopupView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.RequestSevenGift,CC.Notifications.OnPurchaseNotify)
end

function PopupView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnPurchaseNotify)
end

function PopupView:RequestSevenGift(param)
	if param.WareId == CC.PaymentManager.GetActiveWareIdByKey("sevenday") then
		CC.Request("Take7DaysReward",nil,function (err,data)
			CC.uu.Log(data,"Take7DaysReward")
			if data.State == 1 then
				CC.Player.Inst():SetSevenDays(data)
				CC.Player.Inst():OpenSevenDaysView()
				self:ActionOut()
			end
		end,function (err,data)
			logError("ActiveView: 7DaysReward failed:"..err)
			self:ActionOut()
		end)
		
	end
end

function PopupView:ReqGetNotice()
	local url = self.WebUrlDataManager.GetNoticeUrl()
	local www = CC.HttpMgr.Get(url,function (www)
		local table = Json.decode(www.downloadHandler.text)
		if table.status == 1 then 
			self.NoticeData.SetNotice(table.Title,table.data)
			if not CC.LocalGameData.GetNoticeState() then
				CC.LocalGameData.SetNoticeState(true)
				CC.ViewManager.OpenEx("ActiveView", true)
			end
		end
	end)
end

function PopupView:ActionIn()
	self:SetCanClick(false)
    self:FindChild("UILayout").transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self:FindChild("UILayout"), {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
end

function PopupView:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self:FindChild("UILayout"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
		self:Destroy();
	end})
end

function PopupView:OnDestroy()

	self:unRegisterEvent()
	self:StopUpdate()
end

return PopupView