
local CC = require("CC")

local HeadIconDataMgr = {};

local textureBytes = {};

function HeadIconDataMgr.SetTextureBytes(playerId, bytes)
	--缓存玩家下载的头像数据
	textureBytes[playerId] = bytes;
end

function HeadIconDataMgr.GetTextureBytes(playerId)

	return textureBytes[playerId];
end

function HeadIconDataMgr.ReleaseTextureBytes()

	for id,v in pairs(textureBytes) do
		textureBytes[id] = nil;
	end
	textureBytes = {};
end

return HeadIconDataMgr;