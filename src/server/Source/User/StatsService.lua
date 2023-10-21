--[[
StatsService
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local StatsService = knit.CreateService({
	Name = "StatsService",
	Client = {},
	Signals = {},
})

function StatsService:IncrementStat(user, stat, amount)
	--Increments stat for user
end

function StatsService:SetStat(user, stat, value)
	--Sets users stat to the given value
end

function StatsService:KnitStart() end

function StatsService:KnitInit() end

return StatsService
