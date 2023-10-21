--[[
Vote
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Vote = {}
Vote.__index = Vote

function Vote.new(voteData)
	local self = setmetatable({}, Vote)

	self.Janitor = janitor.new()

	self.VoteData = voteData

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Vote:Start()
	--Starts the vote making it possible for users for cast votes
end

function Vote:CastVote(user, choice)
	--Stores users casted vote
	--If user already voted then change their vote.
end

function Vote:RemoveVote(user)
	--Removes user's vote
end

function Vote:Serialize()
	--Serializes vote
end

function Vote:GetWinner()
	--Gets current winner for vote
end

function Vote:End(): number
	--Ends vote and returns winner
end

function Vote:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Vote
