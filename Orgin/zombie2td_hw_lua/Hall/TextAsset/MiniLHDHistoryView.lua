--------------------------------------------
-- 游戏介绍界面
--------------------------------------------
local CC = require("CC")
local MiniLHDHistoryView = CC.uu.ClassView("MiniLHDHistoryView")
local Request = require("View/MiniLHDView/MiniLHDNetwork/MiniLHDRequest")
local bindClickListener
local initView

function MiniLHDHistoryView:ctor(param)
    self.mainView = param.mainView
end

function MiniLHDHistoryView:OnCreate()
    initView(self)
    bindClickListener(self)
    self:initLanguage()
    self:LoadPlayerRecords()
end

function MiniLHDHistoryView:OnDestroy()
end

function MiniLHDHistoryView:initLanguage()
    local language = self.mainView.language

    local numText = self:SubGet("InsideNode/top/num", "Text")
    local resultText = self:SubGet("InsideNode/top/result", "Text")
    local timeText = self:SubGet("InsideNode/top/time", "Text")
    local indexText = self:SubGet("InsideNode/top/index", "Text")

    numText.text = language.Index
    resultText.text = language.Result
    timeText.text = language.Time
    indexText.text = language.roundID
end

function MiniLHDHistoryView:onCloseBtnClick()
    self:ActionOut()
end

--加载排行榜
function MiniLHDHistoryView:LoadPlayerRecords()
    local cb = function(err, data)
        if err == 0 then
            self:refreshView(data)
        else
            log("loadranking err = " .. err)
        end
    end
    Request.LoadPlayerRecords(0, 49, cb)
end

-- 刷新界面
function MiniLHDHistoryView:refreshView(dataRsp)
    self.dataRsp = dataRsp
    log("loadranking err = " .. tostring(dataRsp))
    if #dataRsp.records == 0 then
        -- self:ShowGameTipsView("数据为空")
        return
    end

    self.ScrollerController:RefreshScroller(#dataRsp.records, 0)
    -- body
end

-- 设置item
function MiniLHDHistoryView:itemData(tran, index)
    local rankId = index + 1
    tran.name = tostring(rankId)

    local data = self.dataRsp.records[rankId]
    if not data then
        return
    end
    tran:SetActive(true)

    local roomID = data.roomID
    tran.transform:FindChild("Bg"):SetActive(rankId % 2 == 0)

    local numText = tran.transform:FindChild("num"):GetComponent("Text")
    numText.text = rankId

    -- required int64 myWin = 4;            // 收到的钱
    -- required int64 lastTime = 5;         // 最后下注时间

    local timeText = tran.transform:FindChild("time"):GetComponent("Text")
    timeText.text = os.date("%d-%m-%Y %H:%M:%S", data.lastTime)

    local timeText = tran.transform:FindChild("index"):GetComponent("Text")
    timeText.text = tostring(data.roundID)

    local loseText = tran.transform:FindChild("lose"):GetComponent("Text")
    local winText = tran.transform:FindChild("win"):GetComponent("Text")

    local result = data.myWin

    if result > 0 then
        winText:SetActive(true)
        loseText:SetActive(false)
        loseText.text = ""
        winText.text = "+" .. result
    else
        winText:SetActive(false)
        loseText:SetActive(true)
        winText.text = ""
        loseText.text = result
    end
end

bindClickListener = function(self)
    self:AddClick("InsideNode/Close", "onCloseBtnClick")
end

initView = function(self)
    local title = self:FindChild("InsideNode/Title/Image")
    title:GetComponent("Image"):SetNativeSize()

    self.ScrollerController = self:FindChild("InsideNode/Frame/ScrollerController"):GetComponent("ScrollerController")
    self.ScrollerController:AddChangeItemListener(
        function(tran, dataIndex, cellIndex)
            self:itemData(tran, dataIndex, cellIndex)
        end
    )
    self.ScrollerController:InitScroller(0)
end

return MiniLHDHistoryView
