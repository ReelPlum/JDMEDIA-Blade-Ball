--[[
EquipItem
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	Name = "EquipItem",
	Aliases = {},
	Description = "Equip item on target",
	Group = "Owner",
	Args = {
		{
			Type = "player",
			Name = "Target",
			Description = "The player you want to give the item(s)",
		},
		{
			Type = "item",
			Name = "Item",
			Description = "The items you want to give",
		},
	},
}
