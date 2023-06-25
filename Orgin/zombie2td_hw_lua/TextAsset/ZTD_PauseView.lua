local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local PauseView = ZTD.ClassView("ZTD_PauseView")
function PauseView:ctor()

end

function PauseView:OnCreate()
	self.tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_PauseView");
    self:Init();
end

function PauseView:Init()
	self:PlayAnimAndEnter();

	self:FindChild("image_bg/music_icon/Text").text = self.language.music
	self:FindChild("image_bg/volume_icon/Text").text = self.language.volume
	self:FindChild("image_bg/energe_icon/Text").text = self.language.energe
	self:FindChild("Buttons/help/Text").text = self.language.help

	self:SetEffectButton()
	self:SetMusicButton()
	self:SetSaveButton()
	local func 
	func = function()
		self:PlayAnimAndExit()
		GC.Sound.Save()
	end
	self:AddClick("image_bg/close2",func)
	self:AddClick("mask",func)

	
	self:AddClick("Buttons/help", function()
        self:onHelp();
    end)

	self:AddClick("Buttons/music", function()
        self:onMusic();
    end)

	self:AddClick("Buttons/volume", function()
        self:onEffect();
    end)

	self:AddClick("Buttons/energe", function()
        self:onSave();
    end)
	--logError(">>>>>>>>>>>>>>> pauseview memory:" .. collectgarbage("count"))
end

function PauseView:SetEffectButton()

	local imgName = "btn_bat_on_T"
	if ZTD.isEffectMute then
		imgName = "btn_bat_off_T"
	end
	local texture = ResMgr.LoadAssetSprite("prefab", imgName)
	self:FindChild("Buttons/volume"):GetComponent("Image").sprite = texture

	-- imgName = "view_state_audio_open"
	-- if ZTD.isEffectMute then
	-- 	imgName = "view_state_audio_close"
	-- end
	--local texture = ResMgr.LoadAssetSprite("images", imgName)
	--self:FindChild("image_bg/volume_icon"):GetComponent("Image").sprite = texture
end

function PauseView:SetMusicButton()
	local imgName = "btn_bat_on_T"
	if ZTD.isMusicMute then
		imgName = "btn_bat_off_T"
	end
	local texture = ResMgr.LoadAssetSprite("prefab", imgName)
	self:FindChild("Buttons/music"):GetComponent("Image").sprite = texture

	-- imgName = "view_state_music_open"
	-- if ZTD.isMusicMute then
	-- 	imgName = "view_state_music_close"
	-- end
	--local texture = ResMgr.LoadAssetSprite("images", imgName)
	--self:FindChild("image_bg/music_icon"):GetComponent("Image").sprite = texture
end

function PauseView:SetSaveButton()
	local imgName = "btn_bat_on_T"
	if ZTD.isSaveMode then
		imgName = "btn_bat_off_T"
	end
	local texture = ResMgr.LoadAssetSprite("prefab", imgName)
	self:FindChild("Buttons/energe"):GetComponent("Image").sprite = texture

	-- imgName = "view_state_energe_close"
	-- if ZTD.isSaveMode then
	-- 	imgName = "view_state_energe_open"
	-- end
	--local texture = ResMgr.LoadAssetSprite("images", imgName)
	--self:FindChild("image_bg/energe_icon"):GetComponent("Image").sprite = texture
end

function PauseView:onHelp()
	ZTD.ViewManager.Open("ZTD_HelpView")
end

function PauseView:onMusic()
	ZTD.SetMusicMute(not ZTD.isMusicMute)
	self:SetMusicButton()
	local tip = self.tipLanguage.MusicMute.Off
	if ZTD.isMusicMute then
		tip = self.tipLanguage.MusicMute.On
	end
	ZTD.ViewManager.ShowTip(tip)
end

function PauseView:onEffect()
	ZTD.SetEffectMute(not ZTD.isEffectMute)
	self:SetEffectButton()
	local tip = self.tipLanguage.EffectMute.Off
	if ZTD.isEffectMute then
		tip = self.tipLanguage.EffectMute.On
	end
	ZTD.ViewManager.ShowTip(tip)
end

function PauseView:onSave()
	ZTD.SetSaveMode(not ZTD.isSaveMode)
	self:SetSaveButton()
	local tip = self.tipLanguage.SaveMode.Off
	if ZTD.isSaveMode then
		tip = self.tipLanguage.SaveMode.On
	end
	ZTD.ViewManager.ShowTip(tip)
end	

return PauseView