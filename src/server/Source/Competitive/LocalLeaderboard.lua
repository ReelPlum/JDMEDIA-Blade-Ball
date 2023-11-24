--[[
LocalLeaderboard
2023, 11, 12
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local LeaderboardsData = require(ReplicatedStorage.Data.LeaderboardsData)

local LocalLeaderboard = {}
LocalLeaderboard.ClassName = "LocalLeaderboard"
LocalLeaderboard.__index = LocalLeaderboard

function LocalLeaderboard.new(leaderboard)
	local self = setmetatable({}, LocalLeaderboard)

	self.Janitor = janitor.new()

	self.Leaderboard = leaderboard

	self.Data = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),

		Updated = self.Janitor:Add(signal.new()),
	}

	local UserService = knit.GetService("UserService")
	self.Janitor:Add(UserService.Signals.UserAdded:Connect(function(user)
		self:UpdateUser(user)
	end))

	self.Janitor:Add(UserService.Signals.UserRemoving:Connect(function(user)
		self.Data[user.Player.UserId] = nil
	end))

	return self
end

function LocalLeaderboard:UpdateUser(user)
	local data = LeaderboardsData[self.Leaderboard]
	if not data then
		return
	end

	local StatsService = knit.GetService("StatsService")

	self.Data[user.Player.UserId] = StatsService:GetStat(user, data.Stat)

	self.Signals.Updated:Fire()
end

function LocalLeaderboard:GetTop()
	local t = {}
	for userId, value in self.Data do
		table.insert(t, {
			key = userId,
			value = value,
		})
	end

	table.sort(t, function(a, b)
		return a.value < b.value
	end)

	return t
end

function LocalLeaderboard:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return LocalLeaderboard
