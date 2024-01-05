--[[
TradingController
2023, 11, 15
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)
local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local TradingController = knit.CreateController({
	Name = "TradingController",
	Signals = {
		TradeStarted = signal.new(),
		TradeEnded = signal.new(),
		StatusChanged = signal.new(),

		ItemsAdded = signal.new(),
		ItemsRemoved = signal.new(),
		TimerUpdated = signal.new(),
	},
})

local CanTradeRobux = false
local success, result = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(LocalPlayer)
end)
if not success then
	warn("Something went wrong while validating item " .. result)
else
	CanTradeRobux = result.IsPaidItemTradingAllowed
end

local CurrentTradeId = nil
local OtherInv = {}
local TradeData = {}
local Statuses = {}

local Timer = nil

function TradingController:AcceptTradeRequest(id)
	local TradingService = knit.GetService("TradingService")
	TradingService:AcceptTradeRequest(id)
end

function TradingController:SendTradeRequest(targetPlayer)
	local TradingService = knit.GetService("TradingService")
	TradingService:SendTradeRequest(targetPlayer.UserId)
end

function TradingController:IsItemTradeable(data)
	--Check if item is tradeable
	local ItemController = knit.GetController("ItemController")
	local metadata = ItemController:GetMetadata(data)

	if not CanTradeRobux and metadata[MetadataTypes.Types.Robux] then
		return false
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

function TradingController:GetTimer()
	if not Timer then
		return
	end

	return math.max(GeneralSettings.User.Trade.AcceptanceTime - math.max(tick() - Timer, 0), 0)
end

function TradingController:GetStatuses()
	return Statuses
end

function TradingController:AddItemToCurrentTrade(itemId)
	--Add item to trade
	local TradingService = knit.GetService("TradingService")
	TradingService:AddItemsToTrade({ itemId })
end

function TradingController:RemoveItemFromCurrentTrade(itemId)
	--Remove item from trade
	local TradingService = knit.GetService("TradingService")
	TradingService:RemoveItemsFromTrade({ itemId })
end

function TradingController:SetStatusForCurrentTrade(status)
	--Set local players status for trade
	local TradingService = knit.GetService("TradingService")
	TradingService:SetTradeAcceptanceStatus(status)
end

function TradingController:CancelCurrentTrade()
	--Cancel the current trade
	local TradingService = knit.GetService("TradingService")
	TradingService:CancelTrade()
end

function TradingController:GetItemFromOtherPlayer(itemId)
	--Get a item from the other players inventory
	if not OtherInv then
		return
	end

	return OtherInv[itemId]
end

function TradingController:GetOtherInv()
	return OtherInv
end

function TradingController:GetCurrentTradeStatus()
	--Get the current status for the trade
	return Statuses
end

function TradingController:GetTradeRequests()
	--Get the trade requests working for local player currently
	local CacheController = knit.GetController("CacheController")

	if not CacheController.Cache.TradeRequests then
		return {
			Sent = {},
			Recieved = {},
		}
	end

	return CacheController.Cache.TradeRequests
end

function TradingController:GetItemsInCurrentTrade()
	--Get the items in both inventories currently
	return TradeData
end

function TradingController:HasBothPlayersAccepted()
	--Check if both players have accepted the current trade
	if not TradingController:GetCurrentTrade() then
		return
	end
	if not Statuses then
		return false
	end

	for _, status in Statuses do
		if not status then
			return false
		end
	end

	return true
end

function TradingController:GetCurrentTrade()
	return CurrentTradeId
end

function TradingController:KnitStart()
	local TradingService = knit.GetService("TradingService")

	--Detect when a new trade has been started.
	TradingService.TradeId:Observe(function(id)
		warn(id)
		CurrentTradeId = id
		Timer = nil

		if not id or id == nil then
			--Trade stopped
			--Close and reset UI
			TradingController.Signals.TradeEnded:Fire()
			return
		end

		--Open UI
		TradingController.Signals.TradeStarted:Fire()
	end)

	TradingService.TradeStatus:Observe(function(statuses)
		--[[
		{
		Localplayer status,
		Other player status,
		}	
		]]

		Statuses = statuses
		TradingController.Signals.StatusChanged:Fire()

		if TradingController:HasBothPlayersAccepted() then
			Timer = tick()
		else
			Timer = nil
		end
	end)

	TradingService.CurrentTrade:Observe(function(otherPlayer)
		return
	end)

	TradingService.ItemsAdded:Connect(function(player, items)
		warn("Items add")
		print(items)
		TradingController.Signals.ItemsAdded:Fire(player == LocalPlayer, items)
	end)

	TradingService.ItemsRemoved:Connect(function(player, items)
		warn("ITem remove")
		print(items)
		TradingController.Signals.ItemsRemoved:Fire(player == LocalPlayer, items)
	end)

	RunService.RenderStepped:Connect(function(deltaTime)
		if not TradingController:GetCurrentTrade() then
			return
		end

		if not Timer then
			return
		end

		TradingController.Signals.TimerUpdated:Fire(TradingController:GetTimer())
	end)
end

function TradingController:KnitInit() end

return TradingController
