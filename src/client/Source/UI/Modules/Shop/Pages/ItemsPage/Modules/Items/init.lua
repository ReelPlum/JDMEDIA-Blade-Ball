--[[
Items
2023, 11, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Item = require(script.Item)

local ShopData = require(ReplicatedStorage.Data.ShopData)

local Items = {}
Items.ClassName = "Items"
Items.__index = Items
Items.Enabled = true

function Items.new(itemsPage, priority)
	local self = setmetatable({}, Items)

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

function Items:Init()
	--UI
	self.UI = self.Janitor:Add(self.ItemsPage.UI.Items:Clone())
	self.UI.Name = "ItemsPage" .. self.Priority
	self.UI.Parent = self.ItemsPage.UI
	self.UI.Visible = true
	self.UI.LayoutOrder = self.Priority

	--Create unboxables
	for itm, data in ShopData.Items do
		if not data.Price then
			continue
		end

		self.CreatedItems[itm] = Item.new(self, itm)
	end

	--Size UI
	self.UI.UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local s = self.UI.UIGridLayout.AbsoluteContentSize
		self.UI.Size = UDim2.new(1, 0, 0, s.Y)
	end)
	local s = self.UI.UIGridLayout.AbsoluteContentSize
	self.UI.Size = UDim2.new(1, 0, 0, s.Y)
end

function Items:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Items
