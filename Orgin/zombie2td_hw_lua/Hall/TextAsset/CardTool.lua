--------------------------------------------
--@Description: 生成卡牌预制体的工具类。
--@Note：只支持由3张图片组成的牌，即左上角点数，点数下面的花色，右下角花色的图片
--@Note：不支持大小王
--@Note: 预制体已经设置好牌的背面、前面。这里只是做替换，根据点数生成相应的牌
--@Note: 只负责创建，不负责销毁
--@Author: Xie Ling Yun
--------------------------------------------

local CC = require("CC")
local uu = CC.uu
local CardTool = CC.class2("CardTool")

local CARDCOLOR = {
    DIAMOND = 1,
    CLUB = 2,
    HEART = 3,
    SPADE = 4,
}
CardTool.CARDCOLOR = CARDCOLOR

local _GetCardInfoByPoint --根据服务器点数获得花色和点数
local _GetSuffixByPoint --根据卡牌点数获取图片后缀

-- @bundleName. 
-- @prefabName. 预制体名字。
-- 预制体结构为
--[[
root
--fontGroup
----littleImg
----bigImg
----pointImg
]]
-- @imageBundleName. 存放图标的文件夹
-- @littleColorNames. 点数下面的花色的图片名字，大小为4数组的，按照方块、梅花、红心、黑桃的顺序
-- @bigColorNames. 右下角花色的图片名字，大小为4数组的，按照方块、梅花、红心、黑桃的顺序
-- @redBigJQKNames. 右下角红色的图片
-- @blackBigJQKNames. 右下角黑色的图片
-- @redPointPrefix. 左上角红色点数的前缀
-- @blackPointPrefix. 左上角黑色点数的前缀
-- @后缀说明。（点数-后缀）(A-1)、(2-2)、(3-3)、(4-4)、(5-5)、(6-6)、(7-7)、(8-8)、(9-9)、(10-A)、(J-B)、(Q-C)、(K-D)
function CardTool:ctor(prefabBundleName,prefabName,imageBundleName,littleColorNames,bigColorNames,redBigJQKNames,blackBigJQKNames,redPointPrefix,blackPointPrefix)
    self.prefabBundleName = prefabBundleName
    self.prefabName = prefabName
    self.imageBundleName = imageBundleName
    self.littleColorNames = littleColorNames
    self.bigColorNames = bigColorNames
    self.redBigJQKNames = redBigJQKNames
    self.blackBigJQKNames = blackBigJQKNames
    self.redPointPrefix = redPointPrefix
    self.blackPointPrefix = blackPointPrefix
end

-- @nPoint. 牌的点数，请参照点数表
-- @方块A-方块K 对应 1-13
-- @梅花A-梅花K 对应 14-26
-- @红心A-红心K 对应 27-39
-- @黑桃A-黑桃K 对应 40-52
-- @parent. 牌的父节点
-- @name. 牌预制体的名字
function CardTool:CreateCard(nPoint, parent, name)
    local cardItem = uu.LoadPrefab(self.prefabBundleName, self.prefabName, parent, name)
    self:ChangeCardItemPoint(cardItem, nPoint)
    return cardItem
end

-- 改变item的点数
-- @cardItem. 想要改变的原cardItem
-- @point. 新的点数
function CardTool:ChangeCardItemPoint(cardItem, nPoint)
    local color,suffix
    color,nPoint = _GetCardInfoByPoint(nPoint)
    if nPoint <= 0 then return end
    
    suffix = _GetSuffixByPoint(nPoint)

    local littleImg = self.littleColorNames[color]
    local pointImg
    if color == CARDCOLOR.DIAMOND or color == CARDCOLOR.HEART then
        pointImg = string.format("%s%s",self.redPointPrefix,suffix)
    else
        pointImg = string.format("%s%s",self.blackPointPrefix,suffix)
    end
    local bigImg
    if nPoint > 10 then
        if color == CARDCOLOR.DIAMOND or color == CARDCOLOR.HEART then
            bigImg = self.redBigJQKNames[nPoint-10]
        else
            bigImg = self.blackBigJQKNames[nPoint-10]
        end
    else
        bigImg = self.bigColorNames[color]
    end

    local replaceImages = {
        ["littleImg"] = littleImg,
        ["pointImg"] = pointImg,
        ["bigImg"] = bigImg,
    }
    for nodeName,imageName in pairs(replaceImages) do
        local image = cardItem:FindChild("fontGroup/"..nodeName):GetComponent("Image")
        image.sprite = uu.LoadImgSprite(imageName..".png",self.imageBundleName)
        image:SetNativeSize()
    end
end

-- 返回花色和点数
_GetCardInfoByPoint = function(nPoint)
    local n = math.floor(nPoint/13)
    local m = nPoint-n*13
    if m == 0 then
        return n,13
    else
        return n+1,m
    end
end

-- 返回后缀
local suffix = {"1","2","3","4","5","6","7","8","9","A","B","C","D"}
_GetSuffixByPoint = function(nPoint)
    return suffix[nPoint]
end

return CardTool

