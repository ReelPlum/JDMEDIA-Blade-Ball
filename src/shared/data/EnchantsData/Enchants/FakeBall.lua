--[[
FakeBall
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local janitor = require(ReplicatedStorage.Packages.Janitor)

return function(Game, Data, User, Level)
	--Listen for ball hits.
	local BallService = knit.GetService("BallService")
	local j = janitor.new()

	--If the player who hit the ball is user then spawn in a fake ball going in users direction.
	j:Add(Game.Signals.BallHit:Connect(function(user, direction)
		if user ~= User then
			return
		end

		local character = User.Player.Character
		if not character then
			return
		end

		for i = 1, Data.Statistics[Level].Balls do
			BallService:CreateFakeBall(
				character:WaitForChild("HumanoidRootPart").CFrame.Position,
				direction,
				Data.Statistics[Level].Speed,
				Data.Statistics[Level].LifeTime,
				user
			)
		end
	end))

	return j
end
