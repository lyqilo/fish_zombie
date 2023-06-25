local CC = require("CC")

local DebugView = CC.uu.ClassView("DebugView")

local _NAME = "DebugConfig"

local EnumDropKey = {
	envState = 1,
	webConfig = 2,
	lan = 3,
	hall = 4,
	game = 5,
	log = 6,
	guide = 7,
	-- package = 8,
	ad = 8,
	googleiap = 9,
	dot = 10,
	lock = 11,
	lowhttp = 12
}

local EnumInputKey = {
	hallIP = 1,
	http = 2,
	gameIP = 3,
	extraAddress = 4,
	account = 5,
	gameHttp = 6
}

function DebugView:ctor()
	self._data = CC.DebugDefine.GetDebugConfig()
end

function DebugView:GlobalNode()
	return GameObject.Find("Main/Canvas/Main").transform
end

function DebugView:GlobalExtend()
	return GameObject.Find("Main/Canvas/Extend").transform
end

function DebugView:GlobalCamera()
	return DebugView.Find("Main/UICamera"):GetComponent("Camera")
end

function DebugView:GlobalLayer()
	return "layer31"
end

function DebugView:OnCreate()
	local enter = self:FindChild("BGImage/Panel/Enter")
	local pos = enter.localPosition
	enter.localPosition = Vector3(pos.x, pos.y - 40, pos.z)

	local moduleTestBtn = self:FindChild("BGImage/Panel/ModuleTestBtn")
	pos = moduleTestBtn.localPosition
	moduleTestBtn.localPosition = Vector3(pos.x, pos.y - 40, pos.z)

	self:AddClick("BGImage/Panel/Enter", "Enter")
	self:AddClick("BGImage/Panel/Check", "Check")
	self:AddClick("BGImage/Panel/Revert", "Revert")
	self:AddClick("BGImage/Panel/Dev", "Dev")
	self:AddClick("BGImage/Panel/Test", "Test")
	self:AddClick(
		"BGImage/Panel/ModuleTestBtn",
		function()
			self:FindChild("BGImage/ModuleTest"):SetActive(true)
		end
	)
	self.backToggle = self:FindChild("BGImage/ModuleTest/AndroidBtn/Toggle/Back"):GetComponent("Toggle")
	self.shopToggle = self:FindChild("BGImage/ModuleTest/AndroidBtn/Toggle/Shop"):GetComponent("Toggle")
	UIEvent.AddToggleValueChange(
		self.backToggle.transform,
		function()
			self:SetButtonShow()
		end
	)
	UIEvent.AddToggleValueChange(
		self.shopToggle.transform,
		function()
			self:SetButtonShow()
		end
	)
	self:AddClick(
		"BGImage/ModuleTest/Close",
		function()
			self:FindChild("BGImage/ModuleTest"):SetActive(false)
		end
	)
	self:AddClick(
		"BGImage/ModuleTest/AndroidBtn/Show",
		function()
			self:SetButtonState(1)
		end
	)
	self:AddClick(
		"BGImage/ModuleTest/AndroidBtn/Hide",
		function()
			self:SetButtonState(0)
		end
	)
	self:AddClick(
		"BGImage/ModuleTest/ReviewsBtn",
		function()
			self:RequestGoogleReviewManager()
		end
	)
	self:AddClick(
		"BGImage/ModuleTest/Topic/Button",
		function()
			self:OnClickTopicBtn()
		end
	)

	self:CreateDropList()
	self:CreateInputList()

	self.EmulatorText = self:FindChild("BGImage/Panel/Emulator/Text")

	self:CheckAndroidEmulator()

	CC.uu.Log(AppsFlyerUtil.GetAppsFlyerId(), "AppsflyerId:")
	log("当前网络标识：" .. Client.GetNetworkType())
	log("当前设备语言：" .. Client.GetDeviceLanguage())
	self:registerEvent()
end

