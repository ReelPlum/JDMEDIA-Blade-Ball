--[[
init
25, 11, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemsContainer = require(script.Parent.Common.ItemsContainer)
local Item = require(script.Parent.Common.Item)
local ToolTip = require(script.Parent.Common.ToolTip)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)
local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)
local EnchantsData = require(ReplicatedStorage.Data.EnchantsData)

local Enchanting = {}
Enchanting.ClassName = "Enchanting"
Enchanting.__index = Enchanting

function Enchanting.new(uiTemplate)
	local self = setmetatable({}, Enchanting)

	self.Janitor = janitor.new()

	self.UITemplate = uiTemplate

	self.SelectedBook = nil
	self.SelectedItem = nil

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Enchanting:Init()
	self.UI = self.Janitor:Add(self.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local InputController = knit.GetController("InputController")
	if self.UI:FindFirstChild(InputController.Platform) then
		self.PlatformUI = self.UI:FindFirstChild(InputController.Platform)
	else
		self.PlatformUI = self.UI:FindFirstChild("Frame")
	end
	self.PlatformUI.Visible = true

	self.ToolTip = ToolTip.new(self.UI)

	--Enchants item UI
	self.CombinedBookItemDisplay = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
		--Unselect
		self:UnselectItem(self.SelectedBook)
	end, self.ToolTip))
	--Parent, size and position
	self.CombinedBookItemDisplay.UI.Parent = self.PlatformUI.Frame.CombineEnchants.Book
	self.CombinedBookItemDisplay.UI.Size = UDim2.new(0.9, 0, 0.9, 0)
	self.CombinedBookItemDisplay.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.CombinedBookItemDisplay.UI.Position = UDim2.new(0.5, 0, 0.5, 0)

	self.CombinedKnifeItemDisplay = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
		self:UnselectItem(self.SelectedItem)
	end, self.ToolTip))
	--Parent, size and position
	self.CombinedKnifeItemDisplay.UI.Parent = self.PlatformUI.Frame.CombineEnchants.Item
	self.CombinedKnifeItemDisplay.UI.Size = UDim2.new(0.9, 0, 0.9, 0)
	self.CombinedKnifeItemDisplay.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.CombinedKnifeItemDisplay.UI.Position = UDim2.new(0.5, 0, 0.5, 0)

	self.RandomKnifeItemDisplay = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
		self:UnselectItem(self.SelectedItem)
	end, self.ToolTip))
	--Parent, size and position
	self.RandomKnifeItemDisplay.UI.Parent = self.PlatformUI.Frame.Enchant.Item
	self.RandomKnifeItemDisplay.UI.Size = UDim2.new(0.9, 0, 0.9, 0)
	self.RandomKnifeItemDisplay.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.RandomKnifeItemDisplay.UI.Position = UDim2.new(0.5, 0, 0.5, 0)

	self.CraftedCombinedItem = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
		self:UnselectItem(self.SelectedItem)
	end, self.ToolTip))
	--Parent, size and position
	self.CraftedCombinedItem.UI.Parent = self.PlatformUI.Frame.CombineEnchants.CombinedItem
	self.CraftedCombinedItem.UI.Size = UDim2.new(0.9, 0, 0.9, 0)
	self.CraftedCombinedItem.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.CraftedCombinedItem.UI.Position = UDim2.new(0.5, 0, 0.5, 0)

	self.CraftedRandomItem = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
		self:UnselectItem(self.SelectedItem)
	end, self.ToolTip))
	--Parent, size and position
	self.CraftedRandomItem.UI.Parent = self.PlatformUI.Frame.Enchant.CombinedItem
	self.CraftedRandomItem.UI.Size = UDim2.new(0.9, 0, 0.9, 0)
	self.CraftedRandomItem.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.CraftedRandomItem.UI.Position = UDim2.new(0.5, 0, 0.5, 0)

	--Setup inventory
	local ItemController = knit.GetController("ItemController")

	self.Pages = {
		["Combine"] = { ui = self.PlatformUI.Frame.CombineEnchants, itemTypes = { "Book", "Knife" } },
		["Random"] = { ui = self.PlatformUI.Frame.Enchant, itemTypes = { "Knife" } },
		["Default"] = { ui = self.PlatformUI.Frame.NoSelection, itemTypes = { "Knife", "Book" } },
	}

	self.ItemContainer = self.Janitor:Add(
		ItemsContainer.new(self.PlatformUI.Frame.Inventory.ScrollingFrame, ItemController:GetInventory(), function(id)
			--Check if book or knife.
			self:SelectItem(id)
		end, { self.Pages.Default.itemTypes }, function(stackData, stackId, itemLookup)
			local data = stackData.Data

			local itemData = ItemController:GetItemData(data.Item)
			if not itemData then
				return
			end

			if itemLookup[self.SelectedItem] and itemLookup[self.SelectedBook] then
				if
					itemLookup[self.SelectedBook].StackId == stackId
					and itemLookup[self.SelectedItem].StackId == stackId
				then
					return false, -2
				end
			end

			if itemLookup[self.SelectedItem] then
				if itemLookup[self.SelectedItem].StackId == stackId then
					return false, -1
				end
			end

			if itemLookup[self.SelectedBook] then
				if itemLookup[self.SelectedBook].StackId == stackId then
					return false, -1
				end
			end

			if not data.Metadata then
				return false
			end

			if data.Metadata[MetadataTypes.Types.Enchant] and itemData.ItemType == "Book" then
				return true
			end

			if not data.Metadata[MetadataTypes.Types.Enchant] and itemData.ItemType == "Knife" then
				return true
			end

			return false
		end)
	)

	self.Janitor:Add(ItemController.Signals.StacksUpdated:Connect(function()
		self.ItemContainer:Update(ItemController:GetInventoryInStacks())
		self:Update()
	end))

	--Buttons
	local EnchantingService = knit.GetService("EnchantingService")

	self.Janitor:Add(self.Pages.Combine.ui.Combine.MouseButton1Click:Connect(function()
		--Combine
		EnchantingService:ApplyBookToItem(self.SelectedBook, self.SelectedItem)

		self:UnselectItem(self.SelectedItem)
		self:UnselectItem(self.SelectedBook)
	end))

	self.Janitor:Add(self.Pages.Random.ui.Enchant.MouseButton1Click:Connect(function()
		EnchantingService:RandomlyEnchantItem(self.SelectedItem)
		self:UnselectItem(self.SelectedItem)
	end))

	self.Janitor:Add(self.PlatformUI.Topbar.Close.MouseButton1Click:Connect(function()
		self:SetVisible(false)
	end))

	-- self.Janitor:Add(self.Pages.Combine.ui.Continue.MouseButton1Click:Connect(function() end))

	-- self.Janitor:Add(self.Pages.Random.ui.Continue.MouseButton1Click:Connect(function() end))

	self.Janitor:Add(game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt)
		if prompt.Name == "EnchantingStation" then
			self:SetVisible(true)
		end
	end))

	self:ChangePage("Default")
	self:SetVisible(false)
