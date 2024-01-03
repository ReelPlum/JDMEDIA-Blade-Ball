--[[
SortRarity
2023, 12, 15
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(data, container)
	local n = 0

	local itemData = container.GetItemInformation(data.Item)
	if not itemData then
		return
	end
	local rarity = itemData.Rarity
	if container.Testing then
		local rarityData = require(ReplicatedStorage.Data.Rarities[rarity])
		n = -rarityData.Rank
	else
		local ItemController = knit.GetController("ItemController")
		local rarityData = ItemController:GetRarityData(itemData.Rarity)
		if not rarityData then
			return
		end

		n = -rarityData.Rank
	end

	return n
end
