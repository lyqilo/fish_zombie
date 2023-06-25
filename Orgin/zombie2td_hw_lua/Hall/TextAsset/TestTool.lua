
local CC = require("CC")

local TestTool = {}

local isInit;

function TestTool.Init()

	if not CC.DebugDefine.GetDebugMode() or isInit or not CC.Platform.isWin32 then 
		return 
	end

	isInit = true;

	Timer.New(TestTool.Update, 0, -1):Start();
end


function TestTool.Update()

	if not CC.ViewManager.IsHallScene() then
		return
	end

	if Input.GetKeyDown(UnityEngine.KeyCode.T) then
		CC.ViewManager.Open("WorldCupView")
		do return end
		-- local json = {agentCode = 1, test = 2}
		--local data = {dynamicLink = "https://www.baidu.com?"..CC.uu.urlEncode("agent=1&test=2")}
		--FirebaseUtil.CreateShortDynamicLink(Json.encode(data), function(url) logError("url:"..url) end);
		-- TestTool.TestFunc1();
		-- TestTool.TestFunc2();
		-- TestTool.TestFunc5();
		-- CC.ViewManager.Open("CaptureScreenShareView")
		-- TestTool.TestFunc12();
		-- TestTool.TestFunc14()
		-- local data = {};
		-- data.imgName = "share_1_1"
		-- CC.ViewManager.Open("ImageShareView",data)
		-- CC.ViewManager.Open("DailyLotteryShareView",{desc = "123"});
		-- local data = {
		-- 	Items = {
		-- 		{
		-- 			ConfigId = 10002,
		-- 			Count = 1
		-- 		}
		-- 	}
		-- }
		-- CC.ViewManager.OpenRewardsView({items = data.Items, needShare = true});
		local wareCfg = CC.ConfigCenter.Inst():getConfigDataByKey("Ware")
		log(CC.uu.Dump(wareCfg["com.huoys.royalcasino.DMSJ29"], "+++++++"))
		-- CC.ViewManager.Open("PackageTestView");

		-- local AsynCall = require("Common/AsynCall")

		-- local model = {}
		-- function model:TestFunc(params, callback)
		-- 	local data = nil

		-- 	-- do something and wait for the callback
		-- 	(function ()
		-- 		logError(params)
		-- 		data = {1,2,3}

		-- 		if data and params == "p1" then
		-- 			callback(0,"ok",data)
		-- 		else
		-- 			callback(-1,"data is nil",data)
		-- 		end
		-- 	end)()
			
		-- end

		-- AsynCall.run(function ()
		-- 	for i=1,1 do
		-- 		local code, msg, info = AsynCall.call(model, 'TestFunc', 'p1')
		-- 	    if code == 0 then
		-- 	    	logError(msg)
		-- 	        logError(CC.uu.Dump(info))
		-- 	    else
		-- 	        logError(msg)
		-- 	    end

		-- 	    code, msg, info = AsynCall.call(model, 'TestFunc', 'p2')
		-- 	    if code == 0 then
		-- 	    	logError(msg)
		-- 	        logError(CC.uu.Dump(info))
		-- 	    else
		-- 	        logError(msg)
		-- 	    end
		-- 	end

		-- end)
	elseif Input.GetKeyDown(UnityEngine.KeyCode.R) then
		TestTool.TestFunc3()
		-- CC.ViewManager.CloseAllOpenView()
	elseif Input.GetKeyDown(UnityEngine.KeyCode.E) then
		-- TestTool.TestFunc4();
		-- CC.ViewManager.Open("NoviceSignInView")
		-- CC.ViewManager.SetNoticeBordAlpha(0.5)
		--CC.ViewManager.OpenRewardsView({items = {{ConfigId = 2, Count = 5000}},title = "BindFacebook"})
		local view = CC.ViewManager.GetViewByName("HCoinView")
		if view then
			view:ActionOut()
		else
			CC.ViewManager.Open("HCoinView")
		end
	elseif Input.GetKeyDown(UnityEngine.KeyCode.F1) then
		TestTool.RefreshText()
	elseif Input.GetKeyDown(UnityEngine.KeyCode.F2) then
		TestTool.SwitchLanguage()
	elseif Input.GetKeyDown(UnityEngine.KeyCode.F5) then
		TestTool.TestFunc3()
	end
end

