--[[
EnchantEquippedItemServer
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

return function(context, player, itemType)
	local EquipmentService = knit.GetService("EquipmentService")
	local EnchantingService = knit.GetService("EnchantingService")
	local UserService = knit.GetService("UserService")

	local user = UserService:WaitForUser(player)

	local id = EquipmentService:GetIdOfEquippedItemOfType(user, itemType)
	if not id then
		return `{player.DisplayName} did not have a item equipped with the type {itemType}`
	end

	local success = EnchantingService:ApplyRandomEnchantOnUsersItem(user, id)
	if not success then
		return `Something went wrong while enchanting...`
	end

	return `Successfully enchanted {player.DisplayName}'s item of type {itemType}!`
end