function DebugView:CreateDropList()
	self.selectList = {
		[EnumDropKey.envState] = {
			Key = "envState",
			Desc = "服务器",
			Options = {
				"正式服",
				"测试服",
				"开发服(游戏)",
				"开发服(大厅)",
				"正式服(备用)",
				"灰度服"
			}
		},
		[EnumDropKey.webConfig] = {
			Key = "webConfig",
			Desc = "web配置",
			Options = {
				"正式",
				"测试",
				"开发",
				"正式(备用)",
				"灰度"
			}
		},
		[EnumDropKey.lan] = {
			Key = "lan",
			Desc = "语言",
			Options = {
				"本地",
				"中文"
			}
		},
		[EnumDropKey.hall] = {
			Key = "hall",
			Desc = "大厅更新",
			Options = {
				"不跳过",
				"跳过"
			}
		},
		[EnumDropKey.game] = {
			Key = "game",
			Desc = "游戏更新",
			Options = {
				"不跳过",
				"跳过",
				"强制"
			}
		},
		[EnumDropKey.log] = {
			Key = "log",
			Desc = "日志",
			Options = {
				"开启",
				"关闭"
			}
		},
		[EnumDropKey.guide] = {
			Key = "guide",
			Desc = "新手引导",
			Options = {
				"不跳过",
				"跳过"
			}
		},
		-- [EnumDropKey.package] = {
		-- 	Key = "package",
		-- 	Desc = "封包工具",
		-- 	Options = {
		-- 		"关闭", "开启"
		-- 	},
		-- },
		[EnumDropKey.ad] = {
			Key = "ad",
			Desc = "广告",
			Options = {
				"正常",
				"关闭",
				"重置"
			}
		},
		[EnumDropKey.googleiap] = {
			Key = "googleiap",
			Desc = "消耗谷歌订单",
			Options = {
				"正常",
				"作弊"
			}
		},
		[EnumDropKey.dot] = {
			Key = "dot",
			Desc = "打点",
			Options = {
				"关闭",
				"开启"
			}
		},
		[EnumDropKey.lock] = {
			Key = "lock",
			Desc = "一级锁",
			Options = {
				"正常",
				"打开"
			}
		},
		[EnumDropKey.lowhttp] = {
			Key = "lowhttp",
			Desc = "降级",
			Options = {
				"正常",
				"打开"
			}
		}
	}

	local OptionData = UnityEngine.UI.Dropdown.OptionData
	local dropdownGroup = self:FindChild("BGImage/Panel/DropdownGroup")
	local unitDropdown = dropdownGroup:FindChild("DropdownUnit")
	for _, config in ipairs(self.selectList) do
		local item = CC.uu.UguiAddChild(dropdownGroup, unitDropdown, config.Key)
		item:SetText("Desc", config.Desc)
		local dropdown = item:GetComponent("Dropdown")
		dropdown:ClearOptions()
		for _, option in ipairs(config.Options) do
			local data = OptionData.New(option)
			dropdown.options:Add(data)
		end
		dropdown.value = self._data[config.Key] - 1

		if config.Key == "webConfig" then
			UIEvent.AddDropdownValueChange(
				dropdown.transform,
				function(value)
					value = value + 1
					if value ~= CC.DebugDefine.WebConfigState.Dev and CC.Platform.isWin32 and not Application.isEditor then
						local dropdown = self.selectList[EnumDropKey.hall].dropdown
						dropdown.value = 1
						dropdown:RefreshShownValue()

						dropdown = self.selectList[EnumDropKey.game].dropdown
						dropdown.value = 1
						dropdown:RefreshShownValue()
					end
				end
			)
		elseif config.Key == "hall" or config.Key == "game" then
			local value = self._data["webConfig"]
			if value ~= CC.DebugDefine.WebConfigState.Dev and CC.Platform.isWin32 then
				dropdown.value = 1
			end
			UIEvent.AddDropdownValueChange(
				dropdown.transform,
				function(value)
					value = value + 1
					if
						value ~= 2 and CC.Platform.isWin32 and not Application.isEditor and
							self.selectList[EnumDropKey.webConfig].dropdown.value + 1 ~= CC.DebugDefine.WebConfigState.Dev
					 then
						dropdown.value = 1
						dropdown:RefreshShownValue()
					end
				end
			)
		elseif config.Key == "log" then
			local func = function(value)
				if value == 0 then
					CC.uu.OpenLogView()
				elseif value == 1 then
					CC.uu.CloseLogView()
				end
			end
			func(dropdown.value)
			UIEvent.AddDropdownValueChange(dropdown.transform, func)
		elseif config.Key == "envState" then
			item:FindChild("Label"):GetComponent("Text").fontSize = 20
			item:FindChild("Template/Viewport/Content/Item/Item Label"):GetComponent("Text").fontSize = 18
		end

		dropdown:RefreshShownValue()

		config.dropdown = dropdown
	end
