local lan =
{
	errorText0 = "成功(0)",
	errorText1 = "异常的捕捉(1)",
	errorText2 = "写入中(2)",
	errorText3 = "读取中(3)",
	errorText4 = "请求数据为空(4)",
	errorText5 = "串口冲突(5)",
	errorText6 = "无响应(6)",
	errorText7 = "读取错误(7)",
	errorText8 = "游戏场已关闭(8)",
	errorText9= "推送数据为空(9)",
	-- errorText10 = "终止(10)",
	errorText100 = "协议解析失败(100)",
	errorText101 = "无效的操作(101)",
	errorText102 = "节点已注册(102)",
	errorText103 = "节点不存在(103)",
	errorText104 = "无效的节点ID(104)",
	errorText105 = "无效的节点类型(105)",
	errorText106 = "玩家不存在(106)",
	errorText107 = "玩家ID不能为空(107)",
	errorText108 = "操作线路未配置(108)",
	errorText109 = "道具不足(109)",
	errorText110 = "序列化失败(110)",
	errorText111 = "未定义的操作(111)",
	errorText112 = "获取用户缓存信息失败(112)",
	errorText113 = "创建用户失败(113)",
	errorText114 = "不是管理员(114)",
	errorText115 = "道具未配置(115)",
	errorText116 = "未指定的服务器ID(116)",
	errorText117 = "组件未启动(117)",
	errorText118 = "连接未建立(118)",
	errorText119 = "写入文件失败(119)",
	errorText120 = "加载玩家信息失败(120)",
	errorText121 = "无效的授权(121)",
	errorText122 = "玩家已登录(122)",
	errorText123 = "准备玩家数据失败(123)",
	errorText124 = "用户名或密码错误(124)",
	errorText125 = "用户已存在(125)",
	errorText127 = "Facebook登录失败(127)",
	errorText128 = "已绑定Facebook(128)",
	errorText129 = "邮件不存在(129)",
	errorText130 = "邮件已失效(130)",
	errorText131 = "无效的邮件范围(131)",
	errorText132 = "没有附件的邮件(132)",
	errorText133 = "邮件列表为空(133)",
	errorText134 = "无效的道具类型(134)",
	errorText135 = "道具不存在(135)",
	errorText136 = "影响配置不存在(136)",
	errorText137 = "无效的影响参数(137)",
	errorText138 = "影响参数为空(138)",
	errorText139 = "道具不能使用(139)",
	errorText140 = "无效道具数量(140)",
	errorText141 = "未签到(141)",
	errorText143 = "签到配置未找到(143)",
	errorText144 = "添加的好友不存在(144)",
	errorText145 = "删除的好友不存在(145)",
	errorText146 = "添加好友失败(146)",
	errorText147 = "删除好友失败(147)",
	errorText148 = "已经是好友(148)",
	errorText149 = "不能添加自己(149)",
	errorText150 = "好友已经在黑名单(150)",
	errorText151 = "未配置的聊天类型(151)",
	errorText152 = "聊天CD(152)",
	errorText153 = "聊天类型错误(153)",
	errorText154 = "H5支付异常(154)",
	errorText155 = "IOS支付验证失败(155)",
	errorText156 = "IOS支付验证结果无效(156)",
	errorText157 = "订单ID和玩家ID不匹配(157)",
	errorText158 = "订单已处理(158)",
	errorText159 = "订单失败(159)",
	errorText160 = "订单不存在(160)",
	errorText161 = "商品未配置(161)",
	errorText162 = "商品已关闭(162)",
	errorText163 = "无效的支付方式(163)",
	errorText164 = "购买次数已达上限(164)",
	errorText165 = "VIP权益配置未找到(165)",
	errorText166 = "无效的范围(166)",
	errorText167 = "未找到其它玩家(167)",
	errorText168 = "触发影响失败(168)",
	errorText169 = "奖励为空(169)",
	errorText170 = "用户划分失败(170)",
	errorText171 = "排行榜为空(171)",
	errorText172 = "台桌分配失败(172)",
	errorText173 = "台桌不存在(173)",
	errorText174 = "台桌为空(174)",
	errorText175 = "私人台桌不匹配(175)",
	errorText176 = "礼物配置未找到(176)",
	errorText177 = "活动未配置(177)",
	errorText178 = "游戏已经注册(178)",
	errorText179 = "游戏为空(179)",
	errorText180 = "游戏服务器已关闭(180)",
	errorText181 = "游戏服务已关闭(181)",
	errorText182 = "无效的签名(182)",
	errorText183 = "消息过长(183)",
	errorText184 = "消息接收者错误(184)",
	errorText185 = "商品价格不匹配(185)",
	errorText186 = "救济金领取次数已达上限(186)",
	errorText187 = "获取救济金失败(187)",
	errorText188 = "重复领取首充奖励(188)",
	errorText189 = "获取救济金配置失败(189)",
	errorText190 = "体验券不足(190)",
	errorText191 = "道具加载失败(191)",
	errorText192 = "MOL点卡支付失败(192)",
	errorText193 = "MOL短信支付失败(193)",
	errorText194 = "MOL电子钱包支付失败(194)",
	errorText195 = "无效的MOL短信消息(195)",
	errorText196 = "玩家已被封号(196)",
	errorText197 = "成为VIP，绑定Facebook，绑定手机号可以开启赠送功能(197)",
	errorText198 = "GooglePlay支付玩家不匹配(198)",
	errorText199 = "GooglePlay支付签名不匹配(199)",
	errorText200 = "GooglePlay支付商品ID不匹配(200)",
	errorText201 = "无效的GooglePlay支付数据(201)",
	errorText202 = "MOL支付商品配置未找到(202)",
	errorText203 = "支付订单不匹配(203)",
	errorText204 = "不能发送给自己(204)",
	errorText205 = "帐号中不存在序列号(205)",
	errorText206 = "赠送上限(206)",
	errorText207 = "没有VIP维持信息(207)",
	errorText208 = "不是VIP玩家(208)",
	errorText209 = "VIP维持未配置(209)",
	errorText211 = "获取GTI账户失败(211)",
	errorText212 = "创建GTI账户失败(212)",
	errorText213 = "GTI上分失败(213)",
	errorText214 = "GTI下分失败(214)",
	errorText215 = "获取GTI Token失败(215)",
	errorText216 = "获取GTI平衡失败(216)",
	errorText217 = "绑定失败，该电话号码已被绑定，请用其他的电话号码(217)",
	errorText218 = "发送短信失败(218)",
	errorText219 = "头衔未配置(219)",
	errorText220 = "未找到头衔(220)",
	errorText221 = "头衔已存在(221)",
	errorText222 = "无效的头衔数据(222)",
	errorText223 = "无效的头衔方法(223)",
	errorText224 = "无效的头衔条件(224)",
	errorText225 = "请求ID不匹配(225)",
	errorText226 = "请求超时(226)",
	-- errorText227 = "关键字不存在(227)",
	errorText228 = "价格为空(228)",
	errorText229 = "该电话号码被绑定过多(229)",
	-- errorText230 = "信用额度不足(230)",
	errorText231 = "手机号不存在(231)",
	errorText232 = "需要绑定Facebook或Line(232)",
	errorText233 = "需要绑定手机号(233)",
	errorText234 = "需要成为VIP(234)",
	errorText235 = "无效的短信Token(235)",
	errorText236 = "救济金领取次数已达上限(236)",
	errorText237 = "未满足救济金领取(237)",
	errorText238 = "请前往大厅操作(238)",
	errorText239 = "赠送最低限额(239)",
	errorText240 = "赠送最高限额(240)",
	errorText241 = "已经在其它游戏中了(241)",
	errorText242 = "OTP过期，请重新操作(242)",
	errorText243 = "已绑定游客(243)",
	errorText244 = "输入OTP不正确， 请重新操作(244)",
	errorText245 = "需要重新进入(245)",
	errorText246 = "用户ID库已满(246)",
	errorText247 = "无效的IP(247)",
	errorText248 = "未在Google文件中找到包(248)",
	errorText249 = "web邮件请求失败(249)",
	errorText250 = "需重新校验短信验证码(250)",
	errorText251 = "web修改玩家道具失败。(251)",
	errorText252 = "在线奖励为空(252)",
	errorText253 = "在线奖励标记(253)",
	errorText254 = "未找到在线奖励文件(254)",
	errorText255 = "奖励无效(255)",
	errorText256 = "已经购买了该商品(256)",
	errorText257 = "奖励不能跨天领取(257)",
	errorText258 = "未到奖励领取时间(258)",
	errorText260 = "奖励为空(260)",
	errorText261 = "奖励已经领取(261)",
	errorText262 = "不在奖励时间内(262)",
	errorText263 = "奖励配置未找到(263)",
	errorText264 = "玩家VIP等级未达到(264)",
	errorText269 = "活动没有开启(269)",
	errorText270 = "奖励配置找不到(270)",
	errorText271 = "兑换福袋活动币不足(271)",
	errorText272 = "登录活动币奖励已领取(272)",
	errorText273 = "vip等级不够(273)",
	errorText274 = "没有充值(274)",
	errorText275 = "充值可领取活动币不足(275)",
	errorText287 = "Line身份验证失败(287)",
	errorText288 = "Line已绑定(288)",
	errorText289 = "获取Line信息失败(289)",
	errorText290 = "无效的LineID(290)",
	errorText300 = "配置参数错误(300)",
	errorText303 = "已经在好友申请列表中(303)",
	errorText306 = "当前功能已被封禁，暂时无法使用(306)",
	errorText307 = "注册ip创建已达上限(307)",
	errorText308 = "注册imei被限制(308)",
	errorText309 = "注册失败(309)",
	errorText317 = "IOS商品重复消耗(317)",
	errorText318 = "操作太频繁(318)",
	errorText319 = "订单冷却中(319)",
	errorText320 = "商品冷却中(320)",
	errorText314 = "补签次数不足(314)",
	errorText315 = "筹码不足(315)",
	errorText316 = "已经签到(316)",
	errorText321 = "不能开启宝箱(321)",
	errorText322 = "库存不足(322)",
	-- errorText323 = "活动关闭(323)",
	errorText324 = "转盘次数不足(324)",
	errorText325 = "账号被禁言(325)",
	errorText326 = "转盘类型不对(326)",
	errorText327 = "免费转盘没有使用完(327)",
	-- errorText328 = "(328)",
	-- errorText329 = "(329)",
	errorText330 = "设备号不能为空(330)",
	errorText331 = "用户名不能为空(331)",
	errorText332 = "密码不能为空(332)",
	errorText333 = "非法的操作系统(333)",

	errorText340 = "许愿失败(340)",
	errorText341 = "许愿次数错误(341)",--"许愿次数错误(341)",
	errorText342 = "许愿排行获取失败(342)",
	errorText343 = "您许愿的次数，超过本期最大购买的次数(343)",
	errorText344 = "正在开奖不能许愿(344)",
	errorText345 = "许愿次数不足(345)",
	errorText346 = "许愿筹码或礼票不足(346)",--"许愿筹码或礼票不足(346)",
	errorText347 = "许愿类型错误(347)",--"许愿类型错误(347)",
	errorText348 = "一天之内开奖次数超过限制(348)",--"一天之内开奖次数超过限制(348)",

	errorText362 = "当前状态无法进行夺宝（362）",
	errorText363 = "您参与本期商品夺宝次数已达上限（363）",
	errorText364 = "当前vip等级未达到本期商品的夺宝条件（364）",

	errorText370 = "上传失败（370）",
	errorText376 = "点卡信息获取失败（376）",
	errorText380 = "当前筹码处于锁定状态，储值类筹码可在购买后48小时用于实物商城兑换使用（380）",
	errorText381 = "筹码发言失败；vip3解锁发言。（381）",
	errorText382 = "发言失败；筹码量达到1M可发言。（382）",
	errorText383 = "金币发言失败；vip1解锁发言。（383）",
	errorText384 = "今日该商品夺宝数已达上限（384）",
	errorText385 = "活动没开（385）",
	errorText386 = "礼包不存在（386）",
	errorText387 = "已经购买过（387）",
	errorText388 = "没有激活（388）",

	errorText393 = "排行榜未开放（393）",
	errorText394 = "每日宝箱未开放（394）",
	errorText395 = "非每日宝箱商品id（395）",
	errorText398 = "扭蛋活动未开放（398）",
	errorText399 = "非扭蛋商品id（399）",
	errorText400 = "当前未满足条件；累计押注达到200000即可参与抽奖（400）",
	-- errorText401 = "您的每日筹码抽奖上限次数为2，升级vip，畅享抽奖无上限！（401）",
	errorText402 = "扭蛋奖励失败（402）",
	errorText403 = "非签到时间内（403）",
	errorText404 = "已经全部签到（404）",
	errorText405 = "非法扭蛋次数（405）",
	errorText407 = "未购买（407）",
	errorText408 = "奖励已领取（408）",
	errorText455 = "免费筹码领取失败(455)",
	errorText456 = "每日礼包奖励领取失败(456)",
	errorText459 = "任务未完成(459)",
	errorText476 = "重复抽奖(476)",
	errorText479 = "奖励已领取(479)",
	errorText480 = "完成任意一笔付费即可解锁赠送功能(480)",
	errorText482 = "点卡兑换失败(482)",
	errorText483 = "超过可兑换上限(483)",
	errorText484 = "超过单日兑换上限(484)",
	errorText486 = "验证码失效(486)",
	errorText493 = "购买次数达到上限(493)",
	errorText494 = "奖励已领取(494)",
	errorText495 = "礼盒已经抽过(495)",
	errorText496 = "无法打开该礼盒(496)",
	errorText497 = "奖品发送失败(497)",
	errorText498 = "礼盒抽奖出错(498)",
	errorText500 = "礼包已经关闭(500)",
	errorText501 = "达到礼包每日限制(501)",
	errorText502 = "达到礼包总限制(502)",
	errorText503 = "VIP等级无法购买当前礼包(503)",
	errorText504 = "不存在的礼包类型(504)",
	errorText505 = "购买前置礼包的次数不足(505)",
	errorText507 = "抽奖失败(507)",
	errorText508 = "抽奖次数不足(508)",
	errorText509 = "发送奖励失败(509)",
	errorText511 = "获取抽奖次数失败(511)",
	errorText512 = "获取跑马灯广播失败(512)",
	errorText513 = "抽奖活动结束或者未开始(513)",

	errorText515 = "未知的排行榜类型(515)",
	errorText516 = "不允许兑换(516)",
	errorText517 = "获取兑换价值失败(517)",
	errorText518 = "钻石购买失败(518)",
	errorText519 = "获取扭蛋奖池失败(519)",
	errorText520 = "未知的jp类型(520)",
	errorText521 = "奖励领取过了或者没有命中(521)",
	errorText529 = "生日信息修改次数已使用(529)",
	errorText531 = "日期输入不合法(531)",
	errorText538 = "已经打开过(538)",
	errorText539 = "充值金额不足(539)",
	errorText557 = "活动未开启(557)",
	errorText560 = "奖励已领取(560)",
	errorText561 = "礼包库存不足，无法购买(561)",
	errorText580 = "已设置安全码(580)",
	errorText581 = "未设置安全码(581)",
	errorText582 = "安全码冻结(582)",
	errorText583 = "验证服务不存在(583)",
	errorText584 = "安全码校验错误(584)",
	errorText585 = "手机验证码错误(585)",
	errorText586 = "存取金额不正确(586)",
	errorText587 = "服务token校验错误(587)",
	errorText592 = "兑换失败! 请联系客服!(592)",
	errorText593 = "兑换失败! 请联系客服!(593)",
	errorText594 = "电话号码不存在(594)",
	errorText595 = "兑换失败! 请联系客服!(595)",
	errorText596 = "兑换失败! 请联系客服!(596)",
	errorText597 = "Truewallet Money 电话已经被使用(597)",
	errorText600 = "升级失败(600)",
	errorText603 = "输入存在非法字符，请重新输入(603)",
	errorText604 = "IP登录被限制(604)",
	errorText608 = "暂未解锁兑换保底条件(608)",
	errorText614 = "投注时间未开启(614)",
	errorText615 = "当前投注超过最大下注(615)",
}

return lan