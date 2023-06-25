local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")
local tools = GC.uu

local ComboNode = GC.class2("ComboNode")

function ComboNode:ctor(_, nodeId, parentNode)
	self.parent = nil;
	self.childs = {};
	self.data = {};
	self.data.rootId = nodeId;
	self.data.nodeId = nodeId;
	
	if parentNode then
		local warpNode = parentNode;
		local rootNode = warpNode;
		while(warpNode.parent ~= nil) do
			warpNode = warpNode.parent;
			rootNode = warpNode;
		end
		
		self.parent = parentNode;
		parentNode.childs[#parentNode.childs + 1] = self;
		self.data.nodeId = nil;
		self.data.rootId = rootNode.data.rootId;
	end
end

function ComboNode:SetNodeData(nodeData)
	for k, v in pairs(nodeData) do
		self.data[k] = v;
	end
end

function ComboNode:GetNodeData()
	return self.data;
end	

--------------- 
local L = {};
L.NodeMap = {};

function L.FindNode(node_id)
	return L.NodeMap[node_id];
end

function L.GetParentUIGoldPos(sNode)
	local findNode = sNode.parent;
	
	local parentUI;
	if findNode then
		parentUI = findNode.data.medalUi;
	else
		parentUI = ZTD.BattleView.inst;
	end

	return parentUI:GetGoldPos();	
end	

function L.ReduceComboByNode(sNode)
	if not sNode then
		return
	end
	local findNode = sNode.parent;
	
	local parentGD;
	local parentUI;
	if findNode then
		parentGD = findNode.data.goldData;
		parentUI = findNode.data.medalUi;
		parentGD:AddRecorder(-1);
	else
		parentGD = ZTD.GoldData.Gold;
		parentUI = ZTD.BattleView.inst;
	end
	
	ZTD.GoldData.FinshGoldData(sNode.data.goldData, parentGD);
	
	parentUI:RefreshGold(sNode.data.medalUi);
end

function L.ReduceCombo(node_id)
	local sNode = L.FindNode(node_id);
	L.ReduceComboByNode(sNode);
end	

function L.LinkCombo(data, kill_id, node_id)
	local cnode;
	-- 如果是免费子弹派生出的击杀，接续进列表中，否则生成一个新的列表
	local findNode = L.FindNode(kill_id)
	if findNode == nil then
		cnode = ComboNode:new(node_id);
	else
		cnode = ComboNode:new(node_id, findNode);
		local parentGD = findNode.data.goldData;
		parentGD:AddRecorder(1);	
	end
	-- logError("LinkComboLinkComboLinkCombo kill_id:" .. tostring(kill_id) .. ",node_id:" .. tostring(node_id))
	L.NodeMap[node_id] = cnode;
	cnode:SetNodeData(data);
	return cnode;
end

function L.Reset()
	L.NodeMap = {};
	ZTD.GoldData.ResetHoldGold();
end

return L;