--[[
Menu
2023, 11, 23
Created by ReelPlum (https://www.roblox.com/users/60083248/profile)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local knit = require(ReplicatedStorage.Packages.Knit)
local signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local formatNumber = require(ReplicatedStorage.Packages.FormatNumber)

local format = formatNumber.Main.NumberFormatter.with()

local Menu = {}
Menu.ClassName = "Menu"
Menu.__index = Menu

function Menu.new(template, parent)
	local self = setmetatable({}, Menu)

	self.Janitor = janitor.new()

	self.Template = template
	self.Parent = parent

	self.Signals = {
		Destroying = self.Janitor:Add(signal.new()),
	}

	self:Init()

	return self
end

function Menu:Init()
	local InputController = knit.GetController("InputController")

	if self.Template:FindFirstChild(InputController.Platform) then
		self.UI = self.Janitor:Add(self.Template:FindFirstChild(InputController.Platform):Clone())
	else
		self.UI = self.Janitor:Add(self.Template["Normal"]:Clone())
	end

	self.UI.Parent = self.Parent

	local Config = self.UI.Config
	self.InGame = Config.InGame.Value
	self.Lobby = Config.Lobby.Value
	self.InGameCash = Config.InGameCash.Value
	self.LobbyCash = Config.LobbyCash.Value
	self.ItemInventoryButton = Config.ItemInventoryButton.Value
	self.TradingButton = Config.TradingButton.Value
	self.RebirthButton = Config.RebirthButton.Value
	self.Kills = Config.Kills.Value
	self.Hits = Config.Hits.Value
	self.ExclusiveShopButton = Config.ExclusiveShopButton.Value
	self.ItemShopButton = Config.ItemShopButton.Value
	self.PlayerLevel = Config.PlayerLevel

	local GameController = knit.GetController("GameController")
	--Listen for game start / end
	-- GameController.Signals.GameChanged:Connect(function(id)
	-- 	if not id then
	-- 		--Set to lobby ui
	-- 		self.InGame.Visible = false
	-- 		self.Lobby.Visible = true

	-- 		return
	-- 	end

	-- 	--Set to ingame UI
	-- 	self.InGame.Visible = true
	-- 	self.Lobby.Visible = false
	-- end)
	-- if GameController.InGame then
	-- 	self.InGame.Visible = true
	-- 	self.Lobby.Visible = false
	-- else
	-- 	self.InGame.Visible = false
	-- 	self.Lobby.Visible = true
	-- end

	local UIController = knit.GetController("UIController")

	--Buttons
	self.Janitor:Add(self.ItemShopButton.MouseButton1Click:Connect(function()
		--Open shop
		local ui = UIController:GetUI("Shop")
		if not ui then
			return
		end
		ui:ChangePage("FrontPage")
		ui:SetVisible()
	end))

	self.Janitor:Add(self.TradingButton.MouseButton1Click:Connect(function()
		--Open trade requests
		local ui = UIController:GetUI("TradeRequest")
		if not ui then
			return
		end
		ui:SetVisible()
	end))

	self.Janitor:Add(self.RebirthButton.MouseButton1Click:Connect(function()
		--Open rebirth
		local ui = UIController:GetUI("Rebirth")
		if not ui then
			return
		end
		ui:SetVisible()
	end))

	self.Janitor:Add(self.ItemInventoryButton.MouseButton1Click:Connect(function()
		--Open Knives inv
		local ui = UIController:GetUI("Inventory")
		if not ui then
			return
		end
		ui:SetVisible()
	end))

	self.Janitor:Add(self.LobbyCash.MouseButton1Click:Connect(function()
		--Open coins shop
		local ui = UIController:GetUI("Shop")
		if not ui then
			return
		end
		--ui:OpenPage("Coins")
		ui:SetVisible()
	end))

	-- self.Janitor:Add(self.InGameCash.MouseButton1Click:Connect(function()
	-- 	--Open coins shop
	-- 	local ui = UIController:GetUI("Shop")
	-- 	if not ui then
	-- 		return
	-- 	end
	-- 	--ui:OpenPage("Coins")
	-- 	ui:SetVisible()
	-- end))

	--Displays
	local CacheController = knit.GetController("CacheController")
	self.Janitor:Add(CacheController.Signals.GameStreaksChanged:Connect(function()
		--Update the two streaks UI
		self:UpdateStreaks()
	end))
	self.Janitor:Add(CacheController.Signals.CurrenciesChanged:Connect(function()
		--Update the two coins displays
		self:UpdateCurrencies()
	end))

	self:ToggleIndicator("Knives", false)
	self:ToggleIndicator("Rebirth", false)
	self:ToggleIndicator("Shop", false)
	self:ToggleIndicator("Trading", false)

	--Listen for trade request changes.

	self:UpdateCurrencies()
	self:UpdateStreaks()

	self:SetVisible(true)
end

function Menu:ToggleIndicator(name, bool)
	local ui = self.UI.Lobby:FindFirstChild(name)
	if not ui then
		return
	end

	local indicator = ui:FindFirstChild("Indicator")
	if not indicator then
		return
	end

	indicator.Visible = bool
end

function Menu:UpdateCurrencies()
	local CacheController = knit.GetController("CacheController")

	local Currencies = CacheController.Cache.Currencies or {}
	local cash = Currencies["Cash"] or 0
	cash = math.floor(cash)

	-- self.InGameCash.Value.Text = format:Format(cash)
	self.LobbyCash.Value.Text = format:Format(cash)
end

function Menu:UpdateStreaks()
	-- local CacheController = knit.GetController("CacheController")

	-- local GameStreaks = CacheController.Cache.GameStreaks or {}
	-- local hits = GameStreaks.Hits or 0
	-- local kills = GameStreaks.Kills or 0
	-- hits = math.floor(hits)
	-- kills = math.floor(kills)

	-- self.Hits.Amount.Text = format:Format(hits)
	-- self.Kills.Amount.Text = format:Format(kills)
end

function Menu:SetVisible(bool)
	if bool == nil then
		bool = not self.Visible
	end

	self.Visible = bool
	self.UI.Visible = bool
end

function Menu:Destroy()
	self.Signals.Destroying:Fire()
	self.Janitor:Destroy()
	self = nil
end

return Menu
