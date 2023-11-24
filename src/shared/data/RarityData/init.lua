--[[
RarityData
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Effects = script.Effects
local SolidColorEffect = require(Effects.SolidColor)
local RainbowEffect = require(Effects.Rainbow)

return {
	["Common"] = {
		DisplayName = "Common",
		Effect = SolidColorEffect,
		Color = Color3.fromRGB(207, 27, 27),
	},

	["Rare"] = {
		DisplayName = "Rare",
		Effect = SolidColorEffect,
		Color = Color3.fromRGB(255, 255, 255),
	},

	["Mythical"] = {
		DisplayName = "Mythical",
		Effect = SolidColorEffect,
		Color = Color3.fromRGB(255, 255, 255),
	},

	["Immortal"] = {
		DisplayName = "Immortal",
		Effect = SolidColorEffect,
		Color = Color3.fromRGB(255, 255, 255),
	},

	["RainbowImmortal"] = {
		DisplayName = "Immortal",
		Effect = RainbowEffect,
	},
}
