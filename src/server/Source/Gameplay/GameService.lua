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

local GameService = knit.CreateService({
	Name = "GameService",
	Client = {
		Time = knit.CreateProperty(0),
		Title = knit.CreateProperty(""),

		GameWon = knit.CreateSignal(),
	},
	Signals = {},
})

local currentGame = nil
local votedMap = nil

local MINUSERS = 2

local GameSections = {
	[0] = {
		Title = "Waiting for players...",
		CheckUsers = true,
	},
	{ --Cooldown
		Title = "Cooldown",
		Time = 1,
		CheckUsers = true,
	},
	{ --Voting
		Title = "Voting",
		Time = 1,
		CheckUsers = true,
		OnStart = function()
			--Start voting

			return
		end,
	},
	{ --Intermission
		Title = "Intermission",
		Time = 1,
		CheckUsers = true,
		OnEnd = function()
			local UserService = knit.GetService("UserService")

			--Start a game
			currentGame = Game.new(votedMap, CFrame.new(0, 0, 0), { MaxPlayers = Players.MaxPlayers })
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
}

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
		if section.OnStart and dontFireEvents then
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
			if currentSection == 0 then
				newSection(1)
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
