local CC = require("CC")
local InviteLotteryView = CC.uu.ClassView("InviteLotteryView")

function InviteLotteryView:ctor(param)
	self:InitVar(param);
end

function InviteLotteryView:InitVar(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    self.LotCountOld = 0
    self.LotCountNew = 0
    self.OldObj = {}
    self.NewObj = {}
    self.RecordItems = {}
    self.HeadTab = {}
    --每个盒子奖励配置，道具id 跟 count 都要跟服务器返回的对上号，否则无法进行抽奖动画
    local enums_pb = CC.shared_enums_pb
    self.RewardCfg = {{{id = enums_pb.EPC_New_GiftVoucher,count = 50},{id = enums_pb.EPC_AnniRaffleTicket,count = 1},{id = enums_pb.EPC_New_GiftVoucher,count = 100},{id = enums_pb.EPC_ChouMa,count = 25000},{id = enums_pb.EPC_50Card,count = 1}},
                      {{id = enums_pb.EPC_New_GiftVoucher,count = 100},{id = enums_pb.EPC_AnniRaffleTicket,count = 2},{id = enums_pb.EPC_New_GiftVoucher,count = 200},{id = enums_pb.EPC_ChouMa,count = 50000},{id = enums_pb.EPC_50Card,count = 1}},
                     }
    self.needReportProp = {enums_pb.EPC_50Card,enums_pb.EPC_AnniRaffleTicket}
end

function InviteLotteryView:OnCreate()
	self:InitNode()
    self:InitClickEvent()
    self:InitView()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()

    local param = {}
    param.parent = self:FindChild("Lottery/Image/MarqueeNode")
    param.TextPos = 1.5
    param.ImageBgSize = {w = 620,h = 40}
    param.ReportEnd = function() CC.Request("ReqFreeAwardList",{PlayerID = self.viewCtr.myId}) end
    self.Marquee = CC.uu.CreateHallView("Marquee",param)

    self.chipCounter = CC.HeadManager.CreateChipCounter({parent = self:FindChild("ChipNode"),hideBtnAdd = true})
    self.integralCounter = CC.HeadManager.CreateIntegralCounter({parent = self:FindChild("IntegralNode"),hideBtnAdd = true})

    CC.Sound.PlayHallEffect("qhjl.ogg")

    if self.param.enterFunc then
        self.param.enterFunc()
    end
end

function InviteLotteryView:InitNode()
    for i = 1, 2 do
        local node = i==1 and "Old" or "New"
        local tempParent = self:FindChild("Lottery/Image/"..node)
        self:AddClick(tempParent:FindChild("Btn"),function() self:ReqLottery(node) end,nil,true)
        tempParent:FindChild("Image/Text").text = self.language["Invite"..i]

        local tempTab = i==1 and self.OldObj or self.NewObj
        for j,v in ipairs(self.RewardCfg[i]) do
            local image = tempParent:FindChild(j.."/Image")
            self:SetImage(image,"prop_img_"..v.id) 
			image:GetComponent("Image"):SetNativeSize()
            tempParent:FindChild(j.."/Text").text = "x"..v.count
            table.insert(tempTab,tempParent:FindChild(j.."/select"))
        end
        self["LotTex"..node] = tempParent:FindChild("Btn/Text")
        self["LotTipTex"..node] = tempParent:FindChild("Image/Text")
        self:RefreshLotTex(node)
    end

    self.RecordPanel = self:FindChild("RecordPanel")
    self.recordItme = self.RecordPanel:FindChild("Content/Scroll View/Viewport/record")
    self.recordParent = self.RecordPanel:FindChild("Content/Scroll View/Viewport/Content")
    self.notRecord = self.RecordPanel:FindChild("Content/Scroll View/Viewport/NotRecord")
end

function InviteLotteryView:InitClickEvent()
    self:AddClick("CloseBtn","Destroy",nil,true)
    self:AddClick("InviteBtn","OnInvite",nil,true)
    self:AddClick("RecordBtn","OpenRecord",nil,true)
    self:AddClick("RecordPanel/Content/Close","CloseRecord",nil,true)
    self:AddClick("ExplainBtn","OnExplain",nil,true)
    self:AddClick("Ticket/Image","ToAnniversaryTurntableView")
end

function InviteLotteryView:InitView()
    self:FindChild("Lottery/Image/Time").text = self.language.Time
    self:FindChild("InviteBtn/Text").text = self.language.Invite
    self:FindChild("RecordBtn").text = self.language.InviteRecord
    self:FindChild("RecordPanel/Content/Title/Image/Text").text = self.language.InviteRecord
    self:FindChild("RecordPanel/Content/Scroll View/Viewport/NotRecord").text = self.language.NotRecord
    self:FindChild("RecordPanel/Content/Tip").text = self.language.Tip1

    self:RefreshTicketCount()
end

function InviteLotteryView:ReqLottery(node)
    if self["LotCount"..node] <= 0 then
        CC.ViewManager.ShowTip(self.language.notLotNum)
        return 
    end
    if not self.isCanClick then return end

    self.isCanClick = false
    CC.Request("ReqFreeLottery",{PlayerID = self.viewCtr.myId,Type = node == "Old" and 2 or 1})
end

function InviteLotteryView:StartLottery(node,reward)

    self["LotCount"..node] = self["LotCount"..node] - 1 <= 0 and 0 or self["LotCount"..node] - 1
    self:RefreshLotTex(node)

    self:SetCanClick(false)
    local tempTab = node == "Old" and self.OldObj or self.NewObj
    self:Turn({RewardObj = tempTab,ObjIndex = 1,TurnTime = 0,TargetTime = 20 + reward[1].Block,interval = 0.01,reward = reward})
end

function InviteLotteryView:Turn(param)
    if CC.uu.IsNil(self.transform) then return end
    param.RewardObj[param.ObjIndex]:SetActive(true)
    CC.Sound.PlayHallEffect("LotterySelect")
    local last = param.ObjIndex - 1 == 0 and #param.RewardObj or param.ObjIndex - 1
    param.RewardObj[last]:SetActive(false)
    param.TurnTime = param.TurnTime + 1
    if param.TurnTime == param.TargetTime then
            --选中光圈闪烁
            self:RunAction(param.RewardObj[param.ObjIndex],
            {{"fadeToAll", 0, 0.1},
            {"fadeToAll", 255, 0.1},
            {"fadeToAll", 0, 0.1},
            {"fadeToAll", 255, 0.1},
            {"fadeToAll", 0, 0.1},
            {"fadeToAll", 255, 0.1,function()
                self:DelayRun(param.interval + 0.3,function()
                    self:SetCanClick(true)
                    CC.ViewManager.OpenRewardsView({items = param.reward,callback = function()
                        if CC.uu.IsNil(self.transform) then return end
                        param.RewardObj[param.ObjIndex]:SetActive(false)

                        if param.reward[1].ConfigId == CC.shared_enums_pb.EPC_AnniRaffleTicket then
                            self:RefreshTicketCount()
                        end
                        --自己中奖走马灯播报
                        if self.viewCtr:GetIsReport(param.reward[1].ConfigId) then 
                            self.viewCtr:OnReport(param.reward[1].ConfigId,CC.Player.Inst():GetSelfInfoByKey("Nick"),true)
                        end
                    end})
                end)
            end}
            })
        return
    else
        param.ObjIndex = param.ObjIndex + 1 > #param.RewardObj and 1 or param.ObjIndex + 1
    end

    if param.TurnTime < param.TargetTime/2 then
        param.interval = param.interval - 0.001 <= 0 and 0.001 or param.interval - 0.001
    else
        param.interval = param.interval + 0.015
    end
    self:DelayRun(param.interval,self.Turn,self,param)
end

function InviteLotteryView:RefreshLotTex(node,isUpLimit)
    self["LotTex"..node].text = string.format(self.language.Count,self["LotCount"..node])

    if isUpLimit then
        self["LotTipTex"..node].text = self.language.InviteLimit
    end
end

function InviteLotteryView:OnInvite()
    local param = {}
    param.imgName = "share_invite"
    param.extraData = {gameId = 1,inviteUserId = CC.Player.Inst():GetSelfInfoByKey("Id")}
    CC.ViewManager.Open("ImageShareView",param)
end

function InviteLotteryView:OnExplain()
    local data = {
		title = self.language.title,
		content = self.language.content,
	}
	CC.ViewManager.Open("CommonExplainView", data)
end

function InviteLotteryView:ToAnniversaryTurntableView()
    -- CC.ViewManager.Open("AnniversaryTurntableView")
    self:Destroy()
end

function InviteLotteryView:OpenRecord()
    self:SetCanClick(false)
    self.RecordPanel:SetActive(true)
    local node = self.RecordPanel:FindChild("Content")
    node.transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(node, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
            self:SetCanClick(true);
    end})
