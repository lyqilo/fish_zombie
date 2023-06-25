
local CC = require("CC")

local DiffRankIcon = CC.class2("DiffRankIcon")

function DiffRankIcon:Create(param)
	self.param = param or {}
	self.IconTab = {}
    self:Init()
end

function DiffRankIcon:Init()
	self.transform = CC.uu.LoadHallPrefab("", "DiffRankIcon", self.param.parent)
	self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer
	self.Btn = self.transform:FindChild("btn")

	if self.param.data then
		self:Show(self.param.data)
	end
	self:AddClick(self.Btn,function ()
		if self.param.clickFunc then
			self.param.clickFunc(self.Btn)
		end
	 end)
end

function DiffRankIcon:Show(data)
	for i,v in ipairs(data) do
		local item = self.transform:FindChild("bg/no"..i)
		item:SetActive(true)
		
		self:SetHeadIcon({parent = item:FindChild("tx"),playerId = v.playerId,vipLevel = v.vipLevel,portrait = v.portrait,headFrame = v.headFrame,clickFunc = v.clickFunc})
	end
end

function DiffRankIcon:SetHeadIcon(param)
	local HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	table.insert(self.IconTab,HeadIcon)
end

function DiffRankIcon:SetBtnPos(pos)
	self.Btn.localPosition = pos
end

function DiffRankIcon:AddClick(node, func, clickSound)
	clickSound = clickSound or "click"

	if CC.uu.isString(func) then
		func = self:Func(func)
	end
	if not node then
		logError("按钮节点不存在")
		return
	end
	--在按下时就播放音效，解决音效延迟问题
	node.onDown = function (obj, eventData)
		CC.Sound.PlayHallEffect(clickSound)
	end

	if node == self.transform then
		node.onClick = function(obj, eventData)
			if eventData.rawPointerPress == eventData.pointerPress then
				func(obj, eventData)
			end
		end
	else
		node.onClick = function(obj, eventData)
			func(obj, eventData)
		end
	end
end

function DiffRankIcon:Func( funcName )
	return function( ... )
		local func = self[funcName]
		if func then
			func( self, ... )
		else
			logError("no func "..self.viewName..":"..funcName)
		end
	end
end

function DiffRankIcon:Destroy()
	for i,v in pairs(self.IconTab) do
        if v then
          v:Destroy()
          v = nil
      end
	end
end

return DiffRankIcon;
