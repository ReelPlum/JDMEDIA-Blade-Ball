--[[
ClientPhysicsService
2023, 11, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ClientPhysicsService = knit.CreateService({
	Name = "ClientPhysicsService",
	Client = {
		ApplyImpulseOnCharacter = knit.CreateSignal(),
	},
	Signals = {},
})

function ClientPhysicsService:ApplyImpulseOnCharacter(user, impulse)
	ClientPhysicsService.Client.ApplyImpulseOnCharacter:Fire(user.Player, impulse)
end

function ClientPhysicsService:KnitStart() end

function ClientPhysicsService:KnitInit() end

return ClientPhysicsService
