-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf/protobuf"
local pb = {}
local descriptor = {}

descriptor.EMPTY = protobuf.Descriptor();
descriptor.MESSAGE = protobuf.Descriptor();
descriptor.MESSAGE_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.MESSAGE_OPS_FIELD = protobuf.FieldDescriptor();
descriptor.MESSAGE_DATA_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPRESULT = protobuf.Descriptor();
descriptor.HTTPRESULT_EN_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPRESULT_DATA_FIELD = protobuf.FieldDescriptor();
descriptor.RPCMESSAGE = protobuf.Descriptor();
descriptor.RPCMESSAGE_ID_FIELD = protobuf.FieldDescriptor();
descriptor.RPCMESSAGE_RESPCHAN_FIELD = protobuf.FieldDescriptor();
descriptor.RPCMESSAGE_OPS_FIELD = protobuf.FieldDescriptor();
descriptor.RPCMESSAGE_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.RPCMESSAGE_DATA_FIELD = protobuf.FieldDescriptor();
descriptor.RPCRESP = protobuf.Descriptor();
descriptor.RPCRESP_ID_FIELD = protobuf.FieldDescriptor();
descriptor.RPCRESP_EN_FIELD = protobuf.FieldDescriptor();
descriptor.RPCRESP_DATA_FIELD = protobuf.FieldDescriptor();

descriptor.EMPTY.name = "Empty"
descriptor.EMPTY.full_name = ".VK.Proto.Empty"
descriptor.EMPTY.nested_types = {}
descriptor.EMPTY.enum_types = {}
descriptor.EMPTY.fields = {}
descriptor.EMPTY.is_extendable = false
descriptor.EMPTY.extensions = {}
descriptor.MESSAGE_PLAYERID_FIELD.name = "PlayerId"
descriptor.MESSAGE_PLAYERID_FIELD.full_name = ".VK.Proto.Message.PlayerId"
descriptor.MESSAGE_PLAYERID_FIELD.number = 1
descriptor.MESSAGE_PLAYERID_FIELD.index = 0
descriptor.MESSAGE_PLAYERID_FIELD.label = 1
descriptor.MESSAGE_PLAYERID_FIELD.has_default_value = false
descriptor.MESSAGE_PLAYERID_FIELD.default_value = 0
descriptor.MESSAGE_PLAYERID_FIELD.type = 3
descriptor.MESSAGE_PLAYERID_FIELD.cpp_type = 2

descriptor.MESSAGE_OPS_FIELD.name = "Ops"
descriptor.MESSAGE_OPS_FIELD.full_name = ".VK.Proto.Message.Ops"
descriptor.MESSAGE_OPS_FIELD.number = 2
descriptor.MESSAGE_OPS_FIELD.index = 1
descriptor.MESSAGE_OPS_FIELD.label = 2
descriptor.MESSAGE_OPS_FIELD.has_default_value = false
descriptor.MESSAGE_OPS_FIELD.default_value = 0
descriptor.MESSAGE_OPS_FIELD.type = 5
descriptor.MESSAGE_OPS_FIELD.cpp_type = 1

descriptor.MESSAGE_DATA_FIELD.name = "Data"
descriptor.MESSAGE_DATA_FIELD.full_name = ".VK.Proto.Message.Data"
descriptor.MESSAGE_DATA_FIELD.number = 3
descriptor.MESSAGE_DATA_FIELD.index = 2
descriptor.MESSAGE_DATA_FIELD.label = 1
descriptor.MESSAGE_DATA_FIELD.has_default_value = false
descriptor.MESSAGE_DATA_FIELD.default_value = ""
descriptor.MESSAGE_DATA_FIELD.type = 12
descriptor.MESSAGE_DATA_FIELD.cpp_type = 9

descriptor.MESSAGE.name = "Message"
descriptor.MESSAGE.full_name = ".VK.Proto.Message"
descriptor.MESSAGE.nested_types = {}
descriptor.MESSAGE.enum_types = {}
descriptor.MESSAGE.fields = {descriptor.MESSAGE_PLAYERID_FIELD, descriptor.MESSAGE_OPS_FIELD, descriptor.MESSAGE_DATA_FIELD}
descriptor.MESSAGE.is_extendable = false
descriptor.MESSAGE.extensions = {}
descriptor.HTTPRESULT_EN_FIELD.name = "En"
descriptor.HTTPRESULT_EN_FIELD.full_name = ".VK.Proto.HttpResult.En"
descriptor.HTTPRESULT_EN_FIELD.number = 1
descriptor.HTTPRESULT_EN_FIELD.index = 0
descriptor.HTTPRESULT_EN_FIELD.label = 2
descriptor.HTTPRESULT_EN_FIELD.has_default_value = false
descriptor.HTTPRESULT_EN_FIELD.default_value = 0
descriptor.HTTPRESULT_EN_FIELD.type = 5
descriptor.HTTPRESULT_EN_FIELD.cpp_type = 1

