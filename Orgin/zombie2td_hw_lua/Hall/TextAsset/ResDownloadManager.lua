local CC = require("CC")
--游戏资源下载管理类
local ResDownloadManager = {}

--内嵌游戏现在进度
local gameResDownloader = {}

--检查大厅资源热更
function ResDownloadManager.CheckHall(tipCall,processCall)

	CC.ReportManager.SetDot("GETVERSION")
    local language = CC.LanguageManager.GetLanguage("L_ResDownloadManager")

    if CC.DebugDefine.GetHallDebugState() then
        CC.uu.DelayRun(0,ResDownloadManager.EnterLogin)
        return
    end

    --ios提审状态直接跳过更新
    if CC.ChannelMgr.GetIosTrailStatus() then
        ResDownloadManager.EnterLogin()
        return
    end

	--本地大版本号
	local localBigVersion = tonumber(AppInfo.version)
	--本地热更资源版本号
    local localHotresVersion = tonumber(Util.GetFromPlayerPrefs("LocalAssetsVersion")) or 0
    --上次下载版本号
    local lastVersion = tonumber(Util.GetFromPlayerPrefs("LastVersion")) or 0

    local data = CC.DataMgrCenter.Inst():GetDataByKey("Update").GetHallUpdateInfo()

    --线上大版本号
    local bigVersion = data.bigVersion
    --线上大版本包大小
    -- local bigSize = data.bigSize
    --线上大版本包的路径
    local packagePath = CC.DataMgrCenter.Inst():GetDataByKey("Update").GetPackagePath()
    --线上热更资源版本号
    local hotresVersion = data.version
    --是否跳过热更资源版本号强制检测热更资源
    local forceUpdate = data.forceUpdate
    --线上热更资源路径
    local hotresPath = CC.DataMgrCenter.Inst():GetDataByKey("Update").GetHotresPath()
    local envState = CC.DebugDefine.GetWebConfigState()
    if CC.Platform.isWin32 and (envState == CC.DebugDefine.EnvState.Dev or envState == CC.DebugDefine.EnvState.StableDev) then
        hotresPath = string.gsub(hotresPath, "/android/", "/win32/")
    end

    local gameName = "Hall"

    if bigVersion > localBigVersion then

        log("大版本更新, 本地:"..localBigVersion.." 线上:"..bigVersion)
        --if CC.ChannelMgr.CheckOppoChannel() then
        ResDownloadManager.CheckAppCommonUpdate(packagePath)
        --else
            --ResDownloadManager.CheckAppUpdate(packagePath)
        --end

    elseif bigVersion == localBigVersion then
    	--（1）热更版本号0，表示新发布整包资源，无需更新
    	--（2）本地版本号不同于线上版本号,并且线上版本号大于0，更新
    	--（3）强制更新字段为true时更新（测试服会使用到，正式上线该字段为false）
        log("版本更新：本地 " .. localHotresVersion .. " 线上 " .. hotresVersion)
        if hotresVersion ~= localHotresVersion  or forceUpdate then
            --先删除文件夹内失效temp文件
            if lastVersion ~= hotresVersion then
                local savePath = Util.dataPath
                Util.DeleteSomeKindFiles(savePath,"*.temp")
                Util.SaveToPlayerPrefs("LastVersion",hotresVersion)
            end
    		local doDownLoadAssets = nil
    		doDownLoadAssets = function()
    			tipCall(language.download_res_do)
        		--检测并更新游戏资源
        		local fileUrl = string.format("%s/%s/%s/%s/", hotresPath, gameName, bigVersion, hotresVersion)
        		local assetlistName = "AssetsList.ini"
        		local tipCallBack = function(isNeedDOwnload,todownloadsize,readyDownload)
        			--下载提示回调
        			--isNeedDOwnload为false表示没有更新内容，为true表示有更新内容
        			--isNeedDOwnload为true时，todownloadsize才有意义，表示下载文件的总大小，单位为字节（B）
        			--isNeedDOwnload为true时，readyDownload才有意义，这是个方法，执行它才会执行游戏资源下载操作
        			if isNeedDOwnload then
        				local size = CC.uu.GetByteSizeString(todownloadsize)
        				CC.ViewManager.ShowMessageBox(language.check_res_size .. size,function()
        					readyDownload()
        				end,
        				function()
        					ResDownloadManager.SafeQuit()
        				end)
        			else
        				--无需更新，直接进入游戏
                        Util.SaveToPlayerPrefs("LocalAssetsVersion",hotresVersion)
        				ResDownloadManager.EnterLogin()
        			end
        		end
        		local rstCallBack = function(rst)
                    if rst then
                		--下载成功,存储资源版本号
                        Util.SaveToPlayerPrefs("LocalAssetsVersion",hotresVersion)
						CC.ReportManager.SetDot("UPDATESUCC")
                        --重新加载资源，进入游戏
                		GameManager:ReloadHallAssetBundles(function()
                			-- log("下载大厅资源成功，重新加载资源")
                            --先把之前的require置空，加载框架部分lua
                			vLuaReloadLocal()
                            --然后重新定义大厅的类表
                			local Main = require("Main")
            				Main.Init()
            				--准备进入游戏，为什么这里要重新require("CC"),并且用CC.ResDownloadManager呢
                            --因为热更完，这个function外的代码都可能改变了，这样可以拿到最新的代码
                            local CC = require("CC")
            				CC.ResDownloadManager.EnterLogin(true)
            			end)
                	else
                		--下载失败，提示是否重新下载
                		CC.ViewManager.ShowMessageBox(language.download_fail,
						        function()
									CC.ReportManager.SetDot("UPDATEFAIL")
						            doDownLoadAssets()
						        end,
						        function()
						            ResDownloadManager.SafeQuit()
						        end
						    )
                	end
        		end
        		local processCallBack = function(process)
                	--process：下载进度 0 ~1
                	processCall(process)
                end
                local savePath = Util.dataPath
        		local downloader = CC.ResDownloader.new()
        		downloader:StartDownLoad(fileUrl,assetlistName,tipCallBack,rstCallBack,processCallBack,savePath)
        	end
        	doDownLoadAssets()
        else
              --无需更新，直接进入游戏
            ResDownloadManager.EnterLogin()
    	end
    else
          --无需更新，直接进入游戏
        ResDownloadManager.EnterLogin()
    end

    tipCall(language.check_version_do)
