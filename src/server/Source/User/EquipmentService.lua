--[[
EquipmentService
27, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local EquipmentService = knit.CreateService({
    Name = 'EquipmentService',
    Client = {
        EquippedItems = knit.CreateProperty({}),
    },
    Signals = {
    },
})


local function Update(user)
    --Update user when new item is equipped
    EquipmentService.Client.EquippedItems:SetFor(user, user.Data.Equipped)

    local ItemService = knit.GetService("ItemService")

    if not user.LastEquipment then
        user.LastEquipment = {}
    end

    --Equip new knife.
    if user.LastEquipment.Knife ~= user.Data.Equipped["Knife"] then
        user.ExtendedCharacter:EquipKnife(ItemService:GetUsersItemFromId(user.Data.Equipped["Knife"]))
    end

    user.LastEquipment = user.Data.Equipped
end

local function SetupUser(user)
    --Check if user has equipped anything
    user:WaitForDataLoaded()

    local ItemService = knit.GetService("ItemService")
    for _, item in GeneralSettings.User.DefaultEquippedItems do
        local data = ItemService:GetItemData(item)
        if not data then
            warn("The default equipped item "..item.." could not be found...")
        end

        if EquipmentService:GetEquippedItemOfType(user, data.ItemType) then
            continue
        end

        EquipmentService:EquipItem(user, item)
    end

    --Load equipment on user
    Update(user)

    EquipmentService.Client.EquippedItems:SetFor(user.Player, user.Data.EquippedItems)
end

function EquipmentService:EquipItem(user, item)
    user:WaitForDataLoaded()

    local ItemService = knit.GetService("ItemService")
    local id = ItemService:GetOneItemOfUser(user, item)
    if not id then
        return
    end

    local data = ItemService:GetItemData(item)
    if not data then
        return
    end

    user.Data.Equipped[data.ItemType] = id

    Update(user)
end

function EquipmentService:GetEquippedItemOfType(user, type)
    user:WaitForDataLoaded()

    local ItemService = knit.GetService("ItemService")

    return 
end

function EquipmentService:KnitStart()
    local UserService = knit.GetService("UserService")
    for _, user in UserService:GetUsers() do
        SetupUser(user)
    end

    UserService.Signals.UserAdded:Connect(SetupUser)
end

function EquipmentService:KnitInit()
end

return EquipmentService