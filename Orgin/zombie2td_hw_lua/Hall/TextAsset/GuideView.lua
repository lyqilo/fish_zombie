local CC = require("CC")

local GuideView = CC.uu.ClassView("GuideView")

local MaskMode = {
    "_MASKMODE_ROUND",
    "_MASKMODE_RECTANGLE",
    "_MASKMODE_MORE",
    "_MASKMODE_NULL"
}

function GuideView:ctor(param)
    self.param = param;
	self.language = self:GetLanguage()
    self.gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game")
    self.WebUrlDataManager = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl")
    self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
    self.stepTranTab = {}
end

function GuideView:OnCreate()
	self.viewCtr = self:CreateViewCtr(self.param);
    self.viewCtr:OnCreate();
    --玩家类型：isDeepPlayer：重度用户，Organic：自然量用户
    self.PlayerType = self.gameDataMgr.GetPlayerType()
    --引导节点
    --1-8新手引导，10-13签到任务引导,20钱包道具,21,22实物夺宝,23比赛场碎片说明引导,24-27高级vip，30资讯，32-34改名卡
    self.stepTab = {1,2,3,4,5,6,7,8,10,11,12,13,20,22,21,23,24,25,26,27,30,32,33,34}
    self.breakBtn = false
    --高级vip界面的按钮
    self.agentBtnTab = nil
    self.twentyFiveStep = {}
	self:InitUI()
end

