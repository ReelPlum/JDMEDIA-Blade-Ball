--[[
GameController
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local GameController = knit.CreateController({
	Name = "GameController",
	Signals = {
		GameChanged = signal.new(),
	},
	InGame = nil,
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

	AbilityService:UseAbility(Camera.CFrame.LookVector, rootPart.CFrame.LookVector):andThen(function(abilityData)
		if not abilityData then
			return
		end
		--Get cooldown for current equipped ability

		HitIndicator:SetCooldown(abilityData.CooldownTime)
	end)
end

function GameController:KnitStart()
	local GameService = knit.GetService("GameService")

	GameService.InGame:Observe(function(id)
		GameController.InGame = id
		GameController.Signals.GameChanged:Fire(id)
	end)

	local ToShow = {
		"waiting for players...",
		"intermission",
		"voting",
	}

	local StatePart = workspace:WaitForChild("GameState"):WaitForChild("State")
	local currentTitle = nil

	GameService.Time:Connect(function(Time)
		--Update time
		local times = GeneralSettings.Game.GameTimes
		local s = Time

		if times[currentTitle] then
			s = math.max(times[currentTitle] - Time, 0)
		end

		local m = (s - s % 60) / 60
		s = s - m * 60

		s = math.floor(s)
		m = math.floor(m)

		while #tostring(s) < 2 do
			s = "0" .. s
		end

		while #tostring(m) < 2 do
			m = "0" .. m
		end

		StatePart.SurfaceGui.Time.Text = m .. ":" .. s
	end)

	GameService.Title:Observe(function(text)
		--Update text
		-- if not table.find(ToShow, string.lower(text)) then
		-- 	print(text)
		-- 	StatePart.Parent = ReplicatedStorage
		-- 	return
		-- end

		-- StatePart.Parent = workspace.GameState

		currentTitle = text
		StatePart.SurfaceGui.Title.Text = text
	end)
end

function GameController:KnitInit() end

return GameController
