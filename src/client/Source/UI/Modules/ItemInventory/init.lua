--[[
init
2023, 11, 03
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemsContainer = require(script.Parent.Common.ItemsContainer)
local Item = require(script.Parent.Common.Item)

local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(UITemplate)
	local self = setmetatable({}, Inventory)

	self.Janitor = janitor.new()

	self.UITemplate = UITemplate

	self.SelectedItemId = nil

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Inventory:Init()
	local ItemController = knit.GetController("ItemController")
	local EquipmentController = knit.GetController("EquipmentController")

	self.UI = self.Janitor:Add(self.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

	self.ItemsContainer = self.Janitor:Add(ItemsContainer.new(self.UI.Frame.Inventory.Container, {}, function(id)
		--Select item
		self:SelectItem(id)
	end, "Knife"))

	self.SelectedItem = self.Janitor:Add(Item.new(ReplicatedStorage.Assets.UI.Item, nil, function()
		return
	end, self.ItemsContainer.ToolTip))
	self.SelectedItem.UI.Parent = self.UI.Frame.EquippedItems.Frame.Frame

	--Equip button
	self.Janitor:Add(self.UI.Frame.EquippedItems.Equip.MouseButton1Click:Connect(function()
		--Equip item
		if not self.SelectedItemId then
			return
		end

		EquipmentController:EquipItem(self.SelectedItemId)
	end))

	--Listen for inventory changes
	self.Janitor:Add(ItemController.Signals.InventoryChanged:Connect(function()
		self:Update()
	end))

	self.Janitor:Add(EquipmentController.Signals.EquipmentChanged:Connect(function()
		self:CheckIfSelectedItemIsEquipped()
	end))

	self:Update()
end

function Inventory:SelectItem(itemId)
	local ItemController = knit.GetController("ItemController")

	local itemData = ItemController:GetItemFromId(itemId)
	if not itemData then
		return
	end

	self.SelectedItemId = itemId
	self.SelectedItem:Update(itemData)
	self:CheckIfSelectedItemIsEquipped()
end

function Inventory:CheckIfSelectedItemIsEquipped()
	local EquipmentController = knit.GetController("EquipmentController")

	if EquipmentController:GetEquippedItemForType("Knife") ~= self.SelectedItemId then
		self.UI.Frame.EquippedItems.Equip.Visible = true
		self.UI.Frame.EquippedItems.Unequip.Visible = false
		return
	end
	self.SelectedItemIsEquipped = true

	--It is the equipped item
	self.UI.Frame.EquippedItems.Equip.Visible = false
	self.UI.Frame.EquippedItems.Unequip.Visible = true
end

function Inventory:Update()
	--Update items
	local ItemController = knit.GetController("ItemController")
	local EquipmentController = knit.GetController("EquipmentController")

	local inventoryData = ItemController:GetInventory()

	warn(inventoryData)
	self.ItemsContainer:Update(inventoryData)

	--Update equipped items
	if self.ItemsContainer.CreatedItems[self.SelectedItemId] and self.SelectedItemId ~= nil then
		self:SelectItem(self.SelectedItemId)
		return
	end

	local equippedItem = EquipmentController:GetEquippedItemForType("Knife")
	warn(EquipmentController:GetEquippedItems())
	warn(equippedItem)
	if not equippedItem then
		return
	end
	self:SelectItem(equippedItem)
end

function Inventory:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Inventory
