local CC = require("CC")
local AgentRank = CC.uu.ClassView("AgentRank")

function AgentRank:ctor(param)
	self:InitVar(param);
    self:RegisterEvent()
end

function AgentRank:InitVar(param)
	self.param = param or {}
	self.PrefabInfo = {}
	self.rankList = {}
	self.IconTab = {}
    self.showTip = false
	self.propTip = false
	self.swtich = false
	self.PlayerRank = 0
	self.List = {}
	self.oldPlayerRank = 0
	self.oldList = {}
end

function AgentRank:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_AgentView")
	self:InitTr()
	self:InitTextByLanguage()
end

function AgentRank:InitTr()
    self.Parent = self:FindChild("ScrollView/Viewport/Content")
	self.item = self:FindChild("item")
	self.PropTip = self:FindChild("Tip")
	self.peopleExplain = self:FindChild("peopleExplain")
	self.awardExplain = self:FindChild("awardExplain")
	self:AddClick(self:FindChild("Top/peopleText/Image"), function()
		self.peopleExplain:SetActive(not self.peopleExplain.activeSelf)
		self.awardExplain:SetActive(false)
    end)
	self:AddClick(self:FindChild("Top/awardText/Image"), function()
		self.awardExplain:SetActive(not self.awardExplain.activeSelf)
		self.peopleExplain:SetActive(false)
    end)
    self:AddClick(self:FindChild("Bottom/Tip/Image"), function()
        self.showTip = not self.showTip
        self:FindChild("Bottom/explain"):SetActive(self.showTip)
    end)
	self:AddClick(self:FindChild("Bottom/SwitchBtn"), function()
		--切换排名数据
		self.swtich = not self.swtich
		if self.swtich then
			self:FindChild("Bottom/SwitchBtn/Text").text = self.language.rankLast
			self:SetRankInfo(self.oldList)
			self:SetMyRank(self.oldPlayerRank)
		else
			self:FindChild("Bottom/SwitchBtn/Text").text = self.language.rankCur
			self:SetRankInfo(self.List)
			self:SetMyRank(self.PlayerRank)
		end
    end)
	CC.Request("ReqWeekRank")
end

function AgentRank:InitTextByLanguage()
	self:FindChild("Top/rankText").text = self.language.ranking
    self:FindChild("Top/nameText").text = self.language.rankName
    self:FindChild("Top/peopleText").text = self.language.rankPeople
    self:FindChild("Top/awardText").text = self.language.rankAward
	self:FindChild("peopleExplain/Text").text = self.language.rankPeopleTip
	self:FindChild("awardExplain/Text").text = self.language.auditRankAward
    self:FindChild("Bottom/MyRank").text = self.language.rankMy
    self:FindChild("Bottom/Tip").text = self.language.rankRequire
	self:FindChild("Bottom/explain/Text").text = self.language.rankExplain
	self:FindChild("EmptyInfo/Text").text = self.language.rankEmpty
	self:FindChild("Tip/Text").text = self.language.rankFreeTaxTip
	self:FindChild("Bottom/SwitchBtn/Text").text = self.language.rankCur
end

function AgentRank:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.OnReqWeekRankResp,CC.Notifications.NW_ReqWeekRank)
end

function AgentRank:UnRegisterEvent()
    CC.HallNotificationCenter.inst():unregisterAll(self)
end

function AgentRank:OnReqWeekRankResp(err, param)
    log("err = ".. err.."  "..CC.uu.Dump(param, "OnReqWeekRankResp",10))
	if err == 0 then
		self.PlayerRank = param.PlayerRank
		self.List = param.list
		self.oldPlayerRank = param.OldPlayerRank
		self.oldList = param.OldList
		self:SetRankInfo(param.list)
        self:SetMyRank(param.PlayerRank)
	end
end

function AgentRank:SetMyRank(myRank)
    if myRank <= 0 then
        self:FindChild("Bottom/MyRank"):SetActive(false)
    else
        self:FindChild("Bottom/MyRank/Text").text = myRank
    end
end

---排名
function  AgentRank:SetRankInfo(data)
	local list = data
    table.sort(list, function(a,b) return a.RankID < b.RankID end )
	for _,v in pairs(self.PrefabInfo) do
		v.transform:SetActive(false)
	end
	if #list <= 0 then
		self:FindChild("EmptyInfo"):SetActive(true)
		self:FindChild("ScrollView"):SetActive(false)
	else
		self:FindChild("EmptyInfo"):SetActive(false)
		self:FindChild("ScrollView"):SetActive(true)
		for i = 1,#list do
			self:InfoItemData(i,list[i])
		end
	end
