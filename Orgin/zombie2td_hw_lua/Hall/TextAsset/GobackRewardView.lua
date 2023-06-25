local CC = require("CC")
local GobackRewardView = CC.uu.ClassView("GobackRewardView")

function GobackRewardView:ctor(param)
	self:InitVar(param);
end

function GobackRewardView:InitVar(param)
    self.param = param or {}
    self.language = self:GetLanguage()
    self.wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
    self.proplanguage = CC.LanguageManager.GetLanguage("L_Prop")
    self.isFirOpen = CC.LocalGameData.GetLocalDataToKey("GobackRewardGobackReward", CC.Player.Inst():GetSelfInfoByKey("Id"))
    self.countDown = 0
    self.totalLose = 0
    self.detailItem = {}
    self.giftItem = {}
    --不同VIP前3个任务对应不同数量的筹码奖励，现分成6个VIP梯度
    self.vipList = {{0,0},{1,2},{3,9},{10,14},{15,19},{20,30}} 
    --不同梯度筹码数量
    self.chipCfg = {{2500/2,10000/2,30000/2,100000/2,500000/2,1000000/2},  --登录即得
                    {5000/2,20000/2,60000/2,200000/2,1000000/2,2000000/2}, --次日登录
                    {2500/2,10000/2,30000/2,100000/2,500000/2,1000000/2},  --分享
                   }
    local chip1 = self:VIPChip(1)
    local chip2 = self:VIPChip(2)
    local chip3 = self:VIPChip(3)
    --7个任务的配置
    self.Rewardcfg = {{taskId = 1,id = 2,count = chip1,canReceive = false,isComplete = false,taskdesc = self.language.LoginGet,
                       content = "0/1",reward = {{r_id = 2,r_count = "x"..chip1}}
                      },
                      {taskId = 6,id = 2,count = chip2,canReceive = false,isComplete = false,taskdesc = self.language.LoginAgain,
                       content = "0/1",reward = {{r_id = 2,r_count = "x"..chip2}}
                      },
                      {taskId = 7,id = 2,count = chip3,canReceive = false,isComplete = false,taskdesc = self.language.Share1,
                       content = "0/1",reward = {{r_id = 2,r_count = "x"..chip3}}
                      },
                      {taskId = 2,id = 2,count = 20000,canReceive = false,isComplete = false,taskdesc = self.language.GameCost,
                       content = "0/10000000",totalLose = 1e7,reward = {{r_id = 2,r_count = "x20000"}}
                      },
                      {taskId = 3,id = 2,count = 300000,canReceive = false,isComplete = false,taskdesc = self.language.GameCost,
                       content = "0/100000000",totalLose = 1e8,reward = {{r_id = 2,r_count = "x300000"}}
                      },
                      {taskId = 4,id = "hglb_lb_icon01",count = "390000",canReceive = false,isComplete = false,taskdesc = self.language.Discount,
                       content = self.proplanguage[2].." *390000",wareId = "30240",tipTex = string.format(self.language.Value,50,100),
                       reward = {{r_id = 2,r_count = "x390000"}}
                      },
                      {taskId = 5,id = "hglb_lb_icon02",count = "2550000",canReceive = false,isComplete = false,taskdesc = self.language.Discount,
                       content = self.proplanguage[2].." *2550000",wareId = "30241",tipTex = string.format(self.language.Value,300,600),
                       reward = {{r_id = 2,r_count = "x2550000"}}
                      },
                     }
end

function GobackRewardView:OnCreate()
    self:EffectDispose()
    self:InitView()
    self:InitClickEvent()
    self.viewCtr = self:CreateViewCtr(self.param)
    self.viewCtr:OnCreate()
    
    self.walletView = CC.uu.CreateHallView("WalletView",{parent = self.transform,notBuyGift = true})
    
    CC.LocalGameData.SetLocalDataToKey("GobackRewardGobackReward", CC.Player.Inst():GetSelfInfoByKey("Id"))
    if self.isFirOpen then
        self:FindChild("Framg/Effect"):SetActive(true)
        CC.Sound.PlayHallEffect("ZNQ3")
    end
    
    self:CountDown()
    self:Animation(self.leftArrow)
    self:Animation(self.rightArrow)
    self:ShowTipTex()
