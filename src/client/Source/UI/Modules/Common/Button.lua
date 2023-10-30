--[[
Button
2023, 10, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Button = {}
Button.__index = Button

function Button.new(UI, buttonType)
	local self = setmetatable({}, Button)

	self.Janitor = janitor.new()

	self.UI = UI
	self.ButtonType = buttonType

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function Button:Init()
	--Initialize the button
end

function Button:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Button