function GuideView:InitUI()
    -- self.canvas = self.transform:GetComponent("Canvas");

    self.mask = self:FindChild("mask")
    for _,v in pairs(MaskMode) do
        if self.mask:GetComponent("Image").material:IsKeywordEnabled(v) then
            self.MaskMode = v
        end
    end
    self.mask:GetComponent("Image").material:DisableKeyword(self.MaskMode)
    self.mask:GetComponent("Image").material:EnableKeyword("_MASKMODE_NULL")
    self.MaskMode = "_MASKMODE_NULL"

    for _,v in ipairs(self.stepTab) do
        self.stepTranTab[v] = self:FindChild(string.format("%d", v))
    end
    self:AddClick(self.stepTranTab[1]:FindChild("BoxBtn"), function ()
        self:StopTimer("GetTreasure")
        self.viewCtr:ReqSaveNewPlayerFlag(1)
    end)
    self:AddClick(self.stepTranTab[2]:FindChild("Btn"),function()
        self.viewCtr:ReqSaveNewPlayerFlag(2)
    end)
    self:AddClick(self.stepTranTab[3]:FindChild("1015"),function()
        self.viewCtr:EnterGame(1015)
    end)
    self:AddClick(self.stepTranTab[3]:FindChild("2003"),function()
        self.viewCtr:EnterGame(2003)
    end)
    self:AddClick(self.stepTranTab[3]:FindChild("3002"),function()
        self.viewCtr:EnterGame(3002)
    end)
    self:AddClick(self.stepTranTab[3]:FindChild("BtnBreak"),function()
        self:BreakGuide()
    end)
    for i = 4, 5 do
        local index = i
        if self.PlayerType == "isDeepPlayer" then
            self.stepTranTab[index]:FindChild("BtnNext/Image"):SetActive(false)
        end
        self:AddClick(self.stepTranTab[index]:FindChild("BtnNext"),function()
            if CC.ChannelMgr.CheckVivoChannel() and index == 4 then
                --vivo包没有限时合集
                index = 5
            end
            if index == 5 and self.PlayerType == "isDeepPlayer" then
                self.breakBtn = true
                self.viewCtr:ReqSaveNewPlayerFlag(8)
            else
                self.viewCtr:ReqSaveNewPlayerFlag(index)
            end
        end)
        self:AddClick(self.stepTranTab[index]:FindChild("BtnBreak"), function ()
            self:BreakGuide()
        end)
    end
    self:AddClick(self.stepTranTab[7]:FindChild("BtnGet"), function ()
        self.viewCtr:ReqSaveNewPlayerFlag(7)
    end)
    self:AddClick(self.stepTranTab[8]:FindChild("Arrow/RealStoreBtn"), function ()
        --实物商城
        self.viewCtr:ReqSaveNewPlayerFlag(8)
    end)

    --签到任务引导
    for i = 10, 12 do
        local index = i
        self:AddClick(self.stepTranTab[index]:FindChild("Btn"),function()
            if index == 11 then
                self.viewCtr:ReqSigninPlayerFlag()
            else
                self.viewCtr:ReqSaveNewPlayerFlag(index)
            end
        end)
    end
    self:AddClick(self.stepTranTab[13]:FindChild("step1/Btn"),function()
        self.stepTranTab[13]:FindChild("step1"):SetActive(false)
        self.stepTranTab[13]:FindChild("step2"):SetActive(true)
        CC.Sound.StopEffect()
        CC.Sound.PlayHallEffect("step13_1.ogg")
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnTreasureSwitch, 1)
    end)
    self:AddClick(self.stepTranTab[13]:FindChild("step2/Btn"),function()
        self.viewCtr:ReqSaveNewPlayerFlag(13)
    end)
    self:AddClick(self.stepTranTab[23]:FindChild("Btn"),function()
        self.viewCtr:ReqSaveSingleNewPlayerFlag(23)
    end)
    self:AddClick(self.stepTranTab[22]:FindChild("Btn"),function()
        self.viewCtr:ReqSaveSingleNewPlayerFlag(22)
    end)
    self:AddClick(self.stepTranTab[21]:FindChild("Btn"),function()
        self.viewCtr:ReqTreasureBuyFlag()
    end)
    self:AddClick(self.stepTranTab[20]:FindChild("Btn"),function()
        self.viewCtr:ReqTreasureAgentExFlag()
    end)
    --资讯引导
    self:AddClick(self.stepTranTab[30]:FindChild("Btn"), "VipThreeCard")
    self:AddClick(self.stepTranTab[30]:FindChild("Arrow/SendBtn"), "VipThreeCard")
    --改名卡引导
    self:AddClick(self.stepTranTab[32]:FindChild("Btn"), "OpenPersonalInfo")
    self:AddClick(self.stepTranTab[32]:FindChild("Arrow/Btn"), "OpenPersonalInfo")
    self:AddClick(self.stepTranTab[33]:FindChild("Arrow/Btn"), "OpenBackPack")
    self:AddClick(self.stepTranTab[34]:FindChild("bg/Btn"),function()
        self.viewCtr:ReqSaveSingleNewPlayerFlag(28)
    end)

    --高级Vip
    self:AddClick(self.stepTranTab[26]:FindChild("Arrow/Btn"), function()
        logError("领取收益")
        if self.param and self.param.ReceiveEarn then
            self.param.ReceiveEarn()
        end
        self.viewCtr:ReqSaveSingleNewPlayerFlag(26)
    end)
    for i = 1, 5 do
        local index = i
        self.twentyFiveStep[index] = self.stepTranTab[25]:FindChild(string.format("step%d", index))
        self:AddClick(self.twentyFiveStep[index]:FindChild(("Arrow/Btn")), function()
            self:TwentyFiveStep(index)
        end)
    end
    self:AddClick(self.stepTranTab[24]:FindChild("step1/Btn"), function()
        self.stepTranTab[24]:FindChild("step1"):SetActive(false)
        self.stepTranTab[24]:FindChild("step2"):SetActive(true)
        self:SetAgentBtnVector2(24, 2)
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnGuideStepAgent, {agentStep = 8})
    end)
    self:AddClick(self.stepTranTab[24]:FindChild("step2/Btn"), function()
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnGuideStepAgent, {agentStep = 9})
        self.viewCtr:ReqSaveSingleNewPlayerFlag(24)
    end)

    self:AddClick(self:FindChild("BgBtn"), function ()
        --点击bg
        self.viewCtr:ReqSaveNewPlayerFlag(6)
    end)
    self:FindChild("BgBtn"):SetActive(false)

    self:MaterialMoveScene()
    self:HandRandom()
    self:LanguageSwitch()
    self:InitViewShow()
end

