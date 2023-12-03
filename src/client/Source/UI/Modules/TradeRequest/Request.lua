--[[
Request
2023, 11, 19
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Request = {}
Request.ClassName = "Request"
Request.__index = Request

function Request.new(TradeRequests, player)
	local self = setmetatable({}, Request)

	self.Janitor = janitor.new()

	self.TradeRequests = TradeRequests
	self.Player = player

	self.RequestId = nil
	self.Sent = false

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	warn(self.Player)

	self:Init()

	return self
end

function Request:Init()
	self.UI = self.Janitor:Add(self.TradeRequests.UI.PlayerTemplate:Clone())
	self.UI.Parent = self.TradeRequests.UI.Frame.Frame.ScrollingFrame
	self.UI.Visible = true
	warn("Starting up!")
	print(self.UI)

	--Buttons
	local TradingController = knit.GetController("TradingController")

	self.Janitor:Add(self.UI.Accept.MouseButton1Click:Connect(function()
		--Send trad
		TradingController:AcceptTradeRequest(self.RequestId)
	end))

	self.Janitor:Add(self.UI.Send.MouseButton1Click:Connect(function()
		TradingController:SendTradeRequest(self.Player)
	end))

	self.Janitor:Add(TradingController.Signals.TradeEnded:Connect(function()
		self.UI.Send.Visible = true
	end))
end

function Request:SetRecieved(bool, id)
	self.RequestId = id

	if self.Sent then
		return
	end

	if bool then
		--Show accept button
		self.UI.Send.Visible = false
		self.UI.Accept.Visible = true
	else
		--Hide accept button
		self.UI.Accept.Visible = false
		self.UI.Send.Visible = true
	end
end

function Request:SetSent(bool)
	self.Sent = bool

	if bool then
		--Hide send button
		self.UI.Accept.Visible = false
		self.UI.Send.Visible = false
	else
		--Show send button
		self.UI.Send.Visible = true
	end
end

function Request:Destroy()
	warn("Destroying?!")

	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Request
