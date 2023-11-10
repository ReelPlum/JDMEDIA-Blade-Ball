--[[
Item
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemData = require(ReplicatedStorage.Data.ItemData)

return function(registry)
	local items = {}

	for name, _ in ItemData do
		table.insert(items, name)
	end

	local itemEnum = registry.Cmdr.Util.MakeEnumType("Item", items)
	registry:RegisterType("item", itemEnum)
	registry:RegisterType("items", registry.Cmdr.Util.MakeListableType(itemEnum))
end
