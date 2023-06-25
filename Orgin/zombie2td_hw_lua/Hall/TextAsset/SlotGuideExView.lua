local CC = require("CC")
local M = CC.uu.ClassView("SlotGuideExView")

local scale

local MaskMode = {
    "_MASKMODE_ROUND",
    "_MASKMODE_RECTANGLE",
    "_MASKMODE_MORE",
    "_MASKMODE_NULL"
}

function M:ctor(param)
    self.param = param;
end

function M:OnCreate()
    self:InitContent(self.param);
end

function M:InitContent(param)
    self.maskMaterial = self:FindChild("mask"):GetComponent("Image").material;
    for k,v in pairs(MaskMode) do
        if self.maskMaterial:IsKeywordEnabled(v) then
            self.MaskMode = v
        end
    end
    self.maskMaterial:DisableKeyword(self.MaskMode)
    self.maskMaterial:EnableKeyword("_MASKMODE_NULL")
    self.MaskMode = "_MASKMODE_NULL"
    self.maskMaterial:SetVector("_Center", Vector4(10000,0,0,0))

    scale = 1280 / Screen.width
    if 1280 / Screen.width < 720 / Screen.height then
        scale = 720 / Screen.height
    end

    self.stepsTran = self:FindChild("steps");
    self.stepPre = self:FindChild("steps/stepPre").gameObject;
    self.steps = {};
    self:InitSteps(param);
end

function M:InitSteps(stepInfos)
    self.stepInfos = stepInfos;
    for i,stepInfo in ipairs(stepInfos) do
        local step = self:InitOneStep(stepInfo,i);
        table.insert(self.steps,step);
    end
    self.maxStepCount = #stepInfos;
end

function M:InitOneStep(stepInfo,index)
    local stepObj = {};
    local stepTran = self:GetStepTran();
    stepObj.transform = stepTran;
    stepObj.mainContent = stepTran:FindChild("mainContent");
    stepObj.image_girl = stepObj.mainContent:FindChild("image_girl");
    stepObj.text_content = stepObj.mainContent:FindChild("text_content");
    stepObj.btn_next = stepObj.mainContent:FindChild("BtnNext");
    stepObj.btn_break = stepObj.mainContent:FindChild("BtnBreak");
    stepObj.arrowPre = stepTran:FindChild("arrowPre");

    if stepInfo.mainContent then
        stepObj.mainContent.localPosition = Vector3(stepInfo.mainContent.x,stepInfo.mainContent.y,0);
    end
    if stepInfo.image_girl then
        stepObj.image_girl.localPosition = Vector3(stepInfo.image_girl.x,stepInfo.image_girl.y,0);
    end
    if stepInfo.text_content then
        stepObj.text_content.text = stepInfo.text_content.str;
        if stepInfo.text_content.pos then
            stepObj.text_content.localPosition = Vector3(stepInfo.text_content.pos.x,stepInfo.text_content.pos.y,0);
        end
    end
    if stepInfo.btn_next then
        if stepInfo.btn_next.pos then
            stepObj.btn_next.localPosition = Vector3(stepInfo.btn_next.pos.x,stepInfo.btn_next.pos.y,0);
        end
        stepObj.btn_next:FindChild("Text").text = stepInfo.btn_next.str;
        if stepInfo.btn_next.active == false then
            stepObj.btn_next.gameObject:SetActive(false)
        end
        if stepInfo.btn_next.isOverBtn == true then
            self:AddClick(stepObj.btn_next,function() self:OnClickBreak() end)
        else
            self:AddClick(stepObj.btn_next,function() self:OnClickNext(index+1) end)
        end
    end
    if stepInfo.btn_break then
        if stepInfo.btn_break.pos then
            stepObj.btn_break.localPosition = Vector3(stepInfo.btn_break.pos.x,stepInfo.btn_break.pos.y,0);
        end
        stepObj.btn_break:FindChild("Text").text = stepInfo.btn_break.str;
        if stepInfo.btn_break.active == false then
            stepObj.btn_break.gameObject:SetActive(false)
        end
        self:AddClick(stepObj.btn_break,function() self:OnClickBreak() end)
    end
    if stepInfo.arrows then
        for i,arrow in ipairs(stepInfo.arrows) do
            local newArrow = GameObject.Instantiate(stepObj.arrowPre).transform;
            newArrow:SetParent(stepTran,false);
            newArrow.localPosition = Vector3((arrow.x - Screen.width / 2) * scale,(arrow.y - Screen.height / 2) * scale,0);
            newArrow.localEulerAngles = Vector3(0,0,arrow.dir);
            newArrow.gameObject:SetActive(true)
        end
    end

    return stepObj;
end

function M:GetStepTran()
    local stepGameObejct = GameObject.Instantiate(self.stepPre);
    stepGameObejct.transform:SetParent(self.stepsTran,false);
    return stepGameObejct.transform;
end

--[[stepInfo = {
    mainContent = {x = 0, y = 0},
    image_girl = {x = 0, y = 0},
    text_content = {pos = {x = 0, y = 0}, str = ""},
    btn_next = {pos = {x = 0, y = 0}, str = "", isOverBtn = false, active = false},
    btn_break = {pos = {x = 0, y = 0}, str = "", active = false},
    arrows = {{x = 0,y = 0, dir = 0}},
    hightLightAreas = {{posX = 0,posY = 0,sizeX = 0,sizeY = 0}...}
}--]]

function M:OnClickNext(nextIndex)
    if not (nextIndex >= 1 and nextIndex <= self.maxStepCount) then
        self:GuideOver();
        return;
    end
    for i,step in ipairs(self.steps) do
        local active = i == nextIndex;
        step.transform.gameObject:SetActive(active);
    end
    if self.stepInfos[nextIndex].hightLightAreas then
        self:SetHighlight(self.stepInfos[nextIndex].hightLightAreas);
    end
end

function M:OnClickBreak()
    self:GuideOver();
end

function M:GuideOver()
    CC.HallNotificationCenter.inst():post(CC.Notifications.OnSlotGuideOver);
    self:Destroy();
end

function M:SetHighlight(hightLightAreas)
    for i,areaInfo in ipairs(hightLightAreas) do
        local posX = (areaInfo.posX - Screen.width / 2) * scale;
        local posY = (areaInfo.posY - Screen.height / 2) * scale;
        local sizeX = areaInfo.sizeX or 60;
        local sizeY = areaInfo.sizeY or 60;
        local shaderIndex = i == 1 and "" or tostring(i-1)
        self.maskMaterial:SetVector("_Center"..shaderIndex, Vector4(posX,posY,0,0))
        self.maskMaterial:SetVector("_RectangleSize"..shaderIndex, Vector4(sizeX,sizeY,0,0))
    end

    local maskMode = (#hightLightAreas)> 1 and "_MASKMODE_MORE" or "_MASKMODE_RECTANGLE"

    self.maskMaterial:DisableKeyword(self.MaskMode)
    self.maskMaterial:EnableKeyword(maskMode)
    self.MaskMode = maskMode
end

return M