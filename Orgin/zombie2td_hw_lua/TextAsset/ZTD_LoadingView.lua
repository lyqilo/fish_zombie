local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local LoadingView = ZTD.ClassView("ZTD_LoadingView")

function LoadingView:ctor()
	LoadingView.inst = self
end
	
function LoadingView:OnCreate()
    --背景
    self.Slider = self:SubGet("Slider","Slider")
    self.Slider.value = 0

    self.point = self:FindChild("Slider/Handle/point")
    self.pointActive = false

    self.percent = self:SubGet("Slider/percent","Text")
	self.percent1 = self:SubGet("Slider/percent/percent1","Text")  

    self:Init()
end

function LoadingView:Init()
    ZTD.LockPop.Init()
	ZTD.PoolManager.PreLoad()
	ZTD.SetSaveMode(ZTD.isSaveMode)
	ZTD.PlayerData.Init()
	ZTD.Flow.isStartGroupTimer = true
	ZTD.Flow.isOpenGroupTimer = true
	ZTD.Flow.isOpenDaily = true
	ZTD.Flow.isOpenGameGift = true
	ZTD.Flow.isExitGamePop = false
	ZTD.Flow.Init()
	
	ZTD.FixedUpdateAdd(self.FixedUpdate, self)
	ZTD.Flow.AddUpdateList(self)
end

function LoadingView:FixedUpdate(dt)
	self.Progress = ZTD.PoolManager.GetNowProcess();
	
	-- 资源加载完就链接网络
	if ZTD.PoolManager.IsFinish() then
		ZTD.Flow.StartNetWork()
		ZTD.Flow.RemoveUpdateList(self)
		ZTD.FixedUpdateRemove(self.FixedUpdate, self)
	else
		self:DoProgress()
	end
end	

function LoadingView:DoProgress()
	if self.Slider.value < 1 then
        self.Slider.value = self.Progress;

        if self.Slider.value > 0.01 and self.pointActive == false then
            self.pointActive = true
            self.point:SetActive(true)
        end
		
		if self.Progress > 1 then
			self.Progress = 1;
		end
		self.percent.text = math.floor(self.Progress*100).."%"
		self.percent1.text = math.floor(self.Progress*100).."%"
    end
end

function LoadingView:OnDestroy()
	LoadingView.inst = nil
	ZTD.FixedUpdateRemove(self.FixedUpdate, self)
end

return LoadingView