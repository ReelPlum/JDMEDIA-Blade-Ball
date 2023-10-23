--[[
AnimationService
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local AnimationService = knit.CreateService({
	Name = "AnimationService",
	Client = {},
	Signals = {},
})

function AnimationService:KnitStart() end

function AnimationService:KnitInit() end

return AnimationService
