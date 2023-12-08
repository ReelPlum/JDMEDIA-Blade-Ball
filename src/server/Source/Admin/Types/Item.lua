--[[
Item
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemData = ReplicatedStorage.Data.Items

return function(registry)
	local items = {}

	for _, item in ItemData:GetChildren() do
		table.insert(items, item.Name)
	end

	local itemEnum = registry.Cmdr.Util.MakeEnumType("Item", items)
	registry:RegisterType("item", itemEnum)
	registry:RegisterType("items", registry.Cmdr.Util.MakeListableType(itemEnum))
end
