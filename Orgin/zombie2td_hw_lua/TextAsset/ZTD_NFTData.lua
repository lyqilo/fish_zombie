local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

--NFT数据
local NFTData = {}

function NFTData.Init()
	--	玩家拥有的ntf卡列表
	NFTData.cardList = {}
	NFTData.armedList = {"","",""}
	
	NFTData.frt = 0
end

--设置卡
--power 卡的算力，设置为0就是销毁
function NFTData.SetCardPower(id, base, extend)

	if NFTData.cardList[id] then
		NFTData.cardList[id].power = base + extend
		NFTData.cardList[id].basePower = base
		NFTData.cardList[id].exPower = extend
	end
end

function NFTData.NewCard(data)
	if not NFTData.cardList[data.ID] then
		NFTData.cardList[data.ID] = {}
	end
	NFTData.cardList[data.ID].id = data.ID
	NFTData.cardList[data.ID].power = data.BasePower+data.ExtendPower
	NFTData.cardList[data.ID].basePower = data.BasePower
	NFTData.cardList[data.ID].exPower = data.ExtendPower
	NFTData.cardList[data.ID].grade = data.Quality or 1
	NFTData.cardList[data.ID].status = data.Status or 0
	if data.Equip > 0 and data.Equip < 4 then
		NFTData.cardList[data.ID].armPos = data.Equip
		NFTData.armedList[data.Equip] = data.ID
	else
		NFTData.cardList[data.ID].armPos = 0
	end

end
function NFTData.RemoveCard(id)
	NFTData.cardList[id] = nil
end

function NFTData.RemoveAllCard()
	NFTData.cardList = {}
end

--frt数量
function NFTData.GetFRT()
	return NFTData.frt
end
--frt数量
function NFTData.SetFRT(count)
	NFTData.frt = count
end
--获取对应的卡
function NFTData.GetCard(id)
	return NFTData.cardList[id]
end


--获取对应品级的卡
function NFTData.GetGradeCardList(grade)
	local tab = {}
	for _,v in pairs(NFTData.cardList) do
		if v.grade == grade then
			table.insert(tab, v)
		end
	end
	table.sort(tab, function (a, b)
		return a.power > b.power
	end)
	
	return tab
end


--获取装备列表
function NFTData.GetArmedList()
	return table.copy(NFTData.armedList)
end
--设置装备列表
function NFTData.SetArmedList(tab)
	for pos,id in pairs(NFTData.armedList) do
		if id~="" then
			NFTData.cardList[id].armPos = 0
		end
	end
	NFTData.armedList = table.copy(tab)
	for pos,id in pairs(NFTData.armedList) do
		if id~="" then
			NFTData.cardList[id].armPos = pos
		end
	end
	
end


function NFTData.Release()
	NFTData.cardList = {}
	NFTData.armedList = {}
end

return NFTData