--[[
ChatService
2023, 10, 31
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local ChatService = knit.CreateService({
	Name = "ChatService",
	Client = {
		SendMessage = knit.CreateSignal(),
	},
	Signals = {},
})

function ChatService:SendSystemMessage(message)
	ChatService.Client.SendMessage:FireAll(message, Color3.fromRGB(255, 145, 19))
end

function ChatService:KnitStart() end

function ChatService:KnitInit() end

return ChatService
