
local CC = require("CC")

local SelectionGameView = CC.uu.ClassView("SelectionGameView")

local NorGroupName = {
		[1] = "primary",
		[2] = "middle",
		[3] = "advanced",
		[4] = "expert",
	}

function SelectionGameView:ctor(param)
	self.param = param
end

function SelectionGameView:OnCreate()
	self.HallDefine = CC.DefineCenter.Inst():getConfigDataByKey("HallDefine")
	self.language = self:GetLanguage()

	self:InitContent()
	self.viewCtr = self:CreateViewCtr(self.param)
	self.viewCtr:OnCreate()
end

function SelectionGameView:InitContent()
	self.btnObj = self:FindChild("Layer_UI/Btn")
	self.btnParent = self:FindChild("Layer_UI/BtnLayout")
	self.gameSprite = self:FindChild("Layer_UI/SpriteNode/GameSprite"):GetComponent("Image")
	self.Spine = self:FindChild("Layer_BG/SkeletonGraphic"):GetComponent("SkeletonGraphic")
	self.Spine.AnimationState.Complete =  self.Spine.AnimationState.Complete + function ()
		self.Spine.AnimationState:ClearTracks()
        self.Spine.AnimationState:SetAnimation(0, "stand01", true)
	end
	self:AddClick("Layer_UI/BtnExit","closeView")
end

function SelectionGameView:ReFreshUI(param)
	local name = param.cardName
	if self.HallDefine.SelectIcon[name] then
		self:SetImage(self.gameSprite, self.HallDefine.SelectIcon[name].path);
		self.gameSprite:SetNativeSize()
	end
	for i,v in ipairs(param.lockSession) do
		self:CreateBtn(v)
	end
end

function SelectionGameView:CreateBtn(param)
	local btn = CC.uu.newObject(self.btnObj,self.btnParent)
	if param.VipLocked > 0 then
		self:SetImage(btn, "Btn_vip");
	else
		self:SetImage(btn, "Btn_common");
	end
	-- local icon = btn.transform:FindChild("Unlock/Detail/Image")
	-- local configId = param.MinConfigId
	-- if configId == CC.shared_enums_pb.EPC_ChouMa then
	-- 	self:SetImage(icon, "chip")
	-- end
	btn:FindChild("Unlock").text = self.language[NorGroupName[param.GroupID]].."\n"
	btn:FindChild("Unlock/Detail/Detail").text = self.language.group_detail
	btn:FindChild("Unlock/Detail/Min").text = param.MinCount
	btn:FindChild("Lock").text = "VIP"..param.VipLocked.." Unlock"
	btn:FindChild("Unlock"):SetActive(param.Bool)
	btn:FindChild("Lock"):SetActive(not param.Bool)
	local cliclEnable = false
	if CC.Player.Inst():GetSelfInfoByKey("EPC_Level") > 0 and not param.Bool and param.VipLocked <= 3 and param.VipLocked > 1 then
		cliclEnable = true
	end
	btn:GetComponent("Button"):SetBtnEnable(param.Bool or cliclEnable)

	self:AddClick(btn,function ()
		if cliclEnable then
			local isOpenView = CC.SubGameInterface.OpenVipBestGiftView({needLevel = param.VipLocked})
			if isOpenView then
				self:closeView()
				return
			elseif not param.Bool then
				return
			end
		end
		CC.uu.Log(param,"Enter====>",3)
		self:VerifyEnter(param)
	end)
end

function SelectionGameView:VerifyEnter(param)
	local chip
	local tipTooMuch
	local tipTooLess
	local tipNotEnough
	if param.MinConfigId == CC.shared_enums_pb.EPC_ChouMa then
		chip = CC.Player.Inst():GetSelfInfoByKey("EPC_ChouMa")
	elseif param.MinConfigId == CC.shared_enums_pb.EPC_TryChouMa then
		chip = CC.Player.Inst():GetSelfInfoByKey("EPC_TryChouMa")
	end
	tipTooMuch = self.language.tips_chipTooMuch
	tipTooLess = self.language.tips_chipTooLess
	tipNotEnough = self.language.tips_chipNotEnough
	if chip >= param.MinCount then
		self.viewCtr:ReqAllocServer(self.param,param.GroupID,false)
	else
		if param.GroupID == 1 then
			CC.ViewManager.ShowMessageBox(tipTooLess,function ()
				CC.ViewManager.OpenAndReplace("StoreView")
			end)
		else
			CC.ViewManager.ShowTip(string.format(tipNotEnough,param.MinCount))
		end
	end
end

function SelectionGameView:closeView()
	self:Destroy()
	CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyExitSelection)
end

function SelectionGameView:OnDestroy()
	if self.viewCtr then
		self.viewCtr:Destroy()
		self.viewCtr = nil
	end
	CC.HallNotificationCenter.inst():post(CC.Notifications.GameClick,true)
end

function SelectionGameView:ActionIn()
	self:SetCanClick(false);
	self.transform:FindChild("Layer_UI").localScale = Vector3(0.1,0.1,1)
    self:RunAction(self.transform:FindChild("Layer_UI") , {"scaleTo", 1, 1, 0.5, ease=CC.Action.EOutBack, function()
    	self:SetCanClick(true);
    end})
end


return SelectionGameView;