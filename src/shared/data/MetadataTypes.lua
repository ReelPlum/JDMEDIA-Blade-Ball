--[[
MetadataTypes
2023, 11, 02
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Types = {
	OriginalPurchaser = "1",
	Untradeable = "2",
	UnboxedBy = "3",
	Unboxable = "4",
	Bundle = "5",
	Admin = "6",
	Robux = "7",
	Enchants = "8",
	Enchant = "9",
}

local Data = {
	[Types.Robux] = {
		BoughtWithRobux = true,
	},
	[Types.Untradeable] = {
		Untradeable = true,
	},
}

local function TypeToString(type)
	for index, t in Types do
		if t == type then
			return index
		end
	end
end

return {
	Types = Types,
	Data = Data,
	TypeToString = TypeToString,
}
