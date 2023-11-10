--[[
ClientPhysicsController
2023, 11, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ClientPhysicsController = knit.CreateController({
	Name = "ClientPhysicsController",
	Signals = {},
})

function ClientPhysicsController:ApplyImpulseOnCharacter(impulse)
	local character = LocalPlayer.Character
	if not character then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	rootPart:ApplyImpulse(impulse)
end

function ClientPhysicsController:KnitStart()
	local ClientPhysicsService = knit.GetService("ClientPhysicsService")
	ClientPhysicsService.ApplyImpulseOnCharacter:Connect(function(impulse)
		ClientPhysicsController:ApplyImpulseOnCharacter(impulse)
	end)
end

function ClientPhysicsController:KnitInit() end

return ClientPhysicsController
