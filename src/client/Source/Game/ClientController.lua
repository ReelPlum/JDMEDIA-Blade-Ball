--[[
ClientController
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ClientController = knit.CreateController({
	Name = "ClientController",
	Signals = {},
})

function ClientController:KnitStart()
	--Start controls

	--Just simple testing
	local BallService = knit.GetService("BallService")

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			--Hit
			local character = LocalPlayer.Character
			if not character then
				return
			end
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then
				return
			end

			BallService:HitBall(Camera.CFrame.LookVector, rootPart.CFrame.LookVector)
		end
	end)
end

function ClientController:KnitInit() end

return ClientController
