--[[
ItemData
26, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	["TestItem"] = {
		DisplayName = "Knife",
		ItemType = "Knife",
		Rarity = "RainbowImmortal",
		Season = "Test",

		Image = "",

		Tags = {
			"Test", --Used to describe item. Can be used to filter in items etc. at a later data
		},

		--Item type specific
		Model = ReplicatedStorage.Assets.Models.Knives.DefaultKnife,
		Animation = "DefaultSingleDeflect",
		KnifeType = "Single", --Single or Dual.
	},

	["Dash"] = {
		DisplayName = "Dash",
		ItemType = "Ability",
		Rarity = "Common",
		Season = "Test",

		Image = "",

		Tags = {
			"Test",
		},

		--Item type specific
	},

	["DeveloperTag"] = {
		DisplayName = "Developer Tag",
		ItemType = "Tag",
		Rarity = "Common",
		Season = "Test",

		Image = "",

		Tags = {
			"Test",
		},

		--Item type specific
		Color = Color3.fromRGB(226, 139, 26),
		Tag = "[Developer]",
	},

	["DefaultTag"] = {
		DisplayName = "Default Tag",
		ItemType = "Tag",
		Rarity = "Common",
		Season = "Test",

		Image = "",

		Tags = {
			"Test",
		},

		--Item type specific
		Color = nil,
		Tag = "",
	},

	["DefaultBall"] = {
		DisplayName = "Ball",
		ItemType = "Ball",
		Rarity = "Common",
		Season = "Test",

		Image = "",

		Tags = {
			"Test", --Used to describe item. Can be used to filter in items etc. at a later data
		},

		Model = ReplicatedStorage.Assets.Models.Balls:WaitForChild("DefaultBall"),
	},
}