end

function Enchanting:ChangePage(page)
	local ItemController = knit.GetController("ItemController")

	self.CurrentPage = page
	for name, data in self.Pages do
		if string.lower(name) == string.lower(page) then
			data.ui.Visible = true
			self.ItemContainer:UpdateItemTypes(data.itemTypes)
			self.ItemContainer:UpdateStacks()
			--self.ItemContainer:Update(ItemController:GetInventory())

			continue
		end
		data.ui.Visible = false
	end

	self:Update()
end

function Enchanting:Update()
	local ItemController = knit.GetController("ItemController")
	local CacheController = knit.GetController("CacheController")

	--Check if selected items are still in player's inventory
	if not ItemController:GetItemFromId(self.SelectedBook) and self.SelectedBook ~= nil then
		self:UnselectItem(self.SelectedBook)
	end
	if not ItemController:GetItemFromId(self.SelectedItem) and self.SelectedItem ~= nil then
		self:UnselectItem(self.SelectedItem)
	end

	local SelectedBookData = ItemController:GetItemFromId(self.SelectedBook)
	local SelectedItemData = ItemController:GetItemFromId(self.SelectedItem)

	self.CraftedCombinedItem.UI.Visible = false
	self.CraftedRandomItem.UI.Visible = true

	--Update items displayed on positions
	if not self.SelectedBook then
		--Hide selected book displays
		self.CombinedBookItemDisplay:Update(SelectedBookData)
		self.CombinedBookItemDisplay.UI.Visible = false
	else
		--Show selected book displays
		self.CombinedBookItemDisplay:Update(SelectedBookData)
		self.CombinedBookItemDisplay.UI.Visible = true
	end

	if not self.SelectedItem then
		--Hide selected knife displays
		self.RandomKnifeItemDisplay:Update(SelectedItemData)
		self.CombinedKnifeItemDisplay:Update(SelectedItemData)
		self.RandomKnifeItemDisplay.UI.Visible = false
		self.CombinedKnifeItemDisplay.UI.Visible = false
	else
		--Show selected knife displays
		self.RandomKnifeItemDisplay:Update(SelectedItemData)
		self.CombinedKnifeItemDisplay:Update(SelectedItemData)
		self.RandomKnifeItemDisplay.UI.Visible = true
		self.CombinedKnifeItemDisplay.UI.Visible = true
	end

	if self.CurrentPage == "Default" then
		return
	end

	if self.CurrentPage == "Combine" and (SelectedItemData and SelectedBookData) then
		--Get combined price
		local itemEnchant = SelectedBookData.Metadata[MetadataTypes.Types.Enchant][1]
		if not itemEnchant then
			return
		end
		local enchantData = EnchantsData[itemEnchant]

		local price = enchantData.Price

		local CurrencyController = knit.GetController("CurrencyController")
		local currencyData = CurrencyController:GetCurrencyData(price.Currency)

		self.Pages.Combine.ui.Price.Amount.Text = price.Amount
		self.Pages.Combine.ui.Price.Coin.Image = currencyData.Image

		--Position enchanted item at other end
		local data = table.clone(SelectedItemData)
		data.Metadata = table.clone(SelectedItemData.Metadata)
		data.Metadata[MetadataTypes.Types.Enchant] = SelectedBookData.Metadata[MetadataTypes.Types.Enchant]

		self.CraftedCombinedItem:Update(data)
		self.CraftedCombinedItem.UI.Visible = true
	elseif self.CurrentPage == "Random" and SelectedItemData then
		--Get random enchantment price
		self.Pages.Random.ui.Price.Amount.Text = GeneralSettings.User.EnchantmentPrice.Amount
		local CurrencyController = knit.GetController("CurrencyController")
		local currencyData = CurrencyController:GetCurrencyData(GeneralSettings.User.EnchantmentPrice.Currency)

		self.Pages.Random.ui.Price.Coin.Image = currencyData.Image

		--Position enchanted item at other end
		local data = table.clone(SelectedItemData)
		data.Metadata = table.clone(SelectedItemData.Metadata)
		data.Metadata[MetadataTypes.Types.Enchant] = {
			CacheController.Cache.RandomEnchant,
			1,
		}

		self.CraftedRandomItem:Update(data)
		self.CraftedRandomItem.UI.Visible = true
	end
