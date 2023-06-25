local GC = require("GC")
local ZTD = require("ZTD")

local DragonTreasureRetView = ZTD.ClassView("ZTD_DragonTreasureRetView")

function DragonTreasureRetView:ctor(data)
    self.data = data
    -- log("data="..GC.uu.Dump(data))
end

function DragonTreasureRetView:OnCreate()
    ZTD.PlayMusicEffect("ZTD_congratulations", nil, nil, true)
	self:PlayAnimAndEnter()
    self:InitData()
    self:InitUI()
    self:AddEvent()
end

function DragonTreasureRetView:InitData()
    --宝箱奖励信息
    self.boxRetInfoList = {}
    --翻倍消耗的金币
    self.coinNum = self.data.DoublingCost
    -- log("coinNum="..tostring(self.coinNum))
    --翻倍结束（不论成功与否）
    self.isOverDoubling = false

    self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_GiftCollectionView")
    self.tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
    self.tipText = self:FindChild("root/tip")
    self.coinNumText = self:FindChild("root/doubleBtn/doubbleCoin/coinNum"):GetComponent("Text")
    self.retNode = self:FindChild("root/retNode")
    self.doubleBtn = self:FindChild("root/doubleBtn")
    self.confirmBtn = self:FindChild("root/confirmBtn")
    self.closeBtn = self:FindChild("root/closeBtn")
    self.titleText = self:FindChild("root/title/Text"):GetComponent("Text")
    self.Glow01Effect = self:FindChild("Glow01")
end

function DragonTreasureRetView:InitUI()
    self.doubleBtn:FindChild("Text"):GetComponent("Text").text = self.language.txt_dragonTreasureRet_doubleBtn
    self.confirmBtn:FindChild("Text"):GetComponent("Text").text = self.language.txt_dragonTreasureRet_confirmBtn
    self.closeBtn:FindChild("Text"):GetComponent("Text").text = self.tipLanguage.txt_btn_confirm
    self.titleText.text = self.language.txt_dragonTreasureRet_title
    self.tipText:GetComponent("Text").text = self.language.txt_dragonTreasureRet_tip
    self.coinNumText.text = self.coinNum
    self:RefreshRetInfo()
end

function DragonTreasureRetView:AddEvent()
    self:AddClick("root/confirmBtn", function()
        self:OnClickDouble(false)
    end)
    self:AddClick("root/doubleBtn", function()
        self:OnClickDouble(true)
    end)
    self:AddClick("root/closeBtn","PlayAnimAndExit")
end

--获取对应图片
function DragonTreasureRetView:GetSprite(id)
    if id == 2 then
        return "ztd_jinbimultiple"
    elseif id == 1112 then
        return "tf_bs1"
    elseif id == 1113 then
        return "tf_bs2"
    elseif id == 1114 then
        return "tf_bs3"
    elseif id == 1115 then
        return "tf_bs4"
    elseif id == 1102 then
        return "jll_icon_l1102"
    elseif id == 1103 then
        return "jll_icon_l1103"
    elseif id == 1104 then
        return "jll_icon_l1104"
    elseif id == 1105 then
        return "jll_icon_l1105"
    elseif id == 1106 then
        return "ztd_sevenday"
    end
end

