-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf/protobuf"
local pb = {}
local descriptor = {}

descriptor.OPS = protobuf.EnumDescriptor();
descriptor.OPS_REQ_BIRTHDAYDATA_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_RECEIVEGIFT_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UPDATEBIRTH_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_RECHARGE_INFO_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_RECHARGE_JP_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_RECHARGE_OPENBOX_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_RECHARGE_LOTTERYLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_RECHARGE_RANK_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_BC_TOKEN_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_BC_TASKLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_BC_RECEIVE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_BC_RECEIVEHCOIN_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_BC_POWERLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_BC_HCOINLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_BC_SHARE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_CLIENTRECORD_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_LIMIT_STATUS_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_LIMIT_SUBSCRIBEADD_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_LIMIT_SUBSCRIBELIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_LIMIT_INOUTGAMEPUSH_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_LIMIT_CANCELQUEUE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_LIMIT_SETWHITELIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_LIMIT_GETWHITELIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_LIMIT_GETGAMETIMELIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_QUEUE_DATA_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_QUEUE_HEARTBEAT_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_QUEUE_PUSH_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UC_RANK_DATA_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UC_OPENPRIZE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_SET_SAFE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_SAFE_DATA_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_COFFER_GUIDE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_SAFE_VERIFY_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_SAFE_RESET_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_COFFER_DATA_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_COFFER_DEPOSIT_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_COFFER_WITHDRAWAL_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_COFFER_RECEIVE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_SAFE_UN_FREEZE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_WEPAY_PAYMENT_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_ACTIVITY_RANK_DATA_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_ANALYSIS_IP_REQ_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_AUTH_IP_REQ_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_WEPAY_UNBINDPAYMENT_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_GETTASK_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_UPGRADE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_BUYUNLOCKGIRT_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_GETWINPRIZELIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_SHARETASK_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSGETTASK_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSUPGRADE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSBUYUNLOCKGIRT_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSGETWINPRIZELIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSSHARETASK_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSGETLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSRECEIVESUBTASKAWARD_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSGETLEVELAWARDLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSRECEIVELEVELAWARD_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MARSGETMTASKRANK_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MONTHDATA_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MONTHRECEIVE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_GIFTLOTTERY_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_GIFTPRIZESLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_FLOWTASKLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_FLOWTASKRECEIVE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_FLOWTASKSHARE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_PLOTTERYDATA_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_PLOTTERYTASKRECEIVE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_PLLOTTERY_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_PLOTTERYRANK_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_PLOTTERYWINPRIZE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MONOPOLYGETGAMEINFO_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MONOPOLYGETUSERINFO_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MONOPOLYLISTRANKS_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MONOPOLYPLAY_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGLIST_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGCHANGE_ENUM = protobuf.EnumValueDescriptor();
descriptor.OPS_REQ_UW_UPDATESTATUS_ENUM = protobuf.EnumValueDescriptor();

