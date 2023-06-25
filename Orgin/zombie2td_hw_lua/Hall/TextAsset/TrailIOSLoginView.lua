local CC = require("CC")

local TrailIOSLoginView = CC.uu.ClassView("TrailIOSLoginView")
local viewCtrClass = require("View/TrailView/TrailIOSLoginViewCtr")

local CC = require("CC")

local TrailIOSLoginView = CC.uu.ClassView("TrailIOSLoginView")

function TrailIOSLoginView:ctor(param)
	self.param = param
end

function TrailIOSLoginView:OnCreate()
	self.notice = self:FindChild("NoticeParent/Notice")
	self.noticeIsShow = false

	self.viewCtr = viewCtrClass.new(self, self.param);
	self.viewCtr:OnCreate();

	self:InitContent();
	self:InitTextByLanguage();
end

function TrailIOSLoginView:GetLanguage()

	return CC.LanguageManager.GetLanguage("L_LoginView")
end

function TrailIOSLoginView:InitContent()
	self.ShowBG = self:FindChild("LoadingNode/BG")

	self:AddClick("BtnPanel/BtnFacebook", "OnClickFacebook", nil, true);

	self:AddClick("BtnPanel/BtnSmall/BtnGuest", "OnClickGuest", nil, true);

	self:AddClick("BtnPanel/BtnLine", "OnClickLine", nil, true);

	self:AddClick("BtnPanel/BtnService", "OnClickService", nil, true);

	self:AddClick("Exit",function () Application.Quit() end,nil,true)

	self:AddClick("NoticeBtn",function ()
		self:Show()
	end)

	self:AddClick("NoticeParent/Notice/Back",function ()
		self:Hide()
	end)

	self:AddClick("DebugListener/Node1", "OnclickNode1")
	self:AddClick("DebugListener/Node2", "OnclickNode2")

	self.loadingPercent = self:FindChild("LoadingNode/LoadingPtg");

	self:RunAction(self:FindChild("LoadingNode/CircleImg"), {'rotateBy', 360, 2, loop=-1})

	if not CC.ChannelMgr.GetSwitchByKey("bHasGuestLogin") or CC.ChannelMgr.GetIosTrailStatus() then
		local btnGuest = self:FindChild("BtnPanel/BtnSmall/BtnGuest");
		btnGuest:SetActive(false);
	end

	if CC.ChannelMgr.GetSwitchByKey("bHasChannelLogin") then

		self:FindChild("BtnPanel/BtnOppo"):SetActive(true);
		self:AddClick("BtnPanel/BtnOppo", "OnClickOppo", nil, true);
	end

	if CC.ChannelMgr.GetSwitchByKey("bHasAppleLogin") then
		local version = AppleUtil.GetSystemVersion();
		version = CC.uu.splitString(version, ".")[1];
		if version ~= "" and tonumber(version) >= 13 then
			self:FindChild("BtnPanel/BtnSmall/BtnApple"):SetActive(true);	
			self:AddClick("BtnPanel/BtnSmall/BtnApple", "OnClickApple", nil, true);
		end
	end

	-- if CC.ChannelMgr.GetIosTrailStatus() then
		local btnPanel = self:FindChild("BtnPanel");
		btnPanel.y = btnPanel.y + 100;
		btnPanel:FindChild("BtnSmall"):SetActive(false);
		btnPanel:FindChild("BtnTrailApple"):SetActive(true);
		self:AddClick("BtnPanel/BtnTrailApple", "OnClickApple", nil, true);
		btnPanel:FindChild("BtnTrailGuest"):SetActive(true);
		self:AddClick("BtnPanel/BtnTrailGuest", "OnClickGuest", nil, true);
		self:FindChild("Icon"):SetActive(false);
		btnPanel:FindChild("BtnService"):SetActive(false);
	-- end

	self:RandomShowBG()
end

function TrailIOSLoginView:InitTextByLanguage()
	local language = self:GetLanguage();
	local btnGuest = self:FindChild("BtnPanel/BtnSmall/BtnGuest/Text");
	btnGuest.text = language.btnGuest;
	local btnExit = self:FindChild("Exit/Text")
	btnExit.text = language.exit
	-- self:FindChild("BtnPanel/BtnFacebook/Text").text = language.btnFB
	self:FindChild("BtnPanel/BtnFacebook/Node/Text").text = "5000"
	-- self:FindChild("BtnPanel/BtnLine/Text").text = language.btnLine
	self:FindChild("BtnPanel/BtnLine/Node/Text").text = "5000"
	local btnOppo = self:FindChild("BtnPanel/BtnOppo/Text");
	btnOppo.text = language.btnOppo;
	-- self:SetText("BtnPanel/BtnTrailApple/Text", language.btnApple)
	-- self:SetText("BtnPanel/BtnTrailGuest/Text", language.btnGuest)

	local tips = self:FindChild("BtnPanel/Mask/Tips");
	tips.text = language.loginTips;
