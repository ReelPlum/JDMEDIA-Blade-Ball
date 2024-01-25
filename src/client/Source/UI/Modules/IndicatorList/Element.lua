--[[
Element
2023, 10, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ShortcutLabel = require(script.Parent.Parent.Common.ShortcutLabel)

local Element = {}
Element.__index = Element

export type ElementData = {
	Action: string,
	Image: string,
}

function Element.new(indicatorList, data: ElementData, func)
	local self = setmetatable({}, Element)

	self.Janitor = janitor.new()

	self.IndicatorList = indicatorList
	self.Data = data
	self.Function = func

	self.UI = nil
	self.Visible = false

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		Visible = self.Janitor:Add(signal.new()),
	}
	return self
end

function Element:Init()
	--Create UI
	self.UI = self.Janitor:Add(self.IndicatorList.UI:WaitForChild("CooldownObject"):Clone())
	self.UI.Name = self.Data.Action
	self.UI.Parent = self.IndicatorList.UI

	self.UI:WaitForChild("ImageButton").Image = self.Data.Image

	self.ShortcutLabel = self.Janitor:Add(ShortcutLabel.new(self.UI:WaitForChild("ActivationButton"), self.Data.Action))

	local InputController = knit.GetController("InputController")
	self.Janitor:Add(self.UI.MouseButton1Click:Connect(function()
		InputController:FireAction(self.Data.Action)
	end))

	self:SetVisible(true)
end

function Element:UpdateData(data: ElementData)
	--Sets data to new data
	self.Data = data

	self.UI:WaitForChild("ImageButton").Image = self.Data.Image
	self.ShortcutLabel:UpdateAction(self.Data.Action)
end

function Element:SetCooldown(t)
	--Sets cooldown effect on UI
	self.UI:WaitForChild("ImageButton"):WaitForChild("UIGradient").Offset = Vector2.new(0, 0)

	local TI = TweenInfo.new(t, Enum.EasingStyle.Linear)
	TweenService
		:Create(self.UI:WaitForChild("ImageButton"):WaitForChild("UIGradient"), TI, { Offset = Vector2.new(0, 1) })
		:Play()
end

function Element:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.Signals.Visible:Fire(bool)

	self.UI.Visible = bool
end

function Element:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Element
