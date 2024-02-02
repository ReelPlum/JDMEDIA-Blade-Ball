--[[
NotificationService
2024, 01, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local NotificationService = knit.CreateService({
	Name = "NotificationService",
	Client = {
		Notification = knit.CreateSignal(),
	},
	Signals = {},
})

function NotificationService:SendNotification(user, message)
	NotificationService.Client.Notification:Fire(user.Player, message)
end

function NotificationService:KnitStart() end

function NotificationService:KnitInit() end

return NotificationService
