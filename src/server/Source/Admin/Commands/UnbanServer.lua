--[[
UnbanServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, userId, t, reason)
	local AdminService = knit.GetService("AdminService")

	local success = AdminService:UnbanUser(userId)
	if success == true then
		return `Unbanned {userId}!`
	end

	return success
end
