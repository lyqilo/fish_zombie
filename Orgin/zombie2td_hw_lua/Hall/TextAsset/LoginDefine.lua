local LoginDefine = {}

--登录类型，正常，注销，重连
LoginDefine.LoginType = {
	Common = 1,
	Logout = 2,
	Reconnect = 3,
	AutoFacebook = 4,
	AutoLine = 5,
	Kickedout = 6
}

LoginDefine.LoginWay = {
	Guest = 1,
	Facebook = 2,
	Line = 3,
	OPPO = 4,
	Phone = 5,
	Apple = 6
}

return LoginDefine
