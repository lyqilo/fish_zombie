local CC = require("CC")
local descriptor = require "protobuf.descriptor"
local FieldDescriptor = descriptor.FieldDescriptor

local table = table
local type = type
local tonumber = tonumber
local ipairs = ipairs
local pairs = pairs
local string = string

local M = {}

M.ProtoString = ""

--构造出的一个message对应的table的格式
-- {
--     headName = 'xxxx',  --message的消息名
--     Note = 'xxxx',   --message的注释
--	   memberType = 1	--message的类型
--     [1] = {
--         headName = 'xxxx'    --可以是proto中定义的类型也可能是基础类型
--         memberType = 1       --成员类型
--         selfName = 'xxxx'    --字段名
--         Note = 'xxxxx'       --当前字段在message中的注释
--     }
-- }

--proto消息中字段的成员类型
M.memberType = {
    ['required'] = 1,
    ['optional'] = 2,
    ['repeated'] = 3,
}

M.memberTypeByNum = {
	[1] = 'required',
	[2] = 'optional',
	[3] = 'repeated',
}

--proto消息中的字段数值类型
M.ValueType = {
    ['int32'] = "int32",
    ['int64'] = "int64",
    ['string'] = "string",
    ['bool'] = "bool",
    ['float'] = "float",
}

M.MemberTypeNote = {
	[1] = '此参数必须要一个',
	[2] = '此参数可以不填',
	[3] = '此参数可填0或多个',
}

M.CppType = {
	[FieldDescriptor.CPPTYPE_INT32] = "int32",
	[FieldDescriptor.CPPTYPE_INT64] = "int64",
	[FieldDescriptor.CPPTYPE_FLOAT] = "float",
	[FieldDescriptor.CPPTYPE_BOOL] = "bool",
	[FieldDescriptor.CPPTYPE_ENUM] = "int32",	--enum类型转成int32
	[FieldDescriptor.CPPTYPE_STRING] = "string",
	-- [10] = "message"
}

--proto中自定义的数据结构
M.SelfDefineType = {}

--读取分析proto的入口
function M.LoadProtoFile()
    -- for msg in string.gmatch( M.ProtoString,"message.-{.-}" ) do
    --     --logError(msg)
    --     M.AnalysisString(msg)
    -- end   
    -- CC.uu.Log(M.SelfDefineType) 

    for reqKey,v in pairs(CC.NetworkHelper.Cfg) do
    	if v.ReqProto then
	    	M.AnalysisPbData(reqKey, v.ReqProto);
	    end
    end
    -- CC.uu.Log(M.SelfDefineType) 
end


function M.LogError(content,title,hideLog)
	local result = nil
    if type(content) == "table" and content._fields then
		result = title.."---ProtoBuff---:\n"..tostring(content);
    elseif type(content) == "table" then
        local str = {}
        table.insert(str, "{\n")
        local function internal(tab, str, indent)
            for k,v in pairs(tab) do
                if type(v) == "table" then
                    table.insert(str, indent..tostring(k).." = {\n")
                    internal(v, str, indent..'          ')
                else
                    table.insert(str, indent..tostring(k).." = "..tostring(v)..",\n")
                end
            end

            table.insert(str, string.sub(indent,1,-5).."}\n") 
        end
        internal(content, str, '    ')
		result = (title.."---LuaTable---\n"..table.concat(str, ''));
		
    else
        result = (title..string.format("---%s---: %s", type(content), content));
	end
	
	if(not hideLog) then
		logError(result)
	end
	return result;
end

--解析proto字符串
function M.AnalysisString(str)
	-- if not string.find(str, "CSMultiShoot") then
	-- 	return
	-- end
    local allLines = {}
    for line in string.gmatch( str,".-\n") do
        local curTable = M.SplitStrAndCheckIsLegal(line)
        
        if(curTable) then
            table.insert(allLines,curTable)
        end
    end
    local result = M.DealHeader(allLines[1])
    if(not result) then
        -- logError('解析 message头 失败')
        return nil
    end

    for i=2,#allLines do
        local index,data = M.DealInSideMsg(allLines[i])
        if(index) then
            result[index] = data
        end
    end

    -- M.LogError(result,'解析后:  ')

    M.SelfDefineType[result.headName] = result
end

function M.AnalysisPbData(reqKey, protoName)
	local protoDescriptor = CC.proto.client_pb[string.upper(protoName)];
	if not protoDescriptor then
		CC.uu.Log(protoName, "没有对应的pb", 3)
		return;
	end
	local allLines = {
		{
			[1] = "message",
			[2] = protoName,
			[3] = reqKey
		}
	}
	for i,v in ipairs(protoDescriptor.fields) do
		local t = {};
		t[1] = M.memberTypeByNum[v.label];
		if v.cpp_type ~= FieldDescriptor.CPPTYPE_MESSAGE then
			t[2] = M.CppType[v.cpp_type];
		else
			t[2] = v.message_type.name;
			M.AnalysisPbData(nil, v.message_type.name);
		end
		t[3] = v.name;
		t[4] = i;
		table.insert(allLines, t);
	end

	-- CC.uu.Log(allLines,"====")

    local result = M.DealHeader(allLines[1])
    -- CC.uu.Log(result, "result")
    if(not result) then
        -- logError('解析 message头 失败')
        return nil
    end

    for i=2,#allLines do
        local index,data = M.DealInSideMsg(allLines[i])
        if(index) then
            result[index] = data
        end
    end

    -- M.LogError(result,'解析后:  ')

    M.SelfDefineType[result.headName] = result
