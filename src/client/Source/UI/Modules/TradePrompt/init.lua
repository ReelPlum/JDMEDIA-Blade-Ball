--[[
TradePrompt
2024, 01, 14
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local TradePrompt = {}
TradePrompt.ClassName = "TradePrompt"
TradePrompt.__index = TradePrompt

function TradePrompt.new(template, parent)
	local self = setmetatable({}, TradePrompt)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Queue = {}
	self.CurrentTrade = nil

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function TradePrompt:Init()
	--UI
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	local Config = self.UI.Config
	self.AcceptButton = Config.AcceptButton.Value
	self.DeclineButton = Config.DeclineButton.Value
	self.PlayerImage = Config.PlayerImage.Value
	self.TextLabel = Config.TextLabel.Value

	--Buttons
	local TradingController = knit.GetController("TradingController")
	self.Janitor:Add(self.AcceptButton.MouseButton1Click:Connect(function()
		--Accept trade request
		if not self.CurrentTrade then
			return
		end

		TradingController:AcceptTradeRequest(self.CurrentTrade)
		self.CurrentTrade = nil
		self:CheckQueue()
	end))

	self.Janitor:Add(self.DeclineButton.MouseButton1Click:Connect(function()
		--Decline trade request
		if not self.CurrentTrade then
			return
		end

		TradingController:DeclineTradeRequest(self.CurrentTrade)
		self.CurrentTrade = nil
		self:CheckQueue()
	end))

	--Listen for events
	self.Janitor:Add(TradingController.Signals.TradeRequestRecieved:Connect(function(id)
		self:AddTradeToQueue(id)
	end))

	local UIController = knit.GetController("UIController")
	local tradingUI = UIController:GetUI("Trading")
	self.Janitor:Add(tradingUI.Signals.VisibilityChanged:Connect(function(bool)
		if bool then
			self:SetVisible(false)
			return
		end

		if self.CurrentTrade then
			self:SetVisible(true)
		end
	end))
end

function TradePrompt:AddTradeToQueue(id)
	--Adds a trade request to the queue
	table.insert(self.Queue, id)

	self:CheckQueue()
end

function TradePrompt:CheckQueue()
	--Go through requests in queue. If the trade is still valid then show it.
	if self.CurrentTrade then
		return
	end

	if not self.Queue[1] then
		self:SetVisible(false)
		return
	end

	table.remove(self.Queue, 1)
	self:PopulateUI(self.Queue[1])
end

function TradePrompt:PopulateUI(id)
	--Populate UI with data for the given trade
	local TradingController = knit.GetController("TradingController")
	local CacheController = knit.GetController("CacheController")

	--Get data for trade request
	if not CacheController.TradeRequests then
		self:CheckQueue()
		return
	end

	local data = CacheController.TradeRequests.Recieved[id]
	if not data then
		self:CheckQueue()
		return
	end

	local player = Players:GetPlayerByUserId(data.RequestingUser)

	if player.HasVerifiedBadge then
		self.TextLabel.Text = `@{player.Name} {utf8.char(0xE000)} sent you a trade request!`
	else
		self.TextLabel.Text = `@{player.Name} sent you a trade request!`
	end

	if self.PlayerImage then
		self.PlayerImage.Image = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.AvatarThumbnail,
			Enum.ThumbnailSize.Size100x100
		)
	end

	local UIController = knit.GetController("UIController")
	local tradingUI = UIController:GetUI("Trading")
	if tradingUI.Visible then
		self:SetVisible(false)
		return
	end

	self:SetVisible(true)
end

function TradePrompt:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = self.Visible
end

function TradePrompt:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return TradePrompt
