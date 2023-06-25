local CC = require "CC"
local TrailIOSGameList = require "view.trailview.trailiosgamelist"

local CompositeJP = CC.uu.ClassView("CompositeJP")

local _OnClickBtn

local Table_Rand
local CalCulate_Table
local Current_Saoguang

function CompositeJP:ctor(param)
    self.resultElementCount={[8]=0,[9]=0,[10]=0,[11]=0}
    self.resultElement={}
    self.clickCount=0
    self.clickTargerCount=0
    self.elementArray={}
    self.shakeElementArray={}
    self.showElementArray={}
    self.hasClickItems={}
    self.shakeView=nil
    self.timeCount=0
    self.CountdownTime=0
    self.showCoinCount=0
    self.isCDFinish = false
    --现在类型为1234，映射为这个代码对应类型的8，9，10，11
    self.targetType = param.targetType + 7
    self.JP1 = param.JP1
    self.JP2 = param.JP2
    self.JP3 = param.JP3
    self.JP4 = param.JP4
    self.finishCall = param.finishCall
end

function CompositeJP:OnCreate()
    self.language = CC.LanguageManager.GetLanguage("L_CompositeView")
    self.text_MiniNum = self:SubGet("Mini/Mini/Horizontal/Text","NumberRoller")
    self.text_GrandNum = self:SubGet("Grand/Grand/Horizontal/Text","NumberRoller")
    self.text_MajorNum = self:SubGet("Major/Major/Horizontal/Text","NumberRoller")
    self.text_MinorNum = self:SubGet("Minor/Minor/Horizontal/Text","NumberRoller")

    for i = 1,12 do
        local child = self:FindChild("rewardGroup/Symbol16:"..i)
        child.transform.name=child.transform.name..":"..i
        child.transform.interactable =false
        self:AddClick(child.transform,function() _OnClickBtn(self,child,i) end)
        table.insert(self.elementArray,child)
    end
    self.transform:SetActive(false)
    self.CDText = self:SubGet("CD","Text")
    self:LanguageSwitch()
    self:Play()
end

function CompositeJP:LanguageSwitch()
	self:FindChild("Tip").text = self.language.JPTip
	self:FindChild("CD").text = self.language.JPCD
end

function CompositeJP:CreateOriginalBlock()
  self:ShowAllCoin()
end

function CompositeJP:Play()
    self.transform:SetActive(true)

    self.cameraTargetPosition=Vector3(0,2.33,-10.09)

    self.resultElementCount={[8]=0,[9]=0,[10]=0,[11]=0}
    self.resultElement={}
    self.resultView={}
    self.clickCount=0
    self.clickTargerCount=0
    self:GetJackPotResultElement()
    self.shakeElementArray={}
    self.showElementArray={}
    self.hasClickItems={}
    self.shakeView=nil
    self.timeCount=0
    self.CountdownTime=0
    self.showCoinCount=0
    self.stopCoinShake = false --金币扫光标识符
    for i,v in ipairs(self.elementArray) do
        table.insert(self.shakeElementArray,v)
        table.insert(self.showElementArray,v)
        table.insert(self.hasClickItems,false)
    end
    self:UpdateUiJackpotText()
    self:CreateOriginalBlock()
end

