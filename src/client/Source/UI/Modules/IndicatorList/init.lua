--[[
init
2023, 10, 28
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Element = require(script.Element)

local InputData = require(ReplicatedStorage.Data.InputData)

local IndicatorList = {}
IndicatorList.__index = IndicatorList
IndicatorList.UIType = "HUD"

function IndicatorList.new(UITemplate, Parent)
	local self = setmetatable({}, IndicatorList)

	self.Janitor = janitor.new()

	self.Visible = false

	self.Parent = Parent
	self.Template = UITemplate
	self.UI = nil

	self.Elements = {
		["Deflect"] = Element.new(self, {
			Action = "Deflect",
			Image = "",
		}),
		["Ability"] = Element.new(self, {
			Action = "Ability",
			Image = "",
		}),
	}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		Visible = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function IndicatorList:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	for _, element in self.Elements do
		element:Init()
	end

	self:SetVisible(true)
end

function IndicatorList:GetElement(elementName)
	return self.Elements[elementName]
end

function IndicatorList:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = bool
end

function IndicatorList:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return IndicatorList