--实时刷新所有文本翻译
function TestTool.RefreshText()
	local path = Application.dataPath.."/_GameCenter/ClientLua/Model/Language/Chinese"
	local files = Util.GetAllFileNameWithExtension(path, "*.lua");
	for _,c in ipairs(files:ToTable()) do
		for _,v in pairs({"Chinese","Thai"}) do
			local path = string.format("Model/Language/%s/%s", v, string.gsub(c, ".lua", ""))
			package.loaded[string.gsub(path,"/",".")] = nil;
			require(path)
		end
	end
	
	TestTool.TestFunc3()
end

--重新require界面语言文本配置
function TestTool.RequireLanguageScript(viewName)
	local path = string.format("Model/Language/Chinese/%s", "L_"..viewName)
	pcall(function ()
			package.loaded[string.gsub(path,"/",".")] = nil;
			require(path)
		end)
	path = string.format("Model/Language/Thai/%s", "L_"..viewName)
	pcall(function ()
			package.loaded[string.gsub(path,"/",".")] = nil;
			require(path)
		end)
end

--切换语言
function TestTool.SwitchLanguage()
	
	local lan = CC.DebugDefine.DebugInfo.lan

	CC.DebugDefine.DebugInfo.lan = lan == 2 and 1 or 2

	TestTool.TestFunc3()
end

--测试vip经验条显示异常
function TestTool.TestFunc1()
	CC.Player.Inst():ChangeProp({Items = {
			{ConfigId = CC.shared_enums_pb.EPC_Experience, Count = 11000000, Delta = -29000000}
		}});
	CC.HallNotificationCenter.inst():post(CC.Notifications.changeSelfInfo,{{ConfigId = CC.shared_enums_pb.EPC_Experience, Delta = -29000000}})

	local func = function()
		CC.Player.Inst():ChangeProp({Items = {
				{ConfigId = CC.shared_enums_pb.EPC_Experience, Count = 40000000, Delta = 40000000}
			}});
		CC.HallNotificationCenter.inst():post(CC.Notifications.changeSelfInfo,{{ConfigId = CC.shared_enums_pb.EPC_Experience, Delta = 40000000}})	
	end

	CC.uu.DelayRun(0, function() func()  end)

	local func = function()	
		CC.Player.Inst():ChangeProp({Items = {
				{ConfigId = CC.shared_enums_pb.EPC_Level, Count = 1, Delta = 1}
			}});
		CC.HallNotificationCenter.inst():post(CC.Notifications.changeSelfInfo,{{ConfigId = CC.shared_enums_pb.EPC_Level, Delta = 1}})	
	end
	CC.uu.DelayRun(0.05, function() func()  end)
end

--json去除转义
function TestTool.TestFunc2()
	local url = "D:/Unity2017/OverSeaHall_Arm64-v8a_b/Assets/_GameCenter/ClientLua/GetMessageList.json"
	CC.HttpMgr.Get(url, function(www)
			local tb = {}
			local t1 = Json.decode(www.downloadHandler.text)

			for _,v in ipairs(t1.data) do

				local t = {};
				for key,c in pairs(v) do
					t[key] = c; 
				end
				t.MessageContent = Json.decode(v.MessageContent);
				table.insert(tb, t);
			end
			local jt = {}
			jt.status = 1;
			jt.data = tb;
			jt.msg = "Success";
			

			local json = Json.encode(jt)
			json = string.gsub(json, "\\", "")
			local file = io.open("D:/Unity2017/OverSeaHall_Arm64-v8a_b/Assets/_GameCenter/ClientLua/GetMessageList_out.json", "w+b")
		      if file then
		        if file:write(json) == nil then return false end
		        io.close(file)
		      end
		end);
	local url = "D:/Unity2017/OverSeaHall_Arm64-v8a_b/Assets/_GameCenter/ClientLua/GameConfig_out.json"
	CC.HttpMgr.Get(url, function(www)
			local t1 = Json.decode(www.downloadHandler.text)
			CC.uu.Log(t1,"====",3)
		end)
end

function TestTool.TestFunc3()
	--刷新当前界面脚本
	local view = CC.ViewManager.GetCurrentView();
	local param = view._args;
	if view.viewName == "FreeChipsCollectionView" or view.viewName == "DailyGiftCollectionView" or view.viewName == "SelectGiftCollectionView" 
	    or view.viewName == "RankCollectionView" or view.viewName == "ActivityCollectionView" or view.viewName == "AgentNewView" then
		TestTool.RequireScript(view.currentView.viewName)
		if not view._args[1] then
			view._args[1] = {}
		end
		view._args[1].currentView = view.currentView.viewName
	elseif view.viewName == "HallView" then
		TestTool.RequireScript("GameList")
	elseif view.viewName == "WorldCupView" then
		local t = {"WorldCupMainView","WorldCupRankView", "ScheduleBoard"}
		for _,v in pairs(t) do 
			TestTool.RequireScript(v)
		end
	end

	view:Destroy();
	TestTool.RequireScript(view.viewName)
	
	if view.viewName == "HallView" or view.viewName == "LoginAwardView" or view.viewName == "LoginView" then
		CC.ViewManager.Replace(view.viewName,unpack(param));
	else
		CC.ViewManager.Open(view.viewName,unpack(param));
	end