end

--检查游戏资源热更
function ResDownloadManager.CheckGame(gameId,callback)
    local language = CC.LanguageManager.GetLanguage("L_ResDownloadManager")
    local callback = callback or function() end

    if CC.DebugDefine.GetGameDebugSkipState() then
        callback()
        return
    end

    if ResDownloadManager.IsGetDownloader(gameId) then
        CC.ViewManager.ShowTip(language.download_res_do)
        return
    end

    local data = CC.DataMgrCenter.Inst():GetDataByKey("Update").GetUpdateInfoByID(gameId)

    --需要通过gameId获取游戏模块名字
    local gameName = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetProNameByID(gameId)

    --下载开始和完成提示名称
    local tipName = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetGameNameByID(gameId)

    local version = data.version

    local forceUpdate = data.forceUpdate
    if CC.DebugDefine.GetGameDebugUpdateState() then
        log("-------------------------------Debug模式下开启游戏强更状态----------------------------------")
        forceUpdate = true
        local savePath = Util.dataPath .. gameName .. "/"
        Util.DeleteSomeKindFiles(savePath,"*.temp")
        CC.LocalGameData.SetDownLoadVersion(gameId,version)
    end

    local hotresPath = CC.DataMgrCenter.Inst():GetDataByKey("Update").GetHotresPath()
    local envState = CC.DebugDefine.GetWebConfigState()
    if CC.Platform.isWin32 and (envState == CC.DebugDefine.EnvState.Dev or envState == CC.DebugDefine.EnvState.StableDev) then
        hotresPath = string.gsub(hotresPath, "/android/", "/win32/")
    end

    --如果取不到本地版本号，默认返回0，表示本地没有资源，所以线上资源必定不能配置0作为游戏版本号
    --不同于大厅，大厅资源是肯定存在的，大厅线上资源版本号0表示提审
    local localVersion = CC.LocalGameData.GetGameVersion(gameId)
    --上次下载版本号
    local lastVersion = CC.LocalGameData.GetDownLoadVersion(gameId)
    log("版本更新：本地 " .. localVersion .. " 上次下载" .. lastVersion .." 线上 " .. version)
    if localVersion ~= version or forceUpdate then
        --先删除文件夹内失效temp文件
        if lastVersion ~= version then
            local savePath = Util.dataPath .. gameName .. "/"
            Util.DeleteSomeKindFiles(savePath,"*.temp")
            CC.LocalGameData.SetDownLoadVersion(gameId,version)
        end
        --有资源更新
        local doDownLoadAssets = nil
        doDownLoadAssets = function()
            --检测并更新游戏资源
            local gameRes = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetResNameByID(gameId)
            local fileUrl = string.format("%s/%s/%s/", hotresPath, gameRes, version)
            local assetlistName = gameRes .. "AssetsList.ini"
            local tipCallBack = function(isNeedDOwnload,todownloadsize)
                --下载提示回调
                --isNeedDOwnload为false表示没有更新内容，为true表示有更新内容
                --isNeedDOwnload为true时，todownloadsize才有意义，表示下载文件的总大小，单位为字节（B）
                --isNeedDOwnload为true时，readyDownload才有意义，这是个方法，执行它才会执行游戏资源下载操作
                if not isNeedDOwnload  then
                    --无需更新，将对应下载器从队列中移除
                    ResDownloadManager.DelDownloader(gameId)
                    --无需更新，存储版本号，直接进入游戏
                    CC.LocalGameData.SetGameVersion(gameId,version)
                    CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadGame,{gameID = gameId,process = 1,isFinish  = true})
                    -- CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadAssetsList,{gameID = gameId,state = true})
                    callback()
                else
                    if forceUpdate then
                        ResDownloadManager.ShowDownloadTip(gameId)
                    end
                    -- CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadAssetsList,{gameID = gameId,state = true})
                end
                --检查是否有下个下载资源
                ResDownloadManager.CheckResDownloadQueue()
            end
            local rstCallBack = function(rst)
                --下载成功后需要将对应下载器从队列中移除
                ResDownloadManager.DelDownloader(gameId)
                --下载结果出来后，检查是否有下个下载资源
                ResDownloadManager.CheckResDownloadQueue()
                if rst then
                    --下载成功,存储版本号，进入游戏
                    CC.LocalGameData.SetGameVersion(gameId,version)
                    --下载成功提示
                    CC.ViewManager.ShowTip(tipName..language.download_res_finish)
                    CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadGame,{gameID = gameId,process = 1,isFinish = true})
                else
                    --下载失败,如何操作?
                    CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadFail,gameId)
                    CC.ViewManager.OpenMessageBoxEx(tipName..language.download_fail,
                        function()
                            doDownLoadAssets()
                            CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadGame,{gameID = gameId,process = 0})
                        end,
                        function()
                            --取消下载,执行对应操作
                        end
                    )
                end
            end
            local processCallBack = function(process)
                --process：下载进度 0 ~1
                CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadGame,{gameID = gameId,process = process})
            end
            local savePath = Util.dataPath .. gameName .. "/"
            local downloader = CC.ResDownloader.new()
            ResDownloadManager.AddDownloader(gameId,downloader,forceUpdate)
            downloader:StartDownLoad(fileUrl,assetlistName,tipCallBack,rstCallBack,processCallBack,savePath)
        end
        doDownLoadAssets()

    else
        --没有资源更新，直接进入游戏
        callback()
        CC.HallNotificationCenter.inst():post(CC.Notifications.OnNotifyGuide)
        CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadGame,{gameID = gameId,process = 1,isFinish  = true})
    end
