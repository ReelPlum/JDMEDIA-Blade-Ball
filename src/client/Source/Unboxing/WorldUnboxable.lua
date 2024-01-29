--[[
WorldUnboxable
2023, 12, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local moonlite = require(ReplicatedStorage.Common:WaitForChild("Moonlite"))

local WorldUnboxable = {}
WorldUnboxable.ClassName = "WorldUnboxable"
WorldUnboxable.__index = WorldUnboxable

function WorldUnboxable.new(location, origin, unboxable, player, unboxedItem)
	local self = setmetatable({}, WorldUnboxable)

	self.Janitor = janitor.new()

	self.Location = location
	self.Origin = origin
	self.Unboxable = unboxable
	self.Player = player
	self.isLocalPlayer = self.Player == LocalPlayer
	self.UnboxedItem = unboxedItem

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function WorldUnboxable:Init()
	--Check if user should show other player's unboxes
	local UnboxingController = knit.GetController("UnboxingController")
	local data = UnboxingController:GetUnboxable(self.Unboxable)

	self.Data = data

	self.Object = self.Janitor:Add(data.Model:Clone())
	self.Object.Parent = workspace

	--local Animator = self.Janitor:Add(Instance.new("AnimationController"))
	--Animator.Parent = self.Object

	--self.Anim = self.Janitor:Add(Animator:LoadAnimation(data.Animation))

	--Emit
	task.spawn(function()
		self:Emit()
	end)
end

function WorldUnboxable:Emit()
	--Emit the unboxable from the origin out to the location
	local g = Vector3.new(0, -workspace.Gravity, 0)
	local t = (self.Location - self.Origin).Magnitude / 20
	local v0 = (self.Location - self.Origin - 0.5 * g * t * t) / t

	--Animate path
	local nt = 0
	self.SpawnAnimation = self.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
		--Animate
		nt = math.min(nt + dt, t)
		self.Object:PivotTo(CFrame.new(0.5 * g * nt * nt + v0 * nt + self.Origin, self.Origin))

		if nt >= t then
			self.SpawnAnimation:Disconnect()
			self.SpawnAnimation = nil

			--Animate on finish
			self:AnimateUnboxing()
		end
	end))
end

function WorldUnboxable:AnimateUnboxing()
	--Animate the unboxing
	--Use moonlite to animate a moon animator 2 animation
	--self.Anim:Play()
	self.Anim = moonlite.CreatePlayer(self.Data.Animation, self.Object)

	self.Janitor:Add(self.Anim.Completed:Connect(function()
		self:FinishedUnboxing()
	end))

	self.Anim:Play()
end

function WorldUnboxable:FinishedUnboxing()
	--Show unboxed item in 3d world
	local UnboxingController = knit.GetController("UnboxingController")
	local data = UnboxingController:GetLootFromUnboxable(self.Unboxable, self.UnboxedItem)

	local WorldUnboxablesController = knit.GetController("WorldUnboxablesController")
	local model = WorldUnboxablesController:CreateModelForItem(data)
	model.Parent = workspace

	local nt = 0
	if self.isLocalPlayer then
		--If localplayer then show on players screen
		local UIController = knit.GetController("UIController")
		local UnboxedItemUI = UIController:GetUI("UnboxedItem")
		UnboxedItemUI:AddItem(data, model:Clone())
	end

	--Move item to unboxing player
	local target = self.Player.Character.HumanoidRootPart.CFrame.Position

	local g = Vector3.new(0, -workspace.Gravity, 0)
	local t = (target - self.Location).Magnitude / 35
	local v0 = (target - self.Location - 0.5 * g * t * t) / t

	self.Animation = self.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
		nt = math.min(nt + dt, t)
		model:PivotTo(
			CFrame.new(
				0.5 * g * nt * nt + v0 * nt + self.Location,
				0.5 * g * (nt + dt) * (nt + dt) + v0 * (nt + dt) + self.Location
			)
		)

		if nt >= t then
			--Finish
			model:Destroy()
			self:Destroy()
		end
	end))
end

function WorldUnboxable:Luck()
	--Click for luck!
end

function WorldUnboxable:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return WorldUnboxable
