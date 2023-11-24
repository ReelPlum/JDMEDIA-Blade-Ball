--[[
GetCurrencyServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player, item)
	local CurrencyService = knit.GetService("CurrencyService")
	local UserService = knit.GetService("UserService")

	local user = UserService:WaitForUser(player)

	local str = ""
	for currency, val in user.Data.Currencies do
		str = str .. ", " .. currency .. ": " .. val
	end

	return `{player.DisplayName} has {str}`
end