end

--检查下载队列
function ResDownloadManager.CheckResDownloadQueue()

    local numAllAtOnce = 2
    --同是下载两个，所以最多只需要查看前面两个downloader即可
    for k,v in ipairs(gameResDownloader) do
        local downloader = v.downloader
        if k < (numAllAtOnce + 1) then
            if not downloader:IsGetStart() and downloader:IsIniFileDownloaded() then
                downloader:ReadyDownload()
            end
        end
    end
end

--是否有下载器
function ResDownloadManager.IsGetDownloader(id)
    for _,v in ipairs(gameResDownloader) do
        local gameId = v.gameId
        if gameId == id then
            return true
        end
    end
    return false
end

--删除下载器
function ResDownloadManager.DelDownloader(id)
    local delIndex = nil
    for i,v in ipairs(gameResDownloader) do
        local gameId = v.gameId
        if id == gameId then
            delIndex = i
            break
        end
    end
    if delIndex ~= nil then
        table.remove(gameResDownloader,delIndex)
    end
end

--添加下载器
function ResDownloadManager.AddDownloader(gameId,downloader,forceUpdate)
    table.insert(gameResDownloader,{gameId = gameId,downloader = downloader})
    --强更状态下需要等ini文件下载完后再显示提示
    if forceUpdate then return end

    ResDownloadManager.ShowDownloadTip(gameId)
