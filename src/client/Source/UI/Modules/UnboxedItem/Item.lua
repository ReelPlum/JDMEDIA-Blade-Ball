--[[
Item
2023, 12, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(holder, unboxData)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Item:Init()
	--Create UI

	--Position UI

  --Animate
end

function Item:Animate()
	--Animate and end up destroying
end

function Item:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item
