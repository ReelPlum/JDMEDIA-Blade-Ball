--[[
SoftShutdownService
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local SoftShutdownService = knit.CreateService({
	Name = "SoftShutdownService",
	Client = {},
	Signals = {},
})

function SoftShutdownService:KnitStart() end

function SoftShutdownService:KnitInit() end

return SoftShutdownService
