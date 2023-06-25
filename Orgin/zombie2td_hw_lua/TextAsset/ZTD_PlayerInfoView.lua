local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local PlayerInfoView = ZTD.ClassView("ZTD_PlayerInfoView")

local  lanPlayerInfo = {
    personSign = "ลายเซ็นส่วนตัว:",
    selfPower = 'พลังคำนวณทั้งหมดของฉัน：',
}
function PlayerInfoView:OnCreate()
    print(self._args[1])
    self.playerdata = self._args[1]
    self.PlayerInfoCardList = {}
    self:Init()
end

function PlayerInfoView:Init()

    self.nameText = self:FindChild("imageRoot/namePanel/namestr"):GetComponent("Text")
    self.idText = self:FindChild("imageRoot/idPanel/idstr"):GetComponent("Text")
    self.infoText = self:FindChild("imageRoot/infoPanel/infostr"):GetComponent("Text")
    self.ImagePortrail = self:FindChild("imageRoot/Mask/ImagePortrail")
    self.powerStr = self:FindChild("imageRoot/cardPanel/powerPanel/powerStr"):GetComponent("Text")
    self:AddClick("imageRoot/btnClose", function()
        self:Destroy()
    end, false)
    local cardData = {
        [1] = {
            armPos = 1,
            basePower = 1,
            exPower   = 0,
            grade   = 1,
            id        = "1479760717321084928",
            power     = 1,
            status    = 0,
        },
        [2] = {
            armPos = 1,
            basePower = 1,
            exPower   = 0,
            grade   = 1,
            id        = "1479760717321084928",
            power     = 1,
            status    = 0,
        },
        [3] = {
            armPos = 1,
            basePower = 1,
            exPower   = 0,
            grade   = 1,
            id        = "1479760717321084928",
            power     = 1,
            status    = 0,
        },
    }
    local tempPowerStr = 0
    for i = 1, 3 do
        -- table.insert(cards, cardData);
        if self.playerdata.cards[i] and self.playerdata.cards[i] ~= nil then
            -- 是否装备 0 不装备 1号位 2号位 3号位
            cardData[i].armPos = self.playerdata.cards[i].Equip
            -- BasePower(基础算力)
            cardData[i].basePower = self.playerdata.cards[i].BasePower
            -- ExtendPower(额外算力)
            cardData[i].exPower = self.playerdata.cards[i].ExtendPower
            -- Quality品质
            cardData[i].grade = self.playerdata.cards[i].Quality
            -- ID 创建卡时生成
            cardData[i].id = self.playerdata.cards[i].ID 
            cardData[i].power = self.playerdata.cards[i].BasePower + self.playerdata.cards[i].ExtendPower
            -- 是否为绑定卡 0-未绑定 1-绑定
            cardData[i].status = self.playerdata.cards[i].status
            tempPowerStr = tempPowerStr + cardData[i].power
        else
            cardData[i] = nil
        end
    end

    for i = 1, 3 do
        -- local data = ZTD.NFTData.GetCard(id)
        if cardData[i] and cardData[i] ~= nil then
            local card = ZTD.NFTCard:new(cardData[i], self:FindChild("imageRoot/cardPanel/CellItem/Card" .. i))
            table.insert(self.PlayerInfoCardList, card)
        end
    end

    if self.playerdata.portrait and self.playerdata.s_uid then
        GC.SubGameInterface.SetHeadIcon(self.playerdata.portrait, self.ImagePortrail, self.playerdata.s_uid)
    end
    self.nameText.text = self.playerdata.nick--"潇湘"
    self.idText.text = self.playerdata.s_uid --"13032176521"
    self.infoText.text = lanPlayerInfo.personSign..self.playerdata.personSign--"这个人很懒，什么也没写"
    self.powerStr.text = lanPlayerInfo.selfPower..self.playerdata.total_power --tempPowerStr--"13032176521"
end

return PlayerInfoView