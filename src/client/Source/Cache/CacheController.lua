--[[
CacheController
2023, 10, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local CacheController = knit.CreateController({
	Name = "CacheController",
	Signals = {
		TagsUpdated = signal.new(),
		EquipmentChanged = signal.new(),
		CurrenciesChanged = signal.new(),
		InventoryChanged = signal.new(),
		LevelChanged = signal.new(),
		PlayersLevelChanged = signal.new(),
		TradeRequestRecieved = signal.new(),
		GameStreaksChanged = signal.new(),
	},
	Cache = {},
})

function CacheController:KnitStart()
	local UserTagService = knit.GetService("UserTagService")
	local ItemService = knit.GetService("ItemService")
	local EquipmentService = knit.GetService("EquipmentService")
	local CurrencyService = knit.GetService("CurrencyService")
	local ExperienceService = knit.GetService("ExperienceService")
	local TradingService = knit.GetService("TradingService")
	local GameStreakService = knit.GetService("GameStreakService")

	UserTagService.UserTags:Observe(function(tags)
		self.Cache.Tags = tags
		self.Signals.TagsUpdated:Fire(tags)
	end)

	ItemService.Inventory:Observe(function(inventory)
		self.Cache.Inventory = inventory
		self.Signals.InventoryChanged:Fire(inventory)
	end)

	EquipmentService.EquippedItems:Observe(function(items)
		self.Cache.Equipment = items
		self.Signals.EquipmentChanged:Fire(items)
	end)

	CurrencyService.Currency:Observe(function(currencies)
		self.Cache.Currencies = currencies
		self.Signals.CurrenciesChanged:Fire(currencies)
	end)

	ExperienceService.Level:Observe(function(levels)
		local LocalPlayerLvl = tonumber(levels[tostring(LocalPlayer.UserId)]) or 1
		CacheController.Cache.Level = LocalPlayerLvl
		CacheController.Signals.LevelChanged:Fire()

		CacheController.Cache.PlayersLevels = levels
		CacheController.Signals.PlayersLevelChanged:Fire()
	end)

	TradingService.TradeRequests:Observe(function(requests)
		--[[
		{
			Sent = {},
			Recieved = {
				UserId
			},
		}
		]]

		CacheController.Cache.TradeRequests = requests
		CacheController.Signals.TradeRequestRecieved:Fire()
	end)

	TradingService.UntradeableUsers:Observe(function(untradeableUsers)
		CacheController.Cache.UntradeableUsers = untradeableUsers
		CacheController.Signals.TradeRequestRecieved:Fire()
	end)

	GameStreakService.Streaks:Observe(function(streaks)
		CacheController.Cache.GameStreaks = streaks
		CacheController.Signals.GameStreaksChanged:Fire()
	end)
end

function CacheController:KnitInit() end

return CacheController
