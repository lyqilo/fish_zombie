local CC = require("CC")
local BatteryExchangeShop = CC.uu.ClassView("BatteryExchangeShop")

function BatteryExchangeShop:ctor(param)
	self:InitVar(param);
end

function BatteryExchangeShop:OnCreate()
	self.language = CC.LanguageManager.GetLanguage("L_BatteryLotteryView");
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self:InitContent();
    self.PrefabTab = {}
    self.viewCtr = self:CreateViewCtr(self.param);
    self.viewCtr:OnCreate();
    self.batteryList = {[1125] = "Battery_1125", [1127] = "Battery_1127", [1151] = "Battery_1151", [4023] = "Battery_4023",}
end

function BatteryExchangeShop:InitVar(param)
	self.param = param or {}
end

function BatteryExchangeShop:InitContent()
	self.isHall = CC.ViewManager.IsHallScene()

    self.Item = self:FindChild("Item")
    self.Parent = self:FindChild("ScrollView/Viewport/Content")
	self:AddClick(self:FindChild("close"), function() self:ActionOut() end)
	self:InitTextByLanguage()
end

function BatteryExchangeShop:InitTextByLanguage()
	self.Item:FindChild("BtnExchange/Text").text = self.language.BtnExchange
    self.Item:FindChild("BtnGray/Text").text = self.language.BtnExchange
    self.Item:FindChild("Count").text = self.language.BtnExchangeLimit
end

function BatteryExchangeShop:UpdateShop(data)
    if not data or #data <= 0 then return end
    for i = 1,#data do
        self:ItemData(i,data[i])
    end
end


function BatteryExchangeShop:ItemData(index,param)
	local item = self.PrefabTab[index]
	if not item then
		item = CC.uu.newObject(self.Item, self.Parent)
		item.transform.name = tostring(index)
		self.PrefabTab[index] = item.transform
	end
    if item then
    	item:SetActive(true)
        self:SetImage(item:FindChild("Prop"),self.propCfg[param.ConsumeConfigId].Icon)
        local count = CC.Player.Inst():GetSelfInfoByKey(param.ConsumeConfigId)
        item:FindChild("Prop/Text").text = string.format("%s/%s", count, param.ConsumeConfigCount)

        local isHave = 0
        if self.batteryList[param.GetConfigId] then
            isHave = CC.Player.Inst():GetSelfInfoByKey(param.GetConfigId) > 0 and 1 or 0
            item:FindChild("Icon"):SetActive(false)
            item:FindChild("Battery"):SetActive(true)

            local battery = nil
            battery = CC.uu.LoadHallPrefab("prefab", self.batteryList[param.GetConfigId], item:FindChild("Battery"))
            if battery then
                local spine = battery:FindChild("Spine"):GetComponent("SkeletonGraphic")
                if spine then
                    spine.AnimationState:ClearTracks()
                    spine.AnimationState:SetAnimation(0, "stand", true)
                end
                battery.transform.localScale = Vector3(0.5,0.5,0.5)
            end
        else
            isHave = param.ExchangeCount
            item:FindChild("Icon"):SetActive(true)
            item:FindChild("Battery"):SetActive(false)
            item:FindChild("Icon/Text").text = string.format("x%s",param.GetConfigCount)
            self:SetImage(item:FindChild("Icon"),self.propCfg[param.GetConfigId].Icon)
        end
        if isHave >= param.PlayerTotalLimit or count < param.ConsumeConfigCount then
            item:FindChild("BtnExchange"):SetActive(false)
            item:FindChild("BtnGray"):SetActive(true)
            if isHave >= param.PlayerTotalLimit then
                isHave = param.PlayerTotalLimit
                item:FindChild("BtnGray/Text").text = self.language.BtnOwned
            end
        else
            item:FindChild("BtnExchange"):SetActive(true)
            item:FindChild("BtnGray"):SetActive(false)
        end
        item:FindChild("Count/Text").text = string.format("%s/%s", isHave, param.PlayerTotalLimit)
        self:AddClick(item:FindChild("BtnExchange"),function()
            local data = {}
            data.ExchangeId = param.ExchangeId
            data.ActivitId = param.ActivitId
            CC.Request("ReqExchangeBattery", data)
        end)
    end
	
end

function BatteryExchangeShop:ActionIn()
end

function BatteryExchangeShop:ActionOut()
    self:Destroy()
end

function BatteryExchangeShop:OnDestroy()
    if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil;
    end
end

return BatteryExchangeShop