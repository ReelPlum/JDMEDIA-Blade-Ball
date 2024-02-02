--[[
TradeRequest
2023, 11, 19
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local request = require(script.Request)

local TradeRequest = {}
TradeRequest.ClassName = "TradeRequest"
TradeRequest.__index = TradeRequest
TradeRequest.UIType = "Main"

function TradeRequest.new(template, parent)
	local self = setmetatable({}, TradeRequest)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Visible = false

	self.Requests = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
		FinishedUpdating = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function TradeRequest:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	local Config = self.UI.Config
	self.CloseButton = Config.CloseButton.Value
	self.Holder = Config.Holder.Value
	self.PlayerElement = Config.PlayerElement.Value

	local done = self:Update()

	self.Janitor:Add(self.CloseButton.MouseButton1Click:Connect(function()
		self:SetVisible(false)
	end))

	--Listen for updates
	self.Janitor:Add(Players.PlayerAdded:Connect(function()
		self:Update()
	end))

	self.Janitor:Add(Players.PlayerRemoving:Connect(function()
		self:Update()
	end))

	local CacheController = knit.GetController("CacheController")
	self.Janitor:Add(CacheController.Signals.TradeRequestRecieved:Connect(function()
		self:Update()
	end))

	local TradingController = knit.GetController("TradingController")
	self.Janitor:Add(TradingController.Signals.TradeEnded:Connect(function()
		self:Update()
	end))

	--Listen for when trading UI sets visibility to true
	local UIController = knit.GetController("UIController")
	local tradingUI = UIController:GetUI("Trading")
	self.Janitor:Add(tradingUI.Signals.VisibilityChanged:Connect(function(bool)
		if bool then
			self:SetVisible(false)
		end
	end))

	self:SetVisible(false)
end

function TradeRequest:Update()
	--Update trade requests
	if self.Working then
		return
	end

	self.Working = true
	local CacheController = knit.GetController("CacheController")
	local tradeRequests = CacheController.Cache.TradeRequests or {
		Sent = {},
		Recieved = {},
	}

	warn(self.Requests)
	for _, player in Players:GetPlayers() do
		if player == LocalPlayer then
			continue
		end
		if not self.Requests[player.UserId] then
			self.Requests[player.UserId] = request.new(self, player, self.PlayerElement)
		end
	end
	warn(self.Requests)

	for userId, req in self.Requests do
		--Check if player is still in game
		if not Players:GetPlayerByUserId(userId) then
			--Not a player anymore :( Remove them
			warn("Destroying!")
			req:Destroy()
			self.Requests[userId] = nil
			continue
		end

		if not table.find(tradeRequests.Sent, userId) then
			req:SetSent(false)
		else
			req:SetSent(true)
		end
	end

	local found = {}
	for id, data in tradeRequests.Recieved do
		table.insert(found, data.RequestingUser)

		if self.Requests[data.RequestingUser] then
			self.Requests[data.RequestingUser]:SetRecieved(true, id)
			continue
		end
	end

	for userId, req in self.Requests do
		if table.find(found, userId) then
			continue
		end
		req:SetRecieved(false)
	end

	self.Working = false
end

function TradeRequest:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.UI.Visible = bool
	self.Visible = bool
end

function TradeRequest:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return TradeRequest
