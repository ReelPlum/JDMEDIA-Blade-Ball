--[[
ShopItem
2024, 01, 24
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ShopItem = {}
ShopItem.ClassName = "ShopItem"
ShopItem.__index = ShopItem

function ShopItem.new(shop, shopId, data, template, parent)
	local self = setmetatable({}, ShopItem)

	self.Janitor = janitor.new()

	self.ShopId = shopId
	self.Shop = shop
	self.Data = data
	self.Template = template
	self.Parent = parent

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function ShopItem:Init()
	--Create UI
	self.UI = self.Template:Clone()
	self.UI.Parent = self.Parent
	self.UI.Visible = true

	--Config
	local Config = self.UI.Config
	self.ItemName = Config.ItemName.Value
	self.ItemImage = Config.ItemImage.Value
	self.Price = Config.Price.Value
	self.PurchaseButton = Config.Purchase.Value

	local ItemController = knit.GetController("ItemController")

	self.ItemData = ItemController:GetItemData(self.Data.Item)

	self:Update()

	--Buttons
	self.Janitor:Add(self.PurchaseButton.MouseButton1Click:Connect(function()
		--Purchase item
		local ShopService = knit.GetService("ShopService")
		ShopService:PurchaseItem(self.ShopId):andThen(function(items)
			return
		end)
	end))

	self.Janitor:Add(ItemController.Signals.ItemAdded:Connect(function(items)
		local itemsUpdated = {}
		for id, data in items do
			if data.Item == self.Data.Item and not table.find(itemsUpdated, data.Item) then
				self:Update()
				table.insert(itemsUpdated, data.Item)
			end
		end
	end))

	self.Janitor:Add(ItemController.Signals.ItemRemoved:Connect(function(items)
		local itemsUpdated = {}
		for id, data in items do
			if data.Item == self.Data.Item and not table.find(itemsUpdated, data.Item) then
				self:Update()
				table.insert(itemsUpdated, data.Item)
			end
		end
	end))

	self.Janitor:Add(ItemController.Signals.InventoryLoaded:Connect(function()
		self:Update()
	end))
end

function ShopItem:Update()
	--Check if Item is already owned, and if more than one can be owned
	local ItemController = knit.GetController("ItemController")

	self.ItemName.Text = self.ItemData.DisplayName
	self.ItemImage.Image = self.ItemData.Image

	if self.ItemData.OneCopyAllowed then
		if ItemController:GetOneItemWhichIsItem(self.Data.Item) then
			self.Owned = true
		end
	end

	if self.Owned then
		self.Price.Visible = false
		self.PurchaseButton.Visible = false

		return
	end

	--Not owned / purchaseable
	self.Price.Text = self.Data.Price.Amount
	self.PurchaseButton.Visible = true
end

function ShopItem:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ShopItem
