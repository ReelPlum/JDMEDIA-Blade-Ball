--[[
GameController
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local GameController = knit.CreateController({
	Name = "GameController",
	Signals = {},
})

function GameController:HitBall()
	local BallService = knit.GetService("BallService")
	local UIController = knit.GetController("UIController")
	local BallController = knit.GetController("BallController")

	local HitIndicator = UIController:GetUI("IndicatorList"):GetElement("Deflect")

	local character = LocalPlayer.Character
	if not character then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	local _, ballId = BallController:GetNearestBall(rootPart.CFrame.Position)

	BallService:HitBall(ballId, Camera.CFrame.LookVector, rootPart.CFrame.LookVector):andThen(function(success)
		if not success then
			return
		end
		HitIndicator:SetCooldown(GeneralSettings.Game.Cooldowns.Hit)
	end)
end

function GameController:UseAbility()
	local AbilityService = knit.GetService("AbilityService")
	local UIController = knit.GetController("UIController")

	local HitIndicator = UIController:GetUI("IndicatorList"):GetElement("Ability")

	local character = LocalPlayer.Character
	if not character then
		return
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	AbilityService:UseAbility(Camera.CFrame.LookVector, rootPart.CFrame.LookVector):andThen(function(success)
		if not success then
			return
		end
		--Get cooldown for current equipped ability

		HitIndicator:SetCooldown(GeneralSettings.Game.Cooldowns.Hit)
	end)
end

function GameController:KnitStart() end

function GameController:KnitInit() end

return GameController
