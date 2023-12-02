--[[
init
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	["FakeBall"] = {
		DisplayName = "FAKE BALL",
		Weight = 10, --Weight used for enchanting
		Price = {
			Currency = "Cash",
			Amount = 100,
		},
		SupportedItemTypes = {
			"Knife",
		},
		Statistics = {
			[1] = {
				Balls = 1,
				Speed = 50,
				LifeTime = 5,
			},
		},

		Run = require(script.Enchants.FakeBall),
	},

	["Run"] = {
		DisplayName = "CHEETAH",
		Weight = 10, --Weight used for enchanting
		Price = { --Price for putting on enchant with book
			Currency = "Cash",
			Amount = 100,
		},
		SupportedItemTypes = {
			"Knife",
		},
		Statistics = {
			[1] = {
				SpeedBoost = 2,
			},
			[2] = {
				SpeedBoost = 5,
			},
		},

		Run = require(script.Enchants.Run),
	},

	["Jump"] = {
		DisplayName = "RABBIT",
		Weight = 10, --Weight used for enchanting
		Price = {
			Currency = "Cash",
			Amount = 100,
		},
		SupportedItemTypes = {
			"Knife",
		},
		Statistics = {
			[1] = {
				JumpBoost = 2,
			},
		},

		Run = require(script.Enchants.Jump),
	},
}
