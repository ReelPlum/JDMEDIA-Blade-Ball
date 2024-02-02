--[[
NotificationController
2024, 01, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local NotificationController = knit.CreateController({
	Name = "NotificationController",
	Signals = {
		RecievedNotification = signal.new(),
	},
})

function NotificationController:KnitStart()
	--Listen for server
	local NotificationService = knit.GetService("NotificationService")

	NotificationService.Notification:Connect(function(message)
		NotificationController.Signals.RecievedNotification:Fire(message)
	end)
end

function NotificationController:KnitInit() end

return NotificationController
