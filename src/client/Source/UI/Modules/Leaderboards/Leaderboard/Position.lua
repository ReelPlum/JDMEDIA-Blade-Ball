--[[
Position
24, 11, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local UserService = game:GetService("UserService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Position = {}
Position.ClassName = "Position"
Position.__index = Position

function Position.new(leaderboardClass, index)
	local self = setmetatable({}, Position)

	self.Janitor = janitor.new()

	self.Leaderboard = leaderboardClass
	self.Index = index

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Position:Init()
	--Create UI
	self.UI = self.Janitor:Add(ReplicatedStorage.Assets.UI.LeaderboardPosition:Clone())
	self.UI.Parent = self.Leaderboard.UI.ScrollingFrame
	self.UI.LayoutOrder = self.Index

	self:SetDefault()
end

function Position:SetDefault()
	--Set position to default
	self.UI.Rank.Text = "#" .. self.Index
end

function Position:Update(userId, value)
	--Update with new data
	task.spawn(function()
		local success, result = pcall(function()
			return UserService:GetUserInfosByUserIdsAsync({ tonumber(userId) })
		end)

		if not success then
			print("❗Failed getting user info for leaderboard... " .. result)
			self:SetDefault()
			return
		end

		if not result.Username then
			result.Username = userId
		end
		if not result.DisplayName then
			result.DisplayName = result.Username
		end

		local name = result.DisplayName or result.Username
		if result.HasVerifiedBadge then
			name = utf8.char(0xE000) .. "" .. name
		end

		self.UI.UserName.Text = "@" .. result.Username
		self.UI.DisplayName.Text = name
		self.UI.Rank.Text = "#" .. self.Index
		self.UI.Value.Text = value

		if self.Index == 1 then
			self.UI.DisplayName.Text = name .. " 🥇"
		elseif self.Index == 2 then
			self.UI.DisplayName.Text = name .. " 🥈"
		elseif self.Index == 3 then
			self.UI.DisplayName.Text = name .. " 🥉"
		elseif self.Index >= 10 then
			self.UI.DisplayName.Text = name .. " 🎖️"
		end

		self.UI.PlayerImage.Image =
			Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
	end)
end

function Position:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Position
