
local CC = require("CC")
 

local ResDownloader = CC.class2("ResDownloader")

function ResDownloader:ctor()
	self.isDownloading = false
	self.fileUrl = nil
	self.assetlistUrl = nil
	self.tipCallBack = nil
	self.rstCallBack = nil
	self.processCallBack = nil
	self.savePath = nil
	self.processCo = nil
	self.assetListContent = nil
	self.NeedUpdateMap = {}
	self.NeedReloadMap = {}
    self.wwwFileList = {}
    self.progress = 0
    self.getStart = false
end

function ResDownloader:StartDownLoad(fileUrl,assetlistName,tipCallBack,rstCallBack,processCallBack,savePath)
	self.fileUrl = fileUrl
	self.assetlistName = assetlistName
	self.assetlistUrl = self.fileUrl .. self.assetlistName
	self.tipCallBack = tipCallBack
	self.rstCallBack = rstCallBack
	self.processCallBack = processCallBack
    self.savePath = savePath

	self:CheckAssetsList()
end

function ResDownloader:CheckAssetsList()
    --计算当前已下载临时文件大小
    local completeSize = 0
    pcall(function () completeSize = Util.GetFilesSizeEndsWith(self.savePath,"temp") end) 

	local sucessCb = function(www)
		local data = www.downloadHandler.text
		--消除mac和windows不同平台导出的文件差异
		data = CC.uu.addEnterAscii(data)
		self.assetListContent = data

		log("下载AssetsList内容：" .. self.assetListContent)
		local assets = Util.GetAllSectionsItems(data, "Assets"):split('\n')

        --从本地的ini文件读取本地文件的md5值！就不使用Util.md5file了，数量多的时候会造成游戏卡顿
        local localAssetsPath = self.savePath .. self.assetlistName
        local localAssetsData = Util.ReadFile(localAssetsPath)
        localAssetsData = CC.uu.addEnterAscii(localAssetsData)
        local localAssetsContents = Util.GetAllSectionsItems(localAssetsData, "Assets"):split('\n')
        local localAssets = {}
        for _,v in ipairs(localAssetsContents) do
            local localfileName = v:split('=')[1]
            local localmd5 = v:split('=')[2]:split(',')[1]
            local localhash = v:split('=')[2]:split(',')[3] or ""
            localAssets[localfileName] = {}
            localAssets[localfileName].md5 = localmd5
            localAssets[localfileName].hash = localhash
        end
		--记录待更新的ab包
	    self.NeedUpdateMap={}
	    --需要加载或者重新加载的ab包，更新时需要重新加载所有的资源，否则可能导致某些节点绑定的预制体丢失
	    self.NeedReloadMap = {}
	    --需要更新文件的总大小
	    local todownloadsize = 0
	    for i, v in ipairs(assets) do
            --线上ab包名字
            local fileName = v:split('=')[1]
            --线上ab包md5值
            local onlinemd5 = v:split('=')[2]:split(',')[1]
            --线上ab包文件
            local fileSize = v:split('=')[2]:split(',')[2]
            --线上ab包hash值
            local onlinehash = v:split('=')[2]:split(',')[3] or ""
            
            --本地ab包路径
            local filepath = self.savePath .. fileName
            if Util.HasFile(filepath) then
            	--文件存在，比较其hash值
                local localhash = localAssets[fileName] and localAssets[fileName].hash or ""
                if string.lower(onlinehash) ~= string.lower(localhash) then
                    table.insert(self.NeedUpdateMap,{fileName = fileName, hash = onlinehash, md5 = onlinemd5, size = fileSize})    
                    todownloadsize = todownloadsize + tonumber(fileSize)
                end
            else
            	--文件不存在，直接需要更新
                table.insert(self.NeedUpdateMap,{fileName = fileName, hash = onlinehash, md5 = onlinemd5, size = fileSize})
                todownloadsize = todownloadsize + tonumber(fileSize)
            end
            table.insert(self.NeedReloadMap,fileName)
        end

        self.todownloadsize = todownloadsize

        if #self.NeedUpdateMap > 0 then
            log("此次更新文件总大小:"..CC.uu.GetByteSizeString(todownloadsize))
            CC.uu.Log(self.NeedUpdateMap, "需要下载的文件：")
	    	--提示回调，有文件更新，大小为todownloadsize个字节
	    	--如果确定下载？外部需要执行readyDownload()
	    	self.tipCallBack(true,todownloadsize - completeSize,function ()
				CC.ReportManager.SetDot("UPDATEPAGE")
                self:ReadyDownload()
            end)
	    else
	    	--提示回调，没有文件需要更新
	    	self.tipCallBack(false)
	    end
	end
	local errroCb = function(www)
		self.rstCallBack(false)
	end
    local url = CC.uu.UrlWithTimeStamp(self.assetlistUrl)
    log("AssetsList下载地址：" .. url)

    CC.HttpMgr.Get(url, sucessCb, errroCb)

end

function ResDownloader:ReadyDownload()
    self.getStart = true
    
    self:StartDownLoadAssetsFile()
    
end

