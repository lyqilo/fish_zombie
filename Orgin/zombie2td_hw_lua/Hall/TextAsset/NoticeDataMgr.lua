
local CC = require("CC")
local NoticeDataMgr = {}

local Title = nil
local Content = nil

function NoticeDataMgr.SetNotice(param)
	Title = param.Title
	Content = param.Content
end

function NoticeDataMgr.GetTitle()
	return Title
end

function NoticeDataMgr.GetContent()
	return Content
end

return NoticeDataMgr