end

function DebugView:CreateInputList()
	self.inputList = {
		[EnumInputKey.hallIP] = {
			Key = "hallIP",
			Desc = "大厅Tcp:",
			Tip = "Tcp专用 端口的域名或者ip,127.0.0.1:5001",
			DefaultText = ""
		},
		[EnumInputKey.http] = {
			Key = "http",
			Desc = "Http:",
			Tip = "Http专用, 只需填域名或者IP",
			DefaultText = ""
		},
		[EnumInputKey.gameHttp] = {
			Key = "gameHttp",
			Desc = "Nginx:",
			Tip = "大厅nginx转发,指向资源服和游戏管理服"
		},
		[EnumInputKey.gameIP] = {
			Key = "gameIP",
			Desc = "游戏IP:",
			Tip = "填写带端口域名或者ip，比如 127.0.0.1:10001"
		},
		[EnumInputKey.extraAddress] = {
			Key = "extraAddress",
			Desc = "透传地址:",
			Tip = "子游戏可以用来传递地址，接口是GetExtraAddress"
		},
		[EnumInputKey.account] = {
			Key = "account",
			Desc = "设备号:",
			Tip = "账号为空即用设备码注册"
		}
	}

	local sortList = {
		EnumInputKey.hallIP,
		EnumInputKey.http,
		EnumInputKey.gameHttp,
		EnumInputKey.gameIP,
		EnumInputKey.extraAddress,
		EnumInputKey.account
	}

	local inputGroup = self:FindChild("BGImage/Panel/InputGroup")
	local inputUnit = inputGroup:FindChild("InputUnit")

	for _, key in ipairs(sortList) do
		local config = self.inputList[key]
		local item = CC.uu.UguiAddChild(inputGroup, inputUnit, config.Key)
		item:SetText("Label", config.Desc)
		item:SetText("Tip", config.Tip)
		local inputField = item:GetComponent("InputField")
		inputField.text =
			(self._data[config.Key] ~= nil and self._data[config.Key] ~= "") and self._data[config.Key] or
			(config.DefaultText or "")

		self:AddClick(
			item:FindChild("Button"),
			function()
				inputField.text = ""
			end
		)

		config.inputField = inputField
	end
end

function DebugView:Enter()
	for _, config in ipairs(self.selectList) do
		self._data[config.Key] = config.dropdown.value + 1
	end
	for _, config in ipairs(self.inputList) do
		self._data[config.Key] = config.inputField.text
	end
	CC.DebugDefine.SaveDebugInfo(self._data)
	CC.UserData.Save(_NAME, self._data)
	-- CC.ViewManager.CommonEnterMainScene()
	-- CC.HallCenter.InitBeforeLogin()
	local doFunc = function()
		CC.WebUrlManager.UpdateAPI()
		CC.ReportManager.SetDot("STARTAPP")
	end
	CC.WebUrlManager.ReqEntryConfig(doFunc)
	CC.ViewManager.Replace("LoadingView")

	if not CC.LocalGameData.GetLocalStateToKey("FCMDebugMode") then
		CC.LocalGameData.SetLocalStateToKey("FCMDebugMode", true)
		CC.FirebasePlugin.TrackDebugMode()
	end
end

function DebugView:Check()
	local dropdownConfig = {
		[EnumDropKey.envState] = CC.DebugDefine.EnvState.Release - 1,
		[EnumDropKey.webConfig] = CC.DebugDefine.WebConfigState.Test - 1,
		[EnumDropKey.lan] = 0,
		[EnumDropKey.hall] = 0,
		[EnumDropKey.game] = 2,
		[EnumDropKey.guide] = 0,
		[EnumDropKey.ad] = 0
	}

	local inputConfig = {
		[EnumInputKey.hallIP] = "",
		[EnumInputKey.http] = "",
		[EnumInputKey.gameIP] = "",
		[EnumInputKey.extraAddress] = ""
	}

	self:UpdateConfig(dropdownConfig, inputConfig)
end

