local CC = require("CC")
local BaseClass = require("View/DailyGiftCollectionView/DailyGiftBaseClass")
local DailyGiftPokdeng = CC.class2("DailyGiftPokdeng",BaseClass)

function DailyGiftPokdeng:Create()
	self:OnCreate("DailyGiftPokdeng")
	-- self.Scroller = self.transform:FindChild("BG/Record/Scroller")
	-- self.Content = self.Scroller:FindChild("Content")
	-- self.Item = self.Scroller:FindChild("Item")
	-- self:InitListData()
end

function DailyGiftPokdeng:InitDailyGiftData()
    -- self.WareId = "22012"
	-- self.giftSource = CC.shared_transfer_source_pb.TS_PokDeng_DailyTreasure
	self.PrefabTab = {}
    self.gameId = 2002
    self.WareId = "30098"
    self.giftSource = CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_29
    self.giftSourceList = {CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_29, CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_50,
        CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_150, CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_500,
        CC.shared_transfer_source_pb.TS_Pokdeng_DailyGift_1000,}
    self.wareIdList = {"30098", "30099", "30100", "30101", "30102"}
end

function DailyGiftPokdeng:InitLanguage()
    for k, v in ipairs(self.panelView) do
        local index = k
		v:FindChild("Effect_dating_pok_mrlb/pokdeng_mrlb_9/Text_1").text = self.language.pokdeng.prop_chip
		v:FindChild("Effect_dating_pok_mrlb/pokdeng_mrlb_9/Text_2").text = self.language.pokdeng.prop_des
		v:FindChild("Effect_dating_pok_mrlb/pokdeng_mrlb_9/Image/Text").text = self.language.pokdeng.prop_name
		v:FindChild("Effect_dating_pok_mrlb/pokdeng_mrlb_9/Num").text = self.language.pokdeng[index].prop_num
		v:FindChild("Effect_dating_pok_mrlb/pokdeng_mrlb_9x/Text_1").text = self.language.pokdeng[index].chip_num
		v:FindChild("Effect_dating_pok_mrlb/pokdeng_mrlb_9x/Text_2").text = self.language.pokdeng.max_chip
        v:FindChild("Record/Text").text = self.language.pokdeng.record_Text
        v:FindChild("Thb").text = self.language.pokdeng[index].Thb
    end
    self:FindChild("ExplainView/Frame/ScrollText/Viewport/Content/Text").text = self.language.pokdeng.Explain_des
    self:FindChild("ExplainView/Frame/Tittle/Text").text = self.language.pokdeng.Explain_title
    self:FindChild("ExplainView/Frame/BtnPay/Text").text = self.language.now_Buy
	self:FindChild("ExplainView/Frame/BtnSkip/Text").text = self.language.now_Skip
end

