local CC = require("CC")
local PackageUtils = require("View/PackageTestView/PackageUtils");

local View = CC.uu.ClassView("PackageTestView")

function View:ctor()
    self.UIFields = {}
    self.leftItemList = {}
    self.leftItemColor = {}
    self.leftItemColor[1] = Color(1,1,1,0.6)
    self.leftItemColor[2] = Color(254/255,255/255,186/255,0.6)

    self.midItemList = {}   --中间列表的item

    self.MsgStack = {}  --需要发出去消息的栈
    self.InfoStack = {} --proto信息的栈
    self.statusStack = {}   --当前栈的状态

    self.StatusType = {
        [1] = 'normal',     --正常处于message内部
        [2] = 'inList',     --处于repeated的数组中
    }

    self.MsgBackStr = nil    --返回的消息
    self.isShow = true      --正在显示
    -- self.showEnemyUid = false   --是否显示所有鱼的uid
	self.uidList = {}

    --请求地址
    self.reqUrl = ""
end

function View:OnCreate()
    self:InitUIFields()

    PackageUtils.LoadProtoFile()

    self:RefreshLeftPart()
    self:RefreshLeftBG()

    self:RegisterEvent()
end

--初始化 绑定UI组件
function View:InitUIFields()
    self.UIFields.enemyUidLayer = self:FindChild('EnemyUidLayer')
    
    local leftPart = {}
    self.UIFields.leftPart = leftPart
    leftPart.Content = self:FindChild('LeftPart/Viewport/Content')
    leftPart.item = leftPart.Content:FindChild('item')

    local midPart = {}
    self.UIFields.midPart = midPart
    midPart.Content = self:FindChild('MidPart/Viewport/Content')
    midPart.item = midPart.Content:FindChild('item')
    midPart.addMemBtn = self:FindChild('MidPart/AddMember')
    midPart.BackBtn = self:FindChild('MidPart/Back')

    local rightPart = {}
    self.UIFields.rightPart = rightPart
    rightPart.DataText = self:FindChild('RightPart/Scroll View/Viewport/Content/text'):GetComponent('Text')
    rightPart.FontSizeSlider = self:FindChild('RightPart/FontSizeSlider')
    rightPart.BtnSend = self:FindChild('RightPart/BtnSend')
    -- rightPart.ShowEnemyUid = self:FindChild('RightPart/ShowEnemyUid')
    rightPart.GameSpeed = self:FindChild('RightPart/GameSpeed')
    rightPart.GameSpeed:GetComponent("Slider").value = Time.timeScale;
    -- rightPart.ShowEnemyUid:GetComponent('Toggle').isOn = false

    self.UIFields.searchInput = self:FindChild("LeftPart/InputField")
end

--注册按钮点击事件
function View:RegisterEvent()
    local UIFields = self.UIFields
    UIFields.midPart.addMemBtn.onClick = function()
        self:OnClickAddMem()
    end

    UIFields.midPart.BackBtn.onClick = function()
        self:OnClickBack()
    end

    UIFields.rightPart.BtnSend.onClick = function()
        self:SendMsg()
    end

    UIEvent.AddSliderOnValueChange(UIFields.rightPart.FontSizeSlider, function (v)
        UIFields.rightPart.DataText.fontSize = 16 + 14 * v
    end)

    UIEvent.AddSliderOnValueChange(UIFields.rightPart.GameSpeed, function (v)
        Time.timeScale = v;
    end)

    UIEvent.AddInputFieldOnValueChange(self.UIFields.searchInput, function(str)
        for _,v in ipairs(self.leftItemList) do
            if not string.find(string.lower(v.reqKey),str) then
                v.transform:SetActive(false)
            else
                v.transform:SetActive(true)
            end
        end
    end)

    self:AddClick("LeftPart/BtnClose", "Destroy");

 --    UIEvent.AddToggleValueChange(UIFields.rightPart.ShowEnemyUid,function (v)
	-- 	self.showEnemyUid = v;
	-- end)
end

