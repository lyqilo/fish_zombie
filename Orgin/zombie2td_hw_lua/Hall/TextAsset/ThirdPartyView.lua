local CC = require("CC")

local ThirdPartyView = CC.uu.ClassView("ThirdPartyView")

function ThirdPartyView:ctor(param, language)
	self.param = param or {}
	self.language = language
    --游戏卡图对象
	self.gameList = {}
	self.gameAction = {}
end

function ThirdPartyView:OnCreate()
	self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
	CC.ViewManager.CloseNoticeView()
	self.ContentNode = self:FindChild("Scroll View/Viewport/Content")
	self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
	self:AddClickEvent()
	self:InitTopPanel()

	CC.ResDownloadManager.CheckDownloaderState()
end

function ThirdPartyView:AddClickEvent()
	--关闭界面
	self:AddClick("TopPanel/BtnBG/BtnBack",function ()
		CC.Sound.PlayHallBackMusic("BGM_Hall");

		self:Destroy()
	end)
	self:AddClick("TopPanel/BtnBG/BtnSetting",function ()
		CC.ViewManager.Open("SetUpSoundView")
	end)
	self:AddClick("TopPanel/BtnBG/BtnServer",function ()
		CC.ViewManager.OpenServiceView();
	end)
	self:AddClick("TopPanel/BtnBG/ShopBtn",function ()
		CC.ViewManager.Open("StoreView")
	end)
end

function ThirdPartyView:InitTopPanel()
	local headNode = self:FindChild("TopPanel/HeadNode");
	self.HeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode, clickFunc = true});

	local chipNode = self:FindChild("TopPanel/ChipNode");
	self.chipCounter = CC.HeadManager.CreateChipCounter({parent = chipNode, hideBtnAdd = false});
end

function ThirdPartyView:InitGameList(list)
	local index = 1
	self.co_InitList = coroutine.start(function ()
		for i = 1, #list do
			local param = self.viewCtr:GetInfoByID(list[i])
			self:CrePrefab(param, self.ContentNode, index)
			index = index + 1
			coroutine.step(1)
		end
		-- 每次进入，检查当前游戏下载进度
		CC.ResDownloadManager.CheckDownloaderState()
	end)
end

function ThirdPartyView:CrePrefab(param,parent,index)
	local obj = nil
	local preName = "third_" .. param.GameID
	if self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].prefab then
		obj = CC.uu.LoadHallPrefab("prefab",preName,parent)
	else
		obj = CC.uu.LoadHallPrefab("prefab","MiniCard",parent)
		local sprite = self.HallDefine.GameListIcon[preName] and self.HallDefine.GameListIcon[preName].path or "img_yxrk_1002"
		self:SetImage(obj:FindChild("icon"), sprite);
		self:SetImage(obj:FindChild("state/icon"), sprite);
		self:SetImage(obj:FindChild("state/mask"), sprite);
	end
	param.obj = obj
	obj.transform.localScale = Vector3(0,0,1)
	self:InitPrefab(param,index)
end

function ThirdPartyView:InitPrefab(param,index)
	local id = param.GameID
	local obj = param.obj
	local action = {
		{"delay", (index-1) * 0.03},
		{"scaleTo", 1, 1, 0.3, ease = CC.Action.EOutBack},
	}

	--设置下载状态
	obj:FindChild("undownload"):SetActive(CC.LocalGameData.GetGameVersion(id) == 0)
	self.gameAction[index] = self:RunAction(obj, action)
	-------------------------------------------------------------------------------------------
	self.gameList[id] = {}
	self.gameList[id].obj = obj
	self.gameList[id].isClick = false

	self:AddClick(obj,function ()
		self:OnClickCard(id)
	end)
	--------------------------------点击缩放-------------------------------------
	obj.onDown = function ()
		if self.gameList[id].isClick == false then
			self:RunAction(obj, { "scaleTo", 0.98, 0.98, 0.05, ease = CC.Action.EOutBack})
		end
	end

	obj.onUp = function ()
		if self.gameList[id].isClick == false then
			self:RunAction(obj, { "scaleTo", 1, 1, 0.05, ease = CC.Action.EOutBack})
		end
	end
	-----------------------------------------------------------------------------------------
end

function ThirdPartyView:OnClickCard(id)
	if self.gameList[id] and self.gameList[id].isClick == false then
		self.gameList[id].isClick = true
		local chip = 18000
		if CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa") < chip then
			CC.ViewManager.ShowTip(string.format(self.language.thirdGameTip, chip))
			self.gameList[id].isClick = false
			return
		end
		CC.HallUtil.CheckAndEnter(id, {GameId = id})
	end
end

function ThirdPartyView:DownloadProcess(data)
	local id = data.gameID
	local process = data.process
	if self.gameList[id] == nil then return end
	local obj = self.gameList[id].obj
	if process < 1 then
		if process == 0 then
			obj:FindChild("icon"):SetActive(false)
			obj:FindChild("undownload"):SetActive(false)
			obj:FindChild("state"):SetActive(true)
			obj:FindChild("state/slider"):SetActive(true)
			obj:FindChild("state/slider/Text").text = self.language.download_tip
			obj:FindChild("state/slider/Slider"):GetComponent("Slider").value = process
		else
			obj:FindChild("icon"):SetActive(false)
			obj:FindChild("undownload"):SetActive(false)
			obj:FindChild("state"):SetActive(true)
			obj:FindChild("state/slider"):SetActive(true)
			obj:FindChild("state/slider/Text").text = string.format("%.1f",process * 100) .. "%"
			obj:FindChild("state/slider/Slider"):GetComponent("Slider").value = process
		end
	else
		obj:FindChild("icon"):SetActive(true)
		obj:FindChild("undownload"):SetActive(false)
		obj:FindChild("state"):SetActive(false)
		self.gameList[id].isClick = false
	end
end

function ThirdPartyView:DownloadFail(id)
	if self.gameList[id] == nil then return end
	local obj = self.gameList[id].obj
	obj:FindChild("icon"):SetActive(true)
	obj:FindChild("undownload"):SetActive(true)
	obj:FindChild("state"):SetActive(false)
	self.gameList[id].isClick = false
end


function ThirdPartyView:OnDestroy()
	if self.param and self.param.closeFunc then
		self.param.closeFunc()
	end
	if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end

	if self.HeadIcon then
		self.HeadIcon:Destroy();
		self.HeadIcon = nil;
	end

	if self.chipCounter then
		self.chipCounter:Destroy();
		self.chipCounter = nil;
	end
end

function ThirdPartyView:ActionIn()
end

return ThirdPartyView