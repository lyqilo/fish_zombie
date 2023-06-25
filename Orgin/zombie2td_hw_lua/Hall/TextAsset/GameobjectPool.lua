local GameobjectPool = {}
GameobjectPool.__index = GameobjectPool

--[[
	prefab:预设
	createFunc:在创建对象之后自动调用，参数为对象自身的回调，一般用来设置父节点，等等
	initFunc:在Get()之后自动调用，参数为对象自身的回调，一般用来恢复对象初始状态
	capcity:池创建上限数。默认无上限
]]
function GameobjectPool.New(prefab,createFunc,initFunc,capcity)
	if prefab == nil then
		logError("[GameobjectPool]prefab should not be nil")
	end
	local self = {}
	setmetatable(self,GameobjectPool)
	self.prefab = prefab
	self.queue = List:new()
	self.usedItems = List:new()
	self.createFunc = createFunc
	self.initFunc = initFunc
	self.capcity = capcity or -1 -- 无上限
	return self
end
 
-- 预先生成指定个数的对象
-- count 需要生成的个数，最大不能超过池大小，若为空则表示直接将池填充满
function GameobjectPool:Prewarm(count)
	if count == nil then
		if self.capcity == -1 then
			count = 0
		else
			count = self.capcity
		end
	elseif count > self.capcity then
		count = self.capcity
	end
 
	for i=1,count do
		local obj =  GameObject.Instantiate(self.prefab)
		if self.createFunc then
			self.createFunc(obj)
		end
		obj:SetActive(false)
		self.queue:push(obj)
	end
end
 
-- 回收一个对象到对象池
function GameobjectPool:Release(obj)
	if self.usedItems:find(obj) then
		self.usedItems:erase(obj)
		obj:SetActive(false)
		self.queue:push(obj)
	else
		logError("[GameobjectPool]invalid state")
	end
end
 
-- 从对象池中获取一个对象，若池为空的，则从Prefab创建一个新的
-- 当对象到达池上限时，会把最早使用的对象回收并作为新对象返回
function GameobjectPool:Get()
	local obj = nil
	if self.queue.length == 0 then
		if self.usedItems.length == self.capcity then
			obj = self.usedItems:shift()
			obj:SetActive(false)
		else
			obj = GameObject.Instantiate(self.prefab)
			if self.createFunc then
				self.createFunc(obj)
			end
		end
	else
		obj = self.queue:pop()
	end
	if self.initFunc then
		self.initFunc(obj)
	end
	self.usedItems:push(obj)
	obj:SetActive(true)
	return obj
end
 
-- 将所有被使用的对象全部回收
function GameobjectPool:RecycleAll()
	local iter,item = self.usedItems:next()
	while(iter)
	do
		self:Release(item)
		iter,item = self.usedItems:next()
	end
	self.usedItems:clear()
end
 
--清空对象池Destroy
function GameobjectPool:Clear()
 
	self:RecycleAll()
 
	for i = 0, self.queue.length - 1 do
		GameObject.Destroy(self.queue:pop())
	end
 
	self.queue:clear()
end
 
return GameobjectPool