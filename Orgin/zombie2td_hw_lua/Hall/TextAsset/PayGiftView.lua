
local CC = require("CC")
local PayGiftView = CC.uu.ClassView("PayGiftView")

function PayGiftView:ctor(param)

	self:InitVar(param);
end

function PayGiftView:InitVar(param)
    self.param = param
	self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.propfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop")
    self.isShowPanel = false
    self.IconTab = {}
    self.LotteryIndex = 1
    self.Boxid = 1
    self.BoxData = {}
    self.Recharge = 0
    self.Props = {{"swsc_cm_01","prop_img_10001","prop_img_22"},
                  {"swsc_cm_02","prop_img_10006","prop_img_22"},
                  {"swsc_cm_03","prop_img_10003","prop_img_22"},
                  {"swsc_cm_04","prop_img_10004","prop_img_22","prop_img_20038"},
                  {"swsc_cm_05","prop_img_10004","prop_img_22","prop_img_20038"},
                 }
    self.TipTest = {{"สูงสุด300K","250"},{"สูงสุด1M","600"},{"สูงสุด2M","1050"},{"สูงสุด5M","1600"},{"สูงสุด10M","4500"}}
    self.ShowImages = {"prop_img_10001","prop_img_10006","prop_img_10003","prop_img_20038","prop_img_20038"}
end

function PayGiftView:OnCreate()
    self:InitNode()
    self:InitView()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param);
    self.viewCtr:OnCreate()
end

function PayGiftView:InitNode()
    self.Ls = self:FindChild("UI/TotalPay/Ls")
    self.TimeTxt = self:FindChild("UI/Bg/Image/Time")
    self.RankContent = self:FindChild("RankPanel/Panel/Bg/Scroll View/Viewport/Content")
    self.RankItem = self.RankContent:FindChild("Item")
    self.BroadCast = self:FindChild("BroadCast")
    self.BroadCast_Lenth = (self:FindChild("BroadCast/Bg"):GetComponent('RectTransform').rect.width - 15)/2
    self.tipText = self:FindChild("BroadCast/Bg/Text")
    self.Effect_zhuanDong = self:FindChild("UI/Effect/Effect_zhuanDong")
    self.WindContent = self:FindChild("UI/Bg/Image/Window/Content")
    self.LotteryBtn = self:FindChild("Btn/LotteryBtn")
    self.ShowIma = self:FindChild("UI/Bg/Image/Window/Image")

    self.Progress = self:FindChild("UI/Progress"):GetComponent("Slider")
    self.BoxToggles = {}
    for i=1,5 do
        table.insert(self.BoxToggles,self:FindChild("Btn/Box/Box"..i):GetComponent("Toggle"))
    end
end

function PayGiftView:InitView()
    --self:FindChild("UI/Bg/Image/Time").text = self.language.ActTime
    self:FindChild("Btn/LotteryBtn/Normal/Text").text = self.language.Lottery
    self:FindChild("Btn/LotteryBtn/Gray/Text").text = self.language.Lottery
    self:FindChild("UI/Tip").text = self.language.Tip
    self:FindChild("UI/TotalPay").text = self.language.TotalPay
    self:FindChild("Btn/Box/Box1/Tip/Text").text = self.language.Tip1
    
    self:OnClickBox(self.Boxid)
end

function PayGiftView:InitClickEvent()
    self:AddClick(self:FindChild("Btn/ExplainBtn") , function() self:OpenExplainView() end)
    self:AddClick(self:FindChild("Btn/LotteryBtn/Normal") , function() self:ReqLottery() end)
    for i=1,5 do
        self:AddClick(self:FindChild("Btn/Box/Box"..i) , function() self:OnClickBox(i) end)
    end
    self:AddClick(self:FindChild("Btn/ClostBtn") , function() self:ActionOut() end)
end

function PayGiftView:OpenExplainView()
	local data = {
		title = self.language.explainTitle,
		content = self.language.explainContent,
	}
	CC.ViewManager.Open("CommonExplainView", data)
end

