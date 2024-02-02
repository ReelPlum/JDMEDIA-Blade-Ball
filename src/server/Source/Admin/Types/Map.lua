--[[
Map
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapData = ReplicatedStorage.Data.Maps

return function(registry)
	local maps = {}

	for _, module in MapData:GetChildren() do
		table.insert(maps, module.Name)
	end

	registry:RegisterType("map", registry.Cmdr.Util.MakeEnumType("Map", maps))
	-- registry:RegisterType("maps", registry.Cmdr.Util.MakeListableType(mapType))
end