--发送消息请求
function View:SendMsg()
    local curMsg = self.MsgStack[1]
    local curInfo = self.InfoStack[1]
    if(not curInfo) then
        CC.ViewManager.ShowTip("请选择要发送的消息")
        return
    end

    local msg;
    if curInfo.headName then
        msg = CC.NetworkHelper.MakeMessage(curInfo.headName);
        for _,v in ipairs(curInfo) do
            if v.memberType ~= PackageUtils.memberType.repeated then
                msg[v.selfName] = curMsg[v.selfName];
            else
                if PackageUtils.ValueType[v.headName] then
                    for _,c in ipairs(curMsg[v.selfName]) do
                        table.insert(msg[v.selfName], c)
                    end
                else
                    for _,c in ipairs(curMsg[v.selfName]) do
                        local _msg = CC.NetworkHelper.MakeMessage(v.headName);
                        for k,d in pairs(c) do
                            _msg[k] = d; 
                        end
                        table.insert(msg[v.selfName], _msg);
                    end
                end
            end
        end
    end

    local reqCfg = CC.NetworkHelper.Cfg[curInfo.reqKey];
    local reqUrlMethod = reqCfg.ReqUrlMethod or CC.Network.RequestHttp;
    local _,url = reqUrlMethod(curInfo.reqKey, msg, function(err, result)
            CC.uu.Log(result, curInfo.reqKey);
            if CC.uu.IsNil(self.transform) then return end
            self.MsgBackStr = tostring(result);
            self:RefreshRightPart()
        end,
        function(err)
            CC.uu.Log(err, tostring(curInfo.reqKey).."返回错误码")
        end)
    self.reqUrl = url;
    CC.uu.Log(url,"请求url")
end

--清空回包数据
function View:ClearBackMsg()
    self.MsgBackStr = nil
end


--改变自己显示的状态
function View:ChangeShowState()
    self.isShow = not self.isShow;
	self:SetActive(self.isShow);
	if not self.isShow then
		-- GC.Notification.UnregisterAll(self);
	end
end

---------------------------------------start  左侧相关部分---------------------------------------------

--初始化左侧列表item
function View:InitLeftItem(item)
    local result = {}
    result.transform = item
    result.Text = item:FindChild('text'):GetComponent('Text')
    result.curMessage = nil

    self:AddClick(result.transform,function()
        self:OnSelectLeftItem(result)
    end)

    return result
end

--刷新左侧
function View:RefreshLeftPart()
    local allDatas = PackageUtils.SelfDefineType
    local i = 1

    for k,v in pairs(CC.NetworkHelper.Cfg) do
        if self:MessageFilter(k) then
            local data = v.ReqProto and allDatas[v.ReqProto] or {};
            local curItem = nil
            if(self.leftItemList[i]) then
                curItem = self.leftItemList[i]
            else
                local itemGo = GameObject.Instantiate(self.UIFields.leftPart.item.gameObject).transform
                itemGo.parent = self.UIFields.leftPart.Content
                itemGo.transform.localScale = Vector3.one
                curItem = self:InitLeftItem(itemGo)
                self.leftItemList[i] = curItem
            end

            local t = {}
            t.reqName = k;
            t.note = v.Note;
            t.headName = data.headName
            self:RefreshLeftItem(curItem,t,true)
            i = i + 1
        end
    end

    for leftIndex = i,#self.leftItemList do
        self:RefreshLeftItem(self.leftItemList[i],nil,false)
    end
end

--刷新左侧的item
function View:RefreshLeftItem(item,data,toShow)
    if(not item) then
        logError('刷新左侧的item为空')
        return
    end

    item.transform.gameObject:SetActive(toShow)

    if(not toShow) then
        return
    end

    item.curMessage = data.headName
    item.reqKey = data.reqName
    local msgNote = data.note
    if(msgNote == '') then
        msgNote = '无  请在proto添加注释'
    end

    local msgString = string.format('协议名:\n%s\n<color=#7D00FF>协议说明:%s</color>',data.reqName,msgNote)

    item.Text.text = msgString
end

--选择左侧item
function View:OnSelectLeftItem(item)
    --首先取消监听事件
    -- GC.Notification.NetworkUnregisterAll(self)

    local curProtoMsg = PackageUtils.SelfDefineType[item.curMessage] or {}
    -- CC.uu.Log(curProtoMsg)
    --PackageUtils.LogError(curProtoMsg,"选中协议:")

    --选中左侧的需要发送的消息后，清空当前栈
    self.MsgStack = {}
    self.InfoStack = {}
    local info = curProtoMsg;
    if table.isEmpty(info) then
        info = {reqKey = item.reqKey}
    end
    table.insert(self.InfoStack,info)

    local baseMsg = {}
    if not table.isEmpty(curProtoMsg) then
        --通过协议构造一个初始消息结构
        baseMsg = PackageUtils.BuildMsgByProto(curProtoMsg)
    end
    table.insert(self.MsgStack,baseMsg)

    self.reqUrl = ""

    self:UpdateStatusStack(true,curProtoMsg)

    self:RefreshLeftBG(item)

    self:ClearBackMsg()

    self:RefreshMidPart()
end