function PayGiftView:OnClickBox(index)
   self.Boxid = index
   local state = nil 
   if not self.BoxData[index] then
       state = false
   else
       state = self.BoxData[index].isCanGet
   end
   self.BoxToggles[index].isOn = true
   self.LotteryBtn:FindChild("Normal"):SetActive(state)
   self.LotteryBtn:FindChild("Gray"):SetActive(not state)
   local prop = self.Props[self.Boxid]
   local localdata =  CC.LocalGameData.GetDataByKey("PayGiftView",CC.Player.Inst():GetSelfInfoByKey("Id")..self.Boxid)
   local image = localdata and localdata or self.ShowImages[self.Boxid]
   self:SetImage(self.ShowIma,image)
   self.ShowIma:GetComponent("Image"):SetNativeSize()
    for i = 1, 4 do
        local parent = self:FindChild("UI/Effect/Effect_qipao"..i)
        local tran1 = parent:FindChild("qipao01/qipao/Image")
        if i == 1 then
            parent:FindChild("qipao01/qipao/Text").text = self.TipTest[self.Boxid][1]
        elseif i == 3 then 
            parent:FindChild("qipao01/qipao/Text").text = self.TipTest[self.Boxid][2]
        end
        
        local tran2 = self:FindChild("UI/Bg/Image/Window/Content/"..i)
      
        if prop[i] then
            parent:SetActive(true)
            self:SetImage(tran1,prop[i])
            tran1:GetComponent("Image"):SetNativeSize()
            tran2:SetActive(true)
            self:SetImage(tran2,prop[i])
            tran2:GetComponent("Image"):SetNativeSize()
        else
            parent:SetActive(false)
            tran2:SetActive(false)
        end
    end
end

function PayGiftView:ReqLottery()
    CC.ViewManager.ShowConnecting()
   CC.Request("ReqGetRechargeActivityReward",{RewardTarget = self.BoxData[self.Boxid].rewardTar})
end

function PayGiftView:StartLottery(Rewards)
    CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, false)
    self:SetCanClick(false)
    self.Effect_zhuanDong:SetActive(true)
    self.ShowIma:SetActive(false)
    self:Run(10,Rewards)
end

function PayGiftView:Run(Time,Rewards)
    self.LotteryIndex = self.LotteryIndex > table.length(self.Props[self.Boxid]) and 1 or self.LotteryIndex
    local NextObj = self.WindContent:FindChild(tostring(self.LotteryIndex))
    self:RunAction(NextObj,{"localMoveBy",0,-500,0.2,function()
        Time = Time -1
        self.LotteryIndex = self.LotteryIndex +1
        NextObj.localPosition = Vector3(0,200,0) 
        if Time > 1 then
            self:Run(Time,Rewards)
        else
            self.LotteryIndex = self.LotteryIndex > table.length(self.Props[self.Boxid]) and 1 or self.LotteryIndex
            NextObj = self.WindContent:FindChild(tostring(self.LotteryIndex))
            self:SetImage(NextObj,self.propfg[Rewards[1].ConfigId].Icon)
            NextObj:GetComponent("Image"):SetNativeSize()
            self.Effect_zhuanDong:SetActive(false)
            self:RunAction(NextObj,{"localMoveTo",0,0,0.5,function()
                self:SetCanClick(true)
                self.LotteryIndex = 1
                NextObj.localPosition = Vector3(0,0,0)  
                CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, true)
                CC.ViewManager.OpenRewardsView({items = Rewards,callback = function ()
                    if CC.uu.IsNil(self.transform) then return end
                    NextObj.localPosition = Vector3(0,200,0)
                    self.ShowImages[self.Boxid] = self.propfg[Rewards[1].ConfigId].Icon
                    CC.LocalGameData.SetDataByKey("PayGiftView",CC.Player.Inst():GetSelfInfoByKey("Id")..self.Boxid,self.propfg[Rewards[1].ConfigId].Icon)
                    self:SetImage(self.ShowIma,self.ShowImages[self.Boxid])
                    self.ShowIma:GetComponent("Image"):SetNativeSize()
                    self.ShowIma:SetActive(true)
                    self:RefreshBox(self.Boxid,false)
                    self.BoxData[self.Boxid].isCanGet = false
                    self:CheckNextBox()
                    if Rewards[1].ConfigId == CC.shared_enums_pb.EPC_BeiHaiJuYaoer_Headset then
                        CC.ViewManager.Open("MailView")
                    end
                end})
            end})
        end
    end})
end

function PayGiftView:CheckNextBox()
   local index = nil
   for i,v in ipairs(self.BoxData) do
       if v.isCanGet then
           index = i
           break
       end
   end
   if index then
       self:OnClickBox(index)
   else
       self.LotteryBtn:FindChild("Normal"):SetActive(false)
       self.LotteryBtn:FindChild("Gray"):SetActive(true)
   end
end

