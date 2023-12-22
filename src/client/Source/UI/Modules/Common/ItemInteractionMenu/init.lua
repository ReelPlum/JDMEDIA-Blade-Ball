--[[
init
2023, 12, 18
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemInteractionMenu = {}
ItemInteractionMenu.ClassName = "ItemInteractionMenu"
ItemInteractionMenu.__index = ItemInteractionMenu

function ItemInteractionMenu.new(template, parent)
	local self = setmetatable({}, ItemInteractionMenu)

	self.Janitor = janitor.new()
	self.ElementJanitor = self.Janitor:Add(janitor.new())

	self.Template = template
	self.Parent = parent

	self.Data = nil

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ItemInteractionMenu:Init()
	self.UI = self.Janitor:Add(self.Template:Clone())
	self.UI.Parent = self.Parent

	local config = self.UI.Config

	self.Element = config.Element.Value
	self.Holder = config.Holder.Value

	self.Element.Visible = false

	self:SetVisible(false)
end

function ItemInteractionMenu:SetData(data, ids, position)
	self.UI.Position = position
	self.Data = data

	self.ElementJanitor:Cleanup()

	--Setup data for ui
	for _, interaction in self.Data do
		--Create element
		local element = self.ElementJanitor:Add(self.Element:Clone())
		element.Text = interaction.DisplayName
		element.Visible = true

		self.ElementJanitor:Add(element.MouseButton1Click:Connect(function()
			interaction.Use(ids)
			self:SetVisible(false)
		end))
		element.Parent = self.Holder
	end

	self.Holder.Size = UDim2.new(
		self.Holder.Size.X.Scale,
		self.Holder.Size.X.Offset,
		0,
		self.Holder:FindFirstChild("UIListLayout").AbsoluteContentSize.Y
	)

	self:SetVisible(true)
end

function ItemInteractionMenu:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = self.Visible
end

function ItemInteractionMenu:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ItemInteractionMenu
