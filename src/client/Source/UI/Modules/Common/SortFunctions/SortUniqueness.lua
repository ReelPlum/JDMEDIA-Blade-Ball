--[[
SortUniqueness
2023, 12, 15
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local Rankings = { --Higher is better
	[MetadataTypes.Types.Strange] = 10,
	[MetadataTypes.Types.StrangeParts] = 10,
	[MetadataTypes.Types.Autograph] = 15,
	[MetadataTypes.Types.Untradeable] = -100,
}

return function(data, container)
	if not data.Metadata then
		return 1
	end

	local ItemController = knit.GetController("ItemController")

	local n = 0

	local itemData = ItemController:GetItemData(data.Item)
	if not itemData then
		return n
	end
	local rarityData = ItemController:GetRarityData(itemData.Rarity)
	if not rarityData then
		return n
	end

	n = -rarityData.Rank

	for index, _ in data.Metadata do
		if not Rankings[index] then
			continue
		end

		n -= Rankings[index]
	end

	return n
end
