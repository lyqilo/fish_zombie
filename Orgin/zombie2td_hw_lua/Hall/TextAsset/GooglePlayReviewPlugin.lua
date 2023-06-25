local M = {}

--[[
cb(errorCode)
errorCode: 1 调起评论框失败
errorCode: 2 发送评论失败。即调起了评论框，但是写好评分之后，发送请求失败
errorCode: 0 0也不一定代表成功。google给的英文原文解释是
// The flow has finished. The API does not indicate whether the user
// reviewed or not, or even whether the review dialog was shown. Thus, no
// matter the result, we continue our app flow.
]]
function M.Review(cb)
    local util = GameObject.Find("GameManager"):AddComponent(typeof(GooglePlayReviewUtil))
    util:Review(cb)
end

return M
