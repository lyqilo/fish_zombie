
local CC = require("CC")
local TemplateView = CC.uu.ClassView("TemplateView")

function TemplateView:ctor(param)

	self:InitVar(param);
end

function TemplateView:OnCreate()

	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function TemplateView:InitVar(param)

	self.param = param;
end

function TemplateView:InitContent()

end

function TemplateView:InitTextByLanguage()

end

function TemplateView:OnDestroy()

	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return TemplateView