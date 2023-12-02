--[[
init
2023, 11, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemsPage = {}
ItemsPage.ClassName = "ItemsPage"
ItemsPage.__index = ItemsPage

function ItemsPage.new(shop)
	local self = setmetatable({}, ItemsPage)

	self.Janitor = janitor.new()

	self.Shop = shop

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ItemsPage:Init()
	self.UI = self.Shop.PlatformUI.Holder.ItemShop

	--Load modules
	for _, i in script.Modules:GetChildren() do
		local m = require(i)
		if not m.Enabled then
			continue
		end

		self.Janitor:Add(m.new(self, 1))
	end

	self.UI.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local s = self.UI.UIListLayout.AbsoluteContentSize
		self.UI.Size = UDim2.new(1, 0, 0, s.Y)
	end)
	local s = self.UI.UIListLayout.AbsoluteContentSize
	self.UI.Size = UDim2.new(1, 0, 0, s.Y)
end

function ItemsPage:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = bool
end

function ItemsPage:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ItemsPage
