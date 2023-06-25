local GC = require("GC")
local ZTD = require("ZTD")

--点击推送逻辑

local LockPop = {}

function LockPop.Init()  
end

function LockPop.CanOpenLockPop(key)
    local state = nil
	local data = LockPop.GetAllLockPop()
	-- log("key="..key)
    -- log("CanOpenLockPop data="..GC.uu.Dump(data))
	if not data.isOpenLockPop then
		local temp = nil
		if not LockPop.isTomorrow() then
			temp = not LockPop.GetLockPopByKey(key)
		else
			temp = true
		end
		data.year = os.date("*t").year
		data.month = os.date("*t").month
		data.day = os.date("*t").day
        data.isOpenLockPop = true
		GC.UserData.Save(ZTD.gamePath.."LockPop", data)
		return temp
    elseif data.isOpenLockPop then
        if LockPop.isTomorrow() then
            data.year = os.date("*t").year
            data.month = os.date("*t").month
            data.day = os.date("*t").day
			data.isOpenLockPop = false
			data.LangZhu = false
			data.LongMu = false
			data.OneKey = false
			data.Trusteeship = false
			data.EliteArena = false
			data.MasterArena = false
			data.NotEnoughV1= false
			data.NotEnoughV2 = false
			GC.UserData.Save(ZTD.gamePath.."LockPop", data)
            return true
		else
            return not LockPop.GetLockPopByKey(key)
        end
    end
end

function LockPop.OpenLockPopView(str, confirmFunc, sortingOrder)
	local cancelFunc = function()
		LockPop.CloseAllLockPop()
	end
	local language = ZTD.LanguageManager.GetLanguage("L_ZTD_TipConfig")
	ZTD.ViewManager.OpenExtenPopView(str, confirmFunc, cancelFunc, language.txt_confirmPop, language.txt_cancelPop, sortingOrder)
end

function LockPop.GetAllLockPop()
	return GC.UserData.Load(ZTD.gamePath.."LockPop")
end

function LockPop.CloseAllLockPop()
    local data = LockPop.GetAllLockPop()
    data.LangZhu = true
    data.LongMu = true
    data.OneKey = true
    data.Trusteeship = true
    data.EliteArena = true
    data.MasterArena = true
    data.NotEnoughV1= true
    data.NotEnoughV2 = true
	GC.UserData.Save(ZTD.gamePath.."LockPop", data)
end

function LockPop.isTomorrow()
	local curYear = os.date("*t").year
	local curMonth = os.date("*t").month
	local curDay = os.date("*t").day
	local year = GC.UserData.Load(ZTD.gamePath.."LockPop").year or 0
	local month = GC.UserData.Load(ZTD.gamePath.."LockPop").month or 0
	local day = GC.UserData.Load(ZTD.gamePath.."LockPop").day or 0
	if curYear > year then
		return true
	elseif curYear == year then
		if curMonth > month then
			return true
		elseif curMonth == month then
			if curDay > day then
				return true
			end
		end
    else
		return false
	end
	return false
end

function LockPop.GetLockPopByKey(key)
    local data = LockPop.GetAllLockPop()
	if key == "LangZhu" then
		return data.LangZhu
	elseif key == "LongMu" then
		return data.LongMu
	elseif key == "OneKey" then
		return data.OneKey
	elseif key == "Trusteeship" then
		return data.Trusteeship
	elseif key == "EliteArena" then
		return data.EliteArena
	elseif key == "MasterArena" then
		return data.MasterArena
	elseif key == "NotEnoughV1" then
		return data.NotEnoughV1
	elseif key == "NotEnoughV2" then
		return data.NotEnoughV2
	end
end

return LockPop