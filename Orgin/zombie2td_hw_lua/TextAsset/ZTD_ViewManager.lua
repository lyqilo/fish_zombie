
local GC = require("GC")
local ZTD = require("ZTD")
local tools = GC.uu

local iViewList = {}
local iTip = nil
local iWaitTip = nil
local iBubble = nil
local iBubbleID = nil
local iMsgbox = nil
local iExitBox = nil
local iExtendPop = nil

local ZTD_ViewManager = {}
ZTD_ViewManager.isOpenShop = false
function ZTD_ViewManager.Start()
	--当前打开的页面列表，Replace和Open打开的
	iViewList = {}
	--游戏顶部下拉提示
	iTip = nil
	--转菊花等待提示
	iWaitTip = nil
	--气泡提示
	iBubble = nil
	iBubbleID = nil
	--自定义弹框
	iMsgbox = nil
	--自定义退出弹框
	iExitBox = nil
	--低层级通用提示框
	iExtendPop = nil
end

function ZTD_ViewManager.PushView(bReplace, view, ...)
	if bReplace then
		--Replace的话，或把当前所有页面先关闭
		ZTD_ViewManager.CloseAllView(bReplace)
	end
	local view = tools.SafeDoFunc(ZTD.CreateView, view, ...)
	if view then
		--监听页面被销毁，清除他在iViewList中的保存
		view.OnDestroyFinish = function(view)
			for i,v in ipairs(iViewList) do
				if v == view then
					--log("close view.viewName="..tostring(view.viewName))
					table.remove(iViewList,i)
					break
				end
			end
		end
		--log("open view.viewName="..tostring(view.viewName))
		table.insert(iViewList,view)
	end
	return view
end

function ZTD_ViewManager.Open( ... )
	return ZTD_ViewManager.PushView(false, ...)
end
function ZTD_ViewManager.Replace( ... )
	return ZTD_ViewManager.PushView(true, ...)
end

function ZTD_ViewManager.CloseAllView(bReplace)
	-- logError("iViewList="..GC.uu.Dump(iViewList))
	for k, view in ipairs(iViewList) do
		-- log("have view.viewName="..tostring(view.viewName))
		if view.viewName ~= "ZTD_MainView" or (view.viewName == "ZTD_MainView" and bReplace) then
			-- log("close view.viewName="..tostring(view.viewName))
			view.OnDestroyFinish = function() end
			view:Destroy()
			iViewList[k] = nil
		end
	end
	ZTD_ViewManager.CloseTip()
	ZTD_ViewManager.CloseWaitTip()
	ZTD_ViewManager.CloseMessageBox()
	ZTD_ViewManager.CloseBubble()
	ZTD_ViewManager.CloseExtendPopView()
end

--行动点不足气泡提示
function ZTD_ViewManager.ShowBubble(pos)
	if iBubble and iBubbleID then 
		ZTD.EffectManager.RemoveEffectByID(iBubbleID)
	end
	local parent = GameObject.Find("Main/Canvas/TopUIPanal").transform
	iBubble, iBubbleID = ZTD.EffectManager.PlayEffect("Effects_UI_qipao", parent, true)
	iBubble.position = ZTD.MainScene.SetupPos2UiPos(pos)
end

--关闭气泡
function ZTD_ViewManager.CloseBubble()
	if iBubble and iBubbleID then
		ZTD.EffectManager.RemoveEffectByID(iBubbleID)
		iBubble = nil
		iBubbleID = nil
	end
end

--游戏顶部下拉提示
function ZTD_ViewManager.ShowTip( str, second, finishCall, tipPos )
	if iTip then iTip:Destroy() end
	iTip = ZTD.CreateView(
	    "ZTD_Tip", 
		str, 
		second, 
		finishCall,
		tipPos
	)

	iTip.OnDestroyFinish = function()
		iTip = nil
	end
	return iTip
end

--关闭游戏顶部下拉提示
function ZTD_ViewManager.CloseTip()
	if iTip then 
		iTip:Destroy() 
		iTip = nil
	end
end

--转菊花的等待页面
function ZTD_ViewManager.ShowWaitTip()
	ZTD_ViewManager.CloseWaitTip()
	--logError("ShowWaitTip")
	iWaitTip = ZTD.CreateView("ZTD_WaitTip")
	iWaitTip.OnDestroyFinish = function( tip )
		if iWaitTip == tip then
			iWaitTip = nil
		end
	end
	return iWaitTip
end

--关闭转菊花的等待页面
function ZTD_ViewManager.CloseWaitTip()
	--logError("CloseWaitTip")
	if iWaitTip then
		iWaitTip:Destroy()
	end
end

--自定义的弹窗(仅用于各类退出游戏框，各类玩家手动点击打开的UI界面，可保证退游戏框弹出时关闭多余UI界面)
function ZTD_ViewManager.OpenMessageBox( viewName, ... )
	ZTD_ViewManager.CloseMessageBox()
	iMsgbox = ZTD.CreateView(viewName, ...)
	iMsgbox.OnDestroyFinish = function( msgBox )
		if iMsgbox == msgBox then
			iMsgbox = nil
		end
	end
	local pos = iMsgbox.transform.localPosition
	ZTD.GlobalTimer.DelayRun(0.01, function()
		iMsgbox.transform.localPosition = pos
    end )
	iMsgbox:Show()
	iMsgbox.transform.localPosition = Vector3(10000,10000,0)
	return iMsgbox
end

--调用各种退回到大厅/选场/登录主页的窗口，该窗口只允许有一个，优先级高的不会被优先级低的覆盖
function ZTD_ViewManager.OpenExitGameBox(priorityInx, ... )
	priorityInx = priorityInx or 0;
	if iExitBox == nil or priorityInx >= iExitBox._iPriorityInx then
		iExitBox = ZTD_ViewManager.OpenMessageBox("ZTD_PopView", ... );
		iExitBox:SetDestroyCall(
			function ()
				iExitBox = nil;
			end
		)
		iExitBox._iPriorityInx = priorityInx;
		return iExitBox;	
	end
end

--关闭自定义的弹窗
function ZTD_ViewManager.CloseMessageBox()
	if iMsgbox then
		iMsgbox:Destroy()
		iMsgbox = nil
	end
end

--通用提示框
function ZTD_ViewManager.OpenExtenPopView(str, confirmFunc, cancelFunc, confirmTxt, cancelTxt, sortingOrder)
	if iExtendPop then iExtendPop:Destroy() end
	iExtendPop = ZTD.CreateView(
	    "ZTD_ExtendPopView", 
		str,
		confirmFunc,
		cancelFunc,
		confirmTxt,
		cancelTxt,
		sortingOrder
	)

	iExtendPop.OnDestroyFinish = function()
		iExtendPop = nil
	end
	return iExtendPop
end

--关闭低层级通用提示框
function ZTD_ViewManager:CloseExtendPopView()
	if iExtendPop then
		iExtendPop:Destroy()
		iExtendPop = nil
	end
end

return ZTD_ViewManager
