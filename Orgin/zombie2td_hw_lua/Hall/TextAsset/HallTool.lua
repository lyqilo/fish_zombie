local CC = require("CC")
local M = {}

function M.CheckEnterLimit(id)
    local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    local switchDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("SwitchDataMgr")
	local hallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
	local vipLimit = gameDataMgr.GetVipUnlockByID(id)
	if hallDefine.UnlockCondition[id] then
		local info = hallDefine.UnlockCondition[id]
		local lock = info.Lock
		local prop = info.Prop
		local view = info.View
		if not lock or switchDataMgr.GetSwitchStateByKey("TreasureGoods") then
			local propNum = CC.Player.Inst():GetSelfInfoByKey(prop) or 0
			if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") >= vipLimit or propNum > 0 then
				return true
			else
				return false
			end
		end
	end

	--正常VIP限制流程
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") < vipLimit then
		return false
	end
	return true
end

return M