--[[
ItemType
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemData = require(ReplicatedStorage.Data.ItemData)

return function(registry)
	local items = {}

	for _, data in ItemData do
		if not table.find(items, data.ItemType) then
			table.insert(items, data.ItemType)
		end
	end

	local itemEnum = registry.Cmdr.Util.MakeEnumType("Item", items)
	registry:RegisterType("itemType", itemEnum)
	registry:RegisterType("itemTypes", registry.Cmdr.Util.MakeListableType(itemEnum))
end
