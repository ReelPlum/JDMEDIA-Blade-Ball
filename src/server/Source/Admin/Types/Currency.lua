--[[
Currency
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyData = require(ReplicatedStorage.Data.CurrencyData)

return function(registry)
	local currencies = {}

	for name, _ in CurrencyData do
		table.insert(currencies, name)
	end

	local itemEnum = registry.Cmdr.Util.MakeEnumType("Currency", currencies)
	registry:RegisterType("currency", itemEnum)
end
