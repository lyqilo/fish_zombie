--Author:AQ
--Time:2020年08月20日 15:55:03 Thursday
--Describe:

local CC = require "CC"

local M = CC.class2("Slot_MatchTipItem")

function M:ctor(go,pool,context)
    self.context = context;
    self.pool = pool;
    self:Init(go);
end

function M:Init(go)
    self.transform = go.transform;
    self.text_content = self.transform:FindChild("image_bg/text_content"):GetComponent("Text");
end

function M:Refresh(str)
    self.transform:SetActive(true);
    self.text_content.text = str;
    CC.Action.RunAction(self.transform, {"localMoveTo", 0, 130, 2.0, ease = CC.Action.EInOutQuart, function()
        self.context:ReleaseLimitMapItem(str);
        self.pool:Release(self);
    end});
end

function M:Reset()
    self.text_content.text = "";
    self.transform.localPosition = Vector3(0,0,0);
    self.transform:SetActive(false);
    self.transform:SetAsLastSibling();
end


return M