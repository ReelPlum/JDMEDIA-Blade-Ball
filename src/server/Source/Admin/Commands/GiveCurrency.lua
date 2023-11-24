--[[
GiveCurrency
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "GiveCurrency",
	Aliases = {},
	Description = "Give a currency to a player",
	Group = "Owner",
	Args = {
		{
			Type = "player",
			Name = "Target",
			Description = "The player you want to give the currency to",
		},
		{
			Type = "currency",
			Name = "Currency",
			Description = "The items you want to give",
		},
		{
			Type = "integer",
			Name = "Amount",
			Description = "How much of the currency you want to give.",
		},
	},
}
