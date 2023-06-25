local CC = require("CC")
local M = CC.uu.ClassView("SlotGuideView")

local MaskMode = {
    "_MASKMODE_ROUND",
    "_MASKMODE_RECTANGLE",
    "_MASKMODE_MORE",
    "_MASKMODE_NULL"
}

function M:ctor()
    self.language = self:GetLanguage();
    self.steps = {};
end

function M:OnCreate()
    self:InitContent();
end

function M:InitContent()
    local stepsTran = self:FindChild("steps");
    self.maxStepCount = stepsTran.childCount;
    for i = 1 , self.maxStepCount do
        local step = stepsTran:GetChild(i-1);
        self:AddClick(step:FindChild("BtnNext"),function() self:OnClickNext(i+1) end);
        self:AddClick(step:FindChild("BtnBreak"),function() self:OnClickBreak() end);
        if i == self.maxStepCount then
            step:FindChild("BtnNext/Text").text = self.language["Btn_Over"];
        else
            step:FindChild("BtnNext/Text").text = self.language["Btn_Next"];
        end
        step:FindChild("BtnBreak/Text").text = self.language["Btn_Break"];
        if i == 1 then
            local gameId = CC.ViewManager.GetCurGameId();
            step:FindChild("Text").text = self.language["Guide_"..i.."_"..gameId];
        else
            step:FindChild("Text").text = self.language["Guide_"..i];
        end
        self.steps[step.name] = step;
    end

    self.material = self:FindChild("mask"):GetComponent("Image").material;
    for k,v in pairs(MaskMode) do
        if self.material:IsKeywordEnabled(v) then
            self.MaskMode = v
        end
    end
    self.material:DisableKeyword(self.MaskMode)
    self.material:EnableKeyword("_MASKMODE_NULL")
    self.MaskMode = "_MASKMODE_NULL"
    self.material:SetVector("_Center", Vector4(10000,0,0,0))
end

function M:OnClickNext(nextIndex)
    if not (nextIndex >= 1 and nextIndex <= self.maxStepCount) then
        self:GuideOver();
        return;
    end
    for name , step in pairs(self.steps) do
        local active = name == tostring(nextIndex);
        step.gameObject:SetActive(active);
    end
    CC.HallNotificationCenter.inst():post(CC.Notifications.OnSlotNotifyGamePos,nextIndex);
end

function M:OnClickBreak()
    self:GuideOver();
end

function M:GuideOver()
    CC.HallNotificationCenter.inst():post(CC.Notifications.OnSlotGuideOver);
    self:Destroy();
end

function M:SetHighlight(param,index)
    local scale = 1280 / Screen.width
    if 1280 / Screen.width < 720 / Screen.height then
        scale = 720 / Screen.height
    end
    local posX1, posY1, posX2, posY2 = 0, 0, 0, 0
    local sizeX1 = param.sizeX1 or 60
    local sizeY1 = param.sizeY1 or 60
    local sizeX2 = param.sizeX2 or 60
    local sizeY2 = param.sizeY2 or 60
    local offset_y = param.offset_y or 0
    if param.vect1 then
        posX1 = (param.vect1.x - Screen.width / 2) * scale
        posY1 = (param.vect1.y - Screen.height / 2) * scale
        if param.maskMode == "_MASKMODE_ROUND" then
            self.material:SetFloat("_Slider", sizeX1)
        end
        self.material:SetVector("_Center", Vector4(posX1,posY1,0,0))
        self.material:SetVector("_RectangleSize", Vector4(sizeX1,sizeY1,0,0))
    end
    if param.vect2 then
        posX2 = (param.vect2.x - Screen.width / 2) * scale
        posY2 = (param.vect2.y - Screen.height / 2) * scale
        self.material:SetVector("_Center1", Vector4(posX2,posY2,0,0))
        self.material:SetVector("_RectangleSize1", Vector4(sizeX2,sizeY2,0,0))
    end
    self.material:DisableKeyword(self.MaskMode)
    self.material:EnableKeyword(param.maskMode)
    self.MaskMode = param.maskMode
    index = tostring(index);
    if self.steps[index] then
        if index == "2" then
            self.steps[index]:FindChild("Arrow").localPosition = Vector3((posX1+posX2)/2, posY1 + offset_y, 0)
        else
            self.steps[index]:FindChild("Arrow").localPosition = Vector3(posX1, posY1 + offset_y, 0)
        end
    end
end

return M