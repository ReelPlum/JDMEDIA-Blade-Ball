--[[
init
2023, 12, 13
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ToolTip = {}
ToolTip.ClassName = "ToolTip"
ToolTip.__index = ToolTip

function ToolTip.new(Template)
	local self = setmetatable({}, ToolTip)

	self.Janitor = janitor.new()

	self.Template = Template

	self.Actors = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function ToolTip:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ToolTip
