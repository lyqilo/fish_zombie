local GC = require("GC")
local ZTD = require("ZTD")

local CoinFlyDrop = GC.class2("CoinFlyDrop", ZTD.CoinFlyBase)
local SUPER = ZTD.CoinFlyBase;
local bundleName = "prefab";

function CoinFlyDrop:DoPlay()
	self:Play(0.1,100,75,{x = 100,y = 150},100 * 0.5,self.durationTo)	
end

function CoinFlyDrop:Play(offsetDelay,dis_y,highX,moveSpeed,bounceY,durationTo)
    local offsetDelay = offsetDelay --每隔多少秒创建一个金币
    local dis_y = dis_y --金币开始出现时 y值，最高与最低的距离差
    local highX = highX --金币开始出现时 x的最大偏幅
    local moveSpeed = moveSpeed --金币出现时移动的速度
    local bounceY = bounceY --落地时第一次反弹的高度
    local durationTo = durationTo --金币去到目标点的总时间

    local moveUpDown = function(coin,index)
        local oriPos = coin.transform.position

        local localMoveBy = {"localMoveBy",0,bounceY,0,bounceY/moveSpeed.y,loop={2,ZTD.Action.LTYoyo},ease=ZTD.Action.EOutQuad}

        local call = {"call",function() self:DestroyCoin(coin) end}
		
        local tweenAction = {
	    {"delay", 0.5},
            call,
            onEnd = function() 
				self:TargetCallBack(); 
			end
        }
        self:StartAction(coin,tweenAction);
       
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
		self:StartAction(coin,{"localMoveBy",dis_x,0,0,dis_y/moveSpeed.y,onEnd=function() moveUpDown(coin,index) end});
		self:StartAction(coin,{
			{"localMoveBy",0,dis_y*0.678,0,dis_y*0.678/moveSpeed.y*0.5,ease=ZTD.Action.EOutQuad},
			{"localMoveBy",0,-dis_y,0,dis_y/moveSpeed.y*0.5,ease=ZTD.Action.EInQuad},
		})
    end
    for i,coin in ipairs(self.coinArray) do
        self:StartAction(coin,{{"delay",(i-1)*offsetDelay},onEnd=function() MoveAction(coin,i) end,})
    end
end
return CoinFlyDrop