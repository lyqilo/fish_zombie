local M = {
    Entry = {
        -- 请求超时时间
        RequestTimeout = 5,
        -- 尝试请求次数
        TryTimes = 3
    },
    Backup = {
        -- 备用链路配置地址
        Url = "/res/HW_PLATFORM_II/config/th_backup.json",
        -- 请求超时时间
        RequestTimeout = 5,
        -- 尝试请求次数
        TryTimes = 3
    },
    Test = {
        -- 测试网站
        Url = "https://www.google.com",
        -- 请求超时时间
        RequestTimeout = 5,
        -- 尝试请求次数
        TryTimes = 3
    }
}

return M
