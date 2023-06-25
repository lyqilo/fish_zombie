
local CC = require("CC")

local SetUpView = CC.uu.ClassView("SetUpView")

local modelDefine = {
	--商店
	Store = 1,
	--换桌
	ChangeTable = 2,
	--声音
	Sound = 3,
	--客服
	Service = 4,
	--个人资料
	PersonalInfo = 5,
	--返回大厅
	BackHall = 6,
}

--[[
@param
OnBackToHall
]]
function SetUpView:ctor(param)

	self.param = param;
end

function SetUpView:OnCreate()

	local modelBtns;
	if CC.ViewManager.IsHallScene() then
		modelBtns = {
			modelDefine.Sound,
			modelDefine.Service,
			modelDefine.BackLogin,
		}
	else
		modelBtns = {
			modelDefine.Store,
			modelDefine.Sound,
			modelDefine.Service,
			modelDefine.PersonalInfo,
			modelDefine.BackHall,
		}
	end

	self:InitContent(modelBtns);
	self:InitTextByLanguage(modelBtns);
end

function SetUpView:InitContent(modelBtns)

	for _,number in ipairs(modelBtns) do
		local btn = self:FindChild("Bg/ItemBg"..number);
		if number == modelDefine.PersonalInfo then
			btn:SetActive(self.param.showPersonalInfo or false)
		else
			btn:SetActive(true);
		end
		self:AddClick(btn, function()
			self:OnClickFuncByModel(number);
		end);
	end

	self:AddClick("CoverBg", function()
			self:ActionOut();
		end, "click_setupclose");
end

function SetUpView:InitTextByLanguage(modelBtns)

	local language = self:GetLanguage();

	for _,number in ipairs(modelBtns) do
		local btnName = self:FindChild("Bg/ItemBg"..number.."/UnSelect/Name");
		btnName.text = language["titleName"..number];
	end
end

function SetUpView:OnClickFuncByModel(enum)

	if enum == modelDefine.Store then
		CC.ViewManager.Open("StoreView");
	elseif enum == modelDefine.ChangeTable then
 		self:OnChangeTable();
	elseif enum == modelDefine.Sound then
		CC.ViewManager.Open("SetUpSoundView");
	elseif enum == modelDefine.Service then
		CC.ViewManager.OpenServiceView();
	elseif enum == modelDefine.PersonalInfo then
		CC.ViewManager.Open("PersonalInfoView");
	elseif enum == modelDefine.BackHall then
		if self.param.OnBackToHall then
			self.param.OnBackToHall();
		else 
			self:OnBackToHall();
		end
	end

	self:Destroy();
end

function SetUpView:OnChangeTable()
end

function SetUpView:OnBackToHall()
	CC.ViewManager.GameEnterMainScene();
end

function SetUpView:ActionIn()

	self:SetCanClick(false);

	local frame = self:FindChild("Bg");
	frame.localScale = Vector3(0,0,0);


	self:RunAction(frame, {"scaleTo", 1, 1, 0.2, ease = CC.Action.EOutBack, function() 
			self:SetCanClick(true);
		end})
end

function SetUpView:ActionOut()

	self:SetCanClick(false);

	local frame = self:FindChild("Bg");
	self:RunAction(frame, {"scaleTo", 0, 0, 0.2, ease = CC.Action.EInBack,function()
			self:Destroy();
		end})
end

return SetUpView;