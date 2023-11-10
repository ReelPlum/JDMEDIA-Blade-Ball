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
local MapData = require(ReplicatedStorage.Data.MapData)

local Gamemodes = {}
for _, gamemode in script.Parent.Gamemodes:GetChildren() do
	if not gamemode:IsA("ModuleScript") then
		continue
	end

	table.insert(Gamemodes, require(gamemode))
end

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

	self:CreateMap()

	return self
end

function Game:ReturnUserToLobby(user)
	--Returns user to the lobby
	local GameService = knit.GetService("GameService")
	GameService:TeleportUserToLobby(user)
end

function Game:SpawnUserOnMap(user, n)
	--Spawns user on map
	local _, size = self.CurrentMap:GetBoundingBox()

	local r = math.min(size.X, size.Z) / 2

	local deg = 360 / #self.Users

	local character = user.Character
	if not character then
		return
	end

	local pos = (CFrame.new(self.CurrentMap.PrimaryPart.Position) * CFrame.Angles(0, math.rad(deg * n), 0) * CFrame.new(
		0,
		0,
		-r / 2
	)).Position
	--Create ray

	character.HumanoidRootPart.CFrame = CFrame.new(
		pos
			+ Vector3.new(self.CurrentMap.PrimaryPart.Size.Y / 2, 0)
			+ Vector3.new(0, character.HumanoidRootPart.Size.Y / 2, 0)
			+ Vector3.new(0, character.Humanoid.HipHeight, 0)
	)
end

function Game:UserHit(user)
	--Called when ball hits user.
	--Teleport user back to spawn
	self:ReturnUserToLobby(user)

	--Make user leave game
	local isFinished = self:Leave(user)
	if isFinished then
		return
	end

	self.Ball:Respawn()
end

function Game:CreateMap()
	--Creates the map for the game.
	local data = MapData[self.Map]
	if not data then
		warn("Could not find map " .. self.Map)
		return
	end

	if not data.Model:FindFirstChild("BallSpawn") then
		warn("Ball Spawn was not found for map " .. self.Map)
		return
	end

	if not data.Model.PrimaryPart then
		warn("No primarypart was found for map " .. self.Map .. " this may bring problems in the future...")
	end

	--Create map and position it.
	self.CurrentMap = self.Janitor:Add(data.Model:Clone())
	--self.CurrentMap:PivotTo(self.Location)
	self.CurrentMap.Parent = workspace
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

	local GameService = knit.GetService("GameService")
	GameService.Client.InGame:SetFor(user.Player, self.Id)

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
	GameService.Client.InGame:SetFor(user.Player, nil)

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
		return true
	end
end

function Game:Start()
	self.StartTime = tick()

	--Choose random gamemode
	local chosenGamemode = Gamemodes[math.random(1, #Gamemodes)]

	--Tell clients what gamemode was chosen
	local GameService = knit.GetService("GameService")
	GameService.Client.CurrentGamemode:Set(chosenGamemode.Name)

	chosenGamemode.Run(self)

	for n, user in self.Users do
		self:SpawnUserOnMap(user, n)
	end
end

function Game:Showdown()
	--Starts showdown for game

	if GeneralSettings.SystemMessages.OnShowdown then
		local ChatService = knit.GetService("ChatService")
		ChatService:SendSystemMessage(
			`{self.Users[1].Player.DisplayName} & {self.Users[2].Player.DisplayName} have entered showdown!`,
			Color3.fromRGB(255, 145, 19)
		)
	end

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
	BallService:DespawnBall(self.Ball.Id)

	if GeneralSettings.SystemMessages.OnGameWin then
		local ChatService = knit.GetService("ChatService")
		ChatService:SendSystemMessage(`{winner.Player.DisplayName} won the game!`, Color3.fromRGB(0, 255, 0))
	end

	--Wait a little before destroying game fully. Give the winner a chance for a victory dance!
	task.wait(5)
	self:ReturnUserToLobby(winner)
	self:Leave(winner)
	self:Destroy()
end

function Game:Destroy()
	local GameService = knit.GetService("GameService")
	GameService.Client.CurrentGamemode:Set(nil)

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Game
