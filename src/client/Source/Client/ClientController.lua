--[[
ClientController
2023, 10, 20
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UserService = game:GetService("UserService")
local UserInputService = game:GetService("UserInputService")
local StarterGUI = game:GetService("StarterGui")

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

local playerInfoCache = {}

function ClientController:GetPlayerInfo(userId)
	if playerInfoCache[userId] then
		return playerInfoCache[userId]
	end

	local success, info = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({
			userId,
		})
	end)
	if not success then
		return
	end
	if not info[1] then
		return
	end
	local playerInfo = info[1]
	playerInfoCache[userId] = playerInfo

	return playerInfo
end

function ClientController:KnitStart()
	-- Roblox Services
	-- Disables the Reset Button
	----[ Creates a Loop to make sure that the ResetButtonCallBack works.
	repeat
		local success = pcall(function()
			StarterGUI:SetCore("ResetButtonCallback", false)
		end)
		task.wait(1)
	until success
end

function ClientController:KnitInit()
	--Initialize CMDR
	cmdr:SetActivationKeys({
		Enum.KeyCode.F4,
	})
end

return ClientController
