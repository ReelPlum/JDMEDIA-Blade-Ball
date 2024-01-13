--[[
Trading
2023, 11, 15
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ItemStacksModule = require(ReplicatedStorage.Common.ItemsStacks)

local ItemsContainer = require(script.Parent.Common.ItemsContainer)

local Trading = {}
Trading.ClassName = "Trading"
Trading.__index = Trading

function Trading.new(UITemplate)
	local self = setmetatable({}, Trading)

	self.Janitor = janitor.new()

	self.UITemplate = UITemplate

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
	--Initialize trading
	local TradingController = knit.GetController("TradingController")
	local ItemController = knit.GetController("ItemController")

	self.UI = self.Janitor:Add(self.UITemplate:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

	self.ItemsContainerLocal = self.Janitor:Add(
		ItemsContainer.new(self.UI.Frame.Trade.Frame.LocalPlayer.Frame.ScrollingFrame, {}, function(_, ids)
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
	)
	self.ItemsContainerB = self.Janitor:Add(
		ItemsContainer.new(self.UI.Frame.Trade.Frame.OtherPlayer.Frame.ScrollingFrame, {}, function()
			return
		end),
		nil,
		nil
	)
	self.Inventory = self.Janitor:Add(
		ItemsContainer.new(
			self.UI.Frame.Inventory.Frame.Inventory.Holder.ScrollingFrame,
			{},
			function(_, ids)
				--Add item to trade
				for _, id in ids do
					if not self.Inventories.Local[id] then
						TradingController:AddItemToCurrentTrade(id)
						break
					end
				end
			end,
			nil,
			function(stackData, stackId, itemLookup)
				if not TradingController:IsItemTradeable(stackData.Data) then
					return false
				end

				--Check if item has been added
				local n = 0
				for id, _ in self.Inventories.Local do
					warn(id)
					if itemLookup[id] then
						if itemLookup[id].StackId == stackId then
							n += 1
						end
					end
				end
				if n > 0 then
					return false, -n
				end

				return true
			end
		)
	)

	--Buttons
	self.Janitor:Add(self.UI.Frame.Inventory.Frame.Buttons.Holder.Accept.MouseButton1Click:Connect(function()
		--Trade

		TradingController:SetStatusForCurrentTrade(true)
	end))
	self.Janitor:Add(self.UI.Frame.Inventory.Frame.Buttons.Holder.Unaccept.MouseButton1Click:Connect(function()
		--UNaccept
		TradingController:SetStatusForCurrentTrade(false)
	end))

	self.Janitor:Add(self.UI.Frame.Inventory.Frame.Buttons.Holder.Cancel.MouseButton1Click:Connect(function()
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
		warn("Items ADded")
		print(isLocalPlayer)

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
				print(id)
				invCache[id] = data
			end
			addedItems = items
		end

		print(addedItems)
		print(lookup)
		print(stacks)

		--Update stacks and lookup
		ItemStacksModule.ItemsAdded(stacks, lookup, addedItems)

		self.ItemsContainerLocal:Update(self.ItemStacks.Local, self.ItemLookups.Local)
		self.ItemsContainerB:Update(self.ItemStacks.Other, self.ItemLookups.Other)
		self.Inventory:Update(ItemController:GetInventoryInStacks())
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

		self.ItemsContainerLocal:Update(self.ItemStacks.Local, self.ItemLookups.Local)
		self.ItemsContainerB:Update(self.ItemStacks.Other, self.ItemLookups.Other)
		self.Inventory:Update(ItemController:GetInventoryInStacks())
	end))

	self.Janitor:Add(ItemController.Signals.StacksUpdated:Connect(function()
		--Update Inventory
		self.Inventory:Update(ItemController:GetInventoryInStacks())
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
		self.UI.Frame.Trade.Frame.LocalPlayer.Frame.Time.Visible = false

		return
	end
	--Show timer and set text formatted
	self.UI.Frame.Trade.Frame.LocalPlayer.Frame.Time.Text = string.format("%0.2fs", t)
	self.UI.Frame.Trade.Frame.LocalPlayer.Frame.Time.Visible = true
end

function Trading:UpdateStatus()
	--Update the statuses for the traders
	local TradingController = knit.GetController("TradingController")

	self.UI.Frame.Trade.Frame.LocalPlayer.Frame.Time.Visible = false

	local statuses = TradingController:GetStatuses()
	if statuses[1] then
		--Localplayer accepted. Show unaccpet button
		self.UI.Frame.Inventory.Frame.Buttons.Holder.Accept.Visible = false
		self.UI.Frame.Inventory.Frame.Buttons.Holder.Unaccept.Visible = true
	else
		--Show accept button
		self.UI.Frame.Inventory.Frame.Buttons.Holder.Accept.Visible = true
		self.UI.Frame.Inventory.Frame.Buttons.Holder.Unaccept.Visible = false
	end

	if statuses[2] then
		--Other player accepted
		self.UI.Frame.Trade.Frame.OtherPlayer.Frame.Info.Accepted.Visible = true
	else
		--Hide accepted text
		self.UI.Frame.Trade.Frame.OtherPlayer.Frame.Info.Accepted.Visible = false
	end
end

function Trading:Update()
	local ItemController = knit.GetController("ItemController")

	--Update all the data for the trade
	self:UpdateStatus()
	self:UpdateTimer()

	warn("Update")
	self.Inventory:Update(ItemController:GetInventoryInStacks())

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

	self.ItemsContainerLocal:Update(self.ItemStacks.Local, self.ItemLookups.Local)
	self.ItemsContainerB:Update(self.ItemStacks.Other, self.ItemLookups.Other)
end

function Trading:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Enabled = bool

	self.Signals.VisibilityChanged:Fire(bool)
end

function Trading:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Trading
