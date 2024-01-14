--[[
TradingService
2023, 11, 05
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")
local PolicyService = game:GetService("PolicyService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Trade = require(script.Parent.Trade)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

local TradingService = knit.CreateService({
	Name = "TradingService",
	Client = {
		CurrentTrade = knit.CreateProperty({}),
		TradeStatus = knit.CreateProperty({}),
		TradeId = knit.CreateProperty(nil),

		ItemsAdded = knit.CreateSignal(),
		ItemsRemoved = knit.CreateSignal(),

		GotTradeRequest = knit.CreateSignal(),
		TradeRequests = knit.CreateProperty({ Sent = {}, Recieved = {} }),
		UntradeableUsers = knit.CreateProperty({}),
	},
	Signals = {},
})

local TradeRequests = {}
local Trades = {}
local UntradeableUsers = {}

function TradingService.Client:AddItemsToTrade(player, itemIds)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	if not typeof(itemIds) == "table" then
		return
	end

	if #itemIds <= 0 then
		return
	end

	TradingService:AddItemsToTrade(user, itemIds)
end

function TradingService.Client:RemoveItemsFromTrade(player, itemIds)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	if not typeof(itemIds) == "table" then
		return
	end

	if #itemIds <= 0 then
		return
	end

	TradingService:RemoveItemsFromTrade(user, itemIds)
end

function TradingService.Client:SetTradeAcceptanceStatus(player, status)
	if not typeof(status) == "boolean" then
		return
	end

	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)
	TradingService:SetTradeAcceptanceStatus(user, status)
end

function TradingService.Client:CancelTrade(player)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	TradingService:CancelTrade(user)
end

function TradingService.Client:SendTradeRequest(player, targetUserId)
	local UserService = knit.GetService("UserService")
	local userA = UserService:WaitForUser(player)

	local userB = UserService:GetUserFromUserId(targetUserId)
	if not userB then
		return
	end

	TradingService:RequestTrade(userA, userB)
end

function TradingService.Client:AcceptTradeRequest(player, requestId)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	TradingService:AcceptTradeRequest(user, requestId)
end

function TradingService.Client:DeclineTradeRequest(player, requestId)
	local UserService = knit.GetService("UserService")
	local user = UserService:WaitForUser(player)

	TradingService:DeclineTradeRequest(user, requestId)
end

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
	if userA.Player == userB.Player then
		return
	end

	if not TradeRequests[userB] then
		TradeRequests[userB] = {
			Recieved = {},
			Sent = {},
		}
	end
	if not TradeRequests[userA] then
		TradeRequests[userA] = {
			Recieved = {},
			Sent = {},
		}
	end

	if not TradingService:UserCanSendTradeRequestToUser(userA, userB) then
		--Notify UserA

		return
	end

	--Check if UserA already sent a request
	if table.find(TradeRequests[userA].Sent, userB.Player.UserId) then
		return
	end

	--Check if USerB sent a request
	if table.find(TradeRequests[userB].Sent, userA.Player.UserId) then
		return
	end

	--Request trade.
	local id = HttpService:GenerateGUID(false)

	local request = {
		RequestingUser = userA.Player.UserId,
		Time = DateTime.now().UnixTimestamp,
	}

	TradeRequests[userB].Recieved[id] = request
	table.insert(TradeRequests[userA].Sent, userB.Player.UserId)

	TradingService.Client.TradeRequests:SetFor(userB.Player, TradeRequests[userB])
	TradingService.Client.TradeRequests:SetFor(userA.Player, TradeRequests[userA])

	TradingService.Client.GotTradeRequest:Fire(userB.Player, id)
end

function TradingService:AcceptTradeRequest(userB, tradeId)
	--Accepts trade with Id
	if not TradeRequests[userB] then
		return
	end

	if not TradeRequests[userB].Recieved[tradeId] then
		return
	end

	--Get UserA
	local UserService = knit.GetService("UserService")
	local userA = UserService:GetUserFromUserId(TradeRequests[userB].Recieved[tradeId].RequestingUser)
	if not userA then
		TradeRequests[userB].Recieved[tradeId] = nil
		return
	end
	local index = table.find(TradeRequests[userA].Sent, userB.Player.UserId)
	if not index then
		return
	end

	--Checks are done. Now we start the trade!
	TradingService:StartTrade(userA, userB)

	TradeRequests[userB].Recieved[tradeId] = nil
	table.remove(TradeRequests[userA].Sent, index)

	TradingService.Client.TradeRequests:SetFor(userB.Player, TradeRequests[userB])
	TradingService.Client.TradeRequests:SetFor(userA.Player, TradeRequests[userA])
end

function TradingService:DeclineTradeRequest(userB, tradeId)
	--Declines trade request
	if not TradeRequests[userB] then
		return warn("No request found for userB")
	end

	if not TradeRequests[userB].Recieved[tradeId] then
		return warn("TradeId not found...")
	end

	local UserService = knit.GetService("UserService")
	local userA = UserService:GetUserFromUserId(TradeRequests[userB].Recieved[tradeId].RequestingUser)
	if not userA then
		TradeRequests[userB].Recieved[tradeId] = nil
		return
	end
	local index = table.find(TradeRequests[userA].Sent, userB.Player.UserId)
	if not index then
		return
	end

	TradeRequests[userB].Recieved[tradeId] = nil
	table.remove(TradeRequests[userA].Sent, index)

	TradingService.Client.TradeRequests:SetFor(userB.Player, TradeRequests[userB])
	TradingService.Client.TradeRequests:SetFor(userA.Player, TradeRequests[userA])
end

function TradingService:StartTrade(userA, userB)
	if userA.CurrentTrade or userB.CurrentTrade then
		return
	end

	local FFlagService = knit.GetService("FFlagService")
	local disabled = FFlagService:GetFFlag("Trading")
	if disabled then
		--Tell players that trading is disabled at the moment

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

	user.CurrentTrade:SetAcceptanceStatus(user, status)
end

function TradingService:CancelTrade(user)
	--Cancels trade and gets user out of trade
	if not user.CurrentTrade then
		return
	end

	user.CurrentTrade:Cancel(user)
end

function TradingService:AddItemsToTrade(user, itemIds)
	--Adds item with Id to trade
	if not user.CurrentTrade then
		return
	end

	user.CurrentTrade:AddItem(user, itemIds)
end

function TradingService:ValidateItemForTrade(user, itemId)
	--Validates if item can be used in trade
	local ItemService = knit.GetService("ItemService")
	local data = ItemService:GetUsersDataFromId(user, itemId)

	--Check if item is bought with robux
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(user.Player)
	end)
	if not success then
		warn("❗Something went wrong while validating item " .. result)
		return
	end

	local metadata = ItemService:GetMetadataFromItem(data)
	if not result.IsPaidItemTradingAllowed and metadata[MetadataTypes.Types.Robux] then
		return
	end

	--Check other metadata
	for t, v in metadata do
		local d = MetadataTypes.Data[t]
		if d then
			if d.Untradeable then
				return false
			end
		end
	end

	return true
end

function TradingService:RemoveItemsFromTrade(user, itemIds)
	--Removes item from trade
	if not user.CurrentTrade then
		return
	end

	user.CurrentTrade:RemoveItem(user, itemIds)
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

		for otherUser, usersRequests in TradeRequests do
			local somethingChanged = false
			for id, trade in usersRequests.Recieved do
				if trade.RequestingUser == user.Player.UserId then
					somethingChanged = true
					usersRequests[id] = nil
				end
			end

			local index = table.find(usersRequests.Sent, user.Player.UserId)
			if index then
				table.remove(usersRequests.Sent, index)
				somethingChanged = true
			end

			if somethingChanged then
				TradingService.Client.TradeRequests:SetFor(otherUser.Player, TradeRequests[otherUser])
			end
		end

		local index = table.find(UntradeableUsers, user.Player.UserId)
		if index then
			table.remove(UntradeableUsers, index)
			TradingService.Client.UntradeableUsers:Set(UntradeableUsers)
		end
	end)

	--Listen for trade setting change.
end

function TradingService:KnitInit() end

return TradingService
