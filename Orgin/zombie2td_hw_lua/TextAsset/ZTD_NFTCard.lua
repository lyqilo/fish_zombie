local GC = require("GC")
local ZTD = require("ZTD")

--NFT卡片
local NFTCard = GC.class2("ZTD_NFTCard")
local vec3Zero = Vector3.zero
local vec3One = Vector3.one
--最高品质
local maxGrade = 6

--data卡牌数据
function NFTCard:ctor(_, data, parent)
	self.id = data.id
	
	self.data = data
	self.transform = ZTD.PoolManager.GetUiItem("ZTD_NFTCard", parent)
	self.rectTrans = self.transform:GetComponent("RectTransform")
	self.textPower = self.transform:FindChild("TextPower"):GetComponent("Text")
	self.textExPower = self.transform:FindChild("TextExPower"):GetComponent("Text")
	self.imgArmed = self.transform:FindChild("ImageArmed")
	self.imgComposed = self.transform:FindChild("ImageComposed")
	self.imgSelected = self.transform:FindChild("ImageSelected")
	self.imgBinding =  self.transform:FindChild("ImageBinding")
	self.textBinding = self.transform:FindChild("TextBinding")
	local lan = ZTD.LanguageManager.GetLanguage("L_ZTD_NFTView");
	self.imgArmed:FindChild("TextArmed"):GetComponent("Text").text = lan.armed
	self.imgComposed:FindChild("TextComposed"):GetComponent("Text").text = lan.composed
	self.textBinding:GetComponent("Text").text = lan.noSell
	self.imgBinding:SetActive(self:IsBinDing())
	self.textBinding:SetActive(self:IsBinDing())
	self:SetPower()
	self:SetGrade(self.data.grade)
	self:SetModel()

end

function NFTCard:SetModel()
	--[[for i=1, 5 do
		self.transform:FindChild("Grade"..i):Hide()
	end--]]
	--模型显示相关
	local cfg = ZTD.NFTConfig.GetGradeConfig(self.data.grade)
	self.cfg = cfg
	local enmeyRoot = self.transform:FindChild("CameraRoot/Camera/EnemyRoot")

	local cameraTran = self.transform:FindChild("CameraRoot")
	cameraTran.transform.position = Vector3(0,ZTD.Flow.cameraIdx*2000,0)
	ZTD.Flow.cameraIdx = ZTD.Flow.cameraIdx + 1
	if ZTD.Flow.cameraIdx > ZTD.Flow.maxIdx then
		ZTD.Flow.cameraIdx = 1
	end
	local camera = self.transform:FindChild("CameraRoot/Camera"):GetComponent("Camera")
	self.camera = camera
	self:SetCameraSize(5)
	if not camera.targetTexture then
		self.renderTexture = UnityEngine.RenderTexture(215,263,1)
		camera.targetTexture = self.renderTexture
		local monsterImage = self.transform:FindChild("BG/MonsterShow"):GetComponent("RawImage")
		monsterImage.texture = self.renderTexture
		monsterImage.gameObject:SetActive(true)
	end
	
	local monsterModel = ZTD.PoolManager.GetGameItem(cfg.modelName)
	monsterModel:SetParent(enmeyRoot)
	monsterModel.localPosition = cfg.modelPos
	monsterModel.localRotation = Quaternion.Euler(cfg.modelRot.x,cfg.modelRot.y,cfg.modelRot.z)
	monsterModel.localScale = cfg.modelScale
	local animator = monsterModel:GetComponentInChildren(typeof(UnityEngine.Animator))
	animator.speed = math.random(80,120)/100
	self.model = monsterModel
	
end
function NFTCard:IsArmed()
	return self.data.armPos > 0
end

function NFTCard:IsBinDing()
	return self.data.status == 1
end

function NFTCard:SetGrade(grade)
	for i=1, maxGrade do
		if grade == i then
			self.transform:FindChild("Grade"..i):Show()
		else
			self.transform:FindChild("Grade"..i):Hide()
		end
		
	end
end

function NFTCard:SetPosition(pos)
	--self.rectTrans.sizeDelta = pos
	self.transform.localPosition = Vector3(pos.x, pos.y, 0)
end
function NFTCard:SetRaycast(isRay)
	self.transform:GetComponent("Image").raycastTarget = isRay
end
function NFTCard:SetCameraSize(size)
	self.camera.orthographicSize = size
end
function NFTCard:SetArmed(armed)
	self.imgArmed:SetActive(armed)
end
function NFTCard:SetComposed(composed)
	self.imgComposed:SetActive(composed)
end
function NFTCard:SetSelected(selected)
	self.imgSelected:SetActive(selected)
end

function NFTCard:SetParent(parent)
	self.transform.parent = parent
	self.transform.localPosition = Vector3.zero
end

function NFTCard:SetScale(scale)
	self.transform.localScale = scale
end
function NFTCard:ResetScale()
	self.transform.localScale = vec3One
end
function NFTCard:ResetPosition()
	self.transform.localPosition = vec3Zero
end
function NFTCard:SetPower()
	self.textPower.text = self.data.power
	self.textExPower.text = string.format("(%d<color=#00ff2c>+%d</color>)",
		self.data.basePower, self.data.exPower)
end


function NFTCard:Release()
	self:SetRaycast(false)
	self:SetArmed(false)
	self:SetComposed(false)
	self:SetSelected(false)
	self:ResetScale()
	
	ZTD.PoolManager.RemoveGameItem(self.cfg.modelName, self.model)
	--GameObject.Destroy(self.renderTexture)
	--ZTD.Extend.Destroy(self.renderTexture)
	ZTD.PoolManager.RemoveUiItem("ZTD_NFTCard", self.transform)
end


return NFTCard