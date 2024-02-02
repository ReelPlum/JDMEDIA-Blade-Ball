--[[
Currency
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyData = ReplicatedStorage.Data.Currencies

return function(registry)
	local currencies = {}

	for _, module in CurrencyData:GetChildren() do
		table.insert(currencies, module.Name)
	end

	local itemEnum = registry.Cmdr.Util.MakeEnumType("Currency", currencies)
	registry:RegisterType("currency", itemEnum)
end
