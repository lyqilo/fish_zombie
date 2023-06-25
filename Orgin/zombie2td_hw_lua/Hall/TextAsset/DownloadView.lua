local CC = require("CC")
local DownloadView = CC.uu.ClassView("DownloadView")

function DownloadView:ctor(param)
	self.param = param
    self.download = false
end

function DownloadView:OnCreate()
    self:RegisterEvent()
    self.language = {
        [1] = "ชวนเพื่อนจะได้รับบัตรของขวัญจำนวนมากมาย ชวนเพื่อนยิ่งมากรางวัลยิ่งเยอะ!",
        [2] = "เข้าร่วมภารกิจจะได้รับรางวัลบัตรของขวัญจำนวนมากมาย!",
        [3] = "สะสมบัตรของขวัญสามารถแลกรางวัลที่ร้านค้าแลกรางวัลได้มากมาย!",
        [4] = "กรอกข้อมูลตนเองครบอัพเกรดความปลอดภัยในบัญชีถึงจะใช้ฟังก์ชั่นส่งชิปอย่างสบายใจ!",
    }
    self:InitTextByLanguage();
end

function DownloadView:RegisterEvent()
	CC.HallNotificationCenter.inst():register(self,self.DownloadProcess,CC.Notifications.DownloadGame)
    CC.HallNotificationCenter.inst():register(self,self.DownloadFail,CC.Notifications.DownloadFail)
end

function DownloadView:unRegisterEvent()
	CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadGame)
    CC.HallNotificationCenter.inst():unregister(self,CC.Notifications.DownloadFail)
end

function DownloadView:DownloadProcess(data)
    if data.gameID ~= self.param.GameId then return end
	local process = data.process
    if process < 1 then
        self:FindChild("progress/Text").text = string.format("%.0f",process * 100) .. "%"
        self:FindChild("Slider"):GetComponent("Slider").value = process
    elseif process >= 1 then
        if data.isFinish and not self.download then
            self.download = true
            CC.HallUtil.EnterGame(data.gameID, nil, function()
                CC.ViewManager.CloseAllOpenView()
            end)
        end
	end
end

function DownloadView:DownloadFail(id)
    CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyExitSelection)
	self:CloseView()
end

function DownloadView:InitTextByLanguage()
    local rd = math.random(1, #self.language)
    self:FindChild("Text").text = self.language[rd]
    local countDown = 2
    local Timeout = 20
    self:StartTimer("ChangeDownload", 1, function()
		countDown = countDown - 1
        Timeout = Timeout - 1
        if countDown <= 0 then
            rd = rd % #self.language + 1
			self:FindChild("Text").text = self.language[rd]
            countDown = 2
		end
        if Timeout < 0 then
            Timeout = 180
            self:DownloadTimeOut()
        end
    end, -1)
end

function DownloadView:DownloadTimeOut()
    CC.ViewManager.OpenMessageBoxEx("อินเตอร์เน็ตดาวน์โหลดช้าลง ต้องการดาวน์โหลดเกมต่อไหม？",
        function()
            --确定继续
            -- CC.ReportManager.SetDot("GUIDEDOWNLOADGO")
        end,
        function()
            self:DownloadFail()
            -- CC.ReportManager.SetDot("GUIDEDOWNLOADCANCE")
        end
    )
end

--关闭界面
function DownloadView:CloseView()
	self:Destroy()
end

function DownloadView:ActionIn()
end
function DownloadView:ActionOut()
end

function DownloadView:OnDestroy()
    self:StopTimer("ChangeDownload")
    self:unRegisterEvent()
end

return DownloadView