function ResDownloader:StartDownLoadAssetsFile()

    coroutine.start(function() 
    	--下载过程中是否出错
        local isDownloadAllRight = true
        self.isDownloading = true

        self:DownLoadProcess()

        local fileCoList = {}
        local index = 0
        for _,v in ipairs(self.NeedUpdateMap) do

            -- 每个文件单独起一个协程下载
            local file_co = coroutine.start(function()

                local tempPath = self.savePath .. v.fileName

                local downloadData = {}
                local wwwfile
                local url

                logError("Start:"..tempPath)

                if Util.HasFile(tempPath) and string.upper(Util.md5file(tempPath)) == v.md5 then
                    -- log("跳过ab包：" .. tempPath)
                    downloadData.downloaded = true
                elseif Util.HasFile(tempPath..".temp") and string.upper(Util.md5file(tempPath..".temp")) == v.md5 then
                    -- log("跳过ab包：" .. tempPath)
                    downloadData.downloaded = true
                else
                    url = CC.uu.UrlWithTimeStamp(self.fileUrl .. v.fileName)
                    -- log("下载ab包：" .. url)
                    wwwfile = DownloadFile.StartDownload(url,tempPath)
                    
                    downloadData.wwwfile = wwwfile;
                    downloadData.downloaded = false;
                end

                table.insert(self.wwwFileList, downloadData);
                
                if wwwfile then
                    coroutine.www(wwwfile)
                    
                    if wwwfile.isDone then
                        if Util.IsNullOrEmpty(wwwfile.error) then
                            --下载成功
                            DownloadFile.Dispose(url)
                            if Util.HasFile(tempPath..".temp") and string.upper(Util.md5file(tempPath..".temp")) == v.md5 then
                                downloadData.downloaded = true;
                            else
                                Util.RemoveFile(tempPath..".temp")
                                isDownloadAllRight = false
                            end
                        else
                            --有错误信息
                            if wwwfile.responseCode == 416 then
                                --temp文件下载成功，改名失败
                                -- logError("416错误,下载成功,等待改名")
                                DownloadFile.StopDownload(url)
                                if Util.HasFile(tempPath..".temp") and string.upper(Util.md5file(tempPath..".temp")) == v.md5 then
                                    downloadData.downloaded = true;
                                else
                                    Util.RemoveFile(tempPath..".temp")
                                    isDownloadAllRight = false
                                end
                            else
                                --其他错误
                                DownloadFile.StopDownload(url)
                                isDownloadAllRight = false
                            end
                        end
                    end
                end
                index = index + 1
            end)

            table.insert(fileCoList,file_co)
        end

        -- 判断结束
        while index ~= #self.NeedUpdateMap do
            coroutine.step(1)
        end

        -- 清理协程
        for _,v in ipairs(fileCoList) do
            coroutine.stop(v)
        end
        fileCoList = nil

        if isDownloadAllRight then
            local allRenameSuccess = true
            for _,v in ipairs(self.NeedUpdateMap) do
                local oldName = self.savePath .. v.fileName
                if Util.RenameFile(oldName .. ".temp", oldName) == false then
                    allRenameSuccess = false
                    break
                end
            end
            self.isDownloading = false
            CC.uu.CancelDelayRun(self.processCo)
            --重命名成功
            if allRenameSuccess then
                --存储assetlist内容
                -- log("savePath:"..tostring(self.savePath).."   assetlistName:"..tostring(self.assetlistName).."  assetListContent:"..(type(self.assetListContent)))
                Util.WriteBytes(self.savePath .. self.assetlistName, self.assetListContent)
                --下载成功
                self.processCallBack(1.0)
                self.rstCallBack(true)
                self:DeleteInvalidFiles()
            end
        else
            --下载失败
            self.isDownloading = false
            CC.uu.CancelDelayRun(self.processCo)
            self.rstCallBack(false)
         end
    end)

end

function ResDownloader:DownLoadProcess()
    if self.isDownloading then

        self.progress = 0;
        self.bytesSize = 0
        for i, v in ipairs(self.wwwFileList) do
            if v.downloaded then
                self.bytesSize = self.bytesSize + self.NeedUpdateMap[i].size
            else
                if v.wwwfile then -- Util.IsNullOrEmpty(v.wwwfile.error) then
                    self.bytesSize = self.bytesSize + v.wwwfile.downloadHandler.DownedLength
                end
            end
        end
        self.progress = 1.0 * self.bytesSize / self.todownloadsize

        self.processCallBack(self.progress)

        --每0.1秒检测一次下载进度
       self.processCo = CC.uu.DelayRun(0.05,
            function ()
                self:DownLoadProcess()
            end
        )
    end
end

function ResDownloader:DeleteInvalidFiles()
    local localAllFile = Util.GetAllFileNameWithExtension(self.savePath,"*u3d")
    if not localAllFile then return end
    for i,localName in ipairs(localAllFile:ToTable()) do
        local delete = true
        for j,v in ipairs(self.NeedReloadMap) do
            if localName == v then
                delete = false
                break
            end
        end
        if delete then
            Util.RemoveFile(self.savePath..localName)
        end
    end
end

function ResDownloader:GetProgress()
    return self.progress
end

function ResDownloader:IsGetStart()
    return self.getStart
end

function ResDownloader:IsIniFileDownloaded()
    return self.assetListContent
end

return ResDownloader