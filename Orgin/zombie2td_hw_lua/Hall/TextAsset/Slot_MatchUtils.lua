--Author:AQ
--Time:2020年09月04日 10:11:28 Friday
--Describe:

local CC = require "CC"
local uu = CC.uu
local slotMatch_message_pb = CC.slotMatch_message_pb

local M = {}

function M.Return0IfNil(value)
    return M.ReturnV2IfV1(value,nil,0);
end

function M.ReturnV2IfV1(value,value1,value2)
    return value == value1 and value2 or value;
end

function M.EnmatchToString(enmatch)
    if M.language == nil then
        M.language = CC.LanguageManager.GetLanguage("L_SlotMatch")
    end
    if enmatch == slotMatch_message_pb.En_Match_Primary then
        return M.language.LANGUAGE_19;
    elseif enmatch == slotMatch_message_pb.En_Match_Middle then
        return M.language.LANGUAGE_20;
    elseif enmatch == slotMatch_message_pb.En_Match_High then
        return M.language.LANGUAGE_21;
    end
end

function M.EnmatchToReqCount(enmatch)
    if enmatch == slotMatch_message_pb.En_Match_Primary then
        return 10,10;
    elseif enmatch == slotMatch_message_pb.En_Match_Middle then
        return 6,10;
    elseif enmatch == slotMatch_message_pb.En_Match_High then
        return 2,10;
    end
    return 0,0;
end

return M