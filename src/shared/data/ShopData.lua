--[[
ShopData
27, 10, 2023
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetadataTypes = require(ReplicatedStorage.Data.MetadataTypes)

return {
	Bundles = {
		{
			DisplayName = "",
			Image = "",
			Price = { --If developer product then comment out price
				Amount = 10,
				Currency = "Cash",
			},
			Items = {
				--Items given on purchase
				--[[
				{
					Item: string
					Metadata: {}
				}
				]]
			},
		},
	},
	Items = {
		{

			Price = { --If developer product then comment out price
				Amount = 10,
				Currency = "Cash",
			},
			Item = {
				Item = nil,
				Metadata = {},
			}, --The item given on purchase
		},
	},
	Unboxables = {
		["Test"] = {
			DisplayName = "Test",
			Image = "",
			Price = { --If developer product then comment out price
				Amount = 10,
				Currency = "Cash",
			},
			DropList = {
				{
					Type = "Item",
					Weight = 10, --The higher the weight compared to others the higher the chance is of getting the item.
					Item = {
						Item = nil,
						Metadata = {},
					}, --The item which should be given
				},
				{
					Type = "Currency",
					Weight = 10,
					Currency = "Cash",
					Amount = 10,
				},
			},
		},

		["Rebirth"] = {
			DisplayName = "Test",
			Image = "",
			DropList = {
				{
					Type = "Item",
					Weight = 10, --The higher the weight compared to others the higher the chance is of getting the item.
					Item = {
						Item = "Dash",
						Metadata = {},
					}, --The item which should be given, --The item which should be given
				},
				{
					Type = "Item",
					Weight = 1000, --The higher the weight compared to others the higher the chance is of getting the item.
					Item = {
						Item = "EnchantmentBook",
						Metadata = {
							[MetadataTypes.Types.Enchant] = {
								"FakeBall",
								1,
							},
						},
					}, --The item which should be given, --The item which should be given
				},
				{
					Type = "Currency",
					Weight = 10,
					Currency = "Cash",
					Amount = 10,
				},
			},
		},
	},
}
