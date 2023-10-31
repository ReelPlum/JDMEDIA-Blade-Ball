--[[
ItemData
26, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	["TestItem"] = {
		DisplayName = "Test",
		ItemType = "Knife",
		Rarity = nil,

		--Item type specific
		Model = ReplicatedStorage.Assets.Models.Knives.Universe,
		Animation = "DefaultSingleDeflect",
		KnifeType = "Single", --Single or Dual.
	},

	["Dash"] = {
		DisplayName = "Test",
		ItemType = "Ability",
		Rarity = nil,

		--Item type specific
	},

	["DeveloperTag"] = {
		DisplayName = "Test",
		ItemType = "Tag",
		Rarity = nil,

		--Item type specific
		Color = Color3.fromRGB(226, 139, 26),
		Tag = "[Developer]",
	},

	["DefaultTag"] = {
		DisplayName = "Test",
		ItemType = "Tag",
		Rarity = nil,

		--Item type specific
		Color = nil,
		Tag = "",
	},
}
