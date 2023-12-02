--[[
CurrencyController
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local CurrencyData = require(ReplicatedStorage.Data.CurrencyData)

local CurrencyController = knit.CreateController({
	Name = "CurrencyController",
	Signals = {},
})

function CurrencyController:GetCurrencyData(currency)
	return CurrencyData[currency]
end

function CurrencyController:GetCurrencies()
	local CacheController = knit.GetController("CacheController")
	if not CacheController.Cache.Currencies then
		return {}
	end

	return CacheController.Cache.Currencies
end

function CurrencyController:GetCurrency(currency)
	local currencies = CurrencyController:GetCurrencies()
	return currencies[currency] or 0
end

function CurrencyController:KnitStart() end

function CurrencyController:KnitInit() end

return CurrencyController