end

--重新require界面脚本
function TestTool.RequireScript(viewName)
	local viewPath = CC.ViewCenter.View2FilePath[viewName];
	package.loaded[string.gsub(viewPath.."Ctr","/",".")] = nil;
	package.loaded[string.gsub(viewPath,"/",".")] = nil;
	CC.ViewCenter[viewName] = nil;
	CC.ViewCenter[viewName] = require(viewPath)
end

function TestTool.TestFunc4()
	--刷新ViewCenter内非界面脚本
	local luaFiles = {"VIPCounter", "ChipCounter", "DiamondCounter", "NumberRoller", "OnlineAward"};
	for _,v in ipairs(luaFiles) do
		local viewPath = CC.ViewCenter.View2FilePath[v];
		package.loaded[string.gsub(viewPath,"/",".")] = nil;
		-- CC.ViewCenter[v]:Destroy();
		CC.ViewCenter[v] = nil;
		CC.ViewCenter[v] = require(viewPath);
	end
	--刷新翻译脚本
	local languageFiles = {"L_VIPRightShow"};
	local language = CC.LanguageManager.GetType();
	for _,v in ipairs(languageFiles) do
		local path = string.format("Model/Language/%s/%s", language, v);
		package.loaded[string.gsub(path,"/",".")] = nil;
		require(path);
	end

	local luaPath = {"View/PackageTestView/PackageUtils"}
	for _,v in ipairs(luaPath) do
		package.loaded[string.gsub(v,"/",".")] = nil;
		require(v);
	end
end

function TestTool.TestFunc5()
	local func = function()
		Application.targetFrameRate = math.random(10, 60);
	end
	Timer.New(func, 0, -1):Start();
end

function TestTool.TestFunc6()
    local width = UnityEngine.Screen.width;
    local height = UnityEngine.Screen.height;
    local texture = Texture2D(width, height, UnityEngine.TextureFormat.RGB24, false);
    texture:ReadPixels(UnityEngine.Rect(0, 0, width, height), 0, 0);
    texture:Apply();
    local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5));
    local object = GameObject.Find("TestObject"):GetComponent("Image");
    object.sprite = sprite;
end

function TestTool.TestFunc7()
	CC.uu.Log(Client.GetSDCardPath(),"=====sdcardPath=====",3)
	CC.uu.Log(Client.GetUUID(),"========getUUID===========", 3)

	local data = {
		a = 1,
		b = 2
	}
	Util.SaveFileByXXTea(Client.GetSDCardPath().."/RoyalCasinoGame/GameData", Json.encode(data));

	local data = Util.LoadFileByXXTea(Client.GetSDCardPath().."/RoyalCasinoGame/GameData");
	CC.uu.Log(Json.decode(data), "==========", 3)
end

function TestTool.TestFunc8()
	--google横幅广告
	local data = {};
	data.onAdLoaded = function() logError("bannerAd loaded..") end
	local banner = CC.GoogleAdsPlugin.CreateBannerAds(data);

	CC.uu.DelayRun(10, function()
			banner:Destroy();
		end)
end

function TestTool.TestFunc9()
	--google视频广告
	local rewardAd;
	local data = {};
	data.onAdLoaded = function() logError("rewardAd loaded..") rewardAd:Show() end
	data.onAdFailedToLoad = function(sender, args) logError("rewardAd load failed.."..args.Message) end
	data.onAdOpening = function() logError("rewardAd onAdOpening....") end
	data.onAdClosed = function() logError("rewardAd onAdClosed....") end
	data.onAdFailedToShow = function() logError("rewardAd onAdFailedToShow...") end
	data.onUserEarnedReward = function(sender, args) logError("rewardAd EarnedReward: type-"..args.Type.."  amount-"..args.Amount) end
	rewardAd = CC.GoogleAdsPlugin.CreateRewardedAds(data);
end

function TestTool.TestFunc10()
	--facebook图片分享
	local b = UnityEngine.ImageConversion.EncodeToPNG(texture);
	FacebookUtil.SharePhoto(b);	
end

