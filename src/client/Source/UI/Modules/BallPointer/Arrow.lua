--[[
Arrow
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local BorderSize = Vector2.new(40 * 2, 40 * 2)

local Arrow = {}
Arrow.ClassName = "Arrow"
Arrow.__index = Arrow

function Arrow.new(BallPointer, ball)
	local self = setmetatable({}, Arrow)

	self.Janitor = janitor.new()

	self.UI = nil
	self.BallPointer = BallPointer
	self.Ball = ball

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

local function GetRotation(position)
	local relToCamera = Camera.CFrame:VectorToObjectSpace(position - Camera.CFrame.Position)

	return Vector2.new(relToCamera.X, relToCamera.Y).Unit
end

local function GetPosition(position)
	local bufferScreen = Camera.ViewportSize - BorderSize
	local longestDist = math.sqrt((bufferScreen.X / 2) ^ 2 + (bufferScreen.Y / 2) ^ 2)

	local dir = GetRotation(position)
	local testDir = dir * longestDist

	local screenPoint
	if math.abs(testDir.Y) > bufferScreen.Y / 2 then
		screenPoint = dir * math.abs(bufferScreen.Y / 2 / dir.Y)
	else
		screenPoint = dir * math.abs(bufferScreen.X / 2 / dir.X)
	end

	local ViewportPosition = Camera.ViewportSize / 2 + Vector2.new(screenPoint.X, -screenPoint.Y)

	return ViewportPosition
end

function Arrow:Init()
	self.UI = self.Janitor:Add(self.BallPointer.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local BallController = knit.GetController("BallController")

	self.Janitor:Add(BallController.Signals.LocalPlayerTargeted:Connect(function(ball)
		if not ball == self.Ball then
			return
		end
		self.UI.Arrow.ImageColor3 = Color3.fromRGB(0, 255, 0)
	end))

	self.Janitor:Add(BallController.Signals.BallChangedTarget:Connect(function(ball)
		if not ball == self.Ball then
			return
		end
		self.UI.Arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end))

	self.Janitor:Add(RunService.RenderStepped:Connect(function()
		local character = LocalPlayer.Character
		if not character then
			self.UI.Enabled = false
			return
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			self.UI.Enabled = false
			return
		end

		if not self.Ball then
			self.UI.Enabled = false
			return
		end
		if not self.Ball:IsDescendantOf(workspace) then
			self.UI.Enabled = false
			return
		end

		local position, _ = Camera:WorldToViewportPoint(self.Ball.CFrame.Position)
		if
			math.clamp(position.X, BorderSize.X / 2, Camera.ViewportSize.X - BorderSize.X / 2) ~= position.X
			or math.clamp(position.Y, BorderSize.Y / 2, Camera.ViewportSize.Y - BorderSize.Y / 2) ~= position.Y
		then
			--Position pointer and make it point in the right direction
			local dir = GetRotation(self.Ball.CFrame.Position)
			local angle = math.atan2(dir.X, dir.Y)
			local position = GetPosition(self.Ball.CFrame.Position)

			--POsition UI
			self.UI.Arrow.Position = UDim2.new(0, position.X, 0, position.Y)
			self.UI.Arrow.Rotation = math.deg(angle)

			self.UI.Enabled = true

			return
		end

		self.UI.Enabled = false
	end))
end

function Arrow:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Arrow
