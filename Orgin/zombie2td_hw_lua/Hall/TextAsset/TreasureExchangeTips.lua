local CC = require("CC")

local TreasureExchangeTips = CC.uu.ClassView("TreasureExchangeTips")

function TreasureExchangeTips:ctor(param)
	self:InitVar(param)
end

function TreasureExchangeTips:InitVar(param)
	self.param = param
	self.language = CC.LanguageManager.GetLanguage("L_TreasureView")
	self.tipsConfig = CC.ConfigCenter.Inst():getConfigDataByKey("PhysicalExchangeTips")
	self.curOption = 0
end

function TreasureExchangeTips:OnCreate()
	self:InitContent()
	self:InitConfig()
	self:InitTextByLanguage()
	self:AddExchangeTipDropdown()
end

function TreasureExchangeTips:InitContent()
	self.scrollContent = self:FindChild("Content/Scroll View/Viewport/Content")
	self.dropDownComp = self.scrollContent:FindChild("Card/CurSelect/Dropdown"):GetComponent("Dropdown")
	self.cardTipItem = self:FindChild("Content/CardTipItem")
	self.cardDesc = self:FindChild("Content/CardDesc")
	self:AddClick("Mask","ActionOut")
	self.dropDownComp:SetHighlightedColor(UnityEngine.Color32(240,201,18,255))
end

function TreasureExchangeTips:InitConfig()
	local VipLevel = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	self.dropDownList = {}
	for i,v in ipairs(self.tipsConfig) do
		local data = {}
		data.Option = string.format(self.language.dropdown_vip,v.MinVip,v.MaxVip)
		data.item = {}
		if v.MinVip == 0 and v.MaxVip == 0 then
			--vip0特殊处理
			data.isSpecial = true
		end
		for j=1,5 do
			table.insert(data.item,v["Item"..j])
		end
		table.insert(self.dropDownList,data)
		if VipLevel >= v.MinVip and VipLevel <= v.MaxVip then
			self.curOption = i
		end
	end
end

function TreasureExchangeTips:InitTextByLanguage()
	self:FindChild("BG/Title/Text").text = self.language.tipsButton
	self.scrollContent:FindChild("Card/CurSelect/Text").text = self.language.dropdown_des
	self.scrollContent:FindChild("Card/Text").text = self.language.cardTitle
	self.scrollContent:FindChild("Physical/Text").text = self.language.physicalTitle
	self.scrollContent:FindChild("Virtual/Text").text = self.language.virtualTitle
	self.scrollContent:FindChild("PhysicalList/ListDesc").text = self.language.physicalDesc
	self.scrollContent:FindChild("VirtualList/ListDesc").text = self.language.virtualDesc
	self.cardDesc.text = self.language.cardDesc
end

function TreasureExchangeTips:AddExchangeTipDropdown()
	self.dropDownComp:ClearOptions()
	local OptionData = UnityEngine.UI.Dropdown.OptionData
	local data = OptionData.New(self.language.dropdown_all)
	self.dropDownComp.options:Add(data)
	for i,v in ipairs(self.dropDownList) do
		data = OptionData.New(v.Option)
		self.dropDownComp.options:Add(data)
		self:AddCardExchangeTips(i,v)
	end
	UIEvent.AddDropdownValueChange(
		self.dropDownComp.transform,
		function (value)
			self:OnDropdownValueChange(value)
		end)
	self.cardDesc:SetParent(self.scrollContent:FindChild("CardList"))
	self.cardDesc:SetActive(true)
	self.dropDownComp.value = self.curOption
	self.dropDownComp:RefreshShownValue()
end

function TreasureExchangeTips:OnDropdownValueChange(index)
	for i,v in ipairs(self.dropDownList) do
		v.contentTrans:SetActive(index == 0 or index == i)
	end
	self.scrollContent.localPosition = Vector3.zero
end

function TreasureExchangeTips:AddCardExchangeTips(index,data)
	local contentTrans = CC.uu.UguiAddChild(self.scrollContent:FindChild("CardList"),self.cardTipItem,data.Option)
	contentTrans:FindChild("Title").text = data.Option
	contentTrans:FindChild("Form/ItemGroup/Item0_1").text = self.language.cardType
	if data.isSpecial then
		contentTrans:FindChild("Form/ItemGroup/Item0_2").text = self.language.cardLimitSp
	else
		contentTrans:FindChild("Form/ItemGroup/Item0_2").text = self.language.cardLimit
	end
	for i,v in ipairs(self.dropDownList[index].item) do
		contentTrans:FindChild("Form/ItemGroup/Item"..i.."_2").text = v
	end
	self.dropDownList[index].contentTrans = contentTrans
end

function TreasureExchangeTips:OnDestroy()
	
end

return TreasureExchangeTips