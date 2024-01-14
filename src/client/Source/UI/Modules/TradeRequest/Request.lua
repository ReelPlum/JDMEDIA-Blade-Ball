--[[
Request
2023, 11, 19
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Request = {}
Request.ClassName = "Request"
Request.__index = Request

function Request.new(TradeRequests, player, template)
	local self = setmetatable({}, Request)

	self.Janitor = janitor.new()

	self.TradeRequests = TradeRequests
	self.Player = player
	self.Template = template

	self.RequestId = nil
	self.Sent = false

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Request:Init()
	self.UI = self.Janitor:Add(self.Template:Clone())
	self.UI.Parent = self.TradeRequests.Holder

	local config = self.UI.Config
	self.AcceptButton = config.AcceptButton.Value
	self.DeclineButton = config.DeclineButton.Value
	self.SendButton = config.SendButton.Value
	self.SentButton = config.SentButton.Value
	self.PlayerImage = config.PlayerImage.Value
	self.UserName = config.UserName.Value
	self.DisplayName = config.DisplayName.Value
	self.Friend = config.Friend.Value

	--Buttons
	local TradingController = knit.GetController("TradingController")

	self.Janitor:Add(self.AcceptButton.MouseButton1Click:Connect(function()
		--Send trade
		TradingController:AcceptTradeRequest(self.RequestId)
	end))

	self.Janitor:Add(self.SendButton.MouseButton1Click:Connect(function()
		TradingController:SendTradeRequest(self.Player)
	end))

	--Populate UI
	self.DisplayName.Text = self.Player.DisplayName
	if self.Player.HasVerifiedBadge then
		self.UserName.Text = `@{self.Player.Name} {utf8.char(0xE000)} sent you a trade request!`
	else
		self.UserName.Text = `@{self.Player.Name} sent you a trade request!`
	end

	self.PlayerImage.Image = Players:GetUserThumbnailAsync(
		self.Player.UserId,
		Enum.ThumbnailType.AvatarThumbnail,
		Enum.ThumbnailSize.Size100x100
	)

	self.Friend.Visible = false
	task.spawn(function()
		if self.Player:IsFriendsWith(LocalPlayer.UserId) then
			self.Friend.Visible = true
		end
	end)

	self.UI.Visible = true
end

function Request:SetRecieved(bool, id)
	self.RequestId = id

	if self.Sent then
		return
	end

	if bool then
		--Show accept button
		self.SendButton.Visible = false
		self.AcceptButton.Visible = true
	else
		--Hide accept button
		self.AcceptButton.Visible = false
		self.SendButton.Visible = true
	end
end

function Request:SetSent(bool)
	self.Sent = bool

	if bool then
		--Hide send button
		self.AcceptButton.Visible = false
		self.SendButton.Visible = false
		self.SentButton.Visible = true
	else
		--Show send button
		self.SendButton.Visible = true
		self.SentButton.Visible = false
	end
end

function Request:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Request