function DebugView:Revert()
	local dropdownConfig = {
		[EnumDropKey.envState] = CC.DebugDefine.EnvState.Release - 1,
		[EnumDropKey.webConfig] = CC.DebugDefine.WebConfigState.Release - 1,
		[EnumDropKey.lan] = 0,
		[EnumDropKey.hall] = 0,
		[EnumDropKey.game] = 0,
		[EnumDropKey.guide] = 0,
		[EnumDropKey.ad] = 0,
		[EnumDropKey.googleiap] = 0,
		[EnumDropKey.dot] = 0,
		[EnumDropKey.lock] = 0
	}

	local inputConfig = {
		[EnumInputKey.hallIP] = "",
		[EnumInputKey.http] = "",
		[EnumInputKey.gameIP] = "",
		[EnumInputKey.extraAddress] = ""
	}
	self:UpdateConfig(dropdownConfig, inputConfig)
end

function DebugView:Dev()
	local dropdownConfig = {
		[EnumDropKey.envState] = CC.DebugDefine.EnvState.StableDev - 1,
		[EnumDropKey.webConfig] = CC.DebugDefine.WebConfigState.Dev - 1,
		[EnumDropKey.lan] = 0,
		[EnumDropKey.hall] = 0,
		[EnumDropKey.game] = 1,
		[EnumDropKey.guide] = 1,
		[EnumDropKey.ad] = 1
	}

	local inputConfig = {}
	self:UpdateConfig(dropdownConfig, inputConfig)
end

function DebugView:Test()
	local dropdownConfig = {
		[EnumDropKey.envState] = CC.DebugDefine.EnvState.Test - 1,
		[EnumDropKey.webConfig] = CC.DebugDefine.WebConfigState.Test - 1,
		[EnumDropKey.hall] = 0,
		[EnumDropKey.game] = 0
	}

	local inputConfig = {}
	self:UpdateConfig(dropdownConfig, inputConfig)
end

function DebugView:UpdateConfig(dropdownConfig, inputConfig)
	for index, value in pairs(dropdownConfig) do
		local config = self.selectList[index]
		local dropdown = config.dropdown
		dropdown.value = value
		if config.Key == "hall" or config.Key == "game" then
			local webConfgValue = self.selectList[EnumDropKey.webConfig]
			if webConfgValue ~= CC.DebugDefine.EnvState.Dev and CC.Platform.isWin32 and not Application.isEditor then
				dropdown.value = 1
			end
		end
		dropdown:RefreshShownValue()
	end

	for index, value in pairs(inputConfig) do
		local config = self.inputList[index]
		local inputField = config.inputField
		inputField.text = value
	end
end

function DebugView:CheckAndroidEmulator()
	self.EmulatorText.text = Client.IsEmulator() and "是" or "否"
end

--------------安卓原生按钮-------------

function DebugView:SetButtonShow()
	local btn = {}
	if self.backToggle.isOn then
		table.insert(btn, "1")
	end
	if self.shopToggle.isOn then
		table.insert(btn, "2")
	end
	CC.SubGameInterface.SetFloatBtnGroupState(btn)
end

function DebugView:SetButtonState(state)
	CC.SubGameInterface.CreateFloatBtnGroup(state)
end

function DebugView:OnBackBtnClicked(msg)
	if msg then
		local table = Json.decode(msg)
		local result = table.result
		if result == 1 then
			logError("ClickBtn:返回")
		elseif result == 2 then
			logError("ClickBtn:商店")
		else
			logError("Error")
		end
	end
end
---------------------------------------------

function DebugView:RequestGoogleReviewManager()
	Client.ShowAppRate(true)
end

function DebugView:OnAppRateCallBack(msg)
	if msg then
		local table = Json.decode(msg)
		local code = table.code
		logError("Reviews response:" .. code)
		if code == 0 then
			--完成调起流程
		else
			logError("调起系统评价失败")
		end
	end
end

function DebugView:OnClickTopicBtn()
	local inputField = self:FindChild("BGImage/ModuleTest/Topic"):GetComponent("InputField")
	local topic = inputField.text
	if topic ~= "" then
		log("SubscribeTopic:" .. topic)
		CC.FirebasePlugin.SubscribeTopic(topic)
	end
end

function DebugView:registerEvent()
	CC.HallNotificationCenter.inst():register(self, self.OnBackBtnClicked, CC.Notifications.OnClickFloatActionButton)
	CC.HallNotificationCenter.inst():register(self, self.OnAppRateCallBack, CC.Notifications.OnAppRateCallBack)
end

function DebugView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregisterAll(self)
end

function DebugView:OnDestroy()
	self:unRegisterEvent()
end

return DebugView
