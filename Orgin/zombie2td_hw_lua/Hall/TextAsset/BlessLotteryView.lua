
local CC = require("CC")
local BlessLotteryView = CC.uu.ClassView("BlessLotteryView")

local rewardCfg = {
	{rewardId = 2, ConfigId = 2,Count = 3999,icon = "Coin2", text = "3,999"},
	{rewardId = 7, ConfigId = 10002,Count = 1,icon = "prop_img_10002", text = ""},
	{rewardId = 3, ConfigId = 2,Count = 5999,icon = "Coin4", text = "5,999"},
	{rewardId = 4, ConfigId = 2,Count = 9999,icon = "Coin5", text = "9,999"},
	{rewardId = 9, ConfigId = 20103,Count = 1,icon = "prop_img_20103", text = ""},
	{rewardId = 5, ConfigId = 2,Count = 99999,icon = "Coin7", text = "99,999"},
	{rewardId = 1, ConfigId = 18,Count = 1,icon = "lottery_icon_18", text = ""},--系统祝福
	{rewardId = 6, ConfigId = 2,Count = 199999,icon = "Coin8", text = "199,999"},
	{rewardId = 8, ConfigId = 10003,Count = 1,icon = "prop_img_10003", text = ""},
}

function BlessLotteryView:ctor(param)
	self.param = param or {}
	self:InitVar();
end

function BlessLotteryView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();

	self.propfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
	self:InitContent();
	self:InitLanguage();
end

function BlessLotteryView:InitVar()
	self.language = self:GetLanguage();
	self.itemQueue = {};
	self.isShowMsg = false;
	self.isRecViewOpen = false
	self.recType = 1
	self.headList = {}
	--当前选择次数
	self.curOption = 0
	self.LotteryNum = 1
end

function BlessLotteryView:InitLanguage()
	self:FindChild("Frame/Tips"):SetText(self.language.activeTips);
	self:FindChild("Frame/BtnLottery/Text").text = self.language.btnLottery
	self:FindChild("Frame/BtnResult/Text").text = self.language.showResult
	self:FindChild("Frame/Task/1/Text").text = self.language.taskTitle_1
	self:FindChild("Frame/Task/2/Text").text = self.language.taskTitle_2
	self:FindChild("Frame/PropTip/Text").text = self.language.propTip
	self.recordPanel:FindChild("Frame/ToggleGroup/BigRecord/Background/Label").text = self.language.toggleBig
	self.recordPanel:FindChild("Frame/ToggleGroup/BigRecord/Checkmark/Label").text = self.language.toggleBig
	self.recordPanel:FindChild("Frame/ToggleGroup/CountRecord/Background/Label").text = self.language.toggleCount
	self.recordPanel:FindChild("Frame/ToggleGroup/CountRecord/Checkmark/Label").text = self.language.toggleCount
	self:FindChild("Record/Frame/Panel/Item/RankCount/Count/Text").text = self.language.countText
	self.MyRank:FindChild("Count/Text").text = self.language.countText
	self.MyRank:FindChild("Rank").text = self.language.myrankings
	self.MyRank:FindChild("NoRank").text = self.language.norankin
end

