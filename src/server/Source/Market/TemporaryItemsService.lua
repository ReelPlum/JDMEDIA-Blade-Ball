--[[
TemporaryItemsService
2024, 01, 12
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local TemporaryItemsService = knit.CreateService({
	Name = "TemporaryItemsService",
	Client = {},
	Signals = {},
})

function TemporaryItemsService:GiveTemporaryItem(user, item, quantity, metadata, ID)
	--Gives user temporary item

	if not ID then
		ID = HttpService:GenerateGUID(false)
	end

	user:WaitForDataLoaded()

	local fullMetadata = {
		[MetadataTypes.Types.Untradeable] = true,
	}

	for index, value in metadata do
		if fullMetadata[index] then
			continue
		end

		fullMetadata[index] = value
	end

	local ItemService = knit.GetService("ItemService")
	local addedItems = ItemService:GiveUserItem(user, item, quantity, fullMetadata)
	if not addedItems then
		return
	end

	if not user.Data.TemporaryItems[ID] then
		user.Data.TemporaryItems[ID] = {}
	end

	for id, _ in addedItems do
		user.Data.TemporaryItems[ID][id] = item
	end

	return ID
end

function TemporaryItemsService:GetTemporaryItemsWithID(user, ID)
	user:WaitForDataLoaded()

	return user.Data.TemporaryItems[ID]
end

function TemporaryItemsService:RemoveAllTemporaryItemsWithID(user, ID)
	user:WaitForDataLoaded()

	--Remove all items under id
	local ItemService = knit.GetService("ItemService")

	local items = TemporaryItemsService:GetTemporaryItemsWithID(user, ID)
	for id, item in items do
		ItemService:RemoveItemWithIdFromUsersInventory(user, id)
	end

	user.Data.TemporaryItems[ID] = nil
end

function TemporaryItemsService:RemoveItemFromTemporaryItems(user, ID, itemId)
	user:WaitForDataLoaded()

	--Remove item under id
	local ItemService = knit.GetService("ItemService")

	local items = TemporaryItemsService:GetTemporaryItemsWithID(user, ID)
	ItemService:RemoveItemWithIdFromUsersInventory(user, itemId)
	items[itemId] = nil
end

function TemporaryItemsService:KnitStart() end

function TemporaryItemsService:KnitInit() end

return TemporaryItemsService
