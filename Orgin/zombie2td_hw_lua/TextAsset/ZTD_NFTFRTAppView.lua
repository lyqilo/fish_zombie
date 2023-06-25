local GC = require("GC")
local ZTD = require("ZTD")
--NFT frt密码修改提示
local NFTFRTAppView = ZTD.ClassView("ZTD_NFTFRTAppView")

--cardType ZTD.MJGame.gameData.DameID 
function NFTFRTAppView:OnCreate()
	self.param = self._args[1]
	local lan = ZTD.LanguageManager.GetLanguage("L_ZTD_NFTView")
	self.lan = lan
	self:SetText("root/Bottom/TextTip", lan.modifyTip)
	self:SetText("root/Bottom/ButtonSure/Text", lan.modifySure)
	self:SetText("root/Bottom/InputField/Placeholder", lan.modifyPwd)
	self:SetText("root/Top/TextGameID", ZTD.PlayerData.GetPlayerId())
	self:SetText("root/Top/TextAccount", self.param.account)
	self:SetText("root/Top/TextFRT", ZTD.Extend.FormatSpecNum(self.param.frt, 6))
	
	self.inputField = self:GetCmp("root/Bottom/InputField", "InputField")
	self.pwd = ""
	UIEvent.AddInputFieldOnEndEdit(self:FindChild("root/Bottom/InputField"),
	function (val)
		self.pwd = val or ""
	end)
    
	--[[self:AddClick("root/TextGotoWeb", function()
        local url = string.format("https://ow.in-nft.com/information.html?Uid=%d",
			ZTD.PlayerData.GetPlayerId())
        Client.OpenURL(url)
		GC.SubGameInterface.OpenService()
    end)--]]
	
	local richText = self:FindChild("root/TextLine"):GetComponent("RichText")
	richText.text = [[<u><url=https://line.me/ti/p/SBhkfK9NZj>ติดต่อฝ่ายบริการช่องทางLINE@ ：@FRTService</url></u>]]
	self:AddClick("root/TextLine", function ()
		Client.OpenURL("https://lin.ee/qczAeHC")
	end)

	
	self:AddClick("Mask", function()
        self:Destroy()
    end)
	self:AddClick("root/BtnClose", function()
        self:Destroy()
    end)
	self:AddClick("root/Bottom/ButtonSure", function()
		self:ModifyPwd()
    end)
end


function NFTFRTAppView:ModifyPwd()
	if string.len(self.pwd) < 6 or string.len(self.pwd) > 20 then
		ZTD.ViewManager.ShowTip(self.lan.pwdRule)
		return
	end
	local pwd = Util.Md5(self.pwd)
	
	ZTD.Request.HttpRequest("ReqModifyPwd", {
		cid = 2,
		new_pwd = pwd,
	}, function ()
		ZTD.ViewManager.ShowTip(self.lan.operateSuccess)
	end, function ()
		logError("ReqModifyPwd error")
	end, true)
end



function NFTFRTAppView:OnDestroy()

end




return NFTFRTAppView