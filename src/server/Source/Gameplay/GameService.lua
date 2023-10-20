--[[
GameService
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Game = require(script.Parent.Game)

local GameService = knit.CreateService({
	Name = "GameService",
	Client = {},
	Signals = {},
})

local CooldownTime = 10
local VotingTime = 30
local IntermissionTime = 30

function GameService:KnitStart()
	--Start game loop here
	task.spawn(function()
		while true do
			--Cooldown
			task.wait(CooldownTime)

			--Vote
			task.wait(VotingTime)
			local ChosenMap = nil
			--Intermission
			task.wait(IntermissionTime)

			--Start game
			local currentGame = Game.new(ChosenMap, CFrame.new(), { MaxPlayers = Players.MaxPlayers })
			currentGame:Start()

			currentGame.Signals.Ended:Wait()

			--And so it continues
		end
	end)
end

function GameService:KnitInit() end

return GameService
