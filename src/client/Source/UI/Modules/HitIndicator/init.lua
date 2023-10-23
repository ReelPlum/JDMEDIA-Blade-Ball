--[[
HitIndicator
2023, 10, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local HitIndicator = {}
HitIndicator.__index = HitIndicator

function HitIndicator.new(UITemplate)
	local self = setmetatable({}, HitIndicator)

	self.Janitor = janitor.new()

	self.UITemplate = UITemplate

	self.UI = nil
	self.Visible = false

	self.CoolDown = 0
	self.t = 1

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function HitIndicator:Init()
	--Setup UI
	self.UI = self.Janitor:Add(self.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

	if LocalPlayer.Character then
		self.UI.Adornee = LocalPlayer.Character
	end
	self.Janitor:Add(LocalPlayer.CharacterAdded:Connect(function(character)
		self.UI.Adornee = character
	end))

	self:Loop()
end

function HitIndicator:Loop()
	self.Janitor:Add(RunService.RenderStepped:Connect(function()
		local p = (tick() - self.CoolDown) / self.t

		--Check time
		if p > 1.25 then
			--Make UI invisible
			self:SetVisible(false)
			return
		end
		--Make UI visible
		self:SetVisible(true)

		--Set gradient
		self.UI:WaitForChild("Indicator"):WaitForChild("UIGradient").Offset = Vector2.new(0, math.min(p, 1))
	end))
end

function HitIndicator:SetCooldown(t)
	self.t = t
	self.CoolDown = tick()
end

function HitIndicator:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool

	self.UI.Enabled = bool
end

function HitIndicator:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return HitIndicator
