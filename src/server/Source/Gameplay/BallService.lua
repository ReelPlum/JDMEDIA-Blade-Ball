--[[
BallService
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local BallService = knit.CreateService({
	Name = "BallService",
	Client = {},
	Signals = {},
})

local CurrentBall = nil

function BallService:CreateNewBall(location: CFrame)
	--Creates new ball at the given location.
	--It also destroys the old ball
end

function BallService:HitBall(user, cameraLookVector)
	--Hits ball. Based on camera & character lookVector
end

function BallService:DespawnBall()
	--Despawns current bladeball
end

function BallService:KnitStart()
	--Loop updating ball
end

function BallService:KnitInit() end

return BallService
