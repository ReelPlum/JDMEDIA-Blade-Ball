--[[
PreloadController
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ContentProvider = game:GetService("ContentProvider")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local PreloadController = knit.CreateController({
	Name = "PreloadController",
	Signals = {},
})

function PreloadController:KnitStart() end

function PreloadController:KnitInit()
	ContentProvider:PreloadAsync(ReplicatedStorage.Assets:GetDescendants(), function() end)
	warn("⭐Successfully preloaded " .. #ReplicatedStorage.Assets:GetDescendants() .. " assets!⭐")
end

return PreloadController
