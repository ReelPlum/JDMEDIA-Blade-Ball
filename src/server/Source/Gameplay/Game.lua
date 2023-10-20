--[[
Game
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

	self.Map = map
	self.Location = location
	self.Settings = gameSettings

	self.Users = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),

		ShowdownStarted = self.Janitor:Add(signal.new()),
		Ended = self.Janitor:Add(signal.new()),
	}

	return self
end

function Game:UserHit(user)
	--Called when ball hits user
end

function Game:GetRandomUser()
	--Returns random user in game
end

function Game:Join(user)
	--Adds user to game
end

function Game:JoinMultiple(users)
	--Makes multiple users join
end

function Game:Leave(user)
	--Removes user from game
end

function Game:LeaveMultiple(users)
	--Makes multiple users leave
end

function Game:Start()
	task.wait(5)

	local UserService = knit.GetService("UserService")
	local users = UserService:GetUsers()
	local usersList = {}
	for _, user in users do
		table.insert(usersList, user)
	end
	self.Users = usersList

	local BallService = knit.GetService("BallService")
	BallService:CreateNewBall(CFrame.new(0, 10, 0), self)

	--Starts game with players

	--Check for when showdown starts

	--Check when all players but one is left
end

function Game:Freeze()
	--Freezes game and all players playing
end

function Game:End()
	--Ends game
end

function Game:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Game
