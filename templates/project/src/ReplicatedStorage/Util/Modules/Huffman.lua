-- HuffmanCoding.lua
local HuffmanCoding = {}

--// Helper function to convert a number to a binary string
local function toBinaryString(num)
	local bin = ""
	while num > 0 do
		bin = (num % 2 == 0 and "0" or "1") .. bin
		num = math.floor(num / 2)
	end
	-- Ensure the binary string is 8 bits long
	while #bin < 8 do
		bin = "0" .. bin
	end
	return bin
end

-- Node class for building the Huffman tree
local Node = {}
Node.__index = Node

function Node.new(char, freq, left, right)
	return setmetatable({
		char = char,
		freq = freq,
		left = left,
		right = right,
	}, Node)
end

-- Function to build frequency table
function HuffmanCoding.buildFrequencyTable(input)
	local freqTable = {}
	for char in input:gmatch(".") do
		freqTable[char] = (freqTable[char] or 0) + 1
	end
	return freqTable
end

-- Function to build Huffman tree
function HuffmanCoding.buildHuffmanTree(freqTable)
	local nodes = {}
	for char, freq in pairs(freqTable) do
		table.insert(nodes, Node.new(char, freq))
	end

	while #nodes > 1 do
		table.sort(nodes, function(a, b)
			return a.freq < b.freq
		end)
		local left = table.remove(nodes, 1)
		local right = table.remove(nodes, 1)
		local parent = Node.new(nil, left.freq + right.freq, left, right)
		table.insert(nodes, parent)
	end

	return nodes[1]
end

-- Function to build code table from Huffman tree
function HuffmanCoding.buildCodeTable(node, prefix, codeTable)
	prefix = prefix or ""
	codeTable = codeTable or {}

	if node.char then
		codeTable[node.char] = prefix
	else
		HuffmanCoding.buildCodeTable(node.left, prefix .. "0", codeTable)
		HuffmanCoding.buildCodeTable(node.right, prefix .. "1", codeTable)
	end

	return codeTable
end

-- Function to encode input string
function HuffmanCoding.encode(input)
	local freqTable = HuffmanCoding.buildFrequencyTable(input)
	local huffmanTree = HuffmanCoding.buildHuffmanTree(freqTable)
	local codeTable = HuffmanCoding.buildCodeTable(huffmanTree)

	local encodedBits = ""
	for char in input:gmatch(".") do
		encodedBits = encodedBits .. codeTable[char]
	end

	-- Convert bits to bytes
	local padding = 8 - (#encodedBits % 8)
	if padding ~= 8 then
		encodedBits = encodedBits .. string.rep("0", padding)
	else
		padding = 0
	end

	local bytes = {}
	for i = 1, #encodedBits, 8 do
		local byte = encodedBits:sub(i, i + 7)
		table.insert(bytes, string.char(tonumber(byte, 2)))
	end

	-- Serialize the tree for decoding
	local treeString = HuffmanCoding.serializeTree(huffmanTree)

	return {
		data = table.concat(bytes),
		tree = treeString,
		padding = padding,
	}
end

-- Function to decode encoded data
function HuffmanCoding.decode(encoded)
	local data = encoded.data
	local treeString = encoded.tree
	local padding = encoded.padding

	local huffmanTree = HuffmanCoding.deserializeTree(treeString)
	local bits = ""
	for i = 1, #data do
		local byte = data:sub(i, i)
		local byteBits = toBinaryString(byte:byte())
		bits = bits .. byteBits
	end

	-- Remove padding
	bits = bits:sub(1, #bits - padding)

	local decoded = ""
	local node = huffmanTree
	for bit in bits:gmatch(".") do
		if bit == "0" then
			node = node.left
		else
			node = node.right
		end

		if node.char then
			decoded = decoded .. node.char
			node = huffmanTree
		end
	end

	return decoded
end

-- Function to serialize Huffman tree into a string
function HuffmanCoding.serializeTree(node)
	if node.char then
		return "1" .. toBinaryString(string.byte(node.char))
	else
		return "0" .. HuffmanCoding.serializeTree(node.left) .. HuffmanCoding.serializeTree(node.right)
	end
end

-- Function to deserialize string back into Huffman tree
function HuffmanCoding.deserializeTree(data)
	local index = 1

	local function deserialize()
		if index > #data then
			return nil
		end
		local flag = data:sub(index, index)
		index = index + 1

		if flag == "1" then
			local byte = data:sub(index, index + 7)
			index = index + 8
			return Node.new(string.char(tonumber(byte, 2)), 0)
		else
			local left = deserialize()
			local right = deserialize()
			return Node.new(nil, 0, left, right)
		end
	end

	return deserialize()
end

return HuffmanCoding
