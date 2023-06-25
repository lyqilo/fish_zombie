local CC = require("CC")

local Queue = CC.class2("Queue")

function Queue:ctor()
	self.objs = CC.List.new()
end

function Queue:push(data)
	self.objs:pushTail(data)
end

function Queue:pop()
	self.objs:popHead()
end

function Queue:size()
	return self.objs:size()
end

function Queue:begin()
	return self.objs:begin()
end

function Queue:rear()
	return self.objs:rear()
end

function Queue:peek()
	local ret = nil

	if self:size() > 0 then
		local node = self:begin()
		ret = node.data
	end

	return ret
end

function Queue:clear()
	self.objs:clear()
end

--兼容old接口
function Queue:pushFront(value)
	self.objs:pushHead(value)
end

function Queue:pushBack(value)
   self.objs:pushTail(value)
end

function Queue:popFront()
    local obj = self:peek()
    self:pop()

    return obj
end

function Queue:popLast()

	local obj = nil
	if self:size() > 0 then
		local node = self:rear()
		obj = node.data
	end

	 self.objs:popTail()
    
    return obj
end

function Queue:front()
	return self:peek()
end

function Queue:isEmpty()
	return self:size() == 0
end


return Queue