function BlessLotteryView:InitContent()
	for i = 1, 9 do
		local rewardData = rewardCfg[i];
		local item = self:CreateBlessItem(i, rewardData);
		table.insert(self.itemQueue, item);
	end
	self.recordPanel = self:FindChild("Record")
	self.recordMask =  self.recordPanel:FindChild("Frame/Mask")
	self.recordScrCtrl = self.recordPanel:FindChild("Frame/Panel/ScrollerController"):GetComponent("ScrollerController")

	self.dropdown = self:FindChild("Frame/Dropdown"):GetComponent("Dropdown")
	self.MyRank = self:FindChild("Record/Frame/Panel/MyRank")
	local headNode = self.MyRank:FindChild("HeadNode");
	self.myHeadIcon = CC.HeadManager.CreateHeadIcon({parent = headNode})
	self:AddClick("Frame/BtnLottery", function ()
		self.viewCtr:Req_UW_PLLottery()
	end);
	self:FindChild("Frame/BtnResult").onClick = function ()
		self.viewCtr:ShowFinishImmediately()
	end
	self:AddClick(self.recordMask,"ChangeRecordViewStatus")
	self:AddClick("Frame/BtnHelp",function ()
		local data = {
			title = self.language.title,
			content = self.language.content,
		}
		CC.ViewManager.Open("CommonExplainView", data)
    end)
	self:AddClick("Frame/Task/1/BtnReceive", function ()
		self.viewCtr:Req_UW_PLotteryTaskReceive(1)
	end)
	self:AddClick("Frame/Task/2/BtnReceive", function ()
		self.viewCtr:Req_UW_PLotteryTaskReceive(2)
	end)

	self.recordScrCtrl:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:RefreshRecordItem(tran,dataIndex)
	end)
	self.recordScrCtrl:AddRycycleAction(function (tran)
		self:RycycleRecordItem(tran)
	end)
	self.panel = self.recordPanel:FindChild("Frame/Panel")
	UIEvent.AddToggleValueChange(self.recordPanel:FindChild("Frame/ToggleGroup/BigRecord"),function (selected)
		if selected then
			self.recType = 2
			self.MyRank:SetActive(false)
			self.panel.transform.height = 592
			self.panel.localPosition = Vector3(20, -38, 0)
			self.recordScrCtrl:InitScroller(#self.viewCtr.bigRecord)
			if not self.isRecViewOpen then
				self:ChangeRecordViewStatus()
			end
		end
	end)
	UIEvent.AddToggleValueChange(self.recordPanel:FindChild("Frame/ToggleGroup/CountRecord"),function (selected)
			if selected then
				self.recType = 1
				self.MyRank:SetActive(true)
				self.panel.transform.height = 516
				self.panel.localPosition = Vector3(20, 0, 0)
				self.recordScrCtrl:InitScroller(#self.viewCtr.countRecord)
				if not self.isRecViewOpen then
					self:ChangeRecordViewStatus()
				end
			end
		end)

	self:InitDropDown()
	self:UpdateCount()
end

function BlessLotteryView:CreateBlessItem(index, rewardData)
	local data = {};
	local obj = self:FindChild(string.format("Frame/Content/%s", index));
	data.index = index;
	data.rewardId = rewardData.rewardId;
	data.ConfigId = rewardData.ConfigId;
	data.Count = rewardData.Count;
	data.selectImg = obj:FindChild("Select");

	self:SetImage(obj:FindChild("Icon"), rewardData.icon)
	obj:FindChild("Text").text = rewardData.text

	return data;
end

--初始化下拉框
function BlessLotteryView:InitDropDown()
    local OptionData = UnityEngine.UI.Dropdown.OptionData
	self.dropdown:ClearOptions()
    for _,v in ipairs(self.viewCtr.dropDownList) do
        local option = string.format("%s x%s", self.language.countText,v)
        local data = OptionData.New(option)
        self.dropdown.options:Add(data)
    end
    UIEvent.AddDropdownValueChange(self.dropdown.transform, function (value)
		self:OnDropdownValueChange(value)
	end)
	self.dropdown.value = self.curOption
	self.dropdown:RefreshShownValue()
end

--次数选择变化
function BlessLotteryView:OnDropdownValueChange(index)
    self.curOption = index
	self.LotteryNum = self.viewCtr.dropDownList[self.curOption + 1]
end

function BlessLotteryView:UpdateCount()
	local propNum = CC.Player.Inst():GetSelfInfoByKey("EPC_Props_83")
    self:FindChild("Frame/Counter/Text").text = CC.uu.ChipFormat(propNum)
end

function BlessLotteryView:ChangeRecordViewStatus()
	self.isRecViewOpen = not self.isRecViewOpen
	self.recordMask:SetActive(self.isRecViewOpen)
	if self.isRecViewOpen then
		self:RunAction(self.recordPanel,{"localMoveBy", -418, 0, 0.2, ease=CC.Action.EOutSine})
	else
		self:RunAction(self.recordPanel,{"localMoveBy", 418, 0, 0.2, ease=CC.Action.EOutSine})
	end
end

function BlessLotteryView:RefreshRecordItem(trans,index)
	if not self.viewCtr then return end
	local dataIdx = index + 1
	local recList
	if self.recType == 2 then
		recList = self.viewCtr.bigRecord
	elseif self.recType == 1 then
		recList =  self.viewCtr.countRecord
	end

	if not recList or table.isEmpty(recList) then
		return
	end

	local recData = recList[dataIdx]
	if self.recType == 2 then
		self:RefreshBigRecordItem(trans,dataIdx,recData)
	elseif self.recType == 1 then
		self:RefreshCountRecordItem(trans,dataIdx,recData)
	end
end

function BlessLotteryView:RycycleRecordItem(trans)
	local index = tonumber(trans.transform.name)
	if self.headList[index] then
		self.headList[index]:Destroy(true)
	end
end

function BlessLotteryView:RefreshBigRecordItem(trans,dataIdx,recData)
	--CC.uu.Log(recData,"recData",3)
	trans.name = dataIdx
	trans:FindChild("Icon"):SetActive(true)
	trans:FindChild("Info"):SetActive(true)
	trans:FindChild("RankCount"):SetActive(false)
	trans:FindChild("Info/Name").text = recData.Nick
	trans:FindChild("Info/Time").text = CC.TimeMgr.GetTimeFormat1(recData.Timestamp)
	if recData.PropID then
		self:SetImage(trans:FindChild("Prop/Icon"),self.propfg[recData.PropID].Icon)
		trans:FindChild("Prop/Icon"):GetComponent("Image"):SetNativeSize()
	end

	local IconData = {}
	IconData.parent = trans:FindChild("Icon/HeadNode")
	IconData.playerId = recData.PlayerId
	IconData.portrait = recData.Portrait
	IconData.headFrame = recData.Background
	IconData.vipLevel = recData.Level
	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headList[dataIdx] = headIcon
end

function BlessLotteryView:RefreshCountRecordItem(trans,dataIdx,recData)
	trans.name = dataIdx
	trans:FindChild("Icon"):SetActive(false)
	trans:FindChild("Info"):SetActive(false)
	trans:FindChild("RankCount"):SetActive(true)
	self:SpriteInfo(dataIdx, trans)
	trans:FindChild("RankCount/Count/Num").text = recData.score
	local ConfigId = self.viewCtr.RewardConfig[dataIdx].rew1.id
	if ConfigId then
		self:SetImage(trans:FindChild("Prop/Icon"),self.propfg[ConfigId].Icon)
		trans:FindChild("Prop/Icon"):GetComponent("Image"):SetNativeSize()
		if self.viewCtr.RewardConfig[dataIdx].rew1.count > 1 then
			trans:FindChild("Prop/Num").text = self.viewCtr.RewardConfig[dataIdx].rew1.count
		else
			trans:FindChild("Prop/Num").text = ""
		end
	end

	local IconData = {}
	IconData.parent = trans:FindChild("RankCount/HeadNode")
	IconData.portrait = recData.Portrait
	-- IconData.headFrame = recData.Background
	IconData.vipLevel = recData.Vip
	IconData.playerId = recData.PlayerId

	local headIcon = CC.HeadManager.CreateHeadIcon(IconData);
	self.headList[dataIdx] = headIcon
end

--皇冠图片切换
function BlessLotteryView:SpriteInfo(key,value)
	if key <= 3 then
		value:FindChild("RankCount/Effect"):SetActive(true)
		value:FindChild("RankCount/Effect/1"):SetActive(key == 1)
		value:FindChild("RankCount/Effect/2"):SetActive(key == 2)
		value:FindChild("RankCount/Effect/3"):SetActive(key == 3)
		value:FindChild("RankCount/Rank"):SetActive(false)
	else
		value:FindChild("RankCount/Effect"):SetActive(false)
		value:FindChild("RankCount/Rank"):SetActive(true)
		value:FindChild("RankCount/Rank/Text").text = key
	end
end

function BlessLotteryView:RefreshUI(param)

	if param.allItemActive ~= nil then
		for _,v in ipairs(self.itemQueue) do
			v.selectImg:SetActive(param.allItemActive);
		end
	end

	if param.itemActiveIndex then
		CC.Sound.PlayHallEffect("lottery_change");
		for _,v in ipairs(self.itemQueue) do
			v.selectImg:SetActive(false);
			if v.index == param.itemActiveIndex then
				v.selectImg:SetActive(true);
			end
		end
	end

	if param.showResult == 1 then
		self:FindChild("Frame/BtnLottery"):SetActive(false);
		self:FindChild("Frame/BtnResult"):SetActive(true);
	elseif param.showResult == 0 then
		self:FindChild("Frame/BtnLottery"):SetActive(true);
		self:FindChild("Frame/BtnResult"):SetActive(false);
	end

	if param.taskList then
		for _, v in ipairs(param.taskList) do
			local id = v.ID
			local Value = v.Value > v.NeeDValue and v.NeeDValue or v.Value
			self:FindChild(string.format("Frame/Task/%s/Text/Des", id)).text = string.format(self.language.taskDes, CC.uu.NumberFormat(Value),CC.uu.NumberFormat(v.NeeDValue))
			self:FindChild(string.format("Frame/Task/%s/Reward/Text",  id)).text = string.format("x%s", v.RewardsList[1].PropNum)
			self:FindChild(string.format("Frame/Task/%s/Reward", id)):SetActive(v.Status ~= 1)
			self:FindChild(string.format("Frame/Task/%s/BtnReceive", id)):SetActive(v.Status == 2)
			self:FindChild(string.format("Frame/Task/%s/Complete", id)):SetActive(v.Status == 1)
			self.viewCtr.taskInfo[id].TaskID = id
			self.viewCtr.taskInfo[id].Level = v.Level
		end
	end
	if param.myRank then
		self.MyRank:FindChild("Rank/Text").text = param.myRank
		self.MyRank:FindChild("Rank"):SetActive(param.myRank ~= 0)
		self.MyRank:FindChild("NoRank"):SetActive(param.myRank == 0)
	end
	if param.myScore then
		self.MyRank:FindChild("Count/Num").text = param.myScore
	end

	if param.showBoardMsg then
		self:ShowBoardMsg();
	end
end

function BlessLotteryView:ShowBoardMsg()
	if self.isShowMsg then return end;
	self.isShowMsg = true;

	local speakBoard = self:FindChild("Frame/SpeakBoard");
	speakBoard:SetActive(true);

	local boardBg = speakBoard:FindChild("BoardBg");
	local msg = boardBg:FindChild("Text");
	local index = 0;
	local moveX = 0;
	local duration = 10;
	local actFunc = function()
		if index >= self.viewCtr.blessDataMgr.GetDataLength() then
			index = 0;
		end
		index = index + 1;
		local data = self.viewCtr.blessDataMgr.GetBlessData();
		msg.text = data[index];
		msg:GetComponent("RectTransform").anchoredPosition = Vector3(0,0,0);
		msg:GetComponent("ContentSizeFitter"):SetLayoutHorizontal();
		moveX = boardBg.width + msg.width;
		self:RunAction(msg, {"localMoveBy", -moveX, 0, duration})
	end

	self:RunAction(self.transform, {"delay", duration+1, onLoop = actFunc, loop = -1, onStart = actFunc});
end

function BlessLotteryView:ActionIn()
	self:SetCanClick(false);
	self:RunAction(self.transform,
			{{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function()
				self:SetCanClick(true);
			end}
		});
end

function BlessLotteryView:ActionOut()
	self:SetCanClick(false);
	self:OnDestroy();
	self:RunAction(self.transform, {{"fadeToAll", 0, 0.5, function() self:Destroy() end},});
end

function BlessLotteryView:ActionShow()
	self:DelayRun(0.5, function() self:SetCanClick(true); end)
	self.transform:SetActive(true);
end

function BlessLotteryView:ActionHide()
	self:SetCanClick(false);
	self.transform:SetActive(false);
end

function BlessLotteryView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy();
	end
	if self.myHeadIcon then
		self.myHeadIcon:Destroy(true)
		self.myHeadIcon = nil
	end
	for _,v in pairs(self.headList) do
		if v then
			v:Destroy(true)
			v = nil
		end
	end
end

return BlessLotteryView;