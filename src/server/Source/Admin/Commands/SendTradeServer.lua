--[[
SendTradeServer
2023, 11, 17
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, target)
	local TradingService = knit.GetService("TradingService")
	local UserService = knit.GetService("UserService")

	local UserA = UserService:WaitForUser(context.Executor)
	local UserB = UserService:WaitForUser(target)

	TradingService:RequestTrade(UserA, UserB)
end
