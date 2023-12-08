--[[
Default
2023, 12, 08
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local debris = game:GetService("Debris")

return function(location)
	print("Boom")

	--Play effect on location
	local Explosion = Instance.new("Explosion")
	local Part = Instance.new("Part")

	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1

	Part.CFrame = CFrame.new(location)
	Part.Parent = workspace
	Explosion.Parent = Part

	debris:AddItem(Part, 5)
end