end

--拆分字符
function M.SplitStrAndCheckIsLegal(str)
    local legalCount = 0;
    local result = {};
    local leftIndex = -1;
    for i=1,string.len(str) do
        local curASCII = string.byte(str,i);
        if(not M.CheckIsLegalChar(curASCII)) then
            if(leftIndex ~= -1) then
                local curStr = string.sub(str,leftIndex,i - 1)
                table.insert(result,curStr)
                leftIndex = -1
            end
        else
            legalCount = legalCount + 1;
            if(leftIndex == -1) then
                leftIndex = i;
            end
        end
    end

    if(legalCount < 3) then
        return nil
    end

    return result
end

--检测是否是合法字符
function M.CheckIsLegalChar(curASCII)
    if(type(curASCII) ~= "number") then
        return false
    end

    -- 9 tab  32 空格    10 换行  11  垂直制表符  59 ;   123 {  125 }  61 =  47 /
	if(curASCII == 9 or curASCII == 32 or curASCII == 10 or curASCII == 11 or curASCII == 47 or
		curASCII == 59 or curASCII == 123 or curASCII == 125 or curASCII == 61) then
        return false
    end

    return true
end

--处理头部信息
function M.DealHeader(tb)
    if(tb == nil or #tb == 0 or tb[1] ~= 'message') then
        return nil
    end

    local result = {}
    result.headName = tb[2]
    result.reqKey = tb[3]
    local NoteStr = ''
	for i=4,#tb do
		if(NoteStr == '') then
			NoteStr = tb[i]
		else
			NoteStr = NoteStr..','..tb[i]
		end
    end

	result.Note = NoteStr
	result.memberType = M.memberType.required

    return result
end

--处理消息内部
function M.DealInSideMsg(tb)
    if(tb == nil or #tb == 0) then
        return nil
    end

    local memType = M.memberType[tb[1]]
    if(not memType) then
        --logError('解析proto 内部错误:没有成员类型'..tb[1])
        return nil
    end

    local result = {}
    result.memberType = memType;
    result.headName = tb[2];
    result.selfName = tb[3];
    result.reqKey = tb[5];

    local index = tonumber(tb[4])
    if(not index) then
        --logError('解析proto 内部错误 无法获得index:'..tb[4])
        return nil
    end

    local note = ''
	for i=5,#tb do
		if(note == '') then
			note = tb[i]
		else
			note = note..tb[i]..','
		end
    end

    result.Note = note
    return index,result
end

--检查字符串是否是基础类型
function M.CheckIsBaseType(str)
	if(M.ValueType[str]) then
		return true
	end

	return false
end

--检查是否是自定义类型
function M.CheckIsSelfDefineType(str)
	if(M.SelfDefineType[str]) then
		return true
	end

	return false
end

--获取基础类型默认值
function M.GetBaseTypeDefaultValue(type)
	if(type == M.ValueType.int32) then
		return 0
	elseif(type == M.ValueType.int64) then
		return 0
	elseif(type == M.ValueType.string) then
		return ''
	elseif(type == M.ValueType.bool) then
		return false
	elseif(type == M.ValueType.float) then
		return 0
	end

	return nil
end

--通过proto结构构造初始的消息结构
function M.BuildMsgByProto(protoMsg)
	--M.LogError(protoMsg,'通过proto结构构造初始的消息结构 传入proto:')
	-- if not protoMsg then
	local result = nil
	if(M.CheckIsSelfDefineType(protoMsg.headName)) then
		result = {}
		for i=1,#protoMsg do
			local curMsg = protoMsg[i]
			if(curMsg.memberType == M.memberType.repeated) then
				result[curMsg.selfName] = {}
			else
				local isBaseType = M.CheckIsBaseType(curMsg.headName)
				local isSelfDefineType = M.CheckIsSelfDefineType(curMsg.headName)
				if((not isBaseType) and (not isSelfDefineType)) then
					logError('未知类型:'..curMsg.headName)
					return
				end

				if(isBaseType) then
					result[curMsg.selfName] = M.GetBaseTypeDefaultValue(curMsg.headName)
				else
					--logError('curMsg.memberType:'..curMsg.headName)
					result[curMsg.selfName] = M.BuildMsgByProto(M.SelfDefineType[curMsg.headName])
				end
			end
		end
	end

	if(M.CheckIsBaseType(protoMsg.headName)) then
		result = M.GetBaseTypeDefaultValue(protoMsg.headName)
	end
	
	--M.LogError(result,'构造好的结构:')
	return result
end


--通过类型来转换输入的str
function M.ConvertStrByType(str,type)
	--logError('str:'..str..'!   type:'..type)
	local result = nil
	if(type == 'int32' or type == 'int64' or type == 'float') then
		result = tonumber(str)
		if(not result) then
			result = M.GetBaseTypeDefaultValue(type)
		end
	elseif(type == 'bool') then
		if(str == 'true' or str == '1') then
			result = true
		else
			result = false
		end
	elseif(type == 'string') then
		result = str
	end

	return result
end


return M