local CC = require("CC")

local BackJumpView = CC.uu.ClassView("BackJumpView")

function BackJumpView:ctor(param)

    self.param = param

    self.jumpID = self.param.Jump

    self.language = CC.LanguageManager.GetLanguage("L_BackpackView");

    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
end

function BackJumpView:OnCreate()
    self:InitUI()
    self:InitTextByLanguage()
    self:InitContent()
    self:AddClickEvent()
end

function BackJumpView:InitUI()
    self.Sprite = self:FindChild("Layer_UI/Content/Sprite")
end

function BackJumpView:InitTextByLanguage()
    self:FindChild("Layer_UI/Title").text = self.language.jumpTitle
    self:FindChild("Layer_UI/Content/Label").text = self.language.enterTips
    self:FindChild("Layer_UI/JumpBtn/Text").text = self.language.sureBtn
end

function BackJumpView:InitContent()
    local sprite = "img_yxrk_"..self.jumpID
    self:SetImage(self.Sprite,sprite)
end

function BackJumpView:AddClickEvent()
    self:AddClick("Layer_UI/BtnClose","ActionOut")
    self:AddClick("Layer_UI/JumpBtn",function ()
        self:CheckGameState()
    end)
end

function BackJumpView:CheckGameState()
    local id = self.jumpID
    CC.ViewManager.CloseAllOpenView()
    CC.HallUtil.CheckAndEnter(id)
    local currentView = CC.ViewManager.GetCurrentView();
	--聚焦当前界面回调
	if currentView and currentView.OnFocusIn then
		currentView:OnFocusIn();
	end
end

function BackJumpView:OnDestroy()
end

return BackJumpView