end

function Enchanting:SelectItem(id)
	if not id then
		return
	end

	local ItemController = knit.GetController("ItemController")
	local data = ItemController:GetItemFromId(id)
	if not data then
		return
	end

	local itemData = ItemController:GetItemData(data.Item)
	if not itemData then
		return
	end

	if itemData.ItemType == "Knife" then
		if self.SelectedItem then
			return
		end

		self.SelectedItem = id

		if not self.SelectedBook then
			self:ChangePage("Random")
			return
		end
		self:ChangePage("Combine")

		return
	end

	if itemData.ItemType == "Book" then
		self.SelectedBook = id

		self:ChangePage("Combine")
	end
end

function Enchanting:UnselectItem(id)
	if self.SelectedBook == id then
		self.SelectedBook = nil
	elseif self.SelectedItem == id then
		self.SelectedItem = nil
	end

	if not self.SelectedBook and not self.SelectedItem then
		self:ChangePage("Default")
	elseif (self.SelectedBook and not self.SelectedItem) or (not self.SelectedBook and self.SelectedItem) then
		self:ChangePage("Combine")
	end
end

function Enchanting:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.SelectedBook = nil
	self.SelectedItem = nil
	self:ChangePage("Default")

	self:Update()
	self.Visible = bool
	self.UI.Enabled = bool
end

function Enchanting:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Enchanting
