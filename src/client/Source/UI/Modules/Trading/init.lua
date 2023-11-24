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

local ItemsContainer = require(script.Parent.Common.ItemsContainer)

local Trading = {}
Trading.ClassName = "Trading"
Trading.__index = Trading

function Trading.new(UITemplate)
	local self = setmetatable({}, Trading)

	self.Janitor = janitor.new()

	self.UITemplate = UITemplate

	self.Inventories = {}

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

	self.ItemsContainerLocal =
		self.Janitor:Add(ItemsContainer.new(self.UI.Frame.Trade.Frame.LocalPlayer.Frame.ScrollingFrame, {}, function(id)
			--Remove item from trade
			warn(id)
			TradingController:RemoveItemFromCurrentTrade(id)
		end))
	self.ItemsContainerB =
		self.Janitor:Add(ItemsContainer.new(self.UI.Frame.Trade.Frame.OtherPlayer.Frame.ScrollingFrame, {}, function()
			return
		end))
	self.Inventory = self.Janitor:Add(
		ItemsContainer.new(self.UI.Frame.Inventory.Frame.Inventory.Holder.ScrollingFrame, {}, function(id)
			--Add item to trade
			warn(id)
			TradingController:AddItemToCurrentTrade(id)
		end)
	)

	--Buttons
	self.Janitor:Add(self.UI.Frame.Inventory.Frame.Buttons.Holder.Accept.MouseButton1Click:Connect(function()
		--Trade
		warn("Accept")

		TradingController:SetStatusForCurrentTrade(true)
	end))
	self.Janitor:Add(self.UI.Frame.Inventory.Frame.Buttons.Holder.Unaccept.MouseButton1Click:Connect(function()
		--UNaccept
		TradingController:SetStatusForCurrentTrade(false)
	end))

	self.Janitor:Add(self.UI.Frame.Inventory.Frame.Buttons.Holder.Cancel.MouseButton1Click:Connect(function()
		--Cancel trade
		warn("Cancel trade")

		TradingController:CancelCurrentTrade()
	end))

	--Listen for trade staring & ending
	warn("Listening")

	self.Janitor:Add(TradingController.Signals.TradeStarted:Connect(function()
		self:Update()

		self:SetVisible(true)
	end))
	self.Janitor:Add(TradingController.Signals.TradeEnded:Connect(function()
		self:SetVisible(false)
		self:Reset()
	end))

	--Listen for updates
	warn("For updates")
	self.Janitor:Add(TradingController.Signals.StatusChanged:Connect(function()
		self:UpdateStatus()
	end))

	self.Janitor:Add(TradingController.Signals.InventoryUpdated:Connect(function()
		self:UpdateInventories()
	end))

	self.Janitor:Add(ItemController.Signals.InventoryChanged:Connect(function()
		self:UpdateInventories()
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

local function GetItems(items, inventory)
	--Return wanted items from inventory
	local wantedItems = {}

	for _, id in items do
		if not inventory[id] then
			continue
		end

		wantedItems[id] = inventory[id]
	end

	return wantedItems
end

function Trading:GetPlayersInventory()
	local TradingController = knit.GetController("TradingController")
	local inv = TradingController:GetTradeableItems()

	local tradeData = TradingController:GetItemsInCurrentTrade()

	local items = {}

	for id, data in inv do
		if table.find(tradeData.LocalInventory, tostring(id)) then
			continue
		end

		items[id] = data
	end

	return items
end

function Trading:UpdateInventories()
	--Update inventories
	local TradingController = knit.GetController("TradingController")
	local ItemController = knit.GetController("ItemController")

	local tradeData = TradingController:GetItemsInCurrentTrade()
	local otherInv = TradingController:GetOtherInv()

	if not tradeData.LocalInventory or not tradeData.InventoryB then
		return
	end
	--Update Inventory
	self.Inventory:Update(self:GetPlayersInventory())

	--Update local players items
	self.ItemsContainerLocal:Update(GetItems(tradeData.LocalInventory or {}, ItemController:GetInventory()))

	--Update other players items
	self.ItemsContainerB:Update(GetItems(tradeData.InventoryB or {}, otherInv))

	--Set name of other player
	local otherPlayer = Players:GetPlayerByUserId(tonumber(tradeData.OtherPlayer or 0))

	if otherPlayer then
		self.UI.Frame.Trade.Frame.OtherPlayer.Frame.Info.PlayerName.Text = `{otherPlayer.DisplayName}`
	end
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
	--Update all the data for the trade
	self:UpdateStatus()
	self:UpdateInventories()
	self:UpdateTimer()

	--Update with other players name
end

function Trading:Reset()
	--Reset everything
	self.ItemsContainerLocal:Update({})
	self.ItemsContainerB:Update({})
	self.Inventory:Update({})
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
