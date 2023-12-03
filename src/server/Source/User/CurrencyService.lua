--[[
CurrencyService
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local CurrencyService = knit.CreateService({
	Name = "CurrencyService",
	Client = {
		Currency = knit.CreateProperty({}),
	},
	Signals = {
		UsersCurrenciesChanged = signal.new(),
	},
})

local function GetUsersCurrencyData(user)
	user:WaitForDataLoaded()

	return user.Data.Currencies
end

local function SyncCurrencies(user) --Syncs users currency data
	task.spawn(function()
		user:WaitForDataLoaded()

		CurrencyService.Client.Currency:SetFor(user.Player, GetUsersCurrencyData(user))
	end)
end

function CurrencyService:SyncCurrency(user)
	SyncCurrencies(user)
end

function CurrencyService:GetCurrency(user, currency)
	user:WaitForDataLoaded()

	local currencies = GetUsersCurrencyData(user)
	return currencies[currency] or 0
end

function CurrencyService:UserHasEnough(user, currency, amount) --Check if user has enough of the given currency
	user:WaitForDataLoaded()

	local currencies = GetUsersCurrencyData(user)
	if not currencies[currency] then
		return false
	end

	return currencies[currency] >= amount
end

function CurrencyService:TakeCurrency(user, currency, amount, dontsync) --Takes the given amount of currency from user
	user:WaitForDataLoaded()

	if not CurrencyService:UserHasEnough(user, currency, amount) then
		return false
	end

	local currencies = GetUsersCurrencyData(user)
	currencies[currency] -= amount

	CurrencyService.Signals.UsersCurrenciesChanged:Fire(user, currency, amount)

	if dontsync then
		return true
	end
	SyncCurrencies(user)

	return true
end

function CurrencyService:GiveCurrency(user, currency, amount) --Gives user the given amount of currency
	user:WaitForDataLoaded()

	local currencies = GetUsersCurrencyData(user)
	if not currencies[currency] then
		currencies[currency] = 0
	end

	currencies[currency] += amount

	CurrencyService.Signals.UsersCurrenciesChanged:Fire(user, currency, amount)
	SyncCurrencies(user)
end

function CurrencyService:WipeCurrency(user, currency)
	user:WaitForDataLoaded()

	local currencies = GetUsersCurrencyData(user)
	currencies[currency] = 0

	CurrencyService.Signals.UsersCurrenciesChanged:Fire(user, currency, 0)
	SyncCurrencies(user)
end

function CurrencyService:KnitStart()
	local UserService = knit.GetService("UserService")

	--Sync currencies for all users
	for _, user in UserService:GetUsers() do
		SyncCurrencies(user)
	end

	UserService.Signals.UserAdded:Connect(function(user)
		SyncCurrencies(user)
	end)
end

function CurrencyService:KnitInit() end

return CurrencyService
