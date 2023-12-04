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

local ItemData = require(ReplicatedStorage.Data.ItemData)
local RarityData = require(ReplicatedStorage.Data.RarityData)

local ItemController = knit.CreateController({
	Name = "ItemController",
	Signals = {
		ItemAdded = signal.new(),
		ItemRemoved = signal.new(),

		InventoryLoaded = signal.new(),
	},

	Inventory = nil,
})

function ItemController:GetInventory()
	if not ItemController.Inventory then
		return {}
	end

	return ItemController.Inventory
end

function ItemController:GetToolTipDataFromItemData(itemData)
	--Gets tooltip data from itemdata
end

function ItemController:GetItemData(item)
	return ItemData[item]
end

function ItemController:GetRarityData(rarity)
	return RarityData[rarity]
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
		ItemController.Signals.InventoryLoaded:Fire()
	end)

	ItemService.ItemAdded:Connect(function(items)
		if not ItemController.Inventory then
			ItemController.Inventory = {}
		end

		for id, data in items do
			ItemController.Inventory[id] = data
		end

		ItemController.Signals.ItemAdded:Fire(items)
	end)

	ItemService.ItemRemoved:Connect(function(items)
		if not ItemController.Inventory then
			ItemController.Inventory = {}
		end

		for _, id in items do
			ItemController.Inventory[id] = nil
		end

		ItemController.Signals.ItemRemoved:Fire(items)
	end)
end

return ItemController
