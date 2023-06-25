local CC = require("CC")

local List = CC.class2("List")

local function createNode(data,next,prev)
	local node = {}
	node.data = data
	node.next = next
	node.prev = prev
	return node
end

function List:ctor()
	self.theSize = 0

	self.head = createNode()
	self.tail = createNode()
	self.head.next = self.tail
	self.tail.prev = self.head
end

function List:begin()
	return self.head.next
end

function List:rear()
	return self.tail.prev
end


function List:insert(data, node)
	if not node then return end

	local newNode = createNode(data,node.next,node)
	node.next.prev = newNode
	node.next = newNode
	
	self.theSize = self.theSize + 1
end

function List:erase(node)
	if not node then return end
	node.next.prev = node.prev
	node.prev.next = node.next
	node = nil
	self.theSize = self.theSize - 1
end

function List:pushHead(data)
	self:insert(data, self.head)
end

function List:pushTail(data)
	self:insert(data, self.tail.prev)
end

function List:popHead()
	if self.theSize < 1 then return end

	self:erase(self.head.next)
end

function List:popTail()
	if self.theSize < 1 then return end

	self:erase(self.tail.prev)
end

function List:clear()
	while ( self.theSize ~= 0 ) do
		self:popHead()
	end
end

function List.Clone(list)
	local newList = List.new()
	local node = list.head.next
	while node ~= list.tail do
		local newNode = createNode(node.data,newList.tail,newList.tail.prev)
		newList.tail.prev.next = newNode
		newList.tail.prev = newNode
		node = node.next
	end
	return newList
end

function List:size()
	return self.theSize
end

return List