descriptor.OPS_REQ_BIRTHDAYDATA_ENUM.name = "Req_BirthdayData"
descriptor.OPS_REQ_BIRTHDAYDATA_ENUM.index = 0
descriptor.OPS_REQ_BIRTHDAYDATA_ENUM.number = 1
descriptor.OPS_REQ_RECEIVEGIFT_ENUM.name = "Req_ReceiveGift"
descriptor.OPS_REQ_RECEIVEGIFT_ENUM.index = 1
descriptor.OPS_REQ_RECEIVEGIFT_ENUM.number = 2
descriptor.OPS_REQ_UPDATEBIRTH_ENUM.name = "Req_UpdateBirth"
descriptor.OPS_REQ_UPDATEBIRTH_ENUM.index = 2
descriptor.OPS_REQ_UPDATEBIRTH_ENUM.number = 3
descriptor.OPS_REQ_RECHARGE_INFO_ENUM.name = "Req_Recharge_Info"
descriptor.OPS_REQ_RECHARGE_INFO_ENUM.index = 3
descriptor.OPS_REQ_RECHARGE_INFO_ENUM.number = 4
descriptor.OPS_REQ_RECHARGE_JP_ENUM.name = "Req_Recharge_JP"
descriptor.OPS_REQ_RECHARGE_JP_ENUM.index = 4
descriptor.OPS_REQ_RECHARGE_JP_ENUM.number = 5
descriptor.OPS_REQ_RECHARGE_OPENBOX_ENUM.name = "Req_Recharge_OpenBox"
descriptor.OPS_REQ_RECHARGE_OPENBOX_ENUM.index = 5
descriptor.OPS_REQ_RECHARGE_OPENBOX_ENUM.number = 6
descriptor.OPS_REQ_RECHARGE_LOTTERYLIST_ENUM.name = "Req_Recharge_LotteryList"
descriptor.OPS_REQ_RECHARGE_LOTTERYLIST_ENUM.index = 6
descriptor.OPS_REQ_RECHARGE_LOTTERYLIST_ENUM.number = 7
descriptor.OPS_REQ_RECHARGE_RANK_ENUM.name = "Req_Recharge_Rank"
descriptor.OPS_REQ_RECHARGE_RANK_ENUM.index = 7
descriptor.OPS_REQ_RECHARGE_RANK_ENUM.number = 8
descriptor.OPS_REQ_BC_TOKEN_ENUM.name = "Req_BC_Token"
descriptor.OPS_REQ_BC_TOKEN_ENUM.index = 8
descriptor.OPS_REQ_BC_TOKEN_ENUM.number = 9
descriptor.OPS_REQ_BC_TASKLIST_ENUM.name = "Req_BC_TaskList"
descriptor.OPS_REQ_BC_TASKLIST_ENUM.index = 9
descriptor.OPS_REQ_BC_TASKLIST_ENUM.number = 10
descriptor.OPS_REQ_BC_RECEIVE_ENUM.name = "Req_BC_Receive"
descriptor.OPS_REQ_BC_RECEIVE_ENUM.index = 10
descriptor.OPS_REQ_BC_RECEIVE_ENUM.number = 11
descriptor.OPS_REQ_BC_RECEIVEHCOIN_ENUM.name = "Req_BC_ReceiveHCoin"
descriptor.OPS_REQ_BC_RECEIVEHCOIN_ENUM.index = 11
descriptor.OPS_REQ_BC_RECEIVEHCOIN_ENUM.number = 12
descriptor.OPS_REQ_BC_POWERLIST_ENUM.name = "Req_BC_PowerList"
descriptor.OPS_REQ_BC_POWERLIST_ENUM.index = 12
descriptor.OPS_REQ_BC_POWERLIST_ENUM.number = 13
descriptor.OPS_REQ_BC_HCOINLIST_ENUM.name = "Req_BC_HCoinList"
descriptor.OPS_REQ_BC_HCOINLIST_ENUM.index = 13
descriptor.OPS_REQ_BC_HCOINLIST_ENUM.number = 14
descriptor.OPS_REQ_BC_SHARE_ENUM.name = "Req_BC_Share"
descriptor.OPS_REQ_BC_SHARE_ENUM.index = 14
descriptor.OPS_REQ_BC_SHARE_ENUM.number = 15
descriptor.OPS_REQ_CLIENTRECORD_ENUM.name = "Req_ClientRecord"
descriptor.OPS_REQ_CLIENTRECORD_ENUM.index = 15
descriptor.OPS_REQ_CLIENTRECORD_ENUM.number = 16
descriptor.OPS_REQ_LIMIT_STATUS_ENUM.name = "Req_limit_status"
descriptor.OPS_REQ_LIMIT_STATUS_ENUM.index = 16
descriptor.OPS_REQ_LIMIT_STATUS_ENUM.number = 17
descriptor.OPS_REQ_LIMIT_SUBSCRIBEADD_ENUM.name = "Req_limit_subscribeAdd"
descriptor.OPS_REQ_LIMIT_SUBSCRIBEADD_ENUM.index = 17
descriptor.OPS_REQ_LIMIT_SUBSCRIBEADD_ENUM.number = 18
descriptor.OPS_REQ_LIMIT_SUBSCRIBELIST_ENUM.name = "Req_limit_subscribeList"
descriptor.OPS_REQ_LIMIT_SUBSCRIBELIST_ENUM.index = 18
descriptor.OPS_REQ_LIMIT_SUBSCRIBELIST_ENUM.number = 19
descriptor.OPS_REQ_LIMIT_INOUTGAMEPUSH_ENUM.name = "Req_limit_inOutGamePush"
descriptor.OPS_REQ_LIMIT_INOUTGAMEPUSH_ENUM.index = 19
descriptor.OPS_REQ_LIMIT_INOUTGAMEPUSH_ENUM.number = 20
descriptor.OPS_REQ_LIMIT_CANCELQUEUE_ENUM.name = "Req_limit_cancelQueue"
descriptor.OPS_REQ_LIMIT_CANCELQUEUE_ENUM.index = 20
descriptor.OPS_REQ_LIMIT_CANCELQUEUE_ENUM.number = 21
descriptor.OPS_REQ_LIMIT_SETWHITELIST_ENUM.name = "Req_limit_setWhiteList"
descriptor.OPS_REQ_LIMIT_SETWHITELIST_ENUM.index = 21
descriptor.OPS_REQ_LIMIT_SETWHITELIST_ENUM.number = 22
descriptor.OPS_REQ_LIMIT_GETWHITELIST_ENUM.name = "Req_limit_getWhiteList"
descriptor.OPS_REQ_LIMIT_GETWHITELIST_ENUM.index = 22
descriptor.OPS_REQ_LIMIT_GETWHITELIST_ENUM.number = 23
descriptor.OPS_REQ_LIMIT_GETGAMETIMELIST_ENUM.name = "Req_limit_getGameTimeList"
descriptor.OPS_REQ_LIMIT_GETGAMETIMELIST_ENUM.index = 23
descriptor.OPS_REQ_LIMIT_GETGAMETIMELIST_ENUM.number = 24
descriptor.OPS_REQ_QUEUE_DATA_ENUM.name = "Req_Queue_Data"
descriptor.OPS_REQ_QUEUE_DATA_ENUM.index = 24
descriptor.OPS_REQ_QUEUE_DATA_ENUM.number = 25
descriptor.OPS_REQ_QUEUE_HEARTBEAT_ENUM.name = "Req_Queue_Heartbeat"
descriptor.OPS_REQ_QUEUE_HEARTBEAT_ENUM.index = 25
descriptor.OPS_REQ_QUEUE_HEARTBEAT_ENUM.number = 26
descriptor.OPS_REQ_QUEUE_PUSH_ENUM.name = "Req_Queue_Push"
descriptor.OPS_REQ_QUEUE_PUSH_ENUM.index = 26
descriptor.OPS_REQ_QUEUE_PUSH_ENUM.number = 27
descriptor.OPS_REQ_UC_RANK_DATA_ENUM.name = "Req_Uc_Rank_Data"
descriptor.OPS_REQ_UC_RANK_DATA_ENUM.index = 27
descriptor.OPS_REQ_UC_RANK_DATA_ENUM.number = 28
descriptor.OPS_REQ_UC_OPENPRIZE_ENUM.name = "Req_Uc_OpenPrize"
descriptor.OPS_REQ_UC_OPENPRIZE_ENUM.index = 28
descriptor.OPS_REQ_UC_OPENPRIZE_ENUM.number = 29
descriptor.OPS_REQ_SET_SAFE_ENUM.name = "Req_Set_Safe"
descriptor.OPS_REQ_SET_SAFE_ENUM.index = 29
descriptor.OPS_REQ_SET_SAFE_ENUM.number = 30
descriptor.OPS_REQ_SAFE_DATA_ENUM.name = "Req_Safe_Data"
descriptor.OPS_REQ_SAFE_DATA_ENUM.index = 30
descriptor.OPS_REQ_SAFE_DATA_ENUM.number = 31
descriptor.OPS_REQ_COFFER_GUIDE_ENUM.name = "Req_Coffer_Guide"
descriptor.OPS_REQ_COFFER_GUIDE_ENUM.index = 31
descriptor.OPS_REQ_COFFER_GUIDE_ENUM.number = 32
descriptor.OPS_REQ_SAFE_VERIFY_ENUM.name = "Req_Safe_Verify"
descriptor.OPS_REQ_SAFE_VERIFY_ENUM.index = 32
descriptor.OPS_REQ_SAFE_VERIFY_ENUM.number = 33
descriptor.OPS_REQ_SAFE_RESET_ENUM.name = "Req_Safe_Reset"
descriptor.OPS_REQ_SAFE_RESET_ENUM.index = 33
descriptor.OPS_REQ_SAFE_RESET_ENUM.number = 34
descriptor.OPS_REQ_COFFER_DATA_ENUM.name = "Req_Coffer_Data"
descriptor.OPS_REQ_COFFER_DATA_ENUM.index = 34
descriptor.OPS_REQ_COFFER_DATA_ENUM.number = 35
descriptor.OPS_REQ_COFFER_DEPOSIT_ENUM.name = "Req_Coffer_Deposit"
descriptor.OPS_REQ_COFFER_DEPOSIT_ENUM.index = 35
descriptor.OPS_REQ_COFFER_DEPOSIT_ENUM.number = 36
descriptor.OPS_REQ_COFFER_WITHDRAWAL_ENUM.name = "Req_Coffer_Withdrawal"
descriptor.OPS_REQ_COFFER_WITHDRAWAL_ENUM.index = 36
descriptor.OPS_REQ_COFFER_WITHDRAWAL_ENUM.number = 37
descriptor.OPS_REQ_COFFER_RECEIVE_ENUM.name = "Req_Coffer_Receive"
descriptor.OPS_REQ_COFFER_RECEIVE_ENUM.index = 37
descriptor.OPS_REQ_COFFER_RECEIVE_ENUM.number = 38
descriptor.OPS_REQ_SAFE_UN_FREEZE_ENUM.name = "Req_Safe_Un_Freeze"
descriptor.OPS_REQ_SAFE_UN_FREEZE_ENUM.index = 38
descriptor.OPS_REQ_SAFE_UN_FREEZE_ENUM.number = 39
descriptor.OPS_REQ_WEPAY_PAYMENT_ENUM.name = "Req_WePay_Payment"
descriptor.OPS_REQ_WEPAY_PAYMENT_ENUM.index = 39
descriptor.OPS_REQ_WEPAY_PAYMENT_ENUM.number = 40
descriptor.OPS_REQ_ACTIVITY_RANK_DATA_ENUM.name = "Req_Activity_Rank_Data"
descriptor.OPS_REQ_ACTIVITY_RANK_DATA_ENUM.index = 40
descriptor.OPS_REQ_ACTIVITY_RANK_DATA_ENUM.number = 41
descriptor.OPS_REQ_ANALYSIS_IP_REQ_ENUM.name = "Req_Analysis_IP_Req"
descriptor.OPS_REQ_ANALYSIS_IP_REQ_ENUM.index = 41
descriptor.OPS_REQ_ANALYSIS_IP_REQ_ENUM.number = 42
descriptor.OPS_REQ_AUTH_IP_REQ_ENUM.name = "Req_Auth_Ip_req"
descriptor.OPS_REQ_AUTH_IP_REQ_ENUM.index = 42
descriptor.OPS_REQ_AUTH_IP_REQ_ENUM.number = 43
descriptor.OPS_REQ_WEPAY_UNBINDPAYMENT_ENUM.name = "Req_WePay_UnBindPayment"
descriptor.OPS_REQ_WEPAY_UNBINDPAYMENT_ENUM.index = 43
descriptor.OPS_REQ_WEPAY_UNBINDPAYMENT_ENUM.number = 44
descriptor.OPS_REQ_UW_GETTASK_ENUM.name = "Req_UW_GetTask"
descriptor.OPS_REQ_UW_GETTASK_ENUM.index = 44
descriptor.OPS_REQ_UW_GETTASK_ENUM.number = 45
descriptor.OPS_REQ_UW_UPGRADE_ENUM.name = "Req_UW_Upgrade"
descriptor.OPS_REQ_UW_UPGRADE_ENUM.index = 45
descriptor.OPS_REQ_UW_UPGRADE_ENUM.number = 46
descriptor.OPS_REQ_UW_BUYUNLOCKGIRT_ENUM.name = "Req_UW_BuyUnLockGirt"
descriptor.OPS_REQ_UW_BUYUNLOCKGIRT_ENUM.index = 46
descriptor.OPS_REQ_UW_BUYUNLOCKGIRT_ENUM.number = 47
descriptor.OPS_REQ_UW_GETWINPRIZELIST_ENUM.name = "Req_UW_GetWinPrizeList"
descriptor.OPS_REQ_UW_GETWINPRIZELIST_ENUM.index = 47
descriptor.OPS_REQ_UW_GETWINPRIZELIST_ENUM.number = 48
descriptor.OPS_REQ_UW_SHARETASK_ENUM.name = "Req_UW_ShareTask"
descriptor.OPS_REQ_UW_SHARETASK_ENUM.index = 48
descriptor.OPS_REQ_UW_SHARETASK_ENUM.number = 49
descriptor.OPS_REQ_UW_MARSGETTASK_ENUM.name = "Req_UW_MarsGetTask"
descriptor.OPS_REQ_UW_MARSGETTASK_ENUM.index = 49
descriptor.OPS_REQ_UW_MARSGETTASK_ENUM.number = 50
descriptor.OPS_REQ_UW_MARSUPGRADE_ENUM.name = "Req_UW_MarsUpgrade"
descriptor.OPS_REQ_UW_MARSUPGRADE_ENUM.index = 50
descriptor.OPS_REQ_UW_MARSUPGRADE_ENUM.number = 51
descriptor.OPS_REQ_UW_MARSBUYUNLOCKGIRT_ENUM.name = "Req_UW_MarsBuyUnLockGirt"
descriptor.OPS_REQ_UW_MARSBUYUNLOCKGIRT_ENUM.index = 51
descriptor.OPS_REQ_UW_MARSBUYUNLOCKGIRT_ENUM.number = 52
descriptor.OPS_REQ_UW_MARSGETWINPRIZELIST_ENUM.name = "Req_UW_MarsGetWinPrizeList"
descriptor.OPS_REQ_UW_MARSGETWINPRIZELIST_ENUM.index = 52
descriptor.OPS_REQ_UW_MARSGETWINPRIZELIST_ENUM.number = 53
descriptor.OPS_REQ_UW_MARSSHARETASK_ENUM.name = "Req_UW_MarsShareTask"
descriptor.OPS_REQ_UW_MARSSHARETASK_ENUM.index = 53
descriptor.OPS_REQ_UW_MARSSHARETASK_ENUM.number = 54
descriptor.OPS_REQ_UW_MARSGETLIST_ENUM.name = "Req_UW_MarsGetList"
descriptor.OPS_REQ_UW_MARSGETLIST_ENUM.index = 54
descriptor.OPS_REQ_UW_MARSGETLIST_ENUM.number = 55
descriptor.OPS_REQ_UW_MARSRECEIVESUBTASKAWARD_ENUM.name = "Req_UW_MarsReceiveSubTaskAward"
descriptor.OPS_REQ_UW_MARSRECEIVESUBTASKAWARD_ENUM.index = 55
descriptor.OPS_REQ_UW_MARSRECEIVESUBTASKAWARD_ENUM.number = 56
descriptor.OPS_REQ_UW_MARSGETLEVELAWARDLIST_ENUM.name = "Req_UW_MarsGetLevelAwardList"
descriptor.OPS_REQ_UW_MARSGETLEVELAWARDLIST_ENUM.index = 56
descriptor.OPS_REQ_UW_MARSGETLEVELAWARDLIST_ENUM.number = 57
descriptor.OPS_REQ_UW_MARSRECEIVELEVELAWARD_ENUM.name = "Req_UW_MarsReceiveLevelAward"
descriptor.OPS_REQ_UW_MARSRECEIVELEVELAWARD_ENUM.index = 57
descriptor.OPS_REQ_UW_MARSRECEIVELEVELAWARD_ENUM.number = 58
descriptor.OPS_REQ_UW_MARSGETMTASKRANK_ENUM.name = "Req_UW_MarsGetMTaskRank"
descriptor.OPS_REQ_UW_MARSGETMTASKRANK_ENUM.index = 58
descriptor.OPS_REQ_UW_MARSGETMTASKRANK_ENUM.number = 59
descriptor.OPS_REQ_UW_MONTHDATA_ENUM.name = "Req_UW_MonthData"
descriptor.OPS_REQ_UW_MONTHDATA_ENUM.index = 59
descriptor.OPS_REQ_UW_MONTHDATA_ENUM.number = 60
descriptor.OPS_REQ_UW_MONTHRECEIVE_ENUM.name = "Req_UW_MonthReceive"
descriptor.OPS_REQ_UW_MONTHRECEIVE_ENUM.index = 60
descriptor.OPS_REQ_UW_MONTHRECEIVE_ENUM.number = 61
descriptor.OPS_REQ_GIFTLOTTERY_ENUM.name = "Req_GiftLottery"
descriptor.OPS_REQ_GIFTLOTTERY_ENUM.index = 61
descriptor.OPS_REQ_GIFTLOTTERY_ENUM.number = 62
descriptor.OPS_REQ_GIFTPRIZESLIST_ENUM.name = "Req_GiftPrizesList"
descriptor.OPS_REQ_GIFTPRIZESLIST_ENUM.index = 62
descriptor.OPS_REQ_GIFTPRIZESLIST_ENUM.number = 63
descriptor.OPS_REQ_UW_FLOWTASKLIST_ENUM.name = "Req_UW_FlowTaskList"
descriptor.OPS_REQ_UW_FLOWTASKLIST_ENUM.index = 63
descriptor.OPS_REQ_UW_FLOWTASKLIST_ENUM.number = 64
descriptor.OPS_REQ_UW_FLOWTASKRECEIVE_ENUM.name = "Req_UW_FlowTaskReceive"
descriptor.OPS_REQ_UW_FLOWTASKRECEIVE_ENUM.index = 64
descriptor.OPS_REQ_UW_FLOWTASKRECEIVE_ENUM.number = 65
descriptor.OPS_REQ_UW_FLOWTASKSHARE_ENUM.name = "Req_UW_FlowTaskShare"
descriptor.OPS_REQ_UW_FLOWTASKSHARE_ENUM.index = 65
descriptor.OPS_REQ_UW_FLOWTASKSHARE_ENUM.number = 66
descriptor.OPS_REQ_UW_PLOTTERYDATA_ENUM.name = "Req_UW_PLotteryData"
descriptor.OPS_REQ_UW_PLOTTERYDATA_ENUM.index = 66
descriptor.OPS_REQ_UW_PLOTTERYDATA_ENUM.number = 67
descriptor.OPS_REQ_UW_PLOTTERYTASKRECEIVE_ENUM.name = "Req_UW_PLotteryTaskReceive"
descriptor.OPS_REQ_UW_PLOTTERYTASKRECEIVE_ENUM.index = 67
descriptor.OPS_REQ_UW_PLOTTERYTASKRECEIVE_ENUM.number = 68
descriptor.OPS_REQ_UW_PLLOTTERY_ENUM.name = "Req_UW_PLLottery"
descriptor.OPS_REQ_UW_PLLOTTERY_ENUM.index = 68
descriptor.OPS_REQ_UW_PLLOTTERY_ENUM.number = 69
descriptor.OPS_REQ_UW_PLOTTERYRANK_ENUM.name = "Req_UW_PLotteryRank"
descriptor.OPS_REQ_UW_PLOTTERYRANK_ENUM.index = 69
descriptor.OPS_REQ_UW_PLOTTERYRANK_ENUM.number = 70
descriptor.OPS_REQ_UW_PLOTTERYWINPRIZE_ENUM.name = "Req_UW_PLotteryWinPrize"
descriptor.OPS_REQ_UW_PLOTTERYWINPRIZE_ENUM.index = 70
descriptor.OPS_REQ_UW_PLOTTERYWINPRIZE_ENUM.number = 71
descriptor.OPS_REQ_UW_MONOPOLYGETGAMEINFO_ENUM.name = "Req_UW_MonopolyGetGameInfo"
descriptor.OPS_REQ_UW_MONOPOLYGETGAMEINFO_ENUM.index = 71
descriptor.OPS_REQ_UW_MONOPOLYGETGAMEINFO_ENUM.number = 72
descriptor.OPS_REQ_UW_MONOPOLYGETUSERINFO_ENUM.name = "Req_UW_MonopolyGetUserInfo"
descriptor.OPS_REQ_UW_MONOPOLYGETUSERINFO_ENUM.index = 72
descriptor.OPS_REQ_UW_MONOPOLYGETUSERINFO_ENUM.number = 73
descriptor.OPS_REQ_UW_MONOPOLYLISTRANKS_ENUM.name = "Req_UW_MonopolyListRanks"
descriptor.OPS_REQ_UW_MONOPOLYLISTRANKS_ENUM.index = 73
descriptor.OPS_REQ_UW_MONOPOLYLISTRANKS_ENUM.number = 74
descriptor.OPS_REQ_UW_MONOPOLYPLAY_ENUM.name = "Req_UW_MonopolyPlay"
descriptor.OPS_REQ_UW_MONOPOLYPLAY_ENUM.index = 74
descriptor.OPS_REQ_UW_MONOPOLYPLAY_ENUM.number = 75
descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGLIST_ENUM.name = "Req_UW_MonopolyGiftBagList"
descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGLIST_ENUM.index = 75
descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGLIST_ENUM.number = 76
descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGCHANGE_ENUM.name = "Req_UW_MonopolyGiftBagChange"
descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGCHANGE_ENUM.index = 76
descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGCHANGE_ENUM.number = 77
descriptor.OPS_REQ_UW_UPDATESTATUS_ENUM.name = "Req_UW_UpdateStatus"
descriptor.OPS_REQ_UW_UPDATESTATUS_ENUM.index = 77
descriptor.OPS_REQ_UW_UPDATESTATUS_ENUM.number = 78
descriptor.OPS.name = "Ops"
descriptor.OPS.full_name = ".VK.Proto.Ops"
descriptor.OPS.values = {descriptor.OPS_REQ_BIRTHDAYDATA_ENUM,descriptor.OPS_REQ_RECEIVEGIFT_ENUM,descriptor.OPS_REQ_UPDATEBIRTH_ENUM,descriptor.OPS_REQ_RECHARGE_INFO_ENUM,descriptor.OPS_REQ_RECHARGE_JP_ENUM,descriptor.OPS_REQ_RECHARGE_OPENBOX_ENUM,descriptor.OPS_REQ_RECHARGE_LOTTERYLIST_ENUM,descriptor.OPS_REQ_RECHARGE_RANK_ENUM,descriptor.OPS_REQ_BC_TOKEN_ENUM,descriptor.OPS_REQ_BC_TASKLIST_ENUM,descriptor.OPS_REQ_BC_RECEIVE_ENUM,descriptor.OPS_REQ_BC_RECEIVEHCOIN_ENUM,descriptor.OPS_REQ_BC_POWERLIST_ENUM,descriptor.OPS_REQ_BC_HCOINLIST_ENUM,descriptor.OPS_REQ_BC_SHARE_ENUM,descriptor.OPS_REQ_CLIENTRECORD_ENUM,descriptor.OPS_REQ_LIMIT_STATUS_ENUM,descriptor.OPS_REQ_LIMIT_SUBSCRIBEADD_ENUM,descriptor.OPS_REQ_LIMIT_SUBSCRIBELIST_ENUM,descriptor.OPS_REQ_LIMIT_INOUTGAMEPUSH_ENUM,descriptor.OPS_REQ_LIMIT_CANCELQUEUE_ENUM,descriptor.OPS_REQ_LIMIT_SETWHITELIST_ENUM,descriptor.OPS_REQ_LIMIT_GETWHITELIST_ENUM,descriptor.OPS_REQ_LIMIT_GETGAMETIMELIST_ENUM,descriptor.OPS_REQ_QUEUE_DATA_ENUM,descriptor.OPS_REQ_QUEUE_HEARTBEAT_ENUM,descriptor.OPS_REQ_QUEUE_PUSH_ENUM,descriptor.OPS_REQ_UC_RANK_DATA_ENUM,descriptor.OPS_REQ_UC_OPENPRIZE_ENUM,descriptor.OPS_REQ_SET_SAFE_ENUM,descriptor.OPS_REQ_SAFE_DATA_ENUM,descriptor.OPS_REQ_COFFER_GUIDE_ENUM,descriptor.OPS_REQ_SAFE_VERIFY_ENUM,descriptor.OPS_REQ_SAFE_RESET_ENUM,descriptor.OPS_REQ_COFFER_DATA_ENUM,descriptor.OPS_REQ_COFFER_DEPOSIT_ENUM,descriptor.OPS_REQ_COFFER_WITHDRAWAL_ENUM,descriptor.OPS_REQ_COFFER_RECEIVE_ENUM,descriptor.OPS_REQ_SAFE_UN_FREEZE_ENUM,descriptor.OPS_REQ_WEPAY_PAYMENT_ENUM,descriptor.OPS_REQ_ACTIVITY_RANK_DATA_ENUM,descriptor.OPS_REQ_ANALYSIS_IP_REQ_ENUM,descriptor.OPS_REQ_AUTH_IP_REQ_ENUM,descriptor.OPS_REQ_WEPAY_UNBINDPAYMENT_ENUM,descriptor.OPS_REQ_UW_GETTASK_ENUM,descriptor.OPS_REQ_UW_UPGRADE_ENUM,descriptor.OPS_REQ_UW_BUYUNLOCKGIRT_ENUM,descriptor.OPS_REQ_UW_GETWINPRIZELIST_ENUM,descriptor.OPS_REQ_UW_SHARETASK_ENUM,descriptor.OPS_REQ_UW_MARSGETTASK_ENUM,descriptor.OPS_REQ_UW_MARSUPGRADE_ENUM,descriptor.OPS_REQ_UW_MARSBUYUNLOCKGIRT_ENUM,descriptor.OPS_REQ_UW_MARSGETWINPRIZELIST_ENUM,descriptor.OPS_REQ_UW_MARSSHARETASK_ENUM,descriptor.OPS_REQ_UW_MARSGETLIST_ENUM,descriptor.OPS_REQ_UW_MARSRECEIVESUBTASKAWARD_ENUM,descriptor.OPS_REQ_UW_MARSGETLEVELAWARDLIST_ENUM,descriptor.OPS_REQ_UW_MARSRECEIVELEVELAWARD_ENUM,descriptor.OPS_REQ_UW_MARSGETMTASKRANK_ENUM,descriptor.OPS_REQ_UW_MONTHDATA_ENUM,descriptor.OPS_REQ_UW_MONTHRECEIVE_ENUM,descriptor.OPS_REQ_GIFTLOTTERY_ENUM,descriptor.OPS_REQ_GIFTPRIZESLIST_ENUM,descriptor.OPS_REQ_UW_FLOWTASKLIST_ENUM,descriptor.OPS_REQ_UW_FLOWTASKRECEIVE_ENUM,descriptor.OPS_REQ_UW_FLOWTASKSHARE_ENUM,descriptor.OPS_REQ_UW_PLOTTERYDATA_ENUM,descriptor.OPS_REQ_UW_PLOTTERYTASKRECEIVE_ENUM,descriptor.OPS_REQ_UW_PLLOTTERY_ENUM,descriptor.OPS_REQ_UW_PLOTTERYRANK_ENUM,descriptor.OPS_REQ_UW_PLOTTERYWINPRIZE_ENUM,descriptor.OPS_REQ_UW_MONOPOLYGETGAMEINFO_ENUM,descriptor.OPS_REQ_UW_MONOPOLYGETUSERINFO_ENUM,descriptor.OPS_REQ_UW_MONOPOLYLISTRANKS_ENUM,descriptor.OPS_REQ_UW_MONOPOLYPLAY_ENUM,descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGLIST_ENUM,descriptor.OPS_REQ_UW_MONOPOLYGIFTBAGCHANGE_ENUM,descriptor.OPS_REQ_UW_UPDATESTATUS_ENUM}



