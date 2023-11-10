--[[
ParticleService
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ParticleService = knit.CreateService({
	Name = "ParticleService",
	Client = {},
	Signals = {},
})

function ParticleService:SpawnParticleAt(CF, emitter, emitAmount)
	--Emit particle at location
end

function ParticleService:SpawnParticleAtNormal(CF, emitter, emitAmount)
	--Spawns particle and automatically gets normal.
end

function ParticleService:KnitStart() end

function ParticleService:KnitInit() end

return ParticleService
