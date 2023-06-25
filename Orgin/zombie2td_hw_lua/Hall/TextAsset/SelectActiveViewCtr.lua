local CC = require("CC")

local SelectActiveViewCtr = CC.class2("SelectActiveViewCtr")
local configData = nil

function SelectActiveViewCtr:ctor(view,content)
	self.viewTab = {}
	self.configData = {
		{
			Id = 1,
			PrefabName = "NoviceGiftView"
		}
		-- {
		-- 	Id = 2,
		-- 	PrefabName = "NoviceGiftView1"
		-- }
	}
	self:InitVar(view, content)
	
end

function SelectActiveViewCtr:OnCreate()
	--self:InitData();
end

function SelectActiveViewCtr:Destroy()
	for i,v in ipairs(self.viewTab) do
		self.viewTab[i]:Destroy()
	end
end


function SelectActiveViewCtr:InitVar(view, content)
	--UI对象
	self.view = view;
	--父节点
	self.content = content
	--加载礼包 prefab
	self:LoadPanel()
end

--加载礼包
function SelectActiveViewCtr:LoadPanel()
	for i,v in ipairs(self.configData) do
		self.viewTab[i] = CC.uu.CreateHallView(self.configData[i].PrefabName,self.content)
	end	
end

--返回每次位移的value
function SelectActiveViewCtr:GetHorizontalMoveSize()
	local count = #self.configData
	local size = 1 / (count - 1)
	return size
end

function SelectActiveViewCtr:InitData()
end

return SelectActiveViewCtr