function CompositeJP:ShowAllCoin()
  UpdateBeat:Add(self.ShakeItem,self)
  self:DelayRun(0.2,function ()
    CC.Sound.PlayHallEffect("jackpot_dragon")
    self:DelayRun(1.8,function (  )
      CC.Sound.PlayHallEffect("jackpot_dragon")
    end)
  end)
  self:DelayRun(0.2,function ( ... )
    CC.Sound.PlayHallEffect("jackpot_gold_spread")
    self:DelayRun(0.2,function ( ... )
      math.randomseed(os.clock()+12345)
      local ran = math.random(1,#self.showElementArray)
      self:ShowCoin(ran,self.showElementArray[ran])
    end)
  end)
end

function CompositeJP:ShowCoin(index,view)
  self.showCoinCount=self.showCoinCount+1
  view.transform.interactable =false
  view.transform:SetActive(true)
  view.transform:FindChild("Effect_CaiShen_FanJinBi"):SetActive(true)
  if self.showCoinCount<12 then
      self:DelayRun(0.1,function()
          table.remove(self.showElementArray ,index)
          math.randomseed(os.clock()+12345)
          local ran = math.random(1,#self.showElementArray)
          self:ShowCoin(ran,self.showElementArray[ran])
      end)
  else
      for i,v in ipairs(self.elementArray) do
          v.transform.interactable=true
      end
  end
end

function CompositeJP:UpdateUiJackpotText()
  local jackPoolNum = {
    self.JP1,
    self.JP2,
    self.JP3,
    self.JP4,
  }
  local time = 5
  if self.text_MiniNum and self.text_GrandNum and self.text_MajorNum and self.text_MinorNum  then
      self:FindChild("Grand/Grand/Horizontal/GameObject"):SetActive(true)
      self:FindChild("Major/Major/Horizontal/GameObject"):SetActive(true)
      self:FindChild("Minor/Minor/Horizontal/GameObject"):SetActive(true)
      self:FindChild("Mini/Mini/Horizontal/GameObject"):SetActive(true)
      jackPoolNum[1]= math.modf( jackPoolNum[1]/1000)
      jackPoolNum[2]= math.modf( jackPoolNum[2]/1000)
      jackPoolNum[3]= math.modf( jackPoolNum[3]/1000)
      jackPoolNum[4]= math.modf( jackPoolNum[4]/1000)

      self.text_GrandNum:RollTo(jackPoolNum[1],time)
      self.text_MajorNum:RollTo(jackPoolNum[2],time)
      self.text_MinorNum:RollTo(jackPoolNum[3],time)
      self.text_MiniNum:RollTo(jackPoolNum[4],time)
  end
end

_OnClickBtn = function(self,view,index)
  if self.clickCount>12 or self.clickTargerCount>=3  then return end
  if self.shakeView == view then
    self.stopCoinShake = true
  end
  self.timeCount=0
  -- self.CountdownTime=0
  self.clickCount=self.clickCount+1
  self.hasClickItems[index]=true
  view.transform.interactable =false
  CC.Sound.PlayHallEffect("jackpot_gold_click")
  view.transform:FindChild("Effect_CaiShen_FanJinBi"):SetActive(false)
  view.transform:FindChild("Effect_FanJinBi_SaoGuang"):SetActive(false)
  view.transform:FindChild("JackPotImage"..tostring(self.resultElement[self.clickCount])):SetActive(true)
  for i , v in ipairs(self.shakeElementArray) do
    if v==view then
      table.remove(self.shakeElementArray ,i)
      if self.shakeView==view then
          self.shakeView=nil
      end
      break
    end
  end

  if self.resultElement[self.clickCount]== self.targetType then
      self.clickTargerCount=self.clickTargerCount+1
      table.insert(self.resultView,view)
  end

  if self.clickTargerCount>=3 then
    self.CDText.text = ""
    UpdateBeat:Remove(self.ShakeItem,self)
    CC.Sound.PlayHallEffect("jackpot_bell2")
      self:DelayRun(2,function ( ... )
        self:ShowRewardIcons()
    end)
    self:DelayRun(6, function()
      self:ShowAll()
    end)
  end
end

function CompositeJP:ShowAll(addShowTime)
    self.isCDFinish = true
    if not CC.uu.IsNil(Current_Saoguang) then
      Current_Saoguang:SetActive(false)
    end

    local trans
    if self.targetType == 11 then
      trans = self.transform:Find("Grand/Grand")
    elseif self.targetType == 10 then
      trans = self.transform:Find("Major/Major")
    elseif self.targetType == 9 then
      trans = self.transform:Find("Minor/Minor")
    elseif self.targetType == 8 then
      trans = self.transform:Find("Mini/Mini")
    end
    trans.position = self.transform:Find("OutcomeParent").position

    self.stopCoinShake = false
    local count = 0
    local index = 0
    local key = 0 --第一次出现3个图标的下标
    local tCount = 0 --临时计数器
    local dRate = self.clickCount > 0 and 0 or 0.6 --图标延迟出现时间变化率
    local totalTime = 0 --图标延迟出现的时间
    local dTime = 0 --玩家未操作第一次出现3个图标的延迟时间
    local unUseElement = {}
    for i=self.clickCount + 1, #self.resultElement,1 do
      if tCount < 3 and self.resultElement[i] == self.targetType then
        tCount = tCount + 1
      elseif tCount == 3 and key == 0 then
        key = i
      end
      table.insert(unUseElement, self.resultElement[i])
    end
    if self.clickCount > 0 and key == 0 then
      key = 12
    end
    for i,v in ipairs(self.elementArray) do
      if self.hasClickItems[i]~=true then
        count=count+1
        v.transform.interactable =false
        totalTime = dRate * count
        if  i == key then
          dTime = totalTime

          self:DelayRun(totalTime,function ( ... )
            UpdateBeat:Remove(self.ShakeItem,self)
            CC.Sound.PlayHallEffect("jackpot_bell2")
          end)

          self:DelayRun(0.5 + totalTime,function ( ... )
            self:ShowRewardIcons()
          end)
        end
        if i>= key and self.clickCount == 0 then
          totalTime = dTime + dRate * 5
        end
        self:DelayRun(totalTime,function()
          index = index + 1
          if  self.clickTargerCount<3 and unUseElement[index]==self.targetType then
            self.clickTargerCount=self.clickTargerCount+1
            table.insert(self.resultView,v)
          end
          v.transform:FindChild("Effect_CaiShen_FanJinBi"):SetActive(false)
          CC.Sound.PlayHallEffect("jackpot_gold_click")
          v.transform:FindChild("JackPotImage"..tostring(unUseElement[index])):SetActive(true)
        end)
      end
    end
    local addTime = addShowTime or 0
    self:DelayRun(totalTime + dRate + 2.2 + addTime,function ()
      if self.finishCall then
        self.finishCall()
        -- self:FindChild("Mask").gameObject:SetActive(false)
      end
    end)
end

function CompositeJP:ShowRewardIcons()
  for i,v in ipairs(self.resultView) do
    v.transform:FindChild("JackPotImage"..tostring(self.targetType).."_reward"):SetActive(true)
  end
end

function CompositeJP:HideRewardIcons()
  for i,v in ipairs(self.resultView) do
    v.transform:FindChild("JackPotImage"..tostring(self.targetType).."_reward"):SetActive(false)
  end
end

local CDTime = 25
function CompositeJP:ShakeItem()
  self.timeCount = self.timeCount+Time.deltaTime
  self.CountdownTime = self.CountdownTime+Time.deltaTime
  if self.CountdownTime >= CDTime then
    if not self.isCDFinish then
      self:ShowAll(2)
    end
    self.CountdownTime = 0
  else
      if self.timeCount >= 3 and not self.stopCoinShake then
        if self.shakeView==nil then
          math.randomseed(os.clock()+12345)
          local ran = math.random(1,#self.shakeElementArray)
          self.shakeView=self.shakeElementArray[ran]
        end
        if not Current_Saoguang then
          Current_Saoguang = self.shakeView.transform:FindChild("Effect_FanJinBi_SaoGuang")
          Current_Saoguang:SetActive(true)
        end
        self.timeCount=0
      end
  end

  local cdTime = CDTime - self.CountdownTime
  cdTime = math.ceil(cdTime)
  cdTime = string.format("หลัง<color=#FF0000FF>%ss</color>จะเปิดรางวัลอัตโนมัติ",cdTime)
  if self.clickTargerCount >= 3 then
    cdTime = ""
  end
  if self.isCDFinish then
    cdTime = ""
  end
  self.CDText.text = cdTime
end

function CompositeJP:MoveGameBoard(bshow)
  if not bshow then
    --向左移动
    local moveLeftElements={}
    table.insert(moveLeftElements,self.text_GrandNum.transform.parent.parent)
    table.insert(moveLeftElements,self.text_MiniNum.transform.parent.parent)
    table.insert(moveLeftElements,self.elementArray[1])
    table.insert(moveLeftElements,self.elementArray[2])
    table.insert(moveLeftElements,self.elementArray[5])
    table.insert(moveLeftElements,self.elementArray[6])
    table.insert(moveLeftElements,self.elementArray[9])
    table.insert(moveLeftElements,self.elementArray[10])

    local time = 1.2
    self:DelayRun(0.5,function ( ... )
        self:HideRewardIcons()
    end)
    -- 上半部向上移动包括棋盘(棋盘位移)
    -- log("向上移动的offset 参数: offsetY 值:" .. tostring( offsetY))
    local moveBy = {"localMoveBy",-Screen.width/2,0,time}
    local fadeTo = {"fadeToAll",0,time}
    for i,v in ipairs(moveLeftElements) do
        self:RunAction(v,{{moveBy}})
        self:RunAction(v,{{fadeTo}})
    end

    --向右移动
    local  moveRightElement = {}
    table.insert(moveRightElement,self.text_MajorNum.transform.parent.parent)
    table.insert(moveRightElement,self.text_MinorNum.transform.parent.parent)
    table.insert(moveRightElement,self.elementArray[3])
    table.insert(moveRightElement,self.elementArray[4])
    table.insert(moveRightElement,self.elementArray[7])
    table.insert(moveRightElement,self.elementArray[8])
    table.insert(moveRightElement,self.elementArray[11])
    table.insert(moveRightElement,self.elementArray[12])

    moveBy = {"localMoveBy",Screen.width/2,0,time}
    for i,v in ipairs(moveRightElement) do
        self:RunAction(v,{{moveBy}})
        self:RunAction(v,{{fadeTo}})
    end

  else
    --向右移动
    local moveLeftElements={}
    table.insert(moveLeftElements,self.text_GrandNum.transform.parent.parent)
    table.insert(moveLeftElements,self.text_MiniNum.transform.parent.parent)
    table.insert(moveLeftElements,self.elementArray[1])
    table.insert(moveLeftElements,self.elementArray[2])
    table.insert(moveLeftElements,self.elementArray[5])
    table.insert(moveLeftElements,self.elementArray[6])
    table.insert(moveLeftElements,self.elementArray[9])
    table.insert(moveLeftElements,self.elementArray[10])

    local time = 0.1
    -- 上半部向上移动包括棋盘(棋盘位移)
    -- log("向上移动的offset 参数: offsetY 值:" .. tostring( offsetY))
    local moveBy = {"localMoveBy",Screen.width/2,0,time}
    for i,v in ipairs(moveLeftElements) do
        self:RunAction(v,{{moveBy}})
    end
    --向左移动
    local  moveRightElement = {}
    table.insert(moveRightElement,self.text_MajorNum.transform.parent.parent)
    table.insert(moveRightElement,self.text_MinorNum.transform.parent.parent)
    table.insert(moveRightElement,self.elementArray[3])
    table.insert(moveRightElement,self.elementArray[4])
    table.insert(moveRightElement,self.elementArray[7])
    table.insert(moveRightElement,self.elementArray[8])
    table.insert(moveRightElement,self.elementArray[11])
    table.insert(moveRightElement,self.elementArray[12])
    moveBy = {"localMoveBy",-Screen.width/2,0,time}
    for i,v in ipairs(moveRightElement) do
        self:RunAction(v,{{moveBy}})
    end
    local fadeTo = {"fadeToAll",255,time}
    local text_jackpot={}
    table.insert(text_jackpot,self.text_GrandNum.transform.parent.parent)
    table.insert(text_jackpot,self.text_MiniNum.transform.parent.parent)
    table.insert(text_jackpot,self.text_MajorNum.transform.parent.parent)
    table.insert(text_jackpot,self.text_MinorNum.transform.parent.parent)
    for i,v in ipairs(text_jackpot) do
        self:RunAction(v,{{fadeTo}})
    end
  end
end

function CompositeJP:GetJackPotResultElement()
    local jpKeyValue = {[8] = 0, [9] = 0, [10] = 0, [11] = 0}
    while true do
        math.randomseed(os.clock()+12345)
        local jpType = math.random(8,11)
        self.resultElementCount[jpType]=self.resultElementCount[jpType]+1
        if jpType ~=  self.targetType and self.resultElementCount[jpType] >= 3 then
        else
            jpKeyValue[jpType] = jpKeyValue[jpType] + 1
            table.insert(self.resultElement,jpType)
            if self.resultElementCount[self.targetType] >= 3 then
                    break
            end
        end
    end
    -- log("中奖数据的数组:"..CC.uu.Dump(self.resultElement))
    self.resultElement = Table_Rand(self.resultElement)--在这一步之前数组中的数据可能是按规律排列，如{10,10,11,11,9,9,9}，所以在此先打乱一次
    -- log("整理之前数据:"..CC.uu.Dump(self.resultElement))
    local count = 12-#self.resultElement
    local jpArray = {}
    jpArray = CalCulate_Table(jpKeyValue,jpArray,count)
    jpArray = Table_Rand(jpArray)
    -- log("打乱的数组："..CC.uu.Dump(jpArray))
    for i,v in ipairs(jpArray) do
      table.insert(self.resultElement, v)
    end
    -- log("整理之后数据:"..CC.uu.Dump(self.resultElement))
end

CalCulate_Table = function(bTable,vTable,count)
    local jpType = 8
    while count > 0 do
      if jpType > 11 then
        break
      end
      if bTable[jpType] < 3 then
        bTable[jpType] = bTable[jpType] + 1
        table.insert(vTable, jpType)
        count = count - 1
      else
        jpType = jpType + 1
      end
    end
    return vTable
end

Table_Rand = function(t)
  if t == nil then
    return
  end

  local tRet = {}

  local Total = table.getn(t)


  while Total > 0 do
    math.randomseed(os.clock()+Total*12345)
    local i = math.random(1, Total)
    table.insert(tRet, t[i])
    t[i] = t[Total]
    Total = Total - 1
  end

  return tRet
end

return CompositeJP