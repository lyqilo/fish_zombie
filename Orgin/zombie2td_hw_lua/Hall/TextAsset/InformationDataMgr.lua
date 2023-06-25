
local CC = require("CC")

local KEY_NAME = "InformationLogisticsData"

local InformationDataMgr = {}
local this = InformationDataMgr

local Name
local PhoneNum
local Address
local Contact

function this.UpdateLogisticsData(data)
	if data then
		if data.Name and data.Name ~= "" then
			Name = data.Name
		end
		if data.PhoneNum and data.PhoneNum ~= "" then
			PhoneNum = data.PhoneNum
		end
		if data.Address and data.Address ~= "" then
			Address = data.Address
		end
		if data.Contact and data.Contact ~= "" then
			Contact = data.Contact
		end
		this.SaveLogisticsData()
	end
end

function this.SaveLogisticsData()
	local content = {Name = Name, PhoneNum = PhoneNum, Address = Address, Contact = Contact}
	CC.UserData.Save(KEY_NAME,content)
end

--点击提交
function this.GetLogisticsData(callback)
	if Name or PhoneNum or Address or Contact then
		log("GetLogisticsData cache")
		callback({Name = Name, PhoneNum = PhoneNum, Address = Address, Contact = Contact})
		return
	end

	local localData = CC.UserData.Load(KEY_NAME)
	if localData and (localData.Name or localData.PhoneNum or localData.Address or localData.Contact) then
		log(CC.uu.Dump(localData,"GetLogisticsData local",10))
		Name = localData.Name
		PhoneNum = localData.PhoneNum
		Address = localData.Address
		Contact = localData.Contact
		callback(localData)
		return
	end

	this.ReqLogisticsData(callback)

end

function this.ReqLogisticsData(callback)
	local url = ""
	local wwwForm
	url,wwwForm = this.GetLogisticsInfo(url,wwwForm)
	log("-----GetLogisticsDataUrl: "..url)
	CC.HttpMgr.PostForm(url,wwwForm,function(www)
		log("Logistics success   "..tostring(www.downloadHandler.text))
		local jsonData = Json.decode(www.downloadHandler.text)
		local data = jsonData.data
		CC.ViewManager.CloseConnecting()
		if jsonData.status == 1 and data ~= "" then
			if data.Name then
				Name = data.Name
			end
			if data.PhoneNum then
				PhoneNum = data.PhoneNum
			end
			if data.Address then
				Address = data.Address
			end
			if data.Contact then
				Contact = data.Contact
			end
			this.SaveLogisticsData()
			if callback then
				callback(data)
			end
		else
			if callback then
				callback()
			end
		end
	end, function(error)
		if callback then
			callback()
		end
	end)
end

--获取个人信息
function this.GetLogisticsInfo(url,wwwForm)
	local ts = os.time()
	local playerID = CC.Player.Inst():GetSelfInfoByKey("Id")
	local sign = Util.Md5(playerID..ts..CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetWebKey())
	url = CC.DataMgrCenter.Inst():GetDataByKey("WebUrl").GetLogisticsInfoUrl()
	wwwForm = UnityEngine.WWWForm.New()
	wwwForm:AddField("PlayerID",playerID)
	wwwForm:AddField("ts",ts)
	wwwForm:AddField("sign",sign)
	return url,wwwForm
end

return InformationDataMgr