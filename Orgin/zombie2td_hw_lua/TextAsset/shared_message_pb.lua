-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf/protobuf"
local pb = {}
local descriptor = {}

descriptor.EMPTY = protobuf.Descriptor();
descriptor.MESSAGE = protobuf.Descriptor();
descriptor.MESSAGE_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.MESSAGE_OPS_FIELD = protobuf.FieldDescriptor();
descriptor.MESSAGE_DATA_FIELD = protobuf.FieldDescriptor();
descriptor.MESSAGE_SIGN_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPMESSAGE = protobuf.Descriptor();
descriptor.HTTPMESSAGE_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPMESSAGE_OPS_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPMESSAGE_DATA_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPMESSAGE_JSON_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPMESSAGE_SIGN_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPRESULT = protobuf.Descriptor();
descriptor.HTTPRESULT_EN_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPRESULT_DATA_FIELD = protobuf.FieldDescriptor();
descriptor.HTTPRESULT_JSON_FIELD = protobuf.FieldDescriptor();

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

descriptor.MESSAGE_SIGN_FIELD.name = "Sign"
descriptor.MESSAGE_SIGN_FIELD.full_name = ".VK.Proto.Message.Sign"
descriptor.MESSAGE_SIGN_FIELD.number = 4
descriptor.MESSAGE_SIGN_FIELD.index = 3
descriptor.MESSAGE_SIGN_FIELD.label = 1
descriptor.MESSAGE_SIGN_FIELD.has_default_value = false
descriptor.MESSAGE_SIGN_FIELD.default_value = ""
descriptor.MESSAGE_SIGN_FIELD.type = 9
descriptor.MESSAGE_SIGN_FIELD.cpp_type = 9

descriptor.MESSAGE.name = "Message"
descriptor.MESSAGE.full_name = ".VK.Proto.Message"
descriptor.MESSAGE.nested_types = {}
descriptor.MESSAGE.enum_types = {}
descriptor.MESSAGE.fields = {descriptor.MESSAGE_PLAYERID_FIELD, descriptor.MESSAGE_OPS_FIELD, descriptor.MESSAGE_DATA_FIELD, descriptor.MESSAGE_SIGN_FIELD}
descriptor.MESSAGE.is_extendable = false
descriptor.MESSAGE.extensions = {}
descriptor.HTTPMESSAGE_PLAYERID_FIELD.name = "PlayerID"
descriptor.HTTPMESSAGE_PLAYERID_FIELD.full_name = ".VK.Proto.HttpMessage.PlayerID"
descriptor.HTTPMESSAGE_PLAYERID_FIELD.number = 1
descriptor.HTTPMESSAGE_PLAYERID_FIELD.index = 0
descriptor.HTTPMESSAGE_PLAYERID_FIELD.label = 1
descriptor.HTTPMESSAGE_PLAYERID_FIELD.has_default_value = false
descriptor.HTTPMESSAGE_PLAYERID_FIELD.default_value = 0
descriptor.HTTPMESSAGE_PLAYERID_FIELD.type = 3
descriptor.HTTPMESSAGE_PLAYERID_FIELD.cpp_type = 2

descriptor.HTTPMESSAGE_OPS_FIELD.name = "Ops"
descriptor.HTTPMESSAGE_OPS_FIELD.full_name = ".VK.Proto.HttpMessage.Ops"
descriptor.HTTPMESSAGE_OPS_FIELD.number = 2
descriptor.HTTPMESSAGE_OPS_FIELD.index = 1
descriptor.HTTPMESSAGE_OPS_FIELD.label = 2
descriptor.HTTPMESSAGE_OPS_FIELD.has_default_value = false
descriptor.HTTPMESSAGE_OPS_FIELD.default_value = 0
descriptor.HTTPMESSAGE_OPS_FIELD.type = 5
descriptor.HTTPMESSAGE_OPS_FIELD.cpp_type = 1

descriptor.HTTPMESSAGE_DATA_FIELD.name = "Data"
descriptor.HTTPMESSAGE_DATA_FIELD.full_name = ".VK.Proto.HttpMessage.Data"
descriptor.HTTPMESSAGE_DATA_FIELD.number = 3
descriptor.HTTPMESSAGE_DATA_FIELD.index = 2
descriptor.HTTPMESSAGE_DATA_FIELD.label = 1
descriptor.HTTPMESSAGE_DATA_FIELD.has_default_value = false
descriptor.HTTPMESSAGE_DATA_FIELD.default_value = ""
descriptor.HTTPMESSAGE_DATA_FIELD.type = 12
descriptor.HTTPMESSAGE_DATA_FIELD.cpp_type = 9

