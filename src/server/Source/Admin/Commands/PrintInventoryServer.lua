--[[
PrintInventoryServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player)
	local UserService = knit.GetService("UserService")
	local ItemService = knit.GetService("ItemService")

	local user = UserService:WaitForUser(player)

	--warn(ItemService:GetUsersInventory(user))
	local inventory = ItemService:GetUsersInventory(user)
	warn(inventory)

	return inventory
end