function PayGiftView:ShowRankPanel(datas)
    if table.isEmpty(datas) then return end
    for i,v in ipairs(datas) do
        local Item = CC.uu.newObject(self.RankItem,self.RankContent)
        Item:SetActive(true)
        Item.name = i
        Item:FindChild("rank").text = i
        Item:FindChild("info/name").text = v.Name
        Item:FindChild("info/bg/ls").text = v.Score
        self:SetImage(Item:FindChild("reward"),self:GetRewardIcon(i))
        local param = {}
        param.parent =  Item:FindChild("txnode")
        param.playerId = v.PlayerId
        param.vipLevel = v.Vip
        param.portrait = v.Portrait
        param.headFrame = v.Background
        param.clickFunc = "unClick"
        self:SetHeadIcon(param,i)
    end
    local list = {}
    for i=1,3 do
       if datas[i] then
            local data = datas[i]
            table.insert(list,data)
            local obj = self:FindChild("RankPanel/Panel/No"..i)
            obj:SetActive(true)
            obj:FindChild("name/Text").text = data.Name
            local param = {}
            param.parent =  obj:FindChild("txnode")
            param.playerId = data.PlayerId
            param.vipLevel = data.Vip
            param.portrait = data.Portrait
            param.headFrame = data.Background
            param.clickFunc = "unClick"
            self:SetHeadIcon(param,#datas +1)
       end
    end
    self.RankIcon = CC.RankIconManager.CreateDiffRankIcon({parent = self:FindChild("RankPanel/BtnNode"),data = list ,clickFunc = function(btnTran)
        self:OnClickRank(btnTran)
    end})
end

function PayGiftView:SetHeadIcon(param,i)
    local HeadIcon = CC.HeadManager.CreateHeadIcon(param)
    table.insert(self.IconTab,HeadIcon)
end

function PayGiftView:GetRewardIcon(rank)
    local icon = nil
    if rank == 1 then
        icon = "prop_img_20035"
    elseif rank == 2 then
        icon = "prop_img_20036"
    elseif rank == 3 then
        icon = "prop_img_20037"
    elseif rank >= 4 and rank <= 6 then
        icon = "prop_img_10003"
    elseif rank >= 7 and rank <= 10 then
        icon = "prop_img_10002"
    end
    return icon
end

function PayGiftView:OnClickRank(btnTran)
    local Mask = self:FindChild("RankPanel/Mask")
    local RankPanel = self:FindChild("RankPanel/Panel")
    local BtnNode = self:FindChild("RankPanel/BtnNode")
    if self.isShowPanel then
        RankPanel.localPosition = Vector3(1100,-30,0)
        BtnNode.localPosition = Vector3(600,-6,0)
        btnTran.localScale = Vector3(1,1,1)
    else
        RankPanel.localPosition = Vector3(294,-30,0)
        BtnNode.localPosition = Vector3(-98,-6,0)
        btnTran.localScale = Vector3(-1,1,1)
    end
    self.isShowPanel = not self.isShowPanel
    Mask:SetActive(self.isShowPanel)
end

function PayGiftView:RefreshView(data)
    local startTime = os.date("%d/%m %H:%M",data.StartStamp)
    local stopTime = os.date("%d/%m %H:%M",data.EndStamp) or startTime
    self.TimeTxt.text = string.format(self.language.ActTime,startTime.." - "..stopTime)
    self.Ls.text = data.Recharge.."฿"
    self.Recharge = data.Recharge
    self.Progress.value = data.Recharge <=10000 and data.Recharge / 10000 or 1
    local index = nil
    for i,v in ipairs(data.RewardTargets) do
        local Flag = bit.band(data.AlreadyGetFlag,math.pow(2,i-1))
        if not self.BoxData[i] then
            self.BoxData[i] = {}
        end
        self.BoxData[i].isCanGet = (Flag == 0 and data.Recharge >= v) and true or false
        self.BoxData[i].rewardTar = v
        self:RefreshBox(i, Flag == 0)
        self:FindChild("UI/Progress/Num"..i).text = tostring(v).."฿"
        if index == nil and self.BoxData[i].isCanGet then
            index = i
        end
    end
    if index then
        self:OnClickBox(index)
    else
        self:OnClickBox(self.Boxid)
    end
end

function PayGiftView:RefreshBox(index,isCanGet)
    local effect = self:FindChild("Btn/Box/Box"..index.."/effect")
    effect:FindChild("Baoxiang"):SetActive(isCanGet)
    effect:FindChild("BaoxiangOpen"):SetActive(not isCanGet)
end

function PayGiftView:ActionIn()
    self:SetCanClick(false);
    self.transform.size = Vector2(125, 0)
	self.transform.localPosition = Vector3(-125 / 2, 0, 0)
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function PayGiftView:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
        });
    self:Destroy()
end

function PayGiftView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil;
    end
    if self.RankIcon then
        CC.RankIconManager.DestroyIcon(self.RankIcon)
        self.RankIcon = nil
    end
    for i,v in pairs(self.IconTab) do
        if v then
          v:Destroy()
          v = nil
      end
    end
    local state = false 
    for i,v in ipairs(self.BoxData) do
        if v.isCanGet then
            state = v.isCanGet
            break
        end
    end
    CC.HallNotificationCenter.inst():post(CC.Notifications.PayGiftGetState, state)
    CC.HallNotificationCenter.inst():post(CC.Notifications.GiftCollectionClickState, true)
end

return PayGiftView