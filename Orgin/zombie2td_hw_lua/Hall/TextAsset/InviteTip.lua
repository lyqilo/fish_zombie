
local CC = require("CC")

local M = CC.uu.ClassView("InviteTip")

--[[
@param
des: 文本内容
second: 存在时间
callback: 回调
]]
function M:ctor(param)
	self.des = param.des or "";
    self.second = param.second or 5;
    self.teamId = param.teamId;
    self.gameId = param.gameId

    --语言包
	self.language = self:GetLanguage();
end

function M:GlobalNode()
	return GameObject.Find("DontDestroyGNode/GCanvas/GMain").transform
end

function M:OnCreate()
	self:InitContent();
	self:AddClickEvent()
    self:AddToDontDestroyNode();
    self:SetTextByLanguage();
    -- 不是本游戏或者不是在大厅，都隐藏按钮
    if not (self.gameId == CC.ViewManager.GetCurGameId() or CC.ViewManager.IsHallScene()) then
        self:HideButtons()
    end
end

function M:InitContent()

	local des = self:FindChild("Frame/Layout/Text");
	des.text = self.des;

	self:MoveIn();

	self:DelayRun(self.second, function()
			self:MoveOut();
		end)
end

function M:SetTextByLanguage()
	self:FindChild("Frame/Layout/Btn_Reject/Text").text = self.language.Reject
	self:FindChild("Frame/Layout/Btn_Agree/Text").text = self.language.Agree
end

function M:MoveIn()
	local frame = self:FindChild("Frame");
	self:RunAction(frame, {"localMoveBy", 0,  -frame.transform.height, 0.2, ease = CC.Action.EOutSine});
end

function M:MoveOut()
	local frame = self:FindChild("Frame")
	self:RunAction(frame, {"localMoveBy", 0, frame.transform.height, 0.2, ease = CC.Action.EOutSine, 
			function() 
				self:Destroy()
			end
		}
	)
end

function M:AddClickEvent()
    self:AddClick("Frame/Layout/Btn_Reject",function ()
        self:Response(false)
		self:MoveOut();
    end)
    
    self:AddClick("Frame/Layout/Btn_Agree",function ()
        self:Response(true)
		self:MoveOut();
	end)
end

function M:HideButtons()
    self:FindChild("Frame/Layout/Btn_Reject"):SetActive(false)
    self:FindChild("Frame/Layout/Btn_Agree"):SetActive(false)
end

function M:Response(bIsAgree)

    local succCb = function(code, data) 
        if data.IsAgree then
            if CC.ViewManager.IsHallScene() then
                local gameDataMgr = CC.DataMgrCenter.Inst():GetDataByKey("Game");
                local param = {}
                param.teamId = data.TeamId
                param.gameData = gameDataMgr.GetInfoByID(self.gameId)
                CC.HallUtil.EnterGame(self.gameId, param)
            else
                CC.HallNotificationCenter.inst():post(CC.Notifications.OnTeamUpAgree, {teamId=data.TeamId})
            end
        end
    end
    local errCb = function() end
    CC.SubGameInterface.ReqInviteAnswer(self.teamId, bIsAgree, succCb, errCb)
end

return M;
