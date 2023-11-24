--[[
RebirthServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player)
	local UserService = knit.GetService("UserService")
	local RebirthService = knit.GetService("RebirthService")

	local user = UserService:WaitForUser(player)

	RebirthService:Rebirth(user)

	local rebirthLevel = RebirthService:GetUsersRebirthLevel(user)

	return `{player.DisplayName} is now at rebirth level {rebirthLevel}`
end
