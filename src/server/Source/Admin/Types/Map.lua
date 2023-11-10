--[[
Map
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapData = require(ReplicatedStorage.Data.MapData)

return function(registry)
	local maps = {}

	for name, _ in MapData do
		table.insert(maps, name)
	end

	registry:RegisterType("map", registry.Cmdr.Util.MakeEnumType("Map", maps))
	-- registry:RegisterType("maps", registry.Cmdr.Util.MakeListableType(mapType))
end
