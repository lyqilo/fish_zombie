-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf/protobuf"
local pb = {}
local descriptor = {}

descriptor.BLOCKCHAINSTATUS = protobuf.EnumDescriptor();
descriptor.BLOCKCHAINSTATUS_STATUSNO_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINSTATUS_STATUSRECEIVE_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINSTATUS_STATUSPENDING_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE = protobuf.EnumDescriptor();
descriptor.BLOCKCHAINTYPE_TASKDAILYCHECKIN_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKONLINETIME_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKSHAREFRIEND_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKRECHARGEAMOUNT_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKVIPUPGRADE_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKTOTALLOSE_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKAGENT_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKREALSHOP_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKTREASURE_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKBINDFB_ENUM = protobuf.EnumValueDescriptor();
descriptor.BLOCKCHAINTYPE_TASKBINDOTP_ENUM = protobuf.EnumValueDescriptor();
descriptor.BC_TASK = protobuf.Descriptor();
descriptor.BC_TASK_TASKID_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_STATUS_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_RECEIVETIME_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_PROPNUM_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_PROPID_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_TASKTYPE_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_RECEIVELEVEL_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_TASKNAME_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_ISADD_FIELD = protobuf.FieldDescriptor();
descriptor.BC_TASK_PENDINGLEVEL_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN = protobuf.Descriptor();
descriptor.BC_HCOIN_BALANCENUMBER_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_STATUS_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_BALANCE_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_BALANCEAFTER_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_ISADD_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_REMARK_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_CREATETIME_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_UPDATETIME_FIELD = protobuf.FieldDescriptor();
descriptor.BC_HCOIN_BALANCETYPE_FIELD = protobuf.FieldDescriptor();
descriptor.TOKENREQ = protobuf.Descriptor();
descriptor.TOKENREQ_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.TOKENRESP = protobuf.Descriptor();
descriptor.TOKENRESP_TOKEN_FIELD = protobuf.FieldDescriptor();
descriptor.TASKLISTREQ = protobuf.Descriptor();
descriptor.TASKLISTREQ_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.TASKLISTRESP = protobuf.Descriptor();
descriptor.TASKLISTRESP_BALANCE_FIELD = protobuf.FieldDescriptor();
descriptor.TASKLISTRESP_INCOME_FIELD = protobuf.FieldDescriptor();
descriptor.TASKLISTRESP_WAITINCOME_FIELD = protobuf.FieldDescriptor();
descriptor.TASKLISTRESP_POWER_FIELD = protobuf.FieldDescriptor();
descriptor.TASKLISTRESP_GRANDTIME_FIELD = protobuf.FieldDescriptor();
descriptor.TASKLISTRESP_COUNTDOWN_FIELD = protobuf.FieldDescriptor();
descriptor.TASKLISTRESP_LIST_FIELD = protobuf.FieldDescriptor();
descriptor.RECEIVEREQ = protobuf.Descriptor();
descriptor.RECEIVEREQ_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.RECEIVEREQ_TASKID_FIELD = protobuf.FieldDescriptor();
descriptor.RECEIVERESP = protobuf.Descriptor();
descriptor.RECEIVERESP_PROPID_FIELD = protobuf.FieldDescriptor();
descriptor.RECEIVERESP_PROPNUM_FIELD = protobuf.FieldDescriptor();
descriptor.RECEIVEHCOINREQ = protobuf.Descriptor();
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.RECEIVEHCOINRESP = protobuf.Descriptor();
descriptor.RECEIVEHCOINRESP_INCOME_FIELD = protobuf.FieldDescriptor();
descriptor.POWERLISTREQ = protobuf.Descriptor();
descriptor.POWERLISTREQ_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.POWERLISTRESP = protobuf.Descriptor();
descriptor.POWERLISTRESP_LIST_FIELD = protobuf.FieldDescriptor();
descriptor.HCOINLISTREQ = protobuf.Descriptor();
descriptor.HCOINLISTREQ_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.HCOINLISTRESP = protobuf.Descriptor();
descriptor.HCOINLISTRESP_LIST_FIELD = protobuf.FieldDescriptor();
descriptor.BCSHAREREQ = protobuf.Descriptor();
descriptor.BCSHAREREQ_PLAYERID_FIELD = protobuf.FieldDescriptor();
descriptor.BCSHARERESP = protobuf.Descriptor();

