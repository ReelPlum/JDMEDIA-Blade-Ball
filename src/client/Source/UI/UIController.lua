--[[
UIController
2023, 10, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local UIController = knit.CreateController({
	Name = "UIController",
	Signals = {},
})

local UI = {}

function UIController:GetUI(name)
	--Returns registered UI with name
	return UI[name]
end

function UIController:RegisterUI(module, UITemplate)
	--Registers UI module
	UI[module.Name] = require(module).new(UITemplate)
end

function UIController:KnitStart() end

function UIController:KnitInit()
	--Register all UI here
	self:RegisterUI(script.Parent.Modules.IndicatorList, ReplicatedStorage.Assets.UI.IndicatorList)
end

return UIController
