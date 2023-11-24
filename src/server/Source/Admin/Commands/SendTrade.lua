--[[
SendTrade
2023, 11, 17
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "SendTrade",
	Aliases = {},
	Description = "Send a trade to a user",
	Group = "All",
	Args = {
		{
			Type = "player",
			Name = "Target",
			Description = "The player you want to send a trade request to",
		},
	},
}