descriptor.BLOCKCHAINSTATUS_STATUSNO_ENUM.name = "StatusNo"
descriptor.BLOCKCHAINSTATUS_STATUSNO_ENUM.index = 0
descriptor.BLOCKCHAINSTATUS_STATUSNO_ENUM.number = 0
descriptor.BLOCKCHAINSTATUS_STATUSRECEIVE_ENUM.name = "StatusReceive"
descriptor.BLOCKCHAINSTATUS_STATUSRECEIVE_ENUM.index = 1
descriptor.BLOCKCHAINSTATUS_STATUSRECEIVE_ENUM.number = 1
descriptor.BLOCKCHAINSTATUS_STATUSPENDING_ENUM.name = "StatusPending"
descriptor.BLOCKCHAINSTATUS_STATUSPENDING_ENUM.index = 2
descriptor.BLOCKCHAINSTATUS_STATUSPENDING_ENUM.number = 2
descriptor.BLOCKCHAINSTATUS.name = "BlockchainStatus"
descriptor.BLOCKCHAINSTATUS.full_name = ".VK.Proto.BlockchainStatus"
descriptor.BLOCKCHAINSTATUS.values = {descriptor.BLOCKCHAINSTATUS_STATUSNO_ENUM,descriptor.BLOCKCHAINSTATUS_STATUSRECEIVE_ENUM,descriptor.BLOCKCHAINSTATUS_STATUSPENDING_ENUM}
descriptor.BLOCKCHAINTYPE_TASKDAILYCHECKIN_ENUM.name = "TaskDailyCheckIn"
descriptor.BLOCKCHAINTYPE_TASKDAILYCHECKIN_ENUM.index = 0
descriptor.BLOCKCHAINTYPE_TASKDAILYCHECKIN_ENUM.number = 1
descriptor.BLOCKCHAINTYPE_TASKONLINETIME_ENUM.name = "TaskOnlineTime"
descriptor.BLOCKCHAINTYPE_TASKONLINETIME_ENUM.index = 1
descriptor.BLOCKCHAINTYPE_TASKONLINETIME_ENUM.number = 2
descriptor.BLOCKCHAINTYPE_TASKSHAREFRIEND_ENUM.name = "TaskShareFriend"
descriptor.BLOCKCHAINTYPE_TASKSHAREFRIEND_ENUM.index = 2
descriptor.BLOCKCHAINTYPE_TASKSHAREFRIEND_ENUM.number = 3
descriptor.BLOCKCHAINTYPE_TASKRECHARGEAMOUNT_ENUM.name = "TaskRechargeAmount"
descriptor.BLOCKCHAINTYPE_TASKRECHARGEAMOUNT_ENUM.index = 3
descriptor.BLOCKCHAINTYPE_TASKRECHARGEAMOUNT_ENUM.number = 4
descriptor.BLOCKCHAINTYPE_TASKVIPUPGRADE_ENUM.name = "TaskVipUpgrade"
descriptor.BLOCKCHAINTYPE_TASKVIPUPGRADE_ENUM.index = 4
descriptor.BLOCKCHAINTYPE_TASKVIPUPGRADE_ENUM.number = 5
descriptor.BLOCKCHAINTYPE_TASKTOTALLOSE_ENUM.name = "TaskTotalLose"
descriptor.BLOCKCHAINTYPE_TASKTOTALLOSE_ENUM.index = 5
descriptor.BLOCKCHAINTYPE_TASKTOTALLOSE_ENUM.number = 6
descriptor.BLOCKCHAINTYPE_TASKAGENT_ENUM.name = "TaskAgent"
descriptor.BLOCKCHAINTYPE_TASKAGENT_ENUM.index = 6
descriptor.BLOCKCHAINTYPE_TASKAGENT_ENUM.number = 7
descriptor.BLOCKCHAINTYPE_TASKREALSHOP_ENUM.name = "TaskRealShop"
descriptor.BLOCKCHAINTYPE_TASKREALSHOP_ENUM.index = 7
descriptor.BLOCKCHAINTYPE_TASKREALSHOP_ENUM.number = 8
descriptor.BLOCKCHAINTYPE_TASKTREASURE_ENUM.name = "TaskTreasure"
descriptor.BLOCKCHAINTYPE_TASKTREASURE_ENUM.index = 8
descriptor.BLOCKCHAINTYPE_TASKTREASURE_ENUM.number = 9
descriptor.BLOCKCHAINTYPE_TASKBINDFB_ENUM.name = "TaskBindFb"
descriptor.BLOCKCHAINTYPE_TASKBINDFB_ENUM.index = 9
descriptor.BLOCKCHAINTYPE_TASKBINDFB_ENUM.number = 10
descriptor.BLOCKCHAINTYPE_TASKBINDOTP_ENUM.name = "TaskBindOtp"
descriptor.BLOCKCHAINTYPE_TASKBINDOTP_ENUM.index = 10
descriptor.BLOCKCHAINTYPE_TASKBINDOTP_ENUM.number = 11
descriptor.BLOCKCHAINTYPE.name = "BlockchainType"
descriptor.BLOCKCHAINTYPE.full_name = ".VK.Proto.BlockchainType"
descriptor.BLOCKCHAINTYPE.values = {descriptor.BLOCKCHAINTYPE_TASKDAILYCHECKIN_ENUM,descriptor.BLOCKCHAINTYPE_TASKONLINETIME_ENUM,descriptor.BLOCKCHAINTYPE_TASKSHAREFRIEND_ENUM,descriptor.BLOCKCHAINTYPE_TASKRECHARGEAMOUNT_ENUM,descriptor.BLOCKCHAINTYPE_TASKVIPUPGRADE_ENUM,descriptor.BLOCKCHAINTYPE_TASKTOTALLOSE_ENUM,descriptor.BLOCKCHAINTYPE_TASKAGENT_ENUM,descriptor.BLOCKCHAINTYPE_TASKREALSHOP_ENUM,descriptor.BLOCKCHAINTYPE_TASKTREASURE_ENUM,descriptor.BLOCKCHAINTYPE_TASKBINDFB_ENUM,descriptor.BLOCKCHAINTYPE_TASKBINDOTP_ENUM}
descriptor.BC_TASK_TASKID_FIELD.name = "TaskID"
descriptor.BC_TASK_TASKID_FIELD.full_name = ".VK.Proto.Bc_Task.TaskID"
descriptor.BC_TASK_TASKID_FIELD.number = 1
descriptor.BC_TASK_TASKID_FIELD.index = 0
descriptor.BC_TASK_TASKID_FIELD.label = 2
descriptor.BC_TASK_TASKID_FIELD.has_default_value = false
descriptor.BC_TASK_TASKID_FIELD.default_value = 0
descriptor.BC_TASK_TASKID_FIELD.type = 3
descriptor.BC_TASK_TASKID_FIELD.cpp_type = 2

descriptor.BC_TASK_STATUS_FIELD.name = "Status"
descriptor.BC_TASK_STATUS_FIELD.full_name = ".VK.Proto.Bc_Task.Status"
descriptor.BC_TASK_STATUS_FIELD.number = 2
descriptor.BC_TASK_STATUS_FIELD.index = 1
descriptor.BC_TASK_STATUS_FIELD.label = 2
descriptor.BC_TASK_STATUS_FIELD.has_default_value = false
descriptor.BC_TASK_STATUS_FIELD.default_value = 0
descriptor.BC_TASK_STATUS_FIELD.type = 3
descriptor.BC_TASK_STATUS_FIELD.cpp_type = 2

descriptor.BC_TASK_RECEIVETIME_FIELD.name = "ReceiveTime"
descriptor.BC_TASK_RECEIVETIME_FIELD.full_name = ".VK.Proto.Bc_Task.ReceiveTime"
descriptor.BC_TASK_RECEIVETIME_FIELD.number = 3
descriptor.BC_TASK_RECEIVETIME_FIELD.index = 2
descriptor.BC_TASK_RECEIVETIME_FIELD.label = 2
descriptor.BC_TASK_RECEIVETIME_FIELD.has_default_value = false
descriptor.BC_TASK_RECEIVETIME_FIELD.default_value = 0
descriptor.BC_TASK_RECEIVETIME_FIELD.type = 3
descriptor.BC_TASK_RECEIVETIME_FIELD.cpp_type = 2

descriptor.BC_TASK_PROPNUM_FIELD.name = "PropNum"
descriptor.BC_TASK_PROPNUM_FIELD.full_name = ".VK.Proto.Bc_Task.PropNum"
descriptor.BC_TASK_PROPNUM_FIELD.number = 4
descriptor.BC_TASK_PROPNUM_FIELD.index = 3
descriptor.BC_TASK_PROPNUM_FIELD.label = 2
descriptor.BC_TASK_PROPNUM_FIELD.has_default_value = false
descriptor.BC_TASK_PROPNUM_FIELD.default_value = 0
descriptor.BC_TASK_PROPNUM_FIELD.type = 3
descriptor.BC_TASK_PROPNUM_FIELD.cpp_type = 2

