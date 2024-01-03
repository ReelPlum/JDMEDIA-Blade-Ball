--[[
init
2023, 12, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local UnboxedItem = {}
UnboxedItem.ClassName = "UnboxedItem"
UnboxedItem.__index = UnboxedItem

function UnboxedItem.new()
	local self = setmetatable({}, UnboxedItem)

	self.Janitor = janitor.new()

	self.Items = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function UnboxedItem:Init()
	--Create UI
end

function UnboxedItem:AddItem(unboxData)
	--Data for unboxed item
end

function UnboxedItem:UpdateItems()
	--Update shown items.
end

function UnboxedItem:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return UnboxedItem
