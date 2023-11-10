local module = {}

function module.StringToBinary(String)
	local BinaryString = {}

	for i, Character in ipairs(String:split("")) do --> ex: {"A", "B", "C"}
		local Binary = ""
		local Byte = Character:byte() -- convert character to ascii character code

		while Byte > 0 do
			-- apply formula for converting number to binary
			Binary = tostring(Byte % 2) .. Binary
			Byte = math.modf(Byte / 2) -- modf to strip decimal
		end
		table.insert(BinaryString, string.format("%.8d", Binary)) -- format string to always have at least 8 characters (00000000)
	end

	return table.concat(BinaryString, " ")
end

function module.BinaryToString(BinaryString)
	local String = ""

	for i, Binary in ipairs(BinaryString:split(" ")) do --> ex: {"01000001", "01000010", "01000011"}
		local Byte = tonumber(Binary, 2) -- convert binary (base 2) to ascii character code
		String ..= string.char(Byte) -- get character from ascii code and append it at end of string
	end

	return String
end

return module
