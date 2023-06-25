local GC = require("GC")
local CC = require("CC")
local ZTD = require("ZTD")

local CoinFlyIconShoot = GC.class2("CoinFlyIconShoot", ZTD.CoinFlyBase)
local SUPER = ZTD.CoinFlyBase;
local bundleName = "prefab";

function CoinFlyIconShoot:DoPlay()
	self:Play(0.1, 0, 0,{x = 100,y = 150},100 * 0.5,self.durationTo)	
end

function CoinFlyIconShoot:InitCoin(coinNode, i)
	SUPER.InitCoin(self, coinNode, i);
	coinNode.transform.position = coinNode.transform.position + Vector3(0,2,0);
end

function CoinFlyIconShoot:Play(offsetDelay,dis_y,highX,moveSpeed,bounceY,durationTo)
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
    end

    local MoveAction = function(coin,index)
		coin:SetActive(true)
		moveUpDown(coin,index);
    end
    for i,coin in ipairs(self.coinArray) do
        self:StartAction(coin,{{"delay",(i-1)*offsetDelay},onEnd=function() MoveAction(coin,i) end,})
    end
	
	for i,coin in ipairs(self.coinArray) do
		self:StartAction(coin,{{"delay",(i-1)*offsetDelay},onEnd=function() MoveAction(coin,i) end,})
	end	
end
return CoinFlyIconShoot