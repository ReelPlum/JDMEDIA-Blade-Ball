--[[
ItemsInInventory
2023, 11, 26
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "ItemsInInventory",
	Aliases = {},
	Description = "Get the amount of items in players inventory",
	Group = "Owner",
	Args = {
		{
			Type = "player",
			Name = "Target",
			Description = "The player whoose inventory you want to check",
		},
	},
}
