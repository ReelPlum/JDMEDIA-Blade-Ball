--[[
SortName
2023, 12, 15
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(data, container)
	local n = 0

	local ItemController = knit.GetController("ItemController")
	local itemData = ItemController:GetItemData(data.Item)

	if not itemData then
		warn(data.Item)
		return -math.huge
	end

	local bitwiseshift = '1'
	for i, letter in itemData.DisplayName:split("") do

		letter = string.lower(letter)
		if letter == " " then
			continue
		end

		if i == 1 then
			n += (string.byte(letter))
		else
			bitwiseshift = bitwiseshift.."00"
			n += (string.byte(letter))/tonumber(bitwiseshift)
		end
	end

	return n
end
