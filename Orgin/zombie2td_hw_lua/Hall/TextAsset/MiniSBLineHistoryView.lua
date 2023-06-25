local CC = require("CC")
local MiniSBLineHistoryView = CC.uu.ClassView("MiniSBLineHistoryView")
local Request = require("View/MiniSBView/MiniSBNetwork/Request")
local MiniSBNotification = require("View/MiniSBView/MiniSBNetwork/MiniSBNotification")
local proto = require("View/MiniSBView/MiniSBNetwork/game_pb")

local initRound21Context
local initRound100Context
local bindClickListener
local registerNotification
local unRegisterNotification
local refreshData

local refreshRound21Panel
local refreshRound100Panel

local addTopView
local addRound100TopView

local addBottomView

local addNode
local setLineProperty
local getRowAndColumn

local onAllToggle
local onDiceToggle

local load100RoundHistory

function MiniSBLineHistoryView:ctor(param)
    self.mainView = param.mainView
    self.history = {}
    -- 默认打开21局的
    self.history["21"] = param.history
    -- 检测数据刷新，如果切换界面了，则需要更新界面
    self.dataChaned = false
    self.quaternion = Quaternion()
end

function MiniSBLineHistoryView:OnCreate()
    initRound21Context(self)
    initRound100Context(self)

    refreshRound21Panel(self)
    bindClickListener(self)
    registerNotification(self)
    self:initLanguage()

    local window = CC.MiniGameMgr.GetCurWindowMode()
    if window then
        self:toWindowsSize()
    else
        self:toFullScreenSize()
    end
    self:registerEvent()
end

function MiniSBLineHistoryView:registerEvent()
    CC.HallNotificationCenter.inst():register(self, self.toWindowsSize, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():register(self, self.toFullScreenSize, CC.Notifications.OnSetFullScreen)
end

function MiniSBLineHistoryView:unregisterEvent()
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetWindowScreen)
    CC.HallNotificationCenter.inst():unregister(self, CC.Notifications.OnSetFullScreen)
end

function MiniSBLineHistoryView:OnDestroy()
    self:unregisterEvent()
    unRegisterNotification(self)
end

function MiniSBLineHistoryView:initLanguage()
    local language = self.mainView.language

    local allToggleText = self:SubGet("InsideNode/21RoundPanel/AllToggle/Label", "Text")
    allToggleText.text = language.AllText

    for i = 1, 3 do
        self:SubGet("InsideNode/21RoundPanel/Dice" .. i .. "Toggle/Label", "Text").text = language.Dice .. i
    end
end

function MiniSBLineHistoryView:onCloseBtnClick()
    unRegisterNotification(self)
    self:ActionOut()
end

-------------------------------------------------
--  显示21局表格
-------------------------------------------------
function MiniSBLineHistoryView:show21Panel()
    if not self.round21Panel.activeSelf then
        if self.dataChaned then
            refreshRound21Panel(self)
            self.dataChaned = false
        end
        self.round21Panel:SetActive(true)
        self.round100Panel:SetActive(false)
    end
end

-------------------------------------------------
--  显示100局表格
-------------------------------------------------
function MiniSBLineHistoryView:show100Panel()
    local history = self.history["100"]

    if history == nil then
        load100RoundHistory(self)
    else
        if not self.round100Panel.activeSelf then
            if self.dataChaned then
                refreshRound100Panel(self)
                self.dataChaned = false
            end
            self.round100Panel:SetActive(true)
            self.round21Panel:SetActive(false)
        end
    end
end

-------------------------------------------------
--注册通知
-------------------------------------------------
registerNotification = function(self)
    MiniSBNotification.GameRegister(self, "SCGameResult", refreshData)
end

-------------------------------------------------
--取消通知
-------------------------------------------------
unRegisterNotification = function(self)
    MiniSBNotification.GameUnregisterAll(self)
    MiniSBNotification.NetworkUnregisterAll(self)
end

-------------------------------------------------
--  刷新数据
--  @data 数据
-------------------------------------------------
refreshData = function(self, data)
    -- 数据已经刷新，如果切换界面，则刷新界面
    self.dataChaned = true

    local result = data.result
    local table21len = #self.history["21"].results

    if table21len == 21 then
        table.remove(self.history["21"].results, 1)
    end
    table.insert(self.history["21"].results, result)

    local history = self.history["100"]
    if history ~= nil then
        local table100len = #self.history["100"].results
        if table100len == 100 then
            table.remove(self.history["100"].results, 1)
        end
        table.insert(self.history["100"].results, result)
    end

    if self.round21Panel.activeSelf then
        refreshRound21Panel(self)
    else
        refreshRound100Panel(self)
    end