end

function GobackRewardView:EffectDispose()
    --获取裁剪区域左下角和右上角的世界坐标
    local viewport = self:FindChild("Framg/Scroll View/Viewport");
    local wordPos = viewport:GetComponent("RectTransform"):GetWorldCorners()
    local minX = wordPos[0].x;
    local minY = wordPos[0].y;
    local maxX = wordPos[2].x;
    local maxY = wordPos[2].y;
    --把坐标传入shader(maskParticle.shader，maskShine.shader)
    local path = "Framg/Scroll View/Viewport/Gifts/%s/Icon"
    for i = 1, 7 do
        local particleParent = self:FindChild(string.format(path, i));
        particleParent:FindChild("saoguang"):SetActive(true)
        local particleComps = particleParent:GetComponentsInChildren(typeof(UnityEngine.UI.Image));
        if particleComps then
            for i,v in ipairs(particleComps:ToTable()) do
                v.material:SetFloat("_MinX",minX);
                v.material:SetFloat("_MinY",minY);
                v.material:SetFloat("_MaxX",maxX);
                v.material:SetFloat("_MaxY",maxY);
            end
        end
        particleParent:FindChild("saoguang"):SetActive(false)
    end
    
end

function GobackRewardView:CountDown()
    self:StartTimer("countDown",1,function()
        if self.countDown > 0 then
            self.countDown = self.countDown - 1 
            local str = (self.countDown > 0 and CC.uu.TicketFormat2(self.countDown) or "00:00:00"):split(":")
            self.TimeTex.text = string.format(self.language.Time, str[1],str[2],str[3])

            if self.countDown <= 0 then
                if self.param.closeFunc then
                    self.param.closeFunc(false,false)
                end
            end
        end
    end,-1)
end

function GobackRewardView:Animation(tran)
    self:RunAction(tran,{"scaleTo", 0.8,0.8, 0.5,function()
        self:RunAction(tran,{"scaleTo", 1,1, 0.5,function()
            self:Animation(tran)
        end})
    end})
end

function GobackRewardView:InitClickEvent()
    self:AddClick("Framg/CloseBtn","Close",nil,true)
    self:AddClick("Framg/ReceiveBtn","OnReceiveBtn",nil,true)
    self:AddClick("Framg/GrayBtn","OnGrayFun",nil,true)
    self:AddClick("Framg/TipBtn","ShowTipTex",nil,true)
    self:AddClick(self.leftArrow:FindChild("Obj"),function() self:ClickArrow(true) end)
    self:AddClick(self.rightArrow,function() self:ClickArrow(false) end)
end

