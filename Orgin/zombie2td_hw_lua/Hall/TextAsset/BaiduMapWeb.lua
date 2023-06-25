
local CC = require("CC")
 

local BaiduMapWeb = {}

local Baidu = nil
local BaiduAK = {
    "DXQAbNfMIMhTy3t2M4S0KHdLATj62LBN",
    "BSwArR6HUW74BEZN39xBaXTMbOT93iHq"
}
local PlayerLocation = {}

local ResPonseType = 
{
    Success = "Success",  --成功
    LocationServiceDisable = "LocationServiceDisable", --位置服务不可用
    LocationServiceTimeOut = "LocationServiceTimeOut" , --服务初始化超时
    NotGetLocation = "NotGetLocation" ,        --无法确定设备位置
    BaiduLocationError = "BaiduLocationError", --百度位置定位请求异常
    BaiduCDTransformError = "BaiduCDTransformError", --百度坐标转换请求异常
    BaidDistanceError = "BaidDistanceError", --百度距离计算请求异常
}

function BaiduMapWeb.InitBaiduMap(  )
    Baidu = GameObject.Find("GameManager"):AddComponent(typeof(BaiduUtil))
     local i = math.random(#BaiduAK)
    Baidu:SetBaiduAK( BaiduAK[i] )
end

function BaiduMapWeb.StartGPS(  )
  Baidu:GetGPS()
end

--请求百度位置定位 必须使用百度坐标
function BaiduMapWeb.RuquestBaiduWebLocation( lat ,lng )
  --print("请求百度位置定位")
  Baidu:HttpRuquestBaiduWeb(lat , lng )
end

-- 请求百度位置坐标转换
 function BaiduMapWeb.RuquestBaiduWebCDTransform(lat , lng )
    --print("请求百度位置坐标转换")
    Baidu:HttpRuquestBaiduWebCDTranform(lat , lng)
 end

--请求百度位置距离计算 参数参照testDistance( ) 需要多个点加"|" 分割
function BaiduMapWeb.RuquestBaiduWebCalDistance(originsLatAndLng , destinationsLatAndLng )
  --print("请求百度位置距离计算")
  Baidu:HttpRuquestBaiduWebDistance( originsLatAndLng,  destinationsLatAndLng)
end

--手机位置定位回调
function BaiduMapWeb.OnPhoneLocationResponseResult( lat , lng , resPonseType)
    --print("手机位置定位回调 lat = " .. lat .. " lng = " .. lng .. "resPonseType = " .. tostring(resPonseType)  )
    if resPonseType == ResPonseType.Success then
        BaiduMapWeb.RuquestBaiduWebCDTransform(lat , lng)
    end
end

--百度定位回调
function BaiduMapWeb.OnBaiduLocationResponseResult( locationMsg , resPonseType)
   --print("百度定位回调数据：" .. tostring(locationMsg))
   --print("resPonseType ======================== ".. tostring(resPonseType))
   if resPonseType == ResPonseType.Success then
      PlayerLocation.address = BaiduMapWeb.DecodeBaiduLocationResultJson( locationMsg )
      -- 
      if PlayerLocation.address.formatted_address ~= nil or PlayerLocation.address.formatted_address ~= "" then
         local uft8Arr = Util.ToUTF8Bytes(PlayerLocation.address.formatted_address)
         PlayerLocation.address = Util.FromUTF8Bytes(uft8Arr)
         --print ("PlayerLocation.address.formatted_address ==== "..PlayerLocation.address)
         CC.LocaltionManager.SetLocaltion( PlayerLocation.address)
      else
        --print("PlayerLocation.address.formatted_address =============   nil")
      end
   else

   end
 
end

--百度坐标位置转换回调
function BaiduMapWeb.OnBaiduCDTansformResponseResult( cdTransformMsg , resPonseType )
   --print("百度坐标转换回调数据：" .. tostring(cdTransformMsg))

   if resPonseType == ResPonseType.Success then
        local data = Json.decode(cdTransformMsg)
        --print("status = " .. data.status)
        --print("result.x = " .. data.result[1].x)
        --print("result.y = " .. data.result[1].y)
        local lat = data.result[1].y
        local lng = data.result[1].x
        PlayerLocation.lat = lat
        PlayerLocation.lng = lng
        --print("PlayerLocation.lat = " .. lat .. " PlayerLocation.lng = " .. lng)
        BaiduMapWeb.RuquestBaiduWebLocation( lat ,lng )
   end
end

--百度步行距离计算回调
function BaiduMapWeb.OnBaiduDistanceResponseResult( distanceMsg , resPonseType)
   --print("百度步行距离计算回调:" .. tostring(distanceMsg))
   --print("resPonseType = " .. resPonseType)
   if resPonseType == ResPonseType.Success then
       CC.HallCenter.notificationCenter:post(CC.Notifications.OnBaiduCalDistanceFinish, distanceMsg)
   end 
end

--解析距离计算回调结果
function BaiduMapWeb.DecodeDistanceResultJson( distanceResultJson )
   local data = Json.decode(distanceResultJson)
   local distanceText = data.result[1].distance.text
   local distanceValue = data.result[1].distance.value

   --print("解析距离JSON 距离文本：" .. distanceText .. "距离value=" .. distanceValue)
   return distanceText , distanceValue
end

--解析位置定位回调结果
function BaiduMapWeb.DecodeBaiduLocationResultJson( locationReslutJson )
    local component = {}
    local data = Json.decode(locationReslutJson)
    if data.status ~= 0 then
        return component
    end
    local addressComponent = data.result.addressComponent
    if addressComponent == nil then
        return component
    end
    component.country = addressComponent.country
    component.province = addressComponent.province
    component.city = addressComponent.city
    component.district = addressComponent.district
    component.town = addressComponent.town
    component.street = addressComponent.street
    component.street_number = addressComponent.street_number
    component.direction = addressComponent.direction
    component.distance = addressComponent.distance
    component.formatted_address = data.result.formatted_address

    --print("玩家地址：address ==== " .. tostring(component.formatted_address))
    return component
end

--将玩家位置信息打包成json传服务器
function BaiduMapWeb.EncodePlayerLocationToJson()
     local locationTable = PlayerLocation
     local location = Json.encode(locationTable)
     --print("玩家信息table  转成JSON = " .. location)
     return location
end

local function CalDistance(  lon1,  lat1, lon2,  lat2 )
  local function rad(d)
     return d * math.pi / 180.0;
  end 
        
  if lon1 == nil or lat1 == nil or lon2 == nil or lat2 == nil  then
    return 0
  end

  local EARTH_RADIUS = 6378137; --赤道半径(单位m) 
  local radLat1 = rad(lat1);  
  local radLat2 = rad(lat2);  

  local radLon1 = rad(lon1);  
  local radLon2 = rad(lon2);  

  if radLat1 < 0  then
      radLat1 = math.pi / 2 + math.abs(radLat1);-- south 
  end
     
  if radLat1 > 0 then
    radLat1 = math.pi / 2 - math.abs(radLat1);-- north  
  end
   
  if radLon1 < 0  then
      radLon1 = math.pi * 2 - math.abs(radLon1);-- west  
  end

  if radLat2 < 0 then 
      radLat2 = math.pi / 2 + math.abs(radLat2);-- south  
  end
  if radLat2 > 0 then
      radLat2 = math.pi / 2 - math.abs(radLat2);-- north  
  end
  if radLon2 < 0  then
      radLon2 = math.pi * 2 - math.abs(radLon2);-- west 
  end 

  local x1 = EARTH_RADIUS * math.cos(radLon1) * math.sin(radLat1);  
  local y1 = EARTH_RADIUS * math.sin(radLon1) * math.sin(radLat1);  
  local z1 = EARTH_RADIUS * math.cos(radLat1);  

  local x2 = EARTH_RADIUS * math.cos(radLon2) * math.sin(radLat2);  
  local y2 = EARTH_RADIUS * math.sin(radLon2) * math.sin(radLat2);  
  local z2 = EARTH_RADIUS * math.cos(radLat2);  

  local d = math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)+ (z1 - z2) * (z1 - z2));  
  --余弦定理求夹角  
  local theta = math.acos((EARTH_RADIUS * EARTH_RADIUS + EARTH_RADIUS * EARTH_RADIUS - d * d) / (2 * EARTH_RADIUS * EARTH_RADIUS));  
  local dist = theta * EARTH_RADIUS;  
  return dist;  
end

function  BaiduMapWeb.CalDistanceWithCD( sourceLocation ,destLocation )
  local lon1 = Json.decode(sourceLocation).lng
  local lat1 = Json.decode(sourceLocation).lat

  local lon2 = Json.decode(destLocation).lng
  local lat2 = Json.decode(destLocation).lat

  local distance = CalDistance(  lon1,  lat1, lon2,  lat2 )
  
  --print("通过坐标计算的距离值为：" .. tostring(distance))
  return distance
end

return BaiduMapWeb