--高亮材质移出场景
function GuideView:MaterialMoveScene()
    self.mask:GetComponent("Image").material:SetVector("_Center", Vector4(10000,0,0,0))
end

--手指随机显示位置
function GuideView:HandRandom()
    local rd = math.random(1, 3)
    self.stepTranTab[3]:FindChild("Effect_shouzhi").localPosition = Vector3(-300 + 260 * rd, -90, 0)
end

--语言切换
function GuideView:LanguageSwitch()
    for k, v in pairs(self.language) do
        if k ~= "breakSure" then
            self:FindChild(k).text = v
        end
    end
end

--初始界面显示
function GuideView:InitViewShow()
    if self.param then
        local singleFlag = self.param.singleFlag or 0
        if self.stepTranTab[singleFlag] then
            self.stepTranTab[singleFlag]:SetActive(true)
            if singleFlag == 32 then
                --需要打开背包界面，把层级设高
                -- self.canvas.sortingLayerName = "sort3"
                -- self.canvas.sortingOrder = 50
                self.mask:GetComponent("Image").material:EnableKeyword("_MASKMODE_ROUND")
                self.MaskMode = "_MASKMODE_ROUND"
            elseif singleFlag == 30 then
                CC.Sound.StopEffect()
                CC.Sound.PlayHallEffect("step30.ogg")
            elseif singleFlag >= 24 and singleFlag <= 27 then
                self.agentBtnTab = self.param.btnTab
                self:SetAgentBtnVector2(singleFlag, 1)
            elseif singleFlag == 21 or singleFlag == 20 then
                local v2 = self:GetVector2(self.param.btn)
                v2.y = v2.y + 30
				local data = {vect1 = v2, sizeX1 = 140, sizeY1 = 140, maskMode = "_MASKMODE_RECTANGLE"}
                data.flag = singleFlag
                self:SetHighlight(data)
            elseif singleFlag >= 10 and singleFlag <= 13 and singleFlag ~= 11 then
                CC.Sound.PlayHallEffect(string.format("step%d.ogg", singleFlag))
            end
            return
        end
    end
    --Flag:已经完成步骤
    local guideData = self.gameDataMgr.GetGuide()
    log(CC.uu.Dump(guideData.Flag,"flag",10))
    if guideData.state and guideData.Flag < 9 then
        if guideData.Flag < 1 then
            self:InitGuide()
        else
            if guideData.Flag == 3 and self.PlayerType == "Organic" and not self.agentDataMgr.GetAgentSatus() then
                --自然量用户，并且非高v
                self:OrganicGuide()
            else
                self:SetGuideStep(guideData.Flag + 1)
            end
        end
    else
        self:CloseView()
    end
end

function GuideView:InitGuide()
    CC.Sound.StopEffect()
    CC.Sound.PlayHallEffect("step1.ogg")
    if self.PlayerType == "isDeepPlayer" then
        self.viewCtr:ReqSaveNewPlayerFlag(0)
    end
    self.stepTranTab[1]:SetActive(true)
    local countDown = 9
    self:StartTimer("GetTreasure", 1, function()
		countDown = countDown - 1
        if countDown <= 0 then
            self.viewCtr:ReqSaveNewPlayerFlag(1)
            self:StopTimer("GetTreasure")
		end
    end, -1)
end

function GuideView:OrganicGuide()
    --推广线
    local Cb = function ()
        self:SetGuideStep(4)
    end
    CC.ViewManager.Open("AgentProxy", {callback = Cb})
end

function GuideView:SetGuideStep(flag)
    if flag > 1 and self.stepTranTab[flag - 1] then
        self.stepTranTab[flag - 1]:SetActive(false)
        if CC.ChannelMgr.CheckVivoChannel() and flag == 6 then
            self.stepTranTab[4]:SetActive(false)
        end
    end
    if flag == 2 and self.PlayerType == "isDeepPlayer" then
        ----重度用户
        self.gameDataMgr.SetGuide(3)
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyHallPos, 30)
        self.stepTranTab[30]:SetActive(true)
        return
    end
    self.stepTranTab[flag]:SetActive(true)
    CC.Sound.PlayHallEffect(string.format("step%d.ogg", flag))
    if flag == 4 or flag == 5 or flag == 8 then
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyHallPos, flag)
    elseif flag == 6 then
        self:MaterialMoveScene()
        self:FindChild("BgBtn"):SetActive(true)
        self.mask:SetActive(false)
    elseif flag == 7 then
        self:FindChild("BgBtn"):SetActive(false)
        self.mask:SetActive(true)
    end