function GobackRewardView:InitView()
    self:FindChild("Framg/TipImage/Text").text = self.language.tip
    for i,v in ipairs(self.Rewardcfg) do
        table.insert(self.detailItem,self:FindChild("Framg/Detail/"..i))
        table.insert(self.giftItem,self:FindChild("Framg/Scroll View/Viewport/Gifts/"..i))

        self:SetImage(self.giftItem[i]:FindChild("Icon"),type(v.id) == "string" and v.id or "prop_img_"..v.id)
		self:SetImage(self.giftItem[i]:FindChild("Icon/saoguang"),type(v.id) == "string" and v.id or "prop_img_"..v.id)
        self.giftItem[i]:FindChild("Icon").sizeDelta = v.size or Vector2(128,128)
        self.giftItem[i]:FindChild("Icon/saoguang").sizeDelta = v.size or Vector2(128,128)
        self.giftItem[i]:FindChild("Count").text = v.count
        self.giftItem[i]:FindChild("Text").text = string.format(self.language.Surprice,i)
        self.giftItem[i]:FindChild("Receflag/Text").text = self.language.Geted

        self.detailItem[i]:FindChild("Task").text = v.taskdesc
        self.detailItem[i]:FindChild("Content").text = v.content
        local rew = self.detailItem[i]:FindChild("Reward/Item")
        local parent = self.detailItem[i]:FindChild("Reward")
        for j,k in ipairs(v.reward) do
            local obj = CC.uu.newObject(rew,parent)
            self:SetImage(obj:FindChild("Icon"),type(k.r_id) == "string" and k.r_id or "prop_img_"..k.r_id)
            obj:FindChild("Icon").sizeDelta = k.r_size or Vector2(90,90)
            obj:FindChild("Count").text = k.r_count
            obj:SetActive(true)
        end
        
        UIEvent.AddToggleValueChange(self.giftItem[i],function(selected) if selected then self:OnRewardBtn(i)end end)

        self:AddClick(self.giftItem[i]:FindChild("btn"),function() CC.ViewManager.ShowTip(self.language.AlreaReceive) end)
    end

    self.scrollRect = self:FindChild("Framg/Scroll View"):GetComponent("ScrollRect")
    UIEvent.AddScrollRectOnValueChange(self:FindChild("Framg/Scroll View"),function(v)
        self.leftArrow:SetActive(v.x > 0)
        self.rightArrow:SetActive(v.x < 1)
    end)

    self.TimeTex = self:FindChild("Framg/Time")
    self.leftArrow = self:FindChild("Framg/LeftBtn")
    self.rightArrow = self:FindChild("Framg/RightBtn")
end

function GobackRewardView:OnRewardBtn(index)
    self.curId = index
    local cfg = self.Rewardcfg[index]
    local state = cfg.canReceive
    if index == 1 or index == 2 or index == 4 or index == 5 then
        state = state and cfg.isComplete
    end
    self:FindChild("Framg/ReceiveBtn"):SetActive(state)
    self:FindChild("Framg/GrayBtn"):SetActive(not state)
    self:FindChild("Framg/ReceiveBtn/Tip"):SetActive(index >= 6)
    self:FindChild("Framg/ReceiveBtn/Group/Image"):SetActive(index >= 6)
    self:FindChild("Framg/ReceiveBtn/Group/Text").text = index >= 6 and self.wareCfg[cfg.wareId].Price or (index == 3 and self.language.Share2 or self.language.Get)
    self:FindChild("Framg/GrayBtn/Text").text = index == 3 and self.language.Share2 or self.language.Get

    if cfg.tipTex then self:FindChild("Framg/ReceiveBtn/Tip/Text").text = cfg.tipTex end
end

function GobackRewardView:OnAllFinish()
    self:FindChild("Framg/ReceiveBtn"):SetActive(false)
    self:FindChild("Framg/GrayBtn"):SetActive(true)
end

function GobackRewardView:OnReceiveBtn()

    if not self.isCanClick then return end --请求没返回，不允许点击

    local cfg = self.Rewardcfg[self.curId]
    if not cfg or not cfg.canReceive then return end
    if (self.curId == 1 or self.curId == 2 or self.curId == 4 or self.curId == 5) and not cfg.isComplete then return end

    if self.curId == 3 then
        local param = {}
        param.imgName = "share_1_9"
        param.shareCallBack = function()
            CC.Request("ReqOldPlayerReturnShare",nil,function()
                self.isCanClick = false
                CC.Request("ReqSendReturnReward",{Stage = cfg.taskId}) -- 请求领奖
            end)
        end
        CC.ViewManager.Open("ImageShareView", param)
    elseif self.curId == 6 or self.curId == 7 then
        if CC.Player.Inst():GetSelfInfoByKey("EPC_ZuanShi") >= self.wareCfg[cfg.wareId].Price then
            self.isCanClick = false
            CC.Request("ReqBuyWithId",{WareId = cfg.wareId, ExchangeWareId = cfg.wareId})
        else
            if self.walletView then
                self.walletView:SetBuyExchangeWareId(cfg.wareId)
                self.walletView:PayRecharge()
            end
        end
    else
        self.isCanClick = false
        CC.Request("ReqSendReturnReward",{Stage = cfg.taskId})
    end
