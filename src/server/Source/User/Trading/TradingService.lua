--[[
TradingService
2023, 11, 05
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Trade = require(script.Parent.Trade)

local TradingService = knit.CreateService({
	Name = "TradingService",
	Client = {
		CurrentTrade = knit.CreateProperty({}),
		TradeStatus = knit.CreateProperty({}),
		TradeId = knit.CreateProperty(nil),
		OtherInventory = knit.CreateProperty({}), --Inventory of the user player is trading with

		TradeRequests = knit.CreateProperty({}),
	},
	Signals = {},
})

local TradeRequests = {}
local Trades = {}

function TradingService:UserIsTrading(user)
	--Check if user is currently trading
	if TradingService:GetUsersCurrentTrade(user) then
		return true
	end

	return false
end

function TradingService:GetUsersCurrentTrade(user)
	--Returns users current trade
	return user.CurrentTrade
end

function TradingService:UserCanSendTradeRequestToUser(userA, userB)
	--Check for users settings, and if they accept trade requests currently.

	return true
end

function TradingService:RequestTrade(userA, userB)
	if not TradeRequests[userB] then
		TradeRequests[userB] = {}
	end

	if not TradingService:UserCanSendTradeRequestToUser(userA, userB) then
		--Notify UserA

		return
	end

	--Check if UserA already sent a request
	for _, trade in TradeRequests[userB] do
		if trade.RequestingUser == userA.Player.UserId then
			--Notify UserA

			return
		end
	end

	--Request trade.
	local id = HttpService:GenerateGUID(false)

	local request = {
		RequestingUser = userA.Player.UserId,
		Time = DateTime.now().UnixTimestamp,
	}

	TradeRequests[userB][id] = request

	TradingService.Client.TradeRequests:SetFor(userB.Player, TradeRequests[userB])
end

function TradingService:AcceptTradeRequest(userB, tradeId)
	--Accepts trade with Id
	if not TradeRequests[userB] then
		return
	end

	if not TradeRequests[userB][tradeId] then
		return
	end

	--Get UserA
	local UserService = knit.GetService("UserService")
	local userA = UserService:GetUserFromUserId(TradeRequests[userB][tradeId].RequestingUser)
	if not userA then
		TradeRequests[userB][tradeId] = nil
		return
	end

	--Checks are done. Now we start the trade!
	TradingService:StartTrade(userA, userB)

	TradeRequests[userB][tradeId] = nil
	TradingService.Client.TradeRequests:SetFor(userB.Player, TradeRequests[userB])
end

function TradingService:DeclineTradeRequest(userB, tradeId)
	--Declines trade request
	if not TradeRequests[userB] then
		return
	end

	if not TradeRequests[userB][tradeId] then
		return
	end

	TradeRequests[userB][tradeId] = nil

	TradingService.Client.TradeRequests:SetFor(userB.Player, TradeRequests[userB])
end

function TradingService:StartTrade(userA, userB)
	if userA.CurrentTrade or userB.CurrentTrade then
		return
	end

	--Starts a trade between userA and userB
	local t = Trade.new(userA, userB)

	Trades[t.Id] = t
	return t
end

function TradingService:UnregisterTrade(tradeId)
	--Unregister trade from memory. Fired on completion or on trade cancelation
	if not Trades[tradeId] then
		return
	end

	Trades[tradeId] = nil
end

function TradingService:SetTradeAcceptanceStatus(user, status)
	--Sets users current trade acceptance status
	if not user.CurrentTrade then
		return
	end

	user.CurrentTrade:SetTradeAcceptanceStatus(user, status)
end

function TradingService:CancelTrade(user)
	--Cancels trade and gets user out of trade
	if not user.CurrentTrade then
		return
	end

	user.CurrentTrade:Cancel(user)
end

function TradingService:AddItemToTrade(user, itemId)
	--Adds item with Id to trade
	if not user.CurrentTrade then
		return
	end

	user.CurrentTrade:AddItem(user, itemId)
end

function TradingService:ValidateItemForTrade(item)
	--Validates if item can be used in trade
end

function TradingService:RemoveItemFromTrade(user, itemId)
	--Removes item from trade
	if not user.CurrentTrade then
		return
	end

	user.CurrentTrade:RemoveItem(user, itemId)
end

local TradeHistory = {}
function TradingService:GetUsersTradeHistory(user)
	if TradeHistory[user] then
		return TradeHistory[user]
	end

	user:WaitForDataLoaded()

	if not user.Data.TradeHistory then
		return {}
	end

	--Uncompress trade history
	local DataCompressionService = knit.GetService("DataCompressionService")
	local uncompressed = DataCompressionService:DecompressData(user.Data.TradeHistory)
	if not uncompressed then
		return {}
	end

	return HttpService:JSONDecode(uncompressed)
end

function TradingService:AddTradeToUsersHistory(userA, userB, tradeId, InventoryA, inventoryB)
	local data = {
		User = userB.Player.UserId,
		InventoryA = InventoryA,
		InventoryB = inventoryB,
	}

	local tradeHistory = TradingService:GetUsersTradeHistory(userA)
	tradeHistory[tradeId] = data

	local DataCompressionService = knit.GetService("DataCompressionService")
	userA.Data.TradeHistory = DataCompressionService:CompressData(HttpService:JSONEncode(tradeHistory))
end

function TradingService:KnitStart()
	local UserService = knit.GetService("UserService")

	UserService.Signals.UserRemoving:Connect(function(user)
		--Remove all traces of user
		TradeHistory[user] = nil

		if TradeRequests[user] then
			TradeRequests[user] = nil
		end

		for _, usersRequests in TradeRequests do
			for id, trade in usersRequests do
				if trade.RequestingUser == user.Player.UserId then
					usersRequests[id] = nil
				end
			end
		end
	end)
end

function TradingService:KnitInit() end

return TradingService
