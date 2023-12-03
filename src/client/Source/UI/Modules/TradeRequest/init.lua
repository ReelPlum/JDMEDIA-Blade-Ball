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

function TradeRequest.new(uiTemplate)
	local self = setmetatable({}, TradeRequest)

	self.Janitor = janitor.new()

	self.UITemplate = uiTemplate

	self.Visible = false

	self.Requests = {}

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function TradeRequest:Init()
	--Create UI
	self.UI = self.Janitor:Add(ReplicatedStorage.Assets.UI.TradeRequests:Clone())
	self.UI.Parent = LocalPlayer:WaitForChild("PlayerGui")

	self.Janitor:Add(self.UI.Frame.Close.MouseButton1Click:Connect(function()
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
		warn("Got request!")
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
	warn("Updating!")

	local CacheController = knit.GetController("CacheController")
	local tradeRequests = CacheController.Cache.TradeRequests or {
		Sent = {},
		Recieved = {},
	}

	print(tradeRequests.Recieved)
	print(tradeRequests.Sent)

	for _, player in Players:GetPlayers() do
		if player == LocalPlayer then
			continue
		end
		if not self.Requests[player] then
			self.Requests[player] = request.new(self, player)
		end
	end

	for player, req in self.Requests do
		--Check if player is still in game
		if not player:IsDescendantOf(Players) then
			--Not a player anymore :( Remove them
			req:Destroy()
			self.Requests[player] = nil
			continue
		end

		print(table.find(tradeRequests.Sent, player.UserId))
		if not table.find(tradeRequests.Sent, player.UserId) then
			req:SetSent(false)
		else
			req:SetSent(true)
		end
	end

	local found = {}
	for id, data in tradeRequests.Recieved do
		local player = Players:GetPlayerByUserId(tonumber(data.RequestingUser))
		table.insert(found, player)
		print(player)

		if self.Requests[player] then
			print("recieved")
			self.Requests[player]:SetRecieved(true, id)
			continue
		end
	end

	for player, req in self.Requests do
		if table.find(found, player) then
			continue
		end
		req:SetRecieved(false)
	end
end

function TradeRequest:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.UI.Enabled = bool
	self.Visible = bool
end

function TradeRequest:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return TradeRequest
