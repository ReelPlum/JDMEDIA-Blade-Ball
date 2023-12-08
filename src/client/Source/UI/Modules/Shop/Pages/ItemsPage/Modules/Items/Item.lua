--[[
Item
2023, 11, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemObj = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Common.Item)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local Item = {}
Item.ClassName = "Item"
Item.__index = Item

function Item.new(Items, shopItem)
	local self = setmetatable({}, Item)

	self.Janitor = janitor.new()

	self.Items = Items
	self.ShopItem = shopItem

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Item:Init()
	local ShopController = knit.GetController("ShopController")
	local CurrencyController = knit.GetController("CurrencyController")
	local ItemController = knit.GetController("ItemController")

	local d = ShopController:GetItem(self.ShopItem)
	if not d then
		return
	end
	local currencyData = CurrencyController:GetCurrencyData(d.Price.Currency)
	if not currencyData then
		return
	end

	self.UI = self.Janitor:Add(self.Items.UI.Item:Clone())
	self.UI.Parent = self.Items.UI
	self.UI.Visible = true

	--Display price
	self.UI.TextLabel.TextLabel.Text = d.Price.Amount
	self.UI.TextLabel.ImageLabel.Image = currencyData.Image or ""

	--Buttons
	self.Janitor:Add(self.UI.MouseButton1Click:Connect(function()
		--
		ShopController:PurchaseItem(self.ShopItem)
	end))

	self.Item = self.Janitor:Add(ItemObj.new(ReplicatedStorage.Assets.UI.Item, d.Item, function()
		return
	end, self.Items.ItemsPage.Shop.ToolTip, d.Amount or 1))
	self.Item.UI.Parent = self.UI.Item
	self.Item.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.Item.UI.Position = UDim2.new(0.5, 0, 0.5, 0)
end

function Item:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item
