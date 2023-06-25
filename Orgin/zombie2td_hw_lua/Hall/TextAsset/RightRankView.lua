local CC = require("CC")

local RightRankView = CC.class2("RightRankView",CC.HallViewBase)

function RightRankView:Create(param)
	self:InitVar(param)
    self:InitContent()
    self:InitTextByLanguage()
    self:AddClickEvent()
end

function RightRankView:InitVar(param)
    self.param = param
    self.req = self.param.req or function () log("无请求") end
    self.headList = {}

    self.actionPlaying = false
    self.show = false

    self.propCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Prop");
    self.PropDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("PropDataMgr")
end

function RightRankView:InitContent()
    self.transform = CC.uu.LoadHallPrefab("prefab", "RightRankView", self.param.parent);

    self.width = self.transform:FindChild("InfoView")
    self.leftArrow = self.transform:FindChild("Btn/Left")
    self.rightArrow = self.transform:FindChild("Btn/Right")

    self.ScrollerController = self.transform:FindChild("ScrollerController"):GetComponent("ScrollerController")
	self.ScrollerController:AddChangeItemListener(function(tran,dataIndex,cellIndex)
		self:InitData(tran,dataIndex,cellIndex)
	end)

	self.ScrollerController:AddRycycleAction(function (tran)
		self:RecycleItem(tran)
    end)
end

function RightRankView:InitTextByLanguage()
    self.language = CC.LanguageManager.GetLanguage("L_RightRankView")
    self.transform:FindChild("InfoView/Title/Name").text = self.language.roleName
    self.transform:FindChild("InfoView/Title/Info").text = self.language.winInfo
    self.transform:FindChild("BG/Text").text = self.language.maskBtn
end

function RightRankView:AddClickEvent()
    self:AddClick(self.transform:FindChild("Btn"),"ShowOrHidePanel")

    self:AddClick(self.transform:FindChild("BG"),"ShowOrHidePanel")
end

function RightRankView:ShowOrHidePanel()
    if self.actionPlaying then
        return
    end
    self.actionPlaying = true
    local rankWidth = self.width.rect.width
    if not self.show then
        self.req()
        self.transform:FindChild("BG"):SetActive(true)
        self:RunAction(
            self.transform,
            {
                "localMoveTo",
                -rankWidth,
                0,
                0.3,
                ease = CC.Action.EInSine,
                function()
                    self.show = true
                    self.actionPlaying = false
                    self.leftArrow:SetActive(false)
                    self.rightArrow:SetActive(true)
                end
            }
        )
    else
        self:RunAction(
            self.transform,
            {
                "localMoveTo",
                0,
                0,
                0.3,
                ease = CC.Action.EInSine,
                function()
                    self.leftArrow:SetActive(true)
                    self.rightArrow:SetActive(false)
                    self.transform:FindChild("BG"):SetActive(false)
                    self.show = false
                    self.actionPlaying = false
                end
            }
        )
    end
end

function RightRankView:InitData(tran,dataIndex,cellIndex)
    local info = self.param[dataIndex + 1]
    local ConfigId = info.Rewards[1].ConfigId
    local Count = info.Rewards[1].Count
    local param = {}
    param.id = info.PlayerId
    param.portrait = info.Portrait
    param.vip = info.Vip
    param.nick = info.Name
    param.time = CC.uu.TimeOut3(info.TimeStamp)
    if ConfigId == 10004 and Count == 1000 then
        param.des = self.PropDataMgr.GetLanguageDesc(ConfigId,Count).." x2"
    else
        param.des = self.PropDataMgr.GetLanguageDesc(ConfigId,Count)
    end
    
    self:RefreshItem(tran,param,dataIndex + 1)
end

function RightRankView:RefreshItem(tran,param,index)
	tran.transform.name = index
	local headNode = tran:FindChild("ItemHead")
	local id = param.id
	local portrait = param.portrait
	local vip = param.vip
	self.headList[index] = self:SetHeadIcon(headNode,id,portrait,vip)
	tran:FindChild("Nick").text = param.nick
	tran:FindChild("Des").text = param.des
	tran:FindChild("Time").text = param.time
end

function RightRankView:SetHeadIcon(node,id,portrait,level)
	local param = {}
	param.parent = node
	param.playerId = id
	param.portrait = portrait
	param.vipLevel = level
	return CC.HeadManager.CreateHeadIcon(param)
end

function RightRankView:RecycleItem(tran)
	local index = tonumber(tran.transform.name)
	if self.headList[index] then
		self.headList[index]:Destroy(true)
	end
end

function RightRankView:RefreshScroller(param)
    self.param = param
    if self.param then
        self.ScrollerController:InitScroller(#self.param)
    end
end

function RightRankView:Destroy()
    for _,v in pairs(self.headList) do
		if v then
			v:Destroy(true)
		end
    end
end

return RightRankView