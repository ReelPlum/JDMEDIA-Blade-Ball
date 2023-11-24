--[[
BanServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player, t, reason)
	local AdminService = knit.GetService("AdminService")

	local success = AdminService:BanUser(player.UserId, t, reason)
	if success == true then
		return `Banned {player.DisplayName}!`
	end

	return success
end
