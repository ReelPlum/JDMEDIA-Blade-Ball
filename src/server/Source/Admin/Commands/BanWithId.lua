--[[
BanWithId
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "BanWithUserId",
	Aliases = {},
	Description = "Ban a player with their userid",
	Group = "Owner",
	Args = {
		{
			Type = "integer",
			Name = "UserId",
			Description = "The userid you want to ban",
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
