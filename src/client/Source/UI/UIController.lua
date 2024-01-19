--[[
UIController
2023, 10, 22
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local ToolTip = require(script.Parent.Modules.Common.ToolTip)

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local UIController = knit.CreateController({
	Name = "UIController",
	Signals = {},
})

local UI = {}

local ParentUI = Instance.new("ScreenGui")
ParentUI.ResetOnSpawn = false
ParentUI.IgnoreGuiInset = true
ParentUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ParentUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToolTipUI = Instance.new("ScreenGui")
ToolTipUI.ResetOnSpawn = false
ToolTipUI.IgnoreGuiInset = true
ToolTipUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToolTipUI.DisplayOrder = 2

ToolTipUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

UIController.ToolTip = ToolTip.new(ToolTipUI)

function UIController:GetUI(name)
	--Returns registered UI with name
	return UI[name]
end

function UIController:RegisterUI(module, UITemplate)
	task.spawn(function()
		--Registers UI module
		UI[module.Name] = require(module).new(UITemplate, ParentUI)
	end)
end

function UIController:ShowGameUI()
	local ui = UIController:GetUI("Menu")
	if not ui then
		return
	end

	ui:SetVisible(true)
end

function UIController:HideAllUI()
	for _, ui in UI do
		if not ui.SetVisible then
			continue
		end
		ui:SetVisible(false)
	end
end

function UIController:KnitStart()
	--Register all UI here
	self:RegisterUI(script.Parent.Modules.Inventory, ReplicatedStorage.Assets.UI.Inventory)
	self:RegisterUI(script.Parent.Modules.BallPointer, ReplicatedStorage.Assets.UI.BallPointer)
	self:RegisterUI(script.Parent.Modules.ItemSelection, ReplicatedStorage.Assets.UI.ItemSelection)
	self:RegisterUI(script.Parent.Modules.UnboxedItem, ReplicatedStorage.Assets.UI.UnboxedItem)
	self:RegisterUI(script.Parent.Modules.Leaderboards)
	self:RegisterUI(script.Parent.Modules.TextPrompt, ReplicatedStorage.Assets.UI.TextPrompt)
	self:RegisterUI(script.Parent.Modules.Enchanting, ReplicatedStorage.Assets.UI.EnchantingTable)
	self:RegisterUI(script.Parent.Modules.Rebirth, ReplicatedStorage.Assets.UI.Rebirth)
	self:RegisterUI(script.Parent.Modules.Menu, ReplicatedStorage.Assets.UI.HUD)
	self:RegisterUI(script.Parent.Modules.Trading, ReplicatedStorage.Assets.UI.Trading)
	self:RegisterUI(script.Parent.Modules.TradeRequest, ReplicatedStorage.Assets.UI.TradeRequests)
	self:RegisterUI(script.Parent.Modules.TradePrompt, ReplicatedStorage.Assets.UI.TradeReq)
end

function UIController:KnitInit()
	--self:RegisterUI(script.Parent.Modules.Loading, ReplicatedStorage.Assets.UI.LoadingScreen)
end

return UIController
