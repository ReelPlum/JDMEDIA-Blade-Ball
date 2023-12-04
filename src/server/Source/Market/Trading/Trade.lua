--[[
Trade
2023, 11, 05
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local Trade = {}
Trade.ClassName = "Trade"
Trade.__index = Trade

function Trade.new(userA, userB)
	local self = setmetatable({}, Trade)

	self.Janitor = janitor.new()

	self.Id = HttpService:GenerateGUID(false)

	self.UserA = userA
	self.UserB = userB

	self.Status = {
		[self.UserA] = false,
		[self.UserB] = false,
	}
	self.Inventories = {
		[self.UserA] = {},
		[self.UserB] = {},
	}

	self.Ready = false
	self.Time = nil

	self.UserA.CurrentTrade = self
	self.UserB.CurrentTrade = self

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),

		TradeAcceptanceStatusChanged = self.Janitor:Add(signal.new()),
		TradeTimerChanged = self.Janitor:Add(signal.new()),
		TradeInventoryChanged = self.Janitor:Add(signal.new()), --Fired on items added or removed from either inventory A or B
		TradeCompleted = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Trade:Init()
	local UserService = knit.GetService("UserService")
	local ItemService = knit.GetService("ItemService")
	local TradingService = knit.GetService("TradingService")
	local UserService = knit.GetService("UserService")

	--Initialize trade for clients
	for _, user in { self.UserA, self.UserB } do
		UserService:SetUserAFK(user, true)

		TradingService.Client.TradeId:SetFor(user.Player, self.Id)
		TradingService.Client.CurrentTrade:SetFor(user.Player, {
			OtherPlayer = if user == self.UserA then self.UserB.Player.UserId else self.UserA.Player.UserId,
			LocalInventory = self.Inventories[user],
			InventoryB = if self.UserA == user then self.Inventories[self.UserB] else self.Inventories[self.UserA],
		})
		TradingService.Client.TradeStatus:SetFor(user.Player, {
			false,
			false,
		})

		local otherInv = {}
		if user == self.UserA then
			otherInv = ItemService:GetUsersInventory(self.UserB)
		else
			otherInv = ItemService:GetUsersInventory(self.UserA)
		end
		TradingService.Client.OtherInventory:SetFor(user.Player, otherInv)
	end

	--Detect for user leave.
	--Cancel trade
	self.Janitor:Add(UserService.Signals.UserRemoving:Connect(function(user)
		if user == self.UserA or user == self.UserB then
			self:Cancel(user)
		end
	end))

	--Detect for user inventory updates
	--If users inventory changes and the user for some reason doesnt have a item that is in the trade, then remove that item from the trade.
	self.Janitor:Add(ItemService:ListenForUserInventoryChange(self.UserA):Connect(function()
		--Check inventory
		if self.Completed then
			return
		end

		TradingService.Client.OtherInventory:SetFor(self.UserB.Player, ItemService:GetUsersInventory(self.UserA))

		for _, id in self.Inventories[self.UserA] do
			if not ItemService:GetUsersItemFromId(self.UserA, id) then
				self:RemoveItem(self.UserA, id)
			end
		end
	end))
	self.Janitor:Add(ItemService:ListenForUserInventoryChange(self.UserB):Connect(function()
		--Check inventory
		if self.Completed then
			return
		end

		TradingService.Client.OtherInventory:SetFor(self.UserA.Player, ItemService:GetUsersInventory(self.UserB))

		for _, id in self.Inventories[self.UserB] do
			if not ItemService:GetUsersItemFromId(self.UserB, id) then
				self:RemoveItem(self.UserB, id)
			end
		end
	end))

	--Detect acceptance status change
	--If both accepted then start timer
	self.Janitor:Add(self.Signals.TradeAcceptanceStatusChanged:Connect(function()
		--Check
		for _, status in self.Status do
			if not status then
				self.Ready = false
				self.Time = nil
				return
			end
		end

		self.Time = tick()
		self.Ready = true
	end))

	--Detect for items adding / removing
	--Set acceptance of players to false
	self.Janitor:Add(self.Signals.TradeInventoryChanged:Connect(function(user)
		--Set both to unready
		self:SetAcceptanceStatus(self.UserA, false)
		self:SetAcceptanceStatus(self.UserB, false)
	end))

	--Handle timer here
	self.Janitor:Add(RunService.Heartbeat:Connect(function()
		--Check timer
		if not self.Ready then
			return
		end

		--Check time
		if tick() - self.Time < GeneralSettings.User.Trade.AcceptanceTime then
			return
		end

		--It's tiiiiiiiiiimmmmme!
		self:Complete()
	end))
end

function Trade:Complete()
	--Completes trade and gives both users their items.
	if self.Cancelled then
		return
	end

	self.Completed = true
	self.UserA:Lock()
	self.UserB:Lock()

	self.Signals.TradeCompleted:Fire()

	--Save items
	local ItemService = knit.GetService("ItemService")
	local InventoryCopies = {}

	for user, inventory in self.Inventories do
		local inv = {}
		for _, id in inventory do
			local data = ItemService:GetUsersDataFromId(user, id)
			inv[id] = data
		end

		InventoryCopies[user] = inv
	end

	--Take items from boths users' inventories
	local successfullUsers = {}
	local FailedUser = nil
	for user, ids in self.Inventories do
		local success = ItemService:RemoveMultipleItemsWithIdFromUsersInventory(user, ids)
		if success then
			table.insert(successfullUsers, user)
		else
			FailedUser = user
			break
		end
	end

	if FailedUser then
		for _, user in successfullUsers do
			--Give them their old stuff back
			local inv = InventoryCopies[user]
			ItemService:TransferMultipleItemsToUsersInventory(user, inv)
		end

		self.Completed = false

		warn("❗Failed with user " .. FailedUser.Player.Name)

		self:Cancel(FailedUser)
		return
	end

	--Give items
	for user, inv in InventoryCopies do
		local to = if user == self.UserA then self.UserB else self.UserA
		ItemService:TransferMultipleItemsToUsersInventory(to, inv)
	end

	--Save trade in logs on both users. (In a compressed format so it doesnt take up much space)
	local TradingService = knit.GetService("TradingService")
	TradingService:AddTradeToUsersHistory(
		self.UserA,
		self.UserB,
		self.Id,
		self.Inventories[self.UserA],
		self.Inventories[self.UserB]
	)

	--Destroy trade
	self:Destroy()
end

function Trade:GetItem(itemId)
	--Gets item with Id from trade.
	local index = nil
	local owner = nil

	for user, inventory in self.Inventories do
		index = table.find(inventory, itemId)
		if index then
			owner = user
			break
		end
	end
	if not index then
		return
	end

	--If item is found, then return data from owners inventory, and owner.
	local ItemService = knit.GetService("ItemService")
	local data = ItemService:GetUsersDataFromId(itemId)

	if not data then
		return --Data is not there for some reason?
	end

	return owner, data
end

function Trade:AddItem(user, itemId)
	--Adds item from users inventory with id
	local ItemService = knit.GetService("ItemService")
	local TradingService = knit.GetService("TradingService")

	if not TradingService:ValidateItemForTrade(user, itemId) then
		warn("❗Invalid")
		return
	end

	--Check if item can be added
	if not ItemService:GetUsersItemFromId(user, itemId) then
		warn("❗Cannot be added because not in inv")
		return
	end

	if self:GetItem(itemId) then
		warn("❗Item already added")
		return
	end

	--Add item to users inventory
	table.insert(self.Inventories[user], itemId)

	--Update clients
	self.Signals.TradeInventoryChanged:Fire(user)

	for _, u in { self.UserA, self.UserB } do
		TradingService.Client.CurrentTrade:SetFor(u.Player, {
			OtherPlayer = if u == self.UserA then self.UserB.Player.UserId else self.UserA.Player.UserId,
			LocalInventory = self.Inventories[u],
			InventoryB = if self.UserA == u then self.Inventories[self.UserB] else self.Inventories[self.UserA],
		})
	end
end

function Trade:RemoveItem(user, itemId)
	--Removes item with id
	local TradingService = knit.GetService("TradingService")

	local index = table.find(self.Inventories[user], itemId)
	if not index then
		return
	end

	table.remove(self.Inventories[user], index)

	--Update clients
	self.Signals.TradeInventoryChanged:Fire(user)

	for _, u in { self.UserA, self.UserB } do
		TradingService.Client.CurrentTrade:SetFor(u.Player, {
			OtherPlayer = if u == self.UserA then self.UserB.Player.UserId else self.UserA.Player.UserId,
			LocalInventory = self.Inventories[u],
			InventoryB = if self.UserA == u then self.Inventories[self.UserB] else self.Inventories[self.UserA],
		})
	end
end

function Trade:SetAcceptanceStatus(user, status)
	--Set trade acceptance status for user
	self.Status[user] = status

	--Update clients
	self.Signals.TradeAcceptanceStatusChanged:Fire(user)
	local TradingService = knit.GetService("TradingService")
	TradingService.Client.TradeStatus:SetFor(self.UserA.Player, {
		self.Status[self.UserA],
		self.Status[self.UserB],
	})
	TradingService.Client.TradeStatus:SetFor(self.UserB.Player, {
		self.Status[self.UserB],
		self.Status[self.UserA],
	})
end

function Trade:Cancel(user)
	if self.Completed then
		return
	end
	self.Cancelled = true

	--Tell other player user cancelled

	--Cancels trade and destroys it.
	self:Destroy()
end

function Trade:Destroy()
	self.UserA.CurrentTrade = nil
	self.UserB.CurrentTrade = nil
	self.UserA:Lock(false)
	self.UserB:Lock(false)

	--Tell clients the trade is finished
	local TradingService = knit.GetService("TradingService")
	local UserService = knit.GetService("UserService")

	for _, user in { self.UserA, self.UserB } do
		UserService:SetUserAFK(user, false)
		TradingService.Client.TradeId:SetFor(user.Player, nil)
		TradingService.Client.CurrentTrade:SetFor(user.Player, {})
		TradingService.Client.TradeStatus:SetFor(user.Player, {})
		TradingService.Client.OtherInventory:SetFor(user.Player, {})
	end

	--Unregister trade
	TradingService:UnregisterTrade(self.Id)

	--Destroy
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Trade
