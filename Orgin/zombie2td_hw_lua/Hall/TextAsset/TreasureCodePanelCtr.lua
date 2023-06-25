---------------------------------
-- region TreasureCodePanelCtr.lua	-
-- Date: 2019.11.11				-
-- Desc: 一元夺宝				-
-- Author:Chaoe					-
---------------------------------
local CC = require("CC")

local TreasureCodePanelCtr = CC.class2("TreasureCodePanelCtr")

function TreasureCodePanelCtr:ctor(view, param)
	self:InitVar(view, param)
end

function TreasureCodePanelCtr:InitVar(view,param)
    self.param = param

	self.view = view

	self.language = CC.LanguageManager.GetLanguage("L_TreasureView");

	self.realDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("RealStoreData")

	-- self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")

    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
end

function TreasureCodePanelCtr:OnCreate()
    self:RegisterEvent()
    if not self.param.CodeList then
        local data = {}
        data.PrizeId = self.param.PrizeId
        data.Issue = self.param.Issue
        CC.Request("Req_PlayerLuckyCode",data)
    else
        self.CodeList = self.param.CodeList.Numbers
        self:SetCodeList(self.param)
    end
end

function TreasureCodePanelCtr:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.PlayerLuckyCodeResp,CC.Notifications.NW_Req_PlayerLuckyCode)
end

function TreasureCodePanelCtr:UnRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.NW_Req_PlayerLuckyCode)
end

function TreasureCodePanelCtr:PlayerLuckyCodeResp(err,data)
    if err == 0 then
        self.CodeList = data.Numbers
        self:SetCodeList(data)
    end
end

function TreasureCodePanelCtr:SetCodeList(data)
    local count = 0
    if data.CodeList then
        count = #data.CodeList.Numbers
    else
        count = #data.Numbers
    end
    self.view:SetCodeList(count)
end

function TreasureCodePanelCtr:SetCodeData(tran,dataIndex,cellIndex)
    local index = dataIndex + 1
    local num = self.CodeList[index]
    self.view:SetCodeItem(tran,num)
end

function TreasureCodePanelCtr:Destroy()
	self:UnRegisterEvent();

	self.view = nil;
end

return TreasureCodePanelCtr