end

function TrailIOSLoginView:RefreshUI(param)

	if param.showBtns ~= nil then
		local btnPanel = self:FindChild("BtnPanel");
		btnPanel:SetActive(param.showBtns);
	end

	if param.percent then
		if not self.loadingPercent then
			self.loadingPercent = self:FindChild("LoadingNode/LoadingPtg");
		end
		self.loadingPercent.text = param.percent.."%";
	end

	if param.showPercent ~= nil then
		local loadingNode = self:FindChild("LoadingNode");
		loadingNode:SetActive(param.showPercent);
	end
end

function TrailIOSLoginView:RefreshNotice(param)
	self:FindChild("NoticeParent/Notice/Viewport/Content/Title").text = param.Title
	self:FindChild("NoticeParent/Notice/Viewport/Content/Content").text = param.Content
	LayoutRebuilder.ForceRebuildLayoutImmediate(self:FindChild("NoticeParent/Notice/Viewport/Content"))
end

function TrailIOSLoginView:Show()
	if not self.noticeIsShow then
		self.noticeIsShow = true
		self:SetCanClick(false)
		self:FindChild("NoticeBtn"):SetActive(false)
		self:RunAction(self.notice,  {"localMoveTo", self.notice.transform.x + 680, self.notice.transform.y, 0.2, ease=CC.Action.EOutSine,function ()
			self:SetCanClick(true)
		end})
	end
end

function TrailIOSLoginView:Hide()
	if self.noticeIsShow then
		self.noticeIsShow = false
		self:SetCanClick(false)
		self:RunAction(self.notice,  {"localMoveTo", self.notice.transform.x - 680, self.notice.transform.y, 0.2, ease=CC.Action.EOutSine,function ()
			self:FindChild("NoticeBtn"):SetActive(true)
			self:SetCanClick(true)
		end})
	else
		self:FindChild("NoticeBtn"):SetActive(true)
	end
end

function TrailIOSLoginView:ShowNotice(show)
	if show and not self.noticeIsShow then
		self.noticeIsShow = true
		self:SetCanClick(false)
		self:FindChild("NoticeBtn"):SetActive(false)
		self:RunAction(self.notice,  {"localMoveTo", self.notice.transform.x + 680, self.notice.transform.y, 0.2, ease=CC.Action.EOutSine,function ()
			self:SetCanClick(true)
		end})
	else
		self:FindChild("NoticeBtn"):SetActive(false)
	end
end

function TrailIOSLoginView:UnderMaintenance()
	if not self.noticeIsShow then
		self.noticeIsShow = true
		self:SetCanClick(false)
			self:FindChild("NoticeBtn"):SetActive(false)
			self:RunAction(self.notice,  {"localMoveTo", self.notice.transform.x + 680, self.notice.transform.y, 0.2, ease=CC.Action.EOutSine,function ()
				self:SetCanClick(true)
		end})
		self:FindChild("Exit"):SetActive(true)
	end
end

function TrailIOSLoginView:RandomShowBG()
	local rd = math.random(1 ,3)
	if CC.ChannelMgr.GetTrailStatus() then
		--提审用第三张loading图
		rd = 2;
	end
	self:SetRawImageFromAb(self.ShowBG, "loading_ggt_"..rd);
	self.ShowBG:SetActive(true)
end

function TrailIOSLoginView:OnClickFacebook()

	self.viewCtr:OnFacebookLogin();
	self:Hide()
end

function TrailIOSLoginView:OnClickGuest()

	self.viewCtr:OnGuestLogin();
	self:Hide()
end

function TrailIOSLoginView:OnClickApple()
	log("OnClickApple  111111111")
	self.viewCtr:OnAppleLogin();
	self:Hide()
end

function TrailIOSLoginView:OnClickLine()

	self.viewCtr:OnLineLogin();
	self:Hide()
end

function TrailIOSLoginView:OnClickOppo()

	self.viewCtr:OnOppoLogin();
	self:Hide()
end

function TrailIOSLoginView:OnClickService()

	self.viewCtr:OnOpenService();
end

function TrailIOSLoginView:OnclickNode1()

	self.viewCtr:OnAddNodeCount(1)
end

function TrailIOSLoginView:OnclickNode2()

	self.viewCtr:OnAddNodeCount(2)
end

function TrailIOSLoginView:OnDestroy()

	if self.viewCtr and self.viewCtr.Destroy then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
	end
end

return TrailIOSLoginView