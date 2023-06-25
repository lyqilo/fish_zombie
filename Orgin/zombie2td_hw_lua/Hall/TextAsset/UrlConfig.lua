local M = {}

-- 旧入口
M.Release = "https://hall.rycgames.com"
M.PreRelease = "https://hall.rycgames.com/pre"
M.Test = "https://test-hall.rycgames.com"
M.Dev = "http://dev-hall-1.rycgames.com"
M.StableDev = "http://dev-hall-2.rycgames.com"
M.TH_Release = "https://th-hall.rycgames.com"

-- 新入口地址
M.EntryUrl = {
    Release = "https://hall.rycgames.com", -- 旧URL
    -- Release = "https://hall-1.rycgames.com", -- 新机房
    PreRelease = "https://hall.rycgames.com/pre",
    Test = "https://test-hall.rycgames.com",
    Dev = "http://dev-hall-1.rycgames.com",
    StableDev = "http://dev-hall-2.rycgames.com",
    TH_Release = "https://th-hall.rycgames.com"
}

-- web api
M.WebApiUrl = {
    Release = "http://api.rycgames.com", -- 旧URL
    -- Release = "http://api-1.rycgames.com",
    Test = "http://test-api.rycgames.com"
}

-- web客服?
M.WebApiServiceUrl = {
    Release = "https://ghv2.rycgames.com" -- 旧URL
    -- Release = "https://ghv2-1.rycgames.com"
}

-- CDN
M.CDNUrl = {
    Release = "https://cdn.rycgames.com" -- 旧URL
    -- Release = "https://cdn-1.rycgames.com"
}

-- Facebook相关
M.Facebook = {
    MainPage = "https://www.facebook.com/RoyalCasinoAppTH",
    ChatGroup = "https://www.facebook.com/groups/592197474594940/"
}

-- 打点?
M.ReportUrl = {
    Release = "https://fdapi.huoys.com/data_api/events_report",
    Test = "http://172.13.1.230:8015/data_api/events_report"
}

-- 火币?
M.BlockchainWebStore = {
    Release = "https://bc-webview.hysgame.com",
    Test = "https://blockchain-webview-test.hysgame.com"
}

return M
