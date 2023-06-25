local CC = require("CC")
local CompositeViewCtr = require "view.compositeview.compositeviewctr"
local TrailIOSGameList = require "view.trailview.trailiosgamelist"
local LoginAwardView = require "View.OtherView.LoginAwardView"
local CompositeView = CC.uu.ClassView("CompositeView")
local table = table
local string = string

--按照需求的一些界面配置
local ignoreIndex = 4--不展示材料的个数（当前需求4个普通材料不展示）
local defaultChooseIndex = 5--默认打开索引（当前需求稀有品质的第一个材料默认打开）
local assemblyPosCfg2 = {--两条鱼的位置配置
	Vector2(-114.65,0),
	Vector2(123.75,0),
}

local assemblyPosCfg3 = {--三条鱼的位置配置
	Vector2(-164.1,-0.8),
	Vector2(4.9,-12),
	Vector2(162.9,-1.6),
}

--排行榜按钮
local rankBtnPos = {
	Vector2(-32,2.7),
	Vector2(-578.2,2.7),
}

--排行榜界面
local rankViewPos = {
	Vector2(273.63,0),
	Vector2(-273.63,0),
}

--物品图标大小
local fishIconCfg = {
	[2] = 0.32,
	[3] = 0.32,
	[4] = 0.34,
	[5] = 0.38,
}
--三种排行榜对应的内容结构和服务器字段不一致
local rankTypeViewcfg = {
	--左边是节点的key，右边{服务器key和文本处理函数(self,排名,服务器数据)}
	[1] = {
		Title3Val = {svrKey = "Point",
					func = function(self,ranking,data)
						return data
					end
					},
		Title4Val = {svrKey = "Point",
					func = function(self,ranking,data)
						return self.viewCtr.cfgRankJP[ranking].base
					end
					},
		Title5Val = {svrKey = "Point",
					func = function(self,ranking,data)
						return self.viewCtr.cfgRankJP[ranking].percentage .. "%JP"
					end},
	},
	[2] = {
		Title3Val = {svrKey = "JPAward",
					func = function(self,ranking,data)
						return data
					end
					},
		Title4Val = {svrKey = "Time",
					func = function(self,ranking,data)
						return CC.uu.TimeOut(data)
					end
					},
	},
	[3] = {
		Title3Val = {svrKey = "ExchangeAward",
					func = function(self,ranking,data)
						return data
					end
					},
		Title4Val = {svrKey = "ExchangeGrade",
					func = function(self,ranking,data)
						return self.language["type"..data]
					end
					},
		Title5Val = {svrKey = "Time",
					func = function(self,ranking,data)
						return CC.uu.TimeOut(data)
					end
					},
	},
}

--合成结果面板对应的位置配置
--如果以后组合有四个，那么也要在这里加入对应的[4] = {xxx}
local resultPosConfig = {
	--索引对应物品个数
	[2] = {
		Vector2(200,0),
		Vector2(-200,0),
	},
	[3] = {
		Vector2(200,-111),
		Vector2(-200,-111),
		Vector2(0,200),
	}
}

--左侧渔区点击区域大小配置,与ID对应
local fishClickConfig = {
	[505] = {
		size = Vector2(85,100),
		pos = Vector2(0,-4.72)
	},
	[506] = {
		size = Vector2(85,100),
		pos = Vector2(0,-4.72)
	},
	[507] = {
		size = Vector2(85,100),
		pos = Vector2(0,-4.72)
	},
	[508] = {
		size = Vector2(85,100),
		pos = Vector2(0,-4.72)
	},
	[509] = {
		size = Vector2(112,112),
		pos = Vector2(0,-4.72)
	},
	[510] = {
		size = Vector2(112,112),
		pos = Vector2(0,-4.72)
	},
	[511] = {
		size = Vector2(112,112),
		pos = Vector2(0,-4.72)
	},
	[512] = {
		size = Vector2(112,112),
		pos = Vector2(0,-4.72)
	},
	[513] = {
		size = Vector2(112,112),
		pos = Vector2(0,-4.72)
	},
	[514] = {
		size = Vector2(112,112),
		pos = Vector2(0,-4.72)
	},
	[515] = {
		size = Vector2(166,112),
		pos = Vector2(-27,-4.72)
	},
	[516] = {
		size = Vector2(166,112),
		pos = Vector2(27,-4.72)
	},
}

--当前界面的多次合成数字
local compositeTimes = 5

--!!!!!!!!!!!!!!!!!!!!!!!
--当前活动的版本号,每次活动开启的时候需要+1，
--或者本次活动结束后，其他系统更新的时候可以吧这个也+1
local curVersion = 1

--为了防止协议频繁请求，对JP奖池的数据做时间记录和数据记录
local lastJPTime = nil
local lastJPData = nil
local JPIntervalTime = 1.5

local GetValue
GetValue = function(values)
	if not values[2] then
		return CC.uu.NumberFormat(values[1])
	end
	return CC.uu.NumberFormat(values[1]) .. "-" .. CC.uu.NumberFormat(values[2])
end

function CompositeView:ctor(param)
	self:InitVar(param);
end

function CompositeView:InitVar(param)
	self.param = param;
	self.language = self:GetLanguage();
	self.quaternion = Quaternion()
end

function CompositeView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
	--物品集合，包含data(当前物品对应的数据),transform(当前物品对应的节点,指向的是UI里左侧物体)
	self.itemsCache = {}
	--itemsCache中的标记索引，为当前选中物体的下标
	self.curIndex = 0
	--当前物品中的某组组合数据
	self.curAssemblyData = nil
	--当前选中的组合数组中的下标
	self.curAssemblyIndex = 0

	--一次和五次合成的钻石勾选标识
	--这里的标识逻辑，去点一下UI里的两个toggle比较直观
	self.isChose1 = false
	self.isChose5 = false

	self.isJPInit = true

	self.ChipNum = self:FindChild("CenterRoot/BG/ChipCounter/Icon/Text")
	self.DiaNum = self:FindChild("CenterRoot/BG/DiaCounter/Icon/Text")
	self.grayMaterial = ResMgr.LoadAsset("material", "Gray")
	self:InitContent();
	self:InitTextByLanguage();
end

function CompositeView:ShowExchangeResp(earnChouMa)
	local data = self.viewCtr.cfgBase[self.curExchangeData.ID]
	if data.type >= 4 then
		self:ShowMoneyRewards(earnChouMa)
	else
		CC.ViewManager.OpenRewardsView({items = {{ConfigId = 2, Count = earnChouMa}},title = "Composite"})
	end
end

function CompositeView:InitBroadCastResp(code,data)
	if code ~= 0 then return end
	self:InitBroadcast(data.BroadcastList)
end

function CompositeView:InsertBroadCastResp(code,data)
	if code ~= 0 then return end
	--在插入的时候，先检查下广播初始化请求返回异常导致的数据为空情况
	if not self.bcTable or not self.bcIndex then
		self:InitBroadcast({})
	end
	table.insert(self.bcTable,self.bcIndex + 1,data)
end

function CompositeView:HasJPResp(code,data)
	if code ~= 0 then return end
	if data.IsHitJP then
		self:JPDispose(data.HitJPInfo)
	end
end

function CompositeView:GetJPResp(code,data)
	if code == 0 then
		if self.JPMoney then
			self:ShowMoneyRewards(self.JPMoney,true)
		end
	end
	if self.JPView then
		self.JPView:Destroy()
		self.JPView = nil
	end
	self.JPMoney = 0
end

function CompositeView:ExchangeResp(code,data)
	if code ~= 0 then return end
	self:CloseExchange()
end

