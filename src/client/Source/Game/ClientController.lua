--[[
ClientController
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local ClientController = knit.CreateController({
	Name = "ClientController",
	Signals = {},
})

function ClientController:KnitStart()
	--Just simple testing
end

function ClientController:KnitInit() end

return ClientController
