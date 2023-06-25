
local CC = require("CC")
local proto = {}

local pbFiles = {
	"client_client_pb",
	"shared_message_pb",
	"client_supply_pb",
	"client_msign_pb",
	"shared_common_pb",
	"client_activity_pb",
	"client_treasure_pb",
	"client_mini_pb",
	"client_periodic_sign_pb",
	"client_daily_lotery_pb",
	"client_agent_pb",
	"client_task_pb",
	"client_shop_pb",
	"client_gift_pb",
	"client_pack_pb",
	"client_compose_pb",
	"server_log_pb",
	"client_ops_pb",
	"client_user_welfare_pb",
	"client_recharge_pb",
	"client_blockchain_pb",
	"client_onlineLimit_pb",
	"client_queue_pb",
	"client_time_activities_pb",
	"client_month_card_pb",
}

function proto.Init()

	proto.shared_operation_pb = CC.shared_operation_pb

	local pbMap = {};
	for i,pbFile in ipairs(pbFiles) do
		-- 服务器后期会根据不同服务整理出很多proto文件，这里不再CC下一一定义了
		local pb = require("Model/Network/protos/"..pbFile)
		pbMap[i] = pb
		proto[pbFile] = pb
	end

	local M = {}
	proto.client_pb = M
	setmetatable(M, {
	    __index = function(tb, key)
	    	for _,pbFile in ipairs(pbMap) do
	    		if pbFile[key] then
	    			return pbFile[key];
	    		end
	    	end
	    end
	})
end

return proto
