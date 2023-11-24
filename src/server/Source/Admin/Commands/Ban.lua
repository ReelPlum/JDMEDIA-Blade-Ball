--[[
Ban
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "Ban",
	Aliases = {},
	Description = "Ban a player",
	Group = "Owner",
	Args = {
		{
			Type = "player",
			Name = "Target",
			Description = "The player you want to ban",
		},
		{
			Type = "integer",
			Name = "Time",
			Description = "The time the ban should last",
		},
		{
			Type = "string",
			Name = "Reason",
			Description = "The reason for the ban",
			Default = "",
		},
	},
}
