-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf/protobuf"
local pb = {}
local descriptor = {}

descriptor.WEPAYCHANNEL = protobuf.EnumDescriptor();
descriptor.WEPAYCHANNEL_CHANNELMTOPUPTMN_ENUM = protobuf.EnumValueDescriptor();
descriptor.WEPAYCHANNEL_CHANNELMTOPUPHAPPY_ENUM = protobuf.EnumValueDescriptor();
descriptor.WEPAYCHANNEL_CHANNELMTOPUPTRMV_ENUM = protobuf.EnumValueDescriptor();
descriptor.WEPAYREQ = protobuf.Descriptor();
descriptor.WEPAYREQ_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.WEPAYREQ_AMOUNT_FIELD = protobuf.FieldDescriptor();
descriptor.WEPAYREQ_TOUSERNAME_FIELD = protobuf.FieldDescriptor();
descriptor.WEPAYREQ_CHANNEL_FIELD = protobuf.FieldDescriptor();
descriptor.WEPAYREQ_PROPID_FIELD = protobuf.FieldDescriptor();
descriptor.WEPAYREQ_PROPNUM_FIELD = protobuf.FieldDescriptor();

descriptor.WEPAYCHANNEL_CHANNELMTOPUPTMN_ENUM.name = "ChannelMToPupTmn"
descriptor.WEPAYCHANNEL_CHANNELMTOPUPTMN_ENUM.index = 0
descriptor.WEPAYCHANNEL_CHANNELMTOPUPTMN_ENUM.number = 1
descriptor.WEPAYCHANNEL_CHANNELMTOPUPHAPPY_ENUM.name = "ChannelMToPupHappy"
descriptor.WEPAYCHANNEL_CHANNELMTOPUPHAPPY_ENUM.index = 1
descriptor.WEPAYCHANNEL_CHANNELMTOPUPHAPPY_ENUM.number = 2
descriptor.WEPAYCHANNEL_CHANNELMTOPUPTRMV_ENUM.name = "ChannelMToPupTrmv"
descriptor.WEPAYCHANNEL_CHANNELMTOPUPTRMV_ENUM.index = 2
descriptor.WEPAYCHANNEL_CHANNELMTOPUPTRMV_ENUM.number = 3
descriptor.WEPAYCHANNEL.name = "WePayChannel"
descriptor.WEPAYCHANNEL.full_name = ".VK.Proto.WePayChannel"
descriptor.WEPAYCHANNEL.values = {descriptor.WEPAYCHANNEL_CHANNELMTOPUPTMN_ENUM,descriptor.WEPAYCHANNEL_CHANNELMTOPUPHAPPY_ENUM,descriptor.WEPAYCHANNEL_CHANNELMTOPUPTRMV_ENUM}
descriptor.WEPAYREQ_PLAYERID_FIELD.name = "PlayerID"
descriptor.WEPAYREQ_PLAYERID_FIELD.full_name = ".VK.Proto.WePayReq.PlayerID"
descriptor.WEPAYREQ_PLAYERID_FIELD.number = 1
descriptor.WEPAYREQ_PLAYERID_FIELD.index = 0
descriptor.WEPAYREQ_PLAYERID_FIELD.label = 2
descriptor.WEPAYREQ_PLAYERID_FIELD.has_default_value = false
descriptor.WEPAYREQ_PLAYERID_FIELD.default_value = 0
descriptor.WEPAYREQ_PLAYERID_FIELD.type = 3
descriptor.WEPAYREQ_PLAYERID_FIELD.cpp_type = 2

descriptor.WEPAYREQ_AMOUNT_FIELD.name = "Amount"
descriptor.WEPAYREQ_AMOUNT_FIELD.full_name = ".VK.Proto.WePayReq.Amount"
descriptor.WEPAYREQ_AMOUNT_FIELD.number = 2
descriptor.WEPAYREQ_AMOUNT_FIELD.index = 1
descriptor.WEPAYREQ_AMOUNT_FIELD.label = 2
descriptor.WEPAYREQ_AMOUNT_FIELD.has_default_value = false
descriptor.WEPAYREQ_AMOUNT_FIELD.default_value = 0
descriptor.WEPAYREQ_AMOUNT_FIELD.type = 3
descriptor.WEPAYREQ_AMOUNT_FIELD.cpp_type = 2

