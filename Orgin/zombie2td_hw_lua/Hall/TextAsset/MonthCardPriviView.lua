
local CC = require("CC")
local MonthCardPriviView = CC.uu.ClassView("MonthCardPriviView")

function MonthCardPriviView:ctor()
    self.language = CC.LanguageManager.GetLanguage("L_MonthCardView")
    self.Cfg = {{true,false,true},
                {true,false,false},
                {true,false,true},
                {true,false,true},

                {false,true,true},
                {false,true,false},
                {false,true,true},
                {true,true,false},

                {false,false,true},
                {false,false,true},
               }
end

function MonthCardPriviView:OnCreate()
    
    self:FindChild("Frame/Tittle/Text").text = self.language.morePrivi
    self:FindChild("Frame/Tip").text = self.language.tip

    for i = 1,10 do
        self:FindChild("Frame/Scroll View/Viewport/Content/"..i.."/Details/Text").text = self.language["Privi"..i]
        for index = 1,3 do
            self:FindChild("Frame/Scroll View/Viewport/Content/"..i.."/State"..index.."/Image"):SetActive(self.Cfg[i][index])
        end
    end

    self:AddClick(self:FindChild("Frame/BtnClose"),"ActionOut",nil,true)
end

function MonthCardPriviView:ActionIn()
	self:SetCanClick(false)
    self:FindChild("Frame").transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self:FindChild("Frame"), {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
    CC.Sound.PlayHallEffect("click_boardopen");
end

function MonthCardPriviView:ActionOut()
	self:SetCanClick(false);
    self:RunAction(self:FindChild("Frame"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})
end

return MonthCardPriviView