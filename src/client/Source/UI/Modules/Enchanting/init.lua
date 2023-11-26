--[[
init
25, 11, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemsContainer = require(script.Parent.Common.ItemsContainer)
local Item = require(script.Parent.Common.Item)
local ToolTip = require(script.Parent.Common.ToolTip)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local Enchanting = {}
Enchanting.ClassName = 'Enchanting'
Enchanting.__index = Enchanting

function Enchanting.new(uiTemplate)
    local self = setmetatable({}, Enchanting)
    
    self.Janitor = janitor.new()
    
    self.UITemplate = uiTemplate

    self.SelectedBook = nil
    self.SelectedItem = nil

    self.Signals = {
        Destroying = self.Janitor:Add(signal.new()),
    }
    
    
    return self
end

function Enchanting:Init()
    self.UI = self.Janitor:Add(self.UITemplate:Clone())
    self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

    self.ToolTip = ToolTip.new(self.UI)

    --Enchants item UI
    self.CombinedBookItemDisplay = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
        --Unselect
        self:UnselectItem(self.SelectedBook)
    end, self.ToolTip))
    --Parent, size and position

    self.CombinedKnifeItemDisplay = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
        self:UnselectItem(self.SelectedKnife)
    end, self.ToolTip))
    --Parent, size and position

    self.RandomKnifeItemDisplay = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
        self:UnselectItem(self.SelectedKnife)
    end, self.ToolTip))
    --Parent, size and position

    self.CraftedCombinedItem = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
        self:UnselectItem(self.SelectedKnife)
    end, self.ToolTip))
    --Parent, size and position

    self.CraftedRandomItem = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
        self:UnselectItem(self.SelectedKnife)
    end, self.ToolTip))
    --Parent, size and position

    --Setup inventory
    local ItemController = knit.GetController("ItemController")

    self.Pages = {
        ["Combine"] = {ui = self.UI.Frame.Frame.CombineEnchants, itemTypes = {"Book", "Knife"}},
        ["Random"] = {ui = self.UI.Frame.Frame.Enchant, itemTypes = {"Knife"}},
        ["Default"] = {ui = self.UI.Frame.Frame.NoSelection, itemTypes = {"Knife", "Book"}}
    }
    
    self.ItemContainer = self.Janitor:Add(ItemsContainer.new(self.UI.Frame.Frame.Inventory.ScrollingFrame, ItemController:GetInventory(), function(id)
        --Check if book or knife.
        self:SelectItem(id)
    end,{self.Pages.Default.itemTypes}, function(data)
        local itemData = ItemController:GetDataForItem(data.Item)

        if not data.Metadata then
            return false
        end

        if data.Metadata[MetadataTypes.Types.Enchant] and itemData.ItemType == "Book" then
            return true
        end

        if not data.Metadata[MetadataTypes.Types.Enchant] and itemData.ItemType == "Knife" then
            return true
        end

        return false


    end))

    self.Janitor:Add(ItemController.Signals.InventoryChanged:Connect(function()
        self.ItemContainer:Update(ItemController:GetInventory())
        --self:Update()
    end))

    --Buttons
    local EnchantingService = knit.GetService("EnchantingService")

    self.Janitor:Add(self.Pages.Combine.Combine.MouseButton1Click:Connect(function()
        --Combine
    end))

    self.Janitor:Add(self.Pages.Random.Enchant.MouseButton1Click:Connect(function()
        
    end))

    self.Janitor:Add(self.Pages.Combine.Continue.MouseButton1Click:Connect(function()
        
    end))

    self.Janitor:Add(self.Pages.Random.Continue.MouseButton1Click:Connect(function()
        
    end))

    self:ChangePage("Default")
end

function Enchanting:ChangePage(page)
    for name, data in self.Pages do
        if string.lower(name) == string.lower(page) then
            data.ui.Visible = true
            self.ItemContainer:UpdateItemTypes(data.itemTypes)

            continue
        end
        data.ui.Visible = false
    end

    self:Update()
    self.CurrentPage = page
end