descriptor.HTTPRESULT_DATA_FIELD.name = "Data"
descriptor.HTTPRESULT_DATA_FIELD.full_name = ".VK.Proto.HttpResult.Data"
descriptor.HTTPRESULT_DATA_FIELD.number = 2
descriptor.HTTPRESULT_DATA_FIELD.index = 1
descriptor.HTTPRESULT_DATA_FIELD.label = 1
descriptor.HTTPRESULT_DATA_FIELD.has_default_value = false
descriptor.HTTPRESULT_DATA_FIELD.default_value = ""
descriptor.HTTPRESULT_DATA_FIELD.type = 12
descriptor.HTTPRESULT_DATA_FIELD.cpp_type = 9

descriptor.HTTPRESULT.name = "HttpResult"
descriptor.HTTPRESULT.full_name = ".VK.Proto.HttpResult"
descriptor.HTTPRESULT.nested_types = {}
descriptor.HTTPRESULT.enum_types = {}
descriptor.HTTPRESULT.fields = {descriptor.HTTPRESULT_EN_FIELD, descriptor.HTTPRESULT_DATA_FIELD}
descriptor.HTTPRESULT.is_extendable = false
descriptor.HTTPRESULT.extensions = {}
descriptor.RPCMESSAGE_ID_FIELD.name = "Id"
descriptor.RPCMESSAGE_ID_FIELD.full_name = ".VK.Proto.RpcMessage.Id"
descriptor.RPCMESSAGE_ID_FIELD.number = 1
descriptor.RPCMESSAGE_ID_FIELD.index = 0
descriptor.RPCMESSAGE_ID_FIELD.label = 2
descriptor.RPCMESSAGE_ID_FIELD.has_default_value = false
descriptor.RPCMESSAGE_ID_FIELD.default_value = ""
descriptor.RPCMESSAGE_ID_FIELD.type = 9
descriptor.RPCMESSAGE_ID_FIELD.cpp_type = 9

descriptor.RPCMESSAGE_RESPCHAN_FIELD.name = "RespChan"
descriptor.RPCMESSAGE_RESPCHAN_FIELD.full_name = ".VK.Proto.RpcMessage.RespChan"
descriptor.RPCMESSAGE_RESPCHAN_FIELD.number = 2
descriptor.RPCMESSAGE_RESPCHAN_FIELD.index = 1
descriptor.RPCMESSAGE_RESPCHAN_FIELD.label = 2
descriptor.RPCMESSAGE_RESPCHAN_FIELD.has_default_value = false
descriptor.RPCMESSAGE_RESPCHAN_FIELD.default_value = ""
descriptor.RPCMESSAGE_RESPCHAN_FIELD.type = 9
descriptor.RPCMESSAGE_RESPCHAN_FIELD.cpp_type = 9

descriptor.RPCMESSAGE_OPS_FIELD.name = "Ops"
descriptor.RPCMESSAGE_OPS_FIELD.full_name = ".VK.Proto.RpcMessage.Ops"
descriptor.RPCMESSAGE_OPS_FIELD.number = 3
descriptor.RPCMESSAGE_OPS_FIELD.index = 2
descriptor.RPCMESSAGE_OPS_FIELD.label = 2
descriptor.RPCMESSAGE_OPS_FIELD.has_default_value = false
descriptor.RPCMESSAGE_OPS_FIELD.default_value = 0
descriptor.RPCMESSAGE_OPS_FIELD.type = 5
descriptor.RPCMESSAGE_OPS_FIELD.cpp_type = 1

descriptor.RPCMESSAGE_PLAYERID_FIELD.name = "PlayerId"
descriptor.RPCMESSAGE_PLAYERID_FIELD.full_name = ".VK.Proto.RpcMessage.PlayerId"
descriptor.RPCMESSAGE_PLAYERID_FIELD.number = 4
descriptor.RPCMESSAGE_PLAYERID_FIELD.index = 3
descriptor.RPCMESSAGE_PLAYERID_FIELD.label = 1
descriptor.RPCMESSAGE_PLAYERID_FIELD.has_default_value = false
descriptor.RPCMESSAGE_PLAYERID_FIELD.default_value = 0
descriptor.RPCMESSAGE_PLAYERID_FIELD.type = 3
descriptor.RPCMESSAGE_PLAYERID_FIELD.cpp_type = 2

