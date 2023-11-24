--[[
SolidColor
2023, 11, 11
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local janitor = require(ReplicatedStorage.Packages.Janitor)

return function(data, ui)
	local j = janitor.new()

	ui.BackgroundColor3 = data.Color
	return j
end
