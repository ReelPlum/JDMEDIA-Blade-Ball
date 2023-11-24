--[[
GameStreakService
2023, 11, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GameStreakService = knit.CreateService({
	Name = "GameStreakService",
	Client = {
		Streaks = knit.CreateProperty({}),
	},
	Signals = {},
})

local streaks = {}

function GameStreakService:SetStreak(user, streak, value)
	--Set streak to value
	if not streaks[user] then
		streaks[user] = {}
	end

	streaks[user][streak] = value

	GameStreakService.Client.Streaks:SetFor(user.Player, streaks[user])
end

function GameStreakService:ResetStreaks(user)
	--Reset all streaks for user
	streaks[user] = {}

	GameStreakService.Client.Streaks:SetFor(user.Player, streaks[user])
end

function GameStreakService:KnitStart() end

function GameStreakService:KnitInit() end

return GameStreakService
