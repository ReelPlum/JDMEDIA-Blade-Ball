--[[
ItemController
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ItemData = require(ReplicatedStorage.Data.ItemData)

local ItemController = knit.CreateController({
	Name = "ItemController",
	Signals = {},
})

function ItemController:GetInventory()
	local CacheController = knit.GetController("CacheController")

	if not CacheController.Cache.Inventory then
		return {}
	end

	return CacheController.Cache.Inventory
end

function ItemController:GetItemData(item)
	return ItemData[item]
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

function ItemController:KnitInit() end

return ItemController
