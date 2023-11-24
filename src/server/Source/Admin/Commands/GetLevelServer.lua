--[[
GetLevelServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player, item)
	local ExperienceService = knit.GetService("ExperienceService")
	local UserService = knit.GetService("UserService")

	local user = UserService:WaitForUser(player)

	local level = ExperienceService:GetUsersLevel(user)

	return `{player.DisplayName}'s level is {level}`
end