end

function GuideView:OnNotifyHallFirst()
    --显示大厅按钮
    CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyHallFirst)
end

function GuideView:EightGuide()
    local fun = function ()
        local signOpen = CC.DataMgrCenter.Inst():GetDataByKey("NoviceDataMgr").GetNoviceDataByKey("NoviceSignInView").open
        if signOpen and not CC.DataMgrCenter.Inst():GetDataByKey("Game").GetSingleFlag(10) then
            CC.ViewManager.Open("GuideView", {singleFlag = 10})
            return
        end
        local param = {}
        param.closeFunc = function ()
            --请求竞技场信息
            CC.DataMgrCenter.Inst():GetDataByKey("ArenaData").GetGameArena()
        end
        CC.ViewManager.OpenEx("FreeChipsCollectionView",param)
	end
    if not self.breakBtn then
        CC.ViewManager.Open("TreasureView", {callback = fun})
    end

    self:CloseView()
end

function GuideView:BreakGuide()
    CC.ViewManager.OpenMessageBoxEx(self.language.breakSure,
            function()
                self.breakBtn = true
                self.viewCtr:ReqSaveNewPlayerFlag(8)
            end,
            function()
            end
        )
end

function GuideView:GuideFlag(flag)
    CC.Sound.StopEffect()
    if self.stepTranTab[flag] then
        self.stepTranTab[flag]:SetActive(false)
    end
    local isSingle = flag > 9 and true or false
    self.gameDataMgr.SetGuide(flag, isSingle)
    if flag < 8 then
        if flag ~= 3 then
            self:SetGuideStep(flag + 1)
        else
            self:CloseView()
        end
    elseif flag == 8 then
        self:EightGuide()
    elseif flag == 10 then
        CC.ViewManager.OpenAndReplace("FreeChipsCollectionView", {currentView = "NoviceSignInView"})
        self:CloseView()
    elseif flag == 11 then
        self.stepTranTab[12]:SetActive(true)
        CC.Sound.PlayHallEffect("step12.ogg")
    elseif flag == 12 then
        local fun = function ()
            local param = {}
            param.closeFunc = function ()
                --请求竞技场信息
                CC.DataMgrCenter.Inst():GetDataByKey("ArenaData").GetGameArena()
                if  CC.DataMgrCenter.Inst():GetDataByKey("Activity").GetActivityInfoByKey("FirstBuyGift").switchOn then
                    CC.ViewManager.Open("FirstBuyGiftView")
                end
            end
            param.currentView = "NewbieTaskView"
            CC.ViewManager.Open("FreeChipsCollectionView",param)
        end
        CC.ViewManager.OpenAndReplace("TreasureView", {OpenViewId = 2, guideFlag = 13, closeFunc = fun})
        self:CloseView()
    elseif flag == 13 or flag == 21 or flag == 20 then
        self:CloseView()
    end
end

--资讯直升卡引导
function GuideView:VipThreeCard()
    local fun = function ()
        if self.PlayerType == "isDeepPlayer" then
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyExitSelection)
            return
        end
        local param = {}
        param.closeFunc = function ()
            --请求竞技场信息
            CC.DataMgrCenter.Inst():GetDataByKey("ArenaData").GetGameArena()
        end
        CC.ViewManager.OpenEx("FreeChipsCollectionView",param)
    end
    CC.ViewManager.Open("GiveGiftSearchView", {guide = true, callback = fun})
    self.viewCtr:ReqSaveSingleNewPlayerFlag(30)
end