descriptor.BC_TASK_PROPID_FIELD.name = "PropID"
descriptor.BC_TASK_PROPID_FIELD.full_name = ".VK.Proto.Bc_Task.PropID"
descriptor.BC_TASK_PROPID_FIELD.number = 5
descriptor.BC_TASK_PROPID_FIELD.index = 4
descriptor.BC_TASK_PROPID_FIELD.label = 2
descriptor.BC_TASK_PROPID_FIELD.has_default_value = false
descriptor.BC_TASK_PROPID_FIELD.default_value = 0
descriptor.BC_TASK_PROPID_FIELD.type = 3
descriptor.BC_TASK_PROPID_FIELD.cpp_type = 2

descriptor.BC_TASK_TASKTYPE_FIELD.name = "TaskType"
descriptor.BC_TASK_TASKTYPE_FIELD.full_name = ".VK.Proto.Bc_Task.TaskType"
descriptor.BC_TASK_TASKTYPE_FIELD.number = 6
descriptor.BC_TASK_TASKTYPE_FIELD.index = 5
descriptor.BC_TASK_TASKTYPE_FIELD.label = 1
descriptor.BC_TASK_TASKTYPE_FIELD.has_default_value = false
descriptor.BC_TASK_TASKTYPE_FIELD.default_value = 0
descriptor.BC_TASK_TASKTYPE_FIELD.type = 5
descriptor.BC_TASK_TASKTYPE_FIELD.cpp_type = 1

descriptor.BC_TASK_RECEIVELEVEL_FIELD.name = "ReceiveLevel"
descriptor.BC_TASK_RECEIVELEVEL_FIELD.full_name = ".VK.Proto.Bc_Task.ReceiveLevel"
descriptor.BC_TASK_RECEIVELEVEL_FIELD.number = 7
descriptor.BC_TASK_RECEIVELEVEL_FIELD.index = 6
descriptor.BC_TASK_RECEIVELEVEL_FIELD.label = 1
descriptor.BC_TASK_RECEIVELEVEL_FIELD.has_default_value = false
descriptor.BC_TASK_RECEIVELEVEL_FIELD.default_value = 0
descriptor.BC_TASK_RECEIVELEVEL_FIELD.type = 5
descriptor.BC_TASK_RECEIVELEVEL_FIELD.cpp_type = 1

descriptor.BC_TASK_TASKNAME_FIELD.name = "TaskName"
descriptor.BC_TASK_TASKNAME_FIELD.full_name = ".VK.Proto.Bc_Task.TaskName"
descriptor.BC_TASK_TASKNAME_FIELD.number = 8
descriptor.BC_TASK_TASKNAME_FIELD.index = 7
descriptor.BC_TASK_TASKNAME_FIELD.label = 2
descriptor.BC_TASK_TASKNAME_FIELD.has_default_value = false
descriptor.BC_TASK_TASKNAME_FIELD.default_value = ""
descriptor.BC_TASK_TASKNAME_FIELD.type = 9
descriptor.BC_TASK_TASKNAME_FIELD.cpp_type = 9

descriptor.BC_TASK_ISADD_FIELD.name = "IsAdd"
descriptor.BC_TASK_ISADD_FIELD.full_name = ".VK.Proto.Bc_Task.IsAdd"
descriptor.BC_TASK_ISADD_FIELD.number = 9
descriptor.BC_TASK_ISADD_FIELD.index = 8
descriptor.BC_TASK_ISADD_FIELD.label = 1
descriptor.BC_TASK_ISADD_FIELD.has_default_value = false
descriptor.BC_TASK_ISADD_FIELD.default_value = 0
descriptor.BC_TASK_ISADD_FIELD.type = 5
descriptor.BC_TASK_ISADD_FIELD.cpp_type = 1

descriptor.BC_TASK_PENDINGLEVEL_FIELD.name = "PendingLevel"
descriptor.BC_TASK_PENDINGLEVEL_FIELD.full_name = ".VK.Proto.Bc_Task.PendingLevel"
descriptor.BC_TASK_PENDINGLEVEL_FIELD.number = 10
descriptor.BC_TASK_PENDINGLEVEL_FIELD.index = 9
descriptor.BC_TASK_PENDINGLEVEL_FIELD.label = 1
descriptor.BC_TASK_PENDINGLEVEL_FIELD.has_default_value = false
descriptor.BC_TASK_PENDINGLEVEL_FIELD.default_value = 0
descriptor.BC_TASK_PENDINGLEVEL_FIELD.type = 5
descriptor.BC_TASK_PENDINGLEVEL_FIELD.cpp_type = 1

descriptor.BC_TASK.name = "Bc_Task"
descriptor.BC_TASK.full_name = ".VK.Proto.Bc_Task"
descriptor.BC_TASK.nested_types = {}
descriptor.BC_TASK.enum_types = {}
descriptor.BC_TASK.fields = {descriptor.BC_TASK_TASKID_FIELD, descriptor.BC_TASK_STATUS_FIELD, descriptor.BC_TASK_RECEIVETIME_FIELD, descriptor.BC_TASK_PROPNUM_FIELD, descriptor.BC_TASK_PROPID_FIELD, descriptor.BC_TASK_TASKTYPE_FIELD, descriptor.BC_TASK_RECEIVELEVEL_FIELD, descriptor.BC_TASK_TASKNAME_FIELD, descriptor.BC_TASK_ISADD_FIELD, descriptor.BC_TASK_PENDINGLEVEL_FIELD}
descriptor.BC_TASK.is_extendable = false
descriptor.BC_TASK.extensions = {}
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.name = "BalanceNumber"
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.full_name = ".VK.Proto.Bc_HCoin.BalanceNumber"
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.number = 1
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.index = 0
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.label = 2
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.has_default_value = false
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.default_value = 0
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.type = 3
descriptor.BC_HCOIN_BALANCENUMBER_FIELD.cpp_type = 2

descriptor.BC_HCOIN_STATUS_FIELD.name = "Status"
descriptor.BC_HCOIN_STATUS_FIELD.full_name = ".VK.Proto.Bc_HCoin.Status"
descriptor.BC_HCOIN_STATUS_FIELD.number = 2
descriptor.BC_HCOIN_STATUS_FIELD.index = 1
descriptor.BC_HCOIN_STATUS_FIELD.label = 2
descriptor.BC_HCOIN_STATUS_FIELD.has_default_value = false
descriptor.BC_HCOIN_STATUS_FIELD.default_value = 0
descriptor.BC_HCOIN_STATUS_FIELD.type = 3
descriptor.BC_HCOIN_STATUS_FIELD.cpp_type = 2

descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.name = "BalanceBefore"
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.full_name = ".VK.Proto.Bc_HCoin.BalanceBefore"
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.number = 3
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.index = 2
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.label = 2
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.has_default_value = false
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.default_value = 0
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.type = 3
descriptor.BC_HCOIN_BALANCEBEFORE_FIELD.cpp_type = 2

descriptor.BC_HCOIN_BALANCE_FIELD.name = "Balance"
descriptor.BC_HCOIN_BALANCE_FIELD.full_name = ".VK.Proto.Bc_HCoin.Balance"
descriptor.BC_HCOIN_BALANCE_FIELD.number = 4
descriptor.BC_HCOIN_BALANCE_FIELD.index = 3
descriptor.BC_HCOIN_BALANCE_FIELD.label = 2
descriptor.BC_HCOIN_BALANCE_FIELD.has_default_value = false
descriptor.BC_HCOIN_BALANCE_FIELD.default_value = 0
descriptor.BC_HCOIN_BALANCE_FIELD.type = 3
descriptor.BC_HCOIN_BALANCE_FIELD.cpp_type = 2

descriptor.BC_HCOIN_BALANCEAFTER_FIELD.name = "BalanceAfter"
descriptor.BC_HCOIN_BALANCEAFTER_FIELD.full_name = ".VK.Proto.Bc_HCoin.BalanceAfter"
descriptor.BC_HCOIN_BALANCEAFTER_FIELD.number = 5
descriptor.BC_HCOIN_BALANCEAFTER_FIELD.index = 4
descriptor.BC_HCOIN_BALANCEAFTER_FIELD.label = 2
descriptor.BC_HCOIN_BALANCEAFTER_FIELD.has_default_value = false
descriptor.BC_HCOIN_BALANCEAFTER_FIELD.default_value = 0
descriptor.BC_HCOIN_BALANCEAFTER_FIELD.type = 3
descriptor.BC_HCOIN_BALANCEAFTER_FIELD.cpp_type = 2

descriptor.BC_HCOIN_ISADD_FIELD.name = "IsAdd"
descriptor.BC_HCOIN_ISADD_FIELD.full_name = ".VK.Proto.Bc_HCoin.IsAdd"
descriptor.BC_HCOIN_ISADD_FIELD.number = 6
descriptor.BC_HCOIN_ISADD_FIELD.index = 5
descriptor.BC_HCOIN_ISADD_FIELD.label = 2
descriptor.BC_HCOIN_ISADD_FIELD.has_default_value = false
descriptor.BC_HCOIN_ISADD_FIELD.default_value = 0
descriptor.BC_HCOIN_ISADD_FIELD.type = 5
descriptor.BC_HCOIN_ISADD_FIELD.cpp_type = 1

descriptor.BC_HCOIN_REMARK_FIELD.name = "Remark"
descriptor.BC_HCOIN_REMARK_FIELD.full_name = ".VK.Proto.Bc_HCoin.Remark"
descriptor.BC_HCOIN_REMARK_FIELD.number = 7
descriptor.BC_HCOIN_REMARK_FIELD.index = 6
descriptor.BC_HCOIN_REMARK_FIELD.label = 2
descriptor.BC_HCOIN_REMARK_FIELD.has_default_value = false
descriptor.BC_HCOIN_REMARK_FIELD.default_value = ""
descriptor.BC_HCOIN_REMARK_FIELD.type = 9
descriptor.BC_HCOIN_REMARK_FIELD.cpp_type = 9

descriptor.BC_HCOIN_CREATETIME_FIELD.name = "CreateTime"
descriptor.BC_HCOIN_CREATETIME_FIELD.full_name = ".VK.Proto.Bc_HCoin.CreateTime"
descriptor.BC_HCOIN_CREATETIME_FIELD.number = 8
descriptor.BC_HCOIN_CREATETIME_FIELD.index = 7
descriptor.BC_HCOIN_CREATETIME_FIELD.label = 2
descriptor.BC_HCOIN_CREATETIME_FIELD.has_default_value = false
descriptor.BC_HCOIN_CREATETIME_FIELD.default_value = 0
descriptor.BC_HCOIN_CREATETIME_FIELD.type = 3
descriptor.BC_HCOIN_CREATETIME_FIELD.cpp_type = 2

descriptor.BC_HCOIN_UPDATETIME_FIELD.name = "UpdateTime"
descriptor.BC_HCOIN_UPDATETIME_FIELD.full_name = ".VK.Proto.Bc_HCoin.UpdateTime"
descriptor.BC_HCOIN_UPDATETIME_FIELD.number = 9
descriptor.BC_HCOIN_UPDATETIME_FIELD.index = 8
descriptor.BC_HCOIN_UPDATETIME_FIELD.label = 2
descriptor.BC_HCOIN_UPDATETIME_FIELD.has_default_value = false
descriptor.BC_HCOIN_UPDATETIME_FIELD.default_value = 0
descriptor.BC_HCOIN_UPDATETIME_FIELD.type = 3
descriptor.BC_HCOIN_UPDATETIME_FIELD.cpp_type = 2

descriptor.BC_HCOIN_BALANCETYPE_FIELD.name = "BalanceType"
descriptor.BC_HCOIN_BALANCETYPE_FIELD.full_name = ".VK.Proto.Bc_HCoin.BalanceType"
descriptor.BC_HCOIN_BALANCETYPE_FIELD.number = 10
descriptor.BC_HCOIN_BALANCETYPE_FIELD.index = 9
descriptor.BC_HCOIN_BALANCETYPE_FIELD.label = 2
descriptor.BC_HCOIN_BALANCETYPE_FIELD.has_default_value = false
descriptor.BC_HCOIN_BALANCETYPE_FIELD.default_value = 0
descriptor.BC_HCOIN_BALANCETYPE_FIELD.type = 5
descriptor.BC_HCOIN_BALANCETYPE_FIELD.cpp_type = 1

