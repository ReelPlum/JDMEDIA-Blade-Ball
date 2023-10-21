--[[
Game
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local SocialService = game:GetService("SocialService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local Game = {}
Game.__index = Game

type GameSettings = {
	MaxPlayers: number,
}

function Game.new(map: Folder, location: CFrame, gameSettings: GameSettings)
	local self = setmetatable({}, Game)

	self.Janitor = janitor.new()

	self.Id = HttpService:GenerateGUID(false)

	self.Map = map
	self.Location = location
	self.Settings = gameSettings

	self.Users = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),

		ShowdownStarted = self.Janitor:Add(signal.new()),
		Ended = self.Janitor:Add(signal.new()),
		UserJoined = self.Janitor:Add(signal.new()),
		UserLeft = self.Janitor:Add(signal.new()),
	}

	local UserService = knit.GetService("UserService")
	UserService.Signals.UserRemoving:Connect(function(user)
		self:Leave(user)
	end)

	return self
end

function Game:ReturnUserToLobby(user)
	--Returns user to the lobby
	local GameService = knit.GetService("GameService")
	GameService:TeleportUserToLobby(user)
end

function Game:SpawnUserOnMap(user)
	--Spawns user on map
end

function Game:UserHit(user)
	--Called when ball hits user.
	--Teleport user back to spawn
	self:ReturnUserToLobby(user)

	--Make user leave game
	self:Leave(user)
end

function Game:GetUsers()
	return self.Users
end

function Game:Join(user)
	--Adds user to game
	if #self.Users + 1 > self.Settings.MaxPlayers then
		return
	end

	if table.find(self.Users, user) then
		return
	end

	if user.Game then
		warn("User already in game...")
		return
	end

	user.Game = self
	table.insert(self.Users, user)

	self.Signals.UserJoined:Fire()
end

function Game:Leave(user)
	--Removes user from game
	if not table.find(self.Users, user) then
		return
	end

	local CurrencyService = knit.GetService("CurrencyService")

	local rewards = {}
	if self.StartTime then
		--Reward user for kills
		for currency, data in GeneralSettings.Game.Rewards.Currency do
			rewards[currency] = 0

			if self.Ball.Hits[user] then
				rewards[currency] += self.Ball.Hits[user] * data.Hit
			end

			if self.Ball.Kills[user] then
				rewards[currency] += self.Ball.Kills[user] * data.Kill
			end

			rewards[currency] += (tick() - self.StartTime) * data.Second
		end
	end
	--Add reward to users cash
	for currency, reward in rewards do
		CurrencyService:GiveCurrency(user, currency, reward)
	end

	--If showdown then save showndown streak
	local StatsService = knit.GetService("StatsService")
	StatsService:IncrementStat(user, "Showdowns", 1)

	--Remove user
	user.Game = nil
	table.remove(self.Users, table.find(self.Users, user))

	self.Signals.UserLeft:Fire()

	local GameService = knit.GetService("GameService")
	--Update players in game property
	GameService.Client.PlayersInGame:SetFor(user.Player, nil)
	local users = {}
	for _, userInGame in self.Users do
		table.insert(users, userInGame.Player.UserId)
	end
	for _, userInGame in self.Users do
		GameService.Client.PlayersInGame:SetFor(userInGame.Player, users)
	end

	if #self.Users == 2 then
		self:Showdown()
		return
	end
	if #self.Users == 1 then
		self:End()
		return
	end
end

function Game:Start()
	self.StartTime = tick()

	local BallService = knit.GetService("BallService")
	self.Ball = BallService:CreateNewBall(CFrame.new(0, 10, 0), self)

	self.Janitor:Add(self.Ball.Signals.HitTarget:Connect(function(user)
		self:UserHit(user)
	end))

	for _, user in self.Users do
		self:SpawnUserOnMap(user)
	end
end

function Game:Showdown()
	--Starts showdown for game

	--Setup showdown stats

	--Count showdown ball hit streak
	self.Janitor:Add(self.Ball.Signals.Hit:Connect(function()
		--Save to streak
	end))
end

function Game:End()
	--Ends game
	local winner = self.Users[1]

	--Reward winner with extra reward
	local CurrencyService = knit.GetService("CurrencyService")

	for currency, data in GeneralSettings.Game.Rewards.Currency do
		CurrencyService:GiveCurrency(winner, currency, data.Win)
	end

	--Save win to winners stats
	local StatsService = knit.GetService("StatsService")
	StatsService:IncrementStat(winner, "Wins", 1)

	--Annouce winner
	local GameService = knit.GetService("GameService")
	GameService.Client.GameWon:FireAll(self.Id, winner.Player.UserId)

	--Remove everything from game
	local BallService = knit.GetService("BallService")
	BallService:DespawnBall()

	--Wait a little before destroying game fully. Give the winner a chance for a victory dance!
	task.wait(5)
	self:Leave(winner)
	self:Destroy()
end

function Game:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Game
