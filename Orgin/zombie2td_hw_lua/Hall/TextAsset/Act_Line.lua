
local CC = require("CC")
local Act_Line = CC.uu.ClassView("Act_Line")
--VIP活动
function Act_Line:ctor(content)
	self.content = content	
	self.accountBinding = false
end

function Act_Line:OnCreate()
	self.transform:SetParent(self.content.transform, false)
	self:BlindLine()
end

--绑定Line
------------------------------------------------------------------------------------------------------------------------
function Act_Line:BlindLine()
	local language = CC.LanguageManager.GetLanguage("L_PersonalInfoView");
	self:AddClick("BG",function ()
		if self.accountBinding then
			return;
		end
		self.accountBinding = true;
 		local successCallback = function(lineData)
                local data = {};
		        data.LineId = lineData.user_id;
		        data.LineToken = lineData.access_token;
                CC.Request("BindLine",data,function(err, data)
		        		--Line绑定成功
		        		local loginData = CC.Player.Inst():GetLoginInfo();
						loginData.BindingFlag = bit.bor(loginData.BindingFlag, CC.shared_enums_pb.EF_LineBinded);
						CC.ViewManager.OpenRewardsView({items = {{ConfigId = 2, Count = 5000}},title = "BindLine",callback = function()
							CC.ViewManager.BackToLogin(CC.DefineCenter.Inst():getConfigDataByKey("LoginDefine").LoginType.AutoLine);
						end})
						self:SetCanClick(false)
		        	end, function(err)
		        		--line绑定失败
		        		if err == CC.shared_en_pb.LineAlreadyBinded then
		        			CC.ViewManager.ShowTip(language.lineLoginTips1);
		        		else
		        			CC.ViewManager.ShowTip(language.lineLoginTips4);
		        		end
		        		self.accountBinding = false;
		        		CC.LinePlugin.Logout();
		        	end)
                  
		    end
	
    	local errCallBack = function()
    			CC.ViewManager.ShowTip(language.lineLoginTips2);
    			self.accountBinding = false;
			end
	
		--如果没有绑定过Line,走Line绑定流程
		CC.LinePlugin.Login(successCallback, errCallBack);
	end)
end
------------------------------------------------------------------------------------------------------------------------

function Act_Line:OnDestroy()
end

return Act_Line