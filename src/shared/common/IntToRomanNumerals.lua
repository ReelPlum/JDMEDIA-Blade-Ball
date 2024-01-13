local numberMap = {
	{ 1000, "M" },
	{ 900, "CM" },
	{ 500, "D" },
	{ 400, "CD" },
	{ 100, "C" },
	{ 90, "XC" },
	{ 50, "L" },
	{ 40, "XL" },
	{ 10, "X" },
	{ 9, "IX" },
	{ 5, "V" },
	{ 4, "IV" },
	{ 1, "I" },
}

return function(num)
	if num == 0 then
		return 0
	end

	local roman = ""
	while num > 0 do
		for index, v in pairs(numberMap) do
			local romanChar = v[2]
			local int = v[1]
			while num >= int do
				roman = roman .. romanChar
				num = num - int
			end
		end
	end
	return roman
end
