--[[
Trading
2023, 11, 15
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemStacksModule = require(ReplicatedStorage.Common.ItemsStacks)

local Interactions = require(script.Interactions)

local ToolTip = require(script.Parent.Common.ToolTip)
local ItemContainer = require(script.Parent.Common.ItemContainer)
local ItemInteractionMenu = require(script.Parent.Common.ItemInteractionMenu)

local Trading = {}
Trading.ClassName = "Trading"
Trading.__index = Trading

function Trading.new(template, parent)
	local self = setmetatable({}, Trading)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Inventories = {
		Local = {},
		Other = {},
	}

	local localStacks, localLookup = ItemStacksModule.GenerateStacks({})
	local otherStacks, otherLookup = ItemStacksModule.GenerateStacks({})

	self.ItemStacks = {
		Local = localStacks,
		Other = otherStacks,
	}

	self.ItemLookups = {
		Local = localLookup,
		Other = otherLookup,
	}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		VisibilityChanged = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Trading:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	self.ToolTip = self.Janitor:Add(ToolTip.new(self.Parent))

	local Config = self.UI.Config
	self.LocalInventoryUI = Config.LocalInventory.Value
	self.OtherInventoryUI = Config.OtherInventory.Value
	self.ItemInventory = Config.ItemInventory.Value
	self.AcceptButton = Config.AcceptButton.Value
	self.UnAcceptButton = Config.UnAcceptButton.Value
	self.CancelButton = Config.CancelButton.Value
	self.TimerLabel = Config.Timer.Value
	self.OtherPlayerName = Config.OtherPlayerName.Value
	self.OtherAccepted = Config.OtherAccepted.Value

	self.InteractionMenu =
		self.Janitor:Add(ItemInteractionMenu.new(ReplicatedStorage.Assets.UI.ItemInteractionMenu, self.Parent))

	local TradingController = knit.GetController("TradingController")
	local ItemController = knit.GetController("ItemController")

	self.ItemsContainerLocal =
		self.Janitor:Add(ItemContainer.new(self.LocalInventoryUI, ReplicatedStorage.Assets.UI.Item, self.ToolTip))
	self.Janitor:Add(self.InteractionMenu.Signals.VisibilityChanged:Connect(function(bool)
		self.ToolTip:Disable(bool)
	end))

	--
	self.ItemsContainerLocal.GetItemInformation = function(item)
		local ItemController = knit.GetController("ItemController")
		return ItemController:GetItemData(item)
	end
	self.ItemsContainerLocal.OnClick = function(ids, data)
		--Remove item from trade
		--TradingController:RemoveItemFromCurrentTrade(id)
		for _, id in ids do
			if self.Inventories.Local[id] then
				TradingController:RemoveItemFromCurrentTrade(id)
				break
			end
		end
	end
	self.ItemsContainerLocal.OnRightClick = function(ids, data)
		--Show interaction menu
		local pos = UserInputService:GetMouseLocation()

		local ItemController = knit.GetController("ItemController")
		local itemData = ItemController:GetItemData(data.Item)

		local interactions = {}
		for index, interaction in Interactions.Remove do
			if not interaction.Check(data, itemData, ids) then
				continue
			end

			table.insert(interactions, interaction)
		end

		--Show interaction frame
		self.InteractionMenu:SetData(interactions, ids, UDim2.new(0, pos.X, 0, pos.Y), data)
	end

	--[[
	function(_, ids)
			--Remove item from trade
			--TradingController:RemoveItemFromCurrentTrade(id)
			for _, id in ids do
				if self.Inventories.Local[id] then
					TradingController:RemoveItemFromCurrentTrade(id)
					break
				end
			end
		end),
		nil,
		nil
	]]
	self.ItemsContainerB = self.Janitor:Add(
		ItemContainer.new(self.OtherInventoryUI, ReplicatedStorage.Assets.UI.Item, self.ToolTip, false)
	)
	self.ItemsContainerB.GetItemInformation = function(item)
		local ItemController = knit.GetController("ItemController")
		return ItemController:GetItemData(item)
	end

	self.Inventory =
		self.Janitor:Add(ItemContainer.new(self.ItemInventory, ReplicatedStorage.Assets.UI.Item, self.ToolTip, false))
	self.Inventory.OnClick = function(ids, data)
		--Add item to trade
		for _, id in ids do
			if not self.Inventories.Local[id] then
				TradingController:AddItemToCurrentTrade(id)
				break
			end
		end

		self.Inventory:UpdateStackSizes(self.Inventory.GetStackSize)
	end
	self.Inventory:UpdateShouldBeEnabled(function(data)
		return TradingController:IsItemTradeable(data)
	end)
	self.Inventory.GetStackSize = function(stackData)
		--Check if item has been added
		local n = 0
		for _, id in stackData.Hold do
			if self.Inventories.Local[id] then
				n += 1
			end
		end
		return #stackData.Hold - n
	end
	self.Inventory.OnRightClick = function(ids, data)
		--Show interaction menu
		local pos = UserInputService:GetMouseLocation()

		local ItemController = knit.GetController("ItemController")
		local itemData = ItemController:GetItemData(data.Item)

		local newIds = {}

		for _, id in ids do
			if self.Inventories.Local[id] then
				continue
			end
			table.insert(newIds, id)
		end

		local interactions = {}
		for index, interaction in Interactions.Add do
			if not interaction.Check(data, itemData, newIds) then
				continue
			end

			table.insert(interactions, interaction)
		end

		print(interactions)
		--Show interaction frame
		self.InteractionMenu:SetData(interactions, newIds, UDim2.new(0, pos.X, 0, pos.Y), data)
	end
	self.Inventory.GetItemInformation = function(item)
		local ItemController = knit.GetController("ItemController")
		return ItemController:GetItemData(item)
	end

	--Buttons
	self.Janitor:Add(self.AcceptButton.MouseButton1Click:Connect(function()
		--Trade

		TradingController:SetStatusForCurrentTrade(true)
	end))
	self.Janitor:Add(self.UnAcceptButton.MouseButton1Click:Connect(function()
		--UNaccept
		TradingController:SetStatusForCurrentTrade(false)
	end))

	self.Janitor:Add(self.CancelButton.MouseButton1Click:Connect(function()
		--Cancel trade

		TradingController:CancelCurrentTrade()
	end))

	--Listen for trade staring & ending
	self.Janitor:Add(TradingController.Signals.TradeStarted:Connect(function()
		self:Update()

		self:SetVisible(true)
	end))
	self.Janitor:Add(TradingController.Signals.TradeEnded:Connect(function()
		self:SetVisible(false)
		self:Reset()
	end))

	--Listen for updates
	self.Janitor:Add(TradingController.Signals.StatusChanged:Connect(function()
		self:UpdateStatus()
	end))

	self.Janitor:Add(TradingController.Signals.ItemsAdded:Connect(function(isLocalPlayer, items)
		--If is local player then it is only ids
		local invCache = nil
		local stacks = nil
		local lookup = nil
		local addedItems = {}

		if isLocalPlayer then
			invCache = self.Inventories.Local
			stacks = self.ItemStacks.Local
			lookup = self.ItemLookups.Local
		else
			invCache = self.Inventories.Other
			stacks = self.ItemStacks.Other
			lookup = self.ItemLookups.Other
		end

		if isLocalPlayer then
			--Update stacks etc.
			local localInv = ItemController:GetInventory()

			for _, id in items do
				--Get data and add it
				local data = localInv[id]
				invCache[id] = data
				addedItems[id] = data
			end
		else
			for id, data in items do
				--Get data and add it
				invCache[id] = data
			end
			addedItems = items
		end

		--Update stacks and lookup
		ItemStacksModule.ItemsAdded(stacks, lookup, addedItems)

		self.ItemsContainerLocal:UpdateWithStacks(self.ItemStacks.Local, self.ItemLookups.Local)
		self.ItemsContainerB:UpdateWithStacks(self.ItemStacks.Other, self.ItemLookups.Other)
		self.Inventory:UpdateWithStacks(ItemController:GetInventoryInStacks())
	end))

	self.Janitor:Add(TradingController.Signals.ItemsRemoved:Connect(function(isLocalPlayer, items)
		warn("Items removed")
		local invCache = nil
		local stacks = nil
		local lookup = nil

		if isLocalPlayer then
			invCache = self.Inventories.Local
			stacks = self.ItemStacks.Local
			lookup = self.ItemLookups.Local
		else
			invCache = self.Inventories.Other
			stacks = self.ItemStacks.Other
			lookup = self.ItemLookups.Other
		end

		for _, id in items do
			--Get data and remove it
			invCache[id] = nil
		end

		--Update stacks and lookup
		ItemStacksModule.ItemsRemoved(stacks, lookup, items)

		self.ItemsContainerLocal:UpdateWithStacks(self.ItemStacks.Local, self.ItemLookups.Local)
		self.ItemsContainerB:UpdateWithStacks(self.ItemStacks.Other, self.ItemLookups.Other)
		self.Inventory:UpdateWithStacks(ItemController:GetInventoryInStacks())
	end))

	self.Janitor:Add(ItemController.Signals.StacksUpdated:Connect(function()
		--Update Inventory
		self.Inventory:UpdateWithStacks(ItemController:GetInventoryInStacks())
	end))

	--Listen for timer change
	self.Janitor:Add(TradingController.Signals.TimerUpdated:Connect(function()
		self:UpdateTimer()
	end))

	self:SetVisible(false)
end

function Trading:UpdateTimer()
	--Updates timer if both players have accepted
	local TradingController = knit.GetController("TradingController")

	local t = TradingController:GetTimer()

	if not t then
		--Hide timer
		self.TimerLabel.Visible = false

		return
	end
	--Show timer and set text formatted
	self.TimerLabel.Text = string.format("%0.2fs", t)
	self.TimerLabel.Visible = true
end

function Trading:UpdateStatus()
	--Update the statuses for the traders
	local TradingController = knit.GetController("TradingController")

	self.TimerLabel.Visible = false

	local statuses = TradingController:GetStatuses()
	if statuses[1] then
		--Localplayer accepted. Show unaccpet button
		self.AcceptButton.Visible = false
		self.UnAcceptButton.Visible = true
	else
		--Show accept button
		self.AcceptButton.Visible = true
		self.UnAcceptButton.Visible = false
	end

	if statuses[2] then
		--Other player accepted
		self.OtherAccepted.Visible = true
	else
		--Hide accepted text
		self.OtherAccepted.Visible = false
	end
end

function Trading:Update()
	local ItemController = knit.GetController("ItemController")

	--Update all the data for the trade
	self:UpdateStatus()
	self:UpdateTimer()

	warn("Update")
	self.Inventory:UpdateWithStacks(ItemController:GetInventoryInStacks())

	--Update with other players name
end

function Trading:Reset()
	--Reset everything
	self.Inventories = {
		Local = {},
		Other = {},
	}

	self.ItemStacks = {
		Local = {},
		Other = {},
	}

	self.ItemLookups = {
		Local = {},
		Other = {},
	}

	self.ItemsContainerLocal:UpdateWithStacks(self.ItemStacks.Local, self.ItemLookups.Local)
	self.ItemsContainerB:UpdateWithStacks(self.ItemStacks.Other, self.ItemLookups.Other)
end

function Trading:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = bool

	self.Signals.VisibilityChanged:Fire(bool)
end

function Trading:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Trading
