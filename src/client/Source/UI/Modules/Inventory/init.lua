--[[
init
2023, 11, 03
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(UITemplate)
	local self = setmetatable({}, Inventory)

	self.Janitor = janitor.new()

	self.UITemplate = UITemplate

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Inventory:Init()
	self.UI = self.Janitor:Add(self.UITemplate:Clone())
end

function Inventory:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Inventory
