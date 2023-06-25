local GC = require("GC")
local ZTD = require("ZTD")


local M = {};

local WaitTime1;
local WaitTime2;

local Waiting;
local View;

local ActionKey;

local ShieldingLayer;
local WaitContent;

local language

function M.Init()
    WaitTime1 = ZTD.WaitForServerConfig.waitTime1;
    WaitTime2 = ZTD.WaitForServerConfig.waitTime2;

    tipLanguage = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig");

    local parent = GameObject.Find("Main").transform:FindChild("TopUIPanal");
    View = ZTD.Extend.LoadPrefab( "ZTD_WaitForServerView", parent);
    ShieldingLayer = View:FindChild("ShieldingLayer");
    WaitContent = View:FindChild("Content");
    View:SetActive(false);
end

function M.BeginWait(waitTime,callBack)
    if Waiting then return end
    Waiting = true;
    View:SetActive(true);
    WaitContent:SetActive(false);
    ShieldingLayer.color = {r = 0,g = 0 ,b = 0 ,a = 0};

    ActionKey = ZTD.Extend.RunAction(View,{
        {"delay",waitTime or WaitTime1,onEnd = function()
            WaitContent:SetActive(true);
            WaitContent:FindChild("Text"):SetText(tipLanguage.connectText);
            ShieldingLayer.color = {r = 0,g = 0 ,b = 0 ,a = 0.8};
        end},
        {"delay",WaitTime2,onEnd = function()
            if callBack then
                callBack();
            else
                ZTD.MJGame.Back2Hall()
            end
            M.EndWait();
        end}
    })
end

function M.EndWait()
    if not Waiting then return end
    Waiting = false;
    View:SetActive(false);
    ZTD.Extend.StopAction(ActionKey);
end

function M.ConnectTimeout(msg)
    M.EndWait();

    if msg then 
        ZTD.ShowTip(msg);
    end

    View:SetActive(true);
    WaitContent:SetActive(true);
    WaitContent:FindChild("Text"):SetText(tipLanguage.connectText);
    ShieldingLayer.color = {r = 0,g = 0 ,b = 0 ,a = 0.8};

    ActionKey = ZTD.Extend.RunAction(View,{
        {"delay",5,onEnd = function()
            ZTD.MJGame.Back2Hall()
            M.EndWait();
        end}
    })
end

--切后台会来的倒计时
function M.OnGameResume(func)
    ZTD.Extend.StopAction(ActionKey);

    View:SetActive(true);
    WaitContent:SetActive(true);
    WaitContent:FindChild("Text"):SetText(tipLanguage.reconnectText);
    ShieldingLayer.color = {r = 0,g = 0 ,b = 0 ,a = 0.8};

    ActionKey = ZTD.Extend.RunAction(View,{
        {"delay",1,onEnd = function()
            if func then
                func();
            end
            View:SetActive(false);
            ZTD.Extend.StopAction(ActionKey);
        end}
    })
end

return M