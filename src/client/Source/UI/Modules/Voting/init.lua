--[[
init
2023, 12, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Voting = {}
Voting.ClassName = "Voting"
Voting.__index = Voting

function Voting.new()
	local self = setmetatable({}, Voting)

	self.Janitor = janitor.new()

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Voting:Init()
	--Create UI

	--Buttons
end

function Voting:SetupVotes(votes)
	--Create the votes
end

function Voting:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Voting
