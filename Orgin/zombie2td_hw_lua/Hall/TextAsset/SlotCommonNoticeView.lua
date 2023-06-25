
local CC = require("CC")
local M = CC.uu.ClassView("SlotCommonNoticeView")
local slotMatch_message_pb = CC.slotMatch_message_pb;
local latternItemClass = require("View/SlotCommonNoticeView/SlotCommonLatternItem");
local bulletMsgItemClass = require("View/SlotCommonNoticeView/SlotCommonBulletMsgItem");

function M:GlobalNode()
    if self.param.parent then
        return self.param.parent;
    else
        return GameObject.Find("GNode/GCanvas/GMain").transform
    end
end

function M:ctor(param)
    self:InitVar(param);
end

function M:InitVar(param)
    self.param = param;
end

function M:InitContent()
    self.latternContent = self:FindChild("LatternContent");
    self.latternItem = self:FindChild("LatternContent/LatternItem").gameObject;
    self.bulletMsgContent = self:FindChild("BulletMsgContent");
    self.bulletMsgItem = self:FindChild("BulletMsgContent/BulletMsgItem").gameObject;

    self.sideFrameContent = self:FindChild("SideFrameContent/Frame");
    self.sideFrameWidth = self.sideFrameContent.width;
    self.sideFrame_content = self:FindChild("SideFrameContent/Frame/TextContent");
    self.sideFrame_title = self:FindChild("SideFrameContent/Frame/TextTitle");

    self.publicContent = self:FindChild("PublicContent").gameObject;
    self.publicFrame = self:FindChild("PublicContent/Frame");
    self.public_Image_content = self:FindChild("PublicContent/Frame/ImageContent"):GetComponent("Image");
    self.public_Text_content = self:FindChild("PublicContent/Frame/TextContentRect/TextContent");
    self.public_Text_title = self:FindChild("PublicContent/Frame/TextTitle");

    self:AddClick("SideFrameContent/Frame/BtnClose", function() self:OnBtnClose(slotMatch_message_pb.SideFrame) end);
    self:AddClick("PublicContent/Frame/ImageContent/BtnClose", function() self:OnBtnClose(slotMatch_message_pb.Public) end);
    self.itemPrefab = {
        [slotMatch_message_pb.Lattern] = self.latternItem,
        [slotMatch_message_pb.BulletMsg] = self.bulletMsgItem,
    };
    self.itemParent = {
        [slotMatch_message_pb.Lattern] = self.latternContent,
        [slotMatch_message_pb.BulletMsg] = self.bulletMsgContent,
    };
    self.itemClass = {
        [slotMatch_message_pb.Lattern] = latternItemClass,
        [slotMatch_message_pb.BulletMsg] = bulletMsgItemClass,
    };
    self.itemPool = {
        [slotMatch_message_pb.Lattern] = {},
        [slotMatch_message_pb.BulletMsg] = {},
    };
    self.itemContainer = {
        [slotMatch_message_pb.Lattern] = {},
        [slotMatch_message_pb.BulletMsg] = {},
    };
    self.itemParam = {
        [slotMatch_message_pb.Lattern] = self.param.latternParam or {},
        [slotMatch_message_pb.BulletMsg] = self.param.bulletMsgParam or {},
    };
    self.latternIndex = 0;
    self.bulletIndex = 0;
end

function M:OnCreate()
    self:InitContent();
	self.viewCtr = self:CreateViewCtr(self.param);
	self.viewCtr:OnCreate();
end

function M:OnBtnClose(nType)
    self:ShowNext(nType);
end

