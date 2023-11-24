--[[
EquipItemServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

return function(context, player, item)
	local EquipmentService = knit.GetService("EquipmentService")
	local UserService = knit.GetService("UserService")

	local user = UserService:WaitForUser(player)

	local success = EquipmentService:EquipItem(user, item)

	if not success then
		return `Could not equip {item} on {player.DisplayName}...`
	end

	return `Equipped {item} on {player.DisplayName}!`
end
