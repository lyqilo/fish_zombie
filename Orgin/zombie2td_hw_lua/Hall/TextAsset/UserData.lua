
--！！！Attention,该文件只起文件读取存储操作，不存储中间参数

local UserData = {}

local dataPath = Util.userPath

--使用XXTea加密方式读取文件！内容必定是json的
function UserData.Load(name, default)
	local data = UserData.ReadFileByXXTea( name, true )
	if data ~= "" then
		return data
	else
		return default or {}
	end
end

--使用XXTea加密方式存储文件！内容必定是json的
function UserData.Save(name, _content)
	local content = _content or {}
	UserData.WriteFileByXXTea(name,content,true)
end

function UserData.ReadFileByXXTea( name, isJson )
    local content = Util.LoadFileByXXTea(dataPath..name)
    if content ~= "" and isJson then
        content = Json.decode(content)
    end
    return content or ""
end

function UserData.WriteFileByXXTea( name, content, isJson )
    if isJson then
        content = Json.encode(content)
    end
    if content then
        Util.SaveFileByXXTea(dataPath..name, content)
    end
end

function UserData.ReadFile( name, isJson )
	local content = Util.ReadFile(dataPath..name)
	if content ~= "" and isJson then
		content = Json.decode(content)
	end
	return content or ""
end

function UserData.WriteFile( name, content, isJson )
	if isJson then
		content = Json.encode(content)
	end
	if content then
		Util.WriteFile(dataPath..name, content)
	end
end

function UserData.HasFile( name )
	return Util.HasFile(dataPath..name)
end

function UserData.ReadBytes( name )
	return Util.ReadBytes(dataPath..name)
end

function UserData.WriteBytes( name, bytes )
	Util.WriteBytes(dataPath..name, bytes)
end

return UserData