--打开个人资料面板
function GuideView:OpenPersonalInfo()
    local fun = function (btn)
		self.transform.parent = GameObject.Find("GNode/GCanvas/GExtend").transform
        self:OpenBackPackGuide()
        local param = {vect1 = self:GetVector2(btn), sizeX1 = 130, sizeY1 = 45, offset_y = 100, maskMode = "_MASKMODE_RECTANGLE"}
        param.flag = 33
        self:SetHighlight(param)
    end
    CC.ViewManager.Open("PersonalInfoView",{guideFun = fun})
end

function GuideView:OpenBackPackGuide()
    self.stepTranTab[32]:SetActive(false)
    self.stepTranTab[33]:SetActive(true)
end

--打开背包
function GuideView:OpenBackPack()
    self.mask:GetComponent("Image").material:DisableKeyword(self.MaskMode)
    self.mask:GetComponent("Image").material:EnableKeyword("_MASKMODE_NULL")
    self.MaskMode = "_MASKMODE_NULL"
    local fun = function (obj1,obj2)
        local v1 = self:GetVector2(obj1)
        local v2 = self:GetVector2(obj2)
        local param = {vect1 = v1, vect2 = v2, sizeX1 = 60, sizeY1 = 60, sizeX2 = 180, sizeY2 = 215, offset_y = 110, maskMode = "_MASKMODE_MORE"}
        param.flag = 34
        self:SetHighlight(param)
    end
    CC.ViewManager.OpenAndReplace("BackpackView",{guideFun = fun,SelectedID = CC.shared_enums_pb.EPC_Mod_Name_Card});
    self:BackpackGuide()
end

function GuideView:BackpackGuide()
    self.stepTranTab[33]:SetActive(false)
    self.stepTranTab[34]:SetActive(true)
end

--高v
function GuideView:TwentyFiveStep(index)
    if index == 5 then
        CC.ViewManager.Open("AgentShareView")
        self.viewCtr:ReqSaveSingleNewPlayerFlag(25)
    elseif index == 4 then
        self.stepTranTab[25]:SetActive(false)
        self.twentyFiveStep[4]:SetActive(false)
        self.mask:SetActive(false)
    else
        self.twentyFiveStep[index]:SetActive(false)
        self.mask:SetActive(false)
        self:DelayRun(1, function ( )
            self.twentyFiveStep[index + 1]:SetActive(true)
            self.mask:SetActive(true)
        end)
        self:SetAgentBtnVector2(25, index + 1)
        if index == 3 then
            local fun = function ()
                self.stepTranTab[25]:SetActive(true)
                self.twentyFiveStep[5]:SetActive(true)
                CC.HallNotificationCenter.inst():post(CC.Notifications.OnGuideStepAgent, {agentStep = 6})
                self.mask:SetActive(true)
                self:SetAgentBtnVector2(25, 5)
            end
            CC.ViewManager.Open("AgentEarningsView",{guideFun = fun})
        else
            CC.HallNotificationCenter.inst():post(CC.Notifications.OnGuideStepAgent, {agentStep = index + 2})
        end
    end
end

function GuideView:SetAgentBtnVector2(step, progress)
    local param = {}
    if step == 26 then
        param = {vect1 = self:GetVector2(self.agentBtnTab[2]), sizeX1 = 80, sizeY1 = 80, offset_y = 10, maskMode = "_MASKMODE_ROUND"}
    elseif step == 25 then
        if progress == 1 then
            param = {vect1 = self:GetVector2(self.agentBtnTab[1]), sizeX1 = 80, sizeY1 = 80, offset_y = 0, maskMode = "_MASKMODE_ROUND"}
        elseif progress == 2 then
            param = {vect1 = self:GetVector2(self.agentBtnTab[3]), sizeX1 = 80, sizeY1 = 80, offset_y = 0, maskMode = "_MASKMODE_ROUND"}
        elseif progress == 3 then
            param = {vect1 = self:GetVector2(self.agentBtnTab[4]), sizeX1 = 120, sizeY1 = 60, offset_y = -85, maskMode = "_MASKMODE_RECTANGLE"}
        elseif progress == 4 then
            self:MaterialMoveScene()
        elseif progress == 5 then
            param = {vect1 = self:GetVector2(self.agentBtnTab[9]), sizeX1 = 70, sizeY1 = 70, offset_y = -100, maskMode = "_MASKMODE_ROUND"}
        end
    elseif step == 24 then
        if progress == 1 then
            param = {vect1 = self:GetVector2(self.agentBtnTab[5]), sizeX1 = 120, sizeY1 = 60, offset_y = 0, maskMode = "_MASKMODE_RECTANGLE"}
        elseif progress == 2 then
            param = {vect1 = self:GetVector2(self.agentBtnTab[6]), sizeX1 = 120, sizeY1 = 60, offset_y = 0, maskMode = "_MASKMODE_RECTANGLE"}
        end
    end
    param.flag = step
    self:SetHighlight(param, progress)
