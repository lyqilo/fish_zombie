local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu


local GD = {}
function GD.Init(Data)
	-- log("新手引导 Data="..GC.uu.Dump(Data))
	GD.StepInfo = {};

	if Data == nil then
		local guideCfgs = ZTD.GuideConfig;
		for guideInx = 1, #guideCfgs do	
			local gCfg = guideCfgs[guideInx];
			GD.StepInfo[gCfg.step] = true;
		end	
	else
		for _, v in ipairs(Data.GuideInfo) do
			GD.StepInfo[v.GuideStep] = v.IsFinsh;
		end	
	end
	
	GD.isGuide = false
	GD.IsInit = true;
	GD.StartCheck();
end

function GD.FinshGuide(step)
	GD.isGuide = false
	GD.StepInfo[step] = true;
end

GD.StepData = {};
function GD.SetNowGuide(step, status)
	GD.StepData[step] = status;
end	

function GD.GetNowGuide(step)
	return GD.StepData[step];
end	

function GD.IsGuide()
	return GD.isGuide
end

function GD.StartCheck()
	local guideCfgs = ZTD.GuideConfig;

	local bindsMap = {};
	for guideInx = 1, #guideCfgs do	
		local gCfg = guideCfgs[guideInx];
		
		if not GD.StepInfo[gCfg.step] then
		
			if not bindsMap[gCfg.bindGameMsg] then				
				bindsMap[gCfg.bindGameMsg] = {};
			end
			
			local t = bindsMap[gCfg.bindGameMsg];
			local mapInx = #t + 1;
				
			local function startGuide(_, bindView, bindNode)
				local guideCfg = ZTD.GuideConfig[guideInx];
				-- 如果该步骤已完成，退出该步新手引导
				if GD.StepInfo[guideCfg.step] then
					ZTD.Notification.GameUnregister(GD, guideCfg.bindGameMsg);
					--如果有，激活下一个新手引导
					local nextInx = mapInx + 1;
					if t[nextInx] then
						ZTD.Notification.GameRegister(GD, guideCfg.bindGameMsg, t[nextInx]);
					end					
					return;
				end	
				
				bindNode = bindNode or bindView.transform;
				local mv = ZTD.GuideMask:new();
				GD.isGuide = true
				mv.___bindMapInx = mapInx;
				local function onFinsh()
					ZTD.Notification.GameUnregister(GD, mv._guideCfg.bindGameMsg);
					--如果有，激活下一个新手引导
					local nextInx = mv.___bindMapInx + 1;
					mv.___bindMapInx = nil;
					if t[nextInx] then
						ZTD.Notification.GameRegister(GD, mv._guideCfg.bindGameMsg, t[nextInx]);
					end
				end
				
				local isReqStep = false;
				if guideCfgs[guideInx + 1] == nil then
					isReqStep = true;
				elseif guideCfgs[guideInx + 1].step > gCfg.step then
					isReqStep = true;	
				end
				mv:Init(guideInx, bindView, bindNode, isReqStep, onFinsh);			
			end
			
			t[mapInx] = startGuide;					
			
			if mapInx == 1 then
				ZTD.Notification.GameRegister(GD, gCfg.bindGameMsg, startGuide);
			end
		
		end
	end

end

function GD.Release()
	GD.StepData = {}
	GD.isGuide = nil
	ZTD.Notification.GameUnregisterAll(GD);
end

return GD