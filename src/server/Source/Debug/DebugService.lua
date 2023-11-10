--[[
DebugService
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local DebugService = knit.CreateService({
	Name = "DebugService",
	Client = {},
	Signals = {},
})

function DebugService:KnitStart() end

function DebugService:KnitInit() end

return DebugService
