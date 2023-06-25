local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local CountDown = GC.class2("TDCountDownUi")

function CountDown:ctor(_)

end

function CountDown:Init(countDown)
	self.language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");
	self._mainUi = ZTD.PoolManager.GetUiItem("TD_COUNT_DOWN", GameObject.Find("Main/Canvas/TopUIPanal").transform);
	self._mainUi.localPosition = Vector3.zero;
	self._text = self._mainUi:FindChild("text");
	self._text1 = self._mainUi:FindChild("text (1)");
	self._progress = self._mainUi:FindChild("img_process"):GetComponent("Image");
	
	self._progress.fillAmount = 1;
	self._text.text = countDown;
	self._text1.text = self.language.TD_COUNT_DOWN
	self._count = countDown;
	self._totalCount = countDown;
	ZTD.Flow.AddUpdateList(self);
end

function CountDown:FixedUpdate(dt)
	if ZTD.Flow.BackStageTime then
		dt = dt + ZTD.Flow.BackStageTime;
	end
	local readyCount = math.floor(self._count);
	self._count = self._count - dt;
	self._progress.fillAmount = self._count/self._totalCount;	
	if self._count <= 0 then
		self._text.text = 0;
		self._progress.fillAmount = 0;		
	elseif 	self._count <= readyCount then
		self._text.text = readyCount;
		ZTD.PlayMusicEffect("ZTD_countDown", nil, nil, true);
	end
end

function CountDown:Release()
	ZTD.Flow.RemoveUpdateList(self);
	ZTD.PoolManager.RemoveUiItem("TD_COUNT_DOWN", self._mainUi);
end

return CountDown;