descriptor.WEPAYREQ_TOUSERNAME_FIELD.name = "ToUserName"
descriptor.WEPAYREQ_TOUSERNAME_FIELD.full_name = ".VK.Proto.WePayReq.ToUserName"
descriptor.WEPAYREQ_TOUSERNAME_FIELD.number = 3
descriptor.WEPAYREQ_TOUSERNAME_FIELD.index = 2
descriptor.WEPAYREQ_TOUSERNAME_FIELD.label = 2
descriptor.WEPAYREQ_TOUSERNAME_FIELD.has_default_value = false
descriptor.WEPAYREQ_TOUSERNAME_FIELD.default_value = ""
descriptor.WEPAYREQ_TOUSERNAME_FIELD.type = 9
descriptor.WEPAYREQ_TOUSERNAME_FIELD.cpp_type = 9

descriptor.WEPAYREQ_CHANNEL_FIELD.name = "Channel"
descriptor.WEPAYREQ_CHANNEL_FIELD.full_name = ".VK.Proto.WePayReq.Channel"
descriptor.WEPAYREQ_CHANNEL_FIELD.number = 4
descriptor.WEPAYREQ_CHANNEL_FIELD.index = 3
descriptor.WEPAYREQ_CHANNEL_FIELD.label = 2
descriptor.WEPAYREQ_CHANNEL_FIELD.has_default_value = false
descriptor.WEPAYREQ_CHANNEL_FIELD.default_value = 0
descriptor.WEPAYREQ_CHANNEL_FIELD.type = 3
descriptor.WEPAYREQ_CHANNEL_FIELD.cpp_type = 2

descriptor.WEPAYREQ_PROPID_FIELD.name = "PropID"
descriptor.WEPAYREQ_PROPID_FIELD.full_name = ".VK.Proto.WePayReq.PropID"
descriptor.WEPAYREQ_PROPID_FIELD.number = 5
descriptor.WEPAYREQ_PROPID_FIELD.index = 4
descriptor.WEPAYREQ_PROPID_FIELD.label = 1
descriptor.WEPAYREQ_PROPID_FIELD.has_default_value = false
descriptor.WEPAYREQ_PROPID_FIELD.default_value = 0
descriptor.WEPAYREQ_PROPID_FIELD.type = 3
descriptor.WEPAYREQ_PROPID_FIELD.cpp_type = 2

descriptor.WEPAYREQ_PROPNUM_FIELD.name = "PropNum"
descriptor.WEPAYREQ_PROPNUM_FIELD.full_name = ".VK.Proto.WePayReq.PropNum"
descriptor.WEPAYREQ_PROPNUM_FIELD.number = 6
descriptor.WEPAYREQ_PROPNUM_FIELD.index = 5
descriptor.WEPAYREQ_PROPNUM_FIELD.label = 1
descriptor.WEPAYREQ_PROPNUM_FIELD.has_default_value = false
descriptor.WEPAYREQ_PROPNUM_FIELD.default_value = 0
descriptor.WEPAYREQ_PROPNUM_FIELD.type = 3
descriptor.WEPAYREQ_PROPNUM_FIELD.cpp_type = 2

descriptor.WEPAYREQ.name = "WePayReq"
descriptor.WEPAYREQ.full_name = ".VK.Proto.WePayReq"
descriptor.WEPAYREQ.nested_types = {}
descriptor.WEPAYREQ.enum_types = {}
descriptor.WEPAYREQ.fields = {descriptor.WEPAYREQ_PLAYERID_FIELD, descriptor.WEPAYREQ_AMOUNT_FIELD, descriptor.WEPAYREQ_TOUSERNAME_FIELD, descriptor.WEPAYREQ_CHANNEL_FIELD, descriptor.WEPAYREQ_PROPID_FIELD, descriptor.WEPAYREQ_PROPNUM_FIELD}
descriptor.WEPAYREQ.is_extendable = false
descriptor.WEPAYREQ.extensions = {}


pb.WEPAYREQ = descriptor.WEPAYREQ;

pb.ChannelMToPupHappy = 2
pb.ChannelMToPupTmn = 1
pb.ChannelMToPupTrmv = 3
pb.WePayReq = protobuf.Message(descriptor.WEPAYREQ)

return pb