function TestTool.TestFunc11()
	--截屏获取图片
	Util.CaptureScreenShot();
	CC.uu.DelayRun(0, function()
			local url = "file://"..Util.captureScreenPath;
			CC.HttpMgr.GetTexture(url, function(www)
					if www.downloadHandler.texture then
						local texture = www.downloadHandler.texture;
						local sprite = Sprite.Create(texture, UnityEngine.Rect(0,0,texture.width,texture.height), Vector2(0.5,0.5));
					end
				end, function() 
					logError("not get the image from phone");
				end);
		end);
end

function TestTool.TestFunc12()
	local data = {
		Items = {
			{
			    Id = 24,
			    Name = "DailyLottery",
			    Desc = "DailyLottery",
			    Type = 1,
			    Platforms ={
			    	{
				        OS = 1,
				        Open = true,
				        Show = true
			    	},
			    	{
				        OS = 2,
				        Open = true,
				        Show = true
			    	},
			    }
			},
			{
			    Id = 10,
			    Name = "TopWin",
			    Desc = "TopWin",
			    Type = 1,
			    Platforms ={
			    	{
				        OS = 1,
				        Open = true,
				        Show = true
			    	},
			    	{
				        OS = 2,
				        Open = true,
				        Show = true
			    	},
			    }
			},
			{
			    Id = 1,
			    Name = "OnlineWelfare",
			    Desc = "OnlineWelfare",
			    Type = 1,
			    Platforms ={
			    	{
				        OS = 1,
				        Open = true,
				        Show = true
			    	},
			    	{
				        OS = 2,
				        Open = true,
				        Show = true
			    	},
			    }
			},
		}
	}
	CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetInfo( data )
end

function TestTool.TestFunc13()
	local data = {
		Items = {
			{
			    Id = 24,
			    Name = "DailyLottery",
			    Desc = "DailyLottery",
			    Type = 1,
			    Platforms ={
			    	{
				        OS = 1,
				        Open = false,
				        Show = false
			    	},
			    	{
				        OS = 2,
				        Open = true,
				        Show = true
			    	},
			    }
			},
			{
			    Id = 10,
			    Name = "TopWin",
			    Desc = "TopWin",
			    Type = 1,
			    Platforms ={
			    	{
				        OS = 1,
				        Open = false,
				        Show = false
			    	},
			    	{
				        OS = 2,
				        Open = true,
				        Show = true
			    	},
			    }
			},
			{
			    Id = 1,
			    Name = "OnlineWelfare",
			    Desc = "OnlineWelfare",
			    Type = 1,
			    Platforms ={
			    	{
				        OS = 1,
				        Open = false,
				        Show = false
			    	},
			    	{
				        OS = 2,
				        Open = true,
				        Show = true
			    	},
			    }
			},
		}
	}
	CC.DataMgrCenter.Inst():GetDataByKey("Activity").SetInfo( data )
end

function TestTool.TestFunc14()
	local ts = os.time();
	local skip = 15;
	local limit = 30;
	local sign = Util.Md5(ts..skip..limit..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey());
	--local url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLotteryListUrl();
	local url = "http://test.ghv2.huoys.com/Api/LotteryList"
	local wwwForm = UnityEngine.WWWForm.New();
	wwwForm:AddField("skip", skip);
	wwwForm:AddField("limit", limit);
	wwwForm:AddField("ts", ts);
	wwwForm:AddField("sign", sign);
	CC.HttpMgr.PostForm(url, wwwForm, function(www)
			local data = Json.decode(www.downloadHandler.text)
			CC.uu.Log(data)
    	end,
    	function()
    		logError("-----")
    	end)
end

function TestTool.TestFunc15()

	local AsynCall = require("Common/AsynCall")

	local model = {}
	function model:TestFunc(params, callback)
		local data = nil

		-- do something and wait for the callback
		(function ()
			logError(params)
			data = {1,2,3}

			if data and params == "p1" then
				callback(0,"ok",data)
			else
				callback(-1,"data is nil",data)
			end
		end)()
		
	end

	AsynCall.run(function ()
		for i=1,1 do
			local code, msg, info = AsynCall.call(model, 'TestFunc', 'p1')
		    if code == 0 then
		    	logError(msg)
		        logError(CC.uu.Dump(info))
		    else
		        logError(msg)
		    end

		    code, msg, info = AsynCall.call(model, 'TestFunc', 'p2')
		    if code == 0 then
		    	logError(msg)
		        logError(CC.uu.Dump(info))
		    else
		        logError(msg)
		    end
		end

	end)
end

return TestTool