--[[
ItemContainer
2023, 12, 14
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Item = require(script.Parent.Item)

local ItemContainer = {}
ItemContainer.ClassName = "ItemContainer"
ItemContainer.__index = ItemContainer

function ItemContainer.new(ui, itemTemplate, testing)
	local self = setmetatable({}, ItemContainer)

	self.Janitor = janitor.new()

	self.UI = ui
	self.ItemTemplate = itemTemplate

	self.OnClick = nil
	self.OnRightClick = nil

	self.GetInteractionMenuData = nil
	self.ShouldBeEnabled = nil
	self.ShouldBeShown = nil
	self.GetStackSize = nil
	self.GetSortScore = nil
	self.ItemTypes = nil
	self.SearchTerm = nil
	self.EquippedItems = {}
	self.Testing = testing

	self.GetItemInformation = nil

	self.Lookup = {}
	self.Stacks = {}

	self.Locked = false
	self.Items = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	return self
end

function ItemContainer:Init() end

function ItemContainer:UpdateItemTypes(newItemTypes, calledByUpdateItemStacks)
	self.ItemTypes = newItemTypes

	if not self.Stacks then
		return
	end

	if not calledByUpdateItemStacks then
		self:UpdateWithStacks(self.Stacks, self.Lookup)
		return
	end

	--Go through and hide / shown items with / without item types
	for id, ui in self.Items do
		if not ui.ItemData then
			continue
		end

		if not self.ItemTypes then
			continue
		end

		if table.find(self.ItemTypes, ui.ItemData.ItemType) then
			continue
		end

		ui:Destroy()
		self.Items[id] = nil
	end
end

function ItemContainer:UpdateShouldBeShown(newFunction)
	self.ShouldBeShown = newFunction

	if not self.Stacks then
		return
	end

	--Go through and hide / show current items
	for id, stackData in self.Stacks do
		if not self.Items[id] then
			continue
		end

		if not self.ShouldBeShown then
			self.Items[id]:SetVisible(true)
			continue
		end

		self.Items[id]:SetVisible(self.ShouldBeShown(stackData.Data))
	end
end

function ItemContainer:UpdateShouldBeEnabled(newFunction)
	self.ShouldBeEnabled = newFunction

	if not self.Stacks then
		return
	end

	--Go through and enable / disable current items
	for id, stackData in self.Stacks do
		if not self.Items[id] then
			continue
		end

		if not self.ShouldBeEnabled then
			self.Items[id]:SetEnabled(true)
			continue
		end

		self.Items[id]:SetEnabled(self.ShouldBeEnabled(stackData.Data))
	end
end

function ItemContainer:UpdateSearchTerm(newSearchTerm, calledByUpdateItemStacks)
	self.SearchTerm = newSearchTerm

	if not calledByUpdateItemStacks then
		self:UpdateWithStacks(self.Stacks, self.Lookup)
	end

	if not newSearchTerm then
		return
	end

	for id, ui in self.Items do
		if not ui.ItemData then
			continue
		end

		if not string.find(ui.ItemData.DisplayName:lower(), self.SearchTerm:lower()) then
			ui:Destroy()
			self.Items[id] = nil
			continue
		end
	end
end

function ItemContainer:UpdateWithStacks(stacks, lookup)
	--Update with new stacks
	self.Stacks = stacks or {}
	self.Lookup = lookup

	if not self.GetItemInformation then
		return warn("❗Get item information not found!")
	end

	local newItems = {}

	for id, stackData in stacks do
		local item = stackData.Data.Item

		local itemData = self.GetItemInformation(item)
		if not itemData then
			continue
		end

		if self.ItemTypes then
			if not table.find(self.ItemTypes, itemData.ItemType) then
				continue
			end
		end

		if self.Items[id] then
			newItems[id] = self.Items[id]
			self.Items[id] = nil

			--Update
			newItems[id]:UpdateData(stackData.Data)
			newItems[id]:UpdateWithItemData(itemData)

			if self.GetStackSize then
				newItems[id]:UpdateStack(self.GetStackSize(stackData))
			else
				newItems[id]:UpdateStack(#stackData.Hold)
			end

			continue
		end

		local createdItem = self:CreateItemFromData(id, stackData.Data)
		if not createdItem then
			continue
		end

		newItems[id] = self.Janitor:Add(createdItem)
		if self.GetStackSize then
			newItems[id]:UpdateStack(self.GetStackSize(stackData))
		else
			newItems[id]:UpdateStack(#stackData.Hold)
		end
	end

	--Destroy old items
	for id, item in self.Items do
		item:Destroy()
		self.Items[id] = nil
	end

	self.Items = newItems

	self:UpdateShouldBeEnabled(self.ShouldBeEnabled)
	self:UpdateShouldBeShown(self.ShouldBeShown)
	self:UpdateEquippedItems(self.EquippedItems)
	self:UpdateItemTypes(self.ItemTypes, true)
	self:UpdateSort(self.CurrentSort)
	self:UpdateSearchTerm(self.SearchTerm, true)
end

function ItemContainer:UpdateSort(newSort)
	self.CurrentSort = newSort

	if not newSort then
		return
	end

	for _, ui in self.Items do
		local data = ui.Data
		ui:SetLayoutOrder(newSort(data, self))
	end
end

function ItemContainer:UpdateEquippedItems(newEquippedItems)
	--Go through items and find equipped items.

	if not self.Lookup then
		self.EquippedItems = newEquippedItems
		return
	end

	if self.EquippedItems then
		for _, id in self.EquippedItems do
			if not self.Lookup[id] then
				continue
			end

			if not self.Items[self.Lookup[id]] then
				continue
			end

			if not newEquippedItems then
				self.Items[self.Lookup[id]]:SetEquipped(false)
				continue
			end

			if not table.find(newEquippedItems, id) then
				self.Items[self.Lookup[id]]:SetEquipped(false)
				continue
			end
		end
	end

	self.EquippedItems = newEquippedItems

	if not self.EquippedItems then
		return
	end

	for _, id in self.EquippedItems do
		print(id)
		if not self.Lookup[id] then
			continue
		end

		if not self.Items[self.Lookup[id]] then
			continue
		end

		self.Items[self.Lookup[id]]:SetEquipped(true)
	end
end

function ItemContainer:CreateItemFromData(id, data)
	local item = data.Item

	if not self.GetItemInformation then
		return warn("❗Get item information not found!")
	end

	local itemData = self.GetItemInformation(item)
	if not itemData then
		return
	end

	local newItem = self.Janitor:Add(Item.new(self.ItemTemplate, self.UI, true))
	newItem:UpdateData(data)
	newItem:UpdateWithItemData(itemData)
	newItem.OnClick = function()
		if not self.Stacks[id] then
			return
		end

		self.OnClick(self.Stacks[id].Hold, data)
	end
	newItem.OnRightClick = function()
		if not self.Stacks[id] then
			return
		end

		self.OnRightClick(self.Stacks[id].Hold, data)
	end

	return newItem
end

function ItemContainer:SetLocked(bool)
	if bool == nil then
		bool = not self.Locked
	end

	self.Locked = bool

	--Lock / unlock
end

function ItemContainer:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return ItemContainer
