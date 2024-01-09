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

local ItemsContainer = require(script.Parent.Common.ItemContainer)
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

	self.SelectedItemTwo = nil
	self.SelectedItemOne = nil

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
		self.PlatformUI = self.UI:FindFirstChild("Normal")
	end
	self.PlatformUI.Visible = true

	self.ToolTip = ToolTip.new(self.UI)

	--UI stuff
	local Config = self.PlatformUI.Config

	self.CloseButton = Config.CloseButton.Value
	local InventoryPage = Config.Inventory
	self.InventoryPage = InventoryPage.InventoryPage.Value
	self.InventoryHolder = InventoryPage.Holder.Value

	local NoSelectionPage = Config.NoSelection
	self.NoSelectionPage = NoSelectionPage.NoSelectionPage.Value

	local CombineEnchantsPage = Config.CombineEnchants
	self.CombineEnchantsPage = CombineEnchantsPage.CombineEnchantsPage.Value
	self.CombineBook = CombineEnchantsPage.Book.Value
	self.CombineItem = CombineEnchantsPage.Item.Value
	self.CombinedItem = CombineEnchantsPage.CombinedItem.Value
	self.CombinePrice = CombineEnchantsPage.Price.Value
	self.CombineButton = CombineEnchantsPage.CombineButton.Value

	--Enchants item UI
	self.CombinedBookItemDisplay =
		self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, self.CombineBook, self.ToolTip))
	--Parent, size and position
	self.CombinedBookItemDisplay.UI.Size = UDim2.new(0.9, 0, 0.9, 0)
	self.CombinedBookItemDisplay.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.CombinedBookItemDisplay.UI.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.CombinedBookItemDisplay.OnClick = function()
		--Unselect
		self:UnselectItem(self.SelectedItemTwo)
	end

	self.CombinedKnifeItemDisplay =
		self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, self.CombineItem, self.ToolTip))
	--Parent, size and position
	self.CombinedKnifeItemDisplay.UI.Size = UDim2.new(0.9, 0, 0.9, 0)
	self.CombinedKnifeItemDisplay.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.CombinedKnifeItemDisplay.UI.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.CombinedKnifeItemDisplay.OnClick = function()
		self:UnselectItem(self.SelectedItemOne)
	end

	self.CraftedCombinedItem =
		self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, self.CombinedItem, self.ToolTip))
	--Parent, size and position
	self.CraftedCombinedItem.UI.Size = UDim2.new(0.9, 0, 0.9, 0)
	self.CraftedCombinedItem.UI.AnchorPoint = Vector2.new(0.5, 0.5)
	self.CraftedCombinedItem.UI.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.CraftedCombinedItem.OnClick = function()
		self:UnselectItem(self.SelectedItemOne)
	end

	--Setup inventory
	local ItemController = knit.GetController("ItemController")

	self.Pages = {
		["Combine"] = {
			ui = self.CombineEnchantsPage,
			itemTypes = { "Book", "Knife" },
			shouldEnchantedItemsBeEnabled = true,
		},
		["Default"] = {
			ui = self.NoSelectionPage,
			itemTypes = { "Knife", "Book" },
			shouldEnchantedItemsBeEnabled = true,
		},
	}

	self.ItemContainer = self.Janitor:Add(
		ItemsContainer.new(self.InventoryHolder, ReplicatedStorage.Assets.UI.Item, self.ToolTip, false)
	)

	self.ItemContainer.GetItemInformation = function(item)
		local ItemController = knit.GetController("ItemController")
		return ItemController:GetItemData(item)
	end

	self.ItemContainer.GetStackSize = function(stackData)
		--Return stack size
		if
			table.find(stackData.Hold, self.SelectedItemTwo) and (not table.find(stackData.Hold, self.SelectedItemOne))
		then
			return #stackData.Hold - 1
		end
		if
			(not table.find(stackData.Hold, self.SelectedItemTwo)) and table.find(stackData.Hold, self.SelectedItemOne)
		then
			return #stackData.Hold - 1
		end
		if table.find(stackData.Hold, self.SelectedItemTwo) and table.find(stackData.Hold, self.SelectedItemOne) then
			return #stackData.Hold - 2
		end

		return #stackData.Hold
	end

	self.ItemContainer.OnClick = function(ids, data)
		--Add item
		local id = nil
		for _, i in ids do
			if i == self.SelectedItemTwo or i == self.SelectedItemOne then
				continue
			end
			id = i
			break
		end

		self:SelectItem(id)

		self.ItemContainer:UpdateStackSizes()
	end

	self.ItemContainer.ShouldBeEnabled = function(data)
		--Check if item should be enabled
		local ItemController = knit.GetController("ItemController")

		local itemData = ItemController:GetItemData(data.Item)
		if not itemData then
			return false
		end

		if not data.Metadata[MetadataTypes.Types.Enchant] and itemData.ItemType == "Book" then
			return false
		end

		if self.SelectedItemOne and self.SelectedItemTwo then
			return false
		end

		local selectedItem
		if self.SelectedItemOne then
			selectedItem = self.SelectedItemOne
		elseif self.SelectedItemTwo then
			selectedItem = self.SelectedItemTwo
		else
			return true
		end

		local d = ItemController:GetItemFromId(selectedItem)
		local itmd = ItemController:GetItemData(d.Item)

		--Check for itemtype
		if itmd.ItemType ~= "Book" and itemData.ItemType ~= "Book" then
			warn("Book")
			return false
		end

		local page = self.Pages[self.CurrentPage]
		if table.find(page.itemTypes, itemData.ItemType) then
			if d.Metadata[MetadataTypes.Types.Enchant] and data.Metadata[MetadataTypes.Types.Enchant] then
				--Book is enchanted
				local EnchantData = ItemController:GetEnchantData(d.Metadata[MetadataTypes.Types.Enchant][1])
				if not EnchantData then
					return false
				end
				--Check if enchant is the same
				if d.Metadata[MetadataTypes.Types.Enchant][1] ~= data.Metadata[MetadataTypes.Types.Enchant][1] then
					return false
				end
				--Check if enchant on selected is lower than item
				if d.Metadata[MetadataTypes.Types.Enchant][2] ~= data.Metadata[MetadataTypes.Types.Enchant][2] then
					return false
				end

				--Check if next enchant exists
				if not EnchantData.Statistics[d.Metadata[MetadataTypes.Types.Enchant][2] + 1] then
					return false
				end

				--Check if item is supported
				if not table.find(EnchantData.SupportedItemTypes, itemData.ItemType) then
					return false
				end
			end

			return true
		end

		--Not found in page
		return false

		-- local page = self.Pages[self.CurrentPage]
		-- if table.find(page.itemTypes, itemData.ItemType) then
		-- 	if data.Metadata[MetadataTypes.Types.Enchant] and not page.shouldEnchantedItemsBeEnabled then
		-- 		return false
		-- 	end

		-- 	if data.Metadata[MetadataTypes.Types.Enchant] then
		-- 		local selectedItem
		-- 		if self.SelectedItemOne then
		-- 			selectedItem = self.SelectedItemOne
		-- 		elseif self.SelectedItemTwo then
		-- 			selectedItem = self.SelectedItemTwo
		-- 		else
		-- 			return true
		-- 		end

		-- 		local d = ItemController:GetItemFromId(selectedItem)
		-- 		local itmd = ItemController:GetItemData(d.Item)

		-- 		if itmd.ItemType == "Book" then
		-- 			if d.Metadata[MetadataTypes.Types.Enchant] then
		-- 				local EnchantData = ItemController:GetEnchantData(d.Metadata[MetadataTypes.Types.Enchant][1])
		-- 				if not EnchantData then
		-- 					return false
		-- 				end

		-- 				if
		-- 					d.Metadata[MetadataTypes.Types.Enchant][1]
		-- 					~= data.Metadata[MetadataTypes.Types.Enchant][1]
		-- 				then
		-- 					return false
		-- 				end

		-- 				if
		-- 					d.Metadata[MetadataTypes.Types.Enchant][2]
		-- 					< data.Metadata[MetadataTypes.Types.Enchant][2]
		-- 				then
		-- 					return false
		-- 				end

		-- 				if not EnchantData.Statistics[d.Metadata[MetadataTypes.Types.Enchant][2] + 1] then
		-- 					return false
		-- 				end

		-- 				if not table.find(EnchantData.SupportedItemTypes, itemData.ItemType) then
		-- 					return false
		-- 				end
		-- 			else
		-- 				return false
		-- 			end
		-- 		else
		-- 			if itmd.ItemType == itemData.ItemType then
		-- 				return false
		-- 			end

		-- 			if d.Metadata[MetadataTypes.Types.Enchant] then
		-- 				local EnchantData = ItemController:GetEnchantData(d.Metadata[MetadataTypes.Types.Enchant][1])
		-- 				if not EnchantData then
		-- 					return false
		-- 				end

		-- 				if
		-- 					d.Metadata[MetadataTypes.Types.Enchant][1]
		-- 					~= data.Metadata[MetadataTypes.Types.Enchant][1]
		-- 				then
		-- 					return false
		-- 				end

		-- 				if
		-- 					d.Metadata[MetadataTypes.Types.Enchant][2]
		-- 					== data.Metadata[MetadataTypes.Types.Enchant][2]
		-- 				then
		-- 					if not EnchantData.Statistics[d.Metadata[MetadataTypes.Types.Enchant][2] + 1] then
		-- 						return false
		-- 					end
		-- 				end

		-- 				if
		-- 					d.Metadata[MetadataTypes.Types.Enchant][2]
		-- 					> data.Metadata[MetadataTypes.Types.Enchant][2]
		-- 				then
		-- 					return false
		-- 				end
		-- 			end
		-- 		end
		-- 	end

		-- 	return true
		-- end
		-- return false
	end

	self.ItemContainer:UpdateItemTypes({
		"Knife",
		"Book",
	})

	self.Janitor:Add(ItemController.Signals.StacksUpdated:Connect(function()
		self.ItemContainer:UpdateWithStacks(ItemController:GetInventoryInStacks())
	end))

	self.ItemContainer:UpdateWithStacks(ItemController:GetInventoryInStacks())

	--Buttons
	local EnchantingService = knit.GetService("EnchantingService")

	self.Janitor:Add(self.CombineButton.MouseButton1Click:Connect(function()
		--Combine
		EnchantingService:ApplyBookToItem(self.SelectedItemTwo, self.SelectedItemOne)

		self:UnselectItem(self.SelectedItemOne)
		self:UnselectItem(self.SelectedItemTwo)
	end))

	self.Janitor:Add(self.CloseButton.MouseButton1Click:Connect(function()
		self:SetVisible(false)
	end))

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
			self.ItemContainer:UpdateStackSizes()
			--self.ItemContainer:UpdateStacks()
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

	self.ItemContainer:UpdateShouldBeEnabled(self.ItemContainer.ShouldBeEnabled)

	--Check if selected items are still in player's inventory
	if not ItemController:GetItemFromId(self.SelectedItemTwo) and self.SelectedItemTwo ~= nil then
		self:UnselectItem(self.SelectedItemTwo)
	end
	if not ItemController:GetItemFromId(self.SelectedItemOne) and self.SelectedItemOne ~= nil then
		self:UnselectItem(self.SelectedItemOne)
	end

	local SelectedItemTwoData = ItemController:GetItemFromId(self.SelectedItemTwo)
	local SelectedItemOneData = ItemController:GetItemFromId(self.SelectedItemOne)

	local SelectedItemOneItemData
	local SelectedItemTwoItemData

	if SelectedItemOneData then
		SelectedItemOneItemData = ItemController:GetItemData(SelectedItemOneData.Item)
	end
	if SelectedItemTwoData then
		SelectedItemTwoItemData = ItemController:GetItemData(SelectedItemTwoData.Item)
	end

	self.CraftedCombinedItem.UI.Visible = false

	--Update items displayed on positions
	if not self.SelectedItemOne then
		--Hide selected book displays
		self.CombinedKnifeItemDisplay:UpdateData(SelectedItemOneData)
		self.CombinedKnifeItemDisplay:UpdateStack(1)
		self.CombinedKnifeItemDisplay.UI.Visible = false
	else
		--Show selected book displays
		self.CombinedKnifeItemDisplay:UpdateData(SelectedItemOneData)
		self.CombinedKnifeItemDisplay:UpdateStack(1)
		self.CombinedKnifeItemDisplay.UI.Visible = true
	end

	if not self.SelectedItemTwo then
		--Hide selected book displays
		self.CombinedBookItemDisplay:UpdateData(SelectedItemTwoData)
		self.CombinedBookItemDisplay:UpdateStack(1)
		self.CombinedBookItemDisplay.UI.Visible = false
	else
		--Show selected book displays
		self.CombinedBookItemDisplay:UpdateData(SelectedItemTwoData)
		self.CombinedBookItemDisplay:UpdateStack(1)
		self.CombinedBookItemDisplay.UI.Visible = true
	end

	if self.CurrentPage == "Default" then
		return
	end

	if self.CurrentPage == "Combine" and (SelectedItemOneData and SelectedItemTwoData) then
		--Get combined price
		local book
		local bookData

		local item
		local itemData

		if SelectedItemOneItemData.ItemType == "Book" then
			book = self.SelectedItemOne
			bookData = SelectedItemOneData

			item = self.SelectedItemTwo
			itemData = SelectedItemTwoData
		elseif SelectedItemTwoItemData.ItemType == "Book" then
			book = self.SelectedItemTwo
			bookData = SelectedItemTwoData

			item = self.SelectedItemOne
			itemData = SelectedItemOneData
		else
			return
		end

		if not bookData.Metadata[MetadataTypes.Types.Enchant] then
			return
		end
		local itemEnchant = bookData.Metadata[MetadataTypes.Types.Enchant][1]
		if not itemEnchant then
			return
		end
		local enchantData = EnchantsData[itemEnchant]

		local price = enchantData.Price

		local CurrencyController = knit.GetController("CurrencyController")
		local currencyData = CurrencyController:GetCurrencyData(price.Currency)

		self.CombinePrice.Amount.Text = price.Amount
		self.CombinePrice.Coin.Image = currencyData.Image

		--Position enchanted item at other end
		local data = table.clone(itemData)
		data.Metadata = table.clone(itemData.Metadata)

		if itemData.Metadata[MetadataTypes.Types.Enchant] then
			if
				itemData.Metadata[MetadataTypes.Types.Enchant][1]
				~= bookData.Metadata[MetadataTypes.Types.Enchant][1]
			then
				return
			else
				if
					bookData.Metadata[MetadataTypes.Types.Enchant][2]
					> itemData.Metadata[MetadataTypes.Types.Enchant][2]
				then
					data.Metadata[MetadataTypes.Types.Enchant] = bookData.Metadata[MetadataTypes.Types.Enchant]
				elseif
					bookData.Metadata[MetadataTypes.Types.Enchant][2]
					== itemData.Metadata[MetadataTypes.Types.Enchant][2]
				then
					data.Metadata[MetadataTypes.Types.Enchant] =
						table.clone(bookData.Metadata[MetadataTypes.Types.Enchant])
					data.Metadata[MetadataTypes.Types.Enchant][2] += 1
				else
					return
				end
			end
		else
			data.Metadata[MetadataTypes.Types.Enchant] = bookData.Metadata[MetadataTypes.Types.Enchant]
		end

		self.CraftedCombinedItem:UpdateData(data)
		self.CraftedCombinedItem:UpdateStack(1)
		self.CraftedCombinedItem.UI.Visible = true
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

	if self.SelectedItemOne then
		if self.SelectedItemTwo then
			return
		end
		self.SelectedItemTwo = id
	else
		self.SelectedItemOne = id
	end

	self:ChangePage("Combine")
end

function Enchanting:UnselectItem(id)
	if self.SelectedItemTwo == id then
		self.SelectedItemTwo = nil
	elseif self.SelectedItemOne == id then
		self.SelectedItemOne = nil
	end

	if not self.SelectedItemTwo and not self.SelectedItemOne then
		self:ChangePage("Default")
	elseif
		(self.SelectedItemTwo and not self.SelectedItemOne) or (not self.SelectedItemTwo and self.SelectedItemOne)
	then
		self:ChangePage("Combine")
	end
end

function Enchanting:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.SelectedItemTwo = nil
	self.SelectedItemOne = nil
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
