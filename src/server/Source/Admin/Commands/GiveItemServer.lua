--[[
GiveItemServer
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

return function(context, player, items, quantities)
	local ItemService = knit.GetService("ItemService")
	local UserService = knit.GetService("UserService")

	local user = UserService:WaitForUser(player)

	if not quantities then
		quantities = {}
	end

	local t = {}
	for index, item in items do
		local quantity = quantities[index] or 1
		t[item] = quantity
	end

	ItemService:GiveUserMultipleItems(user, t, {
		[MetadataTypes.Types.Admin] = context.Executor.UserId,
	})

	return `Gave {player.DisplayName} all the items you specified!`
end
