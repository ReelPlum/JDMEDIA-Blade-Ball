--[[
init
2023, 11, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local RParticle = require(ReplicatedStorage.Common.RParticle)

local ExperienceLevelsData = require(ReplicatedStorage.Data.ExperienceLevels)

local Level = {}
Level.ClassName = "Level"
Level.__index = Level

function Level.new(UITemplate)
	local self = setmetatable({}, Level)

	self.Janitor = janitor.new()

	self.UITemplate = UITemplate

	self.ShownExperience = 0
	self.ShownLevel = 0
	self.LastEmit = 0

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Level:Init()
	--Initialize the UI
	self.UI = self.Janitor:Add(self.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local ParticleUI = self.Janitor:Add(Instance.new("Frame"))
	ParticleUI.AnchorPoint = Vector2.new(0.5, 0.5)
	local aspectRatio = self.Janitor:Add(Instance.new("UIAspectRatioConstraint"))
	aspectRatio.AspectRatio = 1
	aspectRatio.DominantAxis = Enum.DominantAxis.Height
	aspectRatio.Parent = ParticleUI
	local UICorner = self.Janitor:Add(Instance.new("UICorner"))
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = ParticleUI

	self.Particle = self.Janitor:Add(RParticle.new(self.UI, ParticleUI))
	self.Particle.rate = 0

	self.Particle.onSpawn = function(particle)
		particle.velocity = Vector2.new(math.random(250, 350), math.random(-100, 100))
		local size = self.UI.Frame.AbsoluteSize.Y * math.random(8, 10) / 10
		particle.element.Size = UDim2.new(0, size, 0, size)
		particle.maxAge = math.random(3, 10) / 10
		particle.position = self.UI.Frame.AbsolutePosition
			+ Vector2.new(self.UI.Frame.Bar.AbsoluteSize.X, self.UI.Frame.Bar.AbsoluteSize.Y / 2)

		--Choose color here
		particle.element.BackgroundColor3 = Color3.fromRGB(255, 237, 39)
	end

	self.Particle.onUpdate = function(particle, dt)
		particle.velocity = particle.velocity / (1 + dt) - (Vector2.new(0, math.random(150, 350)) * dt)
		particle.position = particle.position + (particle.velocity * dt)

		particle.element.BackgroundTransparency = particle.age / particle.maxAge
		particle.element.BackgroundColor3 = Color3.fromRGB(255, 237, 39)
			:Lerp(Color3.fromRGB(255, 128, 0), particle.age / particle.maxAge)
	end

	local CacheController = knit.GetController("CacheController")
	if not CacheController.Cache.Currencies then
		CacheController.Signals.CurrenciesChanged:Wait()
	end
	if not CacheController.Cache.Level then
		CacheController.Signals.LevelChanged:Wait()
	end

	--Setup shown UI at the start
	self.ShownExperience = CacheController.Cache.Currencies.Experience or 0
	self.ShownLevel = CacheController.Cache.Level or 1

	self:Loop()
end

function Level:GetNextShownLevelData()
	local nextLvl = ExperienceLevelsData[self.ShownLevel + 1]
	return nextLvl
end

function Level:GetPercentage()
	local nextLvl = self:GetNextShownLevelData()
	local nextExperience = 0

	if nextLvl then
		nextExperience = nextLvl.RequiredExperience
	end

	local percentage = math.clamp(self.ShownExperience / nextExperience, 0, 1)
	return percentage
end

function Level:SetPercentage(doNotEmit)
	--Sets bar to percentage of shown experience
	local percentage = self:GetPercentage()
	self.UI.Frame.Bar.Size = UDim2.new(percentage, 0, 1, 0)

	--UI particle effect at end of frame
	if not doNotEmit and tick() - self.LastEmit >= 0.001 then
		self.LastEmit = tick()
		self.Particle:Emit(1)
	end

	self.UI.TextLabel.Text = `Level {self.ShownLevel} - {math.floor(percentage * 100)}%`
end

function Level:Loop()
	--Update the UI
	local CacheController = knit.GetController("CacheController")
	local speed = 200

	self:SetPercentage(true)

	self.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
		local CurrentLevel = CacheController.Cache.Level
		local CurrentExperience = CacheController.Cache.Currencies.Experience

		--Tween shown level to current level by tweening experience till both ShownLevel and experience is the same as the synced values

		if not CurrentLevel or not CurrentExperience then
			return
		end

		if CurrentLevel < self.ShownLevel then
			self.ShownLevel = CurrentLevel
			self.ShownExperience = CurrentExperience
			self:SetPercentage(true)
			return
		end

		if not self:GetNextShownLevelData() then
			return
		end

		if CurrentLevel == self.ShownLevel then
			--CurrentLevel is shown level
			if self.ShownExperience == CurrentExperience then
				return
			end

			self.ShownExperience += speed * dt
			if self.ShownExperience > CurrentExperience then
				self.ShownExperience = CurrentExperience
			end

			self:SetPercentage()
			return
		end
		--Lerp experience
		self.ShownExperience += speed * dt

		--Check for level
		local nextLvl = self:GetNextShownLevelData()
		if not nextLvl then
			self:SetPercentage()
			return
		end
		if not (self.ShownExperience >= nextLvl.RequiredExperience) then
			self:SetPercentage()
			return
		end

		--Level up
		local extra = self.ShownExperience - nextLvl.RequiredExperience
		self.ShownLevel += 1
		self.ShownExperience = extra

		self:SetPercentage(math.floor(extra) > 0)
	end))
end

function Level:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Level