function CompositeView:CompositeRespEffFinish()
	CC.Sound.StopEffect()
	local data = self.resultCache
	if not data then
		logError("没有合成结果缓存，无法快速跳过合成阶段")
		return
	end
	self:StopTimer("ResultEffectTimer")
	for i = self.resultEffParent.childCount - 1,1,-1 do
		GameObject.Destroy(self.resultEffParent:GetChild(i).gameObject)
	end
	self.resultEffImmediate.gameObject:SetActive(false)
	self.resultEffDelay.gameObject:SetActive(true)
	self.resultEffBG.gameObject:SetActive(false)

	--如果本次有命中JP，那么在面板关闭之后播放
	if data.IsHitJP == true then
		self.resultCloseCB = function()
			self:JPDispose(data.HitJPInfo)
		end
	end

	--单次合成
	if #data.Result == 1 then
		local isSucc = data.Result[1].IsSuccess
		local itemID = data.Result[1].MaterialID
		local itemScore = data.TotalPoint
		local icon
		if isSucc then
			icon = self.viewCtr.cfgBase[itemID].icon
		else
			icon = self.itemsCache[self.curIndex].data.icon
		end
		self.resultSuccRoot.gameObject:SetActive(isSucc)
		self.resultFailRoot.gameObject:SetActive(not isSucc)
		if isSucc then
			self:SetImage(self.resultIconSucc.transform,icon)
			self.resultScoreSucc.text = itemScore
		else
			self:SetImage(self.resultIconFail.transform,icon)
		end
	--多次合成
	elseif #data.Result > 1 then
		self.resultOutcomesRoot.gameObject:SetActive(true)
		table.sort(data.Result,function(a,b)
			local val1 = a.IsSuccess and 1 or 0
			local val2 = b.IsSuccess and 1 or 0
			return val1 > val2
		end
		)
		for i = 1,compositeTimes do
			local trans = self.resultOCParent:Find("Item"..i)
			local result = data.Result[i]
			if not result then
				trans.gameObject:SetActive(false)
			else
				trans.gameObject:SetActive(true)
			end
			trans:Find("SuccBG").gameObject:SetActive(result.IsSuccess)
			trans:Find("FailBG").gameObject:SetActive(not result.IsSuccess)
			local icon
			local material
			if result.IsSuccess then
				icon = self.viewCtr.cfgBase[result.MaterialID].icon
				material = nil
			else
				icon = self.itemsCache[self.curIndex].data.icon
				material = self.grayMaterial
			end
			self:SetImage(trans:Find("Icon"),icon)
			trans:Find("Icon").gameObject:GetComponent("Image").material = material
		end
		self.resultOCScore.text = data.TotalPoint or 0
	end
	self.isResultShowTime = false
	self.resultCache = nil
end

function CompositeView:CompositeResp(code,data)
	if code ~= 0 then return end

	self.resultCache = data
	if data.IsSuccess then
		CC.Sound.PlayHallEffect("CompositeSuccess")
	else
		CC.Sound.PlayHallEffect("CompositeFail")
	end
	--黑洞特效阶段
	local GOs = {}
	self.isResultShowTime = true
	local assembly = self.curAssemblyData
	self.resultRoot.gameObject:SetActive(true)
	self.resultEffBG.gameObject:SetActive(true)
	self.resultSuccRoot.gameObject:SetActive(false)
	self.resultFailRoot.gameObject:SetActive(false)
	self.resultEffDelay.gameObject:SetActive(false)
	self.resultOutcomesRoot.gameObject:SetActive(false)
	self.resultEffImmediate.gameObject:SetActive(true)
	self.resultEffParent.localRotation = self.quaternion:SetEuler(0, 0, 0);
	for i = 1,#assembly.materials do
		local trans = CC.uu.newObject(self.resultEffPrefab,self.resultEffParent).transform
		self:SetImage(trans:Find("Icon"),self.viewCtr.cfgBase[assembly.materials[i].propID].icon)
		local pos
		for length, v in pairs(resultPosConfig) do
			if #assembly.materials == length then
				pos = v[i]
				break
			end
		end
		if pos == nil then
			logError("单组组合数量超出了当前的配置，查看下resultPosConfig的定义")
		end
		trans.gameObject:GetComponent("RectTransform").anchoredPosition = pos
		trans.gameObject:SetActive(true)
		table.insert(GOs,trans)
	end

	--旋转功能
	local rotateSpeed
	local startSpeed = 200
	local endSpeed = 400
	local startTime = Time.time
	local inhaleTime = 3
	local scaleTo = 0.4
	local Lerp
	Lerp = function(a,b,x)
		if x > 1 then x = 1
		elseif x < 0 then x = 0
		end
		return a + (b - a) * x
	end
	local basePos = {}
	for i = 1,#GOs do
		basePos[i] = GOs[i].localPosition

		local moveTab = {}
		local tabCount = 10
		for i = 1,tabCount do
			local rX = math.random(-20,20)
			local rY = math.random(-20,20)
			table.insert(moveTab,{"localMoveBy", rX, rY , inhaleTime / tabCount, ease = CC.Action.EOutCubic , loop = 2})
		end

		self:RunAction(GOs[i]:Find("Icon"),moveTab)
	end
	self:StartTimer("ResultEffectTimer",0.03,function()
		local x = (Time.time - startTime) / inhaleTime
		rotateSpeed = Lerp(startSpeed,endSpeed,x)
		self.resultEffParent:Rotate(Vector3.forward, rotateSpeed * Time.deltaTime)
		for i = 1,#GOs do
			local lineR = GOs[i]:Find("Line").gameObject:GetComponent(typeof(UnityEngine.LineRenderer))
			lineR:SetPosition(0,self.resultEffParent.position)
			lineR:SetPosition(1,GOs[i].position)
			GOs[i].localPosition = Vector3.Lerp(basePos[i],Vector3.zero,x - 0.3)
			local scale = Lerp(1,scaleTo,x)
			GOs[i].localScale = Vector3(scale,scale,scale)
		end
		if x >= 1 then
			--黑洞展示完成
			self:CompositeRespEffFinish()
		end
	end,-1)
end

