--[[
GeneralSettings
2023, 10, 21
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return {
	MainCurrency = "Cash", --The main currency used in the game.

	User = {
		StartItems = {
			"TestItem",
			"DefaultTag",
			"Dash",
		},
		DefaultEquippedItems = {
			"TestItem",
			"DefaultTag",
			"Dash",
		},
		StartCurrency = {
			{
				Currency = "Cash",
				Amount = 10,
			},
		},
		StartExperience = 0,
		StartRebirth = 0,
		Trade = {
			AcceptanceTime = 5, --Time till trade completes when both players accept trade
		},
	},

	Game = {
		MinimumPlayers = 2,
		Rewards = { --Rewards rewarded to players for doing each action
			Currency = {
				["Cash"] = {
					Win = 50,
					Kill = 5,
					Hit = 0.05,
					Second = 0.001,
				},
				["Experience"] = {
					Win = 50,
					Kill = 5,
					Hit = 0.001,
					Second = 0.0001,
				},
			},
		},

		GameTimes = { --The times of the different wait times in the gameloop
			CoolDown = 1,
			Voting = 1,
			Intermission = 1,
		},
		Cooldowns = {
			Hit = 1, --The cool down for hitting the ball
			Ability = 1, --The cool down for abilities
		},
		Ball = {
			StartSpeed = 30,
			ImpulseRange = {
				X = NumberRange.new(-2, 2),
				Y = NumberRange.new(0, 2),
				Z = NumberRange.new(-2, 2),
			},
			HitRadius = 20,
			KillRadius = 2,
			BufferTime = 100 / 1000, --Seconds
			Collisions = true,
			CollisionGroup = "Ball",
		},
	},

	SystemMessages = {
		OnGamePassPurchase = true,
		OnDeveloperProductPurchase = true,
		OnGameWin = true,
		OnShowdown = true,
	},
}
