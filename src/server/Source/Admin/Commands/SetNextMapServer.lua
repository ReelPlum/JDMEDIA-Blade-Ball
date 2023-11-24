--[[
SetNextMapServer
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)

return function(context, nextMap)
	local GameService = knit.GetService("GameService")

	GameService:SetNextMap(nextMap)

	return `The next map will be {nextMap}!`
end
