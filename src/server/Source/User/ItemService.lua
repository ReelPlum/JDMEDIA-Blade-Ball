--[[
ItemService
26, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemData = require(ReplicatedStorage.Data.ItemData)

local ItemService = knit.CreateService({
	Name = "ItemService",
	Client = {
		--Inventory = knit.CreateProperty({}),

		ItemAdded = knit.CreateSignal(),
		ItemRemoved = knit.CreateSignal(),
	},
	Signals = {
		ItemCreated = signal.new(),
		ItemDestroyed = signal.new(),
		UsersInventoryChanged = signal.new(),
	},
})

local InventoryCache = {}
local InventoryChangeSignals = {}

function ItemService.Client:GetPlayersInventory(player, requestedPlayer)
	--Get players inventory
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	return ItemService:GetUsersInventory(user)
end

function ItemService:GetItemData(item)
	return ItemData[item]
end

function ItemService:GetDataFromId(inventory, id)
	if not inventory[id] then
		return
	end

	return inventory[id]
end

function ItemService:GetItemFromId(inventory, id)
	if not inventory[id] then
		return
	end

	return inventory[id].Item
end

function ItemService:TransferItemToInventory(inventory, itemId, data)
	if inventory[itemId] then
		warn("❗Inventory already had a item with the id " .. itemId)
		return
	end

	inventory[itemId] = data

	return inventory
end

function ItemService:TransferMultipleItemsToInventory(inventory, items)
	for id, data in items do
		inventory[id] = data
	end

	return inventory
end

function ItemService:RemoveItemWithIdFromInventory(inventory, itemId)
	inventory[itemId] = nil
end

function ItemService:RemoveMultipleItemsWithIdFromInventory(inventory, ids)
	for _, id in ids do
		if not inventory[id] then
			return
		end
	end

	for _, id in ids do
		inventory[id] = nil
	end

	return true
end

function ItemService:GetMetadataFromItem(data)
	if not data.Metadata then
		return {}
	end

	return data.Metadata
end

function ItemService:CreateData(item, metadata)
	--Creates data for item
	return HttpService:GenerateGUID(false),
		{
			Item = item,
			Date = DateTime.now().UnixTimestamp,
			Metadata = metadata or {},
		}
end

function ItemService:InventoryHasItem(inventory, item)
	if not ItemService:GetOneItemFromInventory(inventory, item) then
		return false
	end

	return true
end

function ItemService:GiveItemToInventory(inventory, item, quantity, metadata)
	--Check if item exists
	if not ItemData[item] then
		warn("❗Item " .. item .. " was not found")
		return nil
	end

	local items = {}

	for _ = 1, quantity do
		local id, data = ItemService:CreateData(item, metadata)

		inventory[id] = data
		items[id] = data
	end

	ItemService.Signals.ItemCreated:Fire(item, quantity)

	return items
end

function ItemService:TakeItemFromInventory(inventory, itemId)
	ItemService.Signals.ItemDestroyed:Fire(inventory[itemId].Item, 1)

	inventory[itemId] = nil

	return inventory
end

function ItemService:GetAllItemsFromInventory(inventory, item)
	local items = {}

	for id, data in inventory do
		if data.Item == item then
			items[id] = data
		end
	end

	return items
end

function ItemService:GetOneItemFromInventory(inventory, item)
	for id, data in inventory do
		if data.Item == item then
			return id, data
		end
	end

	return nil
end

function ItemService:GetOneItemOfTypeFromInventory(inventory, itemType)
	--return ItemService:GetAllItemsOfTypeFromInventory(inventory, itemType)[1]
	for id, data in inventory do
		local item = ItemService:GetDataForItem(data.Item)
		if not item then
			continue
		end

		if not (item.ItemType == itemType) then
			continue
		end

		return id, data
	end

	return nil
end

function ItemService:GetAllItemsOfRarity(inventory, rarity)
	local items = {}

	for id, data in inventory do
		local item = ItemService:GetDataForItem(data.Item)
		if not item then
			continue
		end

		if not (item.Rarity == rarity) then
			continue
		end

		items[id] = data
	end

	return items
end

function ItemService:GetOneItemOfRarity(inventory, rarity)
	for id, data in inventory do
		local item = ItemService:GetDataForItem(data.Item)
		if not item then
			continue
		end

		if not (item.Rarity == rarity) then
			continue
		end

		return id, data
	end

	return nil
end

function ItemService:GetAllItemsOfSeason(inventory, season)
	local items = {}

	for id, data in inventory do
		local item = ItemService:GetDataForItem(data.Item)
		if not item then
			continue
		end

		if not (item.Season == season) then
			continue
		end

		items[id] = data
	end

	return items
end

function ItemService:GetOneItemOfSeason(inventory, season)
	for id, data in inventory do
		local item = ItemService:GetDataForItem(data.Item)
		if not item then
			continue
		end

		if not (item.Season == season) then
			continue
		end

		return id, data
	end

	return nil
end

function ItemService:GetDataForItem(item)
	return ItemData[item]
end

function ItemService:GetOneItemOfUser(user, item)
	user:WaitForDataLoaded()

	return ItemService:GetOneItemFromInventory(ItemService:GetUsersInventory(user), item)
end

function ItemService:GetAllItemsOfUser(user, item)
	user:WaitForDataLoaded()

	return ItemService:GetAllItemsFromInventory(ItemService:GetUsersInventory(user), item)
end

function ItemService:GetAllItemsOfRarityFromUser(user, rarity)
	user:WaitForDataLoaded()

	return ItemService:GetAllItemsOfRarity(ItemService:GetUsersInventory(user), rarity)
end

function ItemService:GetOneItemOfRarityFromUser(user, rarity)
	user:WaitForDataLoaded()

	return ItemService:GetOneItemOfRarity(ItemService:GetUsersInventory(user), rarity)
end

function ItemService:GetAllItemsOfTypeFromUser(user, itemType)
	user:WaitForDataLoaded()

	return ItemService:GetAllItemsFromInventory(ItemService:GetUsersInventory(user), itemType)
end

function ItemService:GetOneItemOfTypeFromUser(user, itemType)
	user:WaitForDataLoaded()

	return ItemService:GetOneItemOfTypeFromInventory(ItemService:GetUsersInventory(user), itemType)
end

function ItemService:GetAllItemsOfSeasonFromUser(user, season)
	user:WaitForDataLoaded()

	return ItemService:GetAllItemsOfSeason(ItemService:GetUsersInventory(user), season)
end

function ItemService:GetOneItemOfSeasonFromUser(user, season)
	user:WaitForDataLoaded()

	return ItemService:GetOneItemOfSeason(ItemService:GetUsersInventory(user), season)
end

function ItemService:UserHasItem(user, item)
	user:WaitForDataLoaded()

	return ItemService:InventoryHasItem(ItemService:GetUsersInventory(user), item)
end

function ItemService:GiveUserItem(user, item, quantity, metadata)
	user:WaitForDataLoaded()

	local inventory = ItemService:GetUsersInventory(user)
	local items = ItemService:GiveItemToInventory(inventory, item, quantity, metadata)
	ItemService:SaveInventory(user, inventory)

	ItemService.Client.ItemAdded:Fire(user.Player, items)
end

function ItemService:TakeItemFromUser(user, itemId)
	user:WaitForDataLoaded()

	if user.Locked then
		user.Signals.Unlocked:Wait()
	end

	local inventory = ItemService:GetUsersInventory(user)
	ItemService:TakeItemFromInventory(inventory, itemId)

	ItemService:SaveInventory(user, inventory)

	ItemService.Client.ItemRemoved:Fire(user.Player, { itemId })
end

function ItemService:GetUsersItemFromId(user, id)
	user:WaitForDataLoaded()

	return ItemService:GetItemFromId(ItemService:GetUsersInventory(user), id)
end

function ItemService:UpdateId(user, id, newData)
	local Inventory = ItemService:GetUsersInventory(user)
	Inventory[id] = newData

	ItemService:SaveInventory(user, Inventory)

	ItemService.Client.ItemAdded:Fire(user.Player, { [id] = newData })
end

function ItemService:GetUsersDataFromId(user, id)
	user:WaitForDataLoaded()

	return ItemService:GetDataFromId(ItemService:GetUsersInventory(user), id)
end

function ItemService:TransferItemToUsersInventory(user, itemId, data)
	local inventory = ItemService:GetUsersInventory(user)
	inventory = ItemService:TransferItemToInventory(inventory, itemId, data)

	self:SaveInventory(user, inventory)
	ItemService.Client.ItemAdded:Fire(user.Player, { itemId })
end

function ItemService:TransferMultipleItemsToUsersInventory(user, items)
	local inventory = ItemService:GetUsersInventory(user)
	inventory = ItemService:TransferMultipleItemsToInventory(inventory, items)

	self:SaveInventory(user, inventory)

	ItemService.Client.ItemAdded:Fire(user.Player, items)
end

function ItemService:RemoveItemWithIdFromUsersInventory(user, itemId)
	local inventory = ItemService:GetUsersInventory(user)
	ItemService:RemoveItemWithIdFromInventory(inventory, itemId)

	self:SaveInventory(user, inventory)

	ItemService.Client.ItemRemoved:Fire(user.Player, { itemId })
end

function ItemService:RemoveMultipleItemsWithIdFromUsersInventory(user, ids)
	local inventory = ItemService:GetUsersInventory(user)
	local success = ItemService:RemoveMultipleItemsWithIdFromInventory(inventory, ids)

	self:SaveInventory(user, inventory)

	if success then
		ItemService.Client.ItemRemoved:Fire(user.Player, ids)
	end

	return success
end

function ItemService:GiveUserMultipleItems(user, items, metadata)
	local inventory = ItemService:GetUsersInventory(user)

	local addedItems = {}
	for item, quantity in items do
		local i = ItemService:GiveItemToInventory(inventory, item, quantity, metadata)
		for id, data in i do
			addedItems[id] = data
		end
	end

	self:SaveInventory(user, inventory)
	ItemService.Client.ItemAdded:Fire(user.Player, addedItems)
end

function ItemService:GetUsersInventory(user)
	user:WaitForDataLoaded()

	if InventoryCache[user] then
		return InventoryCache[user]
	end

	if not user.Data.Inventory then
		return {}
	end

	local DataCompressionService = knit.GetService("DataCompressionService")

	local inv = HttpService:JSONDecode(DataCompressionService:DecompressData(user.Data.Inventory))

	InventoryCache[user] = inv
	return inv
end

function ItemService:SaveInventory(user, inventory)
	local DataCompressionService = knit.GetService("DataCompressionService")

	user.Data.Inventory = DataCompressionService:CompressData(HttpService:JSONEncode(inventory))
end

-- function ItemService:SyncInventory(user)
-- 	user:WaitForDataLoaded()

-- 	InventoryChangeSignals[user]:Fire()
-- 	ItemService.Client.Inventory:SetFor(user.Player, ItemService:GetUsersInventory(user))

-- 	ItemService.Signals.UsersInventoryChanged:Fire(user)
-- end

function ItemService:ListenForUserInventoryChange(user)
	return InventoryChangeSignals[user]
end

function ItemService:KnitStart()
	local UserService = knit.GetService("UserService")

	UserService.Signals.UserAdded:Connect(function(user)
		InventoryChangeSignals[user] = signal.new()
	end)

	UserService.Signals.UserRemoving:Connect(function(user)
		InventoryCache[user] = nil

		InventoryChangeSignals[user]:Destroy()
		InventoryChangeSignals[user] = nil
	end)
end

function ItemService:KnitInit() end

return ItemService
