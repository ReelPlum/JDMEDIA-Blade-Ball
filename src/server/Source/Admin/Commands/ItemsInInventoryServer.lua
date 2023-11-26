--[[
ItemsInInventoryServer
2023, 11, 26
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player)
	local ItemService = knit.GetService("ItemService")
	local UserService = knit.GetService("UserService")

	local user = UserService:WaitForUser(player)
	local inventory = ItemService:GetUsersInventory(user)

	local n = 0
	for _, _ in inventory do
		n += 1
	end

	return `{player.DisplayName} had {n} item(s) in their inventory!`
end
