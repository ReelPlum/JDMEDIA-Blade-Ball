--[[
GiveCurrencyServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, player, currency, amount)
	local CurrencyService = knit.GetService("CurrencyService")
	local UserService = knit.GetService("UserService")

	local user = UserService:WaitForUser(player)

	CurrencyService:GiveCurrency(user, currency, amount or 1)

	return `Gave {player.DisplayName} {amount} {currency}!`
end
