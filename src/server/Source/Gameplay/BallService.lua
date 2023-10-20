--[[
BallService
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local BallClass = require(script.Parent.Ball)

local BallService = knit.CreateService({
	Name = "BallService",
	Client = {},
	Signals = {},
})

local CurrentBall = nil

function BallService:CreateNewBall(location: CFrame, currentGame)
	--Creates new ball at the given location.
	--It also destroys the old ball
	CurrentBall = BallClass.new(location, ReplicatedStorage.Ball, currentGame)
	CurrentBall:Respawn()
end

function BallService:HitBall(user, cameraLookVector)
	--Hits ball. Based on camera & character lookVector
end

function BallService:DespawnBall()
	--Despawns current bladeball
end

function BallService:KnitStart()
	--Loop updating ball
	RunService.Heartbeat:Connect(function(deltaTime)
		if not CurrentBall then
			return
		end

		CurrentBall:Update(deltaTime)
	end)
end

function BallService:KnitInit() end

return BallService
