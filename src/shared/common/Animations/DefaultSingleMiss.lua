--[[
Hit
2023, 10, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local janitor = require(ReplicatedStorage.Packages.Janitor)
local knit = require(ReplicatedStorage.Packages.Knit)

return function(user)
	--Play hit animation on character
	local animation = ReplicatedStorage.Assets.Animations.DefaultMiss

	local track = user.Player.Character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(animation)

	local j = janitor.new()

	local holsteredKnife = user.Player.Character:FindFirstChild("EquippedKnife")
	if not holsteredKnife then
		track:Play()

		user.ExtendedCharacter:EquipKnife()
		warn("trying to equip knife again..")

		return
	end

	track.Stopped:Connect(function()
		--Stopped for some reason?
		track:Destroy()
	end)

	track.Ended:Connect(function()
		--Finished.
		j:Cleanup()

		track:Destroy()
	end)

	track:Play()
end
