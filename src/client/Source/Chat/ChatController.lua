--[[
ChatController
2023, 10, 30
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TextChatService = game:GetService("TextChatService")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)

local ItemData = require(ReplicatedStorage.Data.ItemData)

local ChatController = knit.CreateController({
	Name = "ChatController",
	Signals = {},
})

function ChatController:SendSystemMessage(message, color)
	TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(
		`<font color="rgb({math.floor(color.R * 255)},{math.floor(color.G * 255)},{math.floor(color.B * 255)})">{message}</font>`
	)
end

function ChatController:KnitStart()
	local CacheController = knit.GetController("CacheController")
	local ChatService = knit.GetService("ChatService")

	ChatService.SendMessage:Connect(function(message, color)
		ChatController:SendSystemMessage(message, color)
	end)

	TextChatService.OnIncomingMessage = function(msg)
		local Properties = Instance.new("TextChatMessageProperties")

		if not msg.TextSource then
			return
		end

		if not msg.TextSource.UserId then
			return Properties
		end

		local Player = Players:GetPlayerByUserId(msg.TextSource.UserId)
		if not Player then
			return Properties
		end

		if not CacheController.Cache.Tags then
			CacheController.Signals.TagsUpdated:Wait()
		end

		if not CacheController.Cache.Tags[tostring(msg.TextSource.UserId)] then
			return Properties
		end

		if msg.TextSource then
			local data = ItemData[CacheController.Cache.Tags[tostring(msg.TextSource.UserId)]]
			local c = data.Color

			if not c then
				return Properties
			end

			Properties.PrefixText = string.format(
				"<font color=%s>" .. data.Tag .. " %s:</font>",
				`"rgb({math.floor(c.R * 255)},{math.floor(c.G * 255)},{math.floor(c.B * 255)})"`,
				Player.DisplayName
			)
		end

		return Properties
	end
end

function ChatController:KnitInit() end

return ChatController
