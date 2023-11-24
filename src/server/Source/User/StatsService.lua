--[[
StatsService
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local StatData = require(ReplicatedStorage.Data.StatData)

local StatsService = knit.CreateService({
	Name = "StatsService",
	Client = {
		Stats = knit.CreateProperty({}),
	},
	Signals = {
		StatUpdated = signal.new(),
	},
})

function StatsService:GetStat(user, stat)
	--Returns the given stat for user
	user:WaitForDataLoaded()

	local data = StatData[stat]
	if not data then
		warn("could not find stat " .. stat)
		return
	end
	local default = data.Default or 0

	return user.Data.Stats[stat] or default
end

function StatsService:IncrementStat(user, stat, amount)
	--Increments stat for user
	user:WaitForDataLoaded()

	StatsService:SetStat(user, stat, StatsService:GetStat(user, stat) + amount)
end

function StatsService:SetStat(user, stat, value)
	--Sets users stat to the given value
	user:WaitForDataLoaded()

	local oldValue = user.Data.Stats[stat] or 0

	user.Data.Stats[stat] = value
	StatsService.Client.Stats:SetFor(user.Player, user.Data.Stats)
	StatsService.Signals.StatUpdated:Fire(user, stat, value - oldValue)
end

function StatsService:KnitStart()
	local UserService = knit.GetService("UserService")
	UserService.Signals.UserAdded:Connect(function(user)
		user:WaitForDataLoaded()

		StatsService.Client.Stats:SetFor(user.Player, user.Data.Stats)
	end)
end

function StatsService:KnitInit() end

return StatsService