--中奖记录
function  DailyGiftPokdeng:InitListData()
	--播报记录数据
	local data = {[1] = "<color=#68FF00>Lisa's Loveyou</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>291595</color>ชิป",
	[2] = "<color=#68FF00>Panya...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>285836</color>ชิป",
	[3] = "<color=#68FF00>นัด ไง จะใครหละ</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>200000</color>ชิป",
	[4] = "<color=#68FF00>KK《KuKKIG》...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>599999</color>ชิป",
	[5] = "<color=#68FF00>Apicha...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>599999</color>ชิป",
	[6] = "<color=#68FF00>Prig Adisorn</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>2298026</color>ชิป",
	[7] = "<color=#68FF00>ยังง ไง๊</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>200000</color>ชิป",
	[8] = "<color=#68FF00>Nattapong...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>391799</color>ชิป",
	[9] = "<color=#68FF00>Leo Boy</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>284672</color>ชิป",
	[10] = "<color=#68FF00>Panya...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>283267</color>ชิป",
	[11] = "<color=#68FF00>โยธิน สมบูรณ์</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>1999998</color>ชิป",
	[12] = "<color=#68FF00>TopOne Dummee</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>478000</color>ชิป",
	[13] = "<color=#68FF00>KK《KuKKIG》...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>5230000</color>ชิป",
	[14] = "<color=#68FF00>การเดินทาง</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>714000</color>ชิป",
	[15] = "<color=#68FF00>Tikamporn...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>500000</color>ชิป",
	[16] = "<color=#68FF00>แฟน ต้า</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>400000</color>ชิป",
	[17] = "<color=#68FF00>##ร า ฟ ฟี่ ##</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>400000</color>ชิป",
	[18] = "<color=#68FF00>KK《KuKKIG》...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>533000</color>ชิป",
	[19] = "<color=#68FF00>KK《KuKKIG》...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>632000</color>ชิป",
	[20] = "<color=#68FF00>การเดินทาง</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>560000</color>ชิป",
	[21] = "<color=#68FF00>Montree Newz</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>299999</color>ชิป",
	[22] = "<color=#68FF00>Nisharee...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>439000</color>ชิป",
	[23] = "<color=#68FF00>Ae Sa</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>400000</color>ชิป",
	[24] = "<color=#68FF00>Mr. Panya</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>599998</color>ชิป",
	[25] = "<color=#68FF00>การเดินทาง</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>518000</color>ชิป",
	[26] = "<color=#68FF00>ฮัลโหล คิตตี้.</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>652000</color>ชิป",
	[27] = "<color=#68FF00>Tikamporn...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>285000</color>ชิป",
	[28] = "<color=#68FF00>Future Is...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>287947</color>ชิป",
	[29] = "<color=#68FF00>อิคคิว ฯ.</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>800000</color>ชิป",
	[30] = "<color=#68FF00>Kook Naka</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>1500000</color>ชิป",
	[31] = "<color=#68FF00>Por Sakkarin</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>728999</color>ชิป",
	[32] = "<color=#68FF00>อิคคิว ฯ.</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>299999</color>ชิป",
	[33] = "<color=#68FF00>คิง โพแดง</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>1000000</color>ชิป",
	[34] = "<color=#68FF00>➿##Nnuan####</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>211799</color>ชิป",
	[35] = "<color=#68FF00>เเล้วไง ใครเเคร</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>370000</color>ชิป",
	[36] = "<color=#68FF00>Ya Seen</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>1000000</color>ชิป",
	[37] = "<color=#68FF00>Ya Seen</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>2000000</color>ชิป",
	[38] = "<color=#68FF00>Ya Seen</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>1646000</color>ชิป",
	[39] = "<color=#68FF00>Ya Seen</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>387000</color>ชิป",
	[40] = "<color=#68FF00>Panya...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>2000000</color>ชิป",
	[41] = "<color=#68FF00>Panya...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>928000</color>ชิป",
	[42] = "<color=#68FF00>Panya...</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>799000</color>ชิป",
	[43] = "<color=#68FF00>Loetsin Khamtan</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>780000</color>ชิป",
	[44] = "<color=#68FF00>Loetsin Khamtan</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>400000</color>ชิป",
	[45] = "<color=#68FF00>Loetsin Khamtan</color>ได้รับรางวัลบัตรเพิ่มกำไร<color=#00EAFF>752000</color>ชิป",
	}
	local randomIndex = {}
	local idx = 0
	for i = 1, #data do
		local rnd = math.random(1, #data)
		if randomIndex[rnd] == nil then
			randomIndex[rnd] = data[rnd]
			idx = idx + 1
			if idx >= 8 then
				break
			end
		end
	end
	local list = {}
	idx = 0
	for _, v in pairs(randomIndex) do
		idx =  idx + 1
		list[idx] = v
	end
	for i = 1,#list do
		self:AddItemData(i, list[i])
	end
	local countDown = 0
	self:StartTimer("Pokdeng", 1, function()
		if countDown >= 15 then
			countDown = 0
			self:AutoRoll()
		end
		countDown = countDown + 1
    end, -1)
end

function DailyGiftPokdeng:AddItemData(index, data)
	local tran = nil
	local item = nil
	if self.PrefabTab[index] == nil then
		tran = self.Item
		item = CC.uu.newObject(tran)
		item.transform.name = tostring(index)
		self.PrefabTab[index] = item.transform
	else
		item = self.PrefabTab[index]
	end
	item.localPosition = Vector3(0, (1 - index) * 40 + 20, 0)
	item:SetActive(true)

	if item then
		item.transform:SetParent(self.Content, false)
		item.transform:GetComponent("Text").text = data
	end
end

function DailyGiftPokdeng:AutoRoll()
    for i = 1, self.Content.childCount do
		local obj = self.Content:GetChild(i - 1)
		self:RunAction(obj,  {"localMoveTo", 0, obj.localPosition.y + 40, 2 , function ()
			if obj.localPosition.y >= 60 then
				obj.localPosition = Vector3(0, (1 - self.Content.childCount) * 40 + 20, 0);
			end
		end})
	end
end

-- function DailyGiftPokdeng:OnDestroy()
-- 	self:unRegisterEvent()
-- 	self:StopTimer("Pokdeng")
-- 	if self.walletView then
-- 		self.walletView:Destroy()
-- 	end
-- end

return DailyGiftPokdeng