function M:ShowCurrent(noticeData)
    if noticeData.nType == slotMatch_message_pb.Public then
        if noticeData.backImageId ~= nil then
            --self.public_Image_content.sprite = CC.uu.LoadImgSprite("slotCommonNoticeImage_"..noticeData.backImageId,"temp_SlotCommonNotice");
            self:SetImage(self.public_Image_content, "slotCommonNoticeImage_"..noticeData.backImageId)
            self.public_Image_content:SetNativeSize();
        end
        if noticeData.title ~= nil then
            self.public_Text_title.text = noticeData.title;
        end
        if noticeData.content ~= nil then
            self.public_Text_content.text = noticeData.content;
        end
        self.publicFrame.localScale = Vector3(0.5,0.5,1)
        self.publicContent:SetActive(true);
        self:RunAction(self.publicFrame, {"scaleTo", 1, 1, 0.3, ease=CC.Action.EOutBack, function()

        end})
        CC.Sound.PlayHallEffect("click_boardopen");
    elseif noticeData.nType == slotMatch_message_pb.SideFrame then
        if noticeData.title ~= nil then
            self.sideFrame_title.text = noticeData.title;
        end
        if noticeData.content ~= nil then
            self.sideFrame_content.text = noticeData.content;
        end
        local yValue = self.sideFrameContent.y;
        self.sideFrameContent.localPosition = Vector3(-self.sideFrameWidth,yValue,0);
        self.sideFrameContent.gameObject:SetActive(true);
        self:RunAction(self.sideFrameContent,{"localMoveTo",0,yValue,0.5, ease=CC.Action.EOutBack,function()

        end})
    elseif noticeData.nType == slotMatch_message_pb.Lattern then
        local lattern = self:GetItem(noticeData.nType);
        lattern:Refresh(noticeData,self.latternIndex);
        self.latternIndex = self.latternIndex + 1;
    elseif noticeData.nType == slotMatch_message_pb.BulletMsg then
        local bulletMsg = self:GetItem(noticeData.nType);
        bulletMsg:Refresh(noticeData,self.bulletIndex);
        self.bulletIndex = self.bulletIndex + 1;
    end
end

function M:ShowNext(nType)
    if nType == slotMatch_message_pb.Public then
        self:RunAction(self.publicFrame, {"scaleTo", 0.5, 0.5, 0.3, ease=CC.Action.EInBack, function()
            self.publicContent:SetActive(false);
            self.public_Image_content.sprite = nil;
            self.public_Text_title.text = "";
            self.public_Text_content.text = "";
    		self.viewCtr:ShowNext(nType);
    	end})
    elseif nType == slotMatch_message_pb.SideFrame then
        local yValue = self.sideFrameContent.y;
        self:RunAction(self.sideFrameContent,{"localMoveTo",-self.sideFrameWidth,yValue,0.3, ease=CC.Action.EOutBack,function()
            self.sideFrameContent.gameObject:SetActive(false);
            self.sideFrame_title.text = "";
            self.sideFrame_content.text = "";
            self.viewCtr:ShowNext(nType);
        end})
    elseif nType == slotMatch_message_pb.Lattern then
        self.viewCtr:ShowNext(nType);
    elseif nType == slotMatch_message_pb.BulletMsg then
        self.viewCtr:ShowNext(nType);
    end
end

function M:GetItem(nType)
    local item = table.remove(self.itemPool[nType],1);
    if item == nil then
        item = self:CreateItem(nType);
    end
    return item;
end

function M:CreateItem(nType)
    local itemGo = CC.uu.newObject(self.itemPrefab[nType], self.itemParent[nType]);
    local itemClass = self.itemClass[nType];
    local newObj = itemClass.new(itemGo,self.itemParam[nType]);
    newObj.recoveryFunc = function() self:RecoverItem(newObj,nType) end;
    table.insert(self.itemContainer[nType],newObj);
    return newObj;
end

function M:RecoverItem(item,nType)
    table.insert(self.itemPool[nType],item);
end

function M:ReadHistoryPublic()
    return self.viewCtr:ReadHistoryPublic();
end

function M:OnDestroy()
    if self.viewCtr then
		self.viewCtr:Destroy();
		self.viewCtr = nil;
    end
    for k,container in pairs(self.itemContainer) do
        for k1,item in pairs(container) do
            item:Reset();
        end
    end
    self.itemContainer = nil;
    self.itemPool = nil;
end

return M