descriptor.BC_HCOIN.name = "Bc_HCoin"
descriptor.BC_HCOIN.full_name = ".VK.Proto.Bc_HCoin"
descriptor.BC_HCOIN.nested_types = {}
descriptor.BC_HCOIN.enum_types = {}
descriptor.BC_HCOIN.fields = {descriptor.BC_HCOIN_BALANCENUMBER_FIELD, descriptor.BC_HCOIN_STATUS_FIELD, descriptor.BC_HCOIN_BALANCEBEFORE_FIELD, descriptor.BC_HCOIN_BALANCE_FIELD, descriptor.BC_HCOIN_BALANCEAFTER_FIELD, descriptor.BC_HCOIN_ISADD_FIELD, descriptor.BC_HCOIN_REMARK_FIELD, descriptor.BC_HCOIN_CREATETIME_FIELD, descriptor.BC_HCOIN_UPDATETIME_FIELD, descriptor.BC_HCOIN_BALANCETYPE_FIELD}
descriptor.BC_HCOIN.is_extendable = false
descriptor.BC_HCOIN.extensions = {}
descriptor.TOKENREQ_PLAYERID_FIELD.name = "PlayerID"
descriptor.TOKENREQ_PLAYERID_FIELD.full_name = ".VK.Proto.TokenReq.PlayerID"
descriptor.TOKENREQ_PLAYERID_FIELD.number = 1
descriptor.TOKENREQ_PLAYERID_FIELD.index = 0
descriptor.TOKENREQ_PLAYERID_FIELD.label = 2
descriptor.TOKENREQ_PLAYERID_FIELD.has_default_value = false
descriptor.TOKENREQ_PLAYERID_FIELD.default_value = 0
descriptor.TOKENREQ_PLAYERID_FIELD.type = 3
descriptor.TOKENREQ_PLAYERID_FIELD.cpp_type = 2

descriptor.TOKENREQ.name = "TokenReq"
descriptor.TOKENREQ.full_name = ".VK.Proto.TokenReq"
descriptor.TOKENREQ.nested_types = {}
descriptor.TOKENREQ.enum_types = {}
descriptor.TOKENREQ.fields = {descriptor.TOKENREQ_PLAYERID_FIELD}
descriptor.TOKENREQ.is_extendable = false
descriptor.TOKENREQ.extensions = {}
descriptor.TOKENRESP_TOKEN_FIELD.name = "Token"
descriptor.TOKENRESP_TOKEN_FIELD.full_name = ".VK.Proto.TokenResp.Token"
descriptor.TOKENRESP_TOKEN_FIELD.number = 1
descriptor.TOKENRESP_TOKEN_FIELD.index = 0
descriptor.TOKENRESP_TOKEN_FIELD.label = 2
descriptor.TOKENRESP_TOKEN_FIELD.has_default_value = false
descriptor.TOKENRESP_TOKEN_FIELD.default_value = ""
descriptor.TOKENRESP_TOKEN_FIELD.type = 9
descriptor.TOKENRESP_TOKEN_FIELD.cpp_type = 9

descriptor.TOKENRESP.name = "TokenResp"
descriptor.TOKENRESP.full_name = ".VK.Proto.TokenResp"
descriptor.TOKENRESP.nested_types = {}
descriptor.TOKENRESP.enum_types = {}
descriptor.TOKENRESP.fields = {descriptor.TOKENRESP_TOKEN_FIELD}
descriptor.TOKENRESP.is_extendable = false
descriptor.TOKENRESP.extensions = {}
descriptor.TASKLISTREQ_PLAYERID_FIELD.name = "PlayerID"
descriptor.TASKLISTREQ_PLAYERID_FIELD.full_name = ".VK.Proto.TaskListReq.PlayerID"
descriptor.TASKLISTREQ_PLAYERID_FIELD.number = 1
descriptor.TASKLISTREQ_PLAYERID_FIELD.index = 0
descriptor.TASKLISTREQ_PLAYERID_FIELD.label = 2
descriptor.TASKLISTREQ_PLAYERID_FIELD.has_default_value = false
descriptor.TASKLISTREQ_PLAYERID_FIELD.default_value = 0
descriptor.TASKLISTREQ_PLAYERID_FIELD.type = 3
descriptor.TASKLISTREQ_PLAYERID_FIELD.cpp_type = 2

descriptor.TASKLISTREQ.name = "TaskListReq"
descriptor.TASKLISTREQ.full_name = ".VK.Proto.TaskListReq"
descriptor.TASKLISTREQ.nested_types = {}
descriptor.TASKLISTREQ.enum_types = {}
descriptor.TASKLISTREQ.fields = {descriptor.TASKLISTREQ_PLAYERID_FIELD}
descriptor.TASKLISTREQ.is_extendable = false
descriptor.TASKLISTREQ.extensions = {}
descriptor.TASKLISTRESP_BALANCE_FIELD.name = "Balance"
descriptor.TASKLISTRESP_BALANCE_FIELD.full_name = ".VK.Proto.TaskListResp.Balance"
descriptor.TASKLISTRESP_BALANCE_FIELD.number = 1
descriptor.TASKLISTRESP_BALANCE_FIELD.index = 0
descriptor.TASKLISTRESP_BALANCE_FIELD.label = 2
descriptor.TASKLISTRESP_BALANCE_FIELD.has_default_value = false
descriptor.TASKLISTRESP_BALANCE_FIELD.default_value = 0
descriptor.TASKLISTRESP_BALANCE_FIELD.type = 3
descriptor.TASKLISTRESP_BALANCE_FIELD.cpp_type = 2

descriptor.TASKLISTRESP_INCOME_FIELD.name = "InCome"
descriptor.TASKLISTRESP_INCOME_FIELD.full_name = ".VK.Proto.TaskListResp.InCome"
descriptor.TASKLISTRESP_INCOME_FIELD.number = 2
descriptor.TASKLISTRESP_INCOME_FIELD.index = 1
descriptor.TASKLISTRESP_INCOME_FIELD.label = 2
descriptor.TASKLISTRESP_INCOME_FIELD.has_default_value = false
descriptor.TASKLISTRESP_INCOME_FIELD.default_value = 0
descriptor.TASKLISTRESP_INCOME_FIELD.type = 3
descriptor.TASKLISTRESP_INCOME_FIELD.cpp_type = 2

descriptor.TASKLISTRESP_WAITINCOME_FIELD.name = "WaitInCome"
descriptor.TASKLISTRESP_WAITINCOME_FIELD.full_name = ".VK.Proto.TaskListResp.WaitInCome"
descriptor.TASKLISTRESP_WAITINCOME_FIELD.number = 3
descriptor.TASKLISTRESP_WAITINCOME_FIELD.index = 2
descriptor.TASKLISTRESP_WAITINCOME_FIELD.label = 2
descriptor.TASKLISTRESP_WAITINCOME_FIELD.has_default_value = false
descriptor.TASKLISTRESP_WAITINCOME_FIELD.default_value = 0
descriptor.TASKLISTRESP_WAITINCOME_FIELD.type = 3
descriptor.TASKLISTRESP_WAITINCOME_FIELD.cpp_type = 2

