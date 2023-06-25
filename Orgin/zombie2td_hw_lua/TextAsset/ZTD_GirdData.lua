local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local GirdData = GC.class2("TdGirdData")


-- 宽（像素）、长（像素）、宽（格子）、长（格子）、锚点（x，y）
function GirdData:Init(width, high, w_nums, h_nums, cenX, cenY)
	self._maxWidth = width;
	self._maxHigh = high;
	self._girdWidth = width/w_nums;
	self._girdHigh = high/h_nums;
	self._datas = {};
	for i = 1, w_nums do
		self._datas[i] = {};
		for j = 1, h_nums do
			self._datas[i][j] = nil;
		end
	end
	self._offsetX = self._maxWidth * cenX;
	self._offsetY = self._maxHigh * cenY;
	self._w_nums = w_nums;
	self._h_nums = h_nums;
end

function GirdData:Reset()
	for i = 1, self._w_nums do
		self._datas[i] = {};
		for j = 1, self._h_nums do
			self._datas[i][j] = nil;
		end
	end	
end	

-- 传入的坐标为相对map原点的坐标
function GirdData:IsInRange(x, y)
	-- 转换为x：0~width y:0~high的坐标
	local x = x + self._offsetX;
	local y = y + self._offsetY;
	
	if x < 0 or x > self._maxWidth or y < 0 or y > self._maxHigh then
		return false;
	else
		return true, x, y;
	end
end

function GirdData:WriteGrid(x, y, var)
	--logError("WriteGridWriteGridWriteGrid:" .. x .. "," .. y .. ":" .. tostring(var))
	local ret, x, y = self:IsInRange(x,y);
	if not ret then
		return false;
	end	
	
	local i = math.floor(x / self._girdWidth);
	local j = math.floor(y / self._girdHigh);
	
	if not self._datas[i] then
		self._datas[i] = {};
	end
	self._datas[i][j] = var;
	--logError("WriteGridWriteGridWriteGridself._datas[i][j]:" .. i .. "," .. j.. ":" .. tostring(var))
	return true;
end

function GirdData:WriteGridByInx(i, j, var)
	if not self._datas[i] then
		self._datas[i] = {};
	end
	self._datas[i][j] = var;	
	--logError("WriteGridWriteGridWriteGridself._datas[i][j]:" .. i .. "," .. j.. ":" .. tostring(var))
end	

function GirdData:GetFreeGrid(x, y)
	-- 转换为x：0~width y:0~high的坐标
	local ix = x + self._offsetX;
	local iy = y + self._offsetY;
	local i = math.floor(ix / self._girdWidth);
	local j = math.floor(iy / self._girdHigh);
	--logError("GetFreeGridGetFreeGrid GetFreeGrid:" .. i .. "," .. j)
	local wrapList = 
	{
		{0, 0},
		{1, 0},
		{-1, 0},
		{0, 1},
		{0, -1},
		{1, -1},
		{1, 1},
		{-1, 1},
		{-1, -1},		
	}
	
	for _, v in ipairs(wrapList) do
		local ii = i + v[1];
		local jj = j + v[2];
		
		if self._datas[ii] and self._datas[ii][jj] == nil then
			local dstX = x + v[1] * self._girdWidth;
			local dstY = y + v[2] * self._girdHigh;
			local ret, rx, ry = self:IsInRange(dstX, dstY);
			if ret then
				--logError("out GetFreeGridGetFreeGrid GetFreeGrid:" .. ii .. "," .. jj)
				return dstX, dstY, ii, jj;
			end
		end
	end
end

return GirdData;