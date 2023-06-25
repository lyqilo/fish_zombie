--[[
	分享页
]]

local CC = require("CC")
local BaseClass = CC.uu.ClassView("AgentShareView")

function BaseClass:ctor(param)
	self.agentDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Agent")
	self.language = CC.LanguageManager.GetLanguage("L_AgentView");
	self.param = param or {}
end

function BaseClass:OnCreate()
	self:InitContent()
	self:InitTextByLanguage();
	self.msg = self.agentDataMgr.GetAgentUrl()
	local content = self:FindChild("content/NewShare")
	content:SetActive(true)

	self.param.value = self.param.value or 20
	content:FindChild("Value").text = string.format("%s%s Truemoney Wallet", self.param.value, CC.CurrencyDefine.CurrencyCode)
	self:SetImage(content:FindChild("Image"), "truemoney_card_"..self.param.value)
	-- self:FindChild("content/closeBtn"):SetActive(false)
	-- if not self.msg then
	self:FindChild("content/GroupBtn"):SetActive(false)
	self:FindChild("content/closeBtn"):SetActive(false)
	Util.CaptureScreenShot(function(texture)
		self:DelayRun(0.1, function()
			self:CaptureScreenShow(texture);
			self:GetShareUrl()
			self:FindChild("content/closeBtn"):SetActive(true)
		end)
	end);
	-- end

	CC.HallNotificationCenter.inst():register(self,	self.OnResume,CC.Notifications.OnResume)
end

function BaseClass:OnResume()
	if self.param.closeBtn then
		self:ActionOut()
		local param = {}
		param.goodsId = "100059"
		param.type = 2
		CC.ViewManager.Open("AgentExView", param)
	end
end

function BaseClass:CaptureScreenShow(texture)
	self.captureTexture = texture;
	self:FindChild("content/NewShare"):SetActive(false)

	local captureFrame = self:FindChild("content/CaptureFrame")
	captureFrame:SetActive(true)
	local textureObj = captureFrame:FindChild("CaptureTexture")
	local captureScreen = textureObj:GetComponent("Image")
	local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5))
	captureScreen.sprite = sprite

	local fadeInTime = 0.2;
	local fadeInAlpha = 255;
	local stopTime = 0.2;
	local scaleToX = 1078 / captureFrame:GetComponent('RectTransform').rect.width
	local scaleToY = 638 / captureFrame:GetComponent('RectTransform').rect.height

	self:RunAction(captureFrame, {
			{"fadeTo", fadeInAlpha, fadeInTime},
			-- {"localMoveTo", 88, -30 , 0, ease = CC.Action.EOutCubic},
			{"scaleTo", scaleToX, scaleToY, 0.3, ease = CC.Action.EOutSine},
		});

	self:RunAction(textureObj,{
			{"fadeTo", fadeInAlpha, fadeInTime, function()
					self:FindChild("content/GroupBtn"):SetActive(true)
					if self.param.guide then
						self:FindChild("content/GuidePanel"):SetActive(true)
					end
					-- self:FindChild("content/closeBtn"):SetActive(true)
				end},
			{"delay", stopTime},
		});

	-- self:RunAction(captureFrame:FindChild("Mask"),{
	-- 		{"fadeTo", fadeInAlpha, fadeInTime},
	-- 		{"delay", stopTime},
	-- 		{"fadeTo", 0, 0.5, ease = CC.Action.EOutSine},
	-- 	})
end

--获得分享链接
function BaseClass:GetShareUrl()

	CC.ViewManager.ShowLoading(true, 2);
	local param = {};
	param.file = self.captureTexture;
	param.succCb = function(imgUrl)
		local agentId = CC.Player.Inst():GetSelfInfoByKey("Id") or "0"
		local channelCode = AppInfo.ChannelID or "0"
		local data = {
			textureUrl = imgUrl,
			callback = function(url)
				self.msg = url
				self.agentDataMgr.SetAgentUrl(url)
				CC.ViewManager.CloseLoading();
			end,
			urlData = {
				channelCode = channelCode,
				agentId = agentId,
				isDeepPlayer = CC.HallUtil.CheckDeepPlayer()
			}
		}
		CC.FirebasePlugin.CreateAgentLink(data);
	end
	param.errCb = function()
		CC.ViewManager.CloseLoading();
	end;
	CC.HallUtil.UpLoadImg(param);
