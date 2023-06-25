-- nft配置
--一点算力需要3frt
local frtPerPower = 0.3
local TdNFTConfig = {}
--最大排名
TdNFTConfig.maxSeasonRank = 200
TdNFTConfig.Grade = 
{
	[1] = 
	{
		--洗练消耗
		enhanceCost = 1,
		--洗练成功增加下限
		min_enhancement_power = 0,
		--最大洗练增长算力
		max_enhancement_power= 1,
		--洗练最大算力
		exPowerMax = 4,
		--基础算力下限
		min_base_power = 1,
		--基础算力上限
		max_base_power = 2,
		-- 最大额外算力
		extend_power_limit = 1,
		modelName = "SS_05_01",
		modelPos = Vector3(12,130,320.9),
		modelRot = Vector3(0,-142.706,0),
		modelScale = Vector3(330.2082,330.2083,330.2083),
	},
	[2] = 
	{
		--洗练消耗
		enhanceCost = 10,
		--洗练成功增加下限
		min_enhancement_power = 2,
		--最大洗练增长算力
		max_enhancement_power= 8,
		--洗练最大算力
		exPowerMax = 40,
		--基础算力下限
		min_base_power = 10,
		--基础算力上限
		max_base_power = 20,
		-- 最大额外算力
		extend_power_limit = 1,
		modelName = "SS_04_01",
		modelPos = Vector3(-33.18359,-55.84375,883.076),
		modelRot = Vector3(-6.133,-206.6,-4.337),
		modelScale = Vector3(142.3785,142.3785,142.3785),
	},
	[3] = 
	{
		--洗练消耗
		enhanceCost = 100,
		--洗练成功增加下限
		min_enhancement_power = 30,
		--洗练成功增加上限
		max_enhancement_power= 50,
		--洗练最大算力
		exPowerMax = 400,
		--基础算力下限
		min_base_power = 100,
		--基础算力上限
		max_base_power = 200,
		-- 最大额外算力
		extend_power_limit = 1,
		modelName = "SLC_02_01_forShow",
		modelPos = Vector3(100,-190,791),
		modelRot = Vector3(19.493,-115.552,9.962001),
		modelScale = Vector3(129.5568,129.5568,129.5568),
	},
	[4] = 
	{
		--洗练消耗
		enhanceCost = 1000,
		--洗练成功增加下限
		min_enhancement_power = 200,
		--洗练成功增加上限
		max_enhancement_power= 300,
		--洗练最大算力
		exPowerMax = 4000,
		--基础算力下限
		min_base_power = 1000,
		--基础算力上限
		max_base_power = 2000,
		-- 最大额外算力
		extend_power_limit = 1,
		modelName = "SLC_03_01_forShow",
		modelPos = Vector3(33,-94,636),
		modelRot = Vector3(0,-149.644,0),
		modelScale = Vector3(270.4124,270.4124,270.4124),
	},
	[5] = 
	{
		--洗练消耗
		enhanceCost = 10000,
		--洗练成功增加下限
		min_enhancement_power = 1800,
		--洗练成功增加上限
		max_enhancement_power= 2200,
		--洗练最大算力
		exPowerMax = 40000,
		--基础算力下限
		min_base_power = 10000,
		--基础算力上限
		max_base_power = 20000,
		-- 最大额外算力
		extend_power_limit = 1,
		modelName = "SL_04_01_forShow",
		modelPos = Vector3(180,-187,780),
		modelRot = Vector3(0,-512.1,0),
		modelScale =  Vector3(246.1927,246.1927,246.1927),
	},
	[6] = 
	{
		--洗练消耗
		enhanceCost = 100000,
		--洗练成功增加下限
		min_enhancement_power = 19000,
		--洗练成功增加上限
		max_enhancement_power= 21000,
		--洗练最大算力
		exPowerMax = 400000,
		--基础算力下限
		min_base_power = 100000,
		--基础算力上限
		max_base_power = 200000,
		-- 最大额外算力
		extend_power_limit = 1,
		modelName = "SL_02_01_HighView",
		modelPos = Vector3(331,-136,4488),
		modelRot = Vector3(0,-58.323,0),
		modelScale = Vector3(82.95137,82.95137,82.95137),
	},
	
}

for i,v in ipairs(TdNFTConfig.Grade) do
	v.enhanceCost = (v.min_enhancement_power + v.max_enhancement_power)/2*frtPerPower
end

function TdNFTConfig.setGradeConfig(data)
	for i = 1, #TdNFTConfig.Grade, 1 do
		TdNFTConfig.Grade[i].min_base_power = data[i].min_base_power
		TdNFTConfig.Grade[i].max_base_power = data[i].max_base_power
		TdNFTConfig.Grade[i].min_enhancement_power = data[i].min_enhancement_power
		TdNFTConfig.Grade[i].max_enhancement_power = data[i].max_enhancement_power
		TdNFTConfig.Grade[i].extend_power_limit = data[i].extend_power_limit
	end
	for i,v in ipairs(TdNFTConfig.Grade) do
		v.enhanceCost = (v.min_enhancement_power + v.max_enhancement_power)/2*frtPerPower
	end
end

function TdNFTConfig.GetGradeConfig(grade)
	return TdNFTConfig.Grade[grade]
end

--计算合成消耗
--grade 品级
--totalBasePower 当前卡牌的基础总算力
function TdNFTConfig.CalComposeCost(grade, totalBasePower)
	local cfg = TdNFTConfig.Grade[grade+1]
	local avg = (cfg.min_base_power + cfg.max_base_power)/2
	return (avg-totalBasePower)*frtPerPower
end


return TdNFTConfig