descriptor.TASKLISTRESP_POWER_FIELD.name = "Power"
descriptor.TASKLISTRESP_POWER_FIELD.full_name = ".VK.Proto.TaskListResp.Power"
descriptor.TASKLISTRESP_POWER_FIELD.number = 4
descriptor.TASKLISTRESP_POWER_FIELD.index = 3
descriptor.TASKLISTRESP_POWER_FIELD.label = 2
descriptor.TASKLISTRESP_POWER_FIELD.has_default_value = false
descriptor.TASKLISTRESP_POWER_FIELD.default_value = 0
descriptor.TASKLISTRESP_POWER_FIELD.type = 3
descriptor.TASKLISTRESP_POWER_FIELD.cpp_type = 2

descriptor.TASKLISTRESP_GRANDTIME_FIELD.name = "GrandTime"
descriptor.TASKLISTRESP_GRANDTIME_FIELD.full_name = ".VK.Proto.TaskListResp.GrandTime"
descriptor.TASKLISTRESP_GRANDTIME_FIELD.number = 5
descriptor.TASKLISTRESP_GRANDTIME_FIELD.index = 4
descriptor.TASKLISTRESP_GRANDTIME_FIELD.label = 1
descriptor.TASKLISTRESP_GRANDTIME_FIELD.has_default_value = false
descriptor.TASKLISTRESP_GRANDTIME_FIELD.default_value = 0
descriptor.TASKLISTRESP_GRANDTIME_FIELD.type = 3
descriptor.TASKLISTRESP_GRANDTIME_FIELD.cpp_type = 2

descriptor.TASKLISTRESP_COUNTDOWN_FIELD.name = "Countdown"
descriptor.TASKLISTRESP_COUNTDOWN_FIELD.full_name = ".VK.Proto.TaskListResp.Countdown"
descriptor.TASKLISTRESP_COUNTDOWN_FIELD.number = 6
descriptor.TASKLISTRESP_COUNTDOWN_FIELD.index = 5
descriptor.TASKLISTRESP_COUNTDOWN_FIELD.label = 1
descriptor.TASKLISTRESP_COUNTDOWN_FIELD.has_default_value = false
descriptor.TASKLISTRESP_COUNTDOWN_FIELD.default_value = 0
descriptor.TASKLISTRESP_COUNTDOWN_FIELD.type = 3
descriptor.TASKLISTRESP_COUNTDOWN_FIELD.cpp_type = 2

descriptor.TASKLISTRESP_LIST_FIELD.name = "List"
descriptor.TASKLISTRESP_LIST_FIELD.full_name = ".VK.Proto.TaskListResp.List"
descriptor.TASKLISTRESP_LIST_FIELD.number = 7
descriptor.TASKLISTRESP_LIST_FIELD.index = 6
descriptor.TASKLISTRESP_LIST_FIELD.label = 3
descriptor.TASKLISTRESP_LIST_FIELD.has_default_value = false
descriptor.TASKLISTRESP_LIST_FIELD.default_value = {}
descriptor.TASKLISTRESP_LIST_FIELD.message_type = descriptor.BC_TASK
descriptor.TASKLISTRESP_LIST_FIELD.type = 11
descriptor.TASKLISTRESP_LIST_FIELD.cpp_type = 10

descriptor.TASKLISTRESP.name = "TaskListResp"
descriptor.TASKLISTRESP.full_name = ".VK.Proto.TaskListResp"
descriptor.TASKLISTRESP.nested_types = {}
descriptor.TASKLISTRESP.enum_types = {}
descriptor.TASKLISTRESP.fields = {descriptor.TASKLISTRESP_BALANCE_FIELD, descriptor.TASKLISTRESP_INCOME_FIELD, descriptor.TASKLISTRESP_WAITINCOME_FIELD, descriptor.TASKLISTRESP_POWER_FIELD, descriptor.TASKLISTRESP_GRANDTIME_FIELD, descriptor.TASKLISTRESP_COUNTDOWN_FIELD, descriptor.TASKLISTRESP_LIST_FIELD}
descriptor.TASKLISTRESP.is_extendable = false
descriptor.TASKLISTRESP.extensions = {}
descriptor.RECEIVEREQ_PLAYERID_FIELD.name = "PlayerID"
descriptor.RECEIVEREQ_PLAYERID_FIELD.full_name = ".VK.Proto.ReceiveReq.PlayerID"
descriptor.RECEIVEREQ_PLAYERID_FIELD.number = 1
descriptor.RECEIVEREQ_PLAYERID_FIELD.index = 0
descriptor.RECEIVEREQ_PLAYERID_FIELD.label = 2
descriptor.RECEIVEREQ_PLAYERID_FIELD.has_default_value = false
descriptor.RECEIVEREQ_PLAYERID_FIELD.default_value = 0
descriptor.RECEIVEREQ_PLAYERID_FIELD.type = 3
descriptor.RECEIVEREQ_PLAYERID_FIELD.cpp_type = 2

descriptor.RECEIVEREQ_TASKID_FIELD.name = "TaskID"
descriptor.RECEIVEREQ_TASKID_FIELD.full_name = ".VK.Proto.ReceiveReq.TaskID"
descriptor.RECEIVEREQ_TASKID_FIELD.number = 2
descriptor.RECEIVEREQ_TASKID_FIELD.index = 1
descriptor.RECEIVEREQ_TASKID_FIELD.label = 2
descriptor.RECEIVEREQ_TASKID_FIELD.has_default_value = false
descriptor.RECEIVEREQ_TASKID_FIELD.default_value = 0
descriptor.RECEIVEREQ_TASKID_FIELD.type = 3
descriptor.RECEIVEREQ_TASKID_FIELD.cpp_type = 2

descriptor.RECEIVEREQ.name = "ReceiveReq"
descriptor.RECEIVEREQ.full_name = ".VK.Proto.ReceiveReq"
descriptor.RECEIVEREQ.nested_types = {}
descriptor.RECEIVEREQ.enum_types = {}
descriptor.RECEIVEREQ.fields = {descriptor.RECEIVEREQ_PLAYERID_FIELD, descriptor.RECEIVEREQ_TASKID_FIELD}
descriptor.RECEIVEREQ.is_extendable = false
descriptor.RECEIVEREQ.extensions = {}
descriptor.RECEIVERESP_PROPID_FIELD.name = "PropID"
descriptor.RECEIVERESP_PROPID_FIELD.full_name = ".VK.Proto.ReceiveResp.PropID"
descriptor.RECEIVERESP_PROPID_FIELD.number = 1
descriptor.RECEIVERESP_PROPID_FIELD.index = 0
descriptor.RECEIVERESP_PROPID_FIELD.label = 1
descriptor.RECEIVERESP_PROPID_FIELD.has_default_value = false
descriptor.RECEIVERESP_PROPID_FIELD.default_value = 0
descriptor.RECEIVERESP_PROPID_FIELD.type = 3
descriptor.RECEIVERESP_PROPID_FIELD.cpp_type = 2