descriptor.HTTPMESSAGE_JSON_FIELD.name = "Json"
descriptor.HTTPMESSAGE_JSON_FIELD.full_name = ".VK.Proto.HttpMessage.Json"
descriptor.HTTPMESSAGE_JSON_FIELD.number = 4
descriptor.HTTPMESSAGE_JSON_FIELD.index = 3
descriptor.HTTPMESSAGE_JSON_FIELD.label = 1
descriptor.HTTPMESSAGE_JSON_FIELD.has_default_value = false
descriptor.HTTPMESSAGE_JSON_FIELD.default_value = ""
descriptor.HTTPMESSAGE_JSON_FIELD.type = 9
descriptor.HTTPMESSAGE_JSON_FIELD.cpp_type = 9

descriptor.HTTPMESSAGE_SIGN_FIELD.name = "Sign"
descriptor.HTTPMESSAGE_SIGN_FIELD.full_name = ".VK.Proto.HttpMessage.Sign"
descriptor.HTTPMESSAGE_SIGN_FIELD.number = 5
descriptor.HTTPMESSAGE_SIGN_FIELD.index = 4
descriptor.HTTPMESSAGE_SIGN_FIELD.label = 1
descriptor.HTTPMESSAGE_SIGN_FIELD.has_default_value = false
descriptor.HTTPMESSAGE_SIGN_FIELD.default_value = ""
descriptor.HTTPMESSAGE_SIGN_FIELD.type = 9
descriptor.HTTPMESSAGE_SIGN_FIELD.cpp_type = 9

descriptor.HTTPMESSAGE.name = "HttpMessage"
descriptor.HTTPMESSAGE.full_name = ".VK.Proto.HttpMessage"
descriptor.HTTPMESSAGE.nested_types = {}
descriptor.HTTPMESSAGE.enum_types = {}
descriptor.HTTPMESSAGE.fields = {descriptor.HTTPMESSAGE_PLAYERID_FIELD, descriptor.HTTPMESSAGE_OPS_FIELD, descriptor.HTTPMESSAGE_DATA_FIELD, descriptor.HTTPMESSAGE_JSON_FIELD, descriptor.HTTPMESSAGE_SIGN_FIELD}
descriptor.HTTPMESSAGE.is_extendable = false
descriptor.HTTPMESSAGE.extensions = {}
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

descriptor.HTTPRESULT_JSON_FIELD.name = "Json"
descriptor.HTTPRESULT_JSON_FIELD.full_name = ".VK.Proto.HttpResult.Json"
descriptor.HTTPRESULT_JSON_FIELD.number = 3
descriptor.HTTPRESULT_JSON_FIELD.index = 2
descriptor.HTTPRESULT_JSON_FIELD.label = 1
descriptor.HTTPRESULT_JSON_FIELD.has_default_value = false
descriptor.HTTPRESULT_JSON_FIELD.default_value = ""
descriptor.HTTPRESULT_JSON_FIELD.type = 9
descriptor.HTTPRESULT_JSON_FIELD.cpp_type = 9

descriptor.HTTPRESULT.name = "HttpResult"
descriptor.HTTPRESULT.full_name = ".VK.Proto.HttpResult"
descriptor.HTTPRESULT.nested_types = {}
descriptor.HTTPRESULT.enum_types = {}
descriptor.HTTPRESULT.fields = {descriptor.HTTPRESULT_EN_FIELD, descriptor.HTTPRESULT_DATA_FIELD, descriptor.HTTPRESULT_JSON_FIELD}
descriptor.HTTPRESULT.is_extendable = false
descriptor.HTTPRESULT.extensions = {}


pb.EMPTY = descriptor.EMPTY;
pb.MESSAGE = descriptor.MESSAGE;
pb.HTTPMESSAGE = descriptor.HTTPMESSAGE;
pb.HTTPRESULT = descriptor.HTTPRESULT;

pb.Empty = protobuf.Message(descriptor.EMPTY)
pb.HttpMessage = protobuf.Message(descriptor.HTTPMESSAGE)
pb.HttpResult = protobuf.Message(descriptor.HTTPRESULT)
pb.Message = protobuf.Message(descriptor.MESSAGE)

return pb