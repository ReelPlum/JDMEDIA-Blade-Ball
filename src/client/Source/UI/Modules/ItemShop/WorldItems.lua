--[[
WorldItems
2024, 01, 24
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local WorldItem = require(script.Parent.WorldItem)

local WorldItems = {}
WorldItems.ClassName = "WorldItems"
WorldItems.__index = WorldItems

function WorldItems.new(shopData)
	local self = setmetatable({}, WorldItems)

	self.Janitor = janitor.new()

	self.ShopData = shopData

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function WorldItems:Init()
	--Get all world items
	local ShopController = knit.GetController("ShopController")

	self.CreatedWorldItems = {}

	for _, instance in workspace.WorldItems:GetChildren() do
		if not instance:IsA("Model") then
			continue
		end

		--Check if item has a shopId set
		local purchaseId = instance:FindFirstChild("PurchaseableId")
		if not purchaseId then
			continue
		end

		local data = ShopController:GetItem(purchaseId.Value)
		if not data then
			continue
		end

		--Create world item
		self.CreatedWorldItems[instance] = self.Janitor:Add(WorldItem.new(purchaseId.Value, data, instance))
	end
end

function WorldItems:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return WorldItems