end

--检查下载器状态
function ResDownloadManager.CheckDownloaderState()
    for _,v in ipairs(gameResDownloader) do
        local gameId = v.gameId
        local downloader = v.downloader
        CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadGame,{gameID = gameId,process = downloader:GetProgress()})
    end
end

function ResDownloadManager.ShowDownloadTip(gameId)
    --先显示下载loading条
    CC.HallNotificationCenter.inst():post(CC.Notifications.DownloadGame,{gameID = gameId,process = 0})
    --开始下载提示
    local language = CC.LanguageManager.GetLanguage("L_ResDownloadManager")
    local tipName = CC.DataMgrCenter.Inst():GetDataByKey("Game").GetGameNameByID(gameId)
    CC.ViewManager.ShowTip(tipName..language.download_res_start)
end

--下载大厅资源完成，或者木有需要更新的，进入大厅界面
function ResDownloadManager.EnterLogin(isUpdated)

    local callback = function()
        CC.WebUrlManager.UpdateAPI()
		CC.ReportManager.SetDot("STARTAPP")
        CC.HallCenter.InitAfterLoading()
        CC.ViewManager.CommonEnterMainScene()
    end
    if isUpdated then
        -- log("更新完成后重新拉取相关信息")
        CC.WebUrlManager.ReqEntryConfig(callback)
    else
        callback();
    end
end

--退出游戏，如果是PC编辑器下的则直接进游戏
function ResDownloadManager.SafeQuit()
    if Application.isEditor or CC.Platform.isWin32 then
        ResDownloadManager.EnterLogin()
    else
        Application.Quit()
    end
end

function ResDownloadManager.CheckAppUpdate(packagePath)
    local language = CC.LanguageManager.GetLanguage("L_ResDownloadManager")
    local doUpdate
    doUpdate = function()
        local param = {
            str = language.check_app_update,
            posY = 55, height = 400, btnY = -150,
            btnOkText = language.btn_download,
            okFunc = function ()
                if CC.Platform.isIOS then
                    --再次弹出提示框，以免app没刷新，玩家又跳了回来
                    doUpdate()
                    Client.OpenURL(packagePath)
                elseif CC.Platform.isAndroid then
                    --再次弹出提示框，以免app没刷新，玩家又跳了回来
                    doUpdate()
                    if Util.CheckHttpUrl(packagePath) then
                        --配置的URL
                        Client.OpenURL(packagePath)
                    else
                        --配置的包名
                        local marketUrl = "market://details?id="..packagePath;
                        Client.GotoAPPStore(marketUrl);
                    end
                else
                    ResDownloadManager.EnterLogin()
                end
            end

        }
        local box = CC.ViewManager.MessageBoxExtend(param);
        box:SetOneButton();
    end
    doUpdate();
end

function ResDownloadManager.CheckAppCommonUpdate(packagePath)
    local language = CC.LanguageManager.GetLanguage("L_ResDownloadManager")
    local messtr = CC.Platform.isIOS and language.check_ios_new or language["check_"..AppInfo.ChannelID.."_new"];
    messtr = not messtr and language.check_common_new or messtr;
    --整包更新全部走商店下载
    local doUpdate
    doUpdate = function()
        CC.ViewManager.ShowMessageBox(messtr,
            function ()
                if CC.Platform.isIOS then
                    --再次弹出提示框，以免app没刷新，玩家又跳了回来
                    doUpdate()
                    Client.OpenURL(packagePath)
                elseif CC.Platform.isAndroid then
                    --再次弹出提示框，以免app没刷新，玩家又跳了回来
                    doUpdate()
                    if Util.CheckHttpUrl(packagePath) then
                        --配置的URL
                        Client.OpenURL(packagePath)
                    else
                        --配置的包名
                        local marketUrl = "market://details?id="..packagePath;
                        Client.GotoAPPStore(marketUrl);
                    end
                else
                    ResDownloadManager.EnterLogin()
                end
            end,
            function ()
                ResDownloadManager.SafeQuit()
            end
        )
    end
    doUpdate();
end

return ResDownloadManager