
local CC = require("CC")
local BatteryGiftView = CC.uu.ClassView("BatteryGiftView")

function BatteryGiftView:ctor(param)

	self:InitVar(param);
end

function BatteryGiftView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();

	self.btnRoot = self:FindChild("Gift/Scroll/Viewport/Content")
	self.btnPrefab = self:FindChild("Gift/Scroll/Viewport/Content/Item")
	self.btnPrefab:SetActive(false)
	self.language = self:GetLanguage()
	-- self.animator = self:FindChild("F4BY_Battery10"):GetComponent("Animator")
    -- self.animator:Play("Effect_NiuDan_QiPao_Open",0,1)

	self:InitContent()
	self:ClickEvent()
end

function BatteryGiftView:InitVar(param)

	self.param = param or {}

	--顶部炮台icon
	self.IconList = {}
	--右侧动态炮台
	self.RightBatteryList = {}
	--左侧静态炮台
	self.LeftBatteryList = {}
	--spine动效
	self.SpineList = {}
	--当前正在显示第几个商品
	self.index = 1
	--要展示商品列表
	self.batteryIdList = {}
	--商品列表信息
	self.BatteryIdListInfo =  {{id = 1138, type = "Spine",wareId = "30353",save = "20%",name = 1},{id = 1136, type = "Spine",wareId = "30352",save = "20%",name = 2},
	{id = 1129, type = "Spine",wareId = "30351",save = "30%",name = 3},{id = 1123, type = "Animator",wareId = "30252",save = "50%",name = 4},
	{id = 1110, type = "Animator",wareId = "30250",save = "50%",name = 5}}

	for i, v in ipairs(self.BatteryIdListInfo) do
		local isHaveBattery = CC.Player.Inst():GetSelfInfoByKey(v.id) or 0
		if isHaveBattery <= 0 then
			table.insert(self.batteryIdList,v)
		end
	end
	self.GiftCount = #self.batteryIdList

	--礼包已经全部购买完成，赋一个默认值
	if self.GiftCount == 0 then
		self.batteryIdList = self.BatteryIdListInfo
	end
end

function BatteryGiftView:InitContent()
	self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform})
	self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
	self:FindChild("Gift/Content/Animal/Title").text = self.language.Preview
	for i, v in ipairs(self.batteryIdList) do
		--创建顶部icon
		local btnItem = self:ItemData(i);
		table.insert(self.IconList, btnItem);
		--左侧炮台
		local batteryName = "Battery_"..self.batteryIdList[i].id
		local battery = CC.uu.LoadHallPrefab("prefab", batteryName, self:FindChild("Gift/Content/Static/Battery"))
		battery:FindChild("ef"):SetActive(true)
		battery:SetActive(false)
		table.insert(self.LeftBatteryList, battery);
		if battery then
            if v.type == "Spine" then
                self.SpineList[v.id] = battery:FindChild("Spine"):GetComponent("SkeletonGraphic")
                self.SpineList[v.id].AnimationState:ClearTracks()
                self.SpineList[v.id].AnimationState:SetAnimation(0, "stand", true)
            end
        end

		--右侧炮台动画
		local batteryAnimator = CC.uu.LoadHallPrefab("prefab", batteryName, self:FindChild("Gift/Content/Animal/Image/Content"))
		batteryAnimator:GetComponent("Animator").enabled = true
		batteryAnimator:SetActive(false)
		table.insert(self.RightBatteryList, batteryAnimator);

        if batteryAnimator then
            if v.type == "Animator" then
				-- self.animator = battery:GetComponent("Animator")
    			-- self.animator:Play("anim_general_shoot",0,1)
            end
            if v.type == "Spine" then
                self.SpineList[v.id] = batteryAnimator:FindChild("Spine"):GetComponent("SkeletonGraphic")
                self.SpineList[v.id].AnimationState:ClearTracks()
                self.SpineList[v.id].AnimationState:SetAnimation(0, "shot", true)
            end
        end
	end

	--默认显示第一个
	self.IconList[1].toggle.isOn = true
	self.LeftBatteryList[1]:SetActive(true)
	self.RightBatteryList[1]:SetActive(true)
	--仅有一个商品时，toggle的selected方法没有走，设置了该段代码
	if self.GiftCount == 1 then
		local wareId = self.batteryIdList[1].wareId
		local price = self.wareCfg[wareId].Price
		self:FindChild("Gift/Content/Static/Title").text = self.language.batteryStrList[self.batteryIdList[1].name]
		self:FindChild("Gift/Content/Static/save/Text1").text = self.batteryIdList[1].save
		self:FindChild("Gift/Content/Static/Buy/Text").text = price
	end
end

