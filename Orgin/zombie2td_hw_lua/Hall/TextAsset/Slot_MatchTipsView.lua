--Author:lijundao
--Time:2020年08月18日 09:03:23 Tuesday
--Describe:
local ObjectPool = require("View/SlotMatch/Slot_MatchObjectPool")
local Slot_MatchTipItem = require("View/SlotMatch/Slot_MatchTipItem")
local CC = require("CC")
local M = CC.uu.ClassView("Slot_MatchTipsView")

-------------------------------------创建及初始化-----------------------------------
function M:OnCreate( ... )
    self.language = CC.LanguageManager.GetLanguage("L_SlotMatch");
    self:Init();
    self:RegisterEvent();
    self:Reset();
end

function M:Init()
    self.tipItemGo = self:FindChild("Slot_MatchTipItem");
    self:InitPool(self.tipItemGo,self.transform);
    self.limitMap = {};
end

function M:RegisterEvent()
    CC.HallNotificationCenter.inst():register(self,self.OnMatchTip,CC.Notifications.MATCHTIP);
end

function M:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self);
end

function M:InitPool(itemGo, tipContainer)
    local context = self;
    local r_flag = true
	local r_createFunc = function ()
		local obj
		if r_flag then
			obj = itemGo
			r_flag = false
		else
            obj = CC.uu.newObject(itemGo, tipContainer)
		end
		local item = Slot_MatchTipItem.new(obj,self.tipItemsPool,context)
		return item
    end
    local r_releaseFunc = function(obj)
        obj:Reset()
    end
    self.tipItemsPool = ObjectPool.New(r_createFunc,nil,r_releaseFunc)
    self.tipItemsPool:Release(self.tipItemsPool:Get()) ---隐藏预制体
end

-------------------------------------------事件---------------------------------

function M:OnMatchTip(str)
    self:Show(str);
end

------------------------------------显示-----------------------------------------
function M:Show(str)
    if self.limitMap[str] then
        return;
    end
    self.limitMap[str] = true;
    local tip = self.tipItemsPool:Get();
    tip:Refresh(str);
end

function M:Reset()
    self.tipItemsPool:RecycleAll();
end

-------------------------------------清理------------------------------------------
function M:ReleaseLimitMapItem(str)
    self.limitMap[str] = nil;
end

function M:OnDestroy()
    self:UnRegisterEvent();
    self.tipItemsPool:Clear();
end
return M


