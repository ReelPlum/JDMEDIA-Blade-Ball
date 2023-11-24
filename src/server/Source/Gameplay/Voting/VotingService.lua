--[[
VotingService
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Vote = require(script.Parent.Vote)

local VotingService = knit.CreateService({
	Name = "VotingService",
	Client = {
		VoteStarted = knit.CreateSignal(),
		VotesChanged = knit.CreateSignal(),
		VoteEnded = knit.CreateSignal(),
	},
	Signals = {},
})

type VoteData = {
	Choices: {
		[string | number]: {
			Image: string,
			DisplayName: string,
		},
	},
}

function VotingService:StartVote(voteData: VoteData)
	--Start a vote
	local vote = Vote.new(voteData)
	vote:Start()

	return vote
end

function VotingService:KnitStart() end

function VotingService:KnitInit() end

return VotingService