pb.Req_Activity_Rank_Data = 41
pb.Req_Analysis_IP_Req = 42
pb.Req_Auth_Ip_req = 43
pb.Req_BC_HCoinList = 14
pb.Req_BC_PowerList = 13
pb.Req_BC_Receive = 11
pb.Req_BC_ReceiveHCoin = 12
pb.Req_BC_Share = 15
pb.Req_BC_TaskList = 10
pb.Req_BC_Token = 9
pb.Req_BirthdayData = 1
pb.Req_ClientRecord = 16
pb.Req_Coffer_Data = 35
pb.Req_Coffer_Deposit = 36
pb.Req_Coffer_Guide = 32
pb.Req_Coffer_Receive = 38
pb.Req_Coffer_Withdrawal = 37
pb.Req_GiftLottery = 62
pb.Req_GiftPrizesList = 63
pb.Req_Queue_Data = 25
pb.Req_Queue_Heartbeat = 26
pb.Req_Queue_Push = 27
pb.Req_ReceiveGift = 2
pb.Req_Recharge_Info = 4
pb.Req_Recharge_JP = 5
pb.Req_Recharge_LotteryList = 7
pb.Req_Recharge_OpenBox = 6
pb.Req_Recharge_Rank = 8
pb.Req_Safe_Data = 31
pb.Req_Safe_Reset = 34
pb.Req_Safe_Un_Freeze = 39
pb.Req_Safe_Verify = 33
pb.Req_Set_Safe = 30
pb.Req_UW_BuyUnLockGirt = 47
pb.Req_UW_FlowTaskList = 64
pb.Req_UW_FlowTaskReceive = 65
pb.Req_UW_FlowTaskShare = 66
pb.Req_UW_GetTask = 45
pb.Req_UW_GetWinPrizeList = 48
pb.Req_UW_MarsBuyUnLockGirt = 52
pb.Req_UW_MarsGetLevelAwardList = 57
pb.Req_UW_MarsGetList = 55
pb.Req_UW_MarsGetMTaskRank = 59
pb.Req_UW_MarsGetTask = 50
pb.Req_UW_MarsGetWinPrizeList = 53
pb.Req_UW_MarsReceiveLevelAward = 58
pb.Req_UW_MarsReceiveSubTaskAward = 56
pb.Req_UW_MarsShareTask = 54
pb.Req_UW_MarsUpgrade = 51
pb.Req_UW_MonopolyGetGameInfo = 72
pb.Req_UW_MonopolyGetUserInfo = 73
pb.Req_UW_MonopolyGiftBagChange = 77
pb.Req_UW_MonopolyGiftBagList = 76
pb.Req_UW_MonopolyListRanks = 74
pb.Req_UW_MonopolyPlay = 75
pb.Req_UW_MonthData = 60
pb.Req_UW_MonthReceive = 61
pb.Req_UW_PLLottery = 69
pb.Req_UW_PLotteryData = 67
pb.Req_UW_PLotteryRank = 70
pb.Req_UW_PLotteryTaskReceive = 68
pb.Req_UW_PLotteryWinPrize = 71
pb.Req_UW_ShareTask = 49
pb.Req_UW_UpdateStatus = 78
pb.Req_UW_Upgrade = 46
pb.Req_Uc_OpenPrize = 29
pb.Req_Uc_Rank_Data = 28
pb.Req_UpdateBirth = 3
pb.Req_WePay_Payment = 40
pb.Req_WePay_UnBindPayment = 44
pb.Req_limit_cancelQueue = 21
pb.Req_limit_getGameTimeList = 24
pb.Req_limit_getWhiteList = 23
pb.Req_limit_inOutGamePush = 20
pb.Req_limit_setWhiteList = 22
pb.Req_limit_status = 17
pb.Req_limit_subscribeAdd = 18
pb.Req_limit_subscribeList = 19

return pb