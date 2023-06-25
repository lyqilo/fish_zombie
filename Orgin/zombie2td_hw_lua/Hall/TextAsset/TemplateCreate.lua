

local viewName = "BatteryGiftView"

local viewCtr = viewName.."Ctr"
local fileName =viewName

local templateName = "TemplateView"
local templateCtr = templateName.."Ctr"

local function ReplaceClassName(filePath, sourceName, replaceName)
	local content =""
	io.input(filePath)
	content = io.read("*a")
	content = string.gsub(content, sourceName, replaceName)
	io.output(filePath)
	io.write(content)
	io.flush()
	io.close()
end

local function CreateTemplateFile()

	local cmd = string.format("mkdir ..\\View\\%s", viewName);
	os.execute(cmd);


	local copyList = {
		{
			sourcePath = templateName..".lua",
			targetPath = string.format("..\\View\\%s\\%s.lua", fileName, viewName),
			reSourceName = templateName,
			reTargetName = viewName
		},
		{
			sourcePath = templateCtr..".lua",
			targetPath = string.format("..\\View\\%s\\%s.lua", fileName, viewCtr),
			reSourceName = templateCtr,
			reTargetName = viewCtr
		},
		{
			sourcePath = "L_"..templateName..".lua",
			targetPath = string.format("..\\Model\\Language\\Chinese\\L_%s.lua", viewName),
		},
		{
			sourcePath = "L_"..templateName..".lua",
			targetPath = string.format("..\\Model\\Language\\Thai\\L_%s.lua", viewName),
		},
	}

	for _,v in pairs(copyList) do
		local cmd = string.format("copy %s %s", v.sourcePath, v.targetPath)
		os.execute(cmd);
		if v.reSourceName then
			ReplaceClassName(v.targetPath, v.reSourceName, v.reTargetName);
		end
	end
end

CreateTemplateFile();
