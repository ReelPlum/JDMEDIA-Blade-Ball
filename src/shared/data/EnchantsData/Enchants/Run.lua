--[[
Run
2023, 11, 16
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

return function(Game, Data, User, Level)
	if not User.Player.Character then
		return
	end

	User.Player.Character:WaitForChild("Humanoid").JumpPower = game:GetService("StarterPlayer").CharacterWalkSpeed
		* Data.Statistics[Level].SpeedBoost
end