function Enchanting:Update()
    local ItemController = knit.GetController("ItemController")

    --Check if selected items are still in player's inventory
    if not ItemController:GetItemFromId(self.SelectedBook) and self.SelectedBook ~= nil then
        self:UnselectItem(self.SelectedBook)
    end
    if not ItemController:GetItemFromId(self.SelectedKnife) and self.SelectedKnife ~= nil then
        self:UnselectItem(self.SelectedKnife)
    end

    local SelectedBookData = ItemController:GetItemFromId(self.SelectedBook)
    local SelectedKnifeData = ItemController:GetItemFromId(self.SelectedKnife)

    self.CraftedCombinedItem.UI.Visible = false
    self.CraftedRandomItem.UI.Visible = true

    --Update items displayed on positions
    if not self.SelectedBook then
        --Hide selected book displays
        self.CombinedBookItemDisplay:Update(SelectedBookData)
        self.CombinedBookItemDisplay.UI.Visible = false
    else
        --Show selected book displays
        self.CombinedBookItemDisplay:Update(SelectedBookData)
        self.CombinedBookItemDisplay.UI.Visible = true
    end

    if not self.SelectedKnife then
        --Hide selected knife displays
        self.RandomKnifeItemDisplay:Update(SelectedKnifeData)
        self.CombinedKnifeItemDisplay:Update(SelectedKnifeData)
        self.RandomKnifeItemDisplay.UI.Visible = false
        self.CombinedKnifeItemDisplay.UI.Visible = false
    else
        --Show selected knife displays
        self.RandomKnifeItemDisplay:Update(SelectedKnifeData)
        self.CombinedKnifeItemDisplay:Update(SelectedKnifeData)
        self.RandomKnifeItemDisplay.UI.Visible = true
        self.CombinedKnifeItemDisplay.UI.Visible = true
    end
end

function Enchanting:Combine(newItemId)
    local ItemController = knit.GetController("ItemController")

    --Remove selected item displays
    local SelectedBookData = ItemController:GetItemFromId(self.SelectedBook)
    local SelectedKnifeData = ItemController:GetItemFromId(self.SelectedKnife)

    self.RandomKnifeItemDisplay:Update(SelectedKnifeData)
    self.CombinedKnifeItemDisplay:Update(SelectedKnifeData)
    self.RandomKnifeItemDisplay.UI.Visible = false
    self.CombinedKnifeItemDisplay.UI.Visible = false

    self.CombinedBookItemDisplay:Update(SelectedBookData)
    self.CombinedBookItemDisplay.UI.Visible = false

    --Add new combined item on combine slot
    local data = ItemController:GetItemFromId(newItemId)
    self.CraftedCombinedItem:Update(data)
    self.CraftedCombinedItem.UI.Visible = true

    --Show continue button
    self.Pages.Combine.Combine.Visible = false
    self.Pages.Combine.Continue.Visible = true
end

function Enchanting:RandomEnchant(newItemId)
    local ItemController = knit.GetController("ItemController")
    
    --Remove selected items
    local SelectedBookData = ItemController:GetItemFromId(self.SelectedBook)
    local SelectedKnifeData = ItemController:GetItemFromId(self.SelectedKnife)

    self.RandomKnifeItemDisplay:Update(SelectedKnifeData)
    self.CombinedKnifeItemDisplay:Update(SelectedKnifeData)
    self.RandomKnifeItemDisplay.UI.Visible = false
    self.CombinedKnifeItemDisplay.UI.Visible = false

    self.CombinedBookItemDisplay:Update(SelectedBookData)
    self.CombinedBookItemDisplay.UI.Visible = false

    --Add new combined item on combine slot
    local data = ItemController:GetItemFromId(newItemId)
    self.CraftedRandomItem:Update(data)
    self.CraftedRandomItem.Visible = true

    --Show continue button
    self.Pages["Random"].Continue.Visible = true
    self.Pages.Random.Enchant.Visible = false
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

    local itemData = ItemController:GetDataForItem(data.Item)
    if not itemData then
        return
    end


    if itemData.ItemType == "Knife" then
        if self.SelectedKnife then
            return
        end

        self.SelectedKnife = id

        if not self.SelectedBook then
            self:ChangePage("Random")
        end

        return
    end

    if itemData.ItemType == "Book" then
        if self.SelectedBook then
            return
        end

        self.SelectedBook = id


        self:ChangePage("Combine")
    end
end

function Enchanting:UnselectItem(id)
    local ItemController = knit.GetController("ItemController")
    local data = ItemController:GetItemFromId(id)
    if not data then
        return
    end

    local itemData = ItemController:GetDataForItem(data.Item)
    if not itemData then
        return
    end

    --Unselect items
    if itemData.ItemType == "Knife" and self.SelectedKnife == id then
        --Unselect
        self.SelectedKnife = nil
    elseif itemData.ItemType == "Book" and self.SelectedBook == id then
        --Unselect
        self.SelectedBook = nil
    end

    if not self.SelectedBook and not self.SelectedKnife then
        self:ChangePage("Default")
    elseif self.SelectedBook and not self.SelectedKnife then
        self:ChangePage("Combine")
    elseif not self.SelectedBook and self.SelectedKnife then
        self:ChangePage("Combine")
    end

    self:Update()
end

function Enchanting:SetVisible(bool)
    if bool == nil then
        bool = not self.Visible
    end

    self:Update()
    self.Visible = bool
end

function Enchanting:Destroy()
    self.Signals.Destroying:Fire()
    self.Janitor:Destroy()
    self = nil
end

return Enchanting