
local CC = require("CC")

local Tip = CC.uu.ClassView("Tip")

--[[
@param
des: 文本内容
second: 存在时间
callback: 回调
]]
function Tip:ctor(param)

	self.des = param.des or "";

	self.second = param.second or 2;

	self.callback = param.callback;
end

function Tip:GlobalNode()
	if self:IsPortraitView() then
		return GameObject.Find("DontDestroyGNode/GPortraitCanvas/GMain").transform
	else
		return GameObject.Find("DontDestroyGNode/GCanvas/GMain").transform
	end
end

function Tip:OnCreate()
	self:InitContent();
	self:AddClickEvent()
	self:AddToDontDestroyNode();
end

function Tip:InitContent()

	local des = self:FindChild("Frame/Layout/Text");
	des.text = self.des;

	self:MoveIn();

	self:DelayRun(self.second, function()
			self:MoveOut();
		end)
end

function Tip:MoveIn()
	local frame = self:FindChild("Frame");
	self:RunAction(frame, {"localMoveBy", 0,  -frame.transform.height, 0.2, ease = CC.Action.EOutSine});
end

function Tip:MoveOut()
	local frame = self:FindChild("Frame")
	self:RunAction(frame, {"localMoveBy", 0, frame.transform.height, 0.2, ease = CC.Action.EOutSine,
			function()
				self:Destroy()
			end
		}
	)
end

function Tip:AddClickEvent()
	self:AddClick("Frame/Layout/Button",function ()
		if self.callback then
			self.callback()
		end
		self:MoveOut();
	end)
end

function Tip:SetButtonText(text)
	self:SetText("Frame/Layout/Button/Text", text)
end

function Tip:SetOneButton()
	self:FindChild("Frame/Layout/Button"):SetActive(true)
end

function Tip:SetFulfillIcon()
	self:FindChild("Frame/Layout/Fulfill"):SetActive(true)
end

return Tip;
