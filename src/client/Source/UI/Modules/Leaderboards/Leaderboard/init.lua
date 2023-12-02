--[[
Leaderboard
24, 11, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local PositionClass = require(script.Position)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)
local LeaderboardsData = require(ReplicatedStorage.Data.LeaderboardsData)

local Leaderboard = {}
Leaderboard.ClassName = "Leaderboard"
Leaderboard.__index = Leaderboard

function Leaderboard.new(instance, leaderboard)
	local self = setmetatable({}, Leaderboard)

	self.Janitor = janitor.new()

	self.Instance = instance
	self.Leaderboard = leaderboard
	self.Data = LeaderboardsData[self.Leaderboard]

	self.Positions = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Leaderboard:Init()
	--Base UI
	self.UI = self.Janitor:Add(ReplicatedStorage.Assets.UI.Leaderboard:Clone())
	self.UI.Parent = self.Instance

	--Create positions
	for i = 1, 50 do
		task.spawn(function()
			self.Positions[i] = self.Janitor:Add(PositionClass.new(self, i))
		end)
	end

	self.UI.Title.Text = self.Data.Header

	--Listen for updates
	local CacheController = knit.GetController("CacheController")
	self.Janitor:Add(CacheController.Signals.LeaderboardsChanged:Connect(function()
		self:Update()
	end))
	self:Update()
end

function Leaderboard:Update()
	--Updates leaderboard with up to date data
	local CacheController = knit.GetController("CacheController")

	local data = CacheController.Cache.Leaderboards
	if not data then
		data = {}
	end
	local currentLeaderboardData = data[self.Leaderboard]
	if not currentLeaderboardData then
		currentLeaderboardData = {}
	end

	for i, position in self.Positions do
		if not currentLeaderboardData[i] then
			position:SetDefault()
			continue
		end

		position:Update(currentLeaderboardData[i].Key, currentLeaderboardData[i].Value)
	end

	local size = self.UI.ScrollingFrame.UIListLayout.AbsoluteContentSize
	self.UI.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, size.Y)
end

function Leaderboard:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Leaderboard