end

function InviteLotteryView:CloseRecord()
    self:SetCanClick(false);
    self:RunAction(self.RecordPanel:FindChild("Content"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
            self:SetCanClick(true);
            self.RecordPanel:SetActive(false)
    end})
end

function InviteLotteryView:RefreshTicketCount()
    local Ticket = CC.Player.Inst():GetSelfInfoByKey("EPC_AnniRaffleTicket") or 0
    self:FindChild("Ticket/Text").text = Ticket < 999999 and Ticket or 999999
end

function InviteLotteryView:ShowRecord(data)
    
    if self.notRecord.activeSelf then self.notRecord:SetActive(false) end

    for i,v in ipairs(data.InviteList) do
        local obj = self.RecordItems[i]
        if not obj then
            obj = CC.uu.newObject(self.recordItme, self.recordParent)
            table.insert(self.RecordItems,obj)
        end
        obj:FindChild("Image"):SetActive(i % 2 > 0)
        obj:FindChild("time").text = v.Time
        obj:FindChild("nick").text = v.PlayerName
        obj:FindChild("userType").text = v.Type == 1 and self.language.NewUser or self.language.OldUser
        obj:FindChild("reward").text = v.GetAwardType == 1 and self.language.Reward or self.language.RewardLimit
        
        self:SetHeadIcon({parent = obj:FindChild("headNode"),playerId = v.PlayerID,vipLevel = v.vipLevel,portrait = v.Avatar,headFrame = v.AvatarFrame})

        if not obj.activeSelf then obj:SetActive(true) end
    end
end

function InviteLotteryView:SetHeadIcon(param)
    local HeadIcon = CC.HeadManager.CreateHeadIcon(param)
    table.insert(self.HeadTab,HeadIcon)
end

function InviteLotteryView:ActionIn()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0},
			{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
		});
end

function InviteLotteryView:OnDestroy()
    CC.Sound.StopEffect()
    if self.param.closeFunc then
        self.param.closeFunc(self.LotCountOld > 0 or self.LotCountNew > 0)
    end
    
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
    if self.Marquee then
        self.Marquee:Destroy()
        self.Marquee = nil
    end
    if self.integralCounter then
		self.integralCounter:Destroy()
		self.integralCounter = nil
	end
    if self.chipCounter then
		self.chipCounter:Destroy()
		self.chipCounter = nil
	end
    for i,v in pairs(self.HeadTab) do
        if v then
          v:Destroy()
          v = nil
        end
    end
end

return InviteLotteryView    