descriptor.RECEIVERESP_PROPNUM_FIELD.name = "PropNum"
descriptor.RECEIVERESP_PROPNUM_FIELD.full_name = ".VK.Proto.ReceiveResp.PropNum"
descriptor.RECEIVERESP_PROPNUM_FIELD.number = 2
descriptor.RECEIVERESP_PROPNUM_FIELD.index = 1
descriptor.RECEIVERESP_PROPNUM_FIELD.label = 1
descriptor.RECEIVERESP_PROPNUM_FIELD.has_default_value = false
descriptor.RECEIVERESP_PROPNUM_FIELD.default_value = 0
descriptor.RECEIVERESP_PROPNUM_FIELD.type = 3
descriptor.RECEIVERESP_PROPNUM_FIELD.cpp_type = 2

descriptor.RECEIVERESP.name = "ReceiveResp"
descriptor.RECEIVERESP.full_name = ".VK.Proto.ReceiveResp"
descriptor.RECEIVERESP.nested_types = {}
descriptor.RECEIVERESP.enum_types = {}
descriptor.RECEIVERESP.fields = {descriptor.RECEIVERESP_PROPID_FIELD, descriptor.RECEIVERESP_PROPNUM_FIELD}
descriptor.RECEIVERESP.is_extendable = false
descriptor.RECEIVERESP.extensions = {}
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.name = "PlayerID"
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.full_name = ".VK.Proto.ReceiveHCoinReq.PlayerID"
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.number = 1
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.index = 0
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.label = 2
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.has_default_value = false
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.default_value = 0
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.type = 3
descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD.cpp_type = 2

descriptor.RECEIVEHCOINREQ.name = "ReceiveHCoinReq"
descriptor.RECEIVEHCOINREQ.full_name = ".VK.Proto.ReceiveHCoinReq"
descriptor.RECEIVEHCOINREQ.nested_types = {}
descriptor.RECEIVEHCOINREQ.enum_types = {}
descriptor.RECEIVEHCOINREQ.fields = {descriptor.RECEIVEHCOINREQ_PLAYERID_FIELD}
descriptor.RECEIVEHCOINREQ.is_extendable = false
descriptor.RECEIVEHCOINREQ.extensions = {}
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.name = "InCome"
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.full_name = ".VK.Proto.ReceiveHCoinResp.InCome"
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.number = 1
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.index = 0
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.label = 1
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.has_default_value = false
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.default_value = 0
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.type = 3
descriptor.RECEIVEHCOINRESP_INCOME_FIELD.cpp_type = 2

descriptor.RECEIVEHCOINRESP.name = "ReceiveHCoinResp"
descriptor.RECEIVEHCOINRESP.full_name = ".VK.Proto.ReceiveHCoinResp"
descriptor.RECEIVEHCOINRESP.nested_types = {}
descriptor.RECEIVEHCOINRESP.enum_types = {}
descriptor.RECEIVEHCOINRESP.fields = {descriptor.RECEIVEHCOINRESP_INCOME_FIELD}
descriptor.RECEIVEHCOINRESP.is_extendable = false
descriptor.RECEIVEHCOINRESP.extensions = {}
descriptor.POWERLISTREQ_PLAYERID_FIELD.name = "PlayerID"
descriptor.POWERLISTREQ_PLAYERID_FIELD.full_name = ".VK.Proto.PowerListReq.PlayerID"
descriptor.POWERLISTREQ_PLAYERID_FIELD.number = 1
descriptor.POWERLISTREQ_PLAYERID_FIELD.index = 0
descriptor.POWERLISTREQ_PLAYERID_FIELD.label = 2
descriptor.POWERLISTREQ_PLAYERID_FIELD.has_default_value = false
descriptor.POWERLISTREQ_PLAYERID_FIELD.default_value = 0
descriptor.POWERLISTREQ_PLAYERID_FIELD.type = 3
descriptor.POWERLISTREQ_PLAYERID_FIELD.cpp_type = 2

descriptor.POWERLISTREQ.name = "PowerListReq"
descriptor.POWERLISTREQ.full_name = ".VK.Proto.PowerListReq"
descriptor.POWERLISTREQ.nested_types = {}
descriptor.POWERLISTREQ.enum_types = {}
descriptor.POWERLISTREQ.fields = {descriptor.POWERLISTREQ_PLAYERID_FIELD}
descriptor.POWERLISTREQ.is_extendable = false
descriptor.POWERLISTREQ.extensions = {}
descriptor.POWERLISTRESP_LIST_FIELD.name = "List"
descriptor.POWERLISTRESP_LIST_FIELD.full_name = ".VK.Proto.PowerListResp.List"
descriptor.POWERLISTRESP_LIST_FIELD.number = 1
descriptor.POWERLISTRESP_LIST_FIELD.index = 0
descriptor.POWERLISTRESP_LIST_FIELD.label = 3
descriptor.POWERLISTRESP_LIST_FIELD.has_default_value = false
descriptor.POWERLISTRESP_LIST_FIELD.default_value = {}
descriptor.POWERLISTRESP_LIST_FIELD.message_type = descriptor.BC_TASK
descriptor.POWERLISTRESP_LIST_FIELD.type = 11
descriptor.POWERLISTRESP_LIST_FIELD.cpp_type = 10

descriptor.POWERLISTRESP.name = "PowerListResp"
descriptor.POWERLISTRESP.full_name = ".VK.Proto.PowerListResp"
descriptor.POWERLISTRESP.nested_types = {}
descriptor.POWERLISTRESP.enum_types = {}
descriptor.POWERLISTRESP.fields = {descriptor.POWERLISTRESP_LIST_FIELD}
descriptor.POWERLISTRESP.is_extendable = false
descriptor.POWERLISTRESP.extensions = {}
descriptor.HCOINLISTREQ_PLAYERID_FIELD.name = "PlayerID"
descriptor.HCOINLISTREQ_PLAYERID_FIELD.full_name = ".VK.Proto.HCoinListReq.PlayerID"
descriptor.HCOINLISTREQ_PLAYERID_FIELD.number = 1
descriptor.HCOINLISTREQ_PLAYERID_FIELD.index = 0
descriptor.HCOINLISTREQ_PLAYERID_FIELD.label = 2
descriptor.HCOINLISTREQ_PLAYERID_FIELD.has_default_value = false
descriptor.HCOINLISTREQ_PLAYERID_FIELD.default_value = 0
descriptor.HCOINLISTREQ_PLAYERID_FIELD.type = 3
descriptor.HCOINLISTREQ_PLAYERID_FIELD.cpp_type = 2

