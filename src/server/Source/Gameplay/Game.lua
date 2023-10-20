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

	table.insert(self.Users, user)

	self.Signals.UserJoined:Fire()
end

function Game:Leave(user)
	--Removes user from game
	if not table.find(self.Users, user) then
		return
	end

	local reward = 0
	if self.StartTime then
		--Reward user for kills
		if self.Ball.Hits[user] then
			reward += self.Ball.Hits[user] * 0.25
		end

		if self.Ball.Kills[user] then
			reward += self.Ball.Kills[user] * 25
		end

		--Reward user for survival time & ball hits
		reward += tick() - self.StartTime * 0.05
	end
	--Add reward to users cash
	--Give user experience reward

	--If showdown then save showndown streak

	--Remove user
	table.remove(self.Users, table.find(self.Users, user))
	self.Signals.UserLeft:Fire()

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
end

function Game:Showdown()
	--Starts showdown for game

	--Setup showdown stats

	--Count showdown streak
	self.Janitor:Add(self.Ball.Signals.Hit:Connect(function()
		--Save to streak
	end))
end

function Game:End()
	--Ends game
	local winner = self.Users[1]

	--Reward winner with extra reward

	--Save win to winners stats

	--Remove everything from game
	local BallService = knit.GetService("BallService")
	BallService:DespawnBall()

	self:Leave(winner)
	self:Destroy()
end

function Game:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Game
