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

local ItemData = ReplicatedStorage.Data.Items
local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

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

		ItemAdded = signal.new(),
		ItemRemoved = signal.new(),
	},
})

local InventoryCache = {}
local InventoryChangeSignals = {}

function ItemService.Client:GetPlayersInventory(player, requestedPlayer)
	--Get players inventory
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	user:WaitForDataLoaded()

	return ItemService:GetUsersInventory(user)
end

function ItemService:GetItemData(item)
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

	local metadata = data.Metadata

	if data.Item then
		metadata = table.clone(data.Metadata)
		local itemData = ItemService:GetDataForItem(data.Item)
		if not itemData then
			return metadata
		end

		if itemData.Metadata then
			for index, value in itemData.Metadata do
				if metadata[index] then
					continue
				end 
				metadata[index] = value
			end
		end
	end


	return metadata
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

	ItemService.Signals.ItemCreated:Fire(item, quantity, metadata)

	return items
end

function ItemService:TakeItemFromInventory(inventory, itemId)
	local metadata = nil
	if inventory[itemId] then
		metadata = inventory[itemId].Metadata
	end

	ItemService.Signals.ItemDestroyed:Fire(inventory[itemId].Item, 1, metadata)

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
	return ItemService:GetItemData(item)
end

function ItemService:CanUserRecieveItem(user, item)
	local itemData = ItemService:GetDataForItem(item)
	if not itemData then
		return false
	end

	if not itemData.OneCopyAllowed then
		return true
	end

	if ItemService:UserHasItem(user, item) then
		return false
	end

	return true
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

	if not ItemService:DoesUserHaveSpaceForItems(user, quantity) then
		return false
	end

	if not ItemService:CanUserRecieveItem(user, item) then
		return false
	end

	local inventory = ItemService:GetUsersInventory(user)
	local items = ItemService:GiveItemToInventory(inventory, item, quantity, metadata)
	ItemService:SaveInventory(user, inventory)
	user.Data.ItemsInInventory += quantity

	ItemService.Client.ItemAdded:Fire(user.Player, items)
	ItemService.Signals.ItemAdded:Fire(user, item)

	return items
end

function ItemService:TakeItemFromUser(user, itemId)
	user:WaitForDataLoaded()

	if user.Locked then
		user.Signals.Unlocked:Wait()
	end

	local inventory = ItemService:GetUsersInventory(user)
	ItemService:TakeItemFromInventory(inventory, itemId)

	ItemService:SaveInventory(user, inventory)

	user.Data.ItemsInInventory -= 1
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

	if not ItemService:DoesUserHaveSpaceForItems(user, 1) then
		return false
	end

	if not ItemService:CanUserRecieveItem(user, data.Item) then
		return false
	end

	inventory = ItemService:TransferItemToInventory(inventory, itemId, data)

	self:SaveInventory(user, inventory)
	user.Data.ItemsInInventory += 1
	ItemService.Client.ItemAdded:Fire(user.Player, { itemId })
	ItemService.Signals.ItemAdded:Fire(user, data.Item)
end

function ItemService:TransferMultipleItemsToUsersInventory(user, items)
	local n = 0
	for _, data in items do
		n += 1
		
		if not ItemService:CanUserRecieveItem(data.Item) then
			return false
		end
	end

	if not ItemService:DoesUserHaveSpaceForItems(user, n) then
		return false
	end

	local inventory = ItemService:GetUsersInventory(user)
	inventory = ItemService:TransferMultipleItemsToInventory(inventory, items)

	self:SaveInventory(user, inventory)

	user.Data.ItemsInInventory += n
	ItemService.Client.ItemAdded:Fire(user.Player, items)

	for _, data in items do
		ItemService.Signals.ItemAdded:Fire(user, data.Item)
	end
end

function ItemService:RemoveItemWithIdFromUsersInventory(user, itemId)
	local inventory = ItemService:GetUsersInventory(user)
	ItemService:RemoveItemWithIdFromInventory(inventory, itemId)

	self:SaveInventory(user, inventory)

	user.Data.ItemsInInventory -= 1
	ItemService.Client.ItemRemoved:Fire(user.Player, { itemId })
end

function ItemService:RemoveMultipleItemsWithIdFromUsersInventory(user, ids)
	local inventory = ItemService:GetUsersInventory(user)
	local success = ItemService:RemoveMultipleItemsWithIdFromInventory(inventory, ids)

	self:SaveInventory(user, inventory)

	if success then
		ItemService.Client.ItemRemoved:Fire(user.Player, ids)

		local n = 0
		for _, _ in ids do
			n += 1
		end

		user.Data.ItemsInInventory -= n
	end

	return success
end

function ItemService:GiveUserMultipleItems(user, items, metadata)
	local inventory = ItemService:GetUsersInventory(user)

	local n = 0
	for item, quantity in items do
		n += quantity

		if not ItemService:CanUserRecieveItem(user, item) then
			return
		end
	end
	if not ItemService:DoesUserHaveSpaceForItems(user, n) then
		return false
	end

	local addedItems = {}
	for item, quantity in items do
		local i = ItemService:GiveItemToInventory(inventory, item, quantity, metadata)
		ItemService.Signals.ItemAdded:Fire(user, item)
		for id, data in i do
			addedItems[id] = data
		end
	end
	user.Data.ItemsInInventory += n

	self:SaveInventory(user, inventory)
	ItemService.Client.ItemAdded:Fire(user.Player, addedItems)
end

function ItemService:GetUsersInventory(user)
	if InventoryCache[user] then
		return InventoryCache[user]
	end

	if not user.Data.Inventory then
		return {}
	end

	local DataCompressionService = knit.GetService("DataCompressionService")

	local inv = DataCompressionService:DecompressData(user.Data.Inventory)

	InventoryCache[user] = inv
	return inv
end

function ItemService:SaveInventory(user, inventory)
	local DataCompressionService = knit.GetService("DataCompressionService")

	user.Data.Inventory = DataCompressionService:CompressData(inventory)
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

function ItemService:DoesUserHaveSpaceForItems(user, quantity)
	user:WaitForDataLoaded()

	if user.Data.ItemsInInventory + quantity > GeneralSettings.User.MaxInventoryItems then
		return false
	end

	return true
end

function ItemService:KnitStart()
	local UserService = knit.GetService("UserService")

	UserService.Signals.UserAdded:Connect(function(user)
		InventoryChangeSignals[user] = signal.new()
	end)

	UserService.Signals.UserRemoving:Connect(function(user)
		InventoryCache[user] = nil

		if not InventoryChangeSignals[user] then
			return
		end

		InventoryChangeSignals[user]:Destroy()
		InventoryChangeSignals[user] = nil
	end)
end

function ItemService:KnitInit() end

return ItemService
