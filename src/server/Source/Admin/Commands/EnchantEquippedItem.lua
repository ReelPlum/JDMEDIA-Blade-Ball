--[[
EnchantEquippedItem
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "EnchantEquippedItem",
	Aliases = {},
	Description = "Enchant players currently equipped item of type",
	Group = "Owner",
	Args = {
		{
			Type = "player",
			Name = "Target",
			Description = "The player whose item you want to enchant",
		},
		{
			Type = "itemType",
			Name = "ItemType",
			Description = "The type of item to look for",
		},
	},
}