descriptor.RPCMESSAGE_DATA_FIELD.name = "Data"
descriptor.RPCMESSAGE_DATA_FIELD.full_name = ".VK.Proto.RpcMessage.Data"
descriptor.RPCMESSAGE_DATA_FIELD.number = 5
descriptor.RPCMESSAGE_DATA_FIELD.index = 4
descriptor.RPCMESSAGE_DATA_FIELD.label = 1
descriptor.RPCMESSAGE_DATA_FIELD.has_default_value = false
descriptor.RPCMESSAGE_DATA_FIELD.default_value = ""
descriptor.RPCMESSAGE_DATA_FIELD.type = 12
descriptor.RPCMESSAGE_DATA_FIELD.cpp_type = 9

descriptor.RPCMESSAGE.name = "RpcMessage"
descriptor.RPCMESSAGE.full_name = ".VK.Proto.RpcMessage"
descriptor.RPCMESSAGE.nested_types = {}
descriptor.RPCMESSAGE.enum_types = {}
descriptor.RPCMESSAGE.fields = {descriptor.RPCMESSAGE_ID_FIELD, descriptor.RPCMESSAGE_RESPCHAN_FIELD, descriptor.RPCMESSAGE_OPS_FIELD, descriptor.RPCMESSAGE_PLAYERID_FIELD, descriptor.RPCMESSAGE_DATA_FIELD}
descriptor.RPCMESSAGE.is_extendable = false
descriptor.RPCMESSAGE.extensions = {}
descriptor.RPCRESP_ID_FIELD.name = "Id"
descriptor.RPCRESP_ID_FIELD.full_name = ".VK.Proto.RpcResp.Id"
descriptor.RPCRESP_ID_FIELD.number = 1
descriptor.RPCRESP_ID_FIELD.index = 0
descriptor.RPCRESP_ID_FIELD.label = 2
descriptor.RPCRESP_ID_FIELD.has_default_value = false
descriptor.RPCRESP_ID_FIELD.default_value = ""
descriptor.RPCRESP_ID_FIELD.type = 9
descriptor.RPCRESP_ID_FIELD.cpp_type = 9

descriptor.RPCRESP_EN_FIELD.name = "En"
descriptor.RPCRESP_EN_FIELD.full_name = ".VK.Proto.RpcResp.En"
descriptor.RPCRESP_EN_FIELD.number = 2
descriptor.RPCRESP_EN_FIELD.index = 1
descriptor.RPCRESP_EN_FIELD.label = 2
descriptor.RPCRESP_EN_FIELD.has_default_value = false
descriptor.RPCRESP_EN_FIELD.default_value = 0
descriptor.RPCRESP_EN_FIELD.type = 5
descriptor.RPCRESP_EN_FIELD.cpp_type = 1

descriptor.RPCRESP_DATA_FIELD.name = "Data"
descriptor.RPCRESP_DATA_FIELD.full_name = ".VK.Proto.RpcResp.Data"
descriptor.RPCRESP_DATA_FIELD.number = 3
descriptor.RPCRESP_DATA_FIELD.index = 2
descriptor.RPCRESP_DATA_FIELD.label = 1
descriptor.RPCRESP_DATA_FIELD.has_default_value = false
descriptor.RPCRESP_DATA_FIELD.default_value = ""
descriptor.RPCRESP_DATA_FIELD.type = 12
descriptor.RPCRESP_DATA_FIELD.cpp_type = 9

descriptor.RPCRESP.name = "RpcResp"
descriptor.RPCRESP.full_name = ".VK.Proto.RpcResp"
descriptor.RPCRESP.nested_types = {}
descriptor.RPCRESP.enum_types = {}
descriptor.RPCRESP.fields = {descriptor.RPCRESP_ID_FIELD, descriptor.RPCRESP_EN_FIELD, descriptor.RPCRESP_DATA_FIELD}
descriptor.RPCRESP.is_extendable = false
descriptor.RPCRESP.extensions = {}


pb.EMPTY = descriptor.EMPTY;
pb.MESSAGE = descriptor.MESSAGE;
pb.HTTPRESULT = descriptor.HTTPRESULT;
pb.RPCMESSAGE = descriptor.RPCMESSAGE;
pb.RPCRESP = descriptor.RPCRESP;

pb.Empty = protobuf.Message(descriptor.EMPTY)
pb.HttpResult = protobuf.Message(descriptor.HTTPRESULT)
pb.Message = protobuf.Message(descriptor.MESSAGE)
pb.RpcMessage = protobuf.Message(descriptor.RPCMESSAGE)
pb.RpcResp = protobuf.Message(descriptor.RPCRESP)

return pb