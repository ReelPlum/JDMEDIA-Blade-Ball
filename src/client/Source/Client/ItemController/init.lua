--[[
ItemController
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ItemStacksModule = require(ReplicatedStorage.Common.ItemsStacks)

local ItemData = ReplicatedStorage.Data.Items
local RarityData = ReplicatedStorage.Data.Rarities

local ItemController = knit.CreateController({
	Name = "ItemController",
	Signals = {
		ItemAdded = signal.new(),
		ItemRemoved = signal.new(),

		InventoryLoaded = signal.new(),

		StacksUpdated = signal.new(),
	},

	Inventory = nil,
})

local ItemLookup = {}
local ItemStacks = {}

function ItemController:GetInventory()
	if not ItemController.Inventory then
		return {}
	end

	return ItemController.Inventory
end

function ItemController:GetInventoryInStacks()
	--Returns inventory in stacks
	return ItemStacks, ItemLookup
end

function ItemController:GetToolTipDataFromItemData(itemData)
	--Gets tooltip data from itemdata
end

function ItemController:GetItemData(item)
	if not item then
		return nil
	end

	local data = ItemData:FindFirstChild(item)
	if not data then
		return nil
	end
	if not data:IsA("ModuleScript") then
		return nil
	end

	return require(data)
end

function ItemController:GetRarityData(rarity)
	if not rarity then
		return nil
	end

	local data = RarityData:FindFirstChild(rarity)
	if not data then
		return nil
	end

	if not data:IsA("ModuleScript") then
		return nil
	end

	return require(data)
end

function ItemController:GetItemFromId(id)
	local inventory = ItemController:GetInventory()

	return inventory[tostring(id)]
end

function ItemController:GetAllItemsWhichAreItem(item)
	local inventory = ItemController:GetInventory()

	local items = {}

	for id, data in inventory do
		if data.Item == item then
			items[id] = data
		end
	end

	return items
end

function ItemController:GetOneItemWhichIsItem(item)
	local inventory = ItemController:GetInventory()

	for id, data in inventory do
		if data.Item == item then
			return id, data
		end
	end
end

function ItemController:GetAllItemsWhichAreItemType(itemType)
	local inventory = ItemController:GetInventory()

	local items = {}

	for id, data in inventory do
		local itemdata = ItemController:GetItemData(data.Item)
		if not itemdata then
			continue
		end
		if itemdata.ItemType == itemType then
			items[id] = data
		end
	end

	return items
end

function ItemController:GetOneItemWhichIsItemType(itemType)
	local inventory = ItemController:GetInventory()

	for id, data in inventory do
		local itemdata = ItemController:GetItemData(data.Item)
		if not itemdata then
			continue
		end
		if itemdata.ItemType == itemType then
			return id, data
		end
	end
end

function ItemController:GetAllItemsWhichAreRarity(rarity)
	local inventory = ItemController:GetInventory()

	local items = {}

	for id, data in inventory do
		local itemdata = ItemController:GetItemData(data.Item)
		if not itemdata then
			continue
		end
		if itemdata.Rarity == rarity then
			items[id] = data
		end
	end

	return items
end

function ItemController:GetOneItemWhichIsRarity(rarity)
	local inventory = ItemController:GetInventory()

	for id, data in inventory do
		local itemdata = ItemController:GetItemData(data.Item)
		if not itemdata then
			continue
		end
		if itemdata.Rarity == rarity then
			return id, data
		end
	end
end

function ItemController:GetAllItemsWhichAreSeason(season)
	local inventory = ItemController:GetInventory()

	local items = {}

	for id, data in inventory do
		local itemdata = ItemController:GetItemData(data.Item)
		if not itemdata then
			continue
		end
		if itemdata.Season == season then
			items[id] = data
		end
	end

	return items
end

function ItemController:GetOneItemWhichIsSeason(season)
	local inventory = ItemController:GetInventory()

	for id, data in inventory do
		local itemdata = ItemController:GetItemData(data.Item)
		if not itemdata then
			continue
		end
		if itemdata.Season == season then
			return id, data
		end
	end
end

function ItemController:KnitStart() end

function ItemController:KnitInit()
	local ItemService = knit.GetService("ItemService")

	ItemService:GetPlayersInventory(LocalPlayer):andThen(function(inventory)
		ItemController.Inventory = inventory

		ItemStacks, ItemLookup = ItemStacksModule.GenerateStacks(inventory)
		print(ItemStacks)

		ItemController.Signals.InventoryLoaded:Fire()
		ItemController.Signals.StacksUpdated:Fire()
	end)

	ItemService.ItemAdded:Connect(function(items)
		if not ItemController.Inventory then
			ItemController.Inventory = {}
		end

		for id, data in items do
			ItemController.Inventory[id] = data
		end

		print(items)

		ItemStacksModule.ItemsAdded(ItemStacks, ItemLookup, items)

		ItemController.Signals.ItemAdded:Fire(items)
		ItemController.Signals.StacksUpdated:Fire()
	end)

	ItemService.ItemRemoved:Connect(function(items)
		if not ItemController.Inventory then
			ItemController.Inventory = {}
		end

		for _, id in items do
			ItemController.Inventory[id] = nil
		end

		ItemStacksModule.ItemsRemoved(ItemStacks, ItemLookup, items)

		ItemController.Signals.ItemRemoved:Fire(items)
		ItemController.Signals.StacksUpdated:Fire()
	end)
end

return ItemController
