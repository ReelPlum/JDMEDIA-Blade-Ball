--[[
init
2023, 11, 10
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Arrow = require(script.Arrow)

local BallPointer = {}
BallPointer.ClassName = "BallPointer"
BallPointer.__index = BallPointer
BallPointer.UIType = "HUD"

function BallPointer.new(uiTemplate)
	local self = setmetatable({}, BallPointer)

	self.Janitor = janitor.new()

	self.UITemplate = uiTemplate
	self.Arrows = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function BallPointer:Init()
	local BallController = knit.GetController("BallController")

	self.Janitor:Add(BallController.Signals.BallRemoved:Connect(function(ball)
		if not self.Arrows[ball] then
			return
		end

		self.Arrows[ball]:Destroy()
		self.Arrows[ball] = nil
	end))

	self.Janitor:Add(BallController.Signals.BallAdded:Connect(function(ball)
		self.Arrows[ball] = Arrow.new(self, ball)
	end))
end

function BallPointer:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return BallPointer
