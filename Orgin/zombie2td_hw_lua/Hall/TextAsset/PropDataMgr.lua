local CC = require("CC")

local PropDataMgr = {}
local this = PropDataMgr

local propData
local function GetPropData()
	if propData == nil then
		-- propData = {}
		-- local propConfig = require("Model/Config/CSVExport/Prop")
		-- for _,v in ipairs(propConfig or {}) do
		-- 	propData[v.Id] = v
		-- end
		propData = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	end
	return propData
end
local language
local function GetLanguage()
	if language == nil then
		language = CC.LanguageManager.GetLanguage("L_Prop")
	end
	return language
end

local function warning( id , p)
	logWarn(string.format("Prop ConfigId-%d, %s is null",id,p))
end

function this.GetProp( ConfigId )
	local prop = GetPropData()[ConfigId]
	if prop then
		return prop
	else
		warning(ConfigId,"Prop")
	end
end

function this.GetIcon( ConfigId, Count )
	local prop = GetPropData()[ConfigId]
	if ConfigId == CC.shared_enums_pb.EPC_TenGift_Sign_97 then
		return this.GetWaterIcon(Count)
	else
		if prop and prop.Icon~=nil and prop.Icon~="" then
			return prop.Icon
		else
			warning(ConfigId,"Icon")
		end
	end
end

function this.GetChipIcon( Count )
	if Count == nil then
		return this.GetIcon( CC.shared_enums_pb.EPC_ChouMa )
	end

	-- Coin1~11
	return "Coin"..this.GetChipLevel(Count)
end

function this.GetWaterIcon(Count)
	if not Count or Count < 5 then
		return "prop_img_97"
	elseif Count < 7 then
		return "psj_qd_wp_sd01"
	elseif Count < 10 then
		return "psj_qd_wp_sd02"
	elseif Count < 12 then
		return "psj_qd_wp_sd03"
	else
		return "psj_qd_wp_sd04"
	end
end

function this.GetLanguageDesc( ConfigId, Count )
	local lan = GetLanguage()[ConfigId]
	if lan then
		if ConfigId == CC.shared_enums_pb.EPC_ChouMa or
			ConfigId == CC.shared_enums_pb.EPC_Speaker or
			ConfigId == CC.shared_enums_pb.EPC_GiftVoucher or
			ConfigId == CC.shared_enums_pb.EPC_New_GiftVoucher then -- 考虑增加配置
			if tonumber(Count) then
				return CC.uu.ChipFormat(Count)..lan
			else
				return Count..lan
			end
		end
		return lan
	else
		warning(ConfigId,"language")
		return ""
	end
end

function this.GetChipDesc( Count )
	return this.GetLanguageDesc( CC.shared_enums_pb.EPC_ChouMa, Count )
end

function this.CheckIsPhysical( ConfigId )
	local prop = GetPropData()[ConfigId]
	if prop and prop.Physical~=nil then
		return prop.Physical
	else
		warning(ConfigId,"Physical")
	end
end

function this.CheckIsReward( ConfigId )
	local prop = GetPropData()[ConfigId]
	if prop and prop.IsReward~=nil then
		return prop.IsReward
	else
		warning(ConfigId,"IsReward")
	end
end

function this.GetChipLevel( Count )
	if Count >= 0 and Count < 1000 then
		return 1
	elseif Count >= 1000 and Count < 5000 then
		return 2
	elseif Count >= 5000 and Count < 10000 then
		return 3
	elseif Count >= 10000 and Count < 20000 then
		return 4
	elseif Count >= 20000 and Count < 50000 then
		return 5
	elseif Count >= 50000 and Count < 100000 then
		return 6
	elseif Count >= 100000 and Count < 200000 then
		return 7
	elseif Count >= 200000 and Count < 500000 then
		return 8
	elseif Count >= 500000 and Count < 1000000 then
		return 9
	elseif Count >= 1000000 and Count < 5000000 then
		return 10
	elseif Count >= 5000000 then
		return 11
	else
		return 3
	end
end

return this