--创建顶部icon
function BatteryGiftView:ItemData(index)
	local item = {}
	item.btn = CC.uu.newObject(self.btnPrefab, self.btnRoot)
	item.btn:SetActive(true);
	item.toggle = item.btn:GetComponent("Toggle");
	self:SetImage(item.btn:FindChild("Image"):GetComponent("Image"),"prop_img_"..self.batteryIdList[index].id)
	self:SetImage(item.btn:FindChild("Image/Image"):GetComponent("Image"),"prop_img_"..self.batteryIdList[index].id)
	UIEvent.AddToggleValueChange(item.btn, function(selected)
		if selected then
			self:ShowBatteryContent(index)
			self.index = index
			local wareId = self.batteryIdList[index].wareId
			local price = self.wareCfg[wareId].Price
			self:FindChild("Gift/Content/Static/Title").text = self.language.batteryStrList[self.batteryIdList[index].name]
			self:FindChild("Gift/Content/Static/save/Text1").text = self.batteryIdList[index].save
			self:FindChild("Gift/Content/Static/Buy/Text").text = price

			local isHaveBattery = CC.Player.Inst():GetSelfInfoByKey(self.batteryIdList[index].id) or 0
			self:FindChild("Gift/Content/Static/Buy/Gray"):SetActive(isHaveBattery > 0)
		end

	end)
	return item;
end
--显示炮台及对应动画
function BatteryGiftView:ShowBatteryContent(index)
	for i, value in ipairs(self.LeftBatteryList) do
		if i == index then
			value:SetActive(true)
		else
			value:SetActive(false)
		end
	end

	for i, value in ipairs(self.RightBatteryList) do
		if i == index then
			value:SetActive(true)
		else
			value:SetActive(false)
		end
	end
end

--点击事件
function BatteryGiftView:ClickEvent()
	self:AddClick("Gift/CloseBtn",function ()
		self:ActionOut()
		-- self.batteryIdList = self:MoveTable(self.batteryIdList,1)
		-- for i = 1, 5, 1 do
		-- 	self:SetImage(self.IconList[i].btn:GetComponent("Image"),"prop_img_"..self.batteryIdList[i])
		-- end
	end)
	self:AddClick("Gift/Content/Static/Buy",function ()
		local wareId = self.batteryIdList[self.index].wareId
		local price = self.wareCfg[wareId].Price

		local isHaveBattery = CC.Player.Inst():GetSelfInfoByKey(self.batteryIdList[self.index].id) or 0
		if isHaveBattery > 0 then
			CC.ViewManager.ShowTip(self.language.error);
			return
		end
		self.viewCtr:OnPay(wareId,price)
	end)
	self:AddClick("Gift/Content/LeftBtn",function ()
		self:SetIndex(self.index -1,false)
	end)
	self:AddClick("Gift/Content/RightBtn",function ()
		self:SetIndex(self.index +1,true)
	end)
end
--三角按钮点击事件
function BatteryGiftView:SetIndex(index,isRight)
	if index > #self.IconList then
		index = 1
	elseif index <= 0 then
		index = #self.IconList
	end
	local isHaveBattery = CC.Player.Inst():GetSelfInfoByKey(self.batteryIdList[index].id) or 0
	if isHaveBattery > 0 then
		if isRight then
			index = index +1
		else
			index = index -1
		end
		self:SetIndex(index)
		return
	end
	
	if  index <= 0 then
		self.IconList[#self.IconList].toggle.isOn = true
	elseif index > #self.IconList then
		self.IconList[1].toggle.isOn = true
	else
		self.IconList[index].toggle.isOn = true
	end
end
--购买完成后置灰按钮
function BatteryGiftView:ShowBuyGaeyBtn()
	self.GiftCount = self.GiftCount -1
	if self.GiftCount <= 0 then
		if self.param.CloseView then
			self.param.CloseView()
			return
		end
	end

	self.IconList[self.index].btn:SetActive(false)
	self.LeftBatteryList[self.index]:SetActive(false)
	self.RightBatteryList[self.index]:SetActive(false)

	self:SetIndex(self.index +1)


	-- self:FindChild("Gift/Content/Static/Buy/Gray"):SetActive(true)
end
--表中数据移动n位
function BatteryGiftView:MoveTable(table,n)
	local newTab = {}
	for i = 1, #table, 1 do
		newTab[i] = table[(n-1+i) % #table +1]
	end
	return newTab
end

function BatteryGiftView:ActionIn()
    self:SetCanClick(false);
    if self.param and self.param.isOffset then
        self.transform.localPosition = Vector3(125/2, 0, 0)
    end
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function BatteryGiftView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function BatteryGiftView:OnDestroy()
	for _, v in pairs(self.SpineList) do
        v = nil
    end
	for _, v in pairs(self.RightBatteryList) do
        v = nil
    end
	for _, v in pairs(self.LeftBatteryList) do
        v = nil
    end

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end

	if self.walletView then
		self.walletView:Destroy()
	end
end

return BatteryGiftView