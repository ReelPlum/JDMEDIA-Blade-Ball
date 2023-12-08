--[[
ItemType
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemData = ReplicatedStorage.Data.Items

return function(registry)
	local items = {}

	for _, item in ItemData:GetChildren() do
		if not item:IsA("ModuleScript") then
			continue
		end

		local data = require(item)
		if not table.find(items, data.ItemType) then
			table.insert(items, data.ItemType)
		end
	end

	local itemEnum = registry.Cmdr.Util.MakeEnumType("Item", items)
	registry:RegisterType("itemType", itemEnum)
	registry:RegisterType("itemTypes", registry.Cmdr.Util.MakeListableType(itemEnum))
end