function CompositeView:RankResp(code,data)
	if data.type ~= self.curRankType then return end
	local index = self.curRankType
	local tip = self:FindChild("RankRoot/InfoView/Rank"..index.."/Tip")
	local jpValue,scoreValue
	--积分榜的JP处理(先给个默认值)
	if self.curRankType == 1 then
		jpValue = self:FindChild("RankRoot/InfoView/Rank1/JPPanel/JPValue"):GetComponent("Text")
		scoreValue = self:FindChild("RankRoot/InfoView/Rank1/JPPanel/MyScore"):GetComponent("Text")
		jpValue.text = 0
		scoreValue.text = 0
	end
	if code ~= 0 or not data.RankList or not data.RankList[1] then
		tip.gameObject:SetActive(true)
		tip.gameObject:GetComponent("Text").text = self.language.noneData
		return
	end
	if self.curRankType == 1 then
		jpValue.text = self.curScoreJP or 0
		scoreValue.text = data.UserPoint or 0
	end
	tip.gameObject:SetActive(false)
	local root = self:FindChild("RankRoot/InfoView/Rank"..index)
	local prefab = root:FindChild("Scroller/Viewport/Item")
	local parent = root:FindChild("Scroller/Viewport/Content")
	root.gameObject:SetActive(true)
	local dataIdx = 0
	self:StartTimer("RankCreateTimer"..index,0.01,function()
		dataIdx = dataIdx + 1
		local trans = CC.uu.newObject(prefab,parent).transform
		local data = data.RankList[dataIdx]

		--背景板
		if dataIdx % 2 ~= 0 then
			trans:Find("bg2").gameObject:SetActive(true)
		end

		--排名
		local ranking = trans:Find("Ranking").gameObject:GetComponent("Text")
		if dataIdx <= 3 then
			ranking.text = ""
			local crown = self:FindChild("RankRoot/InfoView/CrownPrefab/"..dataIdx)
			local crownIns = CC.uu.newObject(crown,ranking.transform).transform
			crownIns.gameObject:GetComponent("RectTransform").anchoredPosition = Vector2(0,-4.609989)
			crownIns.gameObject:SetActive(true)
		else
			ranking.text = dataIdx
		end

		--头像
		local param = {}
		param.parent = trans:Find("ItemHead")
		param.portrait = data.Portrait
		param.playerId = data.PlayerID
		param.vipLevel = data.VipLevel
		param.clickFunc = "unClick"
		CC.HeadManager.CreateHeadIcon(param)

		--名字
		trans:Find("Nick").gameObject:GetComponent("Text").text = data.Nick
		--后面的文本处理
		for k,v in pairs(rankTypeViewcfg[self.curRankType]) do
			trans:Find(k).gameObject:GetComponent("Text").text = v.func(self,dataIdx,data[v.svrKey])
		end
		trans.gameObject:SetActive(true)
	end,#data.RankList)
end

function CompositeView:JPResp(code,data)
	if code ~= 0 then return end
	lastJPData = data
	local time = 10
	if self.isJPInit then
		time = 3
		self.isJPInit = false
	end
	self.JP1:RollTo(data.MiniJP,time)
	self.JP2:RollTo(data.MinorJP,time)
	self.JP3:RollTo(data.MajorJP,time)
	self.JP4:RollTo(data.GrandJP,time)
	self.curScoreJP = data.ScoreJP or 0
end

function CompositeView:InitContent()
	self:InitFishGroupRoot()
	self:InitComposite()
	self:InitDescrible()
	self:InitAssembly()
	self:InitProbability()
	self:InitExecute()
	self:InitHelp()
	self:InitExchange()
	self:InitJP()
	self:InitRank()
	self:InitResult()
	self:InitRewards()
	self:InitTipAni()
	self:InitExchangeTip()
	self:AddClickEvent()
	self:RefreshSelfInfo()
	self.Marquee = CC.uu.CreateHallView("Marquee",{parent = self:FindChild("MarqueeNode"),TextPos = 1.5})
	self.viewCtr:HasJPReq()
end

function CompositeView:InitFishGroupRoot()
	self.itemPrefab = self:FindChild("CenterRoot/Items/ItemPrefab").gameObject
	self.itemPrefab.transform:FindChild("None").text = self.language.None
	self.isCreateClick = false--创建期间的物品点击不会再选择默认项
	local index = ignoreIndex--略过最低级的普通材料
	self:StartTimer("CreateTimer",0.01,function()
		index = index + 1
		local data = self.viewCtr.cfgBaseArray[index]
		if not data then
			logError("CompositeView:InitContent() data is nil index:"..index)
			return
		end

		local parent = self:FindChild("CenterRoot/Items/Type"..data.type.."/ItemGroup")
		local child = CC.uu.newObject(self.itemPrefab,parent).transform
		child.localScale = Vector3.one
		self:SetImage(child:FindChild("Icon"),data.icon)
		local iSprite = child:FindChild("Icon").gameObject:GetComponent("Image").sprite
		local val = fishIconCfg[data.type]
		child:FindChild("Icon").localScale = Vector3(val,val,val)
		child:FindChild("HasMark").gameObject:SetActive(self.viewCtr.svrData[data.ID] > 0)
		child.gameObject:SetActive(true)

		local click = child:FindChild("Click")
		local clickCfg = fishClickConfig[data.ID]
		click.gameObject:GetComponent("RectTransform").sizeDelta = clickCfg.size
		click.gameObject:GetComponent("RectTransform").anchoredPosition = clickCfg.pos
		self:AddClick(click,function()
			self.isCreateClick = true
			self:OnItemClick(data.ID)
		end)

		--按照美术需求第一层的select要变小
		if data.type == 2 then
			child:FindChild("Select"):GetComponent("RectTransform").sizeDelta = Vector2(94,89)
		end
		self.itemsCache[data.ID] = {}
		self.itemsCache[data.ID].transform = child
		self.itemsCache[data.ID].data = data
		self.itemsCache[data.ID].sprite = iSprite

		--对index和ID做转变
		if index == defaultChooseIndex then
			defaultChooseIndex = data.ID
		end
		--默认打开第一个
		if index == #self.viewCtr.cfgBaseArray and not self.isCreateClick then
			self:OnItemClick(defaultChooseIndex)
		end
	end,#self.viewCtr.cfgBaseArray - index)
end

function CompositeView:InitComposite()
	self.showIcon = self:FindChild("CenterRoot/Composite/ShowIcon/Icon"):GetComponent("Image")
	self.showValue = self:FindChild("CenterRoot/Composite/ShowIcon/Value"):GetComponent("Text")
	self.materialPrefab = self:FindChild("CenterRoot/Composite/HasMaterial/MaterialPrefab")
	self.materialParent = self:FindChild("CenterRoot/Composite/HasMaterial")
	self.probabilityVal = self:FindChild("CenterRoot/Composite/ShowIcon/ProValue"):GetComponent("Text")
	self.probabilityAddVal = self:FindChild("CenterRoot/Composite/ShowIcon/ProAddValue"):GetComponent("Text")
	self.exchangeBan = self:FindChild("CenterRoot/Composite/ShowIcon/ExchangeBan")
	self.iconTips = self:FindChild("CenterRoot/Composite/ShowIcon/Tips")

	self:AddClick(self:FindChild("CenterRoot/Composite/ShowIcon/ExchangeBtn"),function()
		self:OpenExchangeTipPanel(self.itemsCache[self.curIndex].data,self.showIcon.sprite)
	end)
	self:AddClick(self.showIcon.transform,function()
		self:OpenDescPanel(self.itemsCache[self.curIndex].data,
						   self.showIcon.transform.position,
						   self.itemsCache[self.curIndex].sprite)
	end)
end

function CompositeView:InitDescrible()
	self.descRoot = self:FindChild("DescRoot")
	self.descPanel = self:FindChild("DescRoot/Panel")
	self.descIcon = self:FindChild("DescRoot/Panel/Icon"):GetComponent("Image")
	self.descName = self:FindChild("DescRoot/Panel/Name")
	self.descNum = self:FindChild("DescRoot/Panel/Num")
	self.descBG = self:FindChild("DescRoot/Panel/BG"):GetComponent("RectTransform")
	self.descValue = self:FindChild("DescRoot/Panel/Value")
	self.descDesc = self:FindChild("DescRoot/Panel/Describle")
	self.descChoseID = 0
	self.descExchange = self:FindChild("DescRoot/Panel/Exchange")
	self.descBan = self:FindChild("DescRoot/Panel/Exchange/Ban")
	self:AddClick(self.descExchange,function()
		self:CloseDescPanel()
		--打开兑换版本
		self:OpenExchangeTipPanel(self.curDescData,self.descIcon.sprite)

		--打开背包版本
		-- local param = {}
		-- param.callback = function ()
		-- 	CC.ViewManager.Open("ActivityCollectionView",{currentView = "CompositeView"})
		-- end
		-- CC.ViewManager.OpenAndReplace("BackpackView",param)
	end)
	self.descMask = self:FindChild("DescRoot/Mask")
	self:AddClick(self.descMask,function()
		self:CloseDescPanel()
	end)
end

function CompositeView:InitAssembly()
	self.assemblyBG2 = self:FindChild("CenterRoot/Composite/Assembly/BG/BG2")
	self.assemblyBG3 = self:FindChild("CenterRoot/Composite/Assembly/BG/BG3")
	self.assemblyParnet = self:FindChild("CenterRoot/Composite/Assembly/Parent")
	self.assemblyPrefab = self:FindChild("CenterRoot/Composite/Assembly/Parent/MaterialPrefab")
	self.assemblyChangeBan = self:FindChild("CenterRoot/Composite/Assembly/Change/Ban").gameObject
	self.assemblyChangeTips = self:FindChild("CenterRoot/Composite/Assembly/Change/Tips")
	self:AddClick(self:FindChild("CenterRoot/Composite/Assembly/Change"),function()
		self:AssemblyChange()
	end)
end

function CompositeView:InitProbability()
	self.goLottery = self:FindChild("CenterRoot/Composite/GoLottery")
	self:AddClick(self.goLottery:Find("Button"),function()
		CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "ComposeCapsuleView")
	end)
	self.probability1 = self:FindChild("CenterRoot/Composite/Probability1")
	self.probabilityToggle = self:FindChild("CenterRoot/Composite/Probability1/Consume/Toggle")
	self.probabilityToggle:GetComponent("Toggle").isOn = false
	self.probabilityToggle:Find("Background/Checkmark").gameObject:SetActive(false)
	UIEvent.AddToggleValueChange(self.probabilityToggle, function(selected)
		self:OnChoseDiamond1(selected)
	  end)

	self.diamondText = self:FindChild("CenterRoot/Composite/Probability1/Consume/Num"):GetComponent("Text")
	self.probabilityTips = self:FindChild("CenterRoot/Composite/Probability1/Tips")
	self.probabilityTips.gameObject:SetActive(true)
	self:InitProbability5()
end

function CompositeView:InitProbability5()
	self.probability5 = self:FindChild("CenterRoot/Composite/Probability5")
	self.probabilityToggle5 = self:FindChild("CenterRoot/Composite/Probability5/Consume/Toggle")
	self.probabilityToggle5:GetComponent("Toggle").isOn = false
	self.probabilityToggle5:Find("Background/Checkmark").gameObject:SetActive(false)
	UIEvent.AddToggleValueChange(self.probabilityToggle5, function(selected)
		self:OnChoseDiamond5(selected)
	  end)
	self.diamondText5 = self:FindChild("CenterRoot/Composite/Probability5/Consume/Num"):GetComponent("Text")
end

function CompositeView:InitExecute()
	self.execute1 = self:FindChild("CenterRoot/Composite/Execute1")
	self.executeBan1 = self:FindChild("CenterRoot/Composite/Execute1/Ban")
	self:AddClick(self:FindChild("CenterRoot/Composite/Execute1/Button"),function()
		self:ExecuteComposite(1)
	end)
	self:InitExecute5()
end

function CompositeView:InitExecute5()
	self.execute5 = self:FindChild("CenterRoot/Composite/Execute5")
	self.executeBan5 = self:FindChild("CenterRoot/Composite/Execute5/Ban")
	self:AddClick(self:FindChild("CenterRoot/Composite/Execute5/Button"),function()
		self:ExecuteComposite(compositeTimes)
	end)
end

function CompositeView:InitHelp()
	self.helpRoot = self:FindChild("HelpRoot").gameObject
	self:AddClick("CenterRoot/Composite/Help",function()
		self.helpRoot:SetActive(true)
	end)
	self:AddClick("HelpRoot/BtnClose",function()
		self.helpRoot:SetActive(false)
	end)
end

function CompositeView:InitExchange()
	self.curExchangeVal = 0
	self.exchangeRoot = self:FindChild("ExchangeRoot")
    self.exchangeTip = self:FindChild("ExchangeRoot/ChangeValue/ExchangeTip"):GetComponent("Text")
    self.exchangeMoney = self:FindChild("ExchangeRoot/ChangeValue/Money"):GetComponent("Text")
	self.exchangeIcon = self:FindChild("ExchangeRoot/Icon"):GetComponent("Image")

	self.exchangeItemVal = self:FindChild("ExchangeRoot/ItemValue/Value"):GetComponent("Text")
    self.exchangeSlider = self:FindChild("ExchangeRoot/Num"):GetComponent("Slider")
    UIEvent.AddSliderOnValueChange(self.exchangeSlider.transform, function(v)
        self:ExchangeValueChange(self.exchangeSlider.value)
    end)
    self:AddClick(self:FindChild("ExchangeRoot/Close"),function() self:CloseExchange() end)
    self:AddClick(self:FindChild("ExchangeRoot/Do"),function()
		self.viewCtr.canShowIconTip = false
		self.viewCtr:SaveCacheData()
		self.iconTips.gameObject:SetActive(false)
        self.viewCtr:ExchangeReq(self.curExchangeData.ID,self.curExchangeVal)
    end)

    local onAdd = self:FindChild("ExchangeRoot/Add")
    local onSub = self:FindChild("ExchangeRoot/Sub")
    onAdd.onDown = function(obj,eventData)
        self:SetExchangeNum(1)
        self.onAddDownTimer = self:StartTimer("ExchangeAddTimer",0.25,function()
            self:SetExchangeNum(1)
        end,-1)
    end
    onAdd.onUp = function(obj,eventData)
        self:StopTimer("ExchangeAddTimer")
    end

    onSub.onDown = function(obj,eventData)
        self:SetExchangeNum(-1)
        self.onAddDownTimer = self:StartTimer("ExchangeSubTimer",0.25,function()
            self:SetExchangeNum(-1)
        end,-1)
    end
    onSub.onUp = function(obj,eventData)
        self:StopTimer("ExchangeSubTimer")
    end
end

function CompositeView:InitJP()
	self.JP1 = self:FindChild("JPRoot/JP1"):GetComponent("NumberRoller")
	self.JP2 = self:FindChild("JPRoot/JP2"):GetComponent("NumberRoller")
	self.JP3 = self:FindChild("JPRoot/JP3"):GetComponent("NumberRoller")
	self.JP4 = self:FindChild("JPRoot/JP4"):GetComponent("NumberRoller")
	if not lastJPTime or not lastJPData then
		self.viewCtr:JPReq()
		lastJPTime = Time.time
		-- logError("第一次数据请求"..Time.time)
	end
	if lastJPTime and Time.time - JPIntervalTime > lastJPTime then
		self.viewCtr:JPReq()
		lastJPTime = Time.time
		-- logError("超过间隔时间的请求"..Time.time)
	else
		if lastJPData then
			-- logError("使用缓存数据"..Time.time)
			self:JPResp(0,lastJPData)
		end
	end
	self:StartTimer("JPRequestTimer",10,function()
		self.viewCtr:JPReq()
	end,-1)
end

function CompositeView:InitRank()
	self.rankBtn = self:FindChild("RankRoot/Button")
	self.rankBtnDir = self:FindChild("RankRoot/Button/Dir")
	self.rankBG = self:FindChild("RankRoot/BG")
	self.rankView = self:FindChild("RankRoot/InfoView")
	self.defaultToggle = self:FindChild("RankRoot/InfoView/RankType/Type1").gameObject:GetComponent("Toggle")
	UIEvent.AddToggleValueChange(self:FindChild("RankRoot/InfoView/RankType/Type1"), function(b)
		self:RankToggleChange(1,b)
	end)
	UIEvent.AddToggleValueChange(self:FindChild("RankRoot/InfoView/RankType/Type2"), function(b)
		self:RankToggleChange(2,b)
	end)
	UIEvent.AddToggleValueChange(self:FindChild("RankRoot/InfoView/RankType/Type3"), function(b)
		self:RankToggleChange(3,b)
	end)
	self.isOpen = false
	self.curRankType = 0
	self:AddClick(self.rankBtn,function()
		self:RankBtnClick()
	end)

	self:AddClick(self:FindChild("RankRoot/BG"),function()
		--能点击这里的时候一定为打开状态，调用这里可以关闭
		self:RankBtnClick()
	end)
end

function CompositeView:InitResult()
	self.resultRoot = self:FindChild("ResultRoot")
	self.resultEffBG = self:FindChild("ResultRoot/BG/EffectBG")
	self.resultEffPrefab = self:FindChild("ResultRoot/Effect/UINode/Prefab")
	self.resultEffParent = self:FindChild("ResultRoot/Effect/UINode")
	self.resultEffDelay = self:FindChild("ResultRoot/Effect/EffectNode/DelayNode")
	self.resultEffImmediate = self:FindChild("ResultRoot/Effect/EffectNode/ShowNode")
	self.resultSuccRoot = self:FindChild("ResultRoot/Succeed")
	self.resultOutcomesRoot = self:FindChild("ResultRoot/Outcomes")
	self.resultFailRoot = self:FindChild("ResultRoot/Failed")
	self.resultIconSucc = self:FindChild("ResultRoot/Succeed/Icon").gameObject:GetComponent("Image")
	self.resultScoreSucc = self:FindChild("ResultRoot/Succeed/Score").gameObject:GetComponent("Text")
	self.resultIconFail = self:FindChild("ResultRoot/Failed/Icon").gameObject:GetComponent("Image")
	self.resultOCParent = self:FindChild("ResultRoot/Outcomes/Items")
	self.resultOCScore = self:FindChild("ResultRoot/Outcomes/Score").gameObject:GetComponent("Text")
	self.isResultShowTime = true
	self:AddClick(self:FindChild("ResultRoot/BG"),function ()
		self:CloseResultPanel()
	end)
	self:AddClick(self:FindChild("ResultRoot/BG/EffectBG/Quick/Button"),function ()
		self:CompositeRespEffFinish()
	end)
end

function CompositeView:InitRewards()
	self.rewardsShareBtn = self:FindChild("Rewards/ShareDes").gameObject
	self.rewardsShareBtn.gameObject:GetComponent("Text").text = self.language.Tips_ShareDes
	self:AddClick(self:FindChild("Rewards"), function()
		if self.rewardClose then
			self:FindChild("Rewards"):SetActive(false)
		end
	end)
	self:AddClick("Rewards/ShareDes/ShareBtn",function ()
        local param = {}
        param.isShowPlayerInfo = true
        param.webText = self.language.Tips_ShareDes
        CC.ViewManager.Open("CaptureScreenShareView",param)
    end)
end

function CompositeView:InitTipAni()

end

function CompositeView:InitExchangeTip()
	self.exchangeTipPanel = self:FindChild("ExchangeTipRoot").gameObject
	self.ETTip = self:FindChild("ExchangeTipRoot/Tip"):GetComponent("Text")
	self.ETTypeTip = self:FindChild("ExchangeTipRoot/TypeTip"):GetComponent("Text")
	self.ETParent = self:FindChild("ExchangeTipRoot/Items")
	self.ETPrefab = self:FindChild("ExchangeTipRoot/Items/ItemPrefab")
	self:AddClick(self:FindChild("ExchangeTipRoot/BtnNo"),function()
		self:CloseExchangeTipPanel()
	end)
	self:AddClick(self:FindChild("ExchangeTipRoot/BtnClose"),function()
		self:CloseExchangeTipPanel()
	end)
	self:AddClick(self:FindChild("ExchangeTipRoot/BtnOk"),function()
		self:CloseExchangeTipPanel()
		self:ETToggleRecord()
		self:OpenExchange(self.ETCacheData,self.ETCacheSprite)
	end)
	self.ETToggle = self:FindChild("ExchangeTipRoot/Toggle").gameObject:GetComponent("Toggle")

	self.ETCacheData = nil
	self.ETCacheSprite = nil
end

function CompositeView:ETToggleRecord()
	self.viewCtr.cancelExchangeTip = self.ETToggle.isOn
	self.viewCtr.cacheVersion = curVersion
	self.viewCtr:SaveCacheData()
end

function CompositeView:ETCacheJudge()
	--记录版本低于当前版本
	if curVersion > self.viewCtr.cacheVersion then
		return false
	end
	return self.viewCtr.cancelExchangeTip
end

function CompositeView:OpenExchangeTipPanel(data,sprite)
	--最高品级的鱼种不弹出二次确认框
	if data.type == 5 then
		self:OpenExchange(data,sprite)
		return
	end
	--数据缓存相关判断
	if self:ETCacheJudge() then
		self:OpenExchange(data,sprite)
		return
	end
	self.ETToggle.isOn = false
	self.ETCacheData = data
	self.ETCacheSprite = sprite
	local typeWord = self.language["type"..(data.type + 1)]
	self.ETTip.text = string.format(self.language.exchangeTipTypeFormat,typeWord)
	self.ETTypeTip.text = typeWord
	self.exchangeTipPanel:SetActive(true)
	local IDs = {}
	for k,v in pairs(self.viewCtr.cfgAssembly) do
		local mark = false
		for i = 1,#v.materials do
			if v.materials[i].propID == data.ID then
				mark = true
				break
			end
		end
		if mark then
			for i = 1,#v.outcomes do
				table.insert(IDs,v.outcomes[i].propID)
			end
		end
	end
	--给ID排序
	table.sort(IDs,function(a,b)
		return a < b
	end)
	--记录下已经展示的元素，不做重复展示
	local shows = {}
	for k,v in pairs(IDs) do
		local ID = v
		if shows[ID] == nil then
			local trans = CC.uu.newObject(self.ETPrefab,self.ETParent).transform
			trans:Find("Icon"):GetComponent("Image").sprite = self.itemsCache[ID].sprite
			trans:Find("Value"):GetComponent("Text").text = GetValue(self.itemsCache[ID].data.value)
			trans.localScale = Vector3.one
			trans.gameObject:SetActive(true)
		end
		shows[ID] = true
	end
end

function CompositeView:CloseExchangeTipPanel()
	for i = self.ETParent.childCount - 1,1,-1 do
		GameObject.Destroy(self.ETParent:GetChild(i).gameObject)
	end
	self.exchangeTipPanel:SetActive(false)
end

function CompositeView:OnItemClick(index)
	if self.curIndex == index then return end
	--处理旧的
	if self.curIndex ~= 0 then
		self.itemsCache[self.curIndex].transform:FindChild("Select").gameObject:SetActive(false)
		self.itemsCache[self.curIndex].transform:FindChild("None").gameObject:SetActive(false)
		self.itemsCache[self.curIndex].transform:FindChild("HasNum").gameObject:SetActive(false)
		local itemNum = self.viewCtr.svrData[self.itemsCache[self.curIndex].data.ID]
		self.itemsCache[self.curIndex].transform:FindChild("HasMark").gameObject:SetActive(itemNum > 0)
	end
	--处理新的
	self.itemsCache[index].transform:FindChild("Select").gameObject:SetActive(true)
	local itemNum = self.viewCtr.svrData[self.itemsCache[index].data.ID]
	self.itemsCache[index].transform:FindChild("None").gameObject:SetActive(itemNum == 0)
	self.itemsCache[index].transform:FindChild("HasNum").gameObject:SetActive(itemNum > 0)
	self.itemsCache[index].transform:FindChild("HasNum").gameObject:GetComponent("Text").text = itemNum
	self.itemsCache[index].transform:FindChild("HasMark").gameObject:SetActive(false)

	self.curIndex = index
	self:OnChoseItem()
end

function CompositeView:InitBroadcast(data)
	self.bcTable = data
	self.bcIndex = 0
	self.bcInterval = 8
	local func
	func = function()
		self.bcIndex = self.bcIndex + 1
		if self.bcIndex > #self.bcTable then
			self.bcIndex = 1
		end
		local data = self.bcTable[self.bcIndex]
		if data then
			self:ReportBroadcast(data)
		end
	end
	func()
	self:StartTimer("BroadcastTimer",self.bcInterval,function()
		func()
	end,-1)
end

function CompositeView:GetBCText(data)
	local nick = data.Nick
	local money = data.CoinAward
	local grade = self.language["type"..data.Grade]

	local str = ""
	if data.Type == 1 then
		str = string.format(self.language.compositeBCFormat,nick,grade)
	elseif data.Type == 2 then
		str = string.format(self.language.exchangeBCFormat,nick,grade,money)
	elseif data.Type == 3 then
		str = string.format(self.language.hitJPBCFormat,nick,money)
	end
	return str
end

function CompositeView:ReportBroadcast(data)
	local str = self:GetBCText(data)
	if self.Marquee then
        self.Marquee:Report(str)
    end
end

function CompositeView:SetExecuteState()
	local data = self.itemsCache[self.curIndex].data
	self.exchangeBan.gameObject:SetActive(self.viewCtr.svrData[data.ID] == nil or self.viewCtr.svrData[data.ID] == 0)
	if not self.isChose1 then
		self.probabilityToggle:GetComponent("Toggle").isOn = false
		self.probabilityToggle:Find("Background/Checkmark").gameObject:SetActive(false)
		self.executeBan5.gameObject:SetActive(false)
	else
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") < self.curAssemblyData.outcome.diamond then
			self.isChose1 = false
			self.probabilityToggle:GetComponent("Toggle").isOn = false
			self.probabilityToggle:Find("Background/Checkmark").gameObject:SetActive(false)
			self.executeBan5.gameObject:SetActive(false)
		end
	end

	if not self.isChose5 then
		self.probabilityToggle5:GetComponent("Toggle").isOn = false
		self.probabilityToggle5:Find("Background/Checkmark").gameObject:SetActive(false)
		self.executeBan1.gameObject:SetActive(false)
	else
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") < self.curAssemblyData.outcome.diamond * compositeTimes then
			self.isChose5 = false
			self.probabilityToggle5:GetComponent("Toggle").isOn = false
			self.probabilityToggle5:Find("Background/Checkmark").gameObject:SetActive(false)
			self.executeBan5.gameObject:SetActive(false)
		end
	end
end

function CompositeView:OnChoseItem()
	self:SetShowIcon()
	self:SetHasMaterial()
	self:SetExecuteState()
	self:ResetProbability()
	self:SetAssemblyWarp()
end

function CompositeView:ResetProbability()
	self.isChose1 = false
	self.isChose5 = false
	self.probabilityToggle:GetComponent("Toggle").isOn = false
	self.probabilityToggle5:GetComponent("Toggle").isOn = false
end

function CompositeView:SetProbability()
	self:SetProbabilityText()
end

function CompositeView:SetHasMaterial()
	local showDatas = {}
	local curChildCount = self.materialParent.childCount - 1-- -1是因为预制体也在当前节点下，不做统计
	for k,v in ipairs(self.viewCtr.cfgBaseArray) do
		if v.type + 1 == self.itemsCache[self.curIndex].data.type then
			table.insert(showDatas,v)
		end
	end
	--比较是数据多还是子节点个数多
	local length = #showDatas > curChildCount and #showDatas or curChildCount
	for i = 1,length do
		local data = showDatas[i]
		if data == nil then
			self.materialParent:GetChild(i).gameObject:SetActive(false)
		else
			local trans
			if i <= curChildCount then
				trans = self.materialParent:GetChild(i)
			else
				trans = CC.uu.newObject(self.materialPrefab,self.materialParent).transform
				trans.localScale = Vector3.one
				self:AddClick(trans:FindChild("Icon"),function()
					self:OnMaterialClick(i)
				end)
			end
			trans.gameObject:SetActive(true)

			--低于2品质的物品图片没有出现在面板中所以需要创建
			if data.type == 1 then
				self:SetImage(trans:FindChild("Icon"),data.icon)
			else
				trans:FindChild("Icon"):GetComponent("Image").sprite = self.itemsCache[data.ID].sprite
			end
			local num = self.viewCtr.svrData[data.ID]
			trans:FindChild("Num"):GetComponent("Text").text = num > 0 and "x"..num or "<color=#FF0000FF>x0</color>"
		end
	end
end

--已有材料区域的点击，index是材料创建的顺序，如1234
function CompositeView:OnMaterialClick(index)
	local l = 0
	for k,v in ipairs(self.viewCtr.cfgBaseArray) do
		if v.type + 1 == self.itemsCache[self.curIndex].data.type then
			l = l + 1
			if l == index then
				local sprite = self.materialParent:GetChild(index):FindChild("Icon"):GetComponent("Image").sprite
				self:OpenDescPanel(v,self.materialParent:GetChild(index).position,sprite)
				break
			end
		end
	end
end

function CompositeView:ShowMoneyRewards(money,showShare)
	self.rewardClose = false
	self:FindChild("Rewards"):SetActive(true)
	self.rewardsShareBtn:SetActive(false)
	local param = {
		parent = self:FindChild("Rewards/Count"),
		number = money,
		callback = function()
			self.rewardClose = true
			self.rewardsShareBtn:SetActive(showShare)
		end
	}
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	self.numberRoller = CC.ViewCenter.NumberRoller.new();
	self.numberRoller:Create(param);
end

function CompositeView:OnJPFinish()
	self.viewCtr:GetJPReq()
end

function CompositeView:OpenCompositeJPView(data)
	local param = {
		JP1 = data.GrandJP,
		JP2 = data.MajorJP,
		JP3 = data.MinorJP,
		JP4 = data.MiniJP,
		targetType = data.Type,
		finishCall = function()
			self:OnJPFinish()
		end
	}
	self.JPMoney = data.JPAward
	self.JPView = CC.uu.CreateHallView("CompositeJP",param)
end

function CompositeView:JPDispose(data)
	self:OpenCompositeJPView(data)
end

function CompositeView:CloseResultPanel()
	if self.isResultShowTime then return end
	for i = self.resultEffParent.childCount - 1,1,-1 do
		GameObject.Destroy(self.resultEffParent:GetChild(i).gameObject)
	end
	self.resultRoot.gameObject:SetActive(false)
	if self.resultCloseCB then
		self.resultCloseCB()
		self.resultCloseCB = nil
	end
end


function CompositeView:RankToggleChange(index,b)
	if b then
		self:OpenRankByType(index)
	else
		self:CloseRankByType(index)
	end
end

function CompositeView:OpenRankByType(index)
	if self.curRankType == index then return end
	self.curRankType = index
	self:FindChild("RankRoot/InfoView/Rank"..index).gameObject:SetActive(true)
	local tip = self:FindChild("RankRoot/InfoView/Rank"..index.."/Tip")
	tip.gameObject:SetActive(true)
	tip.gameObject:GetComponent("Text").text = self.language.dataLoading
	self.viewCtr:MulRankReq(index)
end

function CompositeView:CloseRankByType(index)
	self:StopTimer("RankCreateTimer"..index)

	local parent = self:FindChild("RankRoot/InfoView/Rank"..index.."/Scroller/Viewport/Content")
	for i = parent.childCount - 1,0,-1 do
		GameObject.DestroyImmediate(parent:GetChild(i).gameObject)
	end
	self:FindChild("RankRoot/InfoView/Rank"..index).gameObject:SetActive(false)
end

function CompositeView:RankBtnClick()
	self.isOpen = not self.isOpen
	self.rankBG.gameObject:SetActive(self.isOpen)
	self.rankBtnDir.localRotation = self.isOpen and self.quaternion:SetEuler(0, 180, 0) or self.quaternion:SetEuler(0, 0, 0);
	self.rankBtn.gameObject:GetComponent("RectTransform").anchoredPosition = self.isOpen and rankBtnPos[2] or rankBtnPos[1]
	self.rankView.gameObject:GetComponent("RectTransform").anchoredPosition = self.isOpen and rankViewPos[2] or rankViewPos[1]
	if self.isOpen then
		self:OpenRankView()
	else
		self:CloseRankView()
	end
end

function CompositeView:OpenRankView()
	self.curRankType = 0
	if self.defaultToggle.isOn then
		self:RankToggleChange(1,true)
		self:FindChild("RankRoot/InfoView/RankType/Type1/Background/Checkmark"):SetActive(true)
	else
		self.defaultToggle.isOn = true
	end
end

function CompositeView:CloseRankView()
	self:RankToggleChange(self.curRankType,false)
	self.curRankType = 0
end


function CompositeView:RefreshItemNum()
	--已有材料区域
	local showDatas = {}
	for k,v in ipairs(self.viewCtr.cfgBaseArray) do
		if v.type + 1 == self.itemsCache[self.curIndex].data.type then
			table.insert(showDatas,v)
		elseif v.type == self.itemsCache[self.curIndex].data.type then
			break
		end
	end
	if #showDatas > self.materialParent.childCount - 1 then
		logError("错误的情况，数据与节点数不匹配")
		return
	end
	for i = 1,#showDatas do
		local num = self.viewCtr.svrData[showDatas[i].ID]
		self.materialParent:GetChild(i):FindChild("Num"):GetComponent("Text").text = num and "x"..num or "x0"
	end

	--左侧渔群
	for k,v in pairs(self.itemsCache) do
		local data = v.data
		local trans = v.transform
		local isCurrent = self.curIndex == data.ID
		local hasNum = self.viewCtr.svrData[data.ID]
		trans:FindChild("None").gameObject:SetActive((hasNum == 0 or hasNum == nil) and isCurrent)
		trans:FindChild("HasNum").gameObject:SetActive(hasNum > 0 and isCurrent)
		trans:FindChild("HasNum").gameObject:GetComponent("Text").text = hasNum
		trans:FindChild("HasMark").gameObject:SetActive(not isCurrent and hasNum > 0)
	end
end


function CompositeView:OnChoseDiamond1(val)
	if val then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") < self.curAssemblyData.outcome.diamond then
			self.isChose1 = false
			self.probabilityToggle:GetComponent("Toggle").isOn = false
			self.probabilityToggle:Find("Background/Checkmark").gameObject:SetActive(false)
			CC.ViewManager.ShowMessageBox(self.language.viewTip16,
			function()
				CC.ViewManager.Open("StoreView",{hideAutoExchange=true})
			end,
			function()

			end)
			return
		end
		self.executeBan1.gameObject:SetActive(false)
		self.executeBan5.gameObject:SetActive(true)
		if not self.isChose5 then
			self.probabilityTips.gameObject:SetActive(false)
		end
	else
		self.executeBan5.gameObject:SetActive(false)
		if not self.isChose5 then
			self.probabilityTips.gameObject:SetActive(true)
		end
	end
	self.isChose1 = val
	self:SetProbabilityText()
end

function CompositeView:OnChoseDiamond5(val)
	if val then
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") < self.curAssemblyData.outcome.diamond * compositeTimes then
			self.isChose5 = false
			self.probabilityToggle5:GetComponent("Toggle").isOn = false
			self.probabilityToggle5:Find("Background/Checkmark").gameObject:SetActive(false)
			CC.ViewManager.ShowMessageBox(self.language.viewTip16,
			function()
				CC.ViewManager.Open("StoreView",{hideAutoExchange=true})
			end,
			function()

			end)
			return
		end
		self.executeBan1.gameObject:SetActive(true)
		self.executeBan5.gameObject:SetActive(false)
		if not self.isChose1 then
			self.probabilityTips.gameObject:SetActive(false)
		end
	else
		self.executeBan1.gameObject:SetActive(false)
		if not self.isChose1 then
			self.probabilityTips.gameObject:SetActive(true)
		end
	end
	self.isChose5 = val
	self:SetProbabilityText()
end

function CompositeView:SetProbabilityText()
	self.probabilityVal.text = ((self.isChose1 or self.isChose5) and
								self.curAssemblyData.outcome.probabilityAdd or
								self.curAssemblyData.outcome.probability)
								.. "%"
	self.probabilityAddVal.text = ((self.isChose1 or self.isChose5)) and
								 "<color=#FF0000FF>(+"..(self.curAssemblyData.outcome.probabilityAdd - self.curAssemblyData.outcome.probability) .. "%)</color>" or
								 ""
end

--钻石判断
function CompositeView:CompositeDo(useDiamond,num)
	if useDiamond then
		--没钻石
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") < self.curAssemblyData.outcome.diamond * num then
			CC.ViewManager.ShowMessageBox(self.language.viewTip16,
			function()
				CC.ViewManager.Open("StoreView",{hideAutoExchange=true})
			end,
			function()

			end)
		else
		--有钻石
			self.viewCtr:CompositeReq(self.curAssemblyData.assemblyID,true,num)
		end
	else
		--不使用钻石
		self.viewCtr:CompositeReq(self.curAssemblyData.assemblyID,false,num)
	end
end

--材料判断
function CompositeView:ExecuteComposite(num)
	--一个是否够
	if not self.curAssemblyData.isSatisfy then
		CC.ViewManager.ShowMessageBox(self.language.viewTip26,
		function()
			CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "ComposeCapsuleView")
		end,
		function()

		end)
	end
	--多个是否够
	if num > 1 then
		local isSatisfy = true
		for i = 1,#self.curAssemblyData.materials do
			local ID = self.curAssemblyData.materials[i].propID
			local n = self.curAssemblyData.materials[i].num
			if self.viewCtr.svrData[ID] < num * n then
				isSatisfy = false
				break
			end
		end
		if not isSatisfy then
			CC.ViewManager.ShowMessageBox(self.language.viewTip26,
			function()
				CC.HallNotificationCenter.inst():post(CC.Notifications.OnCollectionViewJumpToView, "ComposeCapsuleView")
			end,
			function()

			end)
			return
		end
	end

	--第一次钻石勾选检测版本
	-- --没有勾选钻石和第一次合成的话需要弹出提示窗口
	-- if self.viewCtr.isNew and (not self.isChose1 and not self.isChose5) then
	-- 	CC.ViewManager.ShowMessageBox(self.language.viewTip17,
	-- 								  function()
	-- 									self:CompositeDo(true,num)
	-- 							      end,
	-- 								  function()
	-- 									self:CompositeDo(false,num)
	-- 							      end)
	-- else
	-- 	self:CompositeDo(self.isChose1 or self.isChose5,num)
	-- end
	-- self.viewCtr.isNew = false

	--没有第一次钻石勾选检测版本
	self:CompositeDo(self.isChose1 or self.isChose5,num)
