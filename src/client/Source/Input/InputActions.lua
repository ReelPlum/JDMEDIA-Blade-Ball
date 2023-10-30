--[[
InputActions
2023, 10, 29
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return {
	["Deflect"] = function()
		local GameController = knit.GetController("GameController")
		GameController:HitBall()
	end,
	["Ability"] = function()
		local GameController = knit.GetController("GameController")
		GameController:UseAbility()
	end,
}