end

initRound21Context = function(self)
    self.round21Panel = self:FindChild("InsideNode/21RoundPanel")
    self.preBtn = self:FindChild("InsideNode/PreBtn")
    self.nextBtn = self:FindChild("InsideNode/NextBtn")
    self.closeBtn = self:FindChild("InsideNode/Close")

    self.allToggle = self:FindChild("InsideNode/21RoundPanel/AllToggle")
    self.diceToggles = {}
    for i = 1, 3 do
        local toggle = self:FindChild("InsideNode/21RoundPanel/Dice" .. i .. "Toggle")
        table.insert(self.diceToggles, toggle)
    end

    -- 21局 顶部 用于克隆的连线
    self.topCloneLine = self:FindChild("InsideNode/ForClone/TopLine")

    -- 大 节点
    self.bigNode = self:FindChild("InsideNode/ForClone/BigNode")
    -- 小 节点
    self.smallNode = self:FindChild("InsideNode/ForClone/SmallNode")

    -- 21局 顶部 放置克隆节点的位置
    self.topNodeParent = self:FindChild("InsideNode/21RoundPanel/Top/Node")
    -- 21局 顶部 放置克隆线的位置
    self.topLineParent = self:FindChild("InsideNode/21RoundPanel/Top/Line")

    -- 21局 底部 用于克隆的连线 3个骰子，3条线
    self.diceLines = {}
    for i = 1, 3 do
        local node = self:FindChild("InsideNode/ForClone/BottomLine" .. i)
        table.insert(self.diceLines, node)
    end

    -- 21局 底部 用于克隆的节点 3个骰子，3个节点
    self.diceNodes = {}
    for i = 1, 3 do
        local node = self:FindChild("InsideNode/ForClone/BottomNode" .. i)
        table.insert(self.diceNodes, node)
    end

    -- 21局 底部 放置克隆节点的位置 3个骰子，3个节点
    self.diceNodeParents = {}

    for i = 1, 3 do
        local node = self:FindChild("InsideNode/21RoundPanel/Bottom/Dice" .. i .. "Node")
        table.insert(self.diceNodeParents, node)
    end
    -- 21局 底部 放置克隆线条的位置 3个骰子，3条线
    self.diceLineParents = {}

    for i = 1, 3 do
        local node = self:FindChild("InsideNode/21RoundPanel/Bottom/Dice" .. i .. "Line")
        table.insert(self.diceLineParents, node)
    end

    -- X 轴的参考位置节点
    self.xNodesIn21 = {}
    -- 顶部 Y 轴的参考位置节点
    self.topYNodesIn21 = {}
    -- 底部 Y 轴的参考位置节点
    self.bottomYNodesIn21 = {}

    -- 21局
    for i = 1, 21 do
        local node = self:FindChild("InsideNode/21RoundPanel/Top/X/" .. i)
        table.insert(self.xNodesIn21, node)
    end

    -- 3个骰子数值 3到18
    for i = 3, 18 do
        local node = self:FindChild("InsideNode/21RoundPanel/Top/Y/" .. i)
        table.insert(self.topYNodesIn21, node)
    end

    -- 每个骰子的数值，1到6
    for i = 1, 6 do
        local node = self:FindChild("InsideNode/21RoundPanel/Bottom/Y/" .. i)
        table.insert(self.bottomYNodesIn21, node)
    end
end

initRound100Context = function(self)
    self.round100Panel = self:FindChild("InsideNode/100RoundPanel")
    self.round100Panel:SetActive(false)

    -- 100局 顶部 放置克隆节点的位置
    self.topNodeParentIn100 = self:FindChild("InsideNode/100RoundPanel/Top/Node")

    -- 100局 底部 放置克隆节点的位置
    self.bottomNodeParentIn100 = self:FindChild("InsideNode/100RoundPanel/Bottom/Node")

    -- X 轴的参考位置节点
    self.xNodesIn100 = {}
    -- 顶部 Y 轴的参考位置节点
    self.topYNodesIn100 = {}
    -- 底部 Y 轴的参考位置节点
    self.bottomYNodesIn100 = {}

    -- 出现 大 的数量
    self.bigCountText = self:FindChild("InsideNode/100RoundPanel/BigCount"):GetComponent("Text")
    -- 出现 小 的数量
    self.smallCountText = self:FindChild("InsideNode/100RoundPanel/SmallCount"):GetComponent("Text")

    -- 20列
    for i = 1, 20 do
        local node = self:FindChild("InsideNode/100RoundPanel/Top/X/" .. i)
        table.insert(self.xNodesIn100, node)
    end

    -- 5行
    for i = 1, 5 do
        local node = self:FindChild("InsideNode/100RoundPanel/Top/Y/" .. i)
        table.insert(self.topYNodesIn100, node)
    end

    -- 1列最多6个
    for i = 1, 6 do
        local node = self:FindChild("InsideNode/100RoundPanel/Bottom/Y/" .. i)
        table.insert(self.bottomYNodesIn100, node)
    end