end

function GobackRewardView:OnGrayFun()
    local cfg = self.Rewardcfg[self.curId]
    if not cfg then return end
    if not cfg.isComplete then 
        CC.ViewManager.ShowTip(self.language.notComplete)
    elseif not cfg.canReceive then
        CC.ViewManager.ShowTip(self.language.AlreaReceive)
    end
end

function GobackRewardView:ClickArrow(isLeft)
    local change =  isLeft and -0.5 or 0.5
    
    self.scrollRect.horizontalNormalizedPosition = Mathf.Clamp(self.scrollRect.horizontalNormalizedPosition + change,0,1)
end

function GobackRewardView:ShowTipTex()
    if self.co then return end
    self:FindChild("Framg/TipImage"):SetActive(true)
    self.co = self:DelayRun(3,function()
        self:FindChild("Framg/TipImage"):SetActive(false)
        self.co = nil
    end)
end

function GobackRewardView:ShowProgress(index,flow)
    if index == 4 or index == 5 then
        self.detailItem[index]:FindChild("Content").text = flow.."/"..self.Rewardcfg[index].totalLose
    elseif index <= 3 then
        self.detailItem[index]:FindChild("Content").text = self.Rewardcfg[index].isComplete and "1/1" or "0/1"
    end
end

function GobackRewardView:SetTaskState(index,state,isClick)
    self.Rewardcfg[index].canReceive = state

    self.giftItem[index]:FindChild("Receflag"):SetActive(not state)
    self.giftItem[index]:FindChild("btn"):SetActive(not state)

    local toggle = self.giftItem[index]:GetComponent("Toggle")
    toggle.interactable = state

    if isClick ~= nil then toggle.isOn = isClick end
end

function GobackRewardView:VIPChip(key)
    local curVip = CC.Player.Inst():GetSelfInfoByKey("EPC_Level")
   
    local chip = self.chipCfg[key]
    for i,v in ipairs(self.vipList) do
        if curVip >= v[1] and curVip <= v[2] then
            return chip[i]
        end
    end
    return chip[1]
end

function GobackRewardView:Close()
    if self.isFirOpen then
        self:FindChild("Framg/Effect"):SetActive(false)
        CC.Sound.StopEffect()
        local hallview = CC.ViewManager.GetReplaceView()
        hallview:SetCanClick(false)
        hallview:OnFocusIn()
        self:FindChild("MovePos").transform.position = hallview.GobackBtn.transform.position
        local pos = self:FindChild("MovePos").transform.localPosition
        self:SetCanClick(false);
        self:FindChild("Mask"):SetActive(false)
        if self.walletView then
            self.walletView:SetActive(false)
        end
        self:RunAction(self.transform, {"spawn",{"localMoveTo", pos.x,pos.y, 0.3},{"fadeToAll", 0.3, 0.3}, {"scaleTo", 0,0, 0.3,function ()
            self:Destroy()
            hallview:SetCanClick(true)
            end}})
    else
        self:ActionOut()
    end
end

function GobackRewardView:ActionIn()
	self:SetCanClick(false)
    self:FindChild("Framg").transform.localScale = Vector3(0.5,0.5,1)
    self:RunAction(self:FindChild("Framg"), {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()
    		self:SetCanClick(true);
    	end})
    CC.Sound.PlayHallEffect("click_boardopen");
end

function GobackRewardView:ActionOut()
	self:SetCanClick(false);
    self:RunAction(self:FindChild("Framg"), {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
    		self:Destroy();
    	end})
end

function GobackRewardView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end

    if self.walletView then
		self.walletView:Destroy()
	end
end

return GobackRewardView    