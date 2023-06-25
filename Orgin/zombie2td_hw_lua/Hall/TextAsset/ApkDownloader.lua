local CC = require("CC")

local ApkDownloader = CC.class2("ApkDownloader")

function ApkDownloader:ctor()
    self.wwwfile = nil
    self.isDownloading = false
    self.apkUrl = nil
    self.processCallBack = nil
    self.rstCallBack = nil
    self.savePath = nil
    self.processCo = nil
    self.progress = 0
end

function ApkDownloader:StartDownLoad(apkUrl, rstCallBack, processCallBack, savePath)
    --apkUrl：apk的下载地址
    --processCallBack：下载进度反馈
    --rstCallBack：下载结果反馈，成功与否
    --savePath: apk保存路径
    self.apkUrl = apkUrl
    self.processCallBack = processCallBack
    self.rstCallBack = rstCallBack
    self.savePath = savePath

    local url = CC.uu.UrlWithTimeStamp(self.apkUrl)
    log("APK下载地址：" .. url)

    coroutine.start(
        function()
            self.wwwfile = UnityWebRequest.Get(url)
            self.isDownloading = true
            self:DownLoadProcess()
            self.wwwfile:SendWebRequest()
            coroutine.www(self.wwwfile)

            if Util.IsNullOrEmpty(self.wwwfile.error) then
                self.isDownloading = false
                --下载成功
                Util.WriteBytes(self.savePath, self.wwwfile.downloadHandler.data)
                --反馈下载进度
                self.processCallBack(self.wwwfile.downloadProgress)
                CC.uu.CancelDelayRun(self.processCo)
                self.rstCallBack(true)
            else
                --下载失败
                CC.uu.CancelDelayRun(self.processCo)
                self.rstCallBack(false)
            end
            self.wwwfile:Dispose()
        end
    )
end

function ApkDownloader:DownLoadProcess()
    if self.isDownloading then
        if Util.IsNullOrEmpty(self.wwwfile.error) then
            --反馈下载进度
            self.progress = self.wwwfile.downloadProgress
            self.processCallBack(self.wwwfile.downloadProgress)
        end
        --每0.1秒检测一次下载进度
        self.processCo =
            CC.uu.DelayRun(
            0.1,
            function()
                self:DownLoadProcess()
            end
        )
    end
end

function ApkDownloader:GetProgress()
    return self.progress
end

return ApkDownloader
