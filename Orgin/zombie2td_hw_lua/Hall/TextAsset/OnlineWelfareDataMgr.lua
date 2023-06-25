local CC = require("CC")
local this = {}
local config = nil
local list = nil
function this.GetRewardDataList()
	return this.LoadConfig()
end

function this.LoadConfig()
	if config == nil then
		config = CC.ConfigCenter.Inst():getConfigDataByKey("OnlineWelfare")
	end
	if list == nil then
		list = {}
		for i,v in ipairs(config) do
			local group = v.VipGroup
			if list[group] == nil then
				list[group] = {}
			end
			table.insert(list[group],v)
		end
	end
	return list
end

function this.GetMyBigRewardConfigId()
	local list = this.LoadConfig()
	local vip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
	local ConfigId
	if vip == 0 then
		ConfigId = list[1][1].ConfigId
	elseif vip >=1 and vip <=2 then
		ConfigId = list[2][1].ConfigId
	elseif vip >= 3 and vip <=9 then
		ConfigId = list[3][1].ConfigId
	else
		ConfigId = list[4][1].ConfigId
	end
	return ConfigId
end

return this