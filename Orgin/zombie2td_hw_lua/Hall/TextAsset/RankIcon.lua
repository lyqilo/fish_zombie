local CC = require("CC")
local RankIcon = CC.class2("RankIcon")

function RankIcon:Create(param)
	self:InitVar(param);
	self:RegisterEvent();
	self:InitContent();
end

function RankIcon:InitVar(param)
    self.param = param or {};
    self.id = param.id
	self.activityDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Activity");
	self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
	self.selectTab = {}
end

function RankIcon:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnRefreshRankIconState, CC.Notifications.OnRefreshActivityBtnsState)
end

function RankIcon:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.OnRefreshActivityBtnsState)
end

function RankIcon:OnRefreshRankIconState(key,switchOn)
	if key == "MonthRankView" and not switchOn then
		if next(self.selectTab) then
			for i, v in ipairs(self.selectTab) do
				if v == "MonthRankView" then
					--隐藏赢分榜
					table.remove(self.selectTab, i)
					break
				end
			end
			if not next(self.selectTab) then
				--没有排行榜开启
				self.transform:SetActive(false)
			end
		else
			self.transform:SetActive(false)
		end
	end
	if key == "BatteryRankView" and not switchOn then
		--炮台排行榜
		self.selectTab = {}
		if not self.activityDataMgr.GetActivityInfoByKey("MonthRankView").switchOn then
			--赢分榜也关闭了
			self.transform:SetActive(false)
		end
	end
end

function RankIcon:InitContent()

	self.transform = CC.uu.LoadHallPrefab("prefab", "RankIcon", self.param.parent);

	self.transform.gameObject.layer = self.param.parent.transform.gameObject.layer;
	if self.activityDataMgr.GetActivityInfoByKey("BatteryRankView").switchOn and
		self.HallDefine.BatteryRank[self.id] and self.HallDefine.BatteryRank[self.id].Open then
		--炮台排行榜
		table.insert(self.selectTab, "BatteryRankView")
		if self.activityDataMgr.GetActivityInfoByKey("MonthRankView").switchOn then
			table.insert(self.selectTab, "MonthRankView")
		end
	end
    self:AddClick(self.transform, function ()
		if next(self.selectTab) then
			CC.ViewManager.Open("RankCollectionView",{selectTab = self.selectTab})
		else
            CC.ViewManager.Open("MonthRankView",{id = self.id})
        end
    end);

end

function RankIcon:AddClick(node, func, clickSound)
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

function RankIcon:Func( funcName )
	return function( ... )
		local func = self[funcName]
		if func then
			func( self, ... )
		end
	end
end

function RankIcon:Destroy()
	self:UnRegisterEvent()
end

return RankIcon