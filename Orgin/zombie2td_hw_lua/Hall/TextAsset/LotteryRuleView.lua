--***************************************************
--文件描述: 彩票系统之彩票规则介绍界面
--关联主体: LotteryRuleView.prefab
--注意事项:无
--作者:langzi
--时间:2018-11-19
--***************************************************
local CC = require("CC")
local LotteryRuleView = CC.uu.ClassView("LotteryRuleView")

local _InitVar
local _OnClickBack
local ruleStr = "Error! no correct configuration."

function LotteryRuleView:ctor(param)
    _InitVar(self,param)
end

function LotteryRuleView:OnCreate()
    self:FindNode()
    self:InitUI()
    self:InitEvent()
end

function LotteryRuleView:FindNode(  )
    -- VIP加成细节界面
    self.vipDetailFather = self:FindChild("ScrollView/Viewport/Content/Item03")
    self.vipDetailPanel = self:FindChild("Tools/VipDetail")
    self.scrollContent = self:FindChild("ScrollView/Viewport/Content")
    self.vipDetailItems = {}

    self.vipRow1Tilte = self.vipDetailPanel:FindChild("Bg/row01/title")
    local row1Layout = self.vipDetailPanel:FindChild("Bg/row01/layout")
    self.vipDetailItems[1] = {}
    for i=1,11 do
        self.vipDetailItems[1][i] = row1Layout:GetChild(i-1):GetChild(0)
    end

    self.vipRow2Tilte = self.vipDetailPanel:FindChild("Bg/row02/title")
    local row2Layout = self.vipDetailPanel:FindChild("Bg/row02/layout")
    self.vipDetailItems[2] = {}
    for i=1,10 do
        self.vipDetailItems[2][i] = row2Layout:GetChild(i-1):GetChild(0)
    end
end

function LotteryRuleView:InitUI()
    local language =  self.mainView.language

    local title = self:SubGet("Title/Text","Text")
    title.text = language.RuleTitle

    local ruleText = self:SubGet("ScrollView/Viewport/Content/Item01","Text")
    ruleText.text = language.LotteryRule

    ruleText = self:SubGet("ScrollView/Viewport/Content/Item02","Text")
    ruleText.text = language.ruleStr01
    ruleText = self:SubGet("ScrollView/Viewport/Content/Item03","Text") -- 这个Item后面有个按钮,注意
    ruleText.text = language.ruleStr02
    ruleText = self:SubGet("ScrollView/Viewport/Content/Item04","Text")
    if CC.Platform.isIOS then
        ruleText.text = language.ruleStr03 .. language.ruleStr04.. language.ruleStr05
    else
        ruleText.text = language.ruleStr03 .. language.ruleStr04
    end
    local tstr = "VIP" .."\n"..language.VipPremiums
    self.vipRow1Tilte.text = tstr
    self.vipRow2Tilte.text = tstr
    for i=1,21 do
        tstr =  i .. "\n" .. self.vipPremiums[i] .. "%"
        if i <= 11 then
            self.vipDetailItems[1][i].text = tstr
        elseif i <= 20 then
            self.vipDetailItems[2][i - 11].text =  tstr
        else
            self.vipDetailItems[2][i - 11].text = "21-30".. "\n" .. self.vipPremiums[i] .. "%"
        end
    end
end

function LotteryRuleView:InitEvent()
    self:AddClick("Close", function (  )
        self:ActionOut()
    end)
    self:AddClick("Mask",function(  )
        self:ActionOut()
    end)
    self:AddClick("ScrollView/Viewport/Content/Item03/Image",function(  )
        local tVipPos = self.vipDetailPanel.localPosition
        local tScrollPos = self.scrollContent.localPosition
        local tempY = math.min( 135,tScrollPos.y - 170  )
        self.vipDetailPanel.localPosition = Vector3(tVipPos.x,tempY,0)
        self.vipDetailPanel:SetActive(true)
    end)
    self:AddClick("Tools/VipDetail/Mask",function(  )
        self.vipDetailPanel:SetActive(false)
    end)
end


function LotteryRuleView:OnDestroy()
	-- if self.viewCtr then
	-- 	self.viewCtr:Destroy()
	-- 	self.viewCtr = nil
    -- end
end

-- function LotteryRuleView:ActionIn()

-- end

_InitVar = function(self,param)
    self.mainView = param.mainView
    self.vipPremiums = self.mainView.lotteryData.VipPremiums
end


return LotteryRuleView