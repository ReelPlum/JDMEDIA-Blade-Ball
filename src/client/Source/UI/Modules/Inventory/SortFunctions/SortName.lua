--[[
SortName
2023, 12, 15
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return function(data, container)
	local n = 0

	for i, letter in data.Item:split("") do
		letter = string.lower(letter)
		if letter == " " then
			continue
		end

		n -= (string.byte(letter) - 96)
	end

	return n
end
