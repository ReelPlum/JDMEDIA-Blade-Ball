--[[
GameService
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Game = require(script.Parent.Game)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local GameService = knit.CreateService({
	Name = "GameService",
	Client = {
		Time = knit.CreateProperty(0),
		Title = knit.CreateProperty(""),
		PlayersInGame = knit.CreateProperty(nil),
		InGame = knit.CreateProperty(nil),

		GameWon = knit.CreateSignal(),
	},
	Signals = {},
})

local currentGame = nil
local votedMap = nil
local nextMap = nil

local currentVote = nil

local MINUSERS = GeneralSettings.Game.MinimumPlayers

local GameSections = {
	[0] = {
		Title = "Waiting for players...",
		CheckUsers = true,
		OnStart = function()
			if currentVote then
				currentVote:End()
				currentVote:Destroy()
				currentVote = nil
			end
		end,
	},
	{ --Cooldown
		Title = "Cooldown",
		Time = GeneralSettings.Game.GameTimes.CoolDown,
		CheckUsers = true,
		OnStart = function()
			currentGame = nil
			votedMap = nil
		end,
	},
	{ --Voting
		Title = "Voting",
		Time = GeneralSettings.Game.GameTimes.Voting,
		CheckUsers = true,
		OnStart = function()
			--Start voting
			if nextMap then
				--A map has already been set
				votedMap = nextMap

				return
			end

			--Start vote
			local VotingService = knit.GetService("VotingService")
			currentVote = VotingService:StartVote({ --Get all maps and an image of them here
				[1] = 1,
			})

			return
		end,
	},
	{ --Intermission
		Title = "Intermission",
		Time = GeneralSettings.Game.GameTimes.Intermission,
		CheckUsers = true,
		OnStart = function()
			if currentVote then
				votedMap = currentVote:End()

				currentVote:Destroy()
				currentVote = nil
			end

			--Announce next map to clients

			--Create game
			--currentGame = Game.new(votedMap, CFrame.new(0, 0, 0), { MaxPlayers = Players.MaxPlayers })

			currentGame = Game.new("TestMap", CFrame.new(0, 0, 0), { MaxPlayers = Players.MaxPlayers })
		end,
		OnEnd = function()
			local UserService = knit.GetService("UserService")

			--Start a game
			for _, user in UserService:GetUsers() do
				if user.AFK then
					continue
				end

				currentGame:Join(user)
			end
			currentGame:Start()

			return
		end,
	},
	{ --InGame
		Title = "In Game",
		CheckUsers = false,
		Check = function()
			--Check when last stand begins
			return #currentGame:GetUsers() <= 2
		end,
	},
	{ --Last stand
		Title = "Last stand",
		CheckUsers = false,
		Check = function()
			--Check when winner is found
			return #currentGame:GetUsers() < 2
		end,
	},
	{ --Last stand
		Title = "Victory",
		CheckUsers = false,
		Check = function()
			--Check when winner is found
			return #currentGame:GetUsers() < 1
		end,
	},
}

function GameService:TeleportUserToLobby(user)
	--Teleports user back to the lobby
end

function GameService:SpawnUserOnMap(user)
	--Spawns user on map
end

function GameService:SetNextMap(map)
	--Sets next map to the given map
end

function GameService:KnitStart()
	local UserService = knit.GetService("UserService")

	local lastUpdate = 0
	local currentTime = 0
	local currentSection = 1

	local function newSection(index, dontFireEvents)
		currentTime = 0
		if not GameSections[index] then
			index = 1
		end

		local lastSection = GameSections[currentSection]
		if lastSection.OnEnd and not dontFireEvents then
			lastSection.OnEnd()
		end

		currentSection = index
		local section = GameSections[index]

		GameService.Client.Title:Set(section.Title)
		if section.OnStart then
			section.OnStart()
		end
	end

	local function checkForUsers()
		--Checks if enough users
		local foundUsers = {}
		for _, user in UserService:GetUsers() do
			--Check AFK
			if user.AFK then
				continue
			end

			table.insert(foundUsers, user)
		end

		return #foundUsers >= MINUSERS
	end

	newSection(1)
	RunService.Heartbeat:Connect(function(deltaTime)
		local section = GameSections[currentSection]
		currentTime += deltaTime

		--Update time for clients
		if tick() - lastUpdate >= 1 then
			--Update
			lastUpdate = tick()
			GameService.Client.Time:Set(math.floor(currentTime))

			print(math.floor(currentTime))
			print(section.Title)
		end

		--Check if enough users
		if section.CheckUsers then
			if not checkForUsers() and not (currentSection == 0) then
				--Wait for users
				newSection(0, true)
				return
			end
			if currentSection == 0 and checkForUsers() then
				newSection(1)
				return
			end
		end

		--Check if section is finished
		if not section.Time then
			--Section does not have a time.
			if section.Check then
				if section.Check() then
					newSection(currentSection + 1)
				end
			end
			return
		end

		if currentTime > section.Time then
			newSection(currentSection + 1)
		end
	end)
end

function GameService:KnitInit() end

return GameService
