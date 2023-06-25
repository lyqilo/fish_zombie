local ObjectPool = {}
ObjectPool.__index = ObjectPool

--[[
	createFunc:创建对象函数，返回一个新对象
    initFunc:在Get()之后自动调用，参数为对象自身的回调，一般用来恢复对象初始状态，等等
    releaseFunc:在Release()时调用，参数为对象自身的回调，一般用来处理对象回收后的应该所处状态，等等
	destroyFunc:在Clear()时调用，参数为对象自身的回调，一般用来清理于对象关联的定时器，等等
	capcity:池创建上限数。默认无上限
]]
function ObjectPool.New(createFunc,initFunc,releaseFunc,destroyFunc,capcity)
	if createFunc == nil then
		logError("[ObjectPool]createFunc should not be nil")
	end
	local self = {}
	setmetatable(self,ObjectPool)
	self.queue = List:new()
	self.usedItems = List:new()
	self.createFunc = createFunc
    self.initFunc = initFunc
    self.releaseFunc = releaseFunc
	self.destroyFunc = destroyFunc
	self.capcity = capcity or -1 -- 无上限
	return self
end
 
-- 预先生成指定个数的对象
-- count 需要生成的个数，最大不能超过池大小，若为空则表示直接将池填充满
function ObjectPool:Prewarm(count)
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
		local obj = self.createFunc()
		self:Release(obj)
	end
end

-- 回收一个对象到对象池
function ObjectPool:Release(obj)
    if self.usedItems:find(obj) then
        if self.releaseFunc then
            self.releaseFunc(obj)
        end
		self.usedItems:erase(obj)
		self.queue:push(obj)
	else
		logError("[ObjectPool]invalid state")
	end
end
 
-- 从对象池中获取一个对象，若池为空的，则从Prefab创建一个新的
-- 当对象到达池上限时，会把最早使用的对象回收并作为新对象返回
function ObjectPool:Get()
	local obj = nil
	if self.queue.length == 0 then
		if self.usedItems.length == self.capcity then
			obj = self.usedItems:shift()
		else
			obj = self.createFunc()
			if self.initFunc then
				self.initFunc(obj)
			end
		end
	else
		obj = self.queue:pop()
	end
 
	self.usedItems:push(obj)
	return obj
end
 
-- 将所有被使用的对象全部回收
function ObjectPool:RecycleAll()
	local iter,item = self.usedItems:next()
	while(iter)
	do
		self:Release(item)
		iter,item = self.usedItems:next()
	end
	self.usedItems:clear()
end
 
--清空对象池Destroy
function ObjectPool:Clear()
	self:RecycleAll()
	if self.destroyFunc then
		for i = 0, self.queue.length - 1 do
			self.destroyFunc(self.queue:pop())
		end
	end
	self.queue:clear()
end
 
return ObjectPool