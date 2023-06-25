local CC = require("CC")

local PersonalInfoDefine = {}

PersonalInfoDefine.PersonalInfoMode = {
	Self = 1, --自己
	Friend = 2, --好友
	Stranger = 3 --陌生人
}

PersonalInfoDefine.OpenPersonalInfoView = function(param)
	CC.uu.Log("该API已弃用！！ 请调用CC.SubGameInterface.OpenPersonalInfoView(param)代替")
	return CC.SubGameInterface.OpenPersonalInfoView(param)
end

PersonalInfoDefine.GetHeadIconPathById = function(id)
	CC.uu.Log("该API已弃用！！ 请调用CC.SubGameInterface.GetHeadIconPathById(id)代替")
	return CC.SubGameInterface.GetHeadIconPathById(id)
end

PersonalInfoDefine.SetHeadIcon = function(iconPath, iconNode, playerId)
	CC.uu.Log("该API已弃用！！ 请调用CC.SubGameInterface.SetHeadIcon(iconPath,iconNode,playerId)代替")
	CC.SubGameInterface.SetHeadIcon(iconPath, iconNode, playerId)
end

PersonalInfoDefine.SetVipLevel = function(vipLevel, vipNode)
	CC.uu.Log("该API已弃用！！ 请调用CC.SubGameInterface.SetHeadVipLevel(vipLevel,vipNode)代替")
	CC.SubGameInterface.SetHeadVipLevel(vipLevel, vipNode)
end

return PersonalInfoDefine
