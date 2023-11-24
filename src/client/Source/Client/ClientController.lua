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
local cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local GeneralSettings = require(ReplicatedStorage.Data.GeneralSettings)

local ClientController = knit.CreateController({
	Name = "ClientController",
	Signals = {},
})

function ClientController:KnitStart()
end

function ClientController:KnitInit()
	--Initialize CMDR
	cmdr:SetActivationKeys({
		Enum.KeyCode.F4,
	})
end

return ClientController