descriptor.HCOINLISTREQ.name = "HCoinListReq"
descriptor.HCOINLISTREQ.full_name = ".VK.Proto.HCoinListReq"
descriptor.HCOINLISTREQ.nested_types = {}
descriptor.HCOINLISTREQ.enum_types = {}
descriptor.HCOINLISTREQ.fields = {descriptor.HCOINLISTREQ_PLAYERID_FIELD}
descriptor.HCOINLISTREQ.is_extendable = false
descriptor.HCOINLISTREQ.extensions = {}
descriptor.HCOINLISTRESP_LIST_FIELD.name = "List"
descriptor.HCOINLISTRESP_LIST_FIELD.full_name = ".VK.Proto.HCoinListResp.List"
descriptor.HCOINLISTRESP_LIST_FIELD.number = 1
descriptor.HCOINLISTRESP_LIST_FIELD.index = 0
descriptor.HCOINLISTRESP_LIST_FIELD.label = 3
descriptor.HCOINLISTRESP_LIST_FIELD.has_default_value = false
descriptor.HCOINLISTRESP_LIST_FIELD.default_value = {}
descriptor.HCOINLISTRESP_LIST_FIELD.message_type = descriptor.BC_HCOIN
descriptor.HCOINLISTRESP_LIST_FIELD.type = 11
descriptor.HCOINLISTRESP_LIST_FIELD.cpp_type = 10

descriptor.HCOINLISTRESP.name = "HCoinListResp"
descriptor.HCOINLISTRESP.full_name = ".VK.Proto.HCoinListResp"
descriptor.HCOINLISTRESP.nested_types = {}
descriptor.HCOINLISTRESP.enum_types = {}
descriptor.HCOINLISTRESP.fields = {descriptor.HCOINLISTRESP_LIST_FIELD}
descriptor.HCOINLISTRESP.is_extendable = false
descriptor.HCOINLISTRESP.extensions = {}
descriptor.BCSHAREREQ_PLAYERID_FIELD.name = "PlayerID"
descriptor.BCSHAREREQ_PLAYERID_FIELD.full_name = ".VK.Proto.BcShareReq.PlayerID"
descriptor.BCSHAREREQ_PLAYERID_FIELD.number = 1
descriptor.BCSHAREREQ_PLAYERID_FIELD.index = 0
descriptor.BCSHAREREQ_PLAYERID_FIELD.label = 2
descriptor.BCSHAREREQ_PLAYERID_FIELD.has_default_value = false
descriptor.BCSHAREREQ_PLAYERID_FIELD.default_value = 0
descriptor.BCSHAREREQ_PLAYERID_FIELD.type = 3
descriptor.BCSHAREREQ_PLAYERID_FIELD.cpp_type = 2

descriptor.BCSHAREREQ.name = "BcShareReq"
descriptor.BCSHAREREQ.full_name = ".VK.Proto.BcShareReq"
descriptor.BCSHAREREQ.nested_types = {}
descriptor.BCSHAREREQ.enum_types = {}
descriptor.BCSHAREREQ.fields = {descriptor.BCSHAREREQ_PLAYERID_FIELD}
descriptor.BCSHAREREQ.is_extendable = false
descriptor.BCSHAREREQ.extensions = {}
descriptor.BCSHARERESP.name = "BcShareResp"
descriptor.BCSHARERESP.full_name = ".VK.Proto.BcShareResp"
descriptor.BCSHARERESP.nested_types = {}
descriptor.BCSHARERESP.enum_types = {}
descriptor.BCSHARERESP.fields = {}
descriptor.BCSHARERESP.is_extendable = false
descriptor.BCSHARERESP.extensions = {}


pb.BC_TASK = descriptor.BC_TASK;
pb.BC_HCOIN = descriptor.BC_HCOIN;
pb.TOKENREQ = descriptor.TOKENREQ;
pb.TOKENRESP = descriptor.TOKENRESP;
pb.TASKLISTREQ = descriptor.TASKLISTREQ;
pb.TASKLISTRESP = descriptor.TASKLISTRESP;
pb.RECEIVEREQ = descriptor.RECEIVEREQ;
pb.RECEIVERESP = descriptor.RECEIVERESP;
pb.RECEIVEHCOINREQ = descriptor.RECEIVEHCOINREQ;
pb.RECEIVEHCOINRESP = descriptor.RECEIVEHCOINRESP;
pb.POWERLISTREQ = descriptor.POWERLISTREQ;
pb.POWERLISTRESP = descriptor.POWERLISTRESP;
pb.HCOINLISTREQ = descriptor.HCOINLISTREQ;
pb.HCOINLISTRESP = descriptor.HCOINLISTRESP;
pb.BCSHAREREQ = descriptor.BCSHAREREQ;
pb.BCSHARERESP = descriptor.BCSHARERESP;

pb.BcShareReq = protobuf.Message(descriptor.BCSHAREREQ)
pb.BcShareResp = protobuf.Message(descriptor.BCSHARERESP)
pb.Bc_HCoin = protobuf.Message(descriptor.BC_HCOIN)
pb.Bc_Task = protobuf.Message(descriptor.BC_TASK)
pb.HCoinListReq = protobuf.Message(descriptor.HCOINLISTREQ)
pb.HCoinListResp = protobuf.Message(descriptor.HCOINLISTRESP)
pb.PowerListReq = protobuf.Message(descriptor.POWERLISTREQ)
pb.PowerListResp = protobuf.Message(descriptor.POWERLISTRESP)
pb.ReceiveHCoinReq = protobuf.Message(descriptor.RECEIVEHCOINREQ)
pb.ReceiveHCoinResp = protobuf.Message(descriptor.RECEIVEHCOINRESP)
pb.ReceiveReq = protobuf.Message(descriptor.RECEIVEREQ)
pb.ReceiveResp = protobuf.Message(descriptor.RECEIVERESP)
pb.StatusNo = 0
pb.StatusPending = 2
pb.StatusReceive = 1
pb.TaskAgent = 7
pb.TaskBindFb = 10
pb.TaskBindOtp = 11
pb.TaskDailyCheckIn = 1
pb.TaskListReq = protobuf.Message(descriptor.TASKLISTREQ)
pb.TaskListResp = protobuf.Message(descriptor.TASKLISTRESP)
pb.TaskOnlineTime = 2
pb.TaskRealShop = 8
pb.TaskRechargeAmount = 4
pb.TaskShareFriend = 3
pb.TaskTotalLose = 6
pb.TaskTreasure = 9
pb.TaskVipUpgrade = 5
pb.TokenReq = protobuf.Message(descriptor.TOKENREQ)
pb.TokenResp = protobuf.Message(descriptor.TOKENRESP)

return pb