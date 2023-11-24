--[[
PrintInventory
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "PrintInventory",
	Aliases = {},
	Description = "Print a users inventory in the output (DEBUG)",
	Group = "Owner",
	Args = {
		{
			Type = "player",
			Name = "Target",
			Description = "The players whose inventory you want printed",
		},
	},
}
