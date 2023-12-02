--[[
Leaderboards
24, 11, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local LeaderboardClass = require(script.Leaderboard)

local LeaderboardsData = require(ReplicatedStorage.Data.LeaderboardsData)

local Leaderboards = {}
Leaderboards.ClassName = "Leaderboards"
Leaderboards.__index = Leaderboards

function Leaderboards.new()
	local self = setmetatable({}, Leaderboards)

	self.Janitor = janitor.new()

	self.Leaderboards = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Leaderboards:Init()
	--Listen for leaderboard creations / destructions
	for leaderboard, data in LeaderboardsData do
		self.Janitor:Add(CollectionService:GetInstanceAddedSignal(data.Tag):Connect(function(instance)
			self:CreateLeaderboard(instance, leaderboard)
		end))

		self.Janitor:Add(CollectionService:GetInstanceRemovedSignal(data.Tag):Connect(function(instance)
			self:DeleteLeaderboardOnInstance(instance)
		end))

		for _, instance in CollectionService:GetTagged(data.Tag) do
			self:CreateLeaderboard(instance, leaderboard)
		end
	end
end

function Leaderboards:DeleteLeaderboardOnInstance(instance)
	local leaderboard = self.Leaderboards[instance]
	if not leaderboard then
		return
	end

	leaderboard:Destroy()
	self.Leaderboards[instance] = nil
end

function Leaderboards:CreateLeaderboard(instance, leaderboard)
	--Create leaderboard on instance.
	if self.Leaderboards[instance] then
		warn("The instance " .. instance:GetFullName() .. " already had a leaderboard connected!")
		return
	end

	self.Leaderboards[instance] = LeaderboardClass.new(instance, leaderboard)
end

function Leaderboards:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Leaderboards
