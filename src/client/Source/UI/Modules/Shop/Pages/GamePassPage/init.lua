--[[
init
2023, 11, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GamePassPage = {}
GamePassPage.ClassName = "GamePassPage"
GamePassPage.__index = GamePassPage

function GamePassPage.new()
	local self = setmetatable({}, GamePassPage)

	self.Janitor = janitor.new()

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function GamePassPage:SetVisible(bool)
  
end

function GamePassPage:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return GamePassPage