end

function BaseClass:InitContent()
	self.mask = self:FindChild("mask")

	self:AddClick(self:FindChild("content/closeBtn"),slot(self.ActionOut,self))
	self:FindChild("content/closeBtn"):SetActive(not self.param.closeBtn)

	self:AddClick(self:FindChild("content/GroupBtn/fbBtn"),slot(self.OnFBBtnClick,self))
	self:AddClick(self:FindChild("content/GuidePanel/Btn/fbBtn"),slot(self.OnFBBtnClick,self))
	self:AddClick(self:FindChild("content/GroupBtn/lineBtn"),slot(self.OnLineBtnClick,self))
	self:AddClick(self:FindChild("content/GroupBtn/otherBtn"),slot(self.OnOtherBtnClick,self))
	self:AddClick(self:FindChild("content/GroupBtn/Btn"),slot(self.OnBtnClick,self))

	self:FindChild("content/NewShare/Frame/PmcText").text = "PMC" .. CC.Player.Inst():GetSelfInfoByKey("Id")
end

function BaseClass:InitTextByLanguage()
	self:FindChild("content/NewShare/Text").text = self.language.codelabel
	self:FindChild("content/GroupBtn/Btn/Text").text = self.language.sharecopylink
	self:FindChild("content/GroupBtn/fbBtn/Text").text = self.language.btnFB
	self:FindChild("content/GroupBtn/lineBtn/Text").text = self.language.btnLine
	self:FindChild("content/GroupBtn/otherBtn/Text").text = self.language.btnOther
	self:FindChild("content/NewShare/Tips").text = self.language.shareTips
	self:FindChild("content/GuidePanel/Btn/fbBtn/Text").text = self.language.btnFB
	self:FindChild("content/GuidePanel/Text").text = self.language.shareGuide
end

function BaseClass:OnFBBtnClick()
	if not CC.HallUtil.JudgeHaveFacebookApp() then
		return;
	end
	if not self.msg then
		CC.ViewManager.ShowMessageBox(self.language.timeout,
			function ()
			end,
			function ()
			end
		)
		return
	end
	local data = {};
	data.contentURL = self.msg;
	data.callback = function(status)
		CC.uu.Log("Agent Share Callback -----> status:"..tostring(status));
	end
	CC.SubGameInterface.ShareLinkToFacebook(data)
end

function BaseClass:OnLineBtnClick()
	if not self.msg then
		CC.ViewManager.ShowMessageBox(self.language.timeout,
			function ()
			end,
			function ()
			end
		)
		return
	end
	CC.SubGameInterface.ShareTextToLine(self.msg)
end

function BaseClass:OnOtherBtnClick()
	if not self.msg then
		CC.ViewManager.ShowMessageBox(self.language.timeout,
			function ()
			end,
			function ()
			end
		)
		return
	end
	CC.SubGameInterface.ShareTextToOther({text = self.msg,callback = function ()
		log("----->分享成功 AgentShareView ")
	end})
end

function BaseClass:OnBtnClick()
	Util.CopyToClipboard(self.msg or "")
	CC.ViewManager.ShowTip(self.language.sharecopysucc)
end

function BaseClass:OnDestroy()

end

function BaseClass:ActionIn()
end

function BaseClass:ActionOut()
	self:SetCanClick(false);
	self:RunAction(self.transform, {
			{"fadeToAll", 0, 0.5, function() self:Destroy() end},
		});
end

return BaseClass