end

bindClickListener = function(self)
    self:AddClick("InsideNode/Close", "onCloseBtnClick")

    self:AddClick(self.preBtn, "show21Panel")
    self:AddClick(self.nextBtn, "show100Panel")

    self:AddClick(
        self.allToggle,
        function()
            onAllToggle(self)
            -- body
        end
    )

    for i, toggle in ipairs(self.diceToggles) do
        self:AddClick(
            toggle,
            function()
                onDiceToggle(self, i)
                -- body
            end
        )
    end
end

refreshRound21Panel = function(self)
    log("数据刷新 21局历史界面")
    local dices = {}
    local dice1 = {}
    local dice2 = {}
    local dice3 = {}

    dices[1] = dice1
    dices[2] = dice2
    dices[3] = dice3

    -- 画顶部节点和连线
    for i, v in ipairs(self.history["21"].results) do
        addTopView(self, i, v)
        table.insert(dice1, v.dices[1])
        table.insert(dice2, v.dices[2])
        table.insert(dice3, v.dices[3])
    end

    -- 画顶底部 三个骰子 的节点和连线
    for i = 1, 3 do
        for j, v in ipairs(dices[i]) do
            addBottomView(self, i, j, v)
        end
    end
end

refreshRound100Panel = function(self)
    log("数据刷新 100局历史界面")
    -- 画顶部节点

    local bigCount = 0
    local smallCount = 0

    for i, v in ipairs(self.history["100"].results) do
        if v.locationAreas == proto.Big then
            bigCount = bigCount + 1
        elseif v.locationAreas == proto.Small then
            smallCount = smallCount + 1
        end
        addRound100TopView(self, i, v)
    end

    -- 出现 大 的数量
    self.bigCountText.text = bigCount
    -- 出现 小 的数量
    self.smallCountText.text = smallCount

    -- 画底部节点
    local locationAreas = proto.InvalidAreas
    local column = 0
    local row = 0

    for i, v in ipairs(self.history["100"].results) do
        -- 当结果变化，换行表示

        if locationAreas ~= v.locationAreas then
            column = column + 1
            row = 0
            locationAreas = v.locationAreas
        end

        -- 一列摆不下，换行继续摆
        if row < 6 then
            row = row + 1
        else
            row = 1
            column = column + 1
        end

        -- 后面的不再显示
        if column > 20 then
            break
        end

        --找出位置
        local x = self.xNodesIn100[column].localPosition.x
        local y = self.bottomYNodesIn100[row].localPosition.y
        -- 添加节点

        local cloneNode

        if v.locationAreas == proto.Big then
            cloneNode = self.bigNode
        else
            cloneNode = self.smallNode
        end

        local newNode = addNode(self.bottomNodeParentIn100, cloneNode, tostring(i), x, y)
        -- 显示数值
        local count = v.dices[1] + v.dices[2] + v.dices[3]
        newNode:FindChild("Text"):GetComponent("Text").text = count
    end
end

-------------------------------------------------
--  100表格，添加节点
--  @index 该局索引
--  @value 该局结果
-------------------------------------------------
addRound100TopView = function(self, index, value)
    local locationAreas = value.locationAreas

    local row, column = getRowAndColumn(index)

    --找出位置
    local x = self.xNodesIn100[column].localPosition.x
    local y = self.topYNodesIn100[row].localPosition.y

    local cloneNode

    if locationAreas == proto.Big then
        cloneNode = self.bigNode
    else
        cloneNode = self.smallNode
    end

    addNode(self.topNodeParentIn100, cloneNode, tostring(index), x, y)
end

