--[[
Classic
2023, 11, 05
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return {
	Name = "Classic",

	Run = function(Game)
		--Run gamemode
		local BallService = knit.GetService("BallService")
		Game.Ball = BallService:CreateNewBall(Game.CurrentMap.BallSpawn.CFrame, Game)

		Game.Janitor:Add(Game.Ball.Signals.HitTarget:Connect(function(user)
			Game:UserHit(user)
		end))
	end,
}
