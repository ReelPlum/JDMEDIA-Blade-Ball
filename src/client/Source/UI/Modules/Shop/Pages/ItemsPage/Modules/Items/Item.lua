--[[
Item
2023, 11, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

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
	local CacheController = knit.GetController("CacheController")

	local d = ShopController:GetItem(self.ShopItem)
	if not d then
		return
	end
	local currencyData = CurrencyController:GetCurrencyData(d.Price.Currency)
	if not currencyData then
		return
	end

	local itemData = ItemController:GetItemData(d.Item.Item)
	if not itemData then
		warn("No data")
		warn(d.Item)
		return
	end

	local rarityData = ItemController:GetRarityData(itemData.Rarity)

	--Create UI
	self.UI = self.Janitor:Add(self.Items.UI.Item:Clone())
	self.UI.Parent = self.Items.UI
	self.UI.Visible = true

	self.UI.Item.ItemName.Text = itemData.DisplayName
	self.UI.Item.ItemImage.Image = itemData.Image

	--Display price
	self.UI.TextLabel.TextLabel.Text = d.Price.Amount
	self.UI.TextLabel.ImageLabel.Image = currencyData.Image

	--Buttons
	self.Janitor:Add(self.UI.MouseButton1Click:Connect(function()
		--
		ShopController:PurchaseItem(self.ShopItem)
	end))

	self.ToolTipData = {
		{
			Type = "Header",
			Text = itemData.DisplayName,
			Item = d.Item.Item,
		},
		{
			Type = "Rarity",
			Data = rarityData,
			Item = d.Item.Item,
		},
	}

	for t, i in d.Item.Metadata do
		table.insert(self.ToolTipData, {
			Type = t,
			Data = i,
			Item = d.Item.Item,
		})
	end

	if table.find(GeneralSettings.ItemTypesToTrackCopiesOf, itemData.ItemType) then
		local amount = 0
		if CacheController.Cache.ItemCopies then
			amount = CacheController.Cache.ItemCopies[d.Item.Item]
		end

		table.insert(self.ToolTipData, {
			Type = "Copies",
			Copies = amount,
			Item = d.Item.Item,
		})
	end

	--Tool tip
	self.Janitor:Add(self.UI.MouseEnter:Connect(function()
		--Shop tool tip
		self:GetToolTipData()

		self.Items.ItemsPage.Shop.ToolTip:AddActor(self.ToolTipData)
	end))

	self.Janitor:Add(self.UI.MouseLeave:Connect(function()
		--Hide tool tip
		self.Items.ItemsPage.Shop.ToolTip:RemoveActor(self.ToolTipData)
	end))
end

function Item:GetToolTipData()
	local ShopController = knit.GetController("ShopController")
	local ItemController = knit.GetController("ItemController")
	local CacheController = knit.GetController("CacheController")

	self.ToolTipData = {}
	local d = ShopController:GetItem(self.ShopItem)
	if not d then
		return
	end

	local itemData = ItemController:GetItemData(d.Item.Item)
	if not itemData then
		warn("No data")
		warn(d.Item)
		return
	end

	local rarityData = ItemController:GetRarityData(itemData.Rarity)
	self.ToolTipData = {
		{
			Type = "Header",
			Text = itemData.DisplayName,
			Item = d.Item.Item,
		},
		{
			Type = "Rarity",
			Data = rarityData,
			Item = d.Item.Item,
		},
	}

	for t, i in d.Item.Metadata do
		table.insert(self.ToolTipData, {
			Type = t,
			Data = i,
			Item = d.Item.Item,
		})
	end

	if table.find(GeneralSettings.ItemTypesToTrackCopiesOf, itemData.ItemType) then
		local amount = 0
		warn(d.Item.Item)
		if CacheController.Cache.ItemCopies then
			amount = CacheController.Cache.ItemCopies[d.Item.Item]
		end

		table.insert(self.ToolTipData, {
			Type = "Copies",
			Copies = amount,
			Item = d.Item.Item,
		})
	end
end

function Item:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Item
