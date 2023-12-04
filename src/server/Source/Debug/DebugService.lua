--[[
DebugService
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local DebugService = knit.CreateService({
	Name = "DebugService",
	Client = {},
	Signals = {},
})

function DebugService:PrintDebug(text)
	if not RunService:IsStudio() then
		return
	end

	print(text)
end

function DebugService:WarnDebug(text)
	if not RunService:IsStudio() then
		return
	end

	warn(text)
end

function DebugService:KnitStart() end

function DebugService:KnitInit() end

return DebugService
