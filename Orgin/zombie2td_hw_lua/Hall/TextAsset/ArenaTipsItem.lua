local CC = require("CC")
local ItemBaseClass = require("View/RewardNoticeView/ItemBaseClass")
local baseClass = CC.class2("ArenaTipsItem",ItemBaseClass)

function baseClass:ctor(view,obj,closeCallback)
	self.type = 3
	self.callback = nil
	self.createTime = os.time()+math.random()
	self.bgRTr = self:SubGet("","RectTransform")
	self.bgImage = self:SubGet("","Image")
	self.btn = self:SubGet("btn","Image")
	-- self.iconSprite = self:SubGet("icon/Image","Image")
	self.itemList = {}
	for i=1,3 do
		local path = "grid/icon"..i
		local item = {}
		item.transform = self:FindChild(path)
		item.iconSprite = self:SubGet(path.."/Image","Image")
		item.numText = self:SubGet(path.."/Text","Text")
		table.insert(self.itemList,item)
	end
	self.titleText = self:SubGet("titleText","Text")
	self.timeText = self:SubGet("timeText","Text")
	self.tipsText = self:SubGet("tipsText","Text")
	self.nameText = self:SubGet("nameText","Text")
	self.getText = self:SubGet("getText","Text")
	self:SetClick()
end

function baseClass:GetOffset(offset)
	return 94 + offset
end

function baseClass:UpdateView( data )
	if data.Props == nil then
		logError("!!!!!!!!!!!!!!!! 未传奖励信息")
		return
	end

	if data.type == 3 then
		self.titleText.text = data.name
		self.timeText.text = data.timeStr
		if data.isShowAwardPool then
			self.nameText.text = self.view.language.bigAwardPool
		else
			self:StartArenaCountDown(data.time)
		end
		self.getText.text = self.view.language.arenaGoto
	elseif data.type == 4 then
		self.titleText.text = data.name
		self.timeText.text = self.view.language.numberone
		self.nameText.text = self.view.language.congratulation
		self.getText.text = "["..data.playerName.."]"
	end

	if type(data.Props) == "table" then
		for i,prop in ipairs(data.Props) do
			local propItem = self.itemList[i]
			local iconSprite = propItem.iconSprite
			local ConfigId = prop.ConfigId or 1
			local Count = prop.Count or 0
			local ImageName = self.view.PropDataMgr.GetIcon( ConfigId, Count )
			if ImageName then
				self.view:SetImage(iconSprite, ImageName);
			else
				logError(ConfigId)
			end
			local numText = propItem.numText
			if Count > 0 then
				numText.text = "x"..Count
			else
				numText.text = ""
			end
			propItem.transform:SetActive(true)
		end
		for i=#data.Props+1,3 do
			self.itemList[i].transform:SetActive(false)
		end
	else
		logError("ArenaTipsItem UpdateView error")
		-- local ConfigId = data.Props.ConfigId or 1
		-- local Count = data.Props.Count or 0

		-- local desc = self.view.PropDataMgr.GetLanguageDesc(ConfigId,Count)

		-- if data.type == 3 then
		-- 	self.tipsText.text = string.format(self.view.language.awardhigh,desc) 
		-- end

		-- local ImageName = self.view.PropDataMgr.GetIcon( ConfigId, Count )
		-- if ImageName then
		-- 	self.view:SetImage(self.iconSprite, ImageName);
		-- else
		-- 	logError(ConfigId)
		-- end
	end
end

-- 竞技场定时器
function baseClass:StartArenaCountDown(Seconds)
	local deltaTime = Seconds or 0
	local time = 0
	self.view:StartTimer("UpdateArenaCountDown"..self.createTime, 0, function()
        time = time + Time.deltaTime
        local leftTime = deltaTime-math.floor(time)
        local timeStr = CC.uu.TicketFormat(leftTime)
        if time >= deltaTime then
        	self.nameText.text = string.format(self.view.language.arenaCountDown,"00:00:00") 
			self.view:StopTimer("UpdateArenaCountDown"..self.createTime)
		else
			self.nameText.text = string.format(self.view.language.arenaCountDown,timeStr)
        end
    end, -1)
end

return baseClass