--刷新开箱信息
function DragonTreasureRetView:RefreshRetInfo()
    -- logError("boxRetInfoList="..GC.uu.Dump(self.boxRetInfoList)) 
    local index = 1
    for k, v in ipairs(self.data.Reward) do
        local item = ZTD.Extend.LoadPrefab("ZTD_DragonTreasureRetItem", self.retNode)
        local str = self:GetSprite(v.PropID)
        item:FindChild("Image"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", str)
        item:FindChild("Image"):GetComponent("Image"):SetNativeSize()
        item:FindChild("Text"):GetComponent("Text").text = v.PropNum
        if not self.boxRetInfoList[index] then
            self.boxRetInfoList[index] = {}
        end
        self.boxRetInfoList[index].obj = item
        self.boxRetInfoList[index].id = v.PropID
        self.boxRetInfoList[index].num = v.PropNum
        index = index + 1
    end
    if self.data.AddReward then
        for k, v in ipairs(self.data.AddReward) do
            local item = ZTD.Extend.LoadPrefab("ZTD_DragonTreasureRetItem", self.retNode)
            local str = self:GetSprite(v.PropID)
            item:FindChild("Image"):GetComponent("Image").sprite = ZTD.Extend.LoadSprite("prefab", str)
            item:FindChild("Image"):GetComponent("Image"):SetNativeSize()
            item:FindChild("Text"):GetComponent("Text").text = v.PropNum
            if not self.boxRetInfoList[index] then
                self.boxRetInfoList[index] = {}
            end
            self.boxRetInfoList[index].obj = item
            self.boxRetInfoList[index].id = v.PropID
            self.boxRetInfoList[index].num = v.PropNum
            index = index + 1
        end
    end
end

--翻倍结果处理
function DragonTreasureRetView:RefreshDoubleInfo(data, IsDoubling)
    --log("data="..GC.uu.Dump(data))
    -- data = {Reward = {[1] = {PropID = 1, PropNum = 2999}, [2] = {PropID = 2, PropNum = 2999}}, DoublingCost = 1999, IsDouble = true}
    if data.IsDouble then
        ZTD.PlayMusicEffect("ZTD_congratulations", nil, nil, true)
        self.Glow01Effect:SetActive(false)
        self.Glow01Effect:SetActive(true)
        self.titleText.text = self.language.txt_dragonTreasureRet_succtitle
    else
        self.titleText.text = self.language.txt_dragonTreasureRet_failtitle
    end
    self.tipText:SetActive(false)
    if IsDoubling then
        self.doubleBtn:SetActive(false)
        self.confirmBtn:SetActive(false)
        self.closeBtn:SetActive(true)
        -- log("boxRetInfoList="..GC.uu.Dump(self.boxRetInfoList))
        for k, v in pairs(self.boxRetInfoList) do
            for i, j in pairs(data.Reward) do
                if j.PropID == v.id then
                    v.obj:FindChild("Text"):GetComponent("Text").text = j.PropNum
                end
            end
            if data.AddReward then
                for m, n in pairs(data.AddReward) do
                    if n.PropID == v.id then
                        v.obj:FindChild("Text"):GetComponent("Text").text = n.PropNum
                    end
                end
            end
        end
    else
        self:Destroy()
    end
end

--点击翻倍
function DragonTreasureRetView:OnClickDouble(IsDoubling)
    local playerId = ZTD.PlayerData.GetPlayerId()
    local ChouMa = ZTD.TableData.GetData(playerId, "Money")
    -- log("ChouMa="..tostring(ChouMa).."  coinNum="..tostring(self.coinNum))
    -- log("IsDoubling="..tostring(IsDoubling))
    if self.coinNum > ChouMa and IsDoubling then
		local param = {
			ChouMa = ZTD.TableData.GetData(playerId, "Money"),
			Integral = GC.SubGameInterface.GetHallIntegral(),
		}
		GC.SubGameInterface.ExOpenShop(param)
       return 
    end
    --如果翻倍结束，点击确定按钮
    if not IsDoubling and self.isOverDoubling then
        self:Destroy()
        return
    end
    local succCb = function(err, data)
        -- log("CSDoublingBoxReq data="..GC.uu.Dump(data))
        self.isOverDoubling = true
        self:RefreshDoubleInfo(data, IsDoubling)
    end
    local errCb = function(err, data)
        logError("CSDoublingBoxReq err="..GC.uu.Dump(err))
    end
    --翻倍请求
    ZTD.Request.CSDoublingBoxReq({IsDoubling = IsDoubling}, succCb, errCb)
end

function DragonTreasureRetView:OnDestroy()
    if self.boxRetInfoList then
        for k, v in ipairs(self.boxRetInfoList) do
            GC.uu.destroyObject(v.obj)
        end
    end
    self.boxRetInfoList = nil
end

return DragonTreasureRetView