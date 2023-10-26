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
    Client = {},
    Signals = {
    },
})

function ItemService:CreateData(item)
    --Creates data for item
    return HttpService:GenerateGUID(false), {
        Item = item,
        Date = DateTime.now().UnixTimestamp,
    }
end

function ItemService:GetItemFromInventory(inventory, item)
    local items = {}

    for id, data in inventory do
        if data.Item == item then
            items[id] = data
        end
    end

    return items
end

function ItemService:GetItemsOfType(inventory, itemType)
    local items = {}

    for id, data in inventory do
        local item = ItemService:GetDataForItem(data.Item)
        if not item then
            continue
        end

        if not (item.ItemType == itemType) then
            continue
        end

        items[id] = data
    end

    return items
end

function ItemService:GetItemsOfRarity(inventory, rarity)
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

function ItemService:GetDataForItem(item)
    return ItemData[item]
end

function ItemService:KnitStart()
end

function ItemService:KnitInit()
end

return ItemService