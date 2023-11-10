--[[
CacheController
2023, 10, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local CacheController = knit.CreateController({
	Name = "CacheController",
	Signals = {
		TagsUpdated = signal.new(),
		EquipmentChanged = signal.new(),
		CurrenciesChanged = signal.new(),
		InventoryChanged = signal.new(),
	},
	Cache = {},
})

function CacheController:KnitStart()
	local UserTagService = knit.GetService("UserTagService")
	local ItemService = knit.GetService("ItemService")
	local EquipmentService = knit.GetService("EquipmentService")
	local CurrencyService = knit.GetService("CurrencyService")

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
end

function CacheController:KnitInit() end

return CacheController