end

function AgentRank:InfoItemData(index, data)
	local  rankId = index
	local tran = nil
	if self.PrefabInfo[rankId] == nil then
        tran = CC.uu.newObject(self.item,self.Parent)
        tran.transform.name = tostring(rankId)
        self.PrefabInfo[rankId] = tran.transform
    else
        tran = self.PrefabInfo[rankId]
    end
	tran.transform:FindChild("rank/Text").text = tostring(rankId)
	tran.transform:FindChild("name").text = data.name
	tran.transform:FindChild("people").text = data.promoteNum
	tran.transform:FindChild("reward/Add"):SetActive(false)
	tran.transform:FindChild("reward/Prop/prop_50"):SetActive(false)
	tran.transform:FindChild("reward/Prop/prop_48"):SetActive(false)
	tran.transform:FindChild("reward/Prop/prop"):SetActive(false)
	for _, v in pairs(data.Reward) do
		if v.propID == CC.shared_enums_pb.EPC_ChouMa then
			tran.transform:FindChild("reward/num").text = CC.uu.NumberFormat(v.propNum)
			--周年庆奖励翻倍
			tran.transform:FindChild("reward/num/Image"):SetActive(rankId == 1 and v.propNum > 10000000)
		elseif v.propID == 50 then
			tran.transform:FindChild("reward/Add"):SetActive(true)
			tran.transform:FindChild("reward/Prop/prop_50"):SetActive(true)
			self:AddClick(tran.transform:FindChild("reward/Prop"), function()
				self.propTip = not self.propTip
				self.PropTip.transform:SetParent(tran.transform:FindChild("reward/Prop/prop_50"), false)
				self.PropTip.localPosition = Vector3(40,60,0)
				self.PropTip:SetActive(self.propTip)
			end)
		elseif v.propID == 48 then
			tran.transform:FindChild("reward/Add"):SetActive(true)
			tran.transform:FindChild("reward/Prop/prop_48"):SetActive(true)
			tran.transform:FindChild("reward/Prop/prop_48/Num").text = CC.uu.NumberFormat(v.propNum)
			tran.transform:FindChild("reward/Prop/prop_48/Image"):SetActive(rankId == 1)
		-- elseif v.propID then
		-- 	tran.transform:FindChild("reward/Add"):SetActive(true)
		-- 	tran.transform:FindChild("reward/Prop/prop"):SetActive(true)
		-- 	self:SetImage(tran.transform:FindChild("reward/Prop/prop"),"prop_img_" .. v.propID)
		end
	end
	self:SpriteInfo(rankId, tran)
	local headNode = tran.transform:FindChild("head/Node")
	self:DeleteHeadIconByKey(headNode)
	Util.ClearChild(headNode,false)
	local param = {}
	param.parent = headNode
	param.playerId = data.playerId
	param.portrait = data.portrait
	param.vipLevel = data.vip
	self:SetHeadIcon(param, rankId)
    tran:SetActive(true)
end

--排名皇冠图片切换
function AgentRank:SpriteInfo(key, tran)
	if key <= 3 then
		tran:FindChild("special"):SetActive(true)
		tran:FindChild("special/1"):SetActive(key == 1)
		tran:FindChild("special/2"):SetActive(key == 2)
		tran:FindChild("special/3"):SetActive(key == 3)
		tran:FindChild("rank").text = ""
	else
		tran:FindChild("special"):SetActive(false)
		tran:FindChild("rank"):SetActive(true)
	end
end

function AgentRank:DeleteHeadIconByKey(headNode)
	if headNode.childCount > 0 then
		local headtran = headNode.transform:GetChild(0)
		if headtran then
			self.IconTab[tonumber(headtran.transform.name)]:Destroy()
			self.IconTab[tonumber(headtran.transform.name)] = nil
		end
	end
end

function  AgentRank:SetHeadIcon(param, i)
	self.HeadIcon = CC.HeadManager.CreateHeadIcon(param)
	self.HeadIcon.transform.name = tostring(i)
	self.IconTab[i] = self.HeadIcon
end

function AgentRank:ActionIn()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
		{"fadeToAll", 0, 0},
		{"fadeToAll", 255, 0.5, function() self:SetCanClick(true); end}
	});
end

function AgentRank:ActionOut()
    self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

function AgentRank:OnDestroy()
    self:UnRegisterEvent()
	for _,v in pairs(self.IconTab) do
		if v then
			v:Destroy()
			v = nil
		end
	end
end

return AgentRank;