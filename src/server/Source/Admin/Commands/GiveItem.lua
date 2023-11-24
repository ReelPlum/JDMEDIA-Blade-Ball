--[[
GiveItem
2023, 11, 09
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "GiveItem",
	Aliases = { "gi", "itemgive", "giveawayitem", "ImAGenerousAdminLol", "DestroyTradingEconomy", "plsitem" },
	Description = "Give items to a player",
	Group = "Owner",
	Args = {
		{
			Type = "player",
			Name = "Reciever",
			Description = "The player you want to give the item(s)",
		},
		{
			Type = "items",
			Name = "Items",
			Description = "The items you want to give",
		},
		{
			Type = "integers",
			Name = "Quantaties",
			Description = "The amount of each item you want to give the reciever",
			Optional = true,
		},
	},
}
