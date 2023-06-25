local CC = require("CC")

local ActiveShareBoard = CC.uu.ClassView("ActiveShareBoard")

function ActiveShareBoard:ctor()

	self:InitVar();
end

function ActiveShareBoard:OnCreate()
	self:InitContent()
	self:InitTextByLanguage()
end

function ActiveShareBoard:InitVar()

	self.rankState = false;

	self.lotteryData = {};

	self.itemList = {};

	self.lotteryCount = 100;

	self.coroutine = nil;

	self.language = CC.LanguageManager.GetLanguage("L_ActiveEntryView");
end

function ActiveShareBoard:InitContent()

	self.rawImg = self:SubGet("Bg", "RawImage")
	local abName = CC.DefineCenter.Inst():getConfigDataByKey("ResourceDefine").Image["fx_17"]
	self.rawImg.texture = ResourceManager.LoadAsset(abName or "image", "fx_17")

	self:AddClick("RankPanel/RankBtn/Btn", "OnClickBtnRank");
	self:AddClick("BtnClose", "Destroy");
	self:AddClick("BtnFitter/BtnFaceBook", "OnClickFacebook");

	CC.ViewManager.ShowLoading(true, 1);
	self:RequestLotteryList(0,self.lotteryCount);
end

function ActiveShareBoard:InitTextByLanguage()

	self:SetText("RankPanel/InfoView/Image/Name", self.language.roleName);
	self:SetText("RankPanel/InfoView/Image/Info", self.language.winInfo);
	self:SetText("RankPanel/InfoView/Image/Tips", self.language.tips3);
	self:SetText("BtnFitter/BtnFaceBook/Text", self.language.btnfb);
end

function ActiveShareBoard:RequestLotteryList(from, to)

	local ts = os.time();
	local skip = from;
	local limit = to;
	local sign = Util.Md5(ts..skip..limit..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey());
	local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLotteryListUrl();

	local wwwForm = UnityEngine.WWWForm.New();
	wwwForm:AddField("skip", skip);
	wwwForm:AddField("limit", limit);
	wwwForm:AddField("ts", ts);
	wwwForm:AddField("sign", sign);
	CC.HttpMgr.PostForm(url, wwwForm, function(www)
			CC.ViewManager.CloseLoading();
			local data = Json.decode(www.downloadHandler.text);
			if not table.isEmpty(data.data) then
				for _,v in ipairs(data.data) do
					table.insert(self.lotteryData, v);
				end
				self:FindChild("RankPanel/InfoView/Image/Tips"):SetActive(false);

				table.sort(self.lotteryData, function(a,b) return tonumber(a.sort) < tonumber(b.sort) end)
				self.coroutine = coroutine.start(function()
					for _,v in ipairs(self.lotteryData) do
						local item = self:CreateItem(v);
						table.insert(self.itemList, item);
						coroutine.wait(0.05);
					end
				end)
			end
    	end,
    	function()
    		CC.ViewManager.CloseLoading();
    		logError("ActiveShareBoard:RequestLotteryList: failed");
    	end)
end

function ActiveShareBoard:CreateItem(param)

	local item = {};
	local obj = self:FindChild("RankPanel/InfoView/Scroller/Viewport/Item");
	local parent = self:FindChild("RankPanel/InfoView/Scroller/Viewport/Content");
	item.transform = CC.uu.newObject(obj, parent);
	item.transform:SetActive(true);

	item.transform:FindChild("Nick").text = param.nickName;
	item.transform:FindChild("Content").text = param.reward;

	local data = {}
	data.parent = item.transform:FindChild("ItemHead");
	data.portrait = param.portrait;
	data.playerId = param.userId;
	data.vipLevel = param.vipLevel;
	data.clickFunc = "unClick";
	item.headIcon = CC.HeadManager.CreateHeadIcon(data);

	return item;
end

function ActiveShareBoard:OnShowRank()

	local rankPanel = self:FindChild("RankPanel"):GetComponent("RectTransform");
	rankPanel.anchoredPosition = Vector2(-rankPanel.width);
	self:SetRankBtnState(false);
end

function ActiveShareBoard:OnHideRank()

	local rankPanel = self:FindChild("RankPanel"):GetComponent("RectTransform");
	rankPanel.anchoredPosition = Vector2.zero;
	self:SetRankBtnState(true);
end

function ActiveShareBoard:SetRankBtnState(flag)

	local scaleX = flag and 1 or -1;
	self:FindChild("RankPanel/RankBtn/Dir_l").localScale = Vector3(scaleX, 1, 1);
	self:FindChild("RankMask"):SetActive(not flag);
end

function ActiveShareBoard:OnClickBtnRank()

	self.rankState = not self.rankState;
	if self.rankState then
		self:OnShowRank();
	else
		self:OnHideRank();
	end
end

function ActiveShareBoard:OnClickFacebook()

	-- 此地址已无效 2023-05-18 luogizz
	-- Client.OpenURL("https://www.facebook.com/RoyalCasinoTH");

	Client.OpenURL(CC.UrlConfig.Facebook.MainPage)
end

function ActiveShareBoard:OnDestroy()

	for _,v in ipairs(self.itemList) do
		v.headIcon:Destroy();
	end

	if self.coroutine then
		coroutine.stop(self.coroutine)
		self.coroutine = nil
	end
end

function ActiveShareBoard:ActionIn()

end

function ActiveShareBoard:ActionOut()

end

return ActiveShareBoard