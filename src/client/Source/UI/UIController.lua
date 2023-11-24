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
	task.spawn(function()
		--Registers UI module
		UI[module.Name] = require(module).new(UITemplate)
	end)
end

function UIController:KnitStart()
	--Register all UI here
	self:RegisterUI(script.Parent.Modules.IndicatorList, ReplicatedStorage.Assets.UI.IndicatorList)
	self:RegisterUI(script.Parent.Modules.BallPointer, ReplicatedStorage.Assets.UI.BallPointer)
	self:RegisterUI(script.Parent.Modules.Level, ReplicatedStorage.Assets.UI.Level)
	self:RegisterUI(script.Parent.Modules.ItemInventory, ReplicatedStorage.Assets.UI.Inventory)
	self:RegisterUI(script.Parent.Modules.Trading, ReplicatedStorage.Assets.UI.Trading)
	self:RegisterUI(script.Parent.Modules.TradeRequest, ReplicatedStorage.Assets.UI.TradeRequests)
	self:RegisterUI(script.Parent.Modules.Unboxing, ReplicatedStorage.Assets.UI.Unbox)
	self:RegisterUI(script.Parent.Modules.Menu, ReplicatedStorage.Assets.UI.Menu)
end

function UIController:KnitInit()
	self:RegisterUI(script.Parent.Modules.Loading, ReplicatedStorage.Assets.UI.LoadingScreen)
end

return UIController