-------------------------------------------------
--  21局 上半部表格
--  @index 该局索引
--  @value 该局结果
-------------------------------------------------
addTopView = function(self, index, value)
    local count = value.dices[1] + value.dices[2] + value.dices[3]
    -- 顶部 Y 轴的起始是 3 ，和节点数组配合，所以要减2
    local yIndex = count - 2

    --找出位置
    local x = self.xNodesIn21[index].localPosition.x
    local y = self.topYNodesIn21[yIndex].localPosition.y

    local cloneNode

    if value.locationAreas == proto.Big then
        cloneNode = self.bigNode
    else
        cloneNode = self.smallNode
    end

    -- 添加节点到该位置
    local newNode = addNode(self.topNodeParent, cloneNode, tostring(index), x, y)
    newNode:FindChild("Text"):GetComponent("Text").text = count

    -- 从第二个开始画线
    if index > 1 then
        local line = self.topLineParent:FindChild(tostring(index - 1))
        if line == nil then
            line = CC.uu.UguiAddChild(self.topLineParent, self.topCloneLine, tostring(index - 1))
        end

        -- 线的起始位置是上个节点的位置
        local lastNode = self.topNodeParent:FindChild(tostring(index - 1))

        setLineProperty(lastNode, newNode, line)
    end
end

-------------------------------------------------
--  21局 下半部表格
--  @parentIndex 骰子索引
--  @index 该局索引
--  @value 该局结果
-------------------------------------------------

addBottomView = function(self, parentIndex, index, value)
    -- body
    local x = self.xNodesIn21[index].localPosition.x
    local y = self.bottomYNodesIn21[value].localPosition.y

    local parentNode = self.diceNodeParents[parentIndex]
    local childNode = self.diceNodes[parentIndex]

    local newNode = addNode(parentNode, childNode, tostring(index), x, y)

    -- 从第二个开始画线
    if index > 1 then
        local parentLine = self.diceLineParents[parentIndex]
        local childLine = self.diceLines[parentIndex]

        local line = parentLine:FindChild(tostring(index - 1))
        if line == nil then
            line = CC.uu.UguiAddChild(parentLine, childLine, tostring(index - 1))
        end

        local lastNode = parentNode:FindChild(tostring(index - 1))

        setLineProperty(lastNode, newNode, line)
    end
end

addNode = function(parent, child, name, x, y)
    -- 添加节点到该位置
    local newNode = parent:FindChild(name)
    if newNode == nil then
        newNode = CC.uu.UguiAddChild(parent, child, name)
    end

    newNode.localPosition = Vector3(x, y, 0)

    return newNode
end

setLineProperty = function(startNode, endNode, line)
    -- 起始位置
    line.localPosition = startNode.localPosition
    -- 长度
    line.transform.sizeDelta = Vector2(line.width, Vector3.Distance(endNode, startNode))
    -- 角度
    local angle = math.atan2(endNode.y - startNode.y, endNode.x - startNode.x) * 180 / math.pi
    line.transform.rotation = self.quaternion:SetEuler(0, 0, angle + 270);
end

getRowAndColumn = function(index)
    --行:row 2、列:column
    local row = math.modf(index / 20) -- 取整数
    local column = math.fmod(index, 20) -- 取余数

    if row ~= 5 and column ~= 0 then
        row = row + 1
    end

    if column == 0 then
        column = 20
    end
    return row, column
end

load100RoundHistory = function(self)
    local cb = function(err, data)
        if data == nil then
            log("load100RoundHistory data == nil")
        end
        self.history["100"] = data
        refreshRound100Panel(self)
        self.round100Panel:SetActive(true)
        self.round21Panel:SetActive(false)
    end

    Request.LoadGameResultHistory(0, 99, cb)
end

onAllToggle = function(self)
    -- body
    local show = false
    if self.allToggle:GetComponent("Toggle").isOn then
        show = true
    end

    for i = 1, 3 do
        local parentNode = self.diceNodeParents[i]
        local parentLine = self.diceLineParents[i]
        parentNode:SetActive(show)
        parentLine:SetActive(show)

        self.diceToggles[i]:GetComponent("Toggle").isOn = show
    end
end

onDiceToggle = function(self, index)
    local parentNode = self.diceNodeParents[index]
    local parentLine = self.diceLineParents[index]

    local toggle = self.diceToggles[index]
    local isOn = toggle:GetComponent("Toggle").isOn

    if isOn then
        parentNode:SetActive(true)
        parentLine:SetActive(true)
    else
        parentNode:SetActive(false)
        parentLine:SetActive(false)
    end

    for i, tg in ipairs(self.diceToggles) do
        -- 有一个不相同，就不用进行下面的逻辑了，
        if tg:GetComponent("Toggle").isOn ~= isOn then
            return
        end
    end
    --都是 显示或者不显示，则全部也要不显示了
    self.allToggle:GetComponent("Toggle").isOn = isOn
end

function MiniSBLineHistoryView:toWindowsSize()
    self:FindChild("InsideNode").localScale = Vector3(0.9, 0.9, 0.9)
end

function MiniSBLineHistoryView:toFullScreenSize()
    self:FindChild("InsideNode").localScale = Vector3(1, 1, 1)
end

return MiniSBLineHistoryView