end

function GuideView:GetVector2(btn)
    if btn then
        local v2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(self:GlobalCamera(), btn.position)
        return v2
    end
end

function GuideView:SetHighlight(param, progress)
    local scale = 1280 / Screen.width
    if 1280 / Screen.width < 720 / Screen.height then
        scale = 720 / Screen.height
    end
    local posX1, posY1, posX2, posY2 = 0, 0, 0, 0
    local sizeX1 = param.sizeX1 or 60
    local sizeY1 = param.sizeY1 or 60
    local sizeX2 = param.sizeX2 or 60
    local sizeY2 = param.sizeY2 or 60
    local offset_y = param.offset_y or 0
    if param.vect1 then
        posX1 = (param.vect1.x - Screen.width / 2) * scale
        posY1 = (param.vect1.y - Screen.height / 2) * scale
        if param.maskMode == "_MASKMODE_ROUND" then
            self.mask:GetComponent("Image").material:SetFloat("_Slider", sizeX1)
        end
        self.mask:GetComponent("Image").material:SetVector("_Center", Vector4(posX1,posY1,0,0))
        self.mask:GetComponent("Image").material:SetVector("_RectangleSize", Vector4(sizeX1,sizeY1,0,0))
    end
    if param.vect2 then
        posX2 = (param.vect2.x - Screen.width / 2) * scale
        posY2 = (param.vect2.y - Screen.height / 2) * scale
        self.mask:GetComponent("Image").material:SetVector("_Center1", Vector4(posX2,posY2,0,0))
        self.mask:GetComponent("Image").material:SetVector("_RectangleSize1", Vector4(sizeX2,sizeY2,0,0))
    end
    self.mask:GetComponent("Image").material:DisableKeyword(self.MaskMode)
    self.mask:GetComponent("Image").material:EnableKeyword(param.maskMode)
    self.MaskMode = param.maskMode

    local index = param.flag
    if self.stepTranTab[index] then
        if index == 34 then
            self.stepTranTab[index]:FindChild("PropTips"):SetActive(true)
            self.stepTranTab[index]:FindChild("PropTips").localPosition = Vector3(posX1, posY1 + offset_y, 0)
        elseif index == 24 or (index == 25 and progress) then
            if progress == 3 or progress == 5 then
                self.stepTranTab[index]:FindChild(string.format("step%d/Arrow", progress)).localPosition = Vector3(posX1, posY1 + offset_y, 0)
            end
        elseif index == 11 or index == 21 or index == 20 then
            self.stepTranTab[index]:FindChild("Btn").localPosition = Vector3(posX1, posY1 + offset_y, 0)
        else
            local arrow = self.stepTranTab[index]:FindChild("Arrow")
            if arrow then
                self.stepTranTab[index]:FindChild("Arrow").localPosition = Vector3(posX1, posY1 + offset_y, 0)
            end
        end
    end
end

--步骤打点
function GuideView:ReqNoviceGuide(step)
    local url = self.WebUrlDataManager.GetGuideUrl(step)
    CC.HttpMgr.Get(url)
end

function GuideView:ActionIn()
end
function GuideView:ActionOut()
end

--关闭界面
function GuideView:CloseView()
	self:Destroy()
end

function GuideView:OnDestroy()
    CC.Sound.StopEffect()
    self:StopTimer("GetTreasure")
    self:CancelAllDelayRun()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
    end
end

return GuideView;