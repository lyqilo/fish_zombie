-------------------------------
--���ʶ�Ӧ���ӵȼ�
local RatioLevelSet = 
{
    low = {
        --�������ֵ��ʾ
        multiple = 15,
        --չʾ���֮���Ϸ�
        playInterval = 1.5,
        iconPath = "SkeletonGraphicLow",
        --������ɫ
        nameColor = Color(182/255,134/255,91/255,1),
        --��Ӱ��ɫ
        outlineColor = Color(40/255,35/255,53/255,1)
    },
    mid = {
        --����low�ҵ������ֵ��ʾ
        multiple = 25,
        --չʾ���֮���Ϸ�
        playInterval = 1.5,
        iconPath = "SkeletonGraphicMid",
        --������ɫ
        nameColor = Color(133/255,169/255,233/255,1),
        --��Ӱ��ɫ
        outlineColor = Color(41/255,51/255,69/255,1)
    },
    high = {
        --���ֵû�����壬����mid�Ķ�Ϊhigh
        multiple = 60,
        --չʾ���֮���Ϸ�
        playInterval = 1.5,
        iconPath = "SkeletonGraphicHigh",
        --���ﱳ��ͼƫ��ֵ
        monsterIconOffset = Vector2(0,-0.56),
        --������ɫ
        nameColor = Color(237/255,182/255,51/255,1),
        --��Ӱ��ɫ
        outlineColor = Color(64/255,37/255,6/255,1)
    }
}

return RatioLevelSet;
-------------------------------