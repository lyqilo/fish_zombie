local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local M = {};

M._trend_points = {};

function M.Clean()
	for _, v in pairs(M._trend_points) do
		if v.tPoint then
			ZTD.PoolManager.RemoveUiItem("ZTD_img_trend_point", v.tPoint);
		end	
		
		if v.tLine then
			ZTD.PoolManager.RemoveUiItem("ZTD_img_trend_line", v.tLine);
		end	

		if v.tArrow then
			ZTD.PoolManager.RemoveUiItem("ZTD_img_trend_arrow", v.tArrow);
		end		
	end
	M._trend_points = {};	
end	

function M.Reset(drawNode)
	M.Close(drawNode);
	drawNode:FindChild("bg_mask/sp_max"):SetActive(false);
	drawNode:FindChild("bg_mask/sp_max_revert"):SetActive(false);
	M.Clean();
end

function M.Open(drawNode, bvSelf)
	drawNode:SetActive(true);
	M.IsOpen = true;
	M._bvSelf = bvSelf;
	for _, v in pairs(M._bvSelf._hero_pos) do
		for __, heroPos in pairs(v) do
			local heroCtrl = heroPos:GetHeroCtrl()
			if heroCtrl then
				heroCtrl:OpenScoreUi();
			end
		end
	end	
end

function M.Close(drawNode)
	drawNode:SetActive(false);
	M.IsOpen = false;
	if M._bvSelf then
		for _, v in pairs(M._bvSelf._hero_pos) do
			for __, heroPos in pairs(v) do
				local heroCtrl = heroPos:GetHeroCtrl()
				if heroCtrl then
					heroCtrl:CloseScoreUi();
				end
			end
		end
	end		
end	

-- 处理数据溢出，一共不超过20
function M.DealRecordOver(dataList)
	local dataLen = #dataList;
	if dataLen > 20 then
		for i = 2, dataLen - 1 do
			if dataList[i] > dataList[i - 1] and dataList[i] < dataList[i + 1] then
				table.remove(dataList, i);
				return;
			end
		end
		
		
		local minWave;
		local minInx;
		for i = 2, dataLen - 1 do
			local aa = math.abs(dataList[i - 1] - dataList[i]);
			local bb = math.abs(dataList[i + 1] - dataList[i]);
			local waveValue = aa + bb;
			if minWave == nil then
				minWave = waveValue;
				minInx = i;
			elseif minWave > waveValue then
				minWave = waveValue;
				minInx = i;
			end
		end		
		
		table.remove(dataList, minInx);
	end
end
	
function M.Draw(drawNode, dataList)
	if(drawNode == nil) then
		return;
	end	
	if next(dataList) == nil or #dataList == 1 then
		return;
	end
	
	local moneyMax;
	local limitMax;
	local inxMax = 1;
	for inx, m in ipairs(dataList) do
		local absM = math.abs(m);
		if moneyMax == nil then
			moneyMax = m;
		elseif m > moneyMax then
			moneyMax = m;
			inxMax = inx;
		end
		
		if limitMax == nil then
			limitMax = absM;
		elseif absM > limitMax then
			limitMax = absM;
		end		
	end
	
	--drawNode:FindChild("bg_mask/sp_max/txt_max"):SetActive(moneyMax > 0);
	drawNode:FindChild("bg_mask/sp_max"):SetActive(false);
	drawNode:FindChild("bg_mask/sp_max_revert"):SetActive(false);
	if moneyMax > 0 then
		drawNode:FindChild("bg_mask/sp_max/txt_max").text = tools.numberToStrWithComma(moneyMax);
		drawNode:FindChild("bg_mask/sp_max_revert/txt_max").text = tools.numberToStrWithComma(moneyMax);
	end
	
	local limitY = limitMax * 1.05;
	if limitY < 1000 then
		limitY = 1000;
	end	
	
	local nodeDrawBack = drawNode:FindChild("bg_mask/node_draw");
	
	if not M._drawWidth then
		M._drawWidth = nodeDrawBack:GetComponent('RectTransform').rect.width;
		M._drawHeight = nodeDrawBack:GetComponent('RectTransform').rect.height;
	end	

	M.Clean();
	local total = #dataList;
	local widthGap;
	-- x的刻度最少从10开始算起
	if total < 10 then
		widthGap = M._drawWidth * 0.9 / 10;
	else
		widthGap = M._drawWidth * 0.9 / total;
	end	
	
	for i = 1, total do
		local dataV = dataList[i];		
		local posY = (M._drawHeight * 0.9/2) * dataV/limitY;
		local posX = M._drawWidth * 0.1 + widthGap * (i - 1) - M._drawWidth/2;
		
		local tData = {};
		M._trend_points[i] = tData;
		local tPoint;
		-- 是最后一个且数组长度不为1，则表示箭头
		if i == total and i ~= 1 then
			tPoint = ZTD.PoolManager.GetUiItem("ZTD_img_trend_arrow", nodeDrawBack);
			tData.tArrow = tPoint;
		else	
			tPoint = ZTD.PoolManager.GetUiItem("ZTD_img_trend_point", nodeDrawBack);
			tData.tPoint = tPoint;
		end
		
		tPoint.localPosition = Vector3(posX, posY, 0);
		
		-- 保证node_draw和bg_mask大小一致，则local pos也能一致
		if i == inxMax and moneyMax > 0 then
			if tPoint.localPosition.x > 0 then
				drawNode:FindChild("bg_mask/sp_max"):SetActive(true);
				drawNode:FindChild("bg_mask/sp_max").localPosition = Vector3(tPoint.localPosition.x - 14, tPoint.localPosition.y, 0);
			else
				drawNode:FindChild("bg_mask/sp_max_revert"):SetActive(true);
				drawNode:FindChild("bg_mask/sp_max_revert").localPosition = Vector3(tPoint.localPosition.x + 14, tPoint.localPosition.y, 0);
			end	
		end
		
		if(i > 1)then
			
			local tLine = ZTD.PoolManager.GetUiItem("ZTD_img_trend_line", nodeDrawBack);
			tData.tLine = tLine;
			local tgPos = tPoint.localPosition;
			local lastPos = M._trend_points[i - 1].tPoint.localPosition;
			local dir = Vector3.Normalize(tgPos - lastPos);
			tLine.localRotation = Quaternion.FromToRotation(Vector3.right, dir)
			
			-- 是最后一个且数组长度不为1，则表示箭头
			if i == total and i ~= 1 then
				tPoint.localRotation = Quaternion.FromToRotation(Vector3.right, dir)
			end	
			
			local fixX = lastPos.x + (tgPos.x - lastPos.x)/2;
			local fixY = lastPos.y + (tgPos.y - lastPos.y)/2;
			
			if M._pLineWidth == nil then
				M._pLineWidth = tLine:GetComponent('RectTransform').rect.width;
			end
			
			local distance = Vector3.Distance(tgPos, lastPos);
			tLine.localScale = Vector3(distance/M._pLineWidth, 1, 0);
			tLine.localPosition = Vector3(fixX, fixY, 0);
		end
	end
end

return M