function View:RefreshLeftBG(item)
    --刷新左侧选中item的颜色
    for i=1,#self.leftItemList do
        if(self.leftItemList[i] == item) then
            self.leftItemList[i].transform:GetComponent('Image').color = self.leftItemColor[2]
        else
            self.leftItemList[i].transform:GetComponent('Image').color = self.leftItemColor[1]
        end
    end
end


--给状态列表添加最新状态    isAdd ture添加  false移除最后状态
function View:UpdateStatusStack(isAdd,protoMsg)
    local statusStack = self.statusStack
    if(not isAdd) then
        statusStack[#statusStack] = nil
        return
    end

    local newStatus = self.StatusType[1]
    if(protoMsg.memberType == PackageUtils.memberType.repeated) then
        newStatus = self.StatusType[2]
    end

    table.insert(statusStack,newStatus)
end


--------------------------------------- end  左侧相关部分 ---------------------------------------------



---------------------------------------start  中间相关部分---------------------------------------------

--初始化中间列表的item
function View:InitMidItem(item,index)
    local result = {}
    result.transform = item
    result.ChangeBtn = item:FindChild('Change')
    result.DeleteBtn = item:FindChild('Delete')
    result.InputFieldTrans = item:FindChild('InputField')
    result.InputField = result.InputFieldTrans:GetComponent('InputField')
    result.MessageText = item:GetComponent('Text')
    result.index = index

    UIEvent.AddInputFieldOnValueChange(result.InputFieldTrans,function()
        self:OnInputValueChanged(result.index)
    end)

    result.ChangeBtn.onClick = function()
        self:EnterTable(result.index)
    end

    result.DeleteBtn.onClick = function()
        self:DeleteData(result.index)
    end

    return result
end

--刷新中间列表的item
--protoData:proto相关属性    value：传入inputfield的值  一般为默认值 或者之前填入的
function View:RefreshMidItem(item,protoData,value,toShow)
    local curStatus = self.statusStack[#self.statusStack]

    item.transform.gameObject:SetActive(toShow)
    if(not toShow) then
        return
    end

    -- PackageUtils.LogError(protoData,'刷新中间列表的item protoData:')
    -- PackageUtils.LogError(value,'刷新中间列表的 value:')

    local isBaseType = PackageUtils.CheckIsBaseType(protoData.headName)
    local isSelfDefineType = PackageUtils.CheckIsSelfDefineType(protoData.headName)
    if((not isBaseType) and (not isSelfDefineType)) then
        logError('未知类型:'..protoData.headName)
        return
    end

    --是否显示输入框  首先肯定是基本类型   其次 要么是非repeated类型 要么是在repeated列表中
    local CanInput = isBaseType and (protoData.memberType ~= PackageUtils.memberType.repeated or curStatus == self.StatusType[2])
    --是否显示进入按钮  就是 not CanInput
    local CanChange = isSelfDefineType or (protoData.memberType == PackageUtils.memberType.repeated and curStatus == self.StatusType[1])
    item.InputFieldTrans:SetActive(CanInput)
    item.ChangeBtn:SetActive(CanChange)
    item.DeleteBtn:SetActive(curStatus == self.StatusType[2])

    --此处开始构造提示信息
    local helpTips = nil
    helpTips = string.format('<size=24><color=#FFF800>字段名:%s</color></size>\n',protoData.selfName)
    helpTips = string.format('%s<size=18><color=#7D00FF>注释:%s</color></size>\n',helpTips,protoData.Note)
    helpTips = string.format('%s<size=20>字段类型:%s </size>\n',helpTips,PackageUtils.memberTypeByNum[protoData.memberType])
    helpTips = string.format('%s<size=20>值类型:%s</size>',helpTips,protoData.headName)

    item.MessageText.text = helpTips

    --这里将构造的message中的值赋值到输入框中
    item.InputField.text = tostring(value)
end

--刷新中间部分
--思路：基础类型直接可以填   自定义类型需要修改
function View:RefreshMidPart()
    local curProtoMsg = self.InfoStack[#self.InfoStack]
    local curStatus = self.statusStack[#self.statusStack]

    --当前处于列表中
    if(curStatus == self.StatusType[2]) then
        self:RefreshMidPartByRepeat()
    else
        self:RefreshMidPartByRequired()
    end

    --说明这个成员是repeat类型的
    self.UIFields.midPart.addMemBtn:SetActive(curProtoMsg.memberType == PackageUtils.memberType.repeated)
    self.UIFields.midPart.BackBtn:SetActive(#self.InfoStack > 1)

    self:RefreshRightPart()
end

--当前proto为列表时 刷新
function View:RefreshMidPartByRepeat()
    --logError('RefreshMidPartByRepeat  刷新列表状态的mid')
    local curProtoMsg = self.InfoStack[#self.InfoStack]
    local curMsg = self.MsgStack[#self.MsgStack]

    for i=1,#curMsg do
        local curItem = self:GetMidItemByIndex(i)
        self:RefreshMidItem(curItem,curProtoMsg,curMsg[i],true)
    end

    for i=#curMsg + 1,#self.midItemList do
        self:RefreshMidItem(self.midItemList[i],nil,nil,false)
    end
end

--当前proto 为非列表时刷新
function View:RefreshMidPartByRequired()
    --logError('RefreshMidPartByRequired   刷新非列表状态下的mid')
    local curProtoMsg = self.InfoStack[#self.InfoStack]
    local curMsg = self.MsgStack[#self.MsgStack]

    for i=1,#curProtoMsg do
        local curItem = self:GetMidItemByIndex(i)
        self:RefreshMidItem(curItem,curProtoMsg[i],curMsg[curProtoMsg[i].selfName],true)
    end

    for i=#curProtoMsg + 1,#self.midItemList do
        self:RefreshMidItem(self.midItemList[i],nil,nil,false)
    end
end

--获取第i个中间的item
function View:GetMidItemByIndex(i)
    local curItem = nil
    if(self.midItemList[i]) then
        curItem = self.midItemList[i]
    else
        local itemGo = GameObject.Instantiate(self.UIFields.midPart.item.gameObject).transform
        itemGo.parent = self.UIFields.midPart.Content
        itemGo.transform.localScale = Vector3.one
        curItem = self:InitMidItem(itemGo,i)
        self.midItemList[i] = curItem
    end

    return curItem
end


--点击添加新成员
function View:OnClickAddMem()
    local curMsg = self.MsgStack[#self.MsgStack]
    local curInfo = self.InfoStack[#self.InfoStack]
    local curStatus = self.statusStack[#self.statusStack]

    local newMsg = nil
    if(curStatus == self.StatusType[2] and PackageUtils.CheckIsSelfDefineType(curInfo.headName)) then
        newMsg = PackageUtils.BuildMsgByProto(curInfo[1])
    else
        newMsg = PackageUtils.BuildMsgByProto(curInfo)
    end

    table.insert(curMsg,newMsg)

    --PackageUtils.LogError(curMsg,'点击添加新成员后 当前stack顶内容:')

    self:RefreshMidPart()
end

--点击返回
function View:OnClickBack()
    self.MsgStack[#self.MsgStack] = nil
    self.InfoStack[#self.InfoStack] = nil
    self:UpdateStatusStack(false)

    self:RefreshMidPart()
end

--输入的值改变时候调用
function View:OnInputValueChanged(index)
    self:SaveInputData(index)
    self:RefreshRightPart()

    self:ClearBackMsg()
end

--保存当前填入的信息
function View:SaveInputData(index)
    local curMsg = self.MsgStack[#self.MsgStack]
    local curInfo = self.InfoStack[#self.InfoStack]
    local curStatus = self.statusStack[#self.statusStack]
    
    if(curStatus == self.StatusType[2]) then
        self:SaveFunction1(index)
    else
        self:SaveFunction2(index)
    end
end

--第一种保存方法 repeated型
function View:SaveFunction1(index)
    --logError('第一种保存方法 repeated型 index:'..index)
    local curMsg = self.MsgStack[#self.MsgStack]
    local curInfo = self.InfoStack[#self.InfoStack]
    --PackageUtils.LogError(curInfo,'curInfo为:')
    
    local curItem = self.midItemList[index]
    local curInfo = self.InfoStack[#self.InfoStack]
    if(curItem.transform.gameObject.activeSelf) then
        if(self:CheckCanWriteData(curInfo)) then
            curMsg[index] = PackageUtils.ConvertStrByType(curItem.InputField.text,curInfo.headName)
            --logError('curHeadName:'..curInfo.selfName..'  curMsg:'..tostring(curMsg[index]))
        end
    end
end

--第二种保存方法 非repeated型
function View:SaveFunction2(index)
    --logError('第二种保存方法  required型 index:'..index)
    local curMsg = self.MsgStack[#self.MsgStack]
    local curInfo = self.InfoStack[#self.InfoStack]
    local midItemList = self.midItemList

    local curItem = self.midItemList[index]
    curInfo = curInfo[index]

    -- PackageUtils.LogError(curInfo,'curInfo为:')
    -- PackageUtils.LogError(curMsg,'curMsg为:')

    if(curItem.transform.gameObject.activeSelf) then
        if(self:CheckCanWriteData(curInfo)) then
            curMsg[curInfo.selfName] = PackageUtils.ConvertStrByType(curItem.InputField.text,curInfo.headName)
            --logError('curHeadName:'..curInfo.selfName..'  curMsg:'..tostring(curMsg[curInfo.selfName]))
        end
    end
end




--点击进入修改数据
function View:EnterTable(index)
    local curMsg = self.MsgStack[#self.MsgStack]
    local curInfo = self.InfoStack[#self.InfoStack]
    local curStatus = self.statusStack[#self.statusStack]
    local midItemList = self.midItemList
    -- PackageUtils.LogError(curMsg,'点击进入修改数据  curMsg:')
    -- PackageUtils.LogError(curInfo,'点击进入修改数据  curInfo:')

    --TODO 这里要判断是否是列表中
    local nextInfo = nil
    local nextMsg = nil

    if(curStatus == self.StatusType[2]) then
        nextInfo = self:BuildNextInfo(curInfo[1])
        nextMsg = curMsg[index]
    else
        nextInfo = self:BuildNextInfo(curInfo[index])
        nextMsg = curMsg[nextInfo.selfName]
    end
    -- PackageUtils.LogError(nextInfo,'点击进入修改数据  nextInfo:')
    -- PackageUtils.LogError(nextMsg,'点击进入修改数据  nextMsg:')

    table.insert(self.MsgStack,nextMsg)
    table.insert(self.InfoStack,nextInfo)
    self:UpdateStatusStack(true,nextInfo)

    self:RefreshMidPart()
end

--删除数据
function View:DeleteData(index)
    local curMsg = self.MsgStack[#self.MsgStack]
    if(index > #curMsg) then
        logError('删除数据数据失败 要删除的数据index:'..index)
        return
    end

    for i= index+1,#curMsg do
        curMsg[i - 1] = curMsg[i]
    end

    curMsg[#curMsg] = nil

    self:RefreshMidPart()
end

--构建下一个info
function View:BuildNextInfo(inputInfo)
    --PackageUtils.LogError(inputInfo,'构建下一个info  inputInfo:')

    local nextInfo = inputInfo
    if(PackageUtils.CheckIsSelfDefineType(nextInfo.headName)) then
        if(nextInfo.memberType == PackageUtils.memberType.repeated) then
            local result = {}
            for k,v in pairs(nextInfo) do
                result[k] = v
            end

            result[1] = PackageUtils.SelfDefineType[nextInfo.headName]

            return result
        else
            local result = PackageUtils.SelfDefineType[nextInfo.headName]
            for k,v in pairs(nextInfo) do
                result[k] = v
            end

            return result
        end
    end

    if(PackageUtils.CheckIsBaseType(nextInfo.headName)) then
        return nextInfo
    end

    --logError('构建下一个info失败  headName为:'..tostring(nextInfo.headName))
end


--检查当前类型能否正常写入
function View:CheckCanWriteData(info)
    --PackageUtils.LogError(info,'检查当前类型能否正常写入:')
    local curStatus = self.statusStack[#self.statusStack]
	--当是repeated时  写入的应该是table  
	if(info.memberType == PackageUtils.memberType.repeated and curStatus == self.StatusType[1]) then
		return false
	end

	--只有是基础数据的时候 才能写入
	if(PackageUtils.CheckIsBaseType(info.headName)) then
		return true
	end

	return false
end
--------------------------------------- end  中间相关部分 ---------------------------------------------



---------------------------------------start  右侧相关部分---------------------------------------------

--刷新右侧的显示
function View:RefreshRightPart()
    local msg = '生成错误'
    if(self.MsgStack[1]) then
        msg = PackageUtils.LogError(self.MsgStack[1],'请求数据:',true)
        msg = string.format('请求地址:\n%s \n %s',self.reqUrl,msg)
    end

    if(self.MsgBackStr) then
        msg = string.format('%s\n\n%s\n\n%s',msg,'返回数据:',tostring(self.MsgBackStr))
    end

    self.UIFields.rightPart.DataText.text = msg
end

--------------------------------------- end  右侧相关部分 ---------------------------------------------


function View:ActionIn()

end

function View:ActionOut()

end

function View:OnDestroy()

end

---------------------------------------start  提供给别人用的部分---------------------------------------------

--不需要去测试封包的协议
local IgnoreMessage = {
    ["test"] = true,
    ["LoginWithToken"] = true
}

--过滤协议名字  将不需要测试的协议隐藏掉
function View:MessageFilter(str)
    if(IgnoreMessage[str]) then
        return false
    end

    return true;
end

--------------------------------------- end  提供给别人用的部分 ---------------------------------------------





return View