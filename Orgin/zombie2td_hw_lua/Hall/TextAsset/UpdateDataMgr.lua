local CC = require("CC")

local UpdateDataMgr = {}

local DownloadData
local hotresPath
local packagePath

local isInit = false

function UpdateDataMgr.Init(data)
	DownloadData = {}
	data = data.data
	for i,v in ipairs(data.List) do
		if not DownloadData[tostring(v.Id)] then
			DownloadData[tostring(v.Id)] = v
		end
	end
	hotresPath = data.hotresPath
	packagePath = data.packagePath
	isInit = true
end

function UpdateDataMgr.SetUpdateInfoByID(param)
	local id = param.Id;
	DownloadData[tostring(id)] = param;
end

function UpdateDataMgr.GetUpdateInfoByID(id)
	return DownloadData[tostring(id)]
end

function UpdateDataMgr.GetHallUpdateInfo()
	return DownloadData[tostring(1)]
end

function UpdateDataMgr.GetHotresPath()
	return hotresPath
end

function UpdateDataMgr.GetPackagePath()
	return packagePath
end

function UpdateDataMgr.ClearInitFlag()
	isInit = false
end

function UpdateDataMgr.isInitFinish()
	return isInit
end

return UpdateDataMgr