--[[
ClientBall
2023, 10, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ClientBall = {}
ClientBall.__index = ClientBall

function ClientBall.new()
	local self = setmetatable({}, ClientBall)

	self.Janitor = janitor.new()

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function ClientBall:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ClientBall
