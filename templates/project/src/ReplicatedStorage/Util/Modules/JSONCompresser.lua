local CompressionModule = {}

-- Simple RLE Compression Function
function CompressionModule.compress(jsonString)
	local compressed = ""
	local length = #jsonString
	local i = 1

	while i <= length do
		local count = 1
		local char = jsonString:sub(i, i)

		while i + 1 <= length and jsonString:sub(i + 1, i + 1) == char and count < 255 do
			count = count + 1
			i = i + 1
		end

		compressed = compressed .. char .. string.char(count)
		i = i + 1
	end

	return compressed
end

-- Simple RLE Decompression Function
function CompressionModule.decompress(compressedString)
	local decompressed = ""
	local length = #compressedString
	local i = 1

	while i <= length do
		local char = compressedString:sub(i, i)
		local count = compressedString:byte(i + 1)
		decompressed = decompressed .. string.rep(char, count)
		i = i + 2
	end

	return decompressed
end

return CompressionModule
