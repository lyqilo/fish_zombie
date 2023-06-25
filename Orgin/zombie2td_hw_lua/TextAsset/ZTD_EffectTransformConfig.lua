local CC = require("CC")
local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local TdEnemyEffConfig = {
	-- 毒爆怪预爆炸圈
	{
		name = "TD_Effect_dubaoguai";
		-- 默认坐标点
		offset = Vector3(0, -0.2, 0);
		-- 默认大小
		scale = Vector3(1.5, 1.5, 1.5);
		
		-- 作用在敌人身上时
		on_enemy = 
		{
		}
	},
	
	-- 毒爆怪预爆中毒烟
	{
		name = "TD_Effect_fumo";
		offset = Vector3(0, 0, 0);
		scale = Vector3(1, 1, 1);
		
		on_enemy = 
		{
			[4003] = 
			{
				offset = Vector3(0, -0.2, 0);
				scale = Vector3(0.2, 0.2, 0.2);				
			},
			[4004] = 
			{
				offset = Vector3(0, 0, 0);
				scale = Vector3(0.2, 0.2, 0.2);				
			},
			[4000] = 
			{
				offset = Vector3(0, 0, 0);
				scale = Vector3(0.3, 0.3, 0.3);				
			},
			[4001] = 
			{
				offset = Vector3(0, 0, 0);
				scale = Vector3(0.3, 0.5, 0.4);				
			},
			[4002] = 
			{
				offset = Vector3(0, 0, 0);
				scale = Vector3(0.2, 0.2, 0.2);				
			},
			[10002] = 
			{
				offset = Vector3(0, 0, 0);
				scale = Vector3(0.8, 0.8, 0.8);				
			},
			[10003] = 
			{
				offset = Vector3(0, 0, 0);
				scale = Vector3(0.9, 0.9, 0.9);				
			},
		}
	},	
	
	-- 毒爆怪爆炸烟
	{
		name = "SS_04_01_baoza02_circle";
		offset = Vector3(0, 0, 0);
		scale = Vector3(1, 1, 1);
		
		on_enemy = 
		{
			[4003] = 
			{
				offset = Vector3(0, -0.3, 0);
				scale = Vector3(0.75, 0.75, 0.75);			
			},
			[4004] = 
			{
				offset = Vector3(0, -0.2, 0);
				scale = Vector3(0.75, 0.75, 0.75);			
			},
			[4000] = 
			{
				offset = Vector3(0, -0.2, 0);
				scale = Vector3(0.75, 0.75, 0.75);			
			},
			[4001] = 
			{
				offset = Vector3(0, -0.2, 0);
				scale = Vector3(0.75, 0.75, 0.75);			
			},
			[4002] = 
			{
				offset = Vector3(0, -0.2, 0);
				scale = Vector3(0.75, 0.75, 0.75);			
			},
			[10002] = 
			{
				offset = Vector3(0, -0.2, 0);
				scale = Vector3(0.75, 0.75, 0.75);			
			},
			[10003] = 
			{
				offset = Vector3(0, 0, 0);
				scale = Vector3(0.75, 0.75, 0.75);			
			},
		}
	},	
	
	-- 夜王召唤尸鬼龙特效
	{
		name = "TD_Efffect_ywzhaohuan";
		offset = Vector3(0, 0, 0);
		scale = Vector3(1, 1, 1);
		
		on_enemy = 
		{		
		}
	};
	
	-- 夜王召唤尸鬼龙特效2(飞行道具)
	{
		name = "TD_Efffect_ywtou";
		offset = Vector3(0, 0, 0);
		scale = Vector3(1, 1, 1);
		
		
		on_enemy = 
		{
			[10004] = 
			{
				offset = Vector3(0, 0, 0);
				scale = Vector3(1, 1, 1);			
				

				-- 针对怪物的特殊运动函数
				doActFunc = function(eff, enemyCtrl)
					ZTD.PlayMusicEffect("Ghost_bullet");
					eff:SetActive(false);
					
					-- 1下 2右 3上 4左
					local dirInx = enemyCtrl._dir;
					local moveByAct;
					if dirInx == 2 then
						eff.localRotation = Quaternion.FromToRotation(Vector3.right, Vector3(1, 0, 0));
						moveByAct = {"localMoveBy", 2, 0, 0, 0.25}
					elseif dirInx == 4 then	
						eff.localRotation = Quaternion.FromToRotation(Vector3.right, Vector3(-1, 0, 0));
						moveByAct = {"localMoveBy", -2, 0, 0, 0.25}
					elseif dirInx == 3 then
						eff.localRotation = Quaternion.FromToRotation(Vector3.right, Vector3(0, 1, 0));
						moveByAct = {"localMoveBy", 0, 2, 0, 0.25}
					elseif dirInx == 1 then
						eff.localRotation = Quaternion.FromToRotation(Vector3.right, Vector3(0, -1, 0));
						moveByAct = {"localMoveBy", 0, -2, 0, 0.25}
					end
					
					
					
					ZTD.Extend.RunAction(eff, {
						{"delay", 1, onEnd = function()eff:SetActive(true);end}
						,moveByAct,
						{"delay", 0, onEnd = function()
						local tuowei1 = eff:FindChild("tou/tuowei2");
						local tuowei2 = eff:FindChild("tou/tuowei3");
						
						--tuowei1:SetActive(false);
						--tuowei2:SetActive(false);
						
						local mapPos = ZTD.MainScene.GetMapObj().position;
						local targetPos = Vector3(mapPos.x - 10, mapPos.y, mapPos.z);
						local function checkFunc(value, tgPos)
							if value > 10 then
								--tuowei1:SetActive(true);
								--tuowei2:SetActive(true);
							end	

							--if (value > 0 and (value % 5 == 0)) then
								local dir = Vector3.Normalize(tgPos - eff.position);
								eff.localRotation = Quaternion.FromToRotation(Vector3.right, dir)
							--end
						end
						
						local function endFunc()
						end
						
						local p1 = eff.position + (targetPos - eff.position) * 0.5 + Vector3(0, 5, 0);
						local bezUpHeroAct = ZTD.Extend.RunBezier(targetPos, eff.position, eff, checkFunc, endFunc, 0.8, p1);						
					end}
					})
					
				end													
			}
		}
	}	
}

return TdEnemyEffConfig;