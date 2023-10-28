--[[
ItemService
26, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local HttpService = game:GetService("HttpService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemData = require(ReplicatedStorage.Data.ItemData)

local ItemService = knit.CreateService({
    Name = 'ItemService',
    Client = {
        Inventory = knit.CreateProperty({}),
    },
    Signals = {
    },
})

function ItemService:GetItemData(item)
    return ItemData[item]
end

function ItemService:GetItemFromId(inventory, id)
    if not inventory[id] then
        return
    end

    return inventory[id].Item
end

function ItemService:CreateData(item)
    --Creates data for item
    return HttpService:GenerateGUID(false), {
        Item = item,
        Date = DateTime.now().UnixTimestamp,
    }
end

function ItemService:InventoryHasItem(inventory, item)
    if not ItemService:GetOneItemFromInventory(inventory, item) then
        return false
    end

    return true
end

function ItemService:GiveItemToInventory(inventory, item)
    --Check if item exists
    if not ItemData[item] then
        return nil
    end

    local id, data = ItemService:CreateData(item)

    inventory[id] = data

    return inventory
end

function ItemService:TakeItemFromInventory(inventory, item)
    if not ItemService:InventoryHasItem(inventory) then
        return nil
    end

    local id = ItemService:GetOneItemFromInventory(inventory, item)
    inventory[id] = nil
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
        if (not item) then
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

function ItemService:GetDataForItem(item)
    return ItemData[item]
end

function ItemService:GetOneItemOfUser(user, item)
    user:WaitForDataLoaded()

    return ItemService:GetOneItemFromInventory(user.Data.Inventory, item)
end

function ItemService:GetAllItemsOfUser(user, item)
    user:WaitForDataLoaded()

    return ItemService:GetAllItemsFromInventory(user.Data.Inventory, item)
end

function ItemService:GetAllItemsOfRarityFromUser(user, rarity)
    user:WaitForDataLoaded()

    return ItemService:GetAllItemsOfRarity(user.Data.Inventory, rarity)
end

function ItemService:GetOneItemOfRarityFromUser(user, rarity)
    user:WaitForDataLoaded()

    return ItemService:GetOneItemOfRarity(user.Data.Inventory, rarity)
end

function ItemService:GetAllItemsOfTypeFromUser(user, itemType)
    user:WaitForDataLoaded()

    return ItemService:GetAllItemsFromInventory(user.Data.Inventory, itemType)
end

function ItemService:GetOneItemOfTypeFromUser(user, itemType)
    user:WaitForDataLoaded()

    return ItemService:GetOneItemOfTypeFromInventory(user.Data.Inventory, itemType)
end

function ItemService:UserHasItem(user, item)
    user:WaitForDataLoaded()

    return ItemService:InventoryHasItem(user.Data.Inventory, item)
end

function ItemService:GiveUserItem(user, item)
    user:WaitForDataLoaded()

    ItemService:GiveItemToInventory(user.Data.Inventory, item)

    ItemService:SyncInventory(user)
end

function ItemService:TakeItemFromUser(user, item)
    user:WaitForDataLoaded()

    ItemService:TakeItemFromInventory(user.Data.Inventory, item)

    ItemService:SyncInventory(user)
end

function ItemService:GetUsersItemFromId(user, id)
    user:WaitForDataLoaded()

    return ItemService:GetItemFromId(user.Data.Inventory, id)
end

function ItemService:SyncInventory(user)
    user:WaitForDataLoaded()

    ItemService.Client.Inventory:SetFor(user.Player, user.Data.Inventory)
end

function ItemService:KnitStart()
end

function ItemService:KnitInit()
end

return ItemService