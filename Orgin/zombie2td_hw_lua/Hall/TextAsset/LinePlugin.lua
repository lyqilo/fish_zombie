local CC = require("CC")
local LinePlugin = {}

function LinePlugin.Init()
	-- 创建一个名为LineSDK的gameobject
	-- 注意，名字一定是 LineSDK

	local cfg = CC.ConfigCenter.Inst():getConfigDataByKey("SDKConfig")
	local channelID = cfg[AppInfo.ChannelID].line.channelId
	local universalLinkURL = ""
	LineUtil.Init(channelID, universalLinkURL)
end

function LinePlugin.Login(succCb, errCb)
	local field = {"profile"}
	LineUtil.Login(
		field,
		function(code, data)
			if code == 0 then
				log(data)
				CC.ReportManager.SetDot("LINELOGINSUCC")
				-- {
				--     "accessToken": {
				--         "access_token": "eyJhbGciOiJIUzI1NiJ9.H64ek43qetOL8TZjI-bGk_rDVU6KvcBEOKUeEGaZKPR3UF_qLyPgUf1noxt3BDYNZ_m06V_QnEh1Erj3zgZbPrX126yOtBnajFZHfjFcTs-G74teH1kM-rx2NQ7HoAfDZjJrQm-tmepGnv4BAePaHhli8ahYmbq5hBRmSBCinHI.YOqckCqXjNZ4q62h7cikLnSudh5x5zfGRXd_3nebt3Q",
				--         "expires_in": 43200000,
				--         "id_token": "",
				--         "refresh_token": "",
				--         "scope": "",
				--         "token_type": ""
				--     },
				--     "scope": "profile",
				--     "userProfile": {
				--         "userId": "Uf4b89608f7765f012f60931d8dd2d958",
				--         "displayName": "凌云谢",
				--         "pictureUrl": "https://profile.line-scdn.net/0hZUC8NLx3BXp-QS8hWSt6LUIECxcJbwMyBnBPTFNECB0Bdkd4FXIdFFNBXkxUcEt_Si9OG14VWkMA",
				--         "statusMessage": ""
				--     },
				--     "friendshipStatusChanged": false
				-- }
				local lineData = {}
				lineData.access_token = data
				lineData.user_id = ""
				succCb(lineData)
			else
				-- 失败的情况下，data是字符串
				log(string.format("LinePlugin.Login code=%d,message=%s", code, data))
				CC.ReportManager.SetDot("LINELOGINFAIL")
				-- data = {
				-- 	error="",
				-- 	error_description=""
				-- }
				errCb(data)
			end
		end
	)
end

function LinePlugin.Logout()
	LineUtil.Logout()
end

function LinePlugin.ShareText(content)
	local schemeUrl = "line://msg/text/" .. content
	Client.OpenURL(schemeUrl)
end

return LinePlugin
