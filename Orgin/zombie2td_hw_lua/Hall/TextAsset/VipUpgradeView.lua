local CC = require("CC")
local VipUpgradeView = CC.uu.ClassView("VipUpgradeView")

function VipUpgradeView:ctor(param)
	self.param = param or {}
    self.language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
    self.ItemList = {}
    --升级奖励
    self.upgrageCount = 0
    self.level = 0
end

function VipUpgradeView:OnCreate()
    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.vipNewRight = CC.ConfigCenter.Inst():getConfigDataByKey("VIPNewRights")
    self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
    self:InitContent();
    self:RegisterEvent()
end

function VipUpgradeView:InitContent()
    self.ItemParent = self:FindChild("RightsNode")
    self.Item = self:FindChild("RightsNode/Item")

	self:AddClick("BgBtn", function()
        self:Destroy()
    end);
    self:FindChild("MoreBtn"):SetActive(true)
    self:AddClick("MoreBtn", function()
        self:Destroy()
        CC.ViewManager.Open("PersonalInfoView", {Upgrade = 2})
    end)
    self.level = self.param.level or CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
    self:LanguageInit()
    self:InitViewUI()
end

function VipUpgradeView:LanguageInit()
    self:FindChild("MoreBtn/Text"):GetComponent("Text").text = self.language.lookRights
    self:FindChild("BgText"):GetComponent("Text").text = self.language.anyContinue
end

function VipUpgradeView:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.RefreshUI,CC.Notifications.OnVipUpgradeView)
end

function VipUpgradeView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnVipUpgradeView)
end

function VipUpgradeView:RefreshUI(level)
    self.level = level
    self:InitViewUI()
end

--界面
function VipUpgradeView:InitViewUI()
    if self.param.items then
        self.upgrageCount = self.param.items[1].Delta
    end
    if self.level > 0 then
        self:FindChild("Vip0"):SetActive(false)
        self:FindChild("VipLevel"):SetActive(true)
        self:FindChild("VipLevel/VipLevel/Text"):GetComponent("Text").text = self.level
        self:FindChild("VipLevel/Level/Text"):GetComponent("Text").text = self.level
    else
        self:FindChild("Vip0"):SetActive(true)
        self:FindChild("VipLevel"):SetActive(false)
    end
    local data = self:GetRightsInfo(self.level)
    if not data then
        self:VipUpgradeReward()
    else
        self:SethVipRightsIcon(data)
    end
end

function VipUpgradeView:GetRightsInfo(level)
	local viplevel = tonumber(level);
	if self.vipNewRight[viplevel + 1] then
		return self.vipNewRight[viplevel + 1]
	end
	return false
end

function VipUpgradeView:VipUpgradeReward()
    if self.param then
        for i,v in ipairs(self.param.items) do
            local item = nil
            item = CC.uu.newObject(self.Item)
            item.transform:SetParent(self.ItemParent, false)
            item:SetActive(true)
            if item then
                item.transform:FindChild("Num"):GetComponent("Text").text = v.Delta
                --item.transform:FindChild("Name"):GetComponent("Text").text = self.param.name
                self:SetImage(item.transform:FindChild("Icon"), self.propCfg[v.ConfigId].Icon);
            end
        end
    end
end

function VipUpgradeView:SethVipRightsIcon(info)
    --设置权益图标
    local list = info.RightsIcon
    for _,v in pairs(self.ItemList) do
        v.transform:SetActive(false)
    end
    for i = 1, #list do
        local item = nil
        if self.ItemList[i] == nil then
            item = CC.uu.newObject(self.Item)
            item.transform.name = tostring(i)
            self.ItemList[i] = item.transform
        else
            item = self.ItemList[i]
        end
        if item then
            item:SetActive(true)
            item.transform:SetParent(self.ItemParent, false)
            self:SetIconItemInfo(item, list[i])
        end
    end
end

function VipUpgradeView:SetIconItemInfo(item, data)
    self:SetImage(item.transform:FindChild("Icon"), self.HallDefine.VIPNewRights[data.Icon].Icon);
    local count = data.Count
    if data.Icon == 10007 then
        --升级奖励
        count = self.upgrageCount
    end
    if data.Icon == 10015 then
		--赠送税收
		count = count .. "%"
	elseif count <= 0 then
		count = ""
	elseif count >= 99999999999 then
		count = self.language.unlimited
	elseif count > 10000 then
		count = CC.uu.ChipFormat(data.Count)
	end
	item.transform:FindChild("Num"):GetComponent("Text").text = count
    item.transform:FindChild("Name"):GetComponent("Text").text = self.language.rightsIcon[data.Icon].name
    item.transform:FindChild("New"):SetActive(data.New)
    item.transform:FindChild("Max"):SetActive(data.Max)
    item.transform:FindChild("Up"):SetActive(data.Up)
	-- if CC.ViewManager.IsHallScene() then
	-- 	self:AddClick(item, function()
	-- 		item.transform:FindChild("New"):SetActive(false)
	-- 		item.transform:FindChild("Up"):SetActive(false)
	-- 		if data.Icon == 10003 then
	-- 			CC.ViewManager.Open("UnLockVipView", {viewType = 2});
	-- 		elseif data.Icon == 10005 then
	-- 			CC.ViewManager.Open("UnLockVipView", {viewType = 1});
	-- 		end
	-- 	end)
    -- end
end

function VipUpgradeView:ActionIn()
end

function VipUpgradeView:OnDestroy()
    self:unRegisterEvent()
end

return VipUpgradeView;