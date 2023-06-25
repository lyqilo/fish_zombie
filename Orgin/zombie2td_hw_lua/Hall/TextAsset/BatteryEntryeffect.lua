local CC = require("CC")
local BatteryEntryeffect = CC.uu.ClassView("BatteryEntryeffect")

function BatteryEntryeffect:ctor(param)
    self.param = param or {}
    --playerId必传
    self.entryEffecyId = self.param.propId
    self.entryEffect = {}
end

function BatteryEntryeffect:OnCreate()
    self.entryEffect[3054] = self:FindChild("3054")
    self.entryEffect[3055] = self:FindChild("3055")
    self.entryEffect[3056] = self:FindChild("3056")
    self.entryEffect[3059] = self:FindChild("3059")
    self.entryEffect[3060] = self:FindChild("3060")
    self.entryEffect[3061] = self:FindChild("3061")
    self.entryEffect[4020] = self:FindChild("4020")
    self.entryEffect[4021] = self:FindChild("4021")
    self.entryEffect[4022] = self:FindChild("4022")
    self:AddClick("Mask","ActionOut")
    if self.entryEffecyId and self.entryEffect[self.entryEffecyId] then
        self.entryEffect[self.entryEffecyId]:SetActive(true)
    end
end

function BatteryEntryeffect:OnDestroy()
end

return BatteryEntryeffect