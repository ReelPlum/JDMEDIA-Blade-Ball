--[[
Vote
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
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
	self.Id = HttpService:GenerateGUID(false)

	self.Votes = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),

		VoteCasted = self.Janitor:Add(signal.new()),
		VoteRemoved = self.Janitor:Add(signal.new()),
	}

	return self
end

function Vote:Start()
	--Starts the vote making it possible for users for cast votes
	local VotingService = knit.GetService("VotingService")

	VotingService.Client.VoteStarted:FireAll(self.Id, self.VoteData)
end

function Vote:CastVote(user, choice)
	--Stores users casted vote
	--If user already voted then change their vote.
	if not self.VoteData.Choices[choice] then
		return
	end

	self.Votes[user] = choice
	self.Signals.VoteCasted:Fire(user, choice)

	local VotingService = knit.GetService("VotingService")
	VotingService.Client.VotesChanged:FireAll(self.Id, self:SerializeVotes())
end

function Vote:RemoveVote(user)
	--Removes user's vote
	self.Votes[user] = nil

	self.Signals.VoteRemoved:Fire(user)

	local VotingService = knit.GetService("VotingService")
	VotingService.Client.VotesChanged:FireAll(self.Id, self:SerializeVotes())
end

function Vote:SerializeVotes()
	--Serializes vote
	local votes = {}

	for user, choice in self.Votes do
		votes[user.Player.UserId] = choice
	end

	return votes
end

function Vote:GetWinner()
	--Gets current winner for vote
	local choices = {}
	for choice, _ in self.VoteData do
		choices[choice] = 0
	end

	for _, choice in self.Votes do
		choices[choice] += 1
	end

	local mostVotes, mostVoted = -10, nil
	for choice, votes in choices do
		if votes > mostVotes then
			mostVoted = choice
			mostVotes = votes
		end
	end

	return mostVoted
end

function Vote:End(): number
	--Ends vote and returns winner
	local VotingService = knit.GetService("VotingService")

	VotingService.Client.VoteEnded:FireAll(self.Id)
end

function Vote:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Vote
