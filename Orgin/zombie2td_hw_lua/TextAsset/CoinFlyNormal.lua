local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")

local CoinFlyNormal = GC.class2("CoinFlyNormal", ZTD.CoinFlyBase)
local SUPER = ZTD.CoinFlyBase;
local bundleName = "prefab";

function CoinFlyNormal:DoPlay()
	self:Play(0.1,100,75,{x = 100,y = 150},100 * 0.5,self.durationTo)	
end

function CoinFlyNormal:Play(offsetDelay,dis_y,highX,moveSpeed,bounceY,durationTo)
    local offsetDelay = offsetDelay --每隔多少秒创建一个金币
    local dis_y = dis_y --金币开始出现时 y值，最高与最低的距离差
    local highX = highX --金币开始出现时 x的最大偏幅
    local moveSpeed = moveSpeed --金币出现时移动的速度
    local bounceY = bounceY --落地时第一次反弹的高度
    local durationTo = durationTo --金币去到目标点的总时间
    local moveUpDown = function(coin,index)
        local oriPos = coin.transform.position
        local isActive = 0
        local ctrlPos = (oriPos+self.targetPos)*0.5 + Vector3(math.random(15,-15),math.random(5,-5),0)
		--local ctrlPos = oriPos;

        local localMoveBy = {"localMoveBy",0,bounceY,0,bounceY/moveSpeed.y,loop={2,ZTD.Action.LTYoyo},ease=ZTD.Action.EOutQuad}
        local to = {"to",1,100,durationTo,function(value)
            --延缓一帧打开拖尾
            isActive = isActive + 1
            if isActive == 8 then
                coin:FindChild("jinbi/Trail"):SetActive(true)
                coin:FindChild("jinbi/Trail").gameObject:GetComponent("TrailRenderer").enabled = true
            end
            -- 这里是二阶贝塞尔曲线的实现
            local t = value*0.01
            local u = 1-t
            local tt = t*t
            local uu = u*u
            local p = Vector3(uu*oriPos.x,uu*oriPos.y,uu*oriPos.z)
            p = p + Vector3(2*u*t*ctrlPos.x,2*u*t*ctrlPos.y,2*u*t*ctrlPos.z)
            p = p + Vector3(tt*self.targetPos.x,tt*self.targetPos.y,tt*self.targetPos.z)
            coin.transform.position = p
        end,ease=ZTD.Action.EInQuad
        }
        local call = {"call",function() self:DestroyCoin(coin) end}
		
        local tweenAction = {
	    {"delay", 0.5},
            to,
            call,
            onEnd = function()
				self:TargetCallBack(); 
			end
        }
       self:StartAction(coin,tweenAction)
       
		local randomX = 0;--math.random(-30,30)
		local randomY = math.random(-100,100)
		self:StartAction(coin,{
			{"localMoveBy",randomX,0,0,bounceY/moveSpeed.y},
			{"localMoveBy",randomX*0.5,0,0,bounceY/moveSpeed.y*0.5},
		})
    end

    local MoveAction = function(coin,index)
		coin:SetActive(true)
		local dis_x = math.random(-highX,highX)
		self:StartAction(coin,{"localMoveBy",dis_x,0,0,dis_y/moveSpeed.y,onEnd=function() moveUpDown(coin,index) end})
		self:StartAction(coin,{
			{"localMoveBy",0,dis_y*0.678,0,dis_y*0.678/moveSpeed.y*0.5,ease=ZTD.Action.EOutQuad},
			{"localMoveBy",0,-dis_y,0,dis_y/moveSpeed.y*0.5,ease=ZTD.Action.EInQuad},
		})
    end
    for i,coin in ipairs(self.coinArray) do
        self:StartAction(coin,{{"delay",(i-1)*offsetDelay},onEnd=function() MoveAction(coin,i) end,})
    end
end
return CoinFlyNormal