end

function CompositeView:AssemblyChange()
	local indexCache = self.curAssemblyIndex
	local pushData,satisfyMark = self:SearchAseemblyData()
	--计算结果和上一次相同则不处理
	if self.curAssemblyIndex == indexCache then
		return
	end
	self.viewCtr.canShowChangeTip = false
	self.viewCtr:SaveCacheData()
	self.assemblyChangeTips.gameObject:SetActive(false)
	self:SetAssembly(pushData,satisfyMark)
end

function CompositeView:SearchAseemblyData()
	local curData = self.itemsCache[self.curIndex].data
	--每次都需要+1来选择下一种组合项
	--举例：现有数组  满足{1,2,3},不满足{1,2,3}
	--当前指向1，那么+1取结果  满足[2]
	--..
	--当前指向3，那么+1取结果  不满足[1]
	--..
	--当前指向6，那么+1取结果  满足[1]
	self.curAssemblyIndex = self.curAssemblyIndex + 1
	--满足材料数量的组合项
	local satisfyAssembly = {}
	--不满足材料数量的组合项
	local dissatisfyAssembly = {}
	for k,v in ipairs(curData.assembly) do
		local isSatisfy = true
		for i = 1,#v.materials do
			if self.viewCtr.svrData[v.materials[i].propID] < v.materials[i].num then
				isSatisfy = false
				break
			end
		end
		if isSatisfy then
			table.insert(satisfyAssembly,v)
		else
			table.insert(dissatisfyAssembly,v)
		end
	end
	local probabilitySortFunc
	probabilitySortFunc = function(a,b)
		return a.outcome.probability > b.outcome.probability
	end
	--满足材料排序，成功率大的排前面
	if #satisfyAssembly > 1 then
		table.sort(satisfyAssembly,probabilitySortFunc)
	end
	--不满足材料排序，成功率大的排前面
	if #dissatisfyAssembly > 1 then
		table.sort(dissatisfyAssembly,probabilitySortFunc)
	end

	local pushData
	local satisfyMark
	if #satisfyAssembly + #dissatisfyAssembly >= self.curAssemblyIndex then
		local val = self.curAssemblyIndex
		if #satisfyAssembly >= self.curAssemblyIndex then
			pushData = satisfyAssembly[val]
			satisfyMark = true
		else
			pushData = dissatisfyAssembly[val - #satisfyAssembly]
			satisfyMark = false
		end
	else
		pushData = satisfyAssembly[1] or dissatisfyAssembly[1]
		satisfyMark = satisfyAssembly[1] and true or false
		self.curAssemblyIndex = 1
	end

	return pushData,satisfyMark
end

function CompositeView:SetAssemblyWarp()
	--重置当前选择的配置组索引
	self.curAssemblyIndex = 0
	self.assemblyChangeTips:SetActive(not(#self.itemsCache[self.curIndex].data.assembly == 1) and self.viewCtr.canShowChangeTip)
	self.assemblyChangeBan:SetActive(#self.itemsCache[self.curIndex].data.assembly == 1)
	local pushData,satisfyMark = self:SearchAseemblyData()
	self:SetAssembly(pushData,satisfyMark)
end

function CompositeView:SetAssembly(data,isSatisfy)
	self.curAssemblyData = data
	self.curAssemblyData.isSatisfy = isSatisfy
	-----组合处理-----
	local showDatas = data.materials
	local curChildCount = self.assemblyParnet.childCount - 1-- -1是因为预制体也在当前节点下，不做统计
	--比较是数据多还是子节点个数多
	local posCfg = #showDatas == 2 and assemblyPosCfg2 or assemblyPosCfg3
	self.assemblyBG2.gameObject:SetActive(#showDatas == 2)
	self.assemblyBG3.gameObject:SetActive(#showDatas == 3)
	local length = #showDatas > curChildCount and #showDatas or curChildCount
	for i = 1,length do
		local data = showDatas[i]
		if data == nil then
			self.assemblyParnet:GetChild(i).gameObject:SetActive(false)
		else
			local trans
			if i <= curChildCount then
				trans = self.assemblyParnet:GetChild(i)
			else
				trans = CC.uu.newObject(self.assemblyPrefab,self.assemblyParnet).transform
				trans.localScale = Vector3.one
				self:AddClick(trans:FindChild("Icon"),function()
					self:OnAssemblyClick(i)
				end)
			end
			trans.gameObject:SetActive(true)
			local itemData = self.viewCtr.cfgBase[data.propID]
			trans:GetComponent("RectTransform").anchoredPosition = posCfg[i]

			--低于2品质的物品图片没有出现在面板中所以需要创建
			if itemData.type == 1 then
				self:SetImage(trans:FindChild("Icon"),itemData.icon)
			else
				trans:FindChild("Icon"):GetComponent("Image").sprite = self.itemsCache[itemData.ID].sprite
			end
			trans:FindChild("Value"):GetComponent("Text").text = "<color=#FAF160>"..self.language.value.."</color>".." "..
																"<color=#FFFBBD>"..GetValue(itemData.value).."</color>"

		end
	end
	-----概率处理-----
	self.diamondText.text = data.outcome.diamond
	self.diamondText5.text = data.outcome.diamond * compositeTimes
	self:SetProbability()
	-----兑换按钮处理-----
	self.probability1.gameObject:SetActive(isSatisfy)
	self.probability5.gameObject:SetActive(isSatisfy)
	self.execute1.gameObject:SetActive(isSatisfy)
	self.execute5.gameObject:SetActive(isSatisfy)
	self.goLottery.gameObject:SetActive(not isSatisfy)
end

function CompositeView:OnAssemblyClick(index)
	for k,v in ipairs(self.curAssemblyData.materials) do
		if k == index then
			local itemData = self.viewCtr.cfgBase[v.propID]
			local sprite = self.assemblyParnet:GetChild(index):FindChild("Icon"):GetComponent("Image").sprite
			self:OpenDescPanel(itemData,self.assemblyParnet:GetChild(index).position,sprite)
			break
		end
	end
end

function CompositeView:OpenDescPanel(data,position,sprite)
	self.curDescData = data
	self.descChoseID = data.ID
	self.descIcon.sprite = sprite
	self.descValue.text = GetValue(data.value)
	self.descPanel.position = position
	self.descRoot.gameObject:SetActive(true)
	self.descNum.text = self.viewCtr.svrData[data.ID]
	-- self.descExchange.gameObject:SetActive(data.type ~= 1 and true or false)
	-- self.descBG.sizeDelta = data.type ~= 1 and Vector2(426,291) or Vector2(426,221)
	self.descName.text = CC.LanguageManager.GetLanguage("L_Prop")[data.ID]
	self.descDesc.text = CC.LanguageManager.GetLanguage("L_Prop")["des"..data.ID]
	-- self.descBan.gameObject:SetActive(self.viewCtr.svrData[data.ID] == nil or self.viewCtr.svrData[data.ID] == 0)
end

function CompositeView:CloseDescPanel()
	self.descChoseID = 0
	self.descRoot.gameObject:SetActive(false)
end

function CompositeView:SetShowIcon()
	self.showIcon.gameObject:SetActive(true)
	self.showIcon.sprite = self.itemsCache[self.curIndex].sprite
	self.showValue.text = "<color=#FAF160>"..self.language.value.."</color>".." "..
							"<color=#FFFBBD>"..GetValue(self.itemsCache[self.curIndex].data.value).."</color>"
	self.iconTips.gameObject:SetActive(self.viewCtr.svrData[self.itemsCache[self.curIndex].data.ID] > 0
									and self.viewCtr.canShowIconTip)
end

function CompositeView:SetExchangeNum(val)
    self.exchangeSlider.value = self.exchangeSlider.value + val
end

function CompositeView:ExchangeValueChange(v)
	v = math.ceil(v - 0.5)
    self.curExchangeVal = v
    self.exchangeTip.text = (self.language.exchangeNum .. v .. "/" .. self.viewCtr.svrData[self.curExchangeData.ID])
	self.exchangeSlider.value = v
	local text
	if not self.curExchangeData.value[2] then
		text = CC.uu.NumberFormat(self.curExchangeData.value[1] * v)
	else
		text = CC.uu.NumberFormat(self.curExchangeData.value[1] * v) .. "-" .. CC.uu.NumberFormat(self.curExchangeData.value[2] * v)
	end
	self.exchangeMoney.text = text
end

function CompositeView:OpenExchange(data,sprite)
    self.exchangeRoot.gameObject:SetActive(true)
	self.curExchangeData = data
	self.curExchangeVal = 1

	self.exchangeItemVal.text = GetValue(data.value)
	self.exchangeTip.text = (self.language.exchangeNum .. 1 .. "/" .. self.viewCtr.svrData[data.ID])
	local text
	if not self.curExchangeData.value[2] then
		text = CC.uu.NumberFormat(self.curExchangeData.value[1])
	else
		text = CC.uu.NumberFormat(self.curExchangeData.value[1]) .. "-" .. CC.uu.NumberFormat(self.curExchangeData.value[2])
	end
	self.exchangeMoney.text = text

    self.exchangeSlider.minValue = 1
    self.exchangeSlider.maxValue = self.viewCtr.svrData[data.ID]
    self.exchangeSlider.value = 1
    self.exchangeIcon.sprite = sprite
    self.exchangeIcon:SetNativeSize()
end

function CompositeView:CloseExchange()
    self.exchangeRoot.gameObject:SetActive(false)
end

function CompositeView:InitTextByLanguage()
	self:FindChild("CenterRoot/Composite/Execute1/Button/Text"):GetComponent("Text").text = self.language.composite1
	self:FindChild("CenterRoot/Composite/Execute1/Ban/Text"):GetComponent("Text").text = self.language.composite1
	self:FindChild("CenterRoot/Composite/Execute5/Button/Text"):GetComponent("Text").text = self.language.composite5
	self:FindChild("CenterRoot/Composite/Execute5/Ban/Text"):GetComponent("Text").text = self.language.composite5
	self:FindChild("CenterRoot/Composite/GoLottery/Button/Text").text = self.language.goLottery

	self:FindChild("CenterRoot/Composite/ShowIcon/ExchangeBtn/Text").text = self.language.exchange

	self:FindChild("CenterRoot/Items/Type2/ItemGrade").text = self.language.type2
	self:FindChild("CenterRoot/Items/Type3/ItemGrade").text = self.language.type3
	self:FindChild("CenterRoot/Items/Type4/ItemGrade").text = self.language.type4
	self:FindChild("CenterRoot/Items/Type5/ItemGrade").text = self.language.type5
	self:FindChild("CenterRoot/Composite/BG/Text").text = self.language.hasMaterial
	self:FindChild("CenterRoot/Composite/Probability1/Consume/Toggle/Label").text = self.language.consume
	self:FindChild("CenterRoot/Composite/Probability5/Consume/Toggle/Label").text = self.language.consume
	self:FindChild("CenterRoot/Composite/ShowIcon/SucceedValue").text = self.language.succeedRate
	self:FindChild("DescRoot/Panel/Exchange/Text").text = self.language.exchange
	self:FindChild("DescRoot/Panel/Exchange/Ban/Text").text = self.language.exchange

	self:FindChild("RankRoot/BG/Tip").text = self.language.viewTip22

	self:FindChild("RankRoot/InfoView/RankType/Type1/Label").text = self.language.scoreRank
	self:FindChild("RankRoot/InfoView/RankType/Type2/Label").text = self.language.JPRank
	self:FindChild("RankRoot/InfoView/RankType/Type3/Label").text = self.language.exchangeRank

	self:FindChild("RankRoot/InfoView/Rank1/JPPanel/Text").text = self.language.myScore
	self:FindChild("RankRoot/InfoView/Rank1/TitlePanel/Title1").text = self.language.ranking
	self:FindChild("RankRoot/InfoView/Rank1/TitlePanel/Title2").text = self.language.player
	self:FindChild("RankRoot/InfoView/Rank1/TitlePanel/Title3").text = self.language.allScore
	self:FindChild("RankRoot/InfoView/Rank1/TitlePanel/Title4").text = self.language.prize
	self:FindChild("RankRoot/InfoView/Rank1/TitlePanel/Title5").text = self.language.JPPrize

	self:FindChild("RankRoot/InfoView/Rank2/TitlePanel/Title1").text = self.language.ranking
	self:FindChild("RankRoot/InfoView/Rank2/TitlePanel/Title2").text = self.language.player
	self:FindChild("RankRoot/InfoView/Rank2/TitlePanel/Title3").text = self.language.JPHitNum
	self:FindChild("RankRoot/InfoView/Rank2/TitlePanel/Title4").text = self.language.winningTime

	self:FindChild("RankRoot/InfoView/Rank3/TitlePanel/Title1").text = self.language.ranking
	self:FindChild("RankRoot/InfoView/Rank3/TitlePanel/Title2").text = self.language.player
	self:FindChild("RankRoot/InfoView/Rank3/TitlePanel/Title3").text = self.language.material2Prize
	self:FindChild("RankRoot/InfoView/Rank3/TitlePanel/Title4").text = self.language.exchangeGrade
	self:FindChild("RankRoot/InfoView/Rank3/TitlePanel/Title5").text = self.language.exchangeTime

	self:FindChild("ResultRoot/Outcomes/Text1").text = self.language.getScore
	self:FindChild("ResultRoot/Succeed/Text1").text = self.language.getScore
	self:FindChild("ResultRoot/BG/Tip").text = self.language.viewTip1
	self:FindChild("ResultRoot/BG/EffectBG/Quick/Button/Text").text = self.language.QuickOpen

	self:FindChild("DescRoot/Panel/BG(1)/Text").text = self.language.num
	self:FindChild("DescRoot/Panel/BG(1)/Text(1)").text = self.language.value

	self:FindChild("ExchangeRoot/ItemValue/Text").text = self.language.value
	self:FindChild("ExchangeRoot/Do/Text").text = self.language.exchange
	self:FindChild("ExchangeRoot/BG/text(2)").text = self.language.exchange
	self:FindChild("ExchangeRoot/Add/Text").text = "+"
	self:FindChild("ExchangeRoot/Sub/Text").text = "-"

	---新增Tips
	self:FindChild("CenterRoot/Composite/ShowIcon/Tips/Text").text = self.language.viewTip23
	self:FindChild("CenterRoot/Composite/Assembly/Change/Tips/Text").text = self.language.viewTip24
	self:FindChild("CenterRoot/Composite/Probability1/Tips/Text").text = self.language.viewTip25

	self:FindChild("ExchangeTipRoot/BtnOk/Text").text = self.language.OK
	self:FindChild("ExchangeTipRoot/BtnNo/Text").text = self.language.NO
	self:FindChild("ExchangeTipRoot/Toggle/Label").text = self.language.exchangeTipToggle
	--帮助
	self:FindChild("HelpRoot/Title/Text").text = self.language.helpTitle
	for i = 1, 15 do
		local index = i
		self:FindChild(string.format("HelpRoot/ScrollView/Viewport/Content/Item%s", index)).text = self.language.helpItem[index]
	end
	for i = 1, 4 do
		local index = i
		self:FindChild(string.format("HelpRoot/ScrollView/Viewport/Content/Title/%s/Text", index)).text = self.language.helpTitleNum[index]
		self:FindChild(string.format("HelpRoot/ScrollView/Viewport/Content/TitleNum/%s/Text", index)).text = self.language.helpNum[index]
	end
end

function CompositeView:OnFocusIn()
	self.viewCtr:OnFocusIn();
end

function CompositeView:ActionIn()
	self:SetCanClick(false);
	-- self.transform.size = Vector2(125, 0)
	-- self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
					self:SetCanClick(true);
				end}
		});
end

function CompositeView:ActionOut()
	self:SetCanClick(false);
	self:OnDestroy();
	CC.HallUtil.HideByTagName("Effect", false)

	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function CompositeView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function CompositeView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function CompositeView:HideAllEffects()
	for _,v in pairs(self.effectList) do
		v:SetActive(false);
	end
end

function CompositeView:AddClickEvent()
	self:AddClick("CenterRoot/BG/ChipCounter",function ()
        if CC.ViewManager.IsHallScene() then
            CC.ViewManager.Open("StoreView", {channelTab = CC.DefineCenter.Inst():getConfigDataByKey("StoreDefine").CommodityType.Chip});
        end
	end)
	self:AddClick("CenterRoot/BG/DiaCounter",function ()
        if CC.ViewManager.IsHallScene() then
            CC.ViewManager.Open("StoreView")
        end
    end)
end

function CompositeView:RefreshSelfInfo()
	self.ChipNum.text = CC.uu.ChipFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa"))
    self.DiaNum.text = CC.uu.ChipFormat(CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi"))
end

function CompositeView:OnDestroy()
	self:CancelAllDelayRun()
	self:StopAllTimer()
	self:StopAllAction()
	if self.Marquee then
        self.Marquee:Destroy()
        self.Marquee = nil
	end
	if self.numberRoller then
		self.numberRoller:Destroy()
		self.numberRoller = nil
	end
	if self.JPView then
		self.JPView:Destroy()
	end
	if self.viewCtr then
		self.viewCtr:OnDestroy();
		self.viewCtr = nil;
	end
end

return CompositeView