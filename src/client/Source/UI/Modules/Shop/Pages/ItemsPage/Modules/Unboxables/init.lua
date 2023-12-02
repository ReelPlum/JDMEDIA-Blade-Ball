--[[
Unboxables
2023, 11, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Unboxable = require(script.Unboxable)

local ShopData = require(ReplicatedStorage.Data.ShopData)

local Unboxables = {}
Unboxables.ClassName = "Unboxables"
Unboxables.__index = Unboxables
Unboxables.Enabled = true

function Unboxables.new(itemsPage, priority)
	local self = setmetatable({}, Unboxables)

	self.Janitor = janitor.new()

	self.ItemsPage = itemsPage
	self.Priority = priority

	self.CreatedItems = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Unboxables:Init()
	--UI
	self.UI = self.Janitor:Add(self.ItemsPage.UI.Unboxables:Clone())
	self.UI.Name = "UnboxablesPage" .. self.Priority
	self.UI.Parent = self.ItemsPage.UI
	self.UI.Visible = true
	self.UI.LayoutOrder = self.Priority

	--Create unboxables
	for unboxable, data in ShopData.Unboxables do
		if not data.Price then
			continue
		end

		self.CreatedItems[unboxable] = Unboxable.new(self, unboxable)
	end

	--Size UI
	self.UI.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local s = self.UI.UIGridLayout.AbsoluteContentSize
		self.UI.Size = UDim2.new(1, 0, 0, s.Y)
	end)
	local s = self.UI.UIGridLayout.AbsoluteContentSize
	self.UI.Size = UDim2.new(1, 0, 0, s.Y)